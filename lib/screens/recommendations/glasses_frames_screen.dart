import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';

class FrameRecommendation {
  final String name;
  final String whyItWorks;
  final IconData icon;

  const FrameRecommendation({
    required this.name,
    required this.whyItWorks,
    required this.icon,
  });
}

class GlassesFramesScreen extends StatelessWidget {
  const GlassesFramesScreen({super.key});

  List<FrameRecommendation> _getFramesForFaceShape(FaceShape shape) {
    switch (shape) {
      case FaceShape.round:
        return const [
          FrameRecommendation(
            name: 'Rectangular Frames',
            whyItWorks: 'Adds sharp angles and contrast to break up facial roundness, making your face appear longer.',
            icon: Icons.rectangle_outlined,
          ),
          FrameRecommendation(
            name: 'Cat-eye Frames',
            whyItWorks: 'Lifts facial features upward and draws attention to your eyes for a flattering silhouette.',
            icon: Icons.visibility_outlined,
          ),
          FrameRecommendation(
            name: 'Wayfarer Frames',
            whyItWorks: 'Classic angular upper corners provide balance to soft, rounded cheek contours.',
            icon: Icons.crop_square_outlined,
          ),
        ];
      case FaceShape.square:
        return const [
          FrameRecommendation(
            name: 'Round Frames',
            whyItWorks: 'Softens a prominent, angular jawline and creates a harmonious facial balance.',
            icon: Icons.circle_outlined,
          ),
          FrameRecommendation(
            name: 'Oval Frames',
            whyItWorks: 'Complements strong square angles with gentle curves that broaden eye area.',
            icon: Icons.lens_outlined,
          ),
          FrameRecommendation(
            name: 'Browline Frames',
            whyItWorks: 'Draws focus to the top of your forehead and away from a broad jawline.',
            icon: Icons.horizontal_rule_rounded,
          ),
        ];
      case FaceShape.heart:
        return const [
          FrameRecommendation(
            name: 'Bottom-Heavy Frames',
            whyItWorks: 'Adds width to the lower half of your face, balancing a wider forehead.',
            icon: Icons.border_bottom_rounded,
          ),
          FrameRecommendation(
            name: 'Oval & Light Frames',
            whyItWorks: 'Softens high cheekbones and pointed chin without overpowering delicate features.',
            icon: Icons.lens_outlined,
          ),
          FrameRecommendation(
            name: 'Cat-eye Frames',
            whyItWorks: 'Accentuates cheekbones while maintaining an elegant upward sweep.',
            icon: Icons.visibility_outlined,
          ),
        ];
      case FaceShape.diamond:
        return const [
          FrameRecommendation(
            name: 'Cat-eye Frames',
            whyItWorks: 'Highlights high diamond cheekbones while softening narrow forehead and chin lines.',
            icon: Icons.visibility_outlined,
          ),
          FrameRecommendation(
            name: 'Oval Frames',
            whyItWorks: 'Subtly softens angular cheeks and adds gentle balance across the face.',
            icon: Icons.lens_outlined,
          ),
          FrameRecommendation(
            name: 'Browline Frames',
            whyItWorks: 'Frames your eyes and widens the appearance of a narrow forehead.',
            icon: Icons.horizontal_rule_rounded,
          ),
        ];
      case FaceShape.oval:
      default:
        return const [
          FrameRecommendation(
            name: 'Cat-eye Frames',
            whyItWorks: 'Enhances your naturally balanced oval proportions with stylish upward angles.',
            icon: Icons.visibility_outlined,
          ),
          FrameRecommendation(
            name: 'Rectangular Frames',
            whyItWorks: 'Adds geometric structure without interfering with balanced facial symmetry.',
            icon: Icons.rectangle_outlined,
          ),
          FrameRecommendation(
            name: 'Round Frames',
            whyItWorks: 'Highlights subtle curves and complements smooth facial contours effortlessly.',
            icon: Icons.circle_outlined,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<UserProfile>(context);
    final faceShape = profile.faceShape != FaceShape.none ? profile.faceShape : FaceShape.oval;
    final faceShapeLabel = faceShape.name[0].toUpperCase() + faceShape.name.substring(1);
    final frames = _getFramesForFaceShape(faceShape);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Glasses Frames'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.glasses, color: AppColors.secondary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$faceShapeLabel Frame Selection',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Frame shapes specifically paired with your $faceShapeLabel face shape.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textDark.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'Recommended Glasses Frames',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),

          ...frames.map((frame) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildFrameCard(frame),
              )),
        ],
      ),
    );
  }

  Widget _buildFrameCard(FrameRecommendation frame) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(frame.icon, color: AppColors.secondary, size: 36),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    frame.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    frame.whyItWorks,
                    style: TextStyle(
                      color: AppColors.textDark.withOpacity(0.7),
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
