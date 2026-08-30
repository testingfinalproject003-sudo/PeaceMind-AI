import 'dart:ui';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import '../models/routine_model.dart';
import '../providers/auth_provider.dart';
import '../providers/routine_provider.dart';
import '../widgets/garden_celebration_card.dart';
import '../widgets/garden_widget.dart';

import 'call_screen.dart';
import 'chat_screen.dart';
import 'exercise_screen.dart';
import 'journal_screen.dart';
import 'routine_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with TickerProviderStateMixin {
  static const Color background = Color(0xFFF3F6E8);
  static const Color darkBlue = Color(0xFF202952);
  static const Color royalOcean = Color(0xFF365A91);
  static const Color darkGreen = Color(0xFF315C53);
  static const Color darkText = Color(0xFF303450);
  static const Color greyText = Color(0xFF777B94);
  static const Color lightLavender = Color(0xFFF4F1FF);

  static const String yappyAudio = 'audio/yappy.mp3';

  int selectedNavigation = 2;
  String selectedMood = '🙂';
  int motivationIndex = 0;
  final Set<String> completingTaskIds = <String>{};

  final GlobalKey<GardenWidgetState> _gardenKey =
      GlobalKey<GardenWidgetState>();

  late final List<Routine> _exerciseTasks;
  final Set<String> _completedExerciseIds = {};

  late final AnimationController moodController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  final List<String> motivations = const [
    'Small steps still move you forward.',
    'You do not have to do everything today.',
    'Be proud of the effort, not only the result.',
    'One calm breath can change the next moment.',
    'Consistency is more powerful than perfection.',
  ];

  final List<HomeNavigationItem> navigationItems = const [
    HomeNavigationItem(
      icon: Icons.chat_bubble_outline_rounded,
      label: 'Chat',
    ),
    HomeNavigationItem(
      icon: Icons.self_improvement_rounded,
      label: 'Exercise',
    ),
    HomeNavigationItem(
      icon: Icons.home_rounded,
      label: 'Home',
    ),
    HomeNavigationItem(
      icon: Icons.phone_outlined,
      label: 'Call',
    ),
    HomeNavigationItem(
      icon: Icons.settings_outlined,
      label: 'Settings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    tz_data.initializeTimeZones();
    moodController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _initExerciseTasks();
    _initializeNotifications();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduleRoutineNotifications();
      _restoreExerciseCompletions();
    });
  }

  void _initExerciseTasks() {
    _exerciseTasks = [
      Routine(
        id: 'ex_breathing',
        title: 'Breathing Exercise',
        time: '08:00',
        category: 'morning',
        days: List.filled(7, true),
        isCompleted: false,
        coverImage: null,
      ),
      Routine(
        id: 'ex_grounding',
        title: 'Grounding Exercise',
        time: '12:30',
        category: 'afternoon',
        days: List.filled(7, true),
        isCompleted: false,
        coverImage: null,
      ),
      Routine(
        id: 'ex_scan',
        title: 'Body Scan',
        time: '18:00',
        category: 'evening',
        days: List.filled(7, true),
        isCompleted: false,
        coverImage: null,
      ),
      Routine(
        id: 'ex_walking',
        title: 'Walking Meditation',
        time: '20:00',
        category: 'night',
        days: List.filled(7, true),
        isCompleted: false,
        coverImage: null,
      ),
    ];
  }

  void _restoreExerciseCompletions() {
    final provider = context.read<RoutineProvider>();
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    for (final h in provider.history) {
      if (_isExerciseTask(h.routineId)) {
        final completedDay = DateTime(
          h.completedAt.year,
          h.completedAt.month,
          h.completedAt.day,
        );
        if (completedDay == todayStart) {
          _completedExerciseIds.add(h.routineId);
        }
      }
    }

    if (mounted) {
      setState(() {});
    }
  }

  bool _isExerciseTask(String id) => id.startsWith('ex_');

  Routine? _getNextRoutine(List<Routine> routines) {
    if (routines.isEmpty) return null;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    int parseTime(String time) {
      final parts = time.split(':');
      if (parts.length >= 2) {
        final h = int.tryParse(parts[0]) ?? 8;
        final m = int.tryParse(parts[1].split(' ')[0]) ?? 0;
        return h * 60 + m;
      }
      return 8 * 60;
    }

    final sorted = [...routines]
      ..sort((a, b) => parseTime(a.time).compareTo(parseTime(b.time)));

    for (final r in sorted) {
      if (parseTime(r.time) > currentMinutes) {
        return r;
      }
    }

    return sorted.first;
  }

  bool _areAllTodayTasksDone(RoutineProvider provider) {
    final todayRoutines = provider.getTodayRoutines();
    final userDone = todayRoutines.where((r) => r.isCompleted).length;
    final exerciseDone = _completedExerciseIds.length;
    final total = todayRoutines.length + _exerciseTasks.length;
    return total > 0 && (userDone + exerciseDone) == total;
  }

  _TaskMeta _metaForCategory(String category) {
    switch (category) {
      case 'morning':
        return _TaskMeta(
          subtitle: 'Take a moment to notice your feelings.',
          icon: Icons.wb_sunny_outlined,
        );
      case 'afternoon':
        return _TaskMeta(
          subtitle: 'Slow down and take four calm breaths.',
          icon: Icons.air_rounded,
        );
      case 'evening':
        return _TaskMeta(
          subtitle: 'Write one thing you did well today.',
          icon: Icons.menu_book_rounded,
        );
      case 'night':
        return _TaskMeta(
          subtitle:
              'Spend a few minutes checking in with yourself.',
          icon: Icons.favorite_outline_rounded,
        );
      default:
        return _TaskMeta(
          subtitle: 'Take a moment for yourself.',
          icon: Icons.self_improvement_rounded,
        );
    }
  }

  List<PendingTask> _buildPendingTasks(RoutineProvider provider) {
    final now = DateTime.now();
    final yesterday = DateTime(now.year, now.month, now.day)
        .subtract(const Duration(days: 1));
    final lastCompletion = <String, DateTime>{};

    for (final h in provider.history) {
      if (lastCompletion[h.routineId] == null ||
          h.completedAt.isAfter(lastCompletion[h.routineId]!)) {
        lastCompletion[h.routineId] = h.completedAt;
      }
    }

    final pending = <PendingTask>[];

    for (final r in provider.routines) {
      final last = lastCompletion[r.id];
      if (last == null || last.isBefore(yesterday)) {
        final daysAgo = last == null ? null : now.difference(last).inDays;
        pending.add(
          PendingTask(
            title: r.title,
            missedDay: last == null ? 'Not started' : _formatDay(last),
            missedCount: last == null ? 'Start today' : 'Missed ${daysAgo}d',
          ),
        );
      }
    }

    for (final r in _exerciseTasks) {
      if (!_completedExerciseIds.contains(r.id)) {
        pending.add(
          PendingTask(
            title: r.title,
            missedDay: 'Today',
            missedCount: 'Do it now',
          ),
        );
      }
    }

    return pending.take(3).toList();
  }

  String _formatDay(DateTime d) {
    final now = DateTime.now();
    final diff = now.difference(d).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return '${d.month}/${d.day}';
  }

  Future<void> _initializeNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings: initializationSettings);
  }

  Future<void> _scheduleRoutineNotifications() async {
    final provider = context.read<RoutineProvider>();
    for (final routine in provider.routines) {
      await _scheduleRoutineNotification(routine);
    }
  }

  Future<void> _scheduleRoutineNotification(Routine routine) async {
    final parts = routine.time.split(':');
    if (parts.length != 2) return;

    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = int.tryParse(parts[1]) ?? 0;

    final details = NotificationDetails(
      android: AndroidNotificationDetails(
        'routine_channel',
        'Routine Notifications',
        channelDescription:
            'Notifications for your daily wellbeing routines.',
        importance: Importance.high,
        priority: Priority.high,
        enableVibration: true,
        playSound: true,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    if (!scheduledDate.isAfter(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    try {
      await _notifications.zonedSchedule(
        id: routine.id.hashCode,
        title: 'It is time 🌿',
        body: '${routine.title} is ready. Take a moment for yourself.',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      debugPrint('Routine notification error: $e');
    }
  }

  Future<void> _playYappy() async {
    try {
      await _audioPlayer.stop();
      await _audioPlayer.play(AssetSource(yappyAudio));
    } catch (e) {
      debugPrint('Yappy audio error: $e');
    }
  }

  String _getRoutineTitle(RoutineProvider provider, String routineId) {
    for (final exercise in _exerciseTasks) {
      if (exercise.id == routineId) return exercise.title;
    }
    for (final routine in provider.routines) {
      if (routine.id == routineId) return routine.title;
    }
    return 'Your task';
  }

  Future<void> _showGardenCelebration({
    required String taskTitle,
  }) async {
    final authProvider = context.read<AuthProvider>();
    final userName = authProvider.userName;

    await _playYappy();

    if (!mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      builder: (dialogContext) {
        return GardenCelebrationCard(
          userName: userName,
          taskTitle: taskTitle,
          onContinue: () {
            Navigator.of(dialogContext).pop();
          },
        );
      },
    );

    if (!mounted) return;

    await _gardenKey.currentState?.growNextTree();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    moodController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RoutineProvider>();
    final allRoutines = provider.routines;
    final todayRoutines = provider.getTodayRoutines();
    final streak = provider.getCurrentStreak();

    final activeExercises = _exerciseTasks
        .where((r) => !_completedExerciseIds.contains(r.id))
        .toList();

    final uncompletedRoutines =
        allRoutines.where((r) => !r.isCompleted).toList();

    final allUncompleted = [...uncompletedRoutines, ...activeExercises];

    final todayUserUncompleted =
        todayRoutines.where((r) => !r.isCompleted).toList();

    final allTodayUncompleted = [
      ...todayUserUncompleted,
      ...activeExercises,
    ];

    final nextRoutine = _getNextRoutine(allUncompleted);
    final allTodayDone = _areAllTodayTasksDone(provider);
    final pendingTasks = _buildPendingTasks(provider);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildHeader(streak)),
                  if (nextRoutine != null)
                    SliverToBoxAdapter(
                      child: _buildNextFocusCard(nextRoutine),
                    ),
                  if (allUncompleted.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildRoutineCarousel(allUncompleted),
                    ),
                  if (allUncompleted.isEmpty && allRoutines.isEmpty)
                    SliverToBoxAdapter(
                      child: _buildSetRoutineCard(),
                    ),
                  SliverToBoxAdapter(child: _buildMoodTracker()),
                  SliverToBoxAdapter(
                    child: GardenWidget(key: _gardenKey),
                  ),
                  if (allTodayUncompleted.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildTodaySchedule(allTodayUncompleted),
                    ),
                  if (allTodayDone)
                    SliverToBoxAdapter(child: _buildYappyCard()),
                  if (pendingTasks.isNotEmpty)
                    SliverToBoxAdapter(
                      child: _buildPendingTasksSection(pendingTasks),
                    ),
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 24),
                  ),
                ],
              ),
            ),
            _buildBottomNavigation(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(int streak) {
    final userName = context.watch<AuthProvider>().userName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.72),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.80),
              ),
              boxShadow: [
                BoxShadow(
                  color: darkBlue.withValues(alpha: 0.08),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 27,
              backgroundImage: AssetImage(
                'assets/images/home/profile.jpg',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$userName 🌿',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  motivations[motivationIndex],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            width: 48,
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: lightLavender.withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            child: Column(
              children: [
                const Text('🔥', style: TextStyle(fontSize: 17)),
                Text(
                  '$streak',
                  style: const TextStyle(
                    color: darkBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const JournalScreen()),
            ),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.72),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.80),
                ),
                boxShadow: [
                  BoxShadow(
                    color: darkBlue.withValues(alpha: 0.08),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: darkBlue,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  Widget _buildNextFocusCard(Routine nextRoutine) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const RoutineScreen()),
      ),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.fromLTRB(20, 10, 20, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFF063A5E),
              Color(0xFF0B6FA8),
              Color(0xFF2C9BD6),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0B6FA8).withValues(alpha: 0.3),
              blurRadius: 16,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.24),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '🗓 Your next focus',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: Colors.white70,
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      nextRoutine.time,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Today · ${nextRoutine.title}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: nextRoutine.coverImage != null
                        ? DecorationImage(
                            image: NetworkImage(nextRoutine.coverImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: nextRoutine.coverImage == null
                        ? Colors.white.withValues(alpha: 0.24)
                        : null,
                  ),
                  child: nextRoutine.coverImage == null
                      ? const Icon(
                          Icons.self_improvement,
                          color: Colors.white,
                        )
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCarousel(List<Routine> routines) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Your Routine 🌿',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              GestureDetector(
                onTap: _setRoutine,
                child: const Text(
                  'Edit',
                  style: TextStyle(
                    color: darkGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 178,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20, right: 10),
            itemCount: routines.length,
            itemBuilder: (context, index) {
              final routine = routines[index];
              return _buildRoutineCard(
                routine,
                isExercise: _isExerciseTask(routine.id),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoutineCard(
    Routine routine, {
    bool isExercise = false,
  }) {
    return GestureDetector(
      onTap: () {
        // Navigate to exercise screen if it's an exercise task
        if (isExercise) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ExerciseScreen()),
          ).then((_) {
            setState(() => selectedNavigation = 2);
          });
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const RoutineScreen()),
          );
        }
      },
      child: Container(
        width: 245,
        margin: const EdgeInsets.only(right: 10),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (routine.coverImage != null &&
                  routine.coverImage!.isNotEmpty)
                Image.network(
                  routine.coverImage!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [darkGreen, darkBlue],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    );
                  },
                )
              else
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        _catColor(routine.category).withValues(alpha: 0.8),
                        _catColor(routine.category),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.04),
                      Colors.black.withValues(alpha: 0.76),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 9, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.90),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            routine.category[0].toUpperCase() +
                                routine.category.substring(1),
                            style: const TextStyle(
                              color: darkBlue,
                              fontSize: 8,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const Spacer(),
                        if (!isExercise)
                          const Icon(
                            Icons.more_horiz_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                      ],
                    ),
                    const Spacer(),
                    Text(
                      routine.time,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      routine.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _dayLabel(routine),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _dayLabel(Routine r) {
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final active = r.days
        .asMap()
        .entries
        .where((e) => e.value)
        .map((e) => days[e.key])
        .join(', ');
    return active.isEmpty ? 'No days selected' : active;
  }

  Color _catColor(String cat) {
    switch (cat) {
      case 'morning':
        return const Color(0xFFE3B15F);
      case 'afternoon':
        return const Color(0xFF2C9BD6);
      case 'evening':
        return const Color(0xFFB9A8DD);
      case 'night':
        return const Color(0xFF063A5E);
      default:
        return const Color(0xFF0B6FA8);
    }
  }

  void _setRoutine() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const RoutineScreen()),
    );
  }

  Widget _buildSetRoutineCard() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [darkBlue, royalOcean],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(17),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.white,
              size: 25,
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Routine',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Build a gentle routine that works for you.',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 9,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _setRoutine,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(13),
              ),
              child: const Text(
                'Set',
                style: TextStyle(
                  color: darkBlue,
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

  Widget _buildTodaySchedule(List<Routine> routines) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RoutineScreen()),
                ),
                child: const Text(
                  'See All',
                  style: TextStyle(
                    color: Color(0xFF0B6FA8),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...routines.map((r) {
            final meta = _metaForCategory(r.category);
            return Container(
              margin: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _catColor(r.category)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Icon(
                              meta.icon,
                              color: _catColor(r.category),
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                r.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: darkText,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${r.time} · ${meta.subtitle}',
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: greyText,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _showMoodPicker(context, r.id),
                          child: Container(
                            width: 32,
                            height: 32,
                            decoration: const BoxDecoration(
                              color: Color(0xFFF1ECFA),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.circle_outlined,
                              size: 18,
                              color: Color(0xFF0B6FA8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  void _showMoodPicker(BuildContext context, String routineId) {
    int selectedMoodScore = 60;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'How do you feel?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            StatefulBuilder(
              builder: (ctx, setSt) => Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _moodFace('😢', 20, selectedMoodScore == 20,
                      () => setSt(() => selectedMoodScore = 20)),
                  _moodFace('😕', 40, selectedMoodScore == 40,
                      () => setSt(() => selectedMoodScore = 40)),
                  _moodFace('🙂', 60, selectedMoodScore == 60,
                      () => setSt(() => selectedMoodScore = 60)),
                  _moodFace('😄', 80, selectedMoodScore == 80,
                      () => setSt(() => selectedMoodScore = 80)),
                  _moodFace('🤩', 100, selectedMoodScore == 100,
                      () => setSt(() => selectedMoodScore = 100)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final provider =
                      context.read<RoutineProvider>();

                  if (completingTaskIds.contains(routineId)) return;

                  completingTaskIds.add(routineId);

                  final completedTitle =
                      _getRoutineTitle(provider, routineId);

                  // Complete exercise task
                  if (_isExerciseTask(routineId)) {
                    if (mounted) {
                      setState(
                        () =>
                            _completedExerciseIds.add(routineId),
                      );
                    }

                    try {
                      provider.completeRoutine(
                        routineId,
                        selectedMoodScore,
                      );
                    } catch (e) {
                      debugPrint(
                          'Exercise completion error: $e');
                    }
                  } else {
                    // Complete user routine
                    provider.completeRoutine(
                      routineId,
                      selectedMoodScore,
                    );
                  }

                  if (!mounted) return;

                  Navigator.pop(ctx);

                  // Show celebration + garden growth
                  await _showGardenCelebration(
                    taskTitle: completedTitle,
                  );

                  completingTaskIds.remove(routineId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B6FA8),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Complete',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _moodFace(
    String emoji,
    int value,
    bool selected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE3B15F)
              : const Color(0xFFF1ECFA),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(emoji, style: const TextStyle(fontSize: 22)),
        ),
      ),
    );
  }

  Widget _buildYappyCard() {
    final userName = context.watch<AuthProvider>().userName;

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF315C53),
            Color(0xFF4CAF50),
            Color(0xFF8BC34A),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4CAF50).withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Yaaay! 🎉',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'You crushed all your tasks today!',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.20),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Keep shining $userName ✨',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.20),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Text('🏆', style: TextStyle(fontSize: 36)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                  borderRadius: BorderRadius.circular(20),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodTracker() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFECE8FA),
            Color(0xFFE7F0EC),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.80),
        ),
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How are you feeling?',
                      style: TextStyle(
                        color: darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'No judgement here 💚',
                      style: TextStyle(
                        color: greyText,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 70,
                height: 70,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.55),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: _buildMoodAnimation(selectedMood),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMood('😭', 'Low'),
              _buildMood('😕', 'Meh'),
              _buildMood('🙂', 'Okay'),
              _buildMood('😄', 'Good'),
              _buildMood('🤩', 'Great'),
            ],
          ),
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: _moodProgress),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return LinearProgressIndicator(
                  value: value,
                  minHeight: 7,
                  backgroundColor: Colors.white.withValues(alpha: 0.60),
                  valueColor: const AlwaysStoppedAnimation(darkGreen),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Text(
              _moodMessage,
              key: ValueKey(_moodMessage),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: darkGreen,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodAnimation(String mood) {
    final path = _moodAnimationPath(mood);

    if (path.isEmpty) {
      return Text(
        mood,
        key: ValueKey(mood),
        style: const TextStyle(fontSize: 40),
      );
    }

    return Lottie.asset(
      path,
      key: ValueKey(mood),
      width: 50,
      height: 50,
      fit: BoxFit.contain,
      repeat: true,
      errorBuilder: (context, error, stackTrace) {
        return Text(
          mood,
          style: const TextStyle(fontSize: 40),
        );
      },
    );
  }

  String _moodAnimationPath(String mood) {
    switch (mood) {
      case '😭':
        return 'assets/animations/sad.json';
      case '😕':
        return 'assets/animations/meh.json';
      case '🙂':
        return 'assets/animations/okay.json';
      case '😄':
        return 'assets/animations/happy.json';
      case '🤩':
        return 'assets/animations/great.json';
      default:
        return 'assets/animations/okay.json';
    }
  }

  Widget _buildMood(String emoji, String label) {
    final isSelected = selectedMood == emoji;

    return GestureDetector(
      onTap: () {
        setState(() => selectedMood = emoji);
        moodController.forward(from: 0);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeOutBack,
        width: isSelected ? 55 : 47,
        height: isSelected ? 58 : 51,
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white.withValues(alpha: 0.70)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(17),
          border: isSelected
              ? Border.all(
                  color: darkBlue.withValues(alpha: 0.10),
                )
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: isSelected ? 1.18 : 1,
              duration: const Duration(milliseconds: 230),
              curve: Curves.easeOutBack,
              child: Text(emoji, style: const TextStyle(fontSize: 21)),
            ),
            const SizedBox(height: 1),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? darkBlue : greyText,
                fontSize: 7,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double get _moodProgress {
    switch (selectedMood) {
      case '😭':
        return .10;
      case '😕':
        return .30;
      case '🙂':
        return .50;
      case '😄':
        return .75;
      case '🤩':
        return 1;
      default:
        return .50;
    }
  }

  String get _moodMessage {
    switch (selectedMood) {
      case '😭':
        return 'It is okay. One tiny step is enough today. 💚';
      case '😕':
        return 'No pressure. You can take it slowly. 🌿';
      case '🙂':
        return 'Small steps still move you forward. ✨';
      case '😄':
        return 'Love that energy! Keep it going. 🌻';
      case '🤩':
        return 'Yay! Keep this feeling with you. 🎉';
      default:
        return 'Small steps still move you forward. ✨';
    }
  }

  Widget _buildPendingTasksSection(List<PendingTask> pendingTasks) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      padding: const EdgeInsets.all(15),
      decoration: _glassDecoration(lightLavender),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Pending Tasks ⏳',
                  style: TextStyle(
                    color: darkText,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Text(
                'Needs attention',
                style: TextStyle(
                  color: Color(0xFFB97951),
                  fontSize: 8,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...pendingTasks.map(_buildPendingTask),
        ],
      ),
    );
  }

  Widget _buildPendingTask(PendingTask task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 7),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 31,
            height: 31,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE8D9).withValues(alpha: 0.80),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.history_rounded,
              color: Color(0xFFB97951),
              size: 16,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: darkText,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${task.missedDay} · ${task.missedCount}',
                  style: const TextStyle(
                    color: greyText,
                    fontSize: 8,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right_rounded,
            color: greyText,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: darkBlue,
        boxShadow: [
          BoxShadow(
            color: darkBlue.withValues(alpha: 0.20),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              navigationItems.length,
              (index) {
                final item = navigationItems[index];
                final selected = selectedNavigation == index;

                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _selectNavigation(index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOutCubic,
                    padding: EdgeInsets.symmetric(
                      horizontal: selected ? 16 : 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color:
                          selected ? royalOcean : Colors.transparent,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: selected
                          ? [
                              BoxShadow(
                                color:
                                    royalOcean.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          item.icon,
                          color: selected
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.55),
                          size: 22,
                        ),
                        if (selected) ...[
                          const SizedBox(width: 8),
                          Text(
                            item.label,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  void _selectNavigation(int index) {
    setState(() => selectedNavigation = index);

    switch (index) {
      case 0: // Chat
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChatScreen()),
        ).then((_) => setState(() => selectedNavigation = 2));
        break;

      case 1: // Exercise
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ExerciseScreen()),
        ).then((_) => setState(() => selectedNavigation = 2));
        break;

      case 2: // Home
        break;

      case 3: // Call
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CallScreen()),
        ).then((_) => setState(() => selectedNavigation = 2));
        break;

      case 4: // Settings
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const SettingsScreen()),
        ).then((_) => setState(() => selectedNavigation = 2));
        break;
    }
  }

  BoxDecoration _glassDecoration(Color baseColor) {
    return BoxDecoration(
      color: baseColor.withValues(alpha: 0.58),
      borderRadius: BorderRadius.circular(22),
      border: Border.all(
        color: Colors.white.withValues(alpha: 0.76),
        width: 1.1,
      ),
      boxShadow: [
        BoxShadow(
          color: darkBlue.withValues(alpha: 0.07),
          blurRadius: 18,
          offset: const Offset(0, 7),
        ),
      ],
    );
  }
}

class PendingTask {
  final String title;
  final String missedDay;
  final String missedCount;

  const PendingTask({
    required this.title,
    required this.missedDay,
    required this.missedCount,
  });
}

class HomeNavigationItem {
  final IconData icon;
  final String label;

  const HomeNavigationItem({
    required this.icon,
    required this.label,
  });
}

class _TaskMeta {
  final String subtitle;
  final IconData icon;

  _TaskMeta({
    required this.subtitle,
    required this.icon,
  });
}