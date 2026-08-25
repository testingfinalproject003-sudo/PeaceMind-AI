import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'journal_screen.dart';
import 'routine_screen.dart';
import 'history_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // ===========================================================================
  // COLORS
  // ===========================================================================

  static const Color background = Color(0xFFF3F6E8);

  static const Color darkBlue = Color(0xFF202952);

  static const Color darkGreen = Color(0xFF315C53);

  static const Color darkText = Color(0xFF303450);
  static const Color greyText = Color(0xFF777B94);

  static const Color lavender = Color(0xFFECE8FA);
  static const Color lightLavender = Color(0xFFF4F1FF);

  static const Color white = Colors.white;

  // ===========================================================================
  // PROFILE (defaults, jab tak Firestore se load na ho)
  // ===========================================================================

  String userName = 'Sara';
  String userMood = '🙂';

  // ===========================================================================
  // ROUTINE & TASKS (counts only, for subtitle display)
  // ===========================================================================

  int routineCount = 4;
  int taskCount = 4;

  // ===========================================================================
  // FIREBASE
  // ===========================================================================

  bool _isLoading = true;
  bool _isSaving = false;

  final User? _currentUser = FirebaseAuth.instance.currentUser;
  late final DocumentReference<Map<String, dynamic>> _userDocRef;

  @override
  void initState() {
    super.initState();
    _userDocRef = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser?.uid);
    _loadUserData();
  }

  /// Firestore se user ka data load karta hai.
  /// Agar document exist nahi karta (yani ye pehli baar app open hua hai),
  /// to default values ke sath naya document create kar deta hai.
  Future<void> _loadUserData() async {
    if (_currentUser == null) {
      // User signed in nahi hai — Auth pehle setup karni hogi.
      setState(() => _isLoading = false);
      return;
    }

    try {
      final snapshot = await _userDocRef.get();

      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        setState(() {
          userName = data['name'] as String? ?? userName;
          userMood = data['mood'] as String? ?? userMood;
          routineCount = data['routineCount'] as int? ?? routineCount;
          taskCount = data['taskCount'] as int? ?? taskCount;
          _isLoading = false;
        });
      } else {
        // Pehli dafa — default data ke sath document banao
        await _userDocRef.set({
          'name': userName,
          'mood': userMood,
          'routineCount': routineCount,
          'taskCount': taskCount,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Sirf diye gaye fields ko update karta hai (merge: true),
  /// isliye purana document overwrite nahi hota — naya bhi nahi banta.
  Future<void> _updateUserFields(Map<String, dynamic> fields) async {
    if (_currentUser == null) return;
    setState(() => _isSaving = true);
    try {
      await _userDocRef.set(
        {
          ...fields,
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      debugPrint('Error updating user data: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Save failed, please try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: background,
        body: const Center(
          child: CircularProgressIndicator(color: darkBlue),
        ),
      );
    }

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
                  _buildProfileCard(),

                  const SizedBox(height: 18),

                  _buildSectionTitle(
                    'Personal',
                    'Manage your profile and preferences.',
                  ),

                  const SizedBox(height: 10),

                  _buildSettingTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Profile',
                    subtitle: 'Edit your name and profile',
                    onTap: _editProfile,
                  ),

                  _buildSettingTile(
                    icon: Icons.notifications_none_rounded,
                    title: 'Notifications',
                    subtitle: 'Manage routine reminders',
                    onTap: _showNotifications,
                  ),

                  const SizedBox(height: 18),

                  _buildSectionTitle(
                    'Your Wellness',
                    'Keep your routines and daily tasks on track.',
                  ),

                  const SizedBox(height: 10),

                  _buildSettingTile(
                    icon: Icons.calendar_month_rounded,
                    title: 'Routine',
                    subtitle: '$routineCount routines active',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RoutineScreen(),
                        ),
                      );
                    },
                  ),

                  _buildSettingTile(
                    icon: Icons.check_circle_outline_rounded,
                    title: 'Journal',
                    subtitle: 'Write your calm',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const JournalScreen(),
                        ),
                      );
                    },
                  ),

                  _buildSettingTile(
                    icon: Icons.bar_chart_rounded,
                    title: 'Report',
                    subtitle: 'View your wellness progress',
                    onTap: _openReport,
                  ),

                  const SizedBox(height: 18),

                  _buildSectionTitle(
                    'Information',
                    'Learn more about the app.',
                  ),

                  const SizedBox(height: 10),

                  _buildSettingTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About',
                    subtitle: 'About your wellbeing companion',
                    onTap: _showAbout,
                  ),

                  _buildSettingTile(
                    icon: Icons.apps_rounded,
                    title: 'Version',
                    subtitle: '1.0.0',
                    showArrow: false,
                    onTap: () {},
                  ),

                  const SizedBox(height: 20),

                  _buildBottomMessage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: white.withValues(alpha: .75),
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
                  'Settings',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Make your space work for you 🌿',
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
              Icons.settings_rounded,
              color: Colors.white,
              size: 19,
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // PROFILE CARD
  // ===========================================================================

  Widget _buildProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF202952),
            Color(0xFF365A91),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: .18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .20),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: .40),
              ),
            ),
            child: const CircleAvatar(
              backgroundImage: AssetImage(
                'assets/images/home/profile.jpg',
              ),
            ),
          ),

          const SizedBox(width: 13),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Your Profile',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 2),

                Text(
                  '$userName 🌿',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  'Current mood $userMood',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: _editProfile,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 11,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .20),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Edit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SECTION TITLE
  // ===========================================================================

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: darkText,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: greyText,
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // SETTING TILE
  // ===========================================================================

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool showArrow = true,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 9),
        padding: const EdgeInsets.all(13),
        decoration: _glassDecoration(lightLavender),
        child: Row(
          children: [
            Container(
              width: 43,
              height: 43,
              decoration: BoxDecoration(
                color: lavender,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                icon,
                color: darkBlue,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: darkText,
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: greyText,
                      fontSize: 8,
                    ),
                  ),
                ],
              ),
            ),

            if (showArrow)
              const Icon(
                Icons.chevron_right_rounded,
                color: greyText,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // PROFILE EDIT
  // ===========================================================================

  void _editProfile() {
    final controller = TextEditingController(text: userName);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: lightLavender,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          title: const Text(
            'Edit Profile',
            style: TextStyle(
              color: darkText,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: TextField(
            controller: controller,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Your name',
              filled: true,
              fillColor: Colors.white.withValues(alpha: .65),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: greyText,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final newName = controller.text.trim();
                if (newName.isNotEmpty && newName != userName) {
                  setState(() {
                    userName = newName; // UI turant update (optimistic)
                  });
                  Navigator.pop(dialogContext);
                  await _updateUserFields({'name': newName});
                } else {
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: darkBlue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // ===========================================================================
  // NOTIFICATIONS
  // ===========================================================================

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          decoration: const BoxDecoration(
            color: background,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildSheetHandle(),

              const SizedBox(height: 10),

              const Text(
                'Routine Notifications 🔔',
                style: TextStyle(
                  color: darkText,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'You will receive a reminder when it is time for an enabled routine.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: greyText,
                  fontSize: 9,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              Container(
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.all(12),
                decoration: _glassDecoration(lightLavender),
                child: const Row(
                  children: [
                    Icon(
                      Icons.notifications_active_outlined,
                      color: darkBlue,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Morning Check-in • 08:00 AM',
                        style: TextStyle(
                          color: darkText,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // REPORT
  // ===========================================================================

  void _openReport() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const HistoryScreen(),
      ),
    );
  }

  // ===========================================================================
  // ABOUT
  // ===========================================================================

  void _showAbout() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: lightLavender,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(27),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: darkBlue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.spa_rounded,
                  color: Colors.white,
                  size: 31,
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Your Wellbeing Companion 🌿',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: darkText,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'A gentle space to track your mood, '
                'build healthy routines, complete daily '
                'tasks and celebrate small progress.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: greyText,
                  fontSize: 10,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 12),

              const Text(
                'Version 1.0.0',
                style: TextStyle(
                  color: darkGreen,
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // BOTTOM MESSAGE
  // ===========================================================================

  Widget _buildBottomMessage() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkBlue,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          Text(
            '🌱',
            style: TextStyle(
              fontSize: 25,
            ),
          ),

          SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your space, your pace.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Small steps are still progress.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // SHEET HANDLE
  // ===========================================================================

  Widget _buildSheetHandle() {
    return Container(
      width: 42,
      height: 4,
      margin: const EdgeInsets.only(top: 8, bottom: 5),
      decoration: BoxDecoration(
        color: greyText.withValues(alpha: .35),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // ===========================================================================
  // GLASS
  // ===========================================================================

  BoxDecoration _glassDecoration(Color baseColor) {
    return BoxDecoration(
      color: baseColor.withValues(alpha: .58),
      borderRadius: BorderRadius.circular(21),
      border: Border.all(
        color: Colors.white.withValues(alpha: .76),
        width: 1.1,
      ),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFF5D5A8A).withValues(alpha: .07),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }
}