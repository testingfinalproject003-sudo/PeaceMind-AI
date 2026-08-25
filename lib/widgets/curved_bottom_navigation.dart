import 'package:flutter/material.dart';

// 1. Navigation Item Data Model
class NavigationItem {
  final IconData icon;
  final String label;

  NavigationItem({required this.icon, required this.label});
}

// 2. Main Curved Bottom Navigation Widget
class CurvedBottomNavigation extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;
  final List<NavigationItem> items;
  final Color darkBlue;
  final Color royalOcean;

  const CurvedBottomNavigation({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    required this.items,
    required this.darkBlue,
    required this.royalOcean,
  });

  @override
  Widget build(BuildContext context) {
    const double barHeight = 70.0;
    final double itemWidth = MediaQuery.of(context).size.width / items.length;

    return SizedBox(
      height: barHeight + 25,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.bottomCenter,
        children: [
          // Dynamic Curved Background
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: selectedIndex.toDouble()),
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            builder: (context, animatedIndex, child) {
              return ClipPath(
                clipper: BottomNavClipper(
                  activeIndex: animatedIndex,
                  itemCount: items.length,
                ),
                child: Container(
                  height: barHeight,
                  color: darkBlue,
                ),
              );
            },
          ),

          // Floating Animated White Circle Button
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutCubic,
            bottom: barHeight - 25,
            left: (selectedIndex * itemWidth) + (itemWidth / 2) - 28,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: darkBlue.withValues(alpha: 0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                items[selectedIndex].icon,
                color: royalOcean,
                size: 26,
              ),
            ),
          ),

          // Navigation Icons and Labels
          SizedBox(
            height: barHeight,
            child: Row(
              children: List.generate(items.length, (index) {
                final selected = selectedIndex == index;
                final item = items[index];

                return Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onItemSelected(index),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (!selected)
                          Icon(
                            item.icon,
                            color: Colors.white.withValues(alpha: 0.55),
                            size: 22,
                          )
                        else
                          const SizedBox(height: 22),

                        const SizedBox(height: 6),

                        Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            item.label,
                            style: TextStyle(
                              color: selected
                                  ? royalOcean
                                  : Colors.white.withValues(alpha: 0.55),
                              fontSize: 11,
                              fontWeight: selected
                                  ? FontWeight.w800
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// 3. Custom Clipper for dynamic notch curve
class BottomNavClipper extends CustomClipper<Path> {
  final double activeIndex;
  final int itemCount;

  BottomNavClipper({required this.activeIndex, required this.itemCount});

  @override
  Path getClip(Size size) {
    final path = Path();
    final itemWidth = size.width / itemCount;
    final currentCenterX = (activeIndex * itemWidth) + (itemWidth / 2);

    const cornerRadius = 24.0;
    const curveWidth = 45.0;
    const curveDepth = 28.0;

    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    path.lineTo(currentCenterX - curveWidth, 0);

    path.cubicTo(
      currentCenterX - (curveWidth / 2),
      0,
      currentCenterX - (curveWidth / 2),
      curveDepth,
      currentCenterX,
      curveDepth,
    );
    path.cubicTo(
      currentCenterX + (curveWidth / 2),
      curveDepth,
      currentCenterX + (curveWidth / 2),
      0,
      currentCenterX + curveWidth,
      0,
    );

    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant BottomNavClipper oldClipper) {
    return oldClipper.activeIndex != activeIndex;
  }
}