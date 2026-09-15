import 'package:flutter/material.dart';
import '../analysis/ai_analysis_screen.dart';
import '../analysis/manual_analysis_screen.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Soft abstract background circles & line-art accents
            Positioned(
              top: -60,
              right: -60,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.18),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              bottom: 120,
              left: -70,
              child: Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withOpacity(0.06),
                  shape: BoxShape.circle,
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  // Brand Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Facecard',
                            style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                  fontSize: 34,
                                  letterSpacing: -1,
                                  fontWeight: FontWeight.w900,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Find what suits you.',
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: AppColors.secondary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.sparkles,
                          color: AppColors.secondary,
                          size: 26,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Short explanation paragraph
                  Text(
                    'Analyze your face shape and undertone to discover what suits you best.',
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.textDark.withOpacity(0.7),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Minimal Face Illustration Hero Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.secondary.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.face_6_outlined,
                            size: 76,
                            color: AppColors.secondary,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Personalized AI Analysis',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tailored dress colors, glasses frames & hairstyles',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textDark.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 3 Feature Indicators/Cards
                  Row(
                    children: [
                      Expanded(child: _buildFeatureCard(Icons.face_retouching_natural, 'Face Shape')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildFeatureCard(Icons.palette_outlined, 'Undertone')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildFeatureCard(Icons.auto_awesome, 'Personal Style')),
                    ],
                  ),

                  const Spacer(),

                  // Main & Prominent Call To Action (Analyze My Face)
                  ElevatedButton.icon(
                    icon: const Icon(Icons.camera_alt, size: 22),
                    label: const Text('Analyze My Face'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 22),
                      textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      elevation: 4,
                      shadowColor: AppColors.secondary.withOpacity(0.2),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AiAnalysisScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 14),

                  // Secondary Call To Action (Manual Analysis)
                  OutlinedButton.icon(
                    icon: const Icon(Icons.tune, size: 18),
                    label: const Text('Manual Analysis'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: BorderSide(color: AppColors.primary.withOpacity(0.8), width: 1.5),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const ManualAnalysisScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: AppColors.secondary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.secondary, size: 26),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
