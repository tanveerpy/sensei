import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';

class ColorSwatchData {
  final String name;
  final Color color;
  final String hex;
  final String description;

  const ColorSwatchData({
    required this.name,
    required this.color,
    required this.hex,
    required this.description,
  });
}

class DressColorsScreen extends StatelessWidget {
  const DressColorsScreen({super.key});

  List<ColorSwatchData> _getColorsForUndertone(Undertone undertone) {
    switch (undertone) {
      case Undertone.warm:
        return const [
          ColorSwatchData(name: 'Warm Mustard', color: Color(0xFFE5A93C), hex: '#E5A93C', description: 'Rich golden hue that adds radiance to warm skin tones.'),
          ColorSwatchData(name: 'Terracotta', color: Color(0xFFC85A32), hex: '#C85A32', description: 'Earthy reddish-orange that complements golden undertones.'),
          ColorSwatchData(name: 'Olive Green', color: Color(0xFF556B2F), hex: '#556B2F', description: 'Deep natural green that brings out warm highlights.'),
          ColorSwatchData(name: 'Coral Pink', color: Color(0xFFF08080), hex: '#F08080', description: 'Vibrant peachy pink for a lively, fresh glow.'),
          ColorSwatchData(name: 'Warm Cream', color: Color(0xFFFFF8DC), hex: '#FFF8DC', description: 'Soft off-white that flatters golden undertones.'),
          ColorSwatchData(name: 'Burnt Amber', color: Color(0xFF8B4513), hex: '#8B4513', description: 'Deep brownish red ideal for sophisticated outfits.'),
        ];
      case Undertone.neutral:
        return const [
          ColorSwatchData(name: 'Dusty Rose', color: Color(0xFFDCAE96), hex: '#DCAE96', description: 'Subtle muted pink that balances cool and warm undertones.'),
          ColorSwatchData(name: 'Soft Jade', color: Color(0xFF779ECB), hex: '#779ECB', description: 'Harmonious blue-green hue perfect for any occasion.'),
          ColorSwatchData(name: 'Muted Mauve', color: Color(0xFF915C83), hex: '#915C83', description: 'Sophisticated purple-gray shade for neutral skin.'),
          ColorSwatchData(name: 'Creamy Ivory', color: Color(0xFFFFFFF0), hex: '#FFFFF0', description: 'Classic neutral white with a soft, elegant touch.'),
          ColorSwatchData(name: 'Warm Charcoal', color: Color(0xFF4A4A4A), hex: '#4A4A4A', description: 'Deep dark gray that offers soft contrast.'),
          ColorSwatchData(name: 'Sage Green', color: Color(0xFF8A9A86), hex: '#8A9A86', description: 'Calming earthy green that accentuates natural beauty.'),
        ];
      case Undertone.cool:
      default:
        return const [
          ColorSwatchData(name: 'Navy Blue', color: Color(0xFF1B2A4A), hex: '#1B2A4A', description: 'Classic deep blue that creates striking contrast with cool skin.'),
          ColorSwatchData(name: 'Emerald Green', color: Color(0xFF004B37), hex: '#004B37', description: 'Rich jewel tone that makes cool undertones pop.'),
          ColorSwatchData(name: 'Burgundy', color: Color(0xFF6B1D2F), hex: '#6B1D2F', description: 'Deep berry red that complements pinkish undertones.'),
          ColorSwatchData(name: 'Soft Lavender', color: Color(0xFFB5A7D6), hex: '#B5A7D6', description: 'Gentle pastel purple for a romantic and soft aesthetic.'),
          ColorSwatchData(name: 'Cool Charcoal', color: Color(0xFF333A42), hex: '#333A42', description: 'Crisp slate gray that enhances cool skin hues.'),
          ColorSwatchData(name: 'Icy Mint', color: Color(0xFFA8E6CF), hex: '#A8E6CF', description: 'Refreshing pastel green that illuminates cool complexions.'),
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = Provider.of<UserProfile>(context);
    final undertone = profile.undertone != Undertone.none ? profile.undertone : Undertone.cool;
    final undertoneLabel = undertone.name[0].toUpperCase() + undertone.name.substring(1);
    final swatches = _getColorsForUndertone(undertone);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dress Colors'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Info
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
                    child: const Icon(Icons.palette, color: AppColors.secondary, size: 28),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$undertoneLabel Palette',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Colors selected to highlight your natural $undertoneLabel undertone.',
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
              'Recommended Swatches',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 16),

            // Color Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: swatches.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final swatch = swatches[index];
                return _buildColorCard(swatch);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildColorCard(ColorSwatchData swatch) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            flex: 5,
            child: Container(
              decoration: BoxDecoration(
                color: swatch.color,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Stack(
                children: [
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        swatch.hex,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    swatch.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    swatch.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.textDark.withOpacity(0.6),
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
