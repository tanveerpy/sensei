import 'package:flutter/foundation.dart';

enum FaceShape { oval, round, square, heart, diamond, none }
enum Undertone { cool, warm, neutral, none }

class UserProfile extends ChangeNotifier {
  FaceShape faceShape = FaceShape.none;
  Undertone undertone = Undertone.none;

  void setAnalysis(FaceShape shape, Undertone under) {
    faceShape = shape;
    undertone = under;
    notifyListeners();
  }
}
