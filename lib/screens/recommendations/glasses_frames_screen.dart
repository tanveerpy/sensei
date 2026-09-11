import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class GlassesFramesScreen extends StatelessWidget {
  const GlassesFramesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Glasses Frames')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Recommended Frames',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'These frame shapes contrast with your face shape to create a balanced, harmonious look.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildFrameCard('Cat-eye', 'Adds width to the top of your face and lifts your features.', Icons.visibility_outlined),
          const SizedBox(height: 16),
          _buildFrameCard('Rectangle', 'Provides sharp angles to soften rounded facial features.', Icons.rectangle_outlined),
          const SizedBox(height: 16),
          _buildFrameCard('Wayfarer', 'A classic shape that provides balance and structure.', Icons.remove_red_eye_outlined),
        ],
      ),
    );
  }

  Widget _buildFrameCard(String title, String description, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColors.secondary, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: Colors.grey, fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
