import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/routine_provider.dart';
import '../../models/routine_model.dart';

class RoutineScreen extends StatefulWidget {
  const RoutineScreen({super.key});

  @override
  State<RoutineScreen> createState() => _RoutineScreenState();
}

class _RoutineScreenState extends State<RoutineScreen> {
  final _titleCtrl = TextEditingController();
  String _category = 'morning';
  TimeOfDay _time = const TimeOfDay(hour: 8, minute: 0);
  final List<bool> _days = [true, true, true, true, true, false, false];
  String? _editingId;
  String? _selectedCoverImage;

  final List<Map<String, dynamic>> _cats = [
    {'key': 'morning', 'label': 'Morning', 'color': Color(0xFFE3B15F), 'emoji': '🌅'},
    {'key': 'afternoon', 'label': 'Afternoon', 'color': Color(0xFF2C9BD6), 'emoji': '☀️'},
    {'key': 'evening', 'label': 'Evening', 'color': Color(0xFFB9A8DD), 'emoji': '🌇'},
    {'key': 'night', 'label': 'Night', 'color': Color(0xFF063A5E), 'emoji': '🌙'},
  ];

  final List<String> _dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  final List<String> _coverOptions = [
    'https://images.unsplash.com/photo-1506126613408-eca07ce68773?w=400&q=80',
    'https://images.unsplash.com/photo-1519834785169-98be25ec3f84?w=400&q=80',
    'https://images.unsplash.com/photo-1545205597-3d9d02c29597?w=400&q=80',
    'https://images.unsplash.com/photo-1515023115689-589c33041697?w=400&q=80',
  ];

  void _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(primary: Color(0xFF0B6FA8)),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _time = picked);
  }

  void _saveRoutine() {
    if (_titleCtrl.text.trim().isEmpty) return;
    final timeStr = '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';
    final provider = context.read<RoutineProvider>();
    
    if (_editingId != null) {
      final existing = provider.routines.firstWhere((r) => r.id == _editingId);
      provider.updateRoutine(Routine(
        id: _editingId!,
        title: _titleCtrl.text.trim(),
        category: _category,
        time: timeStr,
        days: List.from(_days),
        coverImage: _selectedCoverImage ?? existing.coverImage,
        isCompleted: existing.isCompleted,
        completedAt: existing.completedAt,
        moodScore: existing.moodScore,
      ));
    } else {
      provider.addRoutine(
        title: _titleCtrl.text.trim(),
        category: _category,
        time: timeStr,
        days: List.from(_days),
        coverImage: _selectedCoverImage,
      );
    }
    _clearForm();
    Navigator.pop(context);
  }

  void _clearForm() {
    _titleCtrl.clear();
    _category = 'morning';
    _time = const TimeOfDay(hour: 8, minute: 0);
    _selectedCoverImage = null;
    setState(() {
      _days.setAll(0, [true, true, true, true, true, false, false]);
      _editingId = null;
    });
  }

  void _editRoutine(Routine r) {
    _editingId = r.id;
    _titleCtrl.text = r.title;
    _category = r.category;
    _selectedCoverImage = r.coverImage;
    final parts = r.time.split(':');
    _time = TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    setState(() {
      for (int i = 0; i < 7; i++) { _days[i] = r.days[i];}
    });
    _showForm();
  }

  void _showForm() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            top: 20, left: 20, right: 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(
                  child: Container(width: 40, height: 4, 
                    decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
                ),
                const SizedBox(height: 16),
                Text(_editingId != null ? '✏️ Edit Routine' : '➕ New Routine', 
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF233238))),
                const SizedBox(height: 20),
                
                // Title
                TextField(
                  controller: _titleCtrl,
                  decoration: InputDecoration(
                    hintText: 'e.g. Morning Meditation',
                    filled: true,
                    fillColor: const Color(0xFFF1ECFA),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Category — FIXED: uses setModalState now
                const Text('Category', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF233238))),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  children: _cats.map((c) => ChoiceChip(
                    label: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('${c['emoji']} ', style: const TextStyle(fontSize: 14)),
                      Text(c['label'], style: TextStyle(
                        color: _category == c['key'] ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.w600,
                      )),
                    ]),
                    selected: _category == c['key'],
                    selectedColor: c['color'],
                    backgroundColor: const Color(0xFFF1ECFA),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    onSelected: (_) => setModalState(() => _category = c['key']),
                  )).toList(),
                ),
                const SizedBox(height: 20),
                
                // Time
                const Text('Time', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF233238))),
                const SizedBox(height: 10),
                InkWell(
                  onTap: () async {
                    _pickTime();
                    setModalState(() {});
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1ECFA),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(children: [
                      const Icon(Icons.access_time, color: Color(0xFF0B6FA8)),
                      const SizedBox(width: 12),
                      Text(_time.format(context), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Days
                const Text('Repeat Days', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF233238))),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (i) => GestureDetector(
                    onTap: () => setModalState(() => _days[i] = !_days[i]),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _days[i] ? const Color(0xFF0B6FA8) : const Color(0xFFF1ECFA),
                        shape: BoxShape.circle,
                      ),
                      child: Center(child: Text(_dayLabels[i], 
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, 
                          color: _days[i] ? Colors.white : Colors.black87))),
                    ),
                  )),
                ),
                const SizedBox(height: 24),
                
                // Cover Image Picker
                const Text('Cover Image', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Color(0xFF233238))),
                const SizedBox(height: 10),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      // None option (Blue default)
                      GestureDetector(
                        onTap: () => setModalState(() => _selectedCoverImage = null),
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF0B6FA8), Color(0xFF2C9BD6)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            border: _selectedCoverImage == null 
                              ? Border.all(color: const Color(0xFFE3B15F), width: 3)
                              : null,
                          ),
                          child: const Center(child: Text('🎨\nDefault', 
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold))),
                        ),
                      ),
                      // Image options
                      ..._coverOptions.map((url) => GestureDetector(
                        onTap: () => setModalState(() => _selectedCoverImage = url),
                        child: Container(
                          width: 80,
                          margin: const EdgeInsets.only(right: 10),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: _selectedCoverImage == url
                              ? Border.all(color: const Color(0xFFE3B15F), width: 3)
                              : null,
                            image: DecorationImage(
                              image: NetworkImage(url),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      )),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saveRoutine,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B6FA8),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                      elevation: 4,
                    ),
                    child: Text(_editingId != null ? 'Update Routine' : 'Save Routine', 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                const SizedBox(height: 16),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Color _catColor(String cat) {
    switch(cat) {
      case 'morning': return const Color(0xFFE3B15F);
      case 'afternoon': return const Color(0xFF2C9BD6);
      case 'evening': return const Color(0xFFB9A8DD);
      case 'night': return const Color(0xFF063A5E);
      default: return const Color(0xFF0B6FA8);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoutineProvider>();
    final routines = provider.routines;
    
    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('🗓 Daily Routine', 
          style: TextStyle(color: Color(0xFF233238), fontWeight: FontWeight.bold, fontSize: 17)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle, color: Color(0xFF0B6FA8), size: 30),
            onPressed: () { _clearForm(); _showForm(); },
          ),
        ],
      ),
      body: routines.isEmpty
        ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFF1ECFA),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.calendar_today_outlined, size: 56, color: Color(0xFFB9A8DD)),
            ),
            const SizedBox(height: 20),
            const Text('No routines yet', 
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF233238))),
            const SizedBox(height: 8),
            const Text('Add your own routines to get started', 
              style: TextStyle(fontSize: 13, color: Color(0xFF7C8A90))),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () { _clearForm(); _showForm(); },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0B6FA8),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
              ),
              child: const Text('Add First Routine', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: routines.length,
            itemBuilder: (_, i) {
              final r = routines[i];
              final hasCover = r.coverImage != null && r.coverImage!.isNotEmpty;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                height: 110,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha : 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Background: Cover image or blue gradient
                      if (hasCover)
                        Positioned.fill(
                          child: Image.network(
                            r.coverImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF0B6FA8), Color(0xFF2C9BD6)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                        )
                      else
                        Positioned.fill(
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [_catColor(r.category).withValues(alpha : 0.8), _catColor(r.category)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                          ),
                        ),
                      
                      // Glass overlay
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: hasCover ? 3 : 0, sigmaY: hasCover ? 3 : 0),
                          child: Container(
                            color: hasCover 
                              ? Colors.black.withValues(alpha : 0.25) 
                              : Colors.transparent,
                          ),
                        ),
                      ),
                      
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            // Icon box
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.white30),
                              ),
                              child: const Icon(Icons.self_improvement, color: Colors.white, size: 22),
                            ),
                            const SizedBox(width: 14),
                            
                            // Text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(r.title, 
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: Colors.white24,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(r.time, 
                                      style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    r.days.asMap().entries.where((e) => e.value).map((e) => _dayLabels[e.key]).join(', '),
                                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Actions
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _glassIconButton(Icons.edit, () => _editRoutine(r)),
                                const SizedBox(height: 6),
                                _glassIconButton(Icons.delete, () => provider.deleteRoutine(r.id)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }

  Widget _glassIconButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: Colors.white24,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white30),
        ),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}