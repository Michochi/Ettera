// Browse/matching screen with swipe functionality
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/profile_model.dart';
import '../services/matching_service.dart';
import '../providers/user_provider.dart';
import '../widgets/profile_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/app_theme.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final MatchingService _matchingService = MatchingService();
  List<ProfileModel> _profiles = [];
  bool _isLoading = true;
  String? _error;
  Offset _dragPosition = Offset.zero;
  double _dragRotation = 0;
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userProvider = context.read<UserProvider>();
      final token = userProvider.token;

      if (token == null) {
        setState(() {
          _error = 'Please log in to browse profiles';
          _isLoading = false;
        });
        return;
      }

      final response = await _matchingService.getProfiles(
        token: token,
        limit: 20,
      );

      if (response.statusCode == 200) {
        final List<dynamic> profilesJson = response.data['profiles'];
        setState(() {
          _profiles = profilesJson
              .map((json) => ProfileModel.fromJson(json))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load profiles';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  void _onPanStart(DragStartDetails details) {
    setState(() {
      _isDragging = true;
    });
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      _dragPosition += details.delta;
      // Calculate rotation based on horizontal drag
      _dragRotation = _dragPosition.dx / 1000;
    });
  }

  void _onPanEnd(DragEndDetails details) {
    const threshold = 100.0;

    if (_dragPosition.dx > threshold) {
      // Swiped right - Like
      _handleLike();
    } else if (_dragPosition.dx < -threshold) {
      // Swiped left - Pass
      _handlePass();
    } else {
      // Reset position if not far enough
      setState(() {
        _dragPosition = Offset.zero;
        _dragRotation = 0;
        _isDragging = false;
      });
    }
  }

  Future<void> _handleLike() async {
    if (_profiles.isEmpty) return;

    // Show dragging indicator
    setState(() {
      _isDragging = true;
      _dragPosition = const Offset(400, 0);
      _dragRotation = 0.3;
    });

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 300));

    final profile = _profiles.first;
    final userProvider = context.read<UserProvider>();
    final token = userProvider.token;

    if (token == null) return;

    try {
      final response = await _matchingService.likeProfile(
        token: token,
        profileId: profile.id,
      );

      if (response.statusCode == 200 && response.data['match'] == true) {
        // Show match dialog
        _showMatchDialog(profile);
      }

      // Remove the profile from the list
      setState(() {
        _profiles.removeAt(0);
        _dragPosition = Offset.zero;
        _dragRotation = 0;
        _isDragging = false;
      });
    } catch (e) {
      print('Error liking profile: $e');
      setState(() {
        _dragPosition = Offset.zero;
        _dragRotation = 0;
        _isDragging = false;
      });
    }
  }

  Future<void> _handlePass() async {
    if (_profiles.isEmpty) return;

    // Show dragging indicator
    setState(() {
      _isDragging = true;
      _dragPosition = const Offset(-400, 0);
      _dragRotation = -0.3;
    });

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 300));

    final profile = _profiles.first;
    final userProvider = context.read<UserProvider>();
    final token = userProvider.token;

    if (token == null) return;

    try {
      await _matchingService.passProfile(token: token, profileId: profile.id);

      // Remove the profile from the list
      setState(() {
        _profiles.removeAt(0);
        _dragPosition = Offset.zero;
        _dragRotation = 0;
        _isDragging = false;
      });
    } catch (e) {
      print('Error passing profile: $e');
      setState(() {
        _dragPosition = Offset.zero;
        _dragRotation = 0;
        _isDragging = false;
      });
    }
  }

  void _showMatchDialog(ProfileModel profile) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Column(
          children: [
            Icon(Icons.favorite, color: AppTheme.primaryGold, size: 64),
            const SizedBox(height: 16),
            const Text(
              "It's a Match!",
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Text(
          'You and ${profile.name} liked each other!',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Keep Browsing'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              // TODO: Navigate to matches screen
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryGold,
              foregroundColor: Colors.white,
            ),
            child: const Text('View Matches'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: const CustomAppBar(),
      drawer: const CustomDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _error!,
                    style: TextStyle(color: AppTheme.darkGray, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _loadProfiles,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            )
          : _profiles.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.people_outline,
                    size: 64,
                    color: AppTheme.darkGray.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No more profiles to show',
                    style: TextStyle(
                      color: AppTheme.darkGray,
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Check back later for new matches',
                    style: TextStyle(
                      color: AppTheme.darkGray.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadProfiles,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      MediaQuery.of(context).size.height -
                      kToolbarHeight -
                      MediaQuery.of(context).padding.top,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          // Action hints
                          if (_isDragging)
                            Positioned(
                              top: 50,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  // Pass indicator (left)
                                  Opacity(
                                    opacity: _dragPosition.dx < -50
                                        ? math.min(
                                            (-_dragPosition.dx - 50) / 50,
                                            1.0,
                                          )
                                        : 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 200),
                                  // Like indicator (right)
                                  Opacity(
                                    opacity: _dragPosition.dx > 50
                                        ? math.min(
                                            (_dragPosition.dx - 50) / 50,
                                            1.0,
                                          )
                                        : 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.favorite,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          // Profile cards
                          GestureDetector(
                            onPanStart: _onPanStart,
                            onPanUpdate: _onPanUpdate,
                            onPanEnd: _onPanEnd,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              transform: Matrix4.identity()
                                ..translate(_dragPosition.dx, _dragPosition.dy)
                                ..rotateZ(_dragRotation),
                              child: ProfileCard(
                                profile: _profiles.first,
                                position: Offset.zero,
                                rotation: 0,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Action buttons - below the card
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Pass button
                          FloatingActionButton.large(
                            heroTag: 'pass',
                            onPressed: _handlePass,
                            backgroundColor: Colors.white,
                            elevation: 4,
                            child: Icon(
                              Icons.close,
                              color: Colors.red,
                              size: 36,
                            ),
                          ),
                          const SizedBox(width: 60),
                          // Like button
                          FloatingActionButton.large(
                            heroTag: 'like',
                            onPressed: _handleLike,
                            backgroundColor: AppTheme.primaryGold,
                            elevation: 4,
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 36,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
