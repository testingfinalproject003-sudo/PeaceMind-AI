import 'package:flutter/material.dart';

import '../data/exercises.dart';
import '../models/exercise_models.dart';
import '../widgets/glass_widgets.dart';
import 'exercise_player_screen.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  State<ExerciseScreen> createState() => _ExerciseScreenState();
}

class _ExerciseScreenState extends State<ExerciseScreen> {
  AppLang _lang = AppLang.en;
  bool _showLangMenu = false;

  static const Color background = Color(0xFFF3F6E8);
  static const Color darkBlue = Color(0xFF202952);
  static const Color darkText = Color(0xFF303450);
  static const Color greyText = Color(0xFF777B94);

  // ── Translations ──
  static const _screenTr = {
    'header':     {AppLang.en: 'Exercise', AppLang.ur: 'مشقیں', AppLang.urRoman: 'Mashqain', AppLang.pa: 'ਅਭਿਆਸ'},
    'footer':     {AppLang.en: 'More exercises coming soon', AppLang.ur: 'مزید مشقیں جلد آ رہی ہیں', AppLang.urRoman: 'Mazeed mashqain jald aa rahi hain', AppLang.pa: 'ਹੋਰ ਅਭਿਆਸ ਜਲਦ ਆ ਰਹੇ ਹਨ'},
  };

  static const _tileTr = {
    'box_breathing_title':    {AppLang.en: 'Box Breathing', AppLang.ur: 'باکس بریتھنگ', AppLang.urRoman: 'Box Breathing', AppLang.pa: 'ਬਾਕਸ ਸਾਹ'},
    'box_breathing_subtitle': {AppLang.en: '3 cycles • Calm your mind', AppLang.ur: '3 چکر • ذہن کو سکون دیں', AppLang.urRoman: '3 chakkar • Zehn ko sukoon dein', AppLang.pa: '3 ਚੱਕਰ • ਮਨ ਨੂੰ ਸ਼ਾਂਤ ਕਰੋ'},
    'grounding_title':        {AppLang.en: 'Grounding 5-4-3-2-1', AppLang.ur: 'گراؤنڈنگ 5-4-3-2-1', AppLang.urRoman: 'Grounding 5-4-3-2-1', AppLang.pa: 'ਗਰਾਊਂਡਿੰਗ 5-4-3-2-1'},
    'grounding_subtitle':     {AppLang.en: 'Reconnect with senses', AppLang.ur: 'حواس سے دوبارہ جڑیں', AppLang.urRoman: 'Hawas se dobara jurein', AppLang.pa: 'ਇੰਦਰੀਆਂ ਨਾਲ ਦੁਬਾਰਾ ਜੁੜੋ'},
    'mind_walking_title':     {AppLang.en: 'Mindful Walking', AppLang.ur: 'توجہ سے چلنا', AppLang.urRoman: 'Tawajjo Se Chalna', AppLang.pa: 'ਧਿਆਨ ਨਾਲ ਤੁਰਨਾ'},
    'mind_walking_subtitle':  {AppLang.en: 'Walk with awareness', AppLang.ur: 'آگاہی کے ساتھ چلیں', AppLang.urRoman: 'Aagahi ke saath chalein', AppLang.pa: 'ਜਾਗਰੂਕਤਾ ਨਾਲ ਤੁਰੋ'},
    'body_scan_title':        {AppLang.en: 'Body Scan', AppLang.ur: 'باڈی اسکین', AppLang.urRoman: 'Body Scan', AppLang.pa: 'ਸਰੀਰ ਸਕੈਨ'},
    'body_scan_subtitle':     {AppLang.en: 'Release tension slowly', AppLang.ur: 'تناؤ آہستہ آہستہ چھوڑیں', AppLang.urRoman: 'Tanao aahista aahista chorein', AppLang.pa: 'ਤਣਾਅ ਹੌਲੀ-ਹੌਲੀ ਛੱਡੋ'},
  };

  String _t(String key, Map<String, Map<AppLang, String>> map) {
    final entry = map[key];
    return entry?[_lang] ?? entry?[AppLang.en] ?? key;
  }

  List<_ExerciseData> get _exercises => [
    _ExerciseData(
      title: _t('box_breathing_title', _tileTr),
      subtitle: _t('box_breathing_subtitle', _tileTr),
      asset: 'assets/images/box_breathing_cover.png',
      fallbackIcon: Icons.self_improvement_rounded,
      color: const Color(0xFFECE8FA),
      exerciseInfo: boxBreathingExercise,
    ),
    _ExerciseData(
      title: _t('grounding_title', _tileTr),
      subtitle: _t('grounding_subtitle', _tileTr),
      asset: 'assets/images/grounding_cover.png',
      fallbackIcon: Icons.spa_rounded,
      color: const Color(0xFFE5F3EC),
      exerciseInfo: groundingExercise,
    ),
    _ExerciseData(
      title: _t('mind_walking_title', _tileTr),
      subtitle: _t('mind_walking_subtitle', _tileTr),
      asset: 'assets/images/mindful_walking_cover.png',
      fallbackIcon: Icons.directions_walk_rounded,
      color: const Color(0xFFFDECE3),
      exerciseInfo: mindWalkingExercise,
    ),
    _ExerciseData(
      title: _t('body_scan_title', _tileTr),
      subtitle: _t('body_scan_subtitle', _tileTr),
      asset: 'assets/images/body_scan_cover.png',
      fallbackIcon: Icons.accessibility_new_rounded,
      color: const Color(0xFFE8EEF7),
      exerciseInfo: bodyScanExercise,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildExerciseGrid(context),
                        const SizedBox(height: 24),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            _t('footer', _screenTr),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: greyText,
                              fontSize: 12,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            // Language menu — root (full-screen) Stack mein render hota hai:
            // header ke chhote Stack ke bounds ke bahar hit-test fail hota
            // tha, aur barrier menu ke NEECHE hai taaki Urdu/en tap ho sake.
            if (_showLangMenu)
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => setState(() => _showLangMenu = false),
                  child: Container(color: Colors.transparent),
                ),
              ),
            if (_showLangMenu)
              Positioned(
                top: 64,
                right: 20,
                child: LanguageMenu(
                  current: _lang,
                  onSelect: (lang) {
                    setState(() {
                      _lang = lang;
                      _showLangMenu = false;
                    });
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseGrid(BuildContext context) {
    final exercises = _exercises;
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: exercises.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 0.78,
      ),
      itemBuilder: (context, index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 400 + index * 120),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 30 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: _buildExerciseTile(context, exercises[index]),
        );
      },
    );
  }

  Widget _buildExerciseTile(BuildContext context, _ExerciseData data) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ExercisePlayerScreen(exercise: data.exerciseInfo),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: .06),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
            BoxShadow(
              color: data.color.withValues(alpha: .40),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Full image cover
            Image.asset(
              data.asset,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: data.color,
                  alignment: Alignment.center,
                  child: Icon(
                    data.fallbackIcon,
                    color: darkBlue,
                    size: 40,
                  ),
                );
              },
            ),
            // Gradient overlay at bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0),
                      Colors.black.withValues(alpha: 0.65),
                    ],
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      data.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Play icon overlay
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
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
                color: const Color(0xFF202952),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .85),
                ),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: background,
                size: 17,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Text(
              _t('header', _screenTr),
              style: const TextStyle(
                color: darkText,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          // Language button — menu build() ke root Stack mein render hota hai
          // (header ke chhote Stack ke bounds ke BAHAR tap register nahi hota).
          GestureDetector(
            onTap: () => setState(() => _showLangMenu = !_showLangMenu),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF202952),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.white.withValues(alpha: .85),
                ),
              ),
              child: const Icon(
                Icons.language_rounded,
                color: background,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseData {
  final String title;
  final String subtitle;
  final String asset;
  final IconData fallbackIcon;
  final Color color;
  final dynamic exerciseInfo;

  _ExerciseData({
    required this.title,
    required this.subtitle,
    required this.asset,
    required this.fallbackIcon,
    required this.color,
    required this.exerciseInfo,
  });
}
