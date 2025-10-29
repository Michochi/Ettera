// Browse/matching screen with swipe functionality
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../models/profile_model.dart';
import '../services/matching_service.dart';
import '../services/notification_service.dart';
import '../providers/user_provider.dart';
import '../widgets/profile_card.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import '../widgets/app_theme.dart';
import '../utils/error_handler.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final MatchingService _matchingService = MatchingService();
  List<ProfileModel> _profiles = [];
  List<ProfileModel> _filteredProfiles = [];
  bool _isLoading = true;
  String? _error;
  Offset _dragPosition = Offset.zero;
  double _dragRotation = 0;
  bool _isDragging = false;

  // Filter states
  String? _selectedGender;
  RangeValues _ageRange = const RangeValues(18, 60);
  bool _filtersApplied = false;

  @override
  void initState() {
    super.initState();
    _loadProfiles();
  }

  Future<void> _loadProfiles() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userProvider = context.read<UserProvider>();

      // Wait for provider to be initialized
      if (!userProvider.isInitialized) {
        await Future.delayed(const Duration(milliseconds: 100));
        if (!mounted) return;
        return _loadProfiles();
      }

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

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> profilesJson = response.data['profiles'];
        setState(() {
          _profiles = profilesJson
              .map((json) => ProfileModel.fromJson(json))
              .toList();
          _applyFilters();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load profiles';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
        ErrorHandler.logError(e, context: 'Browse - Load Profiles');
        setState(() {
          _error = 'Unable to load profiles';
          _isLoading = false;
        });
      }
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredProfiles = _profiles.where((profile) {
        // Filter by gender
        if (_selectedGender != null && profile.gender != null) {
          if (profile.gender!.toLowerCase() != _selectedGender!.toLowerCase()) {
            return false;
          }
        }
        // Filter by age
        if (profile.age < _ageRange.start || profile.age > _ageRange.end) {
          return false;
        }
        return true;
      }).toList();

      _filtersApplied =
          _selectedGender != null || _ageRange != const RangeValues(18, 60);
    });
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String? tempGender = _selectedGender;
        RangeValues tempAgeRange = _ageRange;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.filter_list, color: AppTheme.primaryGold),
                        const SizedBox(width: 12),
                        Text(
                          'Filter Profiles',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.darkGray,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Gender Filter
                    Text(
                      'Gender',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      children: [
                        FilterChip(
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.people, size: 18),
                              SizedBox(width: 6),
                              Text('All'),
                            ],
                          ),
                          selected: tempGender == null,
                          onSelected: (selected) {
                            setDialogState(() {
                              tempGender = null;
                            });
                          },
                          selectedColor: AppTheme.primaryGold.withOpacity(0.3),
                          checkmarkColor: AppTheme.primaryGold,
                        ),
                        FilterChip(
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.male, size: 18),
                              SizedBox(width: 6),
                              Text('Male'),
                            ],
                          ),
                          selected: tempGender?.toLowerCase() == 'male',
                          onSelected: (selected) {
                            setDialogState(() {
                              tempGender = selected ? 'Male' : null;
                            });
                          },
                          selectedColor: AppTheme.primaryGold.withOpacity(0.3),
                          checkmarkColor: AppTheme.primaryGold,
                        ),
                        FilterChip(
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.female, size: 18),
                              SizedBox(width: 6),
                              Text('Female'),
                            ],
                          ),
                          selected: tempGender?.toLowerCase() == 'female',
                          onSelected: (selected) {
                            setDialogState(() {
                              tempGender = selected ? 'Female' : null;
                            });
                          },
                          selectedColor: AppTheme.primaryGold.withOpacity(0.3),
                          checkmarkColor: AppTheme.primaryGold,
                        ),
                        FilterChip(
                          label: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.transgender, size: 18),
                              SizedBox(width: 6),
                              Text('Other'),
                            ],
                          ),
                          selected: tempGender?.toLowerCase() == 'other',
                          onSelected: (selected) {
                            setDialogState(() {
                              tempGender = selected ? 'Other' : null;
                            });
                          },
                          selectedColor: AppTheme.primaryGold.withOpacity(0.3),
                          checkmarkColor: AppTheme.primaryGold,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Age Filter
                    Text(
                      'Age Range: ${tempAgeRange.start.round()} - ${tempAgeRange.end.round()}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.darkGray,
                      ),
                    ),
                    const SizedBox(height: 12),
                    RangeSlider(
                      values: tempAgeRange,
                      min: 18,
                      max: 100,
                      divisions: 82,
                      activeColor: AppTheme.primaryGold,
                      inactiveColor: AppTheme.primaryGold.withOpacity(0.2),
                      labels: RangeLabels(
                        tempAgeRange.start.round().toString(),
                        tempAgeRange.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setDialogState(() {
                          tempAgeRange = values;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey[400]!),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Cancel'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _selectedGender = tempGender;
                                _ageRange = tempAgeRange;
                                _applyFilters();
                              });
                              Navigator.pop(context);
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              backgroundColor: AppTheme.primaryGold,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text('Apply'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
    if (_filteredProfiles.isEmpty) return;

    // Show dragging indicator
    setState(() {
      _isDragging = true;
      _dragPosition = const Offset(400, 0);
      _dragRotation = 0.3;
    });

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 300));

    final profile = _filteredProfiles.first;
    final userProvider = context.read<UserProvider>();
    final token = userProvider.token;

    if (token == null) return;

    try {
      final response = await _matchingService.likeProfile(
        token: token,
        profileId: profile.id,
      );

      print('Like response: ${response.data}'); // Debug log

      if (response.statusCode == 200 && response.data['isMatch'] == true) {
        print('Match detected! Showing dialog...'); // Debug log

        // Show browser notification for match
        NotificationService().showMatchNotification(
          userName: profile.name,
          userPhoto: profile.photoUrl,
        );

        // Remove the profile first
        setState(() {
          _filteredProfiles.removeAt(0);
          _dragPosition = Offset.zero;
          _dragRotation = 0;
          _isDragging = false;
        });

        // Wait for UI to update, then show match dialog
        await Future.delayed(const Duration(milliseconds: 300));
        if (mounted) {
          _showMatchDialog(profile);
        }
      } else {
        // Just remove the profile if no match
        setState(() {
          _filteredProfiles.removeAt(0);
          _dragPosition = Offset.zero;
          _dragRotation = 0;
          _isDragging = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ErrorHandler.showErrorSnackBar(context, e);
        ErrorHandler.logError(e, context: 'Browse - Like Profile');
      }
      setState(() {
        _dragPosition = Offset.zero;
        _dragRotation = 0;
        _isDragging = false;
      });
    }
  }

  Future<void> _handlePass() async {
    if (_filteredProfiles.isEmpty) return;

    // Show dragging indicator
    setState(() {
      _isDragging = true;
      _dragPosition = const Offset(-400, 0);
      _dragRotation = -0.3;
    });

    // Wait for animation to complete
    await Future.delayed(const Duration(milliseconds: 300));

    final profile = _filteredProfiles.first;
    final userProvider = context.read<UserProvider>();
    final token = userProvider.token;

    if (token == null) return;

    try {
      await _matchingService.passProfile(token: token, profileId: profile.id);

      // Remove the profile from the list
      setState(() {
        _filteredProfiles.removeAt(0);
        _dragPosition = Offset.zero;
        _dragRotation = 0;
        _isDragging = false;
      });
    } catch (e) {
      if (mounted) {
        ErrorHandler.logError(e, context: 'Browse - Pass Profile');
      }
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
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, AppTheme.primaryGold.withOpacity(0.05)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated heart icon
              TweenAnimationBuilder(
                duration: const Duration(milliseconds: 600),
                tween: Tween<double>(begin: 0, end: 1),
                builder: (context, double value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Icon(
                      Icons.favorite,
                      color: AppTheme.primaryGold,
                      size: 80,
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
              // Match title
              Text(
                "It's a Match!",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.darkGray,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),
              // Message
              Text(
                'You and ${profile.name} liked each other!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  color: AppTheme.darkGray.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: AppTheme.primaryGold, width: 2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Keep Browsing',
                        style: TextStyle(
                          color: AppTheme.primaryGold,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        Navigator.pushNamed(context, '/matches');
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: AppTheme.primaryGold,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Send Message',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.backgroundColor,
              AppTheme.primaryGold.withOpacity(0.05),
              AppTheme.backgroundColor,
            ],
          ),
        ),
        child: Column(
          children: [
            const CustomAppBar(),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            color: AppTheme.primaryGold,
                            strokeWidth: 3,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Finding your perfect match...',
                            style: TextStyle(
                              color: AppTheme.darkGray.withOpacity(0.7),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _error != null
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.darkGray.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppTheme.primaryGold,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _error!,
                              style: TextStyle(
                                color: AppTheme.darkGray,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: _loadProfiles,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Try Again'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGold,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _filteredProfiles.isEmpty
                  ? Center(
                      child: Container(
                        margin: const EdgeInsets.all(32),
                        padding: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.darkGray.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGold.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.people_outline,
                                size: 64,
                                color: AppTheme.primaryGold,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              _filtersApplied
                                  ? 'No matching profiles'
                                  : 'No more profiles',
                              style: TextStyle(
                                color: AppTheme.darkGray,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _filtersApplied
                                  ? 'Try adjusting your filters to see more profiles'
                                  : 'Check back later for new matches',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppTheme.darkGray.withOpacity(0.6),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 32),
                            // Filter Button
                            ElevatedButton.icon(
                              onPressed: _showFilterDialog,
                              icon: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Icon(
                                    Icons.filter_list,
                                    color: _filtersApplied
                                        ? Colors.white
                                        : AppTheme.primaryGold,
                                  ),
                                  if (_filtersApplied)
                                    Positioned(
                                      right: -4,
                                      top: -4,
                                      child: Container(
                                        width: 10,
                                        height: 10,
                                        decoration: BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              label: Text(
                                _filtersApplied
                                    ? 'Change Filters'
                                    : 'Filter Profiles',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: _filtersApplied
                                      ? Colors.white
                                      : AppTheme.primaryGold,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _filtersApplied
                                    ? AppTheme.primaryGold
                                    : Colors.white,
                                foregroundColor: _filtersApplied
                                    ? Colors.white
                                    : AppTheme.primaryGold,
                                elevation: 4,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 14,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                  side: BorderSide(
                                    color: AppTheme.primaryGold,
                                    width: 2,
                                  ),
                                ),
                                shadowColor: AppTheme.primaryGold.withOpacity(
                                  0.3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Refresh Button
                            ElevatedButton.icon(
                              onPressed: _loadProfiles,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Refresh'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGold,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : _buildProfileStack(),
            ),
          ],
        ),
      ),
      drawer: const CustomDrawer(),
    );
  }

  Widget _buildProfileStack() {
    return SingleChildScrollView(
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
              const SizedBox(height: 20),
              // Filter Button at the top
              Container(
                margin: const EdgeInsets.only(bottom: 20),
                child: ElevatedButton.icon(
                  onPressed: _showFilterDialog,
                  icon: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Icon(
                        Icons.filter_list,
                        color: _filtersApplied
                            ? Colors.white
                            : AppTheme.primaryGold,
                      ),
                      // Filter indicator badge
                      if (_filtersApplied)
                        Positioned(
                          right: -4,
                          top: -4,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                    ],
                  ),
                  label: Text(
                    _filtersApplied ? 'Filters Active' : 'Filter Profiles',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _filtersApplied
                          ? Colors.white
                          : AppTheme.primaryGold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _filtersApplied
                        ? AppTheme.primaryGold
                        : Colors.white,
                    foregroundColor: _filtersApplied
                        ? Colors.white
                        : AppTheme.primaryGold,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: AppTheme.primaryGold, width: 2),
                    ),
                    shadowColor: AppTheme.primaryGold.withOpacity(0.3),
                  ),
                ),
              ),
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
                                ? math.min((-_dragPosition.dx - 50) / 50, 1.0)
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
                                ? math.min((_dragPosition.dx - 50) / 50, 1.0)
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
                        profile: _filteredProfiles.first,
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
                    child: Icon(Icons.close, color: Colors.red, size: 36),
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
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
