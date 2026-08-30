
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/routine_provider.dart';
import '../../models/history_model.dart';

// ═══════════════════════════════════════════════════════════════
//  FAKE SESSIONS MODEL (Chat / Audio) — future mein real hoga
// ═══════════════════════════════════════════════════════════════
class FakeSession {
  final String id;
  final String title;
  final String type; // 'chat' | 'audio'
  final DateTime completedAt;
  final String transcriptSnippet;

  FakeSession({
    required this.id,
    required this.title,
    required this.type,
    required this.completedAt,
    required this.transcriptSnippet,
  });
}

// ═══════════════════════════════════════════════════════════════
//  SCREEN
// ═══════════════════════════════════════════════════════════════
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // ── fake chat / audio sessions (future mein API se ayega) ──
  late final List<FakeSession> _fakeSessions;

  // ── FILTER STATE ──
  String _filter = 'all'; // 'all' | 'task' | 'chat' | 'audio'

  @override
  void initState() {
    super.initState();
    _fakeSessions = _generateFakeSessions();
  }

  List<FakeSession> _generateFakeSessions() {
    final now = DateTime.now();
    return [
      FakeSession(
        id: 'c1',
        title: 'Chat Session #1',
        type: 'chat',
        completedAt: now.subtract(const Duration(hours: 2)),
        transcriptSnippet: 'Hey, I have been feeling a bit anxious lately...',
      ),
      FakeSession(
        id: 'a1',
        title: 'Audio Session #1',
        type: 'audio',
        completedAt: now.subtract(const Duration(hours: 5)),
        transcriptSnippet: 'Let us try a quick breathing exercise together...',
      ),
      FakeSession(
        id: 'c2',
        title: 'Chat Session #2',
        type: 'chat',
        completedAt: now.subtract(const Duration(days: 1, hours: 3)),
        transcriptSnippet: 'Today felt a little better after the walk...',
      ),
      FakeSession(
        id: 'a2',
        title: 'Audio Session #2',
        type: 'audio',
        completedAt: now.subtract(const Duration(days: 2, hours: 4)),
        transcriptSnippet: 'You are doing great. Keep showing up for yourself...',
      ),
      FakeSession(
        id: 'c3',
        title: 'Chat Session #3',
        type: 'chat',
        completedAt: now.subtract(const Duration(days: 3, hours: 1)),
        transcriptSnippet: 'I managed to complete my morning routine today!',
      ),
    ];
  }

  // ── helpers ──
  Color _catColor(String cat) {
    switch (cat) {
      case 'morning':   return const Color(0xFFE3B15F);
      case 'afternoon': return const Color(0xFF2C9BD6);
      case 'evening':   return const Color(0xFFB9A8DD);
      case 'night':     return const Color(0xFF063A5E);
      case 'chat':      return const Color(0xFF8B5CF6);
      case 'audio':     return const Color(0xFF10B981);
      default:          return const Color(0xFF0B6FA8);
    }
  }

  String _catEmoji(String cat) {
    switch (cat) {
      case 'morning':   return '🌅';
      case 'afternoon': return '☀️';
      case 'evening':   return '🌇';
      case 'night':     return '🌙';
      case 'chat':      return '💬';
      case 'audio':     return '🎙️';
      default:          return '✨';
    }
  }

  // ── filter chip helper ──
  Widget _buildFilterChip(String label, String value, String emoji) {
    final isSelected = _filter == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text('$emoji $label'),
        selected: isSelected,
        onSelected: (_) => setState(() => _filter = value),
        selectedColor: const Color(0xFF0B6FA8),
        backgroundColor: Colors.white,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: isSelected ? Colors.white : const Color(0xFF233238),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
          side: BorderSide(
            color: isSelected ? const Color(0xFF0B6FA8) : const Color(0xFFE0E0E0),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        showCheckmark: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoutineProvider>();
    final realHistory = provider.history;
    final last7Real = provider.getHistoryForLastDays(7);

    // ── REAL stats (sirf routine se) ──
    final streak = provider.getCurrentStreak();
    final catCounts = provider.getCategoryCounts();
    final daily = provider.getDailyCompletionCounts();

    // ── TASK COUNTING (real routines only) ──
    final taskCount = realHistory.length;

    // ── OVERALL PERFORMANCE ──
    // Performance = avg mood + (streak * 5), capped at 100
    final avgMood = realHistory.isEmpty
        ? 0.0
        : realHistory.map((h) => h.moodScore).reduce((a, b) => a + b) / realHistory.length;
    final performance = realHistory.isEmpty
        ? 0
        : ((avgMood + (streak * 5)).clamp(0, 100)).toInt();

    // ── last 7 days list (today → 6 days ago) ──
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) {
      return DateTime(now.year, now.month, now.day).subtract(Duration(days: 6 - i));
    });

    // ── bar chart data (REAL routine data only) ──
    final barGroups = weekDays.asMap().entries.map((e) {
      final count = daily[e.value] ?? 0;
      return BarChartGroupData(
        x: e.key,
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: const Color(0xFF0B6FA8),
            width: 14,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 5,
              color: const Color(0xFFF1ECFA),
            ),
          ),
        ],
      );
    }).toList();

    // ── line chart data: REAL avg mood per day ──
    final moodSpots = weekDays.asMap().entries.map((e) {
      final dayEntries = last7Real.where((h) {
        final hd = DateTime(h.completedAt.year, h.completedAt.month, h.completedAt.day);
        return hd == e.value;
      }).toList();
      final avg = dayEntries.isEmpty
          ? 0.0
          : dayEntries.map((h) => h.moodScore).reduce((a, b) => a + b) / dayEntries.length;
      return FlSpot(e.key.toDouble(), avg);
    }).toList();

    // ── pie chart data (REAL routine categories only) ──
    final pieSections = catCounts.entries.toList().asMap().entries.map((e) {
      final colors = [
        const Color(0xFFE3B15F),
        const Color(0xFF2C9BD6),
        const Color(0xFFB9A8DD),
        const Color(0xFF063A5E),
      ];
      return PieChartSectionData(
        color: colors[e.key % colors.length],
        value: e.value.value.toDouble(),
        title: '${e.value.value}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    // ── MIXED recent sessions (real + fake) ──
    final mixedSessions = _buildMixedSessions(realHistory, _fakeSessions);

    // ── FILTERED sessions ──
    final filteredSessions = mixedSessions.where((item) {
      if (_filter == 'all') return true;
      if (_filter == 'task') return item is HistoryEntry;
      // if (_filter == 'chat') return item is FakeSession && (item as FakeSession).type == 'chat';
      // if (_filter == 'audio') return item is FakeSession && (item as FakeSession).type == 'audio';
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFBF9F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          '📈 Progress & History',
          style: TextStyle(
            color: Color(0xFF233238),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
      body: realHistory.isEmpty && _fakeSessions.isEmpty
          ? _buildEmptyState(context)
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ═══════════════════════════════════════
                  //  SUMMARY CARDS
                  // ═══════════════════════════════════════
                  Row(
                    children: [
                      _StatCard(
                        icon: '🔥',
                        label: 'Streak',
                        value: '$streak day${streak == 1 ? '' : 's'}',
                        color: const Color(0xFFE3B15F),
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: '✅',
                        label: 'Tasks',
                        value: '$taskCount',
                        color: const Color(0xFF2C9BD6),
                      ),
                      const SizedBox(width: 10),
                      _StatCard(
                        icon: '📊',
                        label: 'Performance',
                        value: '$performance%',
                        color: const Color(0xFF10B981),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ═══════════════════════════════════════
                  //  WEEKLY ACTIVITY BAR CHART (REAL)
                  // ═══════════════════════════════════════
                  const _SectionTitle('Weekly Activity'),
                  const SizedBox(height: 8),
                  _ChartCard(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        maxY: 5,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              final date = weekDays[group.x];
                              return BarTooltipItem(
                                '${DateFormat.E().format(date)}\n${rod.toY.toInt()} done',
                                const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              );
                            },
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final d = weekDays[v.toInt()];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    DateFormat.E().format(d)[0],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF7C8A90),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: barGroups,
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ═══════════════════════════════════════
                  //  MOOD TREND LINE CHART (REAL)
                  // ═══════════════════════════════════════
                  const _SectionTitle('Mood Trend'),
                  const SizedBox(height: 8),
                  _ChartCard(
                    height: 180,
                    child: LineChart(
                      LineChartData(
                        minY: 0,
                        maxY: 100,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: 25,
                          getDrawingHorizontalLine: (_) => const FlLine(
                            color: Color(0xFFF1ECFA),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                if (v.toInt() < 0 || v.toInt() >= weekDays.length) {
                                  return const SizedBox();
                                }
                                final d = weekDays[v.toInt()];
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    DateFormat.E().format(d)[0],
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Color(0xFF7C8A90),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 25,
                              getTitlesWidget: (v, _) => Text(
                                v.toInt().toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF7C8A90),
                                ),
                              ),
                              reservedSize: 28,
                            ),
                          ),
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        lineBarsData: [
                          LineChartBarData(
                            spots: moodSpots,
                            isCurved: true,
                            color: const Color(0xFF0B6FA8),
                            barWidth: 3,
                            belowBarData: BarAreaData(
                              show: true,
                              color: const Color(0xFF0B6FA8).withValues(alpha: 0.1),
                            ),
                            dotData: const FlDotData(show: true),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 22),

                  // ═══════════════════════════════════════
                  //  CATEGORY BREAKDOWN (PIE) — REAL only
                  // ═══════════════════════════════════════
                  if (catCounts.isNotEmpty) ...[
                    const _SectionTitle('By Category'),
                    const SizedBox(height: 8),
                    _ChartCard(
                      height: 200,
                      child: Row(
                        children: [
                          Expanded(
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 28,
                                sections: pieSections,
                              ),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: catCounts.entries.map((e) {
                              final colors = [
                                const Color(0xFFE3B15F),
                                const Color(0xFF2C9BD6),
                                const Color(0xFFB9A8DD),
                                const Color(0xFF063A5E),
                              ];
                              final idx = catCounts.keys.toList().indexOf(e.key);
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 10,
                                      height: 10,
                                      decoration: BoxDecoration(
                                        color: colors[idx % colors.length],
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_catEmoji(e.key)} ${e.key[0].toUpperCase()}${e.key.substring(1)}  ',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      '${e.value}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Color(0xFF7C8A90),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                    const SizedBox(height: 22),
                  ],

                  // ═══════════════════════════════════════
                  //  FILTER CHIPS
                  // ═══════════════════════════════════════
                  const _SectionTitle('Recent Sessions'),
                  const SizedBox(height: 10),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', 'all', '🔍'),
                        _buildFilterChip('Tasks', 'task', '✅'),
                        _buildFilterChip('Chat', 'chat', '💬'),
                        _buildFilterChip('Calls', 'audio', '🎙️'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // ═══════════════════════════════════════
                  //  RECENT SESSIONS LIST — FILTERED
                  // ═══════════════════════════════════════
                  if (filteredSessions.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Text(
                          'No sessions found for this filter',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF7C8A90),
                          ),
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredSessions.length > 30 ? 30 : filteredSessions.length,
                      itemBuilder: (_, i) {
                        final item = filteredSessions[i];
                        if (item is HistoryEntry) {
                          return _buildRealHistoryTile(item);
                        } else if (item is FakeSession) {
                          return _buildFakeSessionTile(item);
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ── Mix real + fake sessions, sorted by date ──
  List<dynamic> _buildMixedSessions(
    List<HistoryEntry> real,
    List<FakeSession> fake,
  ) {
    final mixed = <dynamic>[];
    mixed.addAll(real);
    mixed.addAll(fake);
    mixed.sort((a, b) {
      final da = a is HistoryEntry ? a.completedAt : (a as FakeSession).completedAt;
      final db = b is HistoryEntry ? b.completedAt : (b as FakeSession).completedAt;
      return db.compareTo(da); // newest first
    });
    return mixed;
  }

  // ── Real routine history tile ──
  Widget _buildRealHistoryTile(HistoryEntry h) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _catColor(h.category).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_catEmoji(h.category)} ${h.category[0].toUpperCase()}${h.category.substring(1)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _catColor(h.category),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d, h:mm a').format(h.completedAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7C8A90),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            h.routineTitle,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF233238),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _MoodBadge(score: h.moodScore),
              if (h.notes != null && h.notes!.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    h.notes!,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7C8A90),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── Fake chat/audio session tile ──
  Widget _buildFakeSessionTile(FakeSession s) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _catColor(s.type).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_catEmoji(s.type)} ${s.type[0].toUpperCase()}${s.type.substring(1)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _catColor(s.type),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                DateFormat('MMM d, h:mm a').format(s.completedAt),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF7C8A90),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            s.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF233238),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8F7FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.format_quote,
                  size: 14,
                  color: Color(0xFF7C8A90),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    s.transcriptSnippet,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF7C8A90),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('📊', style: TextStyle(fontSize: 56)),
          const SizedBox(height: 16),
          const Text(
            'No history yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF233238),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Complete routines to see your progress here.',
            style: TextStyle(fontSize: 13, color: Color(0xFF7C8A90)),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B6FA8),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
            ),
            child: const Text(
              'Go to Routine',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
//  LOCAL WIDGETS
// ═══════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: Color(0xFF233238),
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final double height;
  final Widget child;
  const _ChartCard({required this.height, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _StatCard extends StatelessWidget {
  final String icon;
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: Color(0xFF7C8A90)),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoodBadge extends StatelessWidget {
  final int score;
  const _MoodBadge({required this.score});

  String get _emoji {
    if (score >= 80) return '🤩';
    if (score >= 60) return '😄';
    if (score >= 40) return '🙂';
    if (score >= 20) return '😕';
    return '😢';
  }

  Color get _color {
    if (score >= 80) return const Color(0xFFE3B15F);
    if (score >= 60) return const Color(0xFFBFDDB6);
    if (score >= 40) return const Color(0xFF2C9BD6);
    if (score >= 20) return const Color(0xFFB9A8DD);
    return const Color(0xFFDD8E8E);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$_emoji $score%',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _color,
        ),
      ),
    );
  }
}