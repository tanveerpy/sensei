import 'package:flutter/foundation.dart';

enum FaceShape { oval, round, square, heart, diamond, none }
enum Undertone { cool, warm, neutral, none }

class UserProfile extends ChangeNotifier {
  FaceShape faceShape = FaceShape.none;
  Undertone undertone = Undertone.none;
  String? imagePath;

  void setImagePath(String? path) {
    imagePath = path;
    notifyListeners();
  }

  void setAnalysis(FaceShape shape, Undertone under, {String? path}) {
    faceShape = shape;
    undertone = under;
    if (path != null) {
      imagePath = path;
    }
    notifyListeners();
  }

  void reset() {
    faceShape = FaceShape.none;
    undertone = Undertone.none;
    imagePath = null;
    notifyListeners();
  }
}

