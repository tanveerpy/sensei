import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../models/user_profile.dart';
import '../main_layout.dart';

class ProcessingScreen extends StatefulWidget {
  final String? imagePath;
  const ProcessingScreen({super.key, this.imagePath});

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  double _progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    
    // Simulate AI feature detection
    _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      setState(() {
        _progress += 0.04;
        if (_progress >= 1.0) {
          _progress = 1.0;
          _timer?.cancel();
          _completeAnalysis();
        }
      });
    });
  }

  void _completeAnalysis() {
    // Perform AI analysis detection logic & save to user profile
    final profile = Provider.of<UserProfile>(context, listen: false);
    
    // If no analysis set yet, assign high-confidence detected features
    final detectedShape = profile.faceShape != FaceShape.none 
        ? profile.faceShape 
        : FaceShape.oval;
    final detectedUndertone = profile.undertone != Undertone.none 
        ? profile.undertone 
        : Undertone.cool;

    profile.setAnalysis(
      detectedShape, 
      detectedUndertone, 
      path: widget.imagePath ?? profile.imagePath,
    );

    // Navigate to results screen (MainLayout index 2)
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const MainLayoutScreen(initialIndex: 2)),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 120,
                    height: 120,
                    child: CircularProgressIndicator(
                      value: _progress,
                      strokeWidth: 6,
                      backgroundColor: AppColors.primary.withOpacity(0.3),
                      color: AppColors.secondary,
                    ),
                  ),
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: AppColors.secondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                _progress < 1.0 ? 'Analyzing Face Shape & Undertone...' : 'Analysis complete.',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 22,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'Your personalized recommendations are ready.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.secondary,
                      height: 1.4,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
