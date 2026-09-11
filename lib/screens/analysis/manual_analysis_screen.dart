import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_profile.dart';
import '../main_layout.dart';
import '../../core/theme/app_colors.dart';

class ManualAnalysisScreen extends StatefulWidget {
  const ManualAnalysisScreen({super.key});

  @override
  State<ManualAnalysisScreen> createState() => _ManualAnalysisScreenState();
}

class _ManualAnalysisScreenState extends State<ManualAnalysisScreen> {
  FaceShape _faceShape = FaceShape.oval;
  Undertone _undertone = Undertone.cool;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manual Analysis')),
      body: Stack(
        children: [
          Positioned(
            bottom: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Tell us about your features',
                  style: Theme.of(context).textTheme.displayMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                const Text('Face Shape', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 8),
                DropdownButtonFormField<FaceShape>(
                  value: _faceShape,
                  items: FaceShape.values.where((e) => e != FaceShape.none).map((shape) {
                    return DropdownMenuItem(
                      value: shape,
                      child: Text(shape.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _faceShape = val!),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Undertone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    TextButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.help_outline, size: 16),
                      label: const Text('How to find this?', style: TextStyle(fontSize: 12)),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Undertone>(
                  value: _undertone,
                  items: Undertone.values.where((e) => e != Undertone.none).map((under) {
                    return DropdownMenuItem(
                      value: under,
                      child: Text(under.name.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _undertone = val!),
                ),
                const SizedBox(height: 48),
                ElevatedButton(
                  onPressed: () {
                    Provider.of<UserProfile>(context, listen: false).setAnalysis(_faceShape, _undertone);
                    // Navigate to results via MainLayout index 2
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const MainLayoutScreen(initialIndex: 2)),
                      (route) => false,
                    );
                  },
                  child: const Text('Save & View Results'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
