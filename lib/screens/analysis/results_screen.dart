import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';
import '../recommendations/dress_colors_screen.dart';
import '../recommendations/glasses_frames_screen.dart';
import '../recommendations/hairstyles_screen.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<UserProfile>(context);

    final String faceShapeName = profile.faceShape != FaceShape.none
        ? profile.faceShape.name[0].toUpperCase() + profile.faceShape.name.substring(1)
        : 'Oval';

    final String undertoneName = profile.undertone != Undertone.none
        ? profile.undertone.name[0].toUpperCase() + profile.undertone.name.substring(1)
        : 'Cool';

    final bool hasImage = profile.imagePath != null &&
        profile.imagePath!.isNotEmpty &&
        File(profile.imagePath!).existsSync();

    return Scaffold(
      body: Stack(
        children: [
          // Background abstract shapes
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: -80,
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),
                  Text(
                    'Your Face Analysis',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontSize: 28,
                          letterSpacing: -0.5,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Personalized insights based on your unique features',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textDark.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Display Captured Face Photo OR Simple Face Illustration
                  Center(
                    child: Container(
                      width: 140,
                      height: 140,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.secondary.withOpacity(0.4),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.secondary.withOpacity(0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: hasImage
                            ? Image.file(
                                File(profile.imagePath!),
                                fit: BoxFit.cover,
                                width: 140,
                                height: 140,
                              )
                            : Container(
                                color: AppColors.primary.withOpacity(0.15),
                                child: const Icon(
                                  Icons.face_6,
                                  size: 76,
                                  color: AppColors.secondary,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Face Analysis Result Cards (Face Shape & Undertone)
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultCard(
                          context,
                          title: 'Face Shape',
                          value: faceShapeName,
                          icon: Icons.face_retouching_natural,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildResultCard(
                          context,
                          title: 'Undertone',
                          value: undertoneName,
                          icon: Icons.lens_blur,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 40),

                  // Made For You Section
                  Text(
                    'Made for You',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          fontSize: 22,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Curated styling recommendations designed for your face',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textDark.withOpacity(0.6),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Recommendation Cards (Dress Colors, Glasses Frames, Hairstyles)
                  _buildRecommendationCard(
                    context,
                    title: 'Dress Colors',
                    subtitle: 'Complements your $undertoneName undertone',
                    icon: Icons.palette_outlined,
                    badgeColor: Colors.purple.shade50,
                    iconColor: Colors.purple.shade700,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const DressColorsScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildRecommendationCard(
                    context,
                    title: 'Glasses Frames',
                    subtitle: 'Flattering shapes for your $faceShapeName face shape',
                    icon: Icons.visibility_outlined,
                    badgeColor: Colors.blue.shade50,
                    iconColor: Colors.blue.shade700,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const GlassesFramesScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildRecommendationCard(
                    context,
                    title: 'Hairstyles',
                    subtitle: 'Balances and enhances your $faceShapeName shape',
                    icon: Icons.face_retouching_natural_sharp,
                    badgeColor: Colors.amber.shade50,
                    iconColor: Colors.amber.shade800,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const HairstylesScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 30, color: AppColors.secondary),
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              color: AppColors.textDark.withOpacity(0.6),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 18,
              color: AppColors.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color badgeColor,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textDark.withOpacity(0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
