import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class DressColorsScreen extends StatelessWidget {
  const DressColorsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dress Colors')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Your Palette',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Based on your undertone, these colors will naturally complement your skin and make you glow.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.85,
              children: [
                _buildColorSwatch(const Color(0xFF000080), 'Navy Blue'),
                _buildColorSwatch(const Color(0xFF50C878), 'Emerald Green'),
                _buildColorSwatch(const Color(0xFF800020), 'Burgundy'),
                _buildColorSwatch(const Color(0xFF36454F), 'Charcoal'),
                _buildColorSwatch(const Color(0xFFE6E6FA), 'Soft Lavender'),
                _buildColorSwatch(const Color(0xFFF5F5DC), 'Warm Beige'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorSwatch(Color color, String name) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
