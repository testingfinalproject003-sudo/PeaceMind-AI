import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../providers/garden_provider.dart';
import '../theme/app_theme.dart';
import 'skeleton.dart';

class GardenWidget extends StatelessWidget {
  const GardenWidget({super.key});

  static const String _gardenBackground =
      'assets/images/home/garden_background.jpg';
  static const String _staticTree = 'assets/animations/garden_tree_static.json';
  static const String _growingTree = 'assets/animations/garden_tree_growing.json';

  @override
  Widget build(BuildContext context) {
    final garden = context.watch<GardenProvider>();

    if (garden.isLoading) return _buildLoadingGarden();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(_gardenBackground),
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          child: _buildGardenContent(garden),
        ),
      ),
    );
  }

  Widget _buildLoadingGarden() {
    // Skeleton layout mirrors the real garden card
    // (header + tree grid + progress bar) — no spinner.
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          color: const Color(0xFFE8F0E3),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  SkeletonBlock(width: 140, height: 16),
                  Spacer(),
                  SkeletonBlock(width: 60, height: 16),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(
                  6,
                  (_) => const SkeletonBlock(
                    width: 40,
                    height: 40,
                    radius: 20,
                  ),
                ),
              ),
              const SizedBox(height: 18),
              const SkeletonBlock(height: 10, radius: 5),
              const SizedBox(height: 6),
              const SkeletonBlock(height: 8, radius: 4),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGardenContent(GardenProvider garden) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(garden),
          const SizedBox(height: 12),
          _buildTreeGrid(garden),
          const SizedBox(height: 10),
          _buildProgressBar(garden),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  Widget _buildHeader(GardenProvider garden) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Growth Garden 🌱',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(color: Colors.black45, blurRadius: 4),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${garden.totalTrees} trees grown · ${garden.gardenStreak} streak 🔥',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(color: Colors.black38, blurRadius: 3),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _buildStreakBadge(garden),
      ],
    );
  }

  Widget _buildStreakBadge(GardenProvider garden) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0x55FFFFFF), Color(0x33FFFFFF)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 13)),
          const SizedBox(width: 3),
          Text(
            '${garden.gardenStreak}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(color: Colors.black38, blurRadius: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTreeGrid(GardenProvider garden) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: GardenProvider.totalSlots,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 2,
          mainAxisSpacing: 4,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final hasTree = index < garden.treeCount;
          final isNewlyGrown = index == garden.lastGrownIndex && hasTree;
          return _buildTreeSlot(hasTree, isNewlyGrown);
        },
      ),
    );
  }

  Widget _buildTreeSlot(bool hasTree, bool isNewlyGrown) {
    return ClipRect(
      child: hasTree
          ? (isNewlyGrown
              ? _buildGrowingTreeAnimation()
              : _buildStaticTree())
          : _buildEmptySlot(),
    );
  }

  Widget _buildGrowingTreeAnimation() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
      builder: (context, scale, child) {
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: Center(
        child: SizedBox(
          width: 58,
          height: 58,
          child: Lottie.asset(
            _growingTree,
            animate: true,
            repeat: false,
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              // Fallback: show static tree with glow
              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: AppColors.green.withValues(alpha: 0.20),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.green.withValues(alpha: 0.30),
                          blurRadius: 14,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),
                  const Text('🌳', style: TextStyle(fontSize: 32)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildStaticTree() {
    return Center(
      child: SizedBox(
        width: 58,
        height: 58,
        child: Lottie.asset(
          _staticTree,
          animate: true,
          repeat: false,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            return const Center(
              child: Text('🌳', style: TextStyle(fontSize: 32)),
            );
          },
        ),
      ),
    );
  }

  Widget _buildEmptySlot() {
    return Center(
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: 0.08),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: const Center(
          child: Text(
            '+',
            style: TextStyle(
              color: Colors.white24,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(GardenProvider garden) {
    final frac = garden.treeCount / GardenProvider.totalSlots;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Text('🌱', style: TextStyle(fontSize: 11)),
          const SizedBox(width: 6),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(5),
              child: Container(
                height: 8,
                color: Colors.white.withValues(alpha: 0.15),
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: frac),
                  duration: const Duration(milliseconds: 800),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) =>
                      FractionallySizedBox(
                    widthFactor: value,
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
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${garden.treeCount}/${GardenProvider.totalSlots}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              shadows: [
                Shadow(color: Colors.black38, blurRadius: 2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
