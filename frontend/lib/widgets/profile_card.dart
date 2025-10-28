// Draggable profile card widget for the matching/browsing screen
import 'package:flutter/material.dart';
import '../models/profile_model.dart';
import '../widgets/app_theme.dart';

class ProfileCard extends StatelessWidget {
  final ProfileModel profile;
  final Offset position;
  final double rotation;

  const ProfileCard({
    super.key,
    required this.profile,
    this.position = Offset.zero,
    this.rotation = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: position,
      child: Transform.rotate(
        angle: rotation,
        child: Container(
          width: 360,
          height: 520,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGold.withOpacity(0.2),
                blurRadius: 30,
                offset: const Offset(0, 15),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Stack(
              children: [
                // Background image or gradient
                Container(
                  decoration: BoxDecoration(
                    image:
                        profile.photoUrl != null && profile.photoUrl!.isNotEmpty
                        ? DecorationImage(
                            image: NetworkImage(profile.photoUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    gradient:
                        profile.photoUrl == null || profile.photoUrl!.isEmpty
                        ? LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppTheme.primaryGold.withOpacity(0.4),
                              AppTheme.primaryGold.withOpacity(0.7),
                            ],
                          )
                        : null,
                  ),
                ),
                // Default avatar icon if no photo
                if (profile.photoUrl == null || profile.photoUrl!.isEmpty)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 120,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ),
                // Enhanced gradient overlay
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.85),
                      ],
                      stops: const [0.4, 0.7, 1.0],
                    ),
                  ),
                ),
                // Profile info with enhanced styling
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Age with shadow
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${profile.name}, ${profile.age}',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: -0.5,
                                shadows: [
                                  Shadow(
                                    color: Colors.black26,
                                    offset: Offset(0, 2),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Location with icon
                      if (profile.location != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  profile.location!,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      const SizedBox(height: 12),
                      // Bio with better styling
                      if (profile.bio != null && profile.bio!.isNotEmpty)
                        Text(
                          profile.bio!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.white.withOpacity(0.95),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 14),
                      // Interests with enhanced design
                      if (profile.interests.isNotEmpty)
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: profile.interests.take(3).map((interest) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    AppTheme.primaryGold,
                                    AppTheme.primaryGold.withOpacity(0.8),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(20),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppTheme.primaryGold.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                interest,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
