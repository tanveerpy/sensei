import 'package:flutter/material.dart';
import 'main_layout.dart';
import '../core/theme/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(40),
                  ),
                  child: const Center(
                    child: Icon(Icons.face_6, size: 120, color: AppColors.secondary),
                  ),
                ),
              ),
              const SizedBox(height: 48),
              Text(
                'Facecard',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(letterSpacing: -1),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Find what suits you.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.secondary, fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainLayoutScreen()),
                  );
                },
                child: const Text('Get Started'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
