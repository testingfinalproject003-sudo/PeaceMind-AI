import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GardenWidget extends StatefulWidget {
  const GardenWidget({
    super.key,
  });

  @override
  GardenWidgetState createState() => GardenWidgetState();
}

class GardenWidgetState extends State<GardenWidget> {
  // ===========================================================================
  // SETTINGS
  // ===========================================================================

  static const int totalSlots = 12;

  static const String _treeCountKey = 'garden_tree_count';
  static const String _gardenStreakKey = 'garden_streak';

  // ===========================================================================
  // ASSETS
  // ===========================================================================

  static const String _gardenBackground =
      'assets/images/home/garden_background.jpg';

  static const String _staticTree =
      'assets/animations/garden_tree_static.json';

  // ===========================================================================
  // STATE
  // ===========================================================================

  int _treeCount = 0;
  int _gardenStreak = 0;

  bool _isLoading = true;
  bool _isUpdating = false;

  // ===========================================================================
  // INIT
  // ===========================================================================

  @override
  void initState() {
    super.initState();
    _loadGarden();
  }

  // ===========================================================================
  // LOAD SAVED DATA
  // ===========================================================================

  Future<void> _loadGarden() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final savedTreeCount = prefs.getInt(_treeCountKey) ?? 0;
      final savedStreak = prefs.getInt(_gardenStreakKey) ?? 0;

      if (!mounted) {
        return;
      }

      setState(() {
        _treeCount = savedTreeCount.clamp(0, totalSlots);
        _gardenStreak = savedStreak < 0 ? 0 : savedStreak;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Garden load error: $e');

      if (!mounted) {
        return;
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  // ===========================================================================
  // SAVE DATA
  // ===========================================================================

  Future<void> _saveGarden() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt(
        _treeCountKey,
        _treeCount,
      );

      await prefs.setInt(
        _gardenStreakKey,
        _gardenStreak,
      );
    } catch (e) {
      debugPrint('Garden save error: $e');
    }
  }

  Future<void> growNextTree() async {
    await addStaticTree();
  }

  // ===========================================================================
  // ADD ONE TREE
  // ===========================================================================

  Future<void> addStaticTree() async {
    if (_isUpdating) {
      return;
    }

    if (_isLoading) {
      await _waitForGardenLoad();
    }

    if (!mounted || _isLoading) {
      return;
    }

    _isUpdating = true;

    try {
      setState(() {
        _treeCount++;
      });

      await _saveGarden();

      if (_treeCount >= totalSlots) {
        await Future.delayed(
          const Duration(milliseconds: 1000),
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _gardenStreak++;
        });

        await _saveGarden();

        await Future.delayed(
          const Duration(milliseconds: 600),
        );

        if (!mounted) {
          return;
        }

        setState(() {
          _treeCount = 0;
        });

        await _saveGarden();
      }
    } catch (e) {
      debugPrint('Garden update error: $e');
    } finally {
      _isUpdating = false;
    }
  }

  // ===========================================================================
  // WAIT FOR INITIAL LOAD
  // ===========================================================================

  Future<void> _waitForGardenLoad() async {
    int attempts = 0;

    while (_isLoading && attempts < 60) {
      await Future.delayed(
        const Duration(milliseconds: 50),
      );

      attempts++;
    }
  }

  // ===========================================================================
  // PUBLIC RESET
  // ===========================================================================

  Future<void> resetGarden() async {
    if (!mounted) {
      return;
    }

    setState(() {
      _treeCount = 0;
    });

    await _saveGarden();
  }

  // ===========================================================================
  // GETTERS
  // ===========================================================================

  int get treeCount => _treeCount;

  int get gardenStreak => _gardenStreak;

  int get remainingTrees => totalSlots - _treeCount;

  // ===========================================================================
  // BUILD
  // ===========================================================================

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return _buildLoadingGarden();
    }

    // Outer Margin for Side Padding
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
          child: _buildGardenContent(),
        ),
      ),
    );
  }

  // ===========================================================================
  // LOADING
  // ===========================================================================

  Widget _buildLoadingGarden() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          height: 300,
          color: const Color(0xFFE8F0E3),
          child: const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF1D7654),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // CONTENT
  // ===========================================================================

  Widget _buildGardenContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),
          _buildTreeGrid(),
          const SizedBox(height: 4),
        ],
      ),
    );
  }

  // ===========================================================================
  // HEADER
  // ===========================================================================

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Growth Garden 🌱',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Every completed task grows your garden.',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 3,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        _buildStreakBadge(),
      ],
    );
  }

  // ===========================================================================
  // STREAK
  // ===========================================================================

  Widget _buildStreakBadge() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          '🔥',
          style: TextStyle(fontSize: 20),
        ),
        Text(
          '$_gardenStreak',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w900,
            shadows: [
              Shadow(
                color: Colors.black45,
                blurRadius: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ===========================================================================
  // 12 TREE GRID
  // ===========================================================================

  Widget _buildTreeGrid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: totalSlots,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          crossAxisSpacing: 2,
          mainAxisSpacing: 4,
          childAspectRatio: 1.0,
        ),
        itemBuilder: (context, index) {
          final hasTree = index < _treeCount;
          return _buildTreeSlot(hasTree: hasTree);
        },
      ),
    );
  }

  // ===========================================================================
  // TREE SLOT
  // ===========================================================================

  Widget _buildTreeSlot({required bool hasTree}) {
    return ClipRect(
      child: hasTree ? _buildStaticTree() : _buildEmptySlot(),
    );
  }

  // ===========================================================================
  // TREE LOTTIE
  // ===========================================================================

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
              child: Text(
                '🌳',
                style: TextStyle(fontSize: 42),
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // EMPTY SLOT
  // ===========================================================================

  Widget _buildEmptySlot() {
    return const Center(
      child: Text(
        '+',
        style: TextStyle(
          color: Colors.transparent,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}