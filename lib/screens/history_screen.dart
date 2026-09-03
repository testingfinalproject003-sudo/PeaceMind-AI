import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/routine_provider.dart';
import '../models/history_model.dart';

// ═══════════════════════════════════════════════════════════════
//  HISTORY / PROGRESS REPORT SCREEN
//  Sirf REAL data — routines, exercises aur NOVA voice calls.
//  Sab kuch RoutineProvider (local + Firestore sync) se aata hai.
// ═══════════════════════════════════════════════════════════════
class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // 'all' | 'task' | 'exercise' | 'audio'
  String _filter = 'all';

  // ── helpers ──
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
      case 'exercise':
        return const Color(0xFF10B981);
      case 'audio':
        return const Color(0xFF8B5CF6);
      case 'chat':
        return const Color(0xFF0EA5E9);
      default:
        return const Color(0xFF0B6FA8);
    }
  }

  String _catEmoji(String cat) {
    switch (cat) {
      case 'morning':
        return '🌅';
      case 'afternoon':
        return '☀️';
      case 'evening':
        return '🌇';
      case 'night':
        return '🌙';
      case 'exercise':
        return '🧘';
      case 'audio':
        return '🎙️';
      case 'chat':
        return '💬';
      default:
        return '✨';
    }
  }

  String _catLabel(String cat) {
    switch (cat) {
      case 'morning':
        return 'Morning';
      case 'afternoon':
        return 'Afternoon';
      case 'evening':
        return 'Evening';
      case 'night':
        return 'Night';
      case 'exercise':
        return 'Exercise';
      case 'audio':
        return 'Voice Call';
      case 'chat':
        return 'Chat';
      default:
        return 'Task';
    }
  }

  /// Filter groups — har entry ek group mein aati hai
  String _filterGroup(String category) {
    switch (category) {
      case 'exercise':
      case 'audio':
      case 'chat':
        return category;
      default:
        return 'task'; // morning / afternoon / evening / night
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
            color: isSelected
                ? const Color(0xFF0B6FA8)
                : const Color(0xFFE0E0E0),
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
    final history = provider.history; // newest first

    // ── REAL stats ──
    final streak = provider.getCurrentStreak();
    final catCounts = provider.getCategoryCounts();
    final daily = provider.getDailyCompletionCounts();
    final taskCount = history.length;

    // Mood wali entries ka average (voice calls mein mood nahi hota)
    final moodEntries = history.where((h) => h.moodScore != null).toList();
    final avgMood = moodEntries.isEmpty
        ? 0.0
        : moodEntries.map((h) => h.moodScore!).reduce((a, b) => a + b) /
              moodEntries.length;
    final performance = moodEntries.isEmpty
        ? 0
        : ((avgMood + (streak * 5)).clamp(0, 100)).toInt();

    // ── last 7 days list (today → 6 days ago) ──
    final now = DateTime.now();
    final weekDays = List.generate(7, (i) {
      return DateTime(
        now.year,
        now.month,
        now.day,
      ).subtract(Duration(days: 6 - i));
    });

    // ── bar chart data: har dinn ki total activities ──
    // maxY dynamic hai taake 5+ activities par overflow na ho
    final maxDaily = daily.values.isEmpty
        ? 0
        : daily.values.reduce((a, b) => a > b ? a : b);
    final barMaxY = (maxDaily + 1).clamp(5, 50).toDouble();

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
              toY: barMaxY,
              color: const Color(0xFFF1ECFA),
            ),
          ),
        ],
      );
    }).toList();

    // ── line chart data: sirf mood wali entries ──
    final hasMoodData = moodEntries.any((h) {
      final d = DateTime(
        h.completedAt.year,
        h.completedAt.month,
        h.completedAt.day,
      );
      return weekDays.contains(d);
    });

    final moodSpots = <FlSpot>[];
    if (hasMoodData) {
      for (var i = 0; i < weekDays.length; i++) {
        final dayEntries = history.where((h) {
          final hd = DateTime(
            h.completedAt.year,
            h.completedAt.month,
            h.completedAt.day,
          );
          return hd == weekDays[i] && h.moodScore != null;
        }).toList();
        final avg = dayEntries.isEmpty
            ? 0.0
            : dayEntries.map((h) => h.moodScore!).reduce((a, b) => a + b) /
                  dayEntries.length;
        moodSpots.add(FlSpot(i.toDouble(), avg));
      }
    }

    // ── pie chart data (categories) ──
    final catKeys = catCounts.keys.toList();
    final pieColors = <Color>[
      const Color(0xFFE3B15F),
      const Color(0xFF2C9BD6),
      const Color(0xFFB9A8DD),
      const Color(0xFF10B981),
      const Color(0xFF8B5CF6),
      const Color(0xFF063A5E),
    ];
    final pieSections = catCounts.entries.toList().asMap().entries.map((e) {
      final count = e.value.value;
      return PieChartSectionData(
        color: pieColors[e.key % pieColors.length],
        value: count.toDouble(),
        title: '$count',
        radius: 44,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();

    // ── FILTERED sessions ──
    final filteredSessions = history
        .where((h) => _filter == 'all' || _filterGroup(h.category) == _filter)
        .toList();

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
      body: history.isEmpty
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
                        label: 'Activities',
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
                  //  WEEKLY ACTIVITY BAR CHART
                  // ═══════════════════════════════════════
                  const _SectionTitle('Weekly Activity'),
                  const SizedBox(height: 8),
                  _ChartCard(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        maxY: barMaxY,
                        barTouchData: BarTouchData(
                          touchTooltipData: BarTouchTooltipData(
                            getTooltipItem: (group, groupIndex, rod, rodIndex) {
                              if (group.x < 0 || group.x >= weekDays.length) {
                                return null;
                              }
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
                              reservedSize: 22,
                              getTitlesWidget: (v, _) {
                                final idx = v.toInt();
                                if (idx < 0 || idx >= weekDays.length) {
                                  return const SizedBox();
                                }
                                return Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    DateFormat.E().format(weekDays[idx])[0],
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
                  //  MOOD TREND LINE CHART (sirf mood data)
                  // ═══════════════════════════════════════
                  const _SectionTitle('Mood Trend'),
                  const SizedBox(height: 8),
                  _ChartCard(
                    height: 180,
                    child: hasMoodData
                        ? LineChart(
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
                                    reservedSize: 22,
                                    getTitlesWidget: (v, _) {
                                      final idx = v.toInt();
                                      if (idx < 0 || idx >= weekDays.length) {
                                        return const SizedBox();
                                      }
                                      return Padding(
                                        padding: const EdgeInsets.only(top: 6),
                                        child: Text(
                                          DateFormat.E().format(
                                            weekDays[idx],
                                          )[0],
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
                                    reservedSize: 28,
                                    getTitlesWidget: (v, _) => Text(
                                      v.toInt().toString(),
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Color(0xFF7C8A90),
                                      ),
                                    ),
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
                                    color: const Color(
                                      0xFF0B6FA8,
                                    ).withValues(alpha: 0.1),
                                  ),
                                  dotData: const FlDotData(show: true),
                                ),
                              ],
                            ),
                          )
                        : const Center(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Text(
                                'No mood data yet.\nComplete a routine with a mood to see your trend.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF7C8A90),
                                  height: 1.5,
                                ),
                              ),
                            ),
                          ),
                  ),

                  const SizedBox(height: 22),

                  // ═══════════════════════════════════════
                  //  CATEGORY BREAKDOWN (PIE)
                  // ═══════════════════════════════════════
                  if (catCounts.isNotEmpty) ...[
                    const _SectionTitle('By Category'),
                    const SizedBox(height: 8),
                    _ChartCard(
                      height: 200,
                      child: Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: PieChart(
                              PieChartData(
                                sectionsSpace: 2,
                                centerSpaceRadius: 26,
                                sections: pieSections,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            flex: 4,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: catKeys.map((key) {
                                final idx = catKeys.indexOf(key);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 3,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color:
                                              pieColors[idx % pieColors.length],
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          '${_catEmoji(key)} ${_catLabel(key)}',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${catCounts[key]}',
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
                          ),
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
                        _buildFilterChip('Exercises', 'exercise', '🧘'),
                        _buildFilterChip('Calls', 'audio', '🎙️'),
                        _buildFilterChip('Chat', 'chat', '💬'),
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
                      itemCount: filteredSessions.length > 30
                          ? 30
                          : filteredSessions.length,
                      itemBuilder: (_, i) =>
                          _buildHistoryTile(filteredSessions[i]),
                    ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // ── Real history tile (task / exercise / voice call) ──
  Widget _buildHistoryTile(HistoryEntry h) {
    final isVoiceCall = h.category == 'audio';

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
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _catColor(h.category).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${_catEmoji(h.category)} ${_catLabel(h.category)}',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: _catColor(h.category),
                  ),
                ),
              ),
              const Spacer(),
              Flexible(
                child: Text(
                  DateFormat('MMM d, h:mm a').format(h.completedAt),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF7C8A90),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (isVoiceCall)
                Icon(Icons.mic_rounded, size: 16, color: _catColor(h.category)),
              if (isVoiceCall) const SizedBox(width: 6),
              Expanded(
                child: Text(
                  h.routineTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF233238),
                  ),
                ),
              ),
            ],
          ),
          if (h.moodScore != null || (h.notes?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                if (h.moodScore != null) ...[_MoodBadge(score: h.moodScore!)],
                if (h.notes != null && h.notes!.isNotEmpty) ...[
                  if (h.moodScore != null) const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      h.notes!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFF7C8A90),
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
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
              'Complete routines, exercises or a NOVA call to see your progress here.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF7C8A90)),
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
              ),
              child: const Text(
                'Go Back',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
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
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 4),
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
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
