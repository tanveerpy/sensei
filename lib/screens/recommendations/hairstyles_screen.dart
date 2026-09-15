import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';

class HairstyleRecommendation {
  final String name;
  final String description;
  final IconData icon;

  const HairstyleRecommendation({
    required this.name,
    required this.description,
    required this.icon,
  });
}

class HairstylesScreen extends StatelessWidget {
  const HairstylesScreen({super.key});

  List<HairstyleRecommendation> _getHairstylesForFaceShape(FaceShape shape) {
    switch (shape) {
      case FaceShape.round:
        return const [
          HairstyleRecommendation(
            name: 'Long Layers',
            description: 'Elongates the neck and face structure while creating graceful vertical lines.',
            icon: Icons.face_3,
          ),
          HairstyleRecommendation(
            name: 'Side-Swept Bangs',
            description: 'Breaks up round symmetry by creating a chic diagonal angle across the forehead.',
            icon: Icons.face_4,
          ),
          HairstyleRecommendation(
            name: 'Textured Shag',
            description: 'Adds crown volume and movement to lengthen facial proportions naturally.',
            icon: Icons.face_6,
          ),
        ];
      case FaceShape.square:
        return const [
          HairstyleRecommendation(
            name: 'Curtain Bangs',
            description: 'Softly frames the forehead and cheekbones, easing sharp jaw angles.',
            icon: Icons.face_4,
          ),
          HairstyleRecommendation(
            name: 'Soft Waves Bob',
            description: 'Shoulder-length loose waves round out sharp edges for an effortless aesthetic.',
            icon: Icons.face_3,
          ),
          HairstyleRecommendation(
            name: 'Deep Side Part',
            description: 'Shifts symmetry away from strong square jawlines for a romantic balance.',
            icon: Icons.face_2,
          ),
        ];
      case FaceShape.heart:
        return const [
          HairstyleRecommendation(
            name: 'Chin-Length Bob',
            description: 'Fills out space around the jaw and chin, creating a rounded lower silhouette.',
            icon: Icons.face_6,
          ),
          HairstyleRecommendation(
            name: 'Long Waves with Layers',
            description: 'Cascading layers soften high cheekbones and balance a pointed chin.',
            icon: Icons.face_3,
          ),
          HairstyleRecommendation(
            name: 'Wispy Curtain Bangs',
            description: 'Draws focus to eye level while narrowing top forehead width.',
            icon: Icons.face_4,
          ),
        ];
      case FaceShape.diamond:
        return const [
          HairstyleRecommendation(
            name: 'Chin-Length Textured Cut',
            description: 'Adds fullness at the jawline to balance wide, striking cheekbones.',
            icon: Icons.face_6,
          ),
          HairstyleRecommendation(
            name: 'Full Curtain Bangs',
            description: 'Expands the appearance of a narrow forehead while showcasing cheeks.',
            icon: Icons.face_4,
          ),
          HairstyleRecommendation(
            name: 'Side-Parted Shoulder Lob',
            description: 'Framing layers soften sharp diamond angles smoothly.',
            icon: Icons.face_3,
          ),
        ];
      case FaceShape.oval:
      default:
        return const [
          HairstyleRecommendation(
            name: 'Curtain Bangs & Long Layers',
            description: 'Complements ideal oval symmetry by framing eyes and cheeks perfectly.',
            icon: Icons.face_4,
          ),
          HairstyleRecommendation(
            name: 'Blunt Textured Bob',
            description: 'Highlights chin and neck contours while maintaining classic chic elegance.',
            icon: Icons.face_6,
          ),
          HairstyleRecommendation(
            name: 'Voluminous Side Part',
            description: 'Adds dynamic flair and body without hiding naturally balanced proportions.',
            icon: Icons.face_3,
          ),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<UserProfile>(context);
    final faceShape = profile.faceShape != FaceShape.none ? profile.faceShape : FaceShape.oval;
    final faceShapeLabel = faceShape.name[0].toUpperCase() + faceShape.name.substring(1);
    final hairstyles = _getHairstylesForFaceShape(faceShape);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hairstyles'),
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
                  child: const Icon(Icons.face_retouching_natural, color: AppColors.secondary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$faceShapeLabel Hairstyles',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Hairstyles curated to flatter and balance your $faceShapeLabel shape.',
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
            'Recommended Hairstyles',
            style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
          ),
          const SizedBox(height: 16),

          ...hairstyles.map((style) => Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildHairstyleCard(style),
              )),
        ],
      ),
    );
  }

  Widget _buildHairstyleCard(HairstyleRecommendation style) {
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
              child: Icon(style.icon, color: AppColors.secondary, size: 38),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    style.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    style.description,
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
