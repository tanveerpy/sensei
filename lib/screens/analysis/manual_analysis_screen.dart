import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';
import '../main_layout.dart';

class ManualAnalysisScreen extends StatefulWidget {
  const ManualAnalysisScreen({super.key});

  @override
  State<ManualAnalysisScreen> createState() => _ManualAnalysisScreenState();
}

class _ManualAnalysisScreenState extends State<ManualAnalysisScreen> {
  FaceShape _selectedFaceShape = FaceShape.oval;
  Undertone _selectedUndertone = Undertone.cool;

  void _showUndertoneGuide() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(28.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'How to identify your Undertone',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 16),
              _buildGuideItem(
                'Cool Undertone',
                'Veins look blue/purple under sunlight. Silver jewelry flatters you best.',
                Icons.ac_unit,
                Colors.blueAccent,
              ),
              const SizedBox(height: 12),
              _buildGuideItem(
                'Warm Undertone',
                'Veins look greenish under sunlight. Gold jewelry complements your skin.',
                Icons.wb_sunny,
                Colors.amber.shade700,
              ),
              const SizedBox(height: 12),
              _buildGuideItem(
                'Neutral Undertone',
                'Veins look blue-green. Both gold and silver jewelry look great on you.',
                Icons.balance,
                AppColors.secondary,
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Got it!'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGuideItem(String title, String desc, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 2),
                Text(desc, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Analysis'),
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
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
                    'Select Your Features',
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Manually choose your face shape and undertone to get instant recommendations.',
                    style: TextStyle(fontSize: 14, color: Colors.grey, height: 1.4),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Face Shape Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.face, color: AppColors.secondary),
                              SizedBox(width: 10),
                              Text(
                                'Face Shape',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          DropdownButtonFormField<FaceShape>(
                            value: _selectedFaceShape,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: FaceShape.values
                                .where((e) => e != FaceShape.none)
                                .map((shape) {
                              final name = shape.name[0].toUpperCase() + shape.name.substring(1);
                              return DropdownMenuItem(
                                value: shape,
                                child: Text(name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedFaceShape = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Undertone Selection
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.lens_blur, color: AppColors.secondary),
                                  SizedBox(width: 10),
                                  Text(
                                    'Undertone',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ],
                              ),
                              TextButton.icon(
                                onPressed: _showUndertoneGuide,
                                icon: const Icon(Icons.help_outline, size: 16, color: AppColors.secondary),
                                label: const Text(
                                  'Guide',
                                  style: TextStyle(fontSize: 13, color: AppColors.secondary, fontWeight: FontWeight.w600),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          DropdownButtonFormField<Undertone>(
                            value: _selectedUndertone,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            items: Undertone.values
                                .where((e) => e != Undertone.none)
                                .map((under) {
                              final name = under.name[0].toUpperCase() + under.name.substring(1);
                              return DropdownMenuItem(
                                value: under,
                                child: Text(name),
                              );
                            }).toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedUndertone = val);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Save & View Results'),
                    onPressed: () {
                      Provider.of<UserProfile>(context, listen: false)
                          .setAnalysis(_selectedFaceShape, _selectedUndertone);

                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => const MainLayoutScreen(initialIndex: 2),
                        ),
                        (route) => false,
                      );
                    },
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
