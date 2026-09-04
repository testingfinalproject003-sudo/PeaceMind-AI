import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';

class HomeHeader extends StatelessWidget {
  final int streak;
  final String motivation;
  final VoidCallback? onJournalTap;

  const HomeHeader({
    super.key,
    required this.streak,
    required this.motivation,
    this.onJournalTap,
  });

  String _getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good morning';
    }

    if (hour < 17) {
      return 'Good afternoon';
    }

    return 'Good evening';
  }

  @override
  Widget build(BuildContext context) {
    final userName = context.watch<AuthProvider>().userName;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        8,
      ),
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
                  color: const Color(0xFF173B55)
                      .withValues(alpha: 0.08),
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
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: const TextStyle(
                    color: Color(0xFF71827A),
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
                    color: Color(0xFF173B55),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  motivation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF174A45),
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
            padding: const EdgeInsets.symmetric(
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFECE8FA)
                  .withValues(alpha: 0.78),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
            child: Column(
              children: [
                const Text(
                  '🔥',
                  style: TextStyle(fontSize: 17),
                ),
                Text(
                  '$streak',
                  style: const TextStyle(
                    color: Color(0xFF173B55),
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),

          if (onJournalTap != null) ...[
            const SizedBox(width: 8),

            GestureDetector(
              onTap: onJournalTap,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.72),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.80),
                  ),
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  color: Color(0xFF173B55),
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}