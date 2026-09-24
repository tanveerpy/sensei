import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const FaceCardApp());
}

/// ===========================================================================
/// FACECARD THEME PALETTE (Lavender + Deep Plum Design System)
/// ===========================================================================
class AppPalette {
  static const Color background = Color(0xFFF6F1FF);   // Main Canvas
  static const Color primary = Color(0xFF5A2A83);      // Deep Plum (Headings, buttons, nav)
  static const Color secondary = Color(0xFFCDB4FF);    // Secondary Lavender
  static const Color accentPink = Color(0xFFE8A0BF);   // Accent Dusty Pink
  static const Color cardBg = Color(0xFFFFFFFF);       // Crisp White Cards
  static const Color textDark = Color(0xFF2F243A);     // Main Text (Deep charcoal purple)
  static const Color borderLight = Color(0xFFE2D7F3);  // Soft Borders / Dividers
  static const Color plumDark = Color(0xFF431B64);
  static const Color plumLight = Color(0xFF7439A5);
  static const Color lavenderLight = Color(0xFFF0E8FF);
}

/// ===========================================================================
/// FLASK REST API DATA CONTRACT MODELS
/// ===========================================================================

class GlassesRecommendation {
  final String name;
  final String reason;

  GlassesRecommendation({
    required this.name,
    required this.reason,
  });

  factory GlassesRecommendation.fromJson(Map<String, dynamic> json) {
    return GlassesRecommendation(
      name: json['name'] as String? ?? 'Classic Frames',
      reason: json['reason'] as String? ?? 'Balances facial architecture.',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'reason': reason,
  };
}

class HairstyleRecommendation {
  final String name;
  final String length;
  final String reason;

  HairstyleRecommendation({
    required this.name,
    this.length = 'Medium',
    required this.reason,
  });

  factory HairstyleRecommendation.fromJson(Map<String, dynamic> json) {
    return HairstyleRecommendation(
      name: json['name'] as String? ?? 'Balanced Cut',
      length: json['length'] as String? ?? 'Medium',
      reason: json['reason'] as String? ?? 'Complements facial contours gracefully.',
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'length': length,
    'reason': reason,
  };
}

class AnalysisExplanations {
  final String faceShapeReason;
  final String undertoneReason;
  final String colourWhyItSuitsYou;
  final String glassesWhyItSuitsYou;
  final String hairstyleWhyItSuitsYou;

  AnalysisExplanations({
    required this.faceShapeReason,
    required this.undertoneReason,
    this.colourWhyItSuitsYou = '',
    this.glassesWhyItSuitsYou = '',
    this.hairstyleWhyItSuitsYou = '',
  });

  factory AnalysisExplanations.fromJson(Map<String, dynamic> json) {
    return AnalysisExplanations(
      faceShapeReason: json['face_shape_reason'] as String? ??
          'Facial width-to-height ratio exhibits harmonious contours and balanced symmetry.',
      undertoneReason: json['undertone_reason'] as String? ??
          'Subsurface melanin pigmentation and vein illumination reflect balanced undertones.',
      colourWhyItSuitsYou: json['colour_why_it_suits_you'] as String? ?? '',
      glassesWhyItSuitsYou: json['glasses_why_it_suits_you'] as String? ?? '',
      hairstyleWhyItSuitsYou: json['hairstyle_why_it_suits_you'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'face_shape_reason': faceShapeReason,
    'undertone_reason': undertoneReason,
    'colour_why_it_suits_you': colourWhyItSuitsYou,
    'glasses_why_it_suits_you': glassesWhyItSuitsYou,
    'hairstyle_why_it_suits_you': hairstyleWhyItSuitsYou,
  };
}

class AnalysisRecommendations {
  final List<String> colours;
  final List<GlassesRecommendation> glasses;
  final List<HairstyleRecommendation> hairstyles;

  AnalysisRecommendations({
    required this.colours,
    required this.glasses,
    required this.hairstyles,
  });

  factory AnalysisRecommendations.fromJson(Map<String, dynamic> json) {
    return AnalysisRecommendations(
      colours: (json['colours'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      glasses: (json['glasses'] as List<dynamic>?)
              ?.map((e) => GlassesRecommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      hairstyles: (json['hairstyles'] as List<dynamic>?)
              ?.map((e) => HairstyleRecommendation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'colours': colours,
    'glasses': glasses.map((e) => e.toJson()).toList(),
    'hairstyles': hairstyles.map((e) => e.toJson()).toList(),
  };
}

class AnalysisResponse {
  final bool success;
  final String faceShape;
  final String undertone;
  final AnalysisExplanations explanations;
  final AnalysisRecommendations recommendations;

  AnalysisResponse({
    required this.success,
    required this.faceShape,
    required this.undertone,
    required this.explanations,
    required this.recommendations,
  });

  factory AnalysisResponse.fromJson(Map<String, dynamic> json) {
    return AnalysisResponse(
      success: json['success'] as bool? ?? true,
      faceShape: json['face_shape'] as String? ?? 'Oval',
      undertone: json['undertone'] as String? ?? 'Cool',
      explanations: AnalysisExplanations.fromJson(
        json['explanations'] as Map<String, dynamic>? ?? {},
      ),
      recommendations: AnalysisRecommendations.fromJson(
        json['recommendations'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'success': success,
    'face_shape': faceShape,
    'undertone': undertone,
    'explanations': explanations.toJson(),
    'recommendations': recommendations.toJson(),
  };
}

/// ===========================================================================
/// API SERVICE LAYER (Flask REST API Integration + Offline Resilient Engine)
/// ===========================================================================
class FaceCardApiService {
  // Base URL: 10.0.2.2 for Android Emulator, localhost for iOS/Web, or custom IP
  static String baseUrl = 'http://10.0.2.2:5000';

  /// Performs analysis via live Flask endpoint or graceful offline fallback
  static Future<AnalysisResponse> analyze({
    String mode = 'manual', // 'ai' or 'manual'
    String? faceShape,
    String? undertone,
    String gender = 'Female',
    Uint8List? imageBytes,
    String? fileName,
  }) async {
    try {
      if (mode == 'ai' && imageBytes != null) {
        final uri = Uri.parse('$baseUrl/api/analyze');
        final request = http.MultipartRequest('POST', uri);
        request.files.add(http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: fileName ?? 'face_capture.jpg',
        ));
        request.fields['gender'] = gender;

        final streamedResponse = await request.send().timeout(const Duration(seconds: 4));
        if (streamedResponse.statusCode == 200) {
          final resBody = await streamedResponse.stream.bytesToString();
          final data = jsonDecode(resBody) as Map<String, dynamic>;
          return AnalysisResponse.fromJson(data);
        }
      } else {
        final uri = Uri.parse('$baseUrl/api/analyze');
        final response = await http.post(
          uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'mode': 'manual',
            'face_shape': faceShape ?? 'Oval',
            'undertone': undertone ?? 'Cool',
            'gender': gender,
          }),
        ).timeout(const Duration(seconds: 3));

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          return AnalysisResponse.fromJson(data);
        }
      }
    } catch (e) {
      debugPrint('FaceCard API live server unreachable ($e). Utilizing built-in calculation engine.');
    }

    // Graceful offline fallback engine ensuring uninterrupted UI experience
    return generateFallbackAnalysis(
      faceShape: faceShape ?? 'Oval',
      undertone: undertone ?? 'Cool',
      gender: gender,
    );
  }

  /// Rule-based mapping for "Why It Suits You" explanations
  static String getColourWhyItSuitsYou(String undertone) {
    const map = {
      'Warm': 'Warm undertones usually harmonize well with earthy, golden, terracotta, and warm saturated shades, creating a healthy natural glow without washing you out.',
      'Cool': 'Cool undertones naturally contrast with crisp jewel tones, icy pastels, and ocean blues, highlighting your rosy and cool subsurface skin radiance.',
      'Neutral': 'Neutral undertones enjoy the versatility of both warm and cool spectrums, excelling in soft muted tones, jade greens, balanced pastels, and rich taupes.',
    };
    return map[undertone] ?? map['Cool']!;
  }

  static String getGlassesWhyItSuitsYou(String faceShape) {
    const map = {
      'Oval': 'Your oval face has balanced proportions, so several frame shapes work well. Angular and geometric frames can add extra definition.',
      'Round': 'Your round face has soft curves with similar width and length. Rectangular, angular, and cat-eye frames add structure and visually lengthen your face.',
      'Square': 'Your square face features a strong jawline and broad forehead. Curved, round, and thin wire frames soften sharp angles and create harmonious equilibrium.',
      'Heart': 'Your heart-shaped face tapers gracefully to a slender chin. Bottom-heavy, oval, and rimless frames add visual width to the lower half of your face.',
      'Diamond': 'Your diamond face features striking cheekbones and narrow temples. Cat-eye and browline frames accentuate your cheek structure while softening angular lines.',
      'Oblong': 'Your oblong face has an extended vertical silhouette. Oversized, tall frames and thick browlines break vertical length and add horizontal width.',
    };
    return map[faceShape] ?? map['Oval']!;
  }

  static String getHairstyleWhyItSuitsYou(String faceShape) {
    const map = {
      'Oval': 'Your oval face exhibits natural structural symmetry. Versatile lengths, sleek cuts, and soft face-framing layers effortlessly showcase your bone structure.',
      'Round': 'Your round face benefits from vertical height at the crown and diagonal, side-swept layers that elongate your facial lines and slim fuller cheeks.',
      'Square': 'Your square face has distinct jaw angles. Soft romantic waves, textured shags, and wispy layers diffuse sharpness and add fluid movement.',
      'Heart': 'Your heart face is wider at the forehead with a pointed chin. Chin-length bobs and collarbone fullness add visual width where your jaw narrows.',
      'Diamond': 'Your diamond face shines with cheek-level width and delicate temple layers that accentuate high cheekbones while softening narrow hairlines.',
      'Oblong': 'Your oblong face is elongated vertically. Fringe bangs, side-swept waves, and horizontal mid-length volume break length and restore equilibrium.',
    };
    return map[faceShape] ?? map['Oval']!;
  }

  /// Rule-based fallback engine generating complete schema
  static AnalysisResponse generateFallbackAnalysis({
    required String faceShape,
    required String undertone,
    String gender = 'Female',
  }) {
    final faceReasons = {
      'Oval': 'Your face exhibits an egg-like contour where forehead width is slightly greater than the rounded jawline. Proportions are naturally balanced and symmetrical.',
      'Round': 'Your face has equal width and length with soft curved cheekbones and jawline, giving a youthful, soft demeanor.',
      'Square': 'Your face features a defined, strong angular jawline and broad forehead with straight cheek contours.',
      'Heart': 'Your face gracefully tapers from a wider forehead down to a slender, pointed chin line.',
      'Diamond': 'High, striking cheekbones define your geometry, tapering inward toward a narrower hairline and chin.',
      'Oblong': 'Your face is characterized by an extended vertical silhouette with harmonious straight cheek lines.',
    };

    final undertoneReasons = {
      'Cool': 'Subsurface pink, blue, or rosy hues create crisp contrast with jewel tones and silver accents.',
      'Warm': 'Subsurface golden, honey, and peachy tones glow effortlessly with rich earth tones and gold accents.',
      'Neutral': 'Balanced warm and cool pigments offer immense flexibility with muted jewel tones and versatile neutrals.',
    };

    final palette = ColorRepository.palettes[undertone] ?? ColorRepository.palettes['Cool']!;
    final frames = FramesRepository.frames[faceShape] ?? FramesRepository.frames['Oval']!;
    final hair = HairstylesRepository.getHairstyles(faceShape, gender);

    return AnalysisResponse(
      success: true,
      faceShape: faceShape,
      undertone: undertone,
      explanations: AnalysisExplanations(
        faceShapeReason: faceReasons[faceShape] ?? 'Naturally balanced facial proportions.',
        undertoneReason: undertoneReasons[undertone] ?? 'Harmonious skin radiance.',
        colourWhyItSuitsYou: getColourWhyItSuitsYou(undertone),
        glassesWhyItSuitsYou: getGlassesWhyItSuitsYou(faceShape),
        hairstyleWhyItSuitsYou: getHairstyleWhyItSuitsYou(faceShape),
      ),
      recommendations: AnalysisRecommendations(
        colours: palette.map((c) => c.name).toList(),
        glasses: frames.map((f) => GlassesRecommendation(name: f.name, reason: f.desc)).toList(),
        hairstyles: hair.map((h) => HairstyleRecommendation(name: h.name, length: h.length, reason: h.desc)).toList(),
      ),
    );
  }
}

/// ===========================================================================
/// STATE MANAGEMENT & DATA MODELS
/// ===========================================================================
class AppStateManager extends InheritedWidget {
  final ValueNotifier<UserPreferences> stateNotifier;

  const AppStateManager({
    Key? key,
    required this.stateNotifier,
    required Widget child,
  }) : super(key: key, child: child);

  static AppStateManager of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppStateManager>()!;
  }

  @override
  bool updateShouldNotify(covariant AppStateManager oldWidget) {
    return oldWidget.stateNotifier != stateNotifier;
  }
}

class SavedReport {
  final String id;
  final String date;
  final String faceShape;
  final String undertone;

  SavedReport({
    required this.id,
    required this.date,
    required this.faceShape,
    required this.undertone,
  });
}

class UserPreferences {
  final String userName;
  final String email;
  final String gender;      // 'Female' | 'Male'
  final String faceShape;   // 'Oval' | 'Round' | 'Square' | 'Heart' | 'Diamond' | 'Oblong'
  final String undertone;   // 'Cool' | 'Warm' | 'Neutral'
  final bool isLoggedIn;
  final bool isGuest;
  final List<SavedReport> savedReports;
  final AnalysisResponse? currentAnalysis;

  UserPreferences({
    this.userName = 'Ayla Rose',
    this.email = 'ayla@facecard.app',
    this.gender = 'Female',
    this.faceShape = 'Oval',
    this.undertone = 'Cool',
    this.isLoggedIn = false,
    this.isGuest = false,
    this.currentAnalysis,
    List<SavedReport>? savedReports,
  }) : savedReports = savedReports ?? [
          SavedReport(
            id: '1',
            date: 'Initial Assessment',
            faceShape: 'Oval',
            undertone: 'Cool',
          ),
        ];

  UserPreferences copyWith({
    String? userName,
    String? email,
    String? gender,
    String? faceShape,
    String? undertone,
    bool? isLoggedIn,
    bool? isGuest,
    List<SavedReport>? savedReports,
    AnalysisResponse? currentAnalysis,
  }) {
    return UserPreferences(
      userName: userName ?? this.userName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      faceShape: faceShape ?? this.faceShape,
      undertone: undertone ?? this.undertone,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isGuest: isGuest ?? this.isGuest,
      savedReports: savedReports ?? this.savedReports,
      currentAnalysis: currentAnalysis ?? this.currentAnalysis,
    );
  }
}

/// ===========================================================================
/// FACECARD LOGO (Original Line Art + Card Outline + Sparkle)
/// ===========================================================================
class FaceCardLogo extends StatelessWidget {
  final double size;
  final bool showSparkle;

  const FaceCardLogo({
    Key? key,
    this.size = 80,
    this.showSparkle = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: FaceCardLogoPainter(),
          ),
          if (showSparkle)
            Positioned(
              top: size * 0.04,
              right: size * 0.08,
              child: const Icon(
                Icons.auto_awesome,
                color: Color(0xFFF5B041),
                size: 16,
              ),
            ),
        ],
      ),
    );
  }
}

class FaceCardLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Tilted Playing Card with soft white-lavender gradient and deep plum contour
    canvas.save();
    canvas.translate(w * 0.58, h * 0.44);
    canvas.rotate(0.12); // ~7 degrees stylish tilt clockwise

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset.zero, width: w * 0.60, height: h * 0.76),
      const Radius.circular(16),
    );

    // Card background fill
    final cardBgPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Colors.white, Color(0xFFF3EBFC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(cardRect.outerRect);
    canvas.drawRRect(cardRect, cardBgPaint);

    // Card border
    final cardBorderPaint = Paint()
      ..color = AppPalette.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4;
    canvas.drawRRect(cardRect, cardBorderPaint);

    // 4-Point Star Sparkle on top-right of card
    _drawSparkle(canvas, Offset(w * 0.17, -h * 0.25), w * 0.065, AppPalette.primary);

    // Dual decorative petals at bottom right of card
    final petal1 = Path()
      ..moveTo(w * 0.13, h * 0.29)
      ..quadraticBezierTo(w * 0.10, h * 0.18, w * 0.18, h * 0.16)
      ..quadraticBezierTo(w * 0.25, h * 0.24, w * 0.13, h * 0.29);
    canvas.drawPath(petal1, Paint()..color = AppPalette.accentPink);

    final petal2 = Path()
      ..moveTo(w * 0.17, h * 0.32)
      ..quadraticBezierTo(w * 0.23, h * 0.22, w * 0.29, h * 0.18)
      ..quadraticBezierTo(w * 0.31, h * 0.28, w * 0.17, h * 0.32);
    canvas.drawPath(petal2, Paint()..color = AppPalette.plumLight);

    canvas.restore();

    // 2. Overlapping Feminine Face Silhouette
    final skinPath = Path()
      ..moveTo(w * 0.38, h * 0.18)
      ..cubicTo(w * 0.44, h * 0.15, w * 0.54, h * 0.15, w * 0.58, h * 0.18)
      ..cubicTo(w * 0.62, h * 0.25, w * 0.60, h * 0.38, w * 0.57, h * 0.50)
      ..cubicTo(w * 0.55, h * 0.58, w * 0.46, h * 0.64, w * 0.41, h * 0.64)
      ..cubicTo(w * 0.37, h * 0.58, w * 0.35, h * 0.45, w * 0.37, h * 0.36)
      ..close();
    canvas.drawPath(skinPath, Paint()..color = const Color(0xFFFFF9FD));

    final plumLine = Paint()
      ..color = AppPalette.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Profile curve: forehead, delicate nose, lips, sculpted jaw
    final profilePath = Path()
      ..moveTo(w * 0.41, h * 0.22)
      ..cubicTo(w * 0.38, h * 0.28, w * 0.36, h * 0.34, w * 0.36, h * 0.39)
      ..cubicTo(w * 0.36, h * 0.41, w * 0.38, h * 0.425, w * 0.39, h * 0.425)
      ..cubicTo(w * 0.375, h * 0.445, w * 0.375, h * 0.47, w * 0.39, h * 0.49)
      ..cubicTo(w * 0.38, h * 0.52, w * 0.39, h * 0.55, w * 0.42, h * 0.57)
      ..cubicTo(w * 0.47, h * 0.57, w * 0.53, h * 0.52, w * 0.57, h * 0.45);
    canvas.drawPath(profilePath, plumLine);

    // Eyeshadow soft blush
    final shadowPaint = Paint()..color = AppPalette.accentPink.withOpacity(0.55);
    canvas.drawOval(Rect.fromCenter(center: Offset(w * 0.48, h * 0.29), width: w * 0.11, height: h * 0.05), shadowPaint);

    // Eyelid line
    final eyeLine = Path()
      ..moveTo(w * 0.43, h * 0.32)
      ..quadraticBezierTo(w * 0.485, h * 0.29, w * 0.535, h * 0.275);
    canvas.drawPath(eyeLine, plumLine);

    // Eyelashes
    final lashPaint = Paint()
      ..color = AppPalette.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 4; i++) {
      final lx = w * (0.45 + i * 0.023);
      final ly = h * (0.312 - i * 0.007);
      canvas.drawLine(Offset(lx, ly), Offset(lx - 2.5, ly + 5), lashPaint);
    }

    // Eyebrow arch
    final browPath = Path()
      ..moveTo(w * 0.41, h * 0.27)
      ..cubicTo(w * 0.46, h * 0.23, w * 0.51, h * 0.23, w * 0.54, h * 0.245);
    canvas.drawPath(browPath, plumLine..strokeWidth = 2.0);

    // Rose Pink Lips
    final lipFill = Paint()..color = AppPalette.accentPink;
    final upperLip = Path()
      ..moveTo(w * 0.375, h * 0.455)
      ..quadraticBezierTo(w * 0.405, h * 0.45, w * 0.435, h * 0.465)
      ..quadraticBezierTo(w * 0.405, h * 0.475, w * 0.375, h * 0.455);
    canvas.drawPath(upperLip, lipFill);

    final lowerLip = Path()
      ..moveTo(w * 0.38, h * 0.475)
      ..quadraticBezierTo(w * 0.405, h * 0.505, w * 0.425, h * 0.475)
      ..close();
    canvas.drawPath(lowerLip, lipFill);

    // 3. Flowing Hair Waves
    final hairLine = Paint()
      ..color = AppPalette.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.6
      ..strokeCap = StrokeCap.round;

    // Top crown wave
    final crownWave = Path()
      ..moveTo(w * 0.32, h * 0.30)
      ..cubicTo(w * 0.30, h * 0.13, w * 0.44, h * 0.07, w * 0.54, h * 0.13)
      ..cubicTo(w * 0.62, h * 0.17, w * 0.68, h * 0.29, w * 0.66, h * 0.41);
    canvas.drawPath(crownWave, hairLine);

    // Front draping strand
    final frontStrand = Path()
      ..moveTo(w * 0.47, h * 0.11)
      ..cubicTo(w * 0.37, h * 0.15, w * 0.31, h * 0.25, w * 0.29, h * 0.36)
      ..cubicTo(w * 0.27, h * 0.44, w * 0.33, h * 0.50, w * 0.33, h * 0.56)
      ..cubicTo(w * 0.33, h * 0.64, w * 0.25, h * 0.67, w * 0.27, h * 0.74);
    canvas.drawPath(frontStrand, hairLine);

    // Side undulating wave
    final sideWave = Path()
      ..moveTo(w * 0.35, h * 0.15)
      ..cubicTo(w * 0.25, h * 0.23, w * 0.23, h * 0.37, w * 0.26, h * 0.49)
      ..cubicTo(w * 0.29, h * 0.59, w * 0.37, h * 0.67, w * 0.41, h * 0.75);
    canvas.drawPath(sideWave, hairLine..strokeWidth = 2.2);

    // Back neck drape
    final backDrape = Path()
      ..moveTo(w * 0.63, h * 0.35)
      ..cubicTo(w * 0.67, h * 0.43, w * 0.59, h * 0.55, w * 0.57, h * 0.65);
    canvas.drawPath(backDrape, hairLine..strokeWidth = 2.0);
  }

  void _drawSparkle(Canvas canvas, Offset center, double radius, Color color) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final path = Path()
      ..moveTo(center.dx, center.dy - radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx + radius * 0.65, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy + radius)
      ..quadraticBezierTo(center.dx, center.dy, center.dx - radius * 0.65, center.dy)
      ..quadraticBezierTo(center.dx, center.dy, center.dx, center.dy - radius)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ===========================================================================
/// CLEAN PLACEHOLDER CONTAINER FOR STYLE ASSETS
/// ===========================================================================
class StyleAssetPlaceholder extends StatelessWidget {
  final IconData icon;
  final String? emoji;
  final double size;

  const StyleAssetPlaceholder({
    Key? key,
    required this.icon,
    this.emoji,
    this.size = 50,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFBF8FF), Color(0xFFF0E6FD)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.borderLight),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: emoji != null
            ? Text(emoji!, style: TextStyle(fontSize: size * 0.5))
            : Icon(icon, color: AppPalette.primary, size: size * 0.5),
      ),
    );
  }
}

/// ===========================================================================
/// CONTEXTUAL "WHY IT SUITS YOU" EXPLANATION CALLOUT WIDGET
/// ===========================================================================
class WhyItSuitsYouCard extends StatelessWidget {
  final String text;

  const WhyItSuitsYouCard({
    Key? key,
    required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFBF8FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppPalette.primary.withOpacity(0.18)),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withOpacity(0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppPalette.lavenderLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.auto_awesome, size: 16, color: AppPalette.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Text(
                      'WHY IT SUITS YOU',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppPalette.primary,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text('✦', style: TextStyle(fontSize: 9, color: AppPalette.primary)),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  text,
                  style: const TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// 35 DRESS COLOURS DATA REPOSITORY (Cool, Warm, Neutral)
/// ===========================================================================
class DressColor {
  final String name;
  final String hex;
  final Color color;
  final String category; // 'Neutrals' | 'Everyday' | 'Soft/Pastels' | 'Brights' | 'Jewel/Rich' | 'Deep Shades'

  const DressColor({
    required this.name,
    required this.hex,
    required this.color,
    required this.category,
  });

  int get colorValue => color.value;
  String get hexCode => hex;
}

class ColorRepository {
  static final Map<String, List<DressColor>> palettes = {
    'Cool': [
      // 1-6: Neutrals
      const DressColor(name: 'Charcoal', hex: '#36454F', color: Color(0xFF36454F), category: 'Neutrals'),
      const DressColor(name: 'Steel', hex: '#4682B4', color: Color(0xFF4682B4), category: 'Neutrals'),
      const DressColor(name: 'Granite', hex: '#676767', color: Color(0xFF676767), category: 'Neutrals'),
      const DressColor(name: 'Aluminum', hex: '#A9ACB6', color: Color(0xFFA9ACB6), category: 'Neutrals'),
      const DressColor(name: 'Silver Shadow', hex: '#C0C0C0', color: Color(0xFFC0C0C0), category: 'Neutrals'),
      const DressColor(name: 'Milk White', hex: '#F0F4F8', color: Color(0xFFF0F4F8), category: 'Neutrals'),

      // 7-11: Everyday
      const DressColor(name: 'Cool Brown', hex: '#5B4033', color: Color(0xFF5B4033), category: 'Everyday'),
      const DressColor(name: 'Navy', hex: '#000080', color: Color(0xFF000080), category: 'Everyday'),
      const DressColor(name: 'Pale Periwinkle', hex: '#C3CDE6', color: Color(0xFFC3CDE6), category: 'Everyday'),
      const DressColor(name: 'Light Indigo', hex: '#4D5887', color: Color(0xFF4D5887), category: 'Everyday'),
      const DressColor(name: 'Deep Periwinkle', hex: '#7B68EE', color: Color(0xFF7B68EE), category: 'Everyday'),

      // 12-16: Soft / Pastels
      const DressColor(name: 'Pink Rose', hex: '#E37383', color: Color(0xFFE37383), category: 'Soft/Pastels'),
      const DressColor(name: 'Powder Pink', hex: '#FFB6C1', color: Color(0xFFFFB6C1), category: 'Soft/Pastels'),
      const DressColor(name: 'Light Lemon', hex: '#FFFACD', color: Color(0xFFFFFACD), category: 'Soft/Pastels'),
      const DressColor(name: 'Baby Blue', hex: '#89CFF0', color: Color(0xFF89CFF0), category: 'Soft/Pastels'),
      const DressColor(name: 'Periwinkle', hex: '#CCCCFF', color: Color(0xFFCCCCFF), category: 'Soft/Pastels'),

      // 17-21: Brights
      const DressColor(name: 'Rose', hex: '#E0115F', color: Color(0xFFE0115F), category: 'Brights'),
      const DressColor(name: 'Jade Green', hex: '#00A86B', color: Color(0xFF00A86B), category: 'Brights'),
      const DressColor(name: 'Ocean Green', hex: '#48BF91', color: Color(0xFF48BF91), category: 'Brights'),
      const DressColor(name: 'Cool Turquoise', hex: '#3EB489', color: Color(0xFF3EB489), category: 'Brights'),
      const DressColor(name: 'Soft Magenta', hex: '#D473D4', color: Color(0xFFD473D4), category: 'Brights'),

      // 22-27: Jewel / Rich
      const DressColor(name: 'Deep Sea', hex: '#015482', color: Color(0xFF015482), category: 'Jewel/Rich'),
      const DressColor(name: 'Cobalt', hex: '#0047AB', color: Color(0xFF0047AB), category: 'Jewel/Rich'),
      const DressColor(name: 'Ocean Blue', hex: '#20669B', color: Color(0xFF20669B), category: 'Jewel/Rich'),
      const DressColor(name: 'Lapis Lazuli', hex: '#26619C', color: Color(0xFF26619C), category: 'Jewel/Rich'),
      const DressColor(name: 'Soft Blue-Violet', hex: '#6A5ACD', color: Color(0xFF6A5ACD), category: 'Jewel/Rich'),
      const DressColor(name: 'Amethyst', hex: '#9966CC', color: Color(0xFF9966CC), category: 'Jewel/Rich'),

      // 28-35: Deep Shades
      const DressColor(name: 'Burgundy', hex: '#800020', color: Color(0xFF800020), category: 'Deep Shades'),
      const DressColor(name: 'Cranberry', hex: '#9E003A', color: Color(0xFF9E003A), category: 'Deep Shades'),
      const DressColor(name: 'Strawberry', hex: '#C83F49', color: Color(0xFFC83F49), category: 'Deep Shades'),
      const DressColor(name: 'Raspberry', hex: '#D21F3C', color: Color(0xFFD21F3C), category: 'Deep Shades'),
      const DressColor(name: 'Purple Mist', hex: '#8E7CC3', color: Color(0xFF8E7CC3), category: 'Deep Shades'),
      const DressColor(name: 'Soft Violet', hex: '#9B59B6', color: Color(0xFF9B59B6), category: 'Deep Shades'),
      const DressColor(name: 'Soft Red-Violet', hex: '#A03472', color: Color(0xFFA03472), category: 'Deep Shades'),
      const DressColor(name: 'Orchid', hex: '#DA70D6', color: Color(0xFFDA70D6), category: 'Deep Shades'),
    ],

    'Warm': [
      // 1-6: Neutrals
      const DressColor(name: 'Espresso', hex: '#362B28', color: Color(0xFF362B28), category: 'Neutrals'),
      const DressColor(name: 'Warm Charcoal', hex: '#3D3635', color: Color(0xFF3D3635), category: 'Neutrals'),
      const DressColor(name: 'Cocoa', hex: '#5C4033', color: Color(0xFF5C4033), category: 'Neutrals'),
      const DressColor(name: 'Camel', hex: '#C19A6B', color: Color(0xFFC19A6B), category: 'Neutrals'),
      const DressColor(name: 'Biscuit', hex: '#D8B589', color: Color(0xFFD8B589), category: 'Neutrals'),
      const DressColor(name: 'Cream', hex: '#FFFDD0', color: Color(0xFFFFFDD0), category: 'Neutrals'),

      // 7-11: Everyday
      const DressColor(name: 'Mahogany', hex: '#4E2728', color: Color(0xFF4E2728), category: 'Everyday'),
      const DressColor(name: 'Cinnamon', hex: '#7B3F00', color: Color(0xFF7B3F00), category: 'Everyday'),
      const DressColor(name: 'Olive', hex: '#808000', color: Color(0xFF808000), category: 'Everyday'),
      const DressColor(name: 'Petrol Blue', hex: '#1D5D68', color: Color(0xFF1D5D68), category: 'Everyday'),
      const DressColor(name: 'Warm Navy', hex: '#1B263B', color: Color(0xFF1B263B), category: 'Everyday'),

      // 12-18: Soft / Pastels
      const DressColor(name: 'Peach', hex: '#FFE5B4', color: Color(0xFFFFE5B4), category: 'Soft/Pastels'),
      const DressColor(name: 'Apricot', hex: '#FBCEB1', color: Color(0xFFFBCEB1), category: 'Soft/Pastels'),
      const DressColor(name: 'Butter Yellow', hex: '#FFFD74', color: Color(0xFFFFFD74), category: 'Soft/Pastels'),
      const DressColor(name: 'Sage', hex: '#9CAF88', color: Color(0xFF9CAF88), category: 'Soft/Pastels'),
      const DressColor(name: 'Soft Aqua', hex: '#88D8C0', color: Color(0xFF88D8C0), category: 'Soft/Pastels'),
      const DressColor(name: 'Paprika Rose', hex: '#D95B66', color: Color(0xFFD95B66), category: 'Soft/Pastels'),
      const DressColor(name: 'Salmon Rose', hex: '#F28E8E', color: Color(0xFFF28E8E), category: 'Soft/Pastels'),

      // 19-24: Brights
      const DressColor(name: 'Tomato Red', hex: '#FF6347', color: Color(0xFFFF6347), category: 'Brights'),
      const DressColor(name: 'Coral Red', hex: '#FF4040', color: Color(0xFFFF4040), category: 'Brights'),
      const DressColor(name: 'Coral', hex: '#FF7F50', color: Color(0xFFFF7F50), category: 'Brights'),
      const DressColor(name: 'Marigold', hex: '#EAA221', color: Color(0xFFEAA221), category: 'Brights'),
      const DressColor(name: 'Moss Green', hex: '#8A9A5B', color: Color(0xFF8A9A5B), category: 'Brights'),
      const DressColor(name: 'Turquoise Blue', hex: '#00C5CD', color: Color(0xFF00C5CD), category: 'Brights'),

      // 25-29: Jewel / Rich
      const DressColor(name: 'Jade', hex: '#387C44', color: Color(0xFF387C44), category: 'Jewel/Rich'),
      const DressColor(name: 'Peacock', hex: '#005F73', color: Color(0xFF005F73), category: 'Jewel/Rich'),
      const DressColor(name: 'Teal', hex: '#008080', color: Color(0xFF008080), category: 'Jewel/Rich'),
      const DressColor(name: 'Warm Turquoise', hex: '#40E0D0', color: Color(0xFF40E0D0), category: 'Jewel/Rich'),
      const DressColor(name: 'Orchid', hex: '#BC6CA7', color: Color(0xFFBC6CA7), category: 'Jewel/Rich'),

      // 30-35: Deep Shades
      const DressColor(name: 'Rust', hex: '#B7410E', color: Color(0xFFB7410E), category: 'Deep Shades'),
      const DressColor(name: 'Brick', hex: '#9C413A', color: Color(0xFF9C413A), category: 'Deep Shades'),
      const DressColor(name: 'Terracotta', hex: '#E2725B', color: Color(0xFFE2725B), category: 'Deep Shades'),
      const DressColor(name: 'Aubergine', hex: '#3D0735', color: Color(0xFF3D0735), category: 'Deep Shades'),
      const DressColor(name: 'Plum', hex: '#673147', color: Color(0xFF673147), category: 'Deep Shades'),
      const DressColor(name: 'Warm Magenta', hex: '#B83280', color: Color(0xFFB83280), category: 'Deep Shades'),
    ],

    'Neutral': [
      // 1-6: Neutrals
      const DressColor(name: 'Espresso', hex: '#3A2E2B', color: Color(0xFF3A2E2B), category: 'Neutrals'),
      const DressColor(name: 'Taupe Charcoal', hex: '#484446', color: Color(0xFF484446), category: 'Neutrals'),
      const DressColor(name: 'Mushroom', hex: '#BDAC9A', color: Color(0xFFBDAC9A), category: 'Neutrals'),
      const DressColor(name: 'Mink', hex: '#887569', color: Color(0xFF887569), category: 'Neutrals'),
      const DressColor(name: 'Latte', hex: '#C5A059', color: Color(0xFFC5A059), category: 'Neutrals'),
      const DressColor(name: 'Soft White', hex: '#FAF9F6', color: Color(0xFFFAF9F6), category: 'Neutrals'),

      // 7-11: Everyday
      const DressColor(name: 'Rose Brown', hex: '#795152', color: Color(0xFF795152), category: 'Everyday'),
      const DressColor(name: 'Olive Taupe', hex: '#6F6652', color: Color(0xFF6F6652), category: 'Everyday'),
      const DressColor(name: 'Slate Blue', hex: '#6A7F96', color: Color(0xFF6A7F96), category: 'Everyday'),
      const DressColor(name: 'Denim Blue', hex: '#4B6E8C', color: Color(0xFF4B6E8C), category: 'Everyday'),
      const DressColor(name: 'Soft Navy', hex: '#243342', color: Color(0xFF243342), category: 'Everyday'),

      // 12-17: Soft / Pastels
      const DressColor(name: 'Blush', hex: '#DE5D83', color: Color(0xFFDE5D83), category: 'Soft/Pastels'),
      const DressColor(name: 'Shell Pink', hex: '#FFD1DC', color: Color(0xFFFFD1DC), category: 'Soft/Pastels'),
      const DressColor(name: 'Peach Beige', hex: '#ECC8B1', color: Color(0xFFECC8B1), category: 'Soft/Pastels'),
      const DressColor(name: 'Buttercream', hex: '#EFEAD8', color: Color(0xFFEFEAD8), category: 'Soft/Pastels'),
      const DressColor(name: 'Powder Blue', hex: '#A6C8D8', color: Color(0xFFA6C8D8), category: 'Soft/Pastels'),
      const DressColor(name: 'Periwinkle', hex: '#B4B8E1', color: Color(0xFFB4B8E1), category: 'Soft/Pastels'),

      // 18-22: Brights
      const DressColor(name: 'Watermelon', hex: '#FC6C85', color: Color(0xFFFC6C85), category: 'Brights'),
      const DressColor(name: 'Soft Coral', hex: '#F88379', color: Color(0xFFF88379), category: 'Brights'),
      const DressColor(name: 'Soft Gold', hex: '#D4AF37', color: Color(0xFFD4AF37), category: 'Brights'),
      const DressColor(name: 'Eucalyptus', hex: '#5F8575', color: Color(0xFF5F8575), category: 'Brights'),
      const DressColor(name: 'Sage Green', hex: '#879E89', color: Color(0xFF879E89), category: 'Brights'),

      // 23-28: Jewel / Rich
      const DressColor(name: 'Jade Mist', hex: '#76B599', color: Color(0xFF76B599), category: 'Jewel/Rich'),
      const DressColor(name: 'Sea Green', hex: '#2E8B57', color: Color(0xFF2E8B57), category: 'Jewel/Rich'),
      const DressColor(name: 'Muted Teal', hex: '#4A767A', color: Color(0xFF4A767A), category: 'Jewel/Rich'),
      const DressColor(name: 'Storm Teal', hex: '#32525A', color: Color(0xFF32525A), category: 'Jewel/Rich'),
      const DressColor(name: 'Smoky Periwinkle', hex: '#747B96', color: Color(0xFF747B96), category: 'Jewel/Rich'),
      const DressColor(name: 'Orchid Rose', hex: '#BC6C84', color: Color(0xFFBC6C84), category: 'Jewel/Rich'),

      // 29-35: Deep Shades
      const DressColor(name: 'Bittersweet', hex: '#8A3324', color: Color(0xFF8A3324), category: 'Deep Shades'),
      const DressColor(name: 'Muted Berry', hex: '#994D66', color: Color(0xFF994D66), category: 'Deep Shades'),
      const DressColor(name: 'Dusty Rose', hex: '#DCAE96', color: Color(0xFFDCAE96), category: 'Deep Shades'),
      const DressColor(name: 'Mauve Taupe', hex: '#915F6D', color: Color(0xFF915F6D), category: 'Deep Shades'),
      const DressColor(name: 'Soft Plum', hex: '#7A4E65', color: Color(0xFF7A4E65), category: 'Deep Shades'),
      const DressColor(name: 'Berry Pink', hex: '#C74375', color: Color(0xFFC74375), category: 'Deep Shades'),
      const DressColor(name: 'Rosewood', hex: '#65000B', color: Color(0xFF65000B), category: 'Deep Shades'),
    ],
  };
}

/// ===========================================================================
/// 6 EYEWEAR FRAMES REPOSITORY
/// ===========================================================================
class FrameItem {
  final String name;
  final String iconText;
  final String desc;

  const FrameItem({required this.name, required this.iconText, required this.desc});
}

class FramesRepository {
  static final Map<String, List<FrameItem>> frames = {
    'Oval': [
      const FrameItem(name: 'Geometric Square Frames', iconText: '👓', desc: 'Structured straight lines balance softer oval cheek contours with modern definition.'),
      const FrameItem(name: 'Classic Cat-Eye Frames', iconText: '🕶️', desc: 'Subtle upward sweep lifts the eyes and accentuates cheekbone symmetry.'),
      const FrameItem(name: 'Sleek Rectangular Acetate', iconText: '👓', desc: 'Crisp horizontal proportions harmonize naturally with balanced facial length.'),
      const FrameItem(name: 'Angular Browline Spectacles', iconText: '👓', desc: 'Draws focus upward to brows, providing architectural depth to soft contours.'),
      const FrameItem(name: 'Retro Wayfarer Sunglasses', iconText: '🕶️', desc: 'Timeless balanced silhouette maintains optimal eye-to-jaw proportions.'),
      const FrameItem(name: 'Hexagonal Wire Frames', iconText: '👓', desc: 'Subtle modern angles add playful sharpness without overwhelming features.'),
    ],
    'Round': [
      const FrameItem(name: 'Sharp Angular Rectangle', iconText: '👓', desc: 'Creates contrast against soft round curves, visually slimming and elongating the face.'),
      const FrameItem(name: 'Oversized Square Acetate', iconText: '🕶️', desc: 'Bold boxy contours introduce needed structure and vertical perception.'),
      const FrameItem(name: 'Dramatic Upswept Cat-Eye', iconText: '🕶️', desc: 'Lifts visual weight upward and outward away from rounded cheeks.'),
      const FrameItem(name: 'Bold Browline Frames', iconText: '👓', desc: 'Emphasizes top facial horizontal lines, giving sculpted architectural definition.'),
      const FrameItem(name: 'Geometric D-Frame Shades', iconText: '🕶️', desc: 'Flat upper browline and squared bottom add sharp definition.'),
      const FrameItem(name: 'Narrow Rectangular Wire', iconText: '👓', desc: 'Streamlined profile breaks cheek fullness without taking over the face.'),
    ],
    'Square': [
      const FrameItem(name: 'Soft Round Wire Frames', iconText: '👓', desc: 'Curved spherical rims gracefully soften strong, prominent jawlines.'),
      const FrameItem(name: 'Oval Acetate Frames', iconText: '👓', desc: 'Gentle rounded geometry balances square angles with relaxed elegance.'),
      const FrameItem(name: 'Classic Teardrop Aviator', iconText: '🕶️', desc: 'Sloping teardrop glass breaks square proportions for a flattering balance.'),
      const FrameItem(name: 'Curvy Butterfly Frames', iconText: '🕶️', desc: 'Flared curved contours draw focus away from jaw corners towards eyes.'),
      const FrameItem(name: 'Thin Metal Round Frames', iconText: '👓', desc: 'Minimalist curves prevent harsh lines, creating a breezy, soft expression.'),
      const FrameItem(name: 'Soft Rounded Cat-Eye', iconText: '🕶️', desc: 'Gentle upward sweep introduces fluid curves above defined cheekbones.'),
    ],
    'Heart': [
      const FrameItem(name: 'Bottom-Heavy Round Frames', iconText: '👓', desc: 'Adds visual fullness to the lower face, balancing a wider forehead.'),
      const FrameItem(name: 'Light Metal Oval Frames', iconText: '👓', desc: 'Delicate light rims avoid overpowering a slender, delicate chin line.'),
      const FrameItem(name: 'Rimless Minimalist Frames', iconText: '👓', desc: 'Keeps upper face light and airy while maintaining harmonious balance.'),
      const FrameItem(name: 'Wayfarer Slim Silhouette', iconText: '🕶️', desc: 'Softly tapered lower rim mimics natural jawline tapers.'),
      const FrameItem(name: 'Low-Bridge Round Eyewear', iconText: '👓', desc: 'Low nose bridge shifts visual weight downward for ideal equilibrium.'),
      const FrameItem(name: 'Soft Hexagonal Frames', iconText: '🕶️', desc: 'Gentle geometric corners add interest without widening temple zones.'),
    ],
    'Diamond': [
      const FrameItem(name: 'Dramatic Cat-Eye Frames', iconText: '🕶️', desc: 'Accentuates striking diamond cheekbones while widening upper temple.'),
      const FrameItem(name: 'Oval Acetate Frames', iconText: '👓', desc: 'Curved contours soften high cheek angles for delicate harmony.'),
      const FrameItem(name: 'Browline Clubmaster', iconText: '👓', desc: 'Emphasizes browline to visually balance narrow temples and chin.'),
      const FrameItem(name: 'Round Wire Frames', iconText: '👓', desc: 'Smooth circular edges balance pointed chins and angular cheek architecture.'),
      const FrameItem(name: 'Soft Rectangular Frames', iconText: '👓', desc: 'Maintains balanced width across eyes without clashing with cheekbones.'),
      const FrameItem(name: 'Rimless Oval Spectacles', iconText: '👓', desc: 'Clean, ultra-light aesthetics complement dramatic sculpted features.'),
    ],
    'Oblong': [
      const FrameItem(name: 'Oversized Square Frames', iconText: '🕶️', desc: 'Deep vertical lenses break face length and create width across cheeks.'),
      const FrameItem(name: 'Wide Wayfarer Frames', iconText: '👓', desc: 'Extended horizontal width shortens the appearance of a longer face.'),
      const FrameItem(name: 'Tall Round Silhouette', iconText: '👓', desc: 'Generous circular height fills mid-face space harmoniously.'),
      const FrameItem(name: 'Thick Browline Frames', iconText: '👓', desc: 'Draws attention across upper face, reducing vertical perception.'),
      const FrameItem(name: 'Aviator Pilot Frames', iconText: '🕶️', desc: 'Broad top bar adds horizontal balance with timeless relaxed swagger.'),
      const FrameItem(name: 'Rounded Square Spectacles', iconText: '👓', desc: 'Provides balanced coverage and proportion for extended face lengths.'),
    ],
  };
}

/// ===========================================================================
/// 6-8 HAIRSTYLES REPOSITORY
/// ===========================================================================
class HairstyleItem {
  final String name;
  final String length;
  final String iconText;
  final String desc;

  const HairstyleItem({required this.name, this.length = 'Medium', required this.iconText, required this.desc});
}

class HairstylesRepository {
  static final Map<String, List<HairstyleItem>> femaleHairstyles = {
    'Oval': [
      const HairstyleItem(name: 'Long Layered Waves', length: 'Long', iconText: '💇‍♀️', desc: 'Frames naturally balanced facial contours with fluid, graceful movement.'),
      const HairstyleItem(name: 'Sleek French Bob', length: 'Short', iconText: '💇', desc: 'Hugs the jawline cleanly, showcasing symmetrical bone structure.'),
      const HairstyleItem(name: 'Curtain Bangs with Lob', length: 'Medium', iconText: '✨', desc: 'Soft cheek-grazing fringe draws immediate focus to eyes and cheekbones.'),
      const HairstyleItem(name: 'Textured Shag Cut', length: 'Medium', iconText: '✂️', desc: 'Playful choppy layers add volume without overwhelming facial balance.'),
      const HairstyleItem(name: 'High Slick Ponytail', length: 'Long', iconText: '👱‍♀️', desc: 'Completely highlights your ideal natural proportions and bone symmetry.'),
      const HairstyleItem(name: 'Beachy Midi Lob', length: 'Medium', iconText: '🌊', desc: 'Effortless collarbone length adds movement flattering for any occasion.'),
      const HairstyleItem(name: 'Half-Up Crown Bun', length: 'Long', iconText: '👑', desc: 'Accentuates natural symmetry while providing easy casual sophistication.'),
    ],
    'Round': [
      const HairstyleItem(name: 'High Voluminous Ponytail', length: 'Long', iconText: '👱‍♀️', desc: 'Adds vertical crown height to elongate facial dimensions dramatically.'),
      const HairstyleItem(name: 'Side-Parted Long Lob', length: 'Medium', iconText: '💇‍♀️', desc: 'Asymmetrical diagonal parting breaks roundness and slims fuller cheeks.'),
      const HairstyleItem(name: 'Textured Shaggy Bob', length: 'Short', iconText: '✂️', desc: 'Uneven textured ends below chin create an elongating silhouette.'),
      const HairstyleItem(name: 'Face-Framing Tendrils', length: 'Medium', iconText: '✨', desc: 'Soft wisps along cheeks narrow width and create vertical flow.'),
      const HairstyleItem(name: 'Asymmetrical Pixie', length: 'Short', iconText: '💇', desc: 'Height on top with tapered sides sculpts sharper facial angles.'),
      const HairstyleItem(name: 'Long Cascading Curls', length: 'Long', iconText: '🌊', desc: 'Weight at collarbone level draws gaze downward, slimming the face.'),
    ],
    'Square': [
      const HairstyleItem(name: 'Romantic Loose Waves', length: 'Long', iconText: '🌊', desc: 'Soft billowy curves diffuse and counterbalance a strong jawline.'),
      const HairstyleItem(name: 'Wispy Curtain Bangs', length: 'Medium', iconText: '✨', desc: 'Feathery forehead fringe softens temple corners and forehead angles.'),
      const HairstyleItem(name: 'Shoulder-Length Layered Lob', length: 'Medium', iconText: '💇‍♀️', desc: 'Layers starting past jaw level draw attention down from square corners.'),
      const HairstyleItem(name: 'Deep Side Swept Part', length: 'Medium', iconText: '💇', desc: 'Diagonal hair drape interrupts boxy lines for gentle feminine grace.'),
      const HairstyleItem(name: 'Tousled Midi Shag', length: 'Medium', iconText: '✂️', desc: 'Organic softness surrounds facial perimeter to minimize angularity.'),
      const HairstyleItem(name: 'Soft Messy Low Bun', length: 'Long', iconText: '👱‍♀️', desc: 'Loose front tendrils frame and soften the jaw with relaxed elegance.'),
    ],
    'Heart': [
      const HairstyleItem(name: 'Chin-Length Blunt Bob', length: 'Short', iconText: '💇', desc: 'Adds visual width and body right at narrower jawline for perfect balance.'),
      const HairstyleItem(name: 'Shoulder-Length Curls', length: 'Medium', iconText: '🌊', desc: 'Fullness around neck and collarbone balances a broad forehead.'),
      const HairstyleItem(name: 'Side-Swept Bangs', length: 'Medium', iconText: '✨', desc: 'Sweeps diagonally across forehead to visually taper upper face width.'),
      const HairstyleItem(name: 'Textured Midi Layers', length: 'Medium', iconText: '✂️', desc: 'Airy bottom layers give volume where needed around a slender chin.'),
      const HairstyleItem(name: 'Low Loose Chignon', length: 'Long', iconText: '👱‍♀️', desc: 'Keeps volume situated low near nape of neck, harmonizing heart shapes.'),
      const HairstyleItem(name: 'Soft Bixie Cut', length: 'Short', iconText: '💇‍♀️', desc: 'Tapered top with fuller nape texture provides lovely proportional balance.'),
    ],
    'Diamond': [
      const HairstyleItem(name: 'Curtain Fringe Long Lob', length: 'Medium', iconText: '✨', desc: 'Widens temple zone while highlighting high sculpted diamond cheekbones.'),
      const HairstyleItem(name: 'Deep Side Part with Waves', length: 'Long', iconText: '💇‍♀️', desc: 'Asymmetrical volume softens angular cheeks and narrow temple lines.'),
      const HairstyleItem(name: 'Chin-Grazing Wavy Bob', length: 'Short', iconText: '💇', desc: 'Builds width at chin level to harmonize with prominent cheekbones.'),
      const HairstyleItem(name: 'Bouncy Voluminous Blowout', length: 'Long', iconText: '🌊', desc: 'Creates full movement around jawline for smooth cohesive balance.'),
      const HairstyleItem(name: 'Sleek Low Pony with Tendrils', length: 'Long', iconText: '👱‍♀️', desc: 'Accentuates sharp cheek structure while softening chin edges.'),
      const HairstyleItem(name: 'Soft Layered Shag', length: 'Medium', iconText: '✂️', desc: 'Choppy bangs and textured ends flatter dramatic angular contours.'),
    ],
    'Oblong': [
      const HairstyleItem(name: 'Soft Full Fringe Bangs', length: 'Medium', iconText: '✨', desc: 'Covers forehead to shorten vertical face length gracefully.'),
      const HairstyleItem(name: 'Voluminous Side Curls', length: 'Long', iconText: '🌊', desc: 'Horizontal body along sides widens face profile for ideal proportions.'),
      const HairstyleItem(name: 'Wavy French Bob', length: 'Short', iconText: '💇', desc: 'Chin-length cut creates horizontal fullness, breaking vertical lines.'),
      const HairstyleItem(name: 'Layered Shoulder-Length Lob', length: 'Medium', iconText: '💇‍♀️', desc: 'Mid-length body prevents pulling face downward visually.'),
      const HairstyleItem(name: 'Side-Parted Hollywood Waves', length: 'Long', iconText: '✨', desc: 'Wide undulating waves add glamorous lateral width across cheekbones.'),
      const HairstyleItem(name: 'Fluffy Textured Shag', length: 'Medium', iconText: '✂️', desc: 'Side volume and brow-skimming bangs craft a harmonious oval impression.'),
    ],
  };

  static final Map<String, List<HairstyleItem>> maleHairstyles = {
    'Oval': [
      const HairstyleItem(name: 'Textured Quiff', length: 'Short', iconText: '✂️', desc: 'Adds subtle crown volume while enhancing natural facial symmetry.'),
      const HairstyleItem(name: 'Classic Taper Fade', length: 'Short', iconText: '💈', desc: 'Neat clean graduation on sides with manageable, balanced length on top.'),
      const HairstyleItem(name: 'Slicked Undercut', length: 'Medium', iconText: '💇‍♂️', desc: 'Sharp contrast between disconnected sides and swept-back textured crown.'),
      const HairstyleItem(name: 'Modern Pompadour', length: 'Medium', iconText: '✨', desc: 'Elevates profile height effortlessly to accentuate oval proportions.'),
      const HairstyleItem(name: 'Ivy League Cut', length: 'Short', iconText: '✂️', desc: 'Refined side-parted crew cut tailored for timeless, clean contours.'),
      const HairstyleItem(name: 'Messy Textured Fringe', length: 'Medium', iconText: '💇‍♂️', desc: 'Relaxed front texture provides effortless youthful movement.'),
      const HairstyleItem(name: 'Short Scissor Crop', length: 'Short', iconText: '✂️', desc: 'Uniform scissor texture highlighting masculine bone structure.'),
    ],
    'Round': [
      const HairstyleItem(name: 'High Top Fade', length: 'Short', iconText: '💈', desc: 'Substantial crown height visually stretches and elongates circular faces.'),
      const HairstyleItem(name: 'Angular Textured Quiff', length: 'Medium', iconText: '✨', desc: 'Sharp diagonal flow cuts across roundness to create structured angles.'),
      const HairstyleItem(name: 'Side-Part Pompadour', length: 'Medium', iconText: '💇‍♂️', desc: 'Distinct parting line and vertical volume disrupt soft curved boundaries.'),
      const HairstyleItem(name: 'Textured French Crop with Taper', length: 'Short', iconText: '✂️', desc: 'Tight faded sides slim facial cheeks while textured top provides vertical lift.'),
      const HairstyleItem(name: 'Spiky Short Top with Mid-Fade', length: 'Short', iconText: '💈', desc: 'Upward hair direction pulls visual attention up and away from full cheeks.'),
      const HairstyleItem(name: 'Slicked Side-Sweep', length: 'Medium', iconText: '💇‍♂️', desc: 'Asymmetrical lateral sweep introduces angular definition.'),
    ],
    'Square': [
      const HairstyleItem(name: 'Buzz Cut with Fade', length: 'Short', iconText: '💈', desc: 'Embraces and celebrates strong chiselled jawlines with ultra-clean precision.'),
      const HairstyleItem(name: 'Textured Crew Cut', length: 'Short', iconText: '✂️', desc: 'Softly textured upper length diffuses harsh boxy contours.'),
      const HairstyleItem(name: 'Classic Side Part', length: 'Medium', iconText: '💇‍♂️', desc: 'Gentle diagonal parting line softens strong temple corners and jaw points.'),
      const HairstyleItem(name: 'Messy Textured Quiff', length: 'Medium', iconText: '✨', desc: 'Organic crown height breaks up the angularity of a broad forehead.'),
      const HairstyleItem(name: 'Slicked Back with Taper', length: 'Medium', iconText: '💈', desc: 'Smooth flowing lines counteract sharp cheekbone and jawline edges.'),
      const HairstyleItem(name: 'French Crop with Soft Fringe', length: 'Short', iconText: '✂️', desc: 'Slightly rounded front fringe balances rigid facial perimeters.'),
    ],
    'Heart': [
      const HairstyleItem(name: 'Mid-Length Layered Flow', length: 'Medium', iconText: '🌊', desc: 'Collarbone-grazing fullness creates width around narrow chin and jawline.'),
      const HairstyleItem(name: 'Textured Fringe with Soft Taper', length: 'Medium', iconText: '✂️', desc: 'Down-swept fringe minimizes a broader forehead for balanced proportions.'),
      const HairstyleItem(name: 'Side-Swept Quiff', length: 'Medium', iconText: '✨', desc: 'Directs attention diagonally away from pointed chin towards hair texture.'),
      const HairstyleItem(name: 'Shaggy Textured Crop', length: 'Short', iconText: '💇‍♂️', desc: 'Airy perimeter volume softens wide temples and harmonizes chin silhouette.'),
      const HairstyleItem(name: 'Classic Scissor Taper', length: 'Medium', iconText: '✂️', desc: 'Avoids overly tight skin fades, preserving gentle side bulk around jaw.'),
      const HairstyleItem(name: 'Wavy Side Part', length: 'Medium', iconText: '🌊', desc: 'Soft undulating waves neutralize top-heavy facial architecture.'),
    ],
    'Diamond': [
      const HairstyleItem(name: 'Textured Comb Over Fade', length: 'Medium', iconText: '💇‍♂️', desc: 'Broadens upper temple appearance while complementing prominent cheekbones.'),
      const HairstyleItem(name: 'Medium Messy Flow with Fringe', length: 'Medium', iconText: '🌊', desc: 'Forehead bangs and side body widen narrow hairline and chin points.'),
      const HairstyleItem(name: 'Classic Pompadour', length: 'Medium', iconText: '✨', desc: 'Rounded crown volume balances the sharpest angular cheek lines seamlessly.'),
      const HairstyleItem(name: 'Low Fade with Textured Top', length: 'Short', iconText: '💈', desc: 'Preserves adequate side fullness around temples to balance wide cheeks.'),
      const HairstyleItem(name: 'Faux Hawk Fade', length: 'Short', iconText: '✂️', desc: 'Central vertical styling aligns harmoniously with high chiselled cheekbones.'),
      const HairstyleItem(name: 'Swept-Back Wavy Midi', length: 'Medium', iconText: '🌊', desc: 'Loose movement around the ears fills out narrower upper/lower contours.'),
    ],
    'Oblong': [
      const HairstyleItem(name: 'Side Part with Low Taper', length: 'Medium', iconText: '💇‍♂️', desc: 'Horizontal styling direction breaks vertical length without adding crown height.'),
      const HairstyleItem(name: 'Crew Cut with Temple Fade', length: 'Short', iconText: '✂️', desc: 'Keeps top short and sides moderate so the face does not look extended.'),
      const HairstyleItem(name: 'Textured Crop with Blunt Bangs', length: 'Short', iconText: '✂️', desc: 'Horizontal front fringe directly conceals forehead, shortening the vertical silhouette.'),
      const HairstyleItem(name: 'Layered Scissor Cut', length: 'Medium', iconText: '💈', desc: 'Full scissor-cut sides build lateral width to offset elongated face proportions.'),
      const HairstyleItem(name: 'Caesar Cut', length: 'Short', iconText: '✨', desc: 'Compact horizontal fringe creates width and anchors facial balance.'),
      const HairstyleItem(name: 'Side Swept Brush Down', length: 'Medium', iconText: '💇‍♂️', desc: 'Diagonal downward drape counterbalances elongated vertical dimensions.'),
    ],
  };

  /// Backwards compatibility accessor returning female hairstyles by default
  static Map<String, List<HairstyleItem>> get hairstyles => femaleHairstyles;

  /// Returns gender-tailored hairstyle recommendations for a given face shape
  static List<HairstyleItem> getHairstyles(String faceShape, String gender) {
    final catalog = (gender.toLowerCase() == 'male') ? maleHairstyles : femaleHairstyles;
    return catalog[faceShape] ?? catalog['Oval'] ?? [];
  }
}

/// ===========================================================================
/// MAIN APPLICATION WIDGET
/// ===========================================================================
class FaceCardApp extends StatefulWidget {
  const FaceCardApp({Key? key}) : super(key: key);

  @override
  State<FaceCardApp> createState() => _FaceCardAppState();
}

class _FaceCardAppState extends State<FaceCardApp> {
  late final ValueNotifier<UserPreferences> _stateNotifier;

  @override
  void initState() {
    super.initState();
    _stateNotifier = ValueNotifier(UserPreferences());
  }

  @override
  Widget build(BuildContext context) {
    return AppStateManager(
      stateNotifier: _stateNotifier,
      child: MaterialApp(
        title: 'FaceCard',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: AppPalette.background,
          primaryColor: AppPalette.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppPalette.primary,
            primary: AppPalette.primary,
            secondary: AppPalette.secondary,
            surface: AppPalette.cardBg,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(fontFamily: 'Playfair Display', color: AppPalette.textDark, fontWeight: FontWeight.bold),
            headlineMedium: TextStyle(fontFamily: 'Playfair Display', color: AppPalette.textDark, fontWeight: FontWeight.bold),
            titleLarge: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppPalette.textDark, fontWeight: FontWeight.bold, fontSize: 18),
            bodyLarge: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppPalette.textDark, fontSize: 14),
            bodyMedium: TextStyle(fontFamily: 'Plus Jakarta Sans', color: AppPalette.textDark, fontSize: 13),
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/welcome': (context) => const WelcomeScreen(),
          '/auth': (context) => const AuthScreen(),
          '/home': (context) => const HomeScreen(),
          '/ai_analysis': (context) => const AiAnalysisScreen(),
          '/manual_shape': (context) => const ManualShapeScreen(),
          '/manual_undertone': (context) => const ManualUndertoneScreen(),
          '/processing': (context) => const ProcessingScreen(),
          '/results': (context) => const ResultsScreen(),
          '/profile': (context) => const ProfileScreen(),
        },
      ),
    );
  }

  @override
  void dispose() {
    _stateNotifier.dispose();
    super.dispose();
  }
}

/// ===========================================================================
/// SCREEN 1: SPLASH SCREEN
/// ===========================================================================
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );

    _animController.forward();

    Future.delayed(const Duration(milliseconds: 2300), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Brand Squircle App Card matching reference icon
                Container(
                  width: 140,
                  height: 140,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(36),
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.primary.withOpacity(0.12),
                        blurRadius: 30,
                        offset: const Offset(0, 10),
                      ),
                    ],
                    border: Border.all(color: AppPalette.borderLight.withOpacity(0.8), width: 1.5),
                  ),
                  child: const Center(
                    child: FaceCardLogo(size: 110, showSparkle: true),
                  ),
                ),
                const SizedBox(height: 28),

                // FaceCard Title with 4-Point Star
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'FaceCard',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 38,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.primary,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: const Icon(Icons.auto_awesome, color: AppPalette.primary, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Tagline: "Find what suits you."
                const Text(
                  'Find what suits you.',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 16,
                    color: AppPalette.textDark,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 14),

                // Delicate Ornamental Divider: ――― ♥ ―――
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 44, height: 1, color: AppPalette.primary.withOpacity(0.35)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Icon(Icons.favorite, size: 12, color: AppPalette.accentPink),
                    ),
                    Container(width: 44, height: 1, color: AppPalette.primary.withOpacity(0.35)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// SCREEN 2: WELCOME SCREEN (Tagline, Log In, Sign Up, Continue as Guest)
/// ===========================================================================
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const SizedBox(height: 10),
              // Brand Hero Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.primary.withOpacity(0.06),
                      blurRadius: 24,
                      offset: const Offset(0, 8),
                    ),
                  ],
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: Column(
                  children: [
                    const FaceCardLogo(size: 110, showSparkle: true),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'FaceCard',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.primary,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.auto_awesome, color: AppPalette.primary, size: 18),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      '“Find what suits you.”',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                        color: AppPalette.plumLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(width: 36, height: 1, color: AppPalette.primary.withOpacity(0.3)),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.favorite, size: 10, color: AppPalette.accentPink),
                        ),
                        Container(width: 36, height: 1, color: AppPalette.primary.withOpacity(0.3)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Discover your flattering face shape, calibrate your natural undertone, and unlock personalized dress colours, glasses frames, and hairstyles.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black54, fontSize: 12, height: 1.4),
                    ),
                  ],
                ),
              ),

              // 3 Welcome Options
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/auth', arguments: 'login'),
                    icon: const Icon(Icons.login, size: 18),
                    label: const Text('LOG IN', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/auth', arguments: 'signup'),
                    icon: const Icon(Icons.person_add_alt_1_outlined, size: 18),
                    label: const Text('CREATE ACCOUNT', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 0.5)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.primary,
                      side: const BorderSide(color: AppPalette.primary, width: 1.5),
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () {
                      final notifier = AppStateManager.of(context).stateNotifier;
                      notifier.value = notifier.value.copyWith(
                        userName: 'Guest User',
                        email: 'guest@facecard.app',
                        isGuest: true,
                        isLoggedIn: false,
                      );
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'CONTINUE AS GUEST',
                          style: TextStyle(
                            color: AppPalette.textDark,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'No registration needed • Local session storage',
                          style: TextStyle(
                            color: Colors.black45,
                            fontSize: 11,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// SCREEN 3: AUTH SCREEN (Log In & Create Account)
/// ===========================================================================
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  final _loginEmailController = TextEditingController(text: 'ayla@facecard.app');
  final _loginPasswordController = TextEditingController(text: 'password123');
  bool _obscureLoginPassword = true;

  final _signupUsernameController = TextEditingController(text: 'Ayla Rose');
  final _signupEmailController = TextEditingController(text: 'ayla@facecard.app');
  final _signupPasswordController = TextEditingController(text: 'password123');
  final _signupConfirmPasswordController = TextEditingController(text: 'password123');
  bool _obscureSignupPassword = true;
  bool _obscureSignupConfirmPassword = true;
  String _signupGender = 'Female';

  final RegExp _emailRegex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,4}$');

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupUsernameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as String?;
    if (args == 'signup') {
      _tabController.index = 1;
    }
  }

  void _handleLogin() {
    if (_loginFormKey.currentState?.validate() ?? false) {
      final notifier = AppStateManager.of(context).stateNotifier;
      final email = _loginEmailController.text.trim();
      final derivedName = email.split('@')[0];
      notifier.value = notifier.value.copyWith(
        email: email,
        userName: derivedName.isNotEmpty ? '${derivedName[0].toUpperCase()}${derivedName.substring(1)}' : 'Member',
        isLoggedIn: true,
        isGuest: false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome back, ${notifier.value.userName}!'),
          backgroundColor: AppPalette.primary,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  void _handleSignup() {
    if (_signupFormKey.currentState?.validate() ?? false) {
      final notifier = AppStateManager.of(context).stateNotifier;
      final prevGuestAnalysis = notifier.value.currentAnalysis;
      final updatedReports = List<SavedReport>.from(notifier.value.savedReports);

      // Automatically migrate guest assessment to permanent saved style history
      if (prevGuestAnalysis != null) {
        final migratedReport = SavedReport(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: 'Guest Session Assessment (Preserved)',
          faceShape: prevGuestAnalysis.faceShape,
          undertone: prevGuestAnalysis.undertone,
        );
        updatedReports.insert(0, migratedReport);
      }

      notifier.value = notifier.value.copyWith(
        userName: _signupUsernameController.text.trim(),
        email: _signupEmailController.text.trim(),
        gender: _signupGender,
        isLoggedIn: true,
        isGuest: false,
        savedReports: updatedReports,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('FaceCard account created successfully!'),
          backgroundColor: AppPalette.primary,
        ),
      );
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        shadowColor: AppPalette.primary.withOpacity(0.08),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppPalette.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'FaceCard Access',
          style: TextStyle(color: AppPalette.primary, fontWeight: FontWeight.bold, fontFamily: 'Playfair Display'),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppPalette.primary,
          indicatorWeight: 3,
          labelColor: AppPalette.primary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5),
          tabs: const [
            Tab(text: 'LOG IN'),
            Tab(text: 'CREATE ACCOUNT'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Login Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: _loginEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppPalette.primary, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.borderLight)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.borderLight)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.primary, width: 2)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email address is required';
                      }
                      if (!_emailRegex.hasMatch(val.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _loginPasswordController,
                    obscureText: _obscureLoginPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppPalette.primary, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureLoginPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppPalette.primary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureLoginPassword = !_obscureLoginPassword),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.borderLight)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.borderLight)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.primary, width: 2)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Password is required';
                      }
                      if (val.trim().length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: const Text('Log In to FaceCard', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ],
              ),
            ),
          ),

          // Sign Up Form
          SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _signupFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _signupUsernameController,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: const Icon(Icons.person_outline, color: AppPalette.primary, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.borderLight)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.borderLight)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.primary, width: 2)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Full name is required';
                      }
                      if (val.trim().length < 3) {
                        return 'Name must be at least 3 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _signupEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      prefixIcon: const Icon(Icons.email_outlined, color: AppPalette.primary, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.borderLight)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.borderLight)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.primary, width: 2)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Email address is required';
                      }
                      if (!_emailRegex.hasMatch(val.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _signupPasswordController,
                    obscureText: _obscureSignupPassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline, color: AppPalette.primary, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureSignupPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppPalette.primary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureSignupPassword = !_obscureSignupPassword),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.borderLight)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.borderLight)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.primary, width: 2)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Password is required';
                      }
                      if (val.trim().length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _signupConfirmPasswordController,
                    obscureText: _obscureSignupConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: const Icon(Icons.lock_reset, color: AppPalette.primary, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureSignupConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: AppPalette.primary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscureSignupConfirmPassword = !_obscureSignupConfirmPassword),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.borderLight)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.borderLight)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppPalette.primary, width: 2)),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (val != _signupPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  const Text('Styling Preference', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppPalette.textDark)),
                  const SizedBox(height: 2),
                  const Text('Used to personalize your hairstyle cuts between feminine and masculine.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  const SizedBox(height: 8),
                  Row(
                    children: ['Female', 'Male'].map((g) {
                      final isSel = _signupGender == g;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => _signupGender = g),
                          child: Container(
                            margin: EdgeInsets.only(right: g == 'Female' ? 8 : 0, left: g == 'Male' ? 8 : 0),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: isSel ? AppPalette.lavenderLight : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isSel ? AppPalette.primary : AppPalette.borderLight, width: isSel ? 2 : 1),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  g == 'Female' ? Icons.female : Icons.male,
                                  size: 18,
                                  color: isSel ? AppPalette.primary : Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  g,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: isSel ? AppPalette.primary : AppPalette.textDark,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _handleSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                    child: const Text('Create FaceCard Account', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
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

/// ===========================================================================
/// SCREEN 4: HOME DASHBOARD SCREEN
/// ===========================================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserPreferences>(
      valueListenable: AppStateManager.of(context).stateNotifier,
      builder: (context, userPrefs, child) {
        return Scaffold(
          backgroundColor: AppPalette.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                const FaceCardLogo(size: 32, showSparkle: false),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, ${userPrefs.userName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppPalette.primary)),
                    Text(
                      userPrefs.isGuest ? 'Guest Session' : 'Member Style Report',
                      style: const TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.person_outline, color: AppPalette.primary),
                tooltip: 'Profile & Settings',
                onPressed: () => Navigator.pushReplacementNamed(context, '/profile'),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Area Greeting Hero Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppPalette.borderLight),
                    boxShadow: [
                      BoxShadow(
                        color: AppPalette.primary.withOpacity(0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Find what suits you ✨',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.primary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Discover the colours, frames and hairstyles that complement your features.',
                        style: TextStyle(
                          color: AppPalette.textDark,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      if (userPrefs.currentAnalysis != null) ...[
                        const SizedBox(height: 14),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/results'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppPalette.lavenderLight,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppPalette.secondary.withOpacity(0.6)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.check_circle_outline, size: 14, color: AppPalette.primary),
                                const SizedBox(width: 6),
                                Text(
                                  'Active FaceCard: ${userPrefs.faceShape} • ${userPrefs.undertone}',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: AppPalette.primary,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(Icons.arrow_forward_ios, size: 10, color: AppPalette.primary),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Main CTA: ANALYZE MY FACE (Deep plum background, white text)
                ElevatedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/ai_analysis'),
                  icon: const Icon(Icons.auto_awesome, size: 20),
                  label: const Text(
                    'ANALYZE MY FACE',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      letterSpacing: 0.8,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppPalette.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 54),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 3,
                    shadowColor: AppPalette.primary.withOpacity(0.3),
                  ),
                ),

                const SizedBox(height: 10),

                // Secondary CTA: CHOOSE MANUALLY (Lavender border/background)
                OutlinedButton.icon(
                  onPressed: () => Navigator.pushNamed(context, '/manual_shape'),
                  icon: const Icon(Icons.tune_rounded, size: 20),
                  label: const Text(
                    'CHOOSE MANUALLY',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 0.6,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppPalette.lavenderLight,
                    foregroundColor: AppPalette.primary,
                    side: const BorderSide(color: AppPalette.secondary, width: 1.5),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                ),

                const SizedBox(height: 24),

                // Three Interactive Feature Cards
                const Text(
                  'EXPLORE YOUR ATTRIBUTES',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    color: AppPalette.primary,
                  ),
                ),
                const SizedBox(height: 12),

                // Card 1: FACE SHAPE
                _buildFeatureCard(
                  context: context,
                  title: 'FACE SHAPE',
                  description: 'Discover the shape and proportions of your face.',
                  emoji: '👤',
                  badge: 'Architecture',
                  onTap: () => Navigator.pushNamed(context, '/manual_shape'),
                ),

                const SizedBox(height: 10),

                // Card 2: UNDERTONE
                _buildFeatureCard(
                  context: context,
                  title: 'UNDERTONE',
                  description: 'Find whether your undertone is warm, cool or neutral.',
                  emoji: '✨',
                  badge: 'Radiance',
                  onTap: () => Navigator.pushNamed(context, '/manual_undertone'),
                ),

                const SizedBox(height: 10),

                // Card 3: YOUR STYLE
                _buildFeatureCard(
                  context: context,
                  title: 'YOUR STYLE',
                  description: 'Get personalized colours, frames and hairstyles.',
                  emoji: '👗',
                  badge: 'Wardrobe',
                  onTap: () => Navigator.pushNamed(context, '/results'),
                ),

                const SizedBox(height: 28),

                // Section: “How FaceCard works” (3-step stepper cards)
                Row(
                  children: const [
                    Icon(Icons.hub_outlined, size: 16, color: AppPalette.primary),
                    SizedBox(width: 6),
                    Text(
                      'HOW FACECARD WORKS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                        color: AppPalette.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Vertical connected stepper cards
                _buildStepperCard(
                  stepNumber: '1',
                  title: 'Upload or capture your photo',
                  detail: 'Take a direct front-facing selfie or upload an existing clear portrait photo.',
                  icon: Icons.camera_alt_outlined,
                  isLast: false,
                ),
                _buildStepperCard(
                  stepNumber: '2',
                  title: 'FaceCard analyzes your features',
                  detail: 'Automated geometric markers map your facial proportions, symmetry, and subsurface skin radiance.',
                  icon: Icons.biotech_outlined,
                  isLast: false,
                ),
                _buildStepperCard(
                  stepNumber: '3',
                  title: 'Receive your personalized style guide',
                  detail: 'Unlock tailor-made dress colour palettes, flattering glasses frames, and bespoke hairstyles.',
                  icon: Icons.workspace_premium_outlined,
                  isLast: true,
                ),

                const SizedBox(height: 18),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context, 0),
        );
      },
    );
  }

  static Widget _buildFeatureCard({
    required BuildContext context,
    required String title,
    required String description,
    required String emoji,
    required String badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPalette.borderLight),
          boxShadow: [
            BoxShadow(
              color: AppPalette.primary.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppPalette.lavenderLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                          letterSpacing: 0.6,
                          color: AppPalette.primary,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                        decoration: BoxDecoration(
                          color: AppPalette.secondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badge,
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppPalette.plumDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 11,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: AppPalette.primary),
          ],
        ),
      ),
    );
  }

  static Widget _buildStepperCard({
    required String stepNumber,
    required String title,
    required String detail,
    required IconData icon,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator with connector line
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppPalette.plumLight, AppPalette.primary],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.primary.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    stepNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: AppPalette.secondary.withOpacity(0.5),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          // Content Card
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppPalette.borderLight),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, size: 20, color: AppPalette.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                            color: AppPalette.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          detail,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 11,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
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

/// ===========================================================================
/// SCREEN 5: AI FACIAL ANALYSIS SCREEN
/// ===========================================================================
class AiAnalysisScreen extends StatelessWidget {
  const AiAnalysisScreen({Key? key}) : super(key: key);

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        if (context.mounted) {
          Navigator.pushNamed(context, '/processing', arguments: {
            'mode': 'ai',
            'source': source == ImageSource.camera ? 'camera' : 'gallery',
            'imageBytes': bytes,
            'fileName': pickedFile.name,
          });
        }
      }
    } catch (e) {
      debugPrint('Error accessing image/camera: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(source == ImageSource.camera
                ? 'Camera access denied or unavailable. Please grant camera permission in device settings.'
                : 'Gallery access denied or unavailable. Please grant photo permission in device settings.'),
            backgroundColor: AppPalette.primary,
            action: SnackBarAction(
              label: 'Proceed',
              textColor: Colors.white,
              onPressed: () {
                Navigator.pushNamed(context, '/processing', arguments: {
                  'mode': 'ai',
                  'source': source == ImageSource.camera ? 'camera' : 'gallery',
                });
              },
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppPalette.primary),
          onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
        ),
        title: const Text('Biometric Scan', style: TextStyle(fontFamily: 'Playfair Display', color: AppPalette.primary, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('AI Biometric Scan', style: TextStyle(fontFamily: 'Playfair Display', fontSize: 22, fontWeight: FontWeight.bold, color: AppPalette.primary)),
                  const SizedBox(height: 6),
                  const Text('Select your preferred photo source to begin analysis.', style: TextStyle(color: Colors.grey, fontSize: 12)),
                  const SizedBox(height: 24),

                  // Simulation target frame
                  Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppPalette.borderLight),
                      boxShadow: [
                        BoxShadow(color: AppPalette.primary.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 130,
                        height: 165,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppPalette.secondary, width: 2, style: BorderStyle.solid),
                        ),
                        child: const Icon(Icons.person_outline, size: 64, color: AppPalette.secondary),
                      ),
                    ),
                  ),
                ],
              ),

              // Two Clear Options: Take Photo & Upload from Gallery
              Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(context, ImageSource.camera),
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () => _pickImage(context, ImageSource.gallery),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Upload from Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppPalette.primary,
                      side: const BorderSide(color: AppPalette.borderLight, width: 1.5),
                      backgroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => Navigator.pushReplacementNamed(context, '/manual_shape'),
                    child: const Text('Prefer manual selection?', style: TextStyle(color: AppPalette.primary, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNav(context, 1),
    );
  }
}

/// ===========================================================================
/// SCREEN 6: MANUAL STEP 1 - CHOOSE YOUR FACE SHAPE
/// ===========================================================================
class ManualShapeScreen extends StatefulWidget {
  const ManualShapeScreen({Key? key}) : super(key: key);

  @override
  State<ManualShapeScreen> createState() => _ManualShapeScreenState();
}

class _ManualShapeScreenState extends State<ManualShapeScreen> {
  final List<Map<String, String>> _shapes = const [
    {
      'id': 'Oval',
      'name': 'Oval',
      'desc': 'Balanced proportions with softly curved, tapering jawline.',
    },
    {
      'id': 'Round',
      'name': 'Round',
      'desc': 'Equal length and width with soft, curved cheek contours.',
    },
    {
      'id': 'Square',
      'name': 'Square',
      'desc': 'Strong angular jawline aligned with a broad, flat forehead.',
    },
    {
      'id': 'Heart',
      'name': 'Heart',
      'desc': 'Wider forehead tapering elegantly down to a slender chin.',
    },
    {
      'id': 'Diamond',
      'name': 'Diamond',
      'desc': 'Dramatic high cheekbones with narrower hairline and chin.',
    },
    {
      'id': 'Oblong',
      'name': 'Oblong / Rectangle',
      'desc': 'Elongated vertical silhouette with straight cheek contours.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final notifier = AppStateManager.of(context).stateNotifier;
    final selectedShape = notifier.value.faceShape;

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppPalette.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Step 1 of 2: Face Shape', style: TextStyle(color: AppPalette.primary, fontSize: 14, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose your face shape',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select the visual silhouette that best matches your facial contour.',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 16),

              Expanded(
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.88,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                  ),
                  itemCount: _shapes.length,
                  itemBuilder: (context, index) {
                    final item = _shapes[index];
                    final isSelected = item['id'] == selectedShape || (item['id'] == 'Oblong' && (selectedShape == 'Oblong' || selectedShape == 'Oblong / Rectangle'));

                    return GestureDetector(
                      onTap: () {
                        notifier.value = notifier.value.copyWith(faceShape: item['id']!);
                        setState(() {});
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          // Visually highlight selected card using FaceCard primary color border/background
                          color: isSelected ? const Color(0xFFF7F2FD) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? AppPalette.primary : AppPalette.borderLight,
                            width: isSelected ? 2.4 : 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppPalette.primary.withOpacity(0.18),
                                    blurRadius: 14,
                                    offset: const Offset(0, 4),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Visual illustrated selection placeholder
                            Container(
                              height: 64,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: isSelected ? AppPalette.lavenderLight.withOpacity(0.7) : AppPalette.background,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Center(
                                child: CustomPaint(
                                  size: const Size(42, 50),
                                  painter: _FaceSilhouettePainter(
                                    shape: item['id']!,
                                    strokeColor: isSelected ? AppPalette.primary : AppPalette.plumLight.withOpacity(0.7),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Name
                            Text(
                              item['name']!,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: isSelected ? AppPalette.primary : AppPalette.textDark,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),

                            // 1-line description
                            Expanded(
                              child: Text(
                                item['desc']!,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: isSelected ? AppPalette.textDark.withOpacity(0.85) : Colors.black54,
                                  height: 1.25,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Selection highlight indicator
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isSelected ? AppPalette.primary : Colors.transparent,
                                  border: Border.all(
                                    color: isSelected ? AppPalette.primary : AppPalette.borderLight,
                                    width: 1.5,
                                  ),
                                ),
                                child: isSelected
                                    ? const Icon(Icons.check, size: 13, color: Colors.white)
                                    : null,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Step 1 Continue Action
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/manual_undertone'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text('Continue to Undertone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 16),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Illustrated silhouette contour painter for face shape cards
class _FaceSilhouettePainter extends CustomPainter {
  final String shape;
  final Color strokeColor;

  _FaceSilhouettePainter({required this.shape, required this.strokeColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = strokeColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final w = size.width;
    final h = size.height;
    final path = Path();

    switch (shape) {
      case 'Oval':
        path.addOval(Rect.fromLTWH(w * 0.12, h * 0.08, w * 0.76, h * 0.84));
        break;
      case 'Round':
        path.addOval(Rect.fromLTWH(w * 0.08, h * 0.12, w * 0.84, h * 0.76));
        break;
      case 'Square':
        path.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.14, h * 0.12, w * 0.72, h * 0.76),
          const Radius.circular(8),
        ));
        break;
      case 'Heart':
        path.moveTo(w * 0.5, h * 0.88); // chin point
        path.cubicTo(w * 0.22, h * 0.70, w * 0.08, h * 0.38, w * 0.20, h * 0.16);
        path.cubicTo(w * 0.34, h * 0.04, w * 0.46, h * 0.16, w * 0.5, h * 0.26);
        path.cubicTo(w * 0.54, h * 0.16, w * 0.66, h * 0.04, w * 0.80, h * 0.16);
        path.cubicTo(w * 0.92, h * 0.38, w * 0.78, h * 0.70, w * 0.5, h * 0.88);
        break;
      case 'Diamond':
        path.moveTo(w * 0.5, h * 0.08); // narrow forehead
        path.lineTo(w * 0.88, h * 0.46); // wide cheekbone right
        path.lineTo(w * 0.5, h * 0.92); // narrow chin
        path.lineTo(w * 0.12, h * 0.46); // wide cheekbone left
        path.close();
        break;
      case 'Oblong':
      default:
        path.addRRect(RRect.fromRectAndRadius(
          Rect.fromLTWH(w * 0.18, h * 0.06, w * 0.64, h * 0.88),
          const Radius.circular(16),
        ));
        break;
    }

    canvas.drawPath(path, paint);

    // Subtle eye / contour baseline markers inside illustration placeholder
    final markerPaint = Paint()
      ..color = strokeColor.withOpacity(0.45)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    canvas.drawLine(Offset(w * 0.34, h * 0.44), Offset(w * 0.42, h * 0.44), markerPaint);
    canvas.drawLine(Offset(w * 0.58, h * 0.44), Offset(w * 0.66, h * 0.44), markerPaint);
    canvas.drawLine(Offset(w * 0.45, h * 0.62), Offset(w * 0.55, h * 0.62), markerPaint);
  }

  @override
  bool shouldRepaint(covariant _FaceSilhouettePainter oldDelegate) {
    return oldDelegate.shape != shape || oldDelegate.strokeColor != strokeColor;
  }
}

/// ===========================================================================
/// SCREEN 7: MANUAL STEP 2 - CHOOSE YOUR UNDERTONE
/// ===========================================================================
class ManualUndertoneScreen extends StatefulWidget {
  const ManualUndertoneScreen({Key? key}) : super(key: key);

  @override
  State<ManualUndertoneScreen> createState() => _ManualUndertoneScreenState();
}

class _ManualUndertoneScreenState extends State<ManualUndertoneScreen> {
  final List<Map<String, dynamic>> _undertones = const [
    {
      'id': 'Warm',
      'name': 'WARM',
      'quote': '“Your skin tends to suit golden, peachy and earthy tones.”',
      'badge': 'Warm Radiance',
      'colors': [Color(0xFFFFCBA4), Color(0xFFD4A017), Color(0xFFC85A32), Color(0xFF556B2F)],
    },
    {
      'id': 'Cool',
      'name': 'COOL',
      'quote': '“Your skin tends to suit blue, rosy and jewel tones.”',
      'badge': 'Cool Radiance',
      'colors': [Color(0xFFF3A9BC), Color(0xFFB0E0E6), Color(0xFF0F52BA), Color(0xFF5A2A83)],
    },
    {
      'id': 'Neutral',
      'name': 'NEUTRAL',
      'quote': '“You can often wear a balance of warm and cool tones.”',
      'badge': 'Balanced Harmony',
      'colors': [Color(0xFFDCAE96), Color(0xFF87A987), Color(0xFF800020), Color(0xFF386668)],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final notifier = AppStateManager.of(context).stateNotifier;
    final selectedTone = notifier.value.undertone;

    return Scaffold(
      backgroundColor: AppPalette.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppPalette.primary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Step 2 of 2: Undertone', style: TextStyle(color: AppPalette.primary, fontSize: 14, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Choose your undertone',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.primary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Select the undertone palette that harmonizes with your skin’s base radiance.',
                style: TextStyle(color: Colors.black54, fontSize: 12),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: ListView.builder(
                  itemCount: _undertones.length,
                  itemBuilder: (context, index) {
                    final item = _undertones[index];
                    final isSelected = (item['id'] as String).toLowerCase() == selectedTone.toLowerCase();

                    return GestureDetector(
                      onTap: () {
                        notifier.value = notifier.value.copyWith(undertone: item['id'] as String);
                        setState(() {});
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          // Visually highlight selected card using FaceCard primary color border/background
                          color: isSelected ? const Color(0xFFF7F2FD) : Colors.white,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: isSelected ? AppPalette.primary : AppPalette.borderLight,
                            width: isSelected ? 2.5 : 1.2,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: AppPalette.primary.withOpacity(0.18),
                                    blurRadius: 16,
                                    offset: const Offset(0, 5),
                                  ),
                                ]
                              : [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      item['name'] as String,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        letterSpacing: 0.6,
                                        color: isSelected ? AppPalette.primary : AppPalette.textDark,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: isSelected ? AppPalette.secondary.withOpacity(0.4) : AppPalette.background,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        item['badge'] as String,
                                        style: TextStyle(
                                          fontSize: 9,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected ? AppPalette.primary : Colors.black54,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected ? AppPalette.primary : Colors.transparent,
                                    border: Border.all(
                                      color: isSelected ? AppPalette.primary : AppPalette.borderLight,
                                      width: 1.5,
                                    ),
                                  ),
                                  child: isSelected
                                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                                      : null,
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Exact quote from specifications
                            Text(
                              item['quote'] as String,
                              style: TextStyle(
                                color: isSelected ? AppPalette.primary.withOpacity(0.9) : Colors.black87,
                                fontSize: 12,
                                height: 1.35,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 14),

                            // Color swatches preview
                            Row(
                              children: [
                                Text(
                                  'Harmonious hues:',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: isSelected ? AppPalette.primary.withOpacity(0.7) : Colors.black45,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ...(item['colors'] as List<Color>).map((c) => Container(
                                  margin: const EdgeInsets.only(right: 6),
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: c,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: Colors.black12, width: 1),
                                  ),
                                )).toList(),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Bottom action: GET MY RECOMMENDATIONS
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/processing', arguments: {
                    'mode': 'manual',
                    'face_shape': notifier.value.faceShape,
                    'undertone': notifier.value.undertone,
                  });
                },
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text(
                  'GET MY RECOMMENDATIONS',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.primary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  elevation: 3,
                  shadowColor: AppPalette.primary.withOpacity(0.35),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// SCREEN 8: PROCESSING / SCANNING SCREEN (Invokes Flask REST API / Engine)
/// ===========================================================================
/// SCREEN 7: ANALYSIS LOADING SCREEN (PROCESSING)
/// ===========================================================================
class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({Key? key}) : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> with SingleTickerProviderStateMixin {
  int _step = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _scaleAnimation;

  final List<String> _stages = const [
    'Detecting your face…',
    'Reading facial proportions…',
    'Checking undertone…',
    'Preparing your FaceCard…',
  ];

  final List<String> _stageSubtitles = const [
    'Aligning facial contour in balanced lighting…',
    'Evaluating shape ratios and aesthetic proportions…',
    'Observing warm, cool, and neutral harmony cues…',
    'Assembling your personalized style palette & frames…',
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1700),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.97, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _executeAnalysis();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _executeAnalysis() async {
    final notifier = AppStateManager.of(context).stateNotifier;
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final mode = args['mode'] as String? ?? 'manual';
    final Uint8List? imageBytes = args['imageBytes'] as Uint8List?;
    final String? fileName = args['fileName'] as String?;

    // Start background API call concurrently
    final apiFuture = FaceCardApiService.analyze(
      mode: mode,
      faceShape: notifier.value.faceShape,
      undertone: notifier.value.undertone,
      gender: notifier.value.gender,
      imageBytes: imageBytes,
      fileName: fileName,
    );

    // Step 0: "Detecting your face…"
    await Future.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;
    setState(() => _step = 1);

    // Step 1: "Reading facial proportions…"
    await Future.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;
    setState(() => _step = 2);

    // Step 2: "Checking undertone…"
    await Future.delayed(const Duration(milliseconds: 950));
    if (!mounted) return;
    setState(() => _step = 3);

    // Step 3: "Preparing your FaceCard…"
    final response = await apiFuture;
    await Future.delayed(const Duration(milliseconds: 850));

    if (mounted) {
      notifier.value = notifier.value.copyWith(
        faceShape: response.faceShape,
        undertone: response.undertone,
        currentAnalysis: response,
      );
      Navigator.pushReplacementNamed(context, '/results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppPalette.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Illustrated Face/Card element with subtle pulsing rings (no generic spinner)
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    final pulseValue = _pulseAnimation.value;
                    return SizedBox(
                      width: 220,
                      height: 220,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer expanding aura glow
                          Container(
                            width: 170 + (42 * pulseValue),
                            height: 170 + (42 * pulseValue),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppPalette.secondary.withOpacity(0.14 * (1.0 - pulseValue * 0.4)),
                            ),
                          ),
                          // Intermediate subtle pulse ring
                          Container(
                            width: 144 + (24 * pulseValue),
                            height: 144 + (24 * pulseValue),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppPalette.plumLight.withOpacity(0.24 * (1.0 - pulseValue * 0.3)),
                                width: 2,
                              ),
                            ),
                          ),
                          // Breathing illustrated face/card element
                          ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              width: 132,
                              height: 132,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(28),
                                border: Border.all(
                                  color: AppPalette.borderLight,
                                  width: 1.5,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppPalette.primary.withOpacity(0.08 + (0.07 * pulseValue)),
                                    blurRadius: 22,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: FaceCardLogo(size: 90, showSparkle: true),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 36),

                // Sequential text updates with smooth crossfade
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 350),
                  transitionBuilder: (Widget child, Animation<double> animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.0, 0.15),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: Column(
                    key: ValueKey<int>(_step),
                    children: [
                      Text(
                        _stages[_step],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 21,
                          fontWeight: FontWeight.bold,
                          color: AppPalette.primary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _stageSubtitles[_step],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // 4-Step progression indicator pills (clean, aesthetic, no generic spinner)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(4, (index) {
                    final isCompleted = index < _step;
                    final isCurrent = index == _step;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: isCurrent ? 26 : 9,
                      height: 6,
                      decoration: BoxDecoration(
                        color: (isCompleted || isCurrent)
                            ? AppPalette.primary
                            : AppPalette.borderLight,
                        borderRadius: BorderRadius.circular(3),
                        boxShadow: isCurrent
                            ? [
                                BoxShadow(
                                  color: AppPalette.primary.withOpacity(0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 1),
                                ),
                              ]
                            : null,
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 16),

                // Honest aesthetic note (no false scientific claims)
                Text(
                  'Facial proportions & undertone harmony',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.6,
                    color: AppPalette.plumLight.withOpacity(0.65),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// SCREEN 9: RESULTS SCREEN (Personalized Style Report)
/// ===========================================================================
class ResultsScreen extends StatefulWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedColorCategory = 'All';
  String _selectedHairstyleLength = 'All';
  bool _glassesGridMode = false;
  String? _previewGender;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _showColorDetailModal(
    BuildContext context,
    DressColor initialColor,
    String undertone,
    List<DressColor> fullPalette,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        DressColor activeColor = initialColor;
        return StatefulBuilder(
          builder: (context, setModalState) {
            // Find neighbors in current undertone palette (up to 4 swatches)
            final currentIndex = fullPalette.indexWhere((c) => c.name == activeColor.name);
            final neighbors = <DressColor>[];
            for (int offset = -2; offset <= 2; offset++) {
              if (offset == 0) continue;
              final idx = currentIndex + offset;
              if (idx >= 0 && idx < fullPalette.length) {
                neighbors.add(fullPalette[idx]);
              }
            }
            if (neighbors.isEmpty && fullPalette.isNotEmpty) {
              neighbors.addAll(fullPalette.take(4));
            }

            final isDarkColor = activeColor.color.computeLuminance() < 0.45;

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$undertone Undertone Palette',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: Colors.black45,
                              ),
                            ),
                            const Text(
                              'Color Swatch Detail',
                              style: TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppPalette.primary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Enlarged Color View
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: activeColor.color,
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: Colors.black12, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: activeColor.color.withOpacity(0.35),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            top: 14,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: isDarkColor ? Colors.white.withOpacity(0.2) : Colors.black.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                activeColor.category,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: isDarkColor ? Colors.white : Colors.black87,
                                ),
                              ),
                            ),
                          ),
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  activeColor.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: 'Playfair Display',
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: isDarkColor ? Colors.white : Colors.black87,
                                    shadows: [
                                      Shadow(
                                        color: isDarkColor ? Colors.black45 : Colors.white70,
                                        blurRadius: 4,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  activeColor.hex,
                                  style: TextStyle(
                                    fontSize: 13,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDarkColor ? Colors.white70 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    // Action / Copy Row
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: activeColor.hex));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Copied ${activeColor.name} (${activeColor.hex}) to clipboard!'),
                                  backgroundColor: AppPalette.primary,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy_rounded, size: 16, color: AppPalette.primary),
                            label: const Text('Copy Hex Code', style: TextStyle(color: AppPalette.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppPalette.primary, width: 1.2),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // "Try Similar Shades" Section
                    const Text(
                      'TRY SIMILAR SHADES',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.0,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: neighbors.map((neighbor) {
                        return Expanded(
                          child: InkWell(
                            onTap: () {
                              setModalState(() {
                                activeColor = neighbor;
                              });
                            },
                            borderRadius: BorderRadius.circular(14),
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF7F2FD),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: activeColor.name == neighbor.name ? AppPalette.primary : Colors.transparent,
                                  width: 1.5,
                                ),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: neighbor.color,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.black12, width: 1.2),
                                      boxShadow: [
                                        BoxShadow(
                                          color: neighbor.color.withOpacity(0.3),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    neighbor.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppPalette.textDark),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _saveReport() {
    final notifier = AppStateManager.of(context).stateNotifier;
    final currentReports = List<SavedReport>.from(notifier.value.savedReports);
    final newReport = SavedReport(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: 'Today, Just Now',
      faceShape: notifier.value.faceShape,
      undertone: notifier.value.undertone,
    );
    currentReports.insert(0, newReport);
    notifier.value = notifier.value.copyWith(savedReports: currentReports);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Personalized Style Report saved to Profile!'), backgroundColor: AppPalette.primary),
    );
  }

  void _openFaceShapeQuickEdit(BuildContext context, UserPreferences userPrefs) {
    final notifier = AppStateManager.of(context).stateNotifier;
    final activeGender = _previewGender ?? userPrefs.gender;
    final shapes = const [
      {'id': 'Oval', 'name': 'Oval', 'desc': 'Balanced proportions with softly curved jawline.'},
      {'id': 'Round', 'name': 'Round', 'desc': 'Equal length & width with soft curved cheek contours.'},
      {'id': 'Square', 'name': 'Square', 'desc': 'Strong angular jawline aligned with a broad forehead.'},
      {'id': 'Heart', 'name': 'Heart', 'desc': 'Wider forehead tapering down to a slender chin.'},
      {'id': 'Diamond', 'name': 'Diamond', 'desc': 'Dramatic high cheekbones with narrow forehead & chin.'},
      {'id': 'Oblong', 'name': 'Oblong / Rectangle', 'desc': 'Elongated vertical silhouette with straight cheek lines.'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick Edit: Face Shape',
                      style: TextStyle(fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.bold, color: AppPalette.primary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Text('Select your corrected face shape to instantly refresh frames and hairstyles.', style: TextStyle(fontSize: 11, color: Colors.black54)),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: shapes.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final s = shapes[i];
                      final isSelected = s['id'] == userPrefs.faceShape;
                      return ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected ? AppPalette.primary : AppPalette.borderLight,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        tileColor: isSelected ? const Color(0xFFF7F2FD) : Colors.white,
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? AppPalette.primary : AppPalette.background,
                          foregroundColor: isSelected ? Colors.white : AppPalette.primary,
                          child: Text(s['name']![0], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        title: Text(s['name']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? AppPalette.primary : AppPalette.textDark)),
                        subtitle: Text(s['desc']!, style: const TextStyle(fontSize: 10, color: Colors.black54)),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: AppPalette.primary, size: 20) : null,
                        onTap: () {
                          final newAnalysis = FaceCardApiService.generateFallbackAnalysis(
                            faceShape: s['id']!,
                            undertone: userPrefs.undertone,
                            gender: activeGender,
                          );
                          notifier.value = notifier.value.copyWith(
                            faceShape: s['id']!,
                            currentAnalysis: newAnalysis,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Updated face shape to ${s['name']!}. Recommendations refreshed!'),
                              backgroundColor: AppPalette.primary,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openUndertoneQuickEdit(BuildContext context, UserPreferences userPrefs) {
    final notifier = AppStateManager.of(context).stateNotifier;
    final activeGender = _previewGender ?? userPrefs.gender;
    final tones = const [
      {
        'id': 'Warm',
        'name': 'WARM',
        'quote': '“Your skin tends to suit golden, peachy and earthy tones.”',
      },
      {
        'id': 'Cool',
        'name': 'COOL',
        'quote': '“Your skin tends to suit blue, rosy and jewel tones.”',
      },
      {
        'id': 'Neutral',
        'name': 'NEUTRAL',
        'quote': '“You can often wear a balance of warm and cool tones.”',
      },
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quick Edit: Undertone',
                      style: TextStyle(fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.bold, color: AppPalette.primary),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const Text('Select your corrected undertone to instantly refresh all 35 dress colours.', style: TextStyle(fontSize: 11, color: Colors.black54)),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: tones.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final t = tones[i];
                      final isSelected = t['id']!.toLowerCase() == userPrefs.undertone.toLowerCase();
                      return ListTile(
                        dense: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: isSelected ? AppPalette.primary : AppPalette.borderLight,
                            width: isSelected ? 2.0 : 1.0,
                          ),
                        ),
                        tileColor: isSelected ? const Color(0xFFF7F2FD) : Colors.white,
                        leading: CircleAvatar(
                          backgroundColor: isSelected ? AppPalette.primary : AppPalette.background,
                          foregroundColor: isSelected ? Colors.white : AppPalette.primary,
                          child: const Icon(Icons.palette_outlined, size: 16),
                        ),
                        title: Text(t['name']!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: isSelected ? AppPalette.primary : AppPalette.textDark)),
                        subtitle: Text(t['quote']!, style: const TextStyle(fontSize: 10, fontStyle: FontStyle.italic, color: Colors.black54)),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: AppPalette.primary, size: 20) : null,
                        onTap: () {
                          final newAnalysis = FaceCardApiService.generateFallbackAnalysis(
                            faceShape: userPrefs.faceShape,
                            undertone: t['id']!,
                            gender: activeGender,
                          );
                          notifier.value = notifier.value.copyWith(
                            undertone: t['id']!,
                            currentAnalysis: newAnalysis,
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Updated undertone to ${t['name']!}. Color palette refreshed!'),
                              backgroundColor: AppPalette.primary,
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserPreferences>(
      valueListenable: AppStateManager.of(context).stateNotifier,
      builder: (context, userPrefs, child) {
        final activeGender = _previewGender ?? userPrefs.gender;

        final analysis = userPrefs.currentAnalysis ??
            FaceCardApiService.generateFallbackAnalysis(
              faceShape: userPrefs.faceShape,
              undertone: userPrefs.undertone,
              gender: activeGender,
            );

        final colors = ColorRepository.palettes[userPrefs.undertone] ?? ColorRepository.palettes['Cool']!;
        final frames = analysis.recommendations.glasses.isNotEmpty
            ? analysis.recommendations.glasses
            : (FramesRepository.frames[userPrefs.faceShape] ?? FramesRepository.frames['Oval']!)
                .map((f) => GlassesRecommendation(name: f.name, reason: f.desc))
                .toList();

        // Retrieve gender-tailored hairstyles
        final hair = HairstylesRepository.getHairstyles(userPrefs.faceShape, activeGender)
            .map((h) => HairstyleRecommendation(name: h.name, length: h.length, reason: h.desc))
            .toList();

        final filteredColors = _selectedColorCategory == 'All'
            ? colors
            : colors.where((c) => c.category == _selectedColorCategory).toList();

        return Scaffold(
          backgroundColor: AppPalette.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppPalette.primary),
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
            title: const Text('Your FaceCard', style: TextStyle(fontFamily: 'Playfair Display', color: AppPalette.primary, fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.bookmark_add_outlined, color: AppPalette.primary),
                tooltip: 'Save Report',
                onPressed: _saveReport,
              ),
              IconButton(
                icon: const Icon(Icons.share_outlined, color: AppPalette.primary),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Report ready for export or share.')),
                  );
                },
              ),
            ],
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Header: Heading & Subheading
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Analysis Complete ✨',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppPalette.primary,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Your personalized recommendations are ready.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Result-summary card ("YOUR FACECARD") with Visual Chips & Quick Edit Section
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: AppPalette.borderLight),
                  boxShadow: [
                    BoxShadow(color: AppPalette.primary.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.style_outlined, size: 16, color: AppPalette.primary),
                            SizedBox(width: 6),
                            Text(
                              'YOUR FACECARD',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                letterSpacing: 1.0,
                                color: AppPalette.primary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppPalette.lavenderLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text('Active Profile', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppPalette.primary)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Visual Chips for Face Shape & Undertone
                    Row(
                      children: [
                        // Face Shape Chip
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F2FD),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppPalette.primary.withOpacity(0.25)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppPalette.primary.withOpacity(0.2)),
                                  ),
                                  child: const Icon(Icons.face_retouching_natural_rounded, size: 18, color: AppPalette.primary),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('FACE SHAPE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black45)),
                                      Text(
                                        userPrefs.faceShape,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppPalette.primary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Undertone Chip
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F2FD),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppPalette.primary.withOpacity(0.25)),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: AppPalette.primary.withOpacity(0.2)),
                                  ),
                                  child: const Icon(Icons.palette_outlined, size: 18, color: AppPalette.primary),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text('UNDERTONE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.black45)),
                                      Text(
                                        userPrefs.undertone,
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppPalette.primary),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // "Not quite right?" Quick Edit section
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppPalette.background,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppPalette.borderLight),
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'Not quite right?',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const Spacer(),
                          OutlinedButton(
                            onPressed: () => _openFaceShapeQuickEdit(context, userPrefs),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppPalette.primary,
                              side: const BorderSide(color: AppPalette.primary, width: 1.2),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('EDIT FACE SHAPE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 6),
                          OutlinedButton(
                            onPressed: () => _openUndertoneQuickEdit(context, userPrefs),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppPalette.primary,
                              side: const BorderSide(color: AppPalette.primary, width: 1.2),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('EDIT UNDERTONE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tab Selector (Colours | Glasses | Hairstyles)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorColor: AppPalette.primary,
                  indicatorWeight: 3,
                  labelColor: AppPalette.primary,
                  unselectedLabelColor: Colors.grey,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  tabs: const [
                    Tab(text: 'DRESS COLOURS'),
                    Tab(text: 'GLASSES'),
                    Tab(text: 'HAIRSTYLES'),
                  ],
                ),
              ),

              // Tab Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // Tab 1: Dress Colours (Grid + Filter Pills)
                    // Tab 1: Dress Colours (Grid + Filter Pills + Swatch Tap Detail)
                    Column(
                      children: [
                        // Filter Pills: All, Neutrals, Everyday, Soft/Pastels, Brights, Jewel/Rich, Deep Shades
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          child: Row(
                            children: ['All', 'Neutrals', 'Everyday', 'Soft/Pastels', 'Brights', 'Jewel/Rich', 'Deep Shades'].map((cat) {
                              final isSel = _selectedColorCategory == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(cat, style: TextStyle(fontSize: 11, color: isSel ? Colors.white : AppPalette.textDark, fontWeight: FontWeight.bold)),
                                  selected: isSel,
                                  selectedColor: AppPalette.primary,
                                  backgroundColor: Colors.white,
                                  onSelected: (val) => setState(() => _selectedColorCategory = cat),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // "Why It Suits You" Contextual Callout
                        WhyItSuitsYouCard(
                          text: analysis.explanations.colourWhyItSuitsYou.isNotEmpty
                              ? analysis.explanations.colourWhyItSuitsYou
                              : FaceCardApiService.getColourWhyItSuitsYou(userPrefs.undertone),
                        ),
                        // Colours Grid (Large visual swatches + Tap Interaction)
                        Expanded(
                          child: GridView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.15,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filteredColors.length,
                            itemBuilder: (context, index) {
                              final color = filteredColors[index];
                              return Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () => _showColorDetailModal(context, color, userPrefs.undertone, colors),
                                  borderRadius: BorderRadius.circular(18),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: AppPalette.borderLight),
                                      boxShadow: [
                                        BoxShadow(color: AppPalette.primary.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 3)),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Container(
                                                width: 36,
                                                height: 36,
                                                decoration: BoxDecoration(
                                                  color: color.color,
                                                  shape: BoxShape.circle,
                                                  border: Border.all(color: Colors.black12, width: 1.5),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: color.color.withOpacity(0.35),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: AppPalette.lavenderLight,
                                                  borderRadius: BorderRadius.circular(6),
                                                ),
                                                child: Text(color.category, style: const TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: AppPalette.primary)),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                color.name,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppPalette.textDark),
                                              ),
                                              const SizedBox(height: 2),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(color.hex, style: const TextStyle(color: Colors.grey, fontSize: 10, letterSpacing: 0.5)),
                                                  const Icon(Icons.touch_app_outlined, size: 12, color: Colors.black26),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),

                    // Tab 2: Glasses (Horizontally Scrollable Carousel or Responsive Grid)
                    Column(
                      children: [
                        WhyItSuitsYouCard(
                          text: analysis.explanations.glassesWhyItSuitsYou.isNotEmpty
                              ? analysis.explanations.glassesWhyItSuitsYou
                              : FaceCardApiService.getGlassesWhyItSuitsYou(userPrefs.faceShape),
                        ),
                        // Layout Mode Selector Bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${frames.length} Recommended Styles for ${userPrefs.faceShape}',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
                              ),
                              Row(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.view_carousel_outlined,
                                      size: 20,
                                      color: !_glassesGridMode ? AppPalette.primary : Colors.grey,
                                    ),
                                    tooltip: 'Carousel View',
                                    onPressed: () => setState(() => _glassesGridMode = false),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.grid_view_outlined,
                                      size: 20,
                                      color: _glassesGridMode ? AppPalette.primary : Colors.grey,
                                    ),
                                    tooltip: 'Grid View',
                                    onPressed: () => setState(() => _glassesGridMode = true),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        // Horizontally scrollable carousel or responsive grid
                        Expanded(
                          child: !_glassesGridMode
                              ? SizedBox(
                                  height: 280,
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    itemCount: frames.length,
                                    itemBuilder: (context, index) {
                                      final f = frames[index];
                                      return Container(
                                        width: 240,
                                        margin: const EdgeInsets.only(right: 14),
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(22),
                                          border: Border.all(color: AppPalette.borderLight),
                                          boxShadow: [
                                            BoxShadow(color: AppPalette.primary.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                                          ],
                                        ),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Center(
                                              child: Container(
                                                width: 80,
                                                height: 80,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF7F2FD),
                                                  borderRadius: BorderRadius.circular(20),
                                                  border: Border.all(color: AppPalette.primary.withOpacity(0.15)),
                                                ),
                                                child: const Center(
                                                  child: Text('👓', style: TextStyle(fontSize: 36)),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 14),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                              decoration: BoxDecoration(
                                                color: AppPalette.lavenderLight,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: const Text('FRAME STYLE', style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppPalette.primary)),
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              f.name,
                                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppPalette.textDark),
                                            ),
                                            const SizedBox(height: 6),
                                            Expanded(
                                              child: Text(
                                                f.reason,
                                                style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.35),
                                                overflow: TextOverflow.fade,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.all(16),
                                  itemCount: frames.length,
                                  itemBuilder: (context, index) {
                                    final f = frames[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 12),
                                      padding: const EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(18),
                                        border: Border.all(color: AppPalette.borderLight),
                                      ),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const StyleAssetPlaceholder(icon: Icons.visibility_outlined, emoji: '👓', size: 52),
                                          const SizedBox(width: 14),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(f.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppPalette.textDark)),
                                                const SizedBox(height: 4),
                                                Text(f.reason, style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.3)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),

                    // Tab 3: Hairstyles with Gender Personalization & Length Filter
                    Column(
                      children: [
                        // Gender Filter Control Bar
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppPalette.borderLight),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.style_outlined, size: 14, color: AppPalette.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Silhouette: $activeGender Cuts',
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppPalette.primary),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Tailored to your face geometry',
                                    style: TextStyle(color: Colors.grey, fontSize: 10),
                                  ),
                                ],
                              ),
                              // Gender Segmented Switch
                              Container(
                                decoration: BoxDecoration(
                                  color: AppPalette.background,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppPalette.borderLight),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: ['Female', 'Male'].map((g) {
                                    final isSel = activeGender == g;
                                    return GestureDetector(
                                      onTap: () => setState(() => _previewGender = g),
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: isSel ? AppPalette.primary : Colors.transparent,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Row(
                                          children: [
                                            Text(g == 'Female' ? '👩' : '👨', style: const TextStyle(fontSize: 11)),
                                            const SizedBox(width: 4),
                                            Text(
                                              g,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.bold,
                                                color: isSel ? Colors.white : AppPalette.textDark,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Hairstyle Length Filter Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Row(
                            children: ['All', 'Short', 'Medium', 'Long'].map((len) {
                              final isSel = _selectedHairstyleLength == len;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: ChoiceChip(
                                  label: Text(
                                    len == 'All' ? 'All Lengths' : '$len Length',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isSel ? Colors.white : AppPalette.textDark,
                                    ),
                                  ),
                                  selected: isSel,
                                  selectedColor: AppPalette.primary,
                                  backgroundColor: Colors.white,
                                  onSelected: (val) => setState(() => _selectedHairstyleLength = len),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        // "Why It Suits You" Contextual Callout
                        WhyItSuitsYouCard(
                          text: analysis.explanations.hairstyleWhyItSuitsYou.isNotEmpty
                              ? analysis.explanations.hairstyleWhyItSuitsYou
                              : FaceCardApiService.getHairstyleWhyItSuitsYou(userPrefs.faceShape),
                        ),
                        // Hairstyles List (Filtered by length)
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final filteredHair = _selectedHairstyleLength == 'All'
                                  ? hair
                                  : hair.where((h) => h.length.toLowerCase() == _selectedHairstyleLength.toLowerCase()).toList();

                              if (filteredHair.isEmpty) {
                                return Center(
                                  child: Text('No hairstyles found for $_selectedHairstyleLength length.', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: filteredHair.length,
                                itemBuilder: (context, index) {
                                  final h = filteredHair[index];
                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 12),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(18),
                                      border: Border.all(color: AppPalette.borderLight),
                                      boxShadow: [
                                        BoxShadow(color: AppPalette.primary.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
                                      ],
                                    ),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        StyleAssetPlaceholder(
                                          icon: Icons.face_retouching_natural,
                                          emoji: activeGender == 'Male' ? '💈' : '💇‍♀️',
                                          size: 52,
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Text(h.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppPalette.textDark)),
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: AppPalette.lavenderLight,
                                                      borderRadius: BorderRadius.circular(6),
                                                    ),
                                                    child: Text(h.length, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppPalette.primary)),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(h.reason, style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.3)),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          bottomNavigationBar: _buildBottomNav(context, 2),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

/// ===========================================================================
/// SCREEN 10: PROFILE & HISTORY SCREEN
/// ===========================================================================
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserPreferences>(
      valueListenable: AppStateManager.of(context).stateNotifier,
      builder: (context, userPrefs, child) {
        return Scaffold(
          backgroundColor: AppPalette.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: AppPalette.primary),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Profile & Session', style: TextStyle(fontFamily: 'Playfair Display', color: AppPalette.primary, fontWeight: FontWeight.bold)),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Identity Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppPalette.borderLight),
                    boxShadow: [
                      BoxShadow(color: AppPalette.primary.withOpacity(0.04), blurRadius: 16, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: userPrefs.isGuest ? AppPalette.secondary.withOpacity(0.4) : AppPalette.lavenderLight,
                        child: userPrefs.isGuest
                            ? const Icon(Icons.person_outline, size: 32, color: AppPalette.primary)
                            : Text(
                                userPrefs.userName.isNotEmpty ? userPrefs.userName[0].toUpperCase() : 'U',
                                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppPalette.primary),
                              ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userPrefs.isGuest ? 'Guest User' : userPrefs.userName,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppPalette.textDark),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userPrefs.isGuest ? 'Temporary In-Memory Session' : userPrefs.email,
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: userPrefs.isGuest ? Colors.amber.shade50 : AppPalette.lavenderLight,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: userPrefs.isGuest ? Colors.amber.shade200 : AppPalette.borderLight),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        userPrefs.isGuest ? Icons.timer_outlined : Icons.verified,
                                        size: 11,
                                        color: userPrefs.isGuest ? Colors.amber.shade800 : AppPalette.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        userPrefs.isGuest ? 'Guest Session' : 'Verified Member',
                                        style: TextStyle(
                                          color: userPrefs.isGuest ? Colors.amber.shade900 : AppPalette.primary,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppPalette.lavenderLight,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    '${userPrefs.gender} Styling',
                                    style: const TextStyle(color: AppPalette.primary, fontSize: 10, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // GUEST MODE PRESENTATION
                if (userPrefs.isGuest) ...[
                  // Prominent Upgrade Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppPalette.lavenderLight, Colors.white],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppPalette.secondary),
                      boxShadow: [
                        BoxShadow(color: AppPalette.primary.withOpacity(0.06), blurRadius: 16, offset: const Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(Icons.cloud_off_outlined, color: AppPalette.primary, size: 22),
                            SizedBox(width: 8),
                            Text(
                              'Guest Session Active',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppPalette.primary),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Your diagnostic tests and personalized recommendations are currently held in temporary device memory. Create a free account to permanently preserve your FaceCard and access past style reports anytime.',
                          style: TextStyle(fontSize: 12, color: AppPalette.textDark, height: 1.4),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pushNamed(context, '/auth', arguments: 'signup'),
                          icon: const Icon(Icons.person_add_alt_1, size: 16),
                          label: const Text('Create Free Account to Save Records', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppPalette.primary,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 46),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            elevation: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Current Session Analysis Preview (if performed during guest session)
                  const Text(
                    'CURRENT SESSION DIAGNOSTIC',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppPalette.primary),
                  ),
                  const SizedBox(height: 10),

                  if (userPrefs.currentAnalysis != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppPalette.borderLight),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppPalette.lavenderLight,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(child: Text('✨', style: TextStyle(fontSize: 20))),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${userPrefs.currentAnalysis!.faceShape} Face • ${userPrefs.currentAnalysis!.undertone}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppPalette.textDark),
                                ),
                                const SizedBox(height: 3),
                                const Text(
                                  'Stored in local memory for this session',
                                  style: TextStyle(color: Colors.grey, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => Navigator.pushNamed(context, '/results'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppPalette.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppPalette.borderLight),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.analytics_outlined, color: Colors.grey, size: 32),
                          const SizedBox(height: 8),
                          const Text(
                            'No assessment performed in this session yet.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontSize: 12),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton(
                            onPressed: () => Navigator.pushNamed(context, '/ai_analysis'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppPalette.primary,
                              side: const BorderSide(color: AppPalette.primary),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            child: const Text('Start FaceCard Analysis', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                ]
                // LOGGED-IN MEMBER PRESENTATION
                else ...[
                  const Text(
                    'SAVED STYLE HISTORY',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppPalette.primary),
                  ),
                  const SizedBox(height: 12),

                  if (userPrefs.savedReports.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppPalette.borderLight),
                      ),
                      child: const Text('No saved reports yet. Complete an analysis and tap bookmark to save.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 12)),
                    )
                  else
                    ...userPrefs.savedReports.map((report) => Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppPalette.borderLight),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 38,
                                height: 38,
                                decoration: BoxDecoration(
                                  color: AppPalette.lavenderLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.bookmark_added_outlined, color: AppPalette.primary, size: 18),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${report.faceShape} Face • ${report.undertone}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppPalette.textDark)),
                                  const SizedBox(height: 2),
                                  Text(report.date, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          OutlinedButton(
                            onPressed: () {
                              final notifier = AppStateManager.of(context).stateNotifier;
                              notifier.value = notifier.value.copyWith(
                                faceShape: report.faceShape,
                                undertone: report.undertone,
                                currentAnalysis: FaceCardApiService.generateFallbackAnalysis(
                                  faceShape: report.faceShape,
                                  undertone: report.undertone,
                                  gender: userPrefs.gender,
                                ),
                              );
                              Navigator.pushNamed(context, '/results');
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppPalette.primary,
                              side: const BorderSide(color: AppPalette.borderLight),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            child: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    )),
                ],

                const SizedBox(height: 28),

                // Logout / Exit Button
                ElevatedButton.icon(
                  onPressed: () {
                    final notifier = AppStateManager.of(context).stateNotifier;
                    notifier.value = UserPreferences(); // reset to default
                    Navigator.pushNamedAndRemoveUntil(context, '/welcome', (route) => false);
                  },
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(
                    userPrefs.isGuest ? 'Exit Guest Mode' : 'Log Out from FaceCard',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context, 3),
        );
      },
    );
  }
}

/// ===========================================================================
/// BOTTOM NAVIGATION HELPER & ARCHITECTURE
/// Home | Analyze | Results | Profile
/// ===========================================================================

class _BottomNavItem {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;

  const _BottomNavItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
  });
}

class FaceCardBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int>? onTap;

  const FaceCardBottomNav({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);

  void _navigateToTab(BuildContext context, int index) {
    if (onTap != null) {
      onTap!(index);
      return;
    }
    if (index == currentIndex) return;
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/ai_analysis');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/results');
        break;
      case 3:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = const [
      _BottomNavItem(
        label: 'Home',
        activeIcon: Icons.grid_view_rounded,
        inactiveIcon: Icons.grid_view_outlined,
      ),
      _BottomNavItem(
        label: 'Analyze',
        activeIcon: Icons.auto_awesome_rounded,
        inactiveIcon: Icons.auto_awesome_outlined,
      ),
      _BottomNavItem(
        label: 'Results',
        activeIcon: Icons.palette_rounded,
        inactiveIcon: Icons.palette_outlined,
      ),
      _BottomNavItem(
        label: 'Profile',
        activeIcon: Icons.person_rounded,
        inactiveIcon: Icons.person_outline_rounded,
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: AppPalette.borderLight.withOpacity(0.8),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppPalette.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final item = items[index];
              final isSelected = index == currentIndex;
              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => _navigateToTab(context, index),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeInOut,
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? AppPalette.lavenderLight : Colors.transparent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.inactiveIcon,
                          color: isSelected ? AppPalette.primary : const Color(0xFF8A8196),
                          size: 22,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item.label,
                          style: TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                            color: isSelected ? AppPalette.primary : const Color(0xFF8A8196),
                            letterSpacing: isSelected ? 0.2 : 0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

Widget _buildBottomNav(BuildContext context, int currentIndex) {
  return FaceCardBottomNav(currentIndex: currentIndex);
}
