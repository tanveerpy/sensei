import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class HairstylesScreen extends StatelessWidget {
  const HairstylesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hairstyles')),
      body: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          const Text(
            'Recommended Styles',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'These hairstyles balance your facial proportions and highlight your best features.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          _buildHairCard('Long Layers', 'Adds volume and movement, perfect for softening angles.', Icons.face_3),
          const SizedBox(height: 16),
          _buildHairCard('Curtain Bangs', 'Frames the face beautifully and highlights the cheekbones.', Icons.face_4),
          const SizedBox(height: 16),
          _buildHairCard('Textured Bob', 'A chic, modern cut that creates the illusion of a stronger jawline.', Icons.face_6),
        ],
      ),
    );
  }

  Widget _buildHairCard(String title, String description, IconData icon) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.secondary, size: 40),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(description, style: const TextStyle(color: Colors.grey, fontSize: 13, height: 1.4)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
