import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_theme.dart';
import '../models/exercise_models.dart';
import '../providers/garden_provider.dart';
import 'glass_widgets.dart';

class CompletionOverlay extends StatefulWidget {
  final CompletionConfig config;
  final Duration totalTime;
  final int cycles;
  final int previousCycles;
  final AppLang lang;
  final VoidCallback onClose;
  final VoidCallback onRestart;

  const CompletionOverlay({
    super.key,
    required this.config,
    required this.totalTime,
    required this.cycles,
    this.previousCycles = 0,
    this.lang = AppLang.en,
    required this.onClose,
    required this.onRestart,
  });

  @override
  State<CompletionOverlay> createState() => _CompletionOverlayState();
}

class _CompletionOverlayState extends State<CompletionOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _entrance = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  late final AnimationController _bars = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..forward();
  late final AnimationController _rings = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  )..forward();
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat(reverse: true);
  late final List<_ConfettiPiece> _pieces = List.generate(
    36,
    (i) => _ConfettiPiece(i),
  );

  @override
  void dispose() {
    _entrance.dispose();
    _bars.dispose();
    _rings.dispose();
    _pulse.dispose();
    super.dispose();
  }

  int get calmPct => min(95, 55 + widget.cycles * 15);
  int get focusPct => min(98, 60 + widget.cycles * 12);
  int get prevCalmPct =>
      widget.previousCycles > 0 ? min(95, 55 + widget.previousCycles * 15) : 0;
  int get prevFocusPct =>
      widget.previousCycles > 0 ? min(98, 60 + widget.previousCycles * 12) : 0;

  // ── i18n helpers ──
  static const _uiTr = {
    'total_time':  {AppLang.en: 'TOTAL TIME', AppLang.ur: 'کل وقت', AppLang.urRoman: 'Kul Waqt', AppLang.pa: 'ਕੁੱਲ ਸਮਾਂ'},
    'cycles_done': {AppLang.en: 'CYCLES DONE', AppLang.ur: 'مکمل چکر', AppLang.urRoman: 'Mukammal Chakkar', AppLang.pa: 'ਪੂਰੇ ਚੱਕਰ'},
    'previous':    {AppLang.en: 'Previous', AppLang.ur: 'پچھلا', AppLang.urRoman: 'Pichla', AppLang.pa: 'ਪਿਛਲਾ'},
    'current':     {AppLang.en: 'Current', AppLang.ur: 'موجودہ', AppLang.urRoman: 'Mojooda', AppLang.pa: 'ਮੌਜੂਦਾ'},
    'better':      {AppLang.en: 'Better!', AppLang.ur: '!بہتر', AppLang.urRoman: 'Behtar!', AppLang.pa: 'ਬਿਹਤਰ!'},
    'calm':        {AppLang.en: 'Calm', AppLang.ur: 'سکون', AppLang.urRoman: 'Sukoon', AppLang.pa: 'ਸ਼ਾਂਤੀ'},
    'focus':       {AppLang.en: 'Focus', AppLang.ur: 'توجہ', AppLang.urRoman: 'Tawajjo', AppLang.pa: 'ਧਿਆਨ'},
    'wellness_desc': {AppLang.en: 'Wellness scores based on your breathing cycles & session duration.', AppLang.ur: 'آپ کے سانس کے چکروں اور سیشن کے دورانیے پر مبنی تندرستی اسکور۔', AppLang.urRoman: 'Aapke saans ke chakkaron aur session duration par mabni tandurusti score.', AppLang.pa: "ਤੁਹਾਡੇ ਸਾਹ ਚੱਕਰਾਂ ਅਤੇ ਸੈਸ਼ਨ ਸਮੇਂ 'ਤੇ ਅਧਾਰਤ ਤੰਦਰੁਸਤੀ ਸਕੋਰ।"},
    'garden_progress': {AppLang.en: 'Garden Progress', AppLang.ur: 'باغ کی پیشرفت', AppLang.urRoman: 'Baagh Ki Peshraft', AppLang.pa: 'ਬਾਗ਼ ਦੀ ਤਰੱਕੀ'},
    'finish':      {AppLang.en: 'Finish', AppLang.ur: 'مکمل', AppLang.urRoman: 'Mukammal', AppLang.pa: 'ਪੂਰਾ'},
    'new_cycle':   {AppLang.en: 'Start New Cycle', AppLang.ur: 'نیا چکر شروع کریں', AppLang.urRoman: 'Naya Chakkar Shuru Karein', AppLang.pa: 'ਨਵਾਂ ਚੱਕਰ ਸ਼ੁਰੂ'},
    'cycles_lbl':  {AppLang.en: 'cycles', AppLang.ur: 'چکر', AppLang.urRoman: 'chakkar', AppLang.pa: 'ਚੱਕਰ'},
  };

  String _t(String key) {
    final map = _uiTr[key];
    return map?[widget.lang] ?? map?[AppLang.en] ?? key;
  }

  static const _completionTr = {
    'Breath Steadied': {AppLang.ur: 'سانس مستحکم ہوا', AppLang.urRoman: 'Saans Mustahkam Hua', AppLang.pa: 'ਸਾਹ ਸਥਿਰ ਹੋਇਆ'},
    'Grounded & Present': {AppLang.ur: 'جڑا ہوا اور حاضر', AppLang.urRoman: 'Jura Hua aur Haazir', AppLang.pa: 'ਜੁੜਿਆ ਅਤੇ ਮੌਜੂਦ'},
    'Session Complete!': {AppLang.ur: '!سیشن مکمل', AppLang.urRoman: 'Session Mukammal!', AppLang.pa: 'ਸੈਸ਼ਨ ਪੂਰਾ!'},
    'Mindfully Walked': {AppLang.ur: 'توجہ سے چلے', AppLang.urRoman: 'Tawajjo Se Chale', AppLang.pa: 'ਧਿਆਨ ਨਾਲ ਤੁਰੇ'},
  };

  String get _trTitle {
    final tr = _completionTr[widget.config.title];
    return tr?[widget.lang] ?? widget.config.title;
  }

  String get _trSubtitle {
    final n = widget.config.unitCount;
    switch (widget.config.title) {
      case 'Breath Steadied':
        switch (widget.lang) {
          case AppLang.ur: return 'آپ نے $n سانس کے مراحل تال میں مکمل کیے۔\nآپ کا اعصابی نظام آپ کا شکریہ ادا کرتا ہے۔';
          case AppLang.urRoman: return 'Aapne $n saans ke maraahil taal mein mukammal kiye.\nAapka asabi nizaam aapka shukriya ada karta hai.';
          case AppLang.pa: return 'ਤੁਸੀਂ $n ਸਾਹ ਪੜਾਅ ਤਾਲ ਵਿੱਚ ਪੂਰੇ ਕੀਤੇ।\nਤੁਹਾਡਾ ਨਸ ਪ੍ਰਣਾਲੀ ਤੁਹਾਡਾ ਧੰਨਵਾਦ ਕਰਦੀ ਹੈ।';
          default: return widget.config.subtitleBuilder(n);
        }
      case 'Grounded & Present':
        switch (widget.lang) {
          case AppLang.ur: return 'آپ نے $n حواس کے ذریعے موجودہ لمحے سے دوبارہ جڑے۔\nبہت خوب — آپ یہاں ہیں، اور محفوظ ہیں۔';
          case AppLang.urRoman: return 'Aapne $n hawas ke zariye mojooda lamhay se dobara jure.\nBohat khoob — aap yahan hain, aur mehfooz hain.';
          case AppLang.pa: return 'ਤੁਸੀਂ $n ਇੰਦਰੀਆਂ ਰਾਹੀਂ ਮੌਜੂਦਾ ਪਲ ਨਾਲ ਦੁਬਾਰਾ ਜੁੜੇ।\nਬਹੁਤ ਵਧੀਆ — ਤੁਸੀਂ ਇੱਥੇ ਹੋ, ਸੁਰੱਖਿਅਤ।';
          default: return widget.config.subtitleBuilder(n);
        }
      case 'Session Complete!':
        switch (widget.lang) {
          case AppLang.ur: return 'آپ نے $n پٹھوں کے گروپس میں تناؤ چھوڑا۔\nبہت خوب — آپ کا جسم آپ کا شکریہ ادا کرتا ہے۔';
          case AppLang.urRoman: return 'Aapne $n pathon ke groups mein tanao chora.\nBohat khoob — aapka jism aapka shukriya ada karta hai.';
          case AppLang.pa: return 'ਤੁਸੀਂ $n ਮਾਸਪੇਸ਼ੀ ਸਮੂਹਾਂ ਵਿੱਚ ਤਣਾਅ ਛੱਡਿਆ।\nਬਹੁਤ ਵਧੀਆ — ਤੁਹਾਡਾ ਸਰੀਰ ਤੁਹਾਡਾ ਧੰਨਵਾਦ ਕਰਦਾ ਹੈ।';
          default: return widget.config.subtitleBuilder(n);
        }
      case 'Mindfully Walked':
        switch (widget.lang) {
          case AppLang.ur: return 'آپ نے $n توجہ سے قدم چلے، مکمل طور پر جسم میں حاضر۔\nآہستہ رفتار، آگے لے کر۔';
          case AppLang.urRoman: return 'Aapne $n tawajjo se qadam chale, mukammal tor par jism mein haazir.\nAahista raftaar, aage le kar.';
          case AppLang.pa: return 'ਤੁਸੀਂ $n ਧਿਆਨ ਨਾਲ ਕਦਮ ਤੁਰੇ, ਪੂਰੀ ਤਰ੍ਹਾਂ ਸਰੀਰ ਵਿੱਚ ਮੌਜੂਦ।\nਹੌਲੀ ਗਤੀ, ਅੱਗੇ ਲੈ ਕੇ।';
          default: return widget.config.subtitleBuilder(n);
        }
      default: return widget.config.subtitleBuilder(n);
    }
  }

  static const _motivations = [
    {
      AppLang.en: 'You showed up for yourself today — that takes real strength.',
      AppLang.ur: 'آپ نے آج اپنے لیے وقت نکالا — یہ واقعی ہمت کی بات ہے۔',
      AppLang.urRoman: 'Aapne aaj apne liye waqt nikala — yeh waakai himmat ki baat hai.',
      AppLang.pa: 'ਤੁਸੀਂ ਅੱਜ ਆਪਣੇ ਲਈ ਸਮਾਂ ਕੱਢਿਆ — ਇਹ ਸੱਚਮੁੱਚ ਹਿੰਮਤ ਦੀ ਗੱਲ ਹੈ।',
    },
    {
      AppLang.en: 'Every breath you took was a choice to be present.',
      AppLang.ur: 'آپ کا ہر سانس، حاضر رہنے کا ایک انتخاب تھا۔',
      AppLang.urRoman: 'Aapka har saans, haazir rehne ka aik intekhab tha.',
      AppLang.pa: 'ਤੁਹਾਡਾ ਹਰ ਸਾਹ, ਮੌਜੂਦ ਰਹਿਣ ਦੀ ਚੋਣ ਸੀ।',
    },
    {
      AppLang.en: 'This calm is yours. Carry it forward.',
      AppLang.ur: 'یہ سکون آپ کا ہے۔ اسے آگے لے کر چلیں۔',
      AppLang.urRoman: 'Yeh sukoon aapka hai. Isay aage le kar chalein.',
      AppLang.pa: 'ਇਹ ਸ਼ਾਂਤੀ ਤੁਹਾਡੀ ਹੈ। ਇਸਨੂੰ ਅੱਗੇ ਲੈ ਕੇ ਚੱਲੋ।',
    },
    {
      AppLang.en: 'You are building a habit that changes lives.',
      AppLang.ur: 'آپ ایک ایسی عادت بنا رہے ہیں جو زندگیاں بدلتی ہے۔',
      AppLang.urRoman: 'Aap aik aisi aadat bana rahe hain jo zindagi badalti hai.',
      AppLang.pa: 'ਤੁਸੀਂ ਇੱਕ ਅਜਿਹੀ ਆਦਤ ਬਣਾ ਰਹੇ ਹੋ ਜੋ ਜ਼ਿੰਦਗੀਆਂ ਬਦਲਦੀ ਹੈ।',
    },
    {
      AppLang.en: 'Small moments of stillness create big shifts.',
      AppLang.ur: 'خاموشی کے چھوٹے لمحے بڑی تبدیلیاں لاتے ہیں۔',
      AppLang.urRoman: 'Khamoshi ke chotay lamhay bari tabdeeliyan laate hain.',
      AppLang.pa: 'ਚੁੱਪ ਦੇ ਛੋਟੇ ਪਲ ਵੱਡੀਆਂ ਤਬਦੀਲੀਆਂ ਲਿਆਉਂਦੇ ਹਨ।',
    },
    {
      AppLang.en: 'Your mind and body thank you for this pause.',
      AppLang.ur: 'آپ کا ذہن اور جسم اس توقف پر آپ کا شکریہ ادا کرتے ہیں۔',
      AppLang.urRoman: 'Aapka zehn aur jism is tauqquf par aapka shukriya ada karte hain.',
      AppLang.pa: 'ਤੁਹਾਡਾ ਮਨ ਅਤੇ ਸਰੀਰ ਇਸ ਵਿਰਾਮ ਲਈ ਤੁਹਾਡਾ ਧੰਨਵਾਦ ਕਰਦੇ ਹਨ।',
    },
    {
      AppLang.en: 'Consistency is the foundation of inner peace.',
      AppLang.ur: 'استقلال اندرونی سکون کی بنیاد ہے۔',
      AppLang.urRoman: 'Istiqlal andarooni sukoon ki bunyad hai.',
      AppLang.pa: 'ਨਿਰੰਤਰਤਾ ਅੰਦਰੂਨੀ ਸ਼ਾਂਤੀ ਦੀ ਨੀਂਹ ਹੈ।',
    },
  ];

  String get _motivation {
    final entry = _motivations[widget.cycles % _motivations.length];
    return entry[widget.lang] ?? entry[AppLang.en] ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entrance,
      builder: (context, _) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.skyTop,
                AppColors.skyMid,
                AppColors.skyBot,
                AppColors.accent.withValues(alpha: 0.08 * _entrance.value),
              ],
            ),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return Stack(
                children: [
                  ..._pieces.map(
                    (p) => _ConfettiWidget(piece: p, areaSize: size),
                  ),
                  SafeArea(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 10),
                          _buildMotivationQuote(),
                          const SizedBox(height: 12),
                          _buildStatCards(),
                          const SizedBox(height: 10),
                          if (widget.previousCycles > 0) ...[
                            _buildCycleComparison(),
                            const SizedBox(height: 10),
                          ],
                          _buildScoreRings(),
                          const SizedBox(height: 10),
                          _buildTreeProgress(),
                          const SizedBox(height: 10),
                          _buildAnalysisChart(),
                          const SizedBox(height: 14),
                          _buildButtons(),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  // ── Header ──
  Widget _buildHeader() {
    return ScaleTransition(
      scale: CurvedAnimation(parent: _entrance, curve: Curves.elasticOut),
      child: Column(
        children: [
          Container(
            width: 78,
            height: 78,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: AppColors.goldGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0x55FFAA3C),
                  blurRadius: 30 + 10 * _pulse.value,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: const Text('🏆', style: TextStyle(fontSize: 36)),
          ),
          const SizedBox(height: 10),
          Text(
            _trTitle,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            _trSubtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: AppColors.inkSoft,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ── Motivational quote ──
  Widget _buildMotivationQuote() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withValues(alpha: 0.10),
            AppColors.accent2.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.accent.withValues(alpha: 0.18)),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.format_quote_rounded,
            color: AppColors.accent,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _motivation,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.ink,
                fontWeight: FontWeight.w600,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stat cards row ──
  Widget _buildStatCards() {
    return Row(
      children: [
        _StatCard(
          value: fmtDuration(widget.totalTime),
          label: _t('total_time'),
          icon: Icons.timer_outlined,
        ),
        const SizedBox(width: 8),
        _StatCard(
          value: '${widget.cycles}',
          label: _t('cycles_done'),
          icon: Icons.autorenew_rounded,
        ),
        const SizedBox(width: 8),
        _StatCard(
          value: '${widget.config.unitCount}',
          label: widget.config.unitLabel,
          icon: Icons.insights_rounded,
        ),
      ],
    );
  }

  // ── Cycle comparison (previous vs current) ──
  Widget _buildCycleComparison() {
    final improved = widget.cycles > widget.previousCycles;
    return GlassPanel(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          // Previous
          Expanded(
            child: _MiniCompare(
              label: _t('previous'),
              cycles: widget.previousCycles,
              calm: prevCalmPct,
              focus: prevFocusPct,
              cyclesLbl: _t('cycles_lbl'),
              calmLbl: _t('calm'),
              focusLbl: _t('focus'),
            ),
          ),
          // Arrow
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Column(
              children: [
                Icon(
                  improved
                      ? Icons.trending_up_rounded
                      : Icons.compare_arrows_rounded,
                  color: improved ? AppColors.green : AppColors.inkSoft,
                  size: 20,
                ),
                if (improved)
                  Text(
                    _t('better'),
                    style: const TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                      color: AppColors.green,
                    ),
                  ),
              ],
            ),
          ),
          // Current
          Expanded(
            child: _MiniCompare(
              label: _t('current'),
              cycles: widget.cycles,
              calm: calmPct,
              focus: focusPct,
              isCurrent: true,
              cyclesLbl: _t('cycles_lbl'),
              calmLbl: _t('calm'),
              focusLbl: _t('focus'),
            ),
          ),
        ],
      ),
    );
  }

  // ── Dual score rings ──
  Widget _buildScoreRings() {
    return Row(
      children: [
        _ScoreRing(
          percent: calmPct,
          label: _t('calm'),
          animCtrl: _rings,
          color: AppColors.accent,
        ),
        const SizedBox(width: 8),
        _ScoreRing(
          percent: focusPct,
          label: _t('focus'),
          animCtrl: _rings,
          color: AppColors.green,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GlassPanel(
            radius: 14,
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.spa_rounded,
                  size: 14,
                  color: AppColors.accent,
                ),
                const SizedBox(height: 4),
                Text(
                  _t('wellness_desc'),
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.inkSoft,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Tree growth progress ──
  Widget _buildTreeProgress() {
    return GlassPanel(
      radius: 16,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF3ECF7A), Color(0xFF2A9D5C)],
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.green.withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Lottie.asset(
              'assets/animations/garden_tree_growing.json',
              width: 30,
              height: 30,
              fit: BoxFit.contain,
              repeat: true,
              errorBuilder: (context, error, stackTrace) =>
                  const Text('🌱', style: TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _t('garden_progress'),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const Spacer(),
                    Consumer<GardenProvider>(
                      builder: (_, g, _) => Text(
                        '${g.treeCount}/${GardenProvider.totalSlots}',
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.green,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Consumer<GardenProvider>(
                  builder: (_, g, _) {
                    final frac = g.treeCount / GardenProvider.totalSlots;
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Container(
                        height: 8,
                        color: const Color(0x80FFFFFF),
                        child: AnimatedBuilder(
                          animation: _bars,
                          builder: (_, _) => FractionallySizedBox(
                            widthFactor: frac * _bars.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF3ECF7A),
                                    Color(0xFF2A9D5C),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Analysis chart ──
  Widget _buildAnalysisChart() {
    return GlassPanel(
      radius: 18,
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.accent.withValues(alpha: 0.15),
                      AppColors.accent2.withValues(alpha: 0.08),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  size: 14,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                widget.config.chartTitle,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...widget.config.chartRows.map(
            (row) => Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                children: [
                  SizedBox(
                    width: 70,
                    child: Text(
                      row.label,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppColors.inkSoft,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Container(
                        height: 12,
                        color: const Color(0x88FFFFFF),
                        alignment: Alignment.centerLeft,
                        child: AnimatedBuilder(
                          animation: _bars,
                          builder: (_, _) => FractionallySizedBox(
                            widthFactor: (row.percent / 100) * _bars.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: AppColors.accentGradient,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 34,
                    child: Text(
                      '${row.percent}%',
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 9.5,
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Buttons ──
  Widget _buildButtons() {
    return Row(
      children: [
        Expanded(
          child: _OverlayButton(label: _t('finish'), onTap: widget.onClose),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _OverlayButton(
            label: _t('new_cycle'),
            primary: true,
            onTap: widget.onRestart,
          ),
        ),
      ],
    );
  }
}

// ── Stat card ──
class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _StatCard({
    required this.value,
    required this.label,
    required this.icon,
  });
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GlassPanel(
        radius: 16,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          children: [
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.accent.withValues(alpha: 0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 14, color: AppColors.accent),
            ),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 8, color: AppColors.inkSoft),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated score ring ──
class _ScoreRing extends StatelessWidget {
  final int percent;
  final String label;
  final AnimationController animCtrl;
  final Color color;
  const _ScoreRing({
    required this.percent,
    required this.label,
    required this.animCtrl,
    required this.color,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 58,
          height: 58,
          child: AnimatedBuilder(
            animation: animCtrl,
            builder: (_, _) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(58, 58),
                    painter: _RingPainter(
                      (percent / 100) * animCtrl.value,
                      color,
                    ),
                  ),
                  Container(
                    width: 46,
                    height: 46,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${(percent * animCtrl.value).round()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: AppColors.inkSoft,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ── Ring painter with custom color ──
class _RingPainter extends CustomPainter {
  final double frac;
  final Color color;
  _RingPainter(this.frac, this.color);
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final track = Paint()
      ..color = const Color(0x66FFFFFF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.38;
    canvas.drawCircle(center, radius * 0.68, track);
    final fg = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = radius * 0.38
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.68),
      -pi / 2,
      2 * pi * frac,
      false,
      fg,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.frac != frac || oldDelegate.color != color;
}

// ── Mini compare column (previous vs current) ──
class _MiniCompare extends StatelessWidget {
  final String label;
  final int cycles;
  final int calm;
  final int focus;
  final bool isCurrent;
  final String cyclesLbl;
  final String calmLbl;
  final String focusLbl;
  const _MiniCompare({
    required this.label,
    required this.cycles,
    required this.calm,
    required this.focus,
    this.isCurrent = false,
    this.cyclesLbl = 'cycles',
    this.calmLbl = 'Calm',
    this.focusLbl = 'Focus',
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: isCurrent
            ? AppColors.accent.withValues(alpha: 0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: isCurrent ? AppColors.accent : AppColors.inkSoft,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            '$cycles $cyclesLbl',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: isCurrent ? AppColors.accent : AppColors.ink,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '$calmLbl $calm%  ·  $focusLbl $focus%',
            style: const TextStyle(fontSize: 8, color: AppColors.inkSoft),
          ),
        ],
      ),
    );
  }
}

// ── Overlay button ──
class _OverlayButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;
  const _OverlayButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: primary ? AppColors.accentGradient : null,
          color: primary ? null : AppColors.glassStrong,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorder),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: primary ? Colors.white : AppColors.ink,
          ),
        ),
      ),
    );
  }
}

// ── Confetti ──
class _ConfettiPiece {
  final double left;
  final Color color;
  final double durationMs;
  final double delayMs;
  _ConfettiPiece(int seed)
    : left = Random(seed * 977).nextDouble(),
      color =
          AppColors.confettiColors[Random(
            seed * 131,
          ).nextInt(AppColors.confettiColors.length)],
      durationMs = 1800 + Random(seed * 53).nextDouble() * 1400,
      delayMs = Random(seed * 17).nextDouble() * 600;
}

class _ConfettiWidget extends StatefulWidget {
  final _ConfettiPiece piece;
  final Size areaSize;
  const _ConfettiWidget({required this.piece, required this.areaSize});
  @override
  State<_ConfettiWidget> createState() => _ConfettiWidgetState();
}

class _ConfettiWidgetState extends State<_ConfettiWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: widget.piece.durationMs.round()),
    );
    Future.delayed(Duration(milliseconds: widget.piece.delayMs.round()), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.areaSize.height;
    final w = widget.areaSize.width;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        final t = _c.value;
        return Positioned(
          left: widget.piece.left * w,
          top: -10 + t * (h + 10),
          child: Opacity(
            opacity: (1 - t).clamp(0, 1),
            child: Transform.rotate(
              angle: t * 2 * pi,
              child: Container(width: 7, height: 12, color: widget.piece.color),
            ),
          ),
        );
      },
    );
  }
}
