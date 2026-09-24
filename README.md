# FaceCard ✦ Find what suits you.

> **FaceCard** is a modern, premium personal style report mobile application built in **Flutter + Dart**, designed to analyze face geometries and undertones to deliver tailored styling recommendations.

---

## 🚫 Important: Non-Commercial Guarantee

**FaceCard is NOT an e-commerce or shopping application.**
- ❌ No products or brands
- ❌ No stores or shopping links
- ❌ No shopping carts or checkout flows
- ❌ No marketplace, payments, or product affiliates

FaceCard is purely an **aesthetic analysis and personal styling report system** created for personal styling intelligence and academic/FYP rigor.

---

## ✨ Core Features

1. **Biometric Face Shape Analysis**:
   - Detects and categorizes facial contour into 6 archetypes: **Oval**, **Round**, **Square**, **Heart**, **Diamond**, and **Oblong**.
   - Dual-Mode: Interactive camera/gallery AI scan with fallback to **Manual Selection** for complete user control and privacy.

2. **Skin Undertone Calibration**:
   - Classifies base undertone into **Cool**, **Warm**, or **Neutral**.
   - Supported by an interactive undertone guide and manual picker.

3. **Curated Style Intelligence Reports**:
   - **Dress Colours (35 Shades)**: 35 distinct named shades per undertone (Cool, Warm, Neutral) categorized into *Neutrals*, *Everyday*, *Soft/Pastels*, *Brights*, *Jewel/Rich*, and *Deep Shades*. Features interactive tap-to-inspect detail bottom sheet with enlarged preview, hex copy, and "Try Similar Shades" neighboring palette recommendations.
   - **Glasses / Frame Shapes**: 5–8 tailored frame geometries (Cat-eye, Rectangle, Oval, Round, Browline, Wayfarer, Geometric, Aviator) with horizontal carousel and responsive grid view modes.
   - **Hairstyles**: 5–8 haircut silhouettes tailored by face geometry, with Female/Male silhouette filters and Short / Medium / Long hair length chips.
   - **Explanations & Insights**: Scientific and aesthetic rationales explaining *why* each styling element suits the diagnosed shape and undertone.

---

## 🎨 Design Tokens & Aesthetic System

FaceCard features a soft, elegant, Gen-Z-friendly fashion editorial look:

| Token | Hex Value | Role |
| :--- | :--- | :--- |
| **Background Canvas** | `#F6F1FF` | Main application background |
| **Primary Deep Plum** | `#5A2A83` | Brand identity, primary CTAs, active states |
| **Secondary Lavender** | `#CDB4FF` | Accents, soft highlights, badges |
| **Accent Dusty Pink** | `#E8A0BF` | Micro-accents, illustration highlights |
| **Card Surface** | `#FFFFFF` | Crisp rounded cards with soft shadows |
| **Main Typography** | `#2F243A` | Deep charcoal purple text |
| **Soft Border** | `#E2D7F3` | Subtle card borders and dividers |

---

## 🔌 Flask REST API Data Contract

The Flutter client cleanly interfaces with a **Python Flask + PostgreSQL** backend via `FaceCardApiService`:

### Endpoint: `POST /api/analyze`

#### Request Format
- **AI Mode**: `multipart/form-data` with image file under `image` field.
- **Manual Mode**: `application/json` payload:
```json
{
  "mode": "manual",
  "face_shape": "Oval",
  "undertone": "Warm"
}
```

#### Standard Response Format
```json
{
  "success": true,
  "face_shape": "Oval",
  "undertone": "Warm",
  "explanations": {
    "face_shape_reason": "Your face exhibits an egg-like contour where forehead width is slightly greater than the rounded jawline. Proportions are naturally balanced and symmetrical.",
    "undertone_reason": "Subsurface golden, honey, and peachy tones glow effortlessly with rich earth tones and gold accents."
  },
  "recommendations": {
    "colours": [
      "Espresso",
      "Warm Charcoal",
      "Terracotta",
      "Olive Green",
      "Mustard Gold"
    ],
    "glasses": [
      {
        "name": "Geometric Square Frames",
        "reason": "Structured straight lines balance softer oval cheek contours with modern definition."
      },
      {
        "name": "Classic Cat-Eye Frames",
        "reason": "Subtle upward sweep lifts the eyes and accentuates cheekbone symmetry."
      }
    ],
    "hairstyles": [
      {
        "name": "Long Layered Waves",
        "length": "Long",
        "reason": "Frames naturally balanced facial contours with fluid, graceful movement."
      },
      {
        "name": "Curtain Bangs with Lob",
        "length": "Medium",
        "reason": "Soft cheek-grazing fringe draws immediate focus to eyes and cheekbones."
      }
    ]
  }
}
```

> **Offline & Demo Resiliency**: If the Flask backend is offline or unreachable during demonstrations, `FaceCardApiService` gracefully triggers its built-in rule-based calculation engine, guaranteeing a seamless presentation experience.

---

## 🛠️ Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/YOUR_USERNAME/facecard.git
   cd facecard
   ```

2. **Retrieve Flutter packages:**
   ```bash
   flutter pub get
   ```

3. **Verify connected devices:**
   ```bash
   flutter devices
   ```

4. **Launch the application:**
   ```bash
   flutter run
   ```

---

## 📁 Repository Directory Structure

```text
facecard/
├── README.md
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── models/
    │   └── analysis_response.dart
    ├── services/
    │   └── api_service.dart
    ├── theme/
    │   └── app_palette.dart
    └── screens/
        ├── splash_screen.dart
        ├── welcome_screen.dart
        ├── auth_screen.dart
        ├── home_screen.dart
        ├── ai_analysis_screen.dart
        ├── manual_shape_screen.dart
        ├── manual_undertone_screen.dart
        ├── processing_screen.dart
        ├── results_screen.dart
        └── profile_screen.dart
```

---

## 📝 License

This project is licensed under the MIT License.
