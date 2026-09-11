import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../recommendations/dress_colors_screen.dart';
import '../recommendations/glasses_frames_screen.dart';
import '../recommendations/hairstyles_screen.dart';
import '../../core/theme/app_colors.dart';

class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<UserProfile>(context);

    final faceShape = profile.faceShape != FaceShape.none
        ? profile.faceShape.name
        : 'Oval';
    final undertone = profile.undertone != Undertone.none
        ? profile.undertone.name
        : 'Cool';

    return Scaffold(
      body: Stack(
        children: [
          // Subtle background decoration
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.05),
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
                  Text(
                    'Your Face Analysis',
                    style: Theme.of(context)
                        .textTheme
                        .displayLarge
                        ?.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 24),

                  // Simple Face Illustration
                  Center(
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 2,
                        ),
                      ),
                      child: const Icon(
                        Icons.face_6,
                        size: 64,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Face Analysis Results Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildResultCard(
                          context,
                          'Face Shape',
                          faceShape.toUpperCase(),
                          Icons.face,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildResultCard(
                          context,
                          'Undertone',
                          undertone.toUpperCase(),
                          Icons.lens_blur,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 48),

                  Text(
                    'Made for you',
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: 16),

                  // Recommendation Cards
                  _buildRecommendationCard(
                    context,
                    title: 'Dress Colors',
                    subtitle: 'Based on your $undertone undertone',
                    icon: Icons.palette_outlined,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const DressColorsScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendationCard(
                    context,
                    title: 'Glasses Frames',
                    subtitle: 'Based on your $faceShape face shape',
                    icon: Icons.visibility_outlined,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const GlassesFramesScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildRecommendationCard(
                    context,
                    title: 'Hairstyles',
                    subtitle: 'Based on your $faceShape face shape',
                    icon: Icons.face_retouching_natural,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const HairstylesScreen(),
                      ),
                    ),
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
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      color: AppColors.primary.withOpacity(0.1),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
        child: Column(
          children: [
            Icon(icon, size: 40, color: AppColors.secondary),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: AppColors.secondary, size: 28),
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
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
