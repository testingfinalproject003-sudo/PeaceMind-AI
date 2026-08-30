import 'package:flutter/material.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({super.key});

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  static const Color background = Color(0xFFF3F6E8);
  static const Color darkBlue = Color(0xFF202952);
  static const Color royalOcean = Color(0xFF365A91);
  // static const Color darkGreen = Color(0xFF315C53);
  static const Color darkText = Color(0xFF303450);
  static const Color greyText = Color(0xFF777B94);
  // static const Color lavender = Color(0xFFECE8FA);
  static const Color lightLavender = Color(0xFFF4F1FF);
  static const Color green = Color(0xFF5D906F);
  static const Color red = Color(0xFFB97951);
  static const Color gold = Color(0xFFE3B15F);

  final TextEditingController _positiveCtrl = TextEditingController();
  final TextEditingController _negativeCtrl = TextEditingController();
  final TextEditingController _letGoCtrl = TextEditingController();

  final List<JournalEntry> _entries = [
    JournalEntry(
      date: 'Today, 08:30 AM',
      positive: 'Finished my morning walk.',
      negative: 'Felt anxious before the meeting.',
      letGo: 'Overthinking small mistakes.',
      mood: '🙂',
    ),
    JournalEntry(
      date: 'Yesterday, 07:15 PM',
      positive: 'Cooked a healthy meal.',
      negative: 'Could not sleep well.',
      letGo: 'Worrying about things I cannot control.',
      mood: '😕',
    ),
  ];

  @override
  void dispose() {
    _positiveCtrl.dispose();
    _negativeCtrl.dispose();
    _letGoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
                children: [
                  _buildAiBadge(),
                  const SizedBox(height: 16),
                  _buildInputField(
                    controller: _positiveCtrl,
                    hint: 'One positive thing today...',
                    borderColor: green,
                    icon: Icons.wb_sunny_outlined,
                    label: 'Positive',
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    controller: _negativeCtrl,
                    hint: 'A challenge or difficult feeling...',
                    borderColor: red,
                    icon: Icons.cloud_outlined,
                    label: 'Challenge',
                  ),
                  const SizedBox(height: 10),
                  _buildInputField(
                    controller: _letGoCtrl,
                    hint: 'Something you want to let go of...',
                    borderColor: gold,
                    icon: Icons.favorite_outline_rounded,
                    label: 'Let Go',
                  ),
                  const SizedBox(height: 14),
                  _buildSaveButton(),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Recent Entries'),
                  const SizedBox(height: 10),
                  ..._entries.map(_buildEntryCard),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .75),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .85),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: darkBlue,
                size: 17,
              ),
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Journal',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Reflect gently, no judgement 🌿',
                  style: TextStyle(
                    color: greyText,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: darkBlue,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: darkBlue.withValues(alpha: .18),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Icon(
              Icons.menu_book_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiBadge() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFECE8FA), Color(0xFFE4F0EA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: .80),
        ),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: .07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .60),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome_rounded,
              color: darkBlue,
              size: 18,
            ),
          ),
          const SizedBox(width: 11),
          const Expanded(
            child: Text(
              'Writing regularly helps your mind breathe. Take your time. 💚',
              style: TextStyle(
                color: darkText,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String hint,
    required Color borderColor,
    required IconData icon,
    required String label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 5),
          child: Text(
            label,
            style: TextStyle(
              color: darkText.withValues(alpha: .85),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .58),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withValues(alpha: .76),
              width: 1.1,
            ),
            boxShadow: [
              BoxShadow(
                color: darkBlue.withValues(alpha: .05),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            maxLines: 3,
            minLines: 2,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: greyText.withValues(alpha: .70),
                fontSize: 11,
              ),
              prefixIcon: Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Icon(icon, color: borderColor, size: 20),
              ),
              contentPadding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
            ),
            style: const TextStyle(
              color: darkText,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _saveEntry,
        style: ElevatedButton.styleFrom(
          backgroundColor: darkBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: const Text(
          'Save Entry 🌿',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  void _saveEntry() {
    if (_positiveCtrl.text.isEmpty &&
        _negativeCtrl.text.isEmpty &&
        _letGoCtrl.text.isEmpty) {
      return;
    }

    setState(() {
      _entries.insert(
        0,
        JournalEntry(
          date: 'Just now',
          positive: _positiveCtrl.text.isNotEmpty ? _positiveCtrl.text : '-',
          negative: _negativeCtrl.text.isNotEmpty ? _negativeCtrl.text : '-',
          letGo: _letGoCtrl.text.isNotEmpty ? _letGoCtrl.text : '-',
          mood: '🙂',
        ),
      );
      _positiveCtrl.clear();
      _negativeCtrl.clear();
      _letGoCtrl.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Entry saved 🌱'),
        duration: Duration(milliseconds: 1300),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: darkText,
        fontSize: 16,
        fontWeight: FontWeight.w900,
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: lightLavender.withValues(alpha: .58),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.white.withValues(alpha: .76),
          width: 1.1,
        ),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: .06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                entry.date,
                style: const TextStyle(
                  color: royalOcean,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const Spacer(),
              Text(
                entry.mood,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildEntryRow('Positive', entry.positive, green),
          const SizedBox(height: 6),
          _buildEntryRow('Challenge', entry.negative, red),
          const SizedBox(height: 6),
          _buildEntryRow('Let Go', entry.letGo, gold),
        ],
      ),
    );
  }

  Widget _buildEntryRow(String label, String text, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(top: 2),
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
          decoration: BoxDecoration(
            color: color.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 8,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: darkText,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

class JournalEntry {
  final String date;
  final String positive;
  final String negative;
  final String letGo;
  final String mood;

  JournalEntry({
    required this.date,
    required this.positive,
    required this.negative,
    required this.letGo,
    required this.mood,
  });
}