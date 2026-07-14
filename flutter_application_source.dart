import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Locks the application to portrait mode for consistent layout rendering
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  runApp(const StyleSenseApp());
}

/// ===========================================================================
/// LUXURY THEME PALETTE CONSTANTS
/// ===========================================================================
class AppPalette {
  static const Color primary = Color(0xFFD8C3A5);      // Deep Beige
  static const Color secondary = Color(0xFF8E735B);    // Soft Brown
  static const Color background = Color(0xFFFAF7F2);   // Off White
  static const Color textDark = Color(0xFF2D2D2D);     // Dark Charcoal
  static const Color accentBeige = Color(0xFFEAE0D5);  // Soft Accent Beige
  static const Color cardBg = Color(0xFFFFFFFF);       // Pure White
  static const Color borderLight = Color(0xFFEAE0D5);  // Light Beige Border
}

/// ===========================================================================
/// STATE MANAGEMENT
/// Lightweight, reliable reactive state management without heavy dependencies.
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

class UserPreferences {
  final String userName;
  final String gender;      // 'Female' | 'Male' | ''
  final String faceShape;   // 'Oval' | 'Round' | 'Square' | 'Heart' | 'Diamond' | ''
  final String skinTone;    // 'Fair' | 'Medium' | 'Deep' | ''
  final String undertone;   // 'Cool' | 'Warm' | 'Neutral' | ''
  final bool isLoggedIn;
  final bool isGuest;
  final List<String> savedItems;

  UserPreferences({
    this.userName = 'Tahira',
    this.gender = 'Female',
    this.faceShape = 'Oval',
    this.skinTone = 'Medium',
    this.undertone = 'Cool',
    this.isLoggedIn = false,
    this.isGuest = false,
    this.savedItems = const [],
  });

  UserPreferences copyWith({
    String? userName,
    String? gender,
    String? faceShape,
    String? skinTone,
    String? undertone,
    bool? isLoggedIn,
    bool? isGuest,
    List<String>? savedItems,
  }) {
    return UserPreferences(
      userName: userName ?? this.userName,
      gender: gender ?? this.gender,
      faceShape: faceShape ?? this.faceShape,
      skinTone: skinTone ?? this.skinTone,
      undertone: undertone ?? this.undertone,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      isGuest: isGuest ?? this.isGuest,
      savedItems: savedItems ?? this.savedItems,
    );
  }
}

/// ===========================================================================
/// MAIN APPLICATION RUNNER
/// ===========================================================================
class StyleSenseApp extends StatefulWidget {
  const StyleSenseApp({Key? key}) : super(key: key);

  @override
  State<StyleSenseApp> createState() => _StyleSenseAppState();
}

class _StyleSenseAppState extends State<StyleSenseApp> {
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
        title: 'Tulip',
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return Container(
            decoration: const BoxDecoration(
              color: AppPalette.background,
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1520763185298-1b434c919102?auto=format&fit=crop&q=80'),
                fit: BoxFit.cover,
                opacity: 0.15,
              ),
            ),
            child: child,
          );
        },
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.transparent,
          primaryColor: AppPalette.primary,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppPalette.secondary,
            primary: AppPalette.secondary,
            background: AppPalette.background,
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
          '/gender': (context) => const GenderSelectionScreen(),
          '/home': (context) => const HomeScreen(),
          '/ai_analysis': (context) => const AiAnalysisScreen(),
          '/manual_analysis': (context) => const ManualAnalysisScreen(),
          '/processing': (context) => const ProcessingScreen(),
          '/results': (context) => const ResultsScreen(),
          '/recommendations': (context) => const RecommendationHubScreen(),
          '/marketplace': (context) => const MarketplaceScreen(),
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
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    
    _controller.forward();
    
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/welcome');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppPalette.secondary,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.secondary.withOpacity(0.2),
                      blurRadius: 25,
                      offset: const Offset(0, 12),
                    )
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  size: 60,
                  color: AppPalette.background,
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Tulip',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppPalette.textDark,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'STYLE THAT SUITS YOU',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 11,
                  letterSpacing: 3,
                  color: AppPalette.secondary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

/// ===========================================================================
/// SCREEN 2: WELCOME SCREEN
/// ===========================================================================
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              // Luxury Graphic Block
              Container(
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: AppPalette.accentBeige,
                  boxShadow: [
                    BoxShadow(
                      color: AppPalette.textDark.withOpacity(0.04),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: const Center(
                  child: Icon(
                    Icons.face_retouching_natural,
                    size: 110,
                    color: AppPalette.secondary,
                  ),
                ),
              ),
              const SizedBox(height: 44),
              const Text(
                'Personalized Styling Curated For You',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppPalette.textDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Unlock custom style insights from hairstyles and clothing palettes to precise frame geometries directly on your device.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  height: 1.6,
                  color: Colors.black54,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/auth'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Join Tulip',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  final stateNotifier = AppStateManager.of(context).stateNotifier;
                  stateNotifier.value = stateNotifier.value.copyWith(
                    isGuest: true,
                    userName: 'Guest User',
                  );
                  Navigator.pushNamed(context, '/gender');
                },
                child: const Text(
                  'Continue as Guest',
                  style: TextStyle(
                    color: AppPalette.secondary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}

/// ===========================================================================
/// SCREEN 3: LOGIN / SIGNUP SCREEN
/// ===========================================================================
class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _submitLogin() {
    if (_loginEmailController.text.isNotEmpty && _loginPasswordController.text.isNotEmpty) {
      final stateNotifier = AppStateManager.of(context).stateNotifier;
      stateNotifier.value = stateNotifier.value.copyWith(
        userName: 'Tahira',
        isLoggedIn: true,
        isGuest: false,
      );
      Navigator.pushNamed(context, '/gender');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all authentication fields.')),
      );
    }
  }

  void _submitSignup() {
    if (_signupNameController.text.isNotEmpty &&
        _signupEmailController.text.isNotEmpty &&
        _signupPasswordController.text.isNotEmpty) {
      if (_signupPasswordController.text != _signupConfirmController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Passwords do not match.')),
        );
        return;
      }
      final stateNotifier = AppStateManager.of(context).stateNotifier;
      stateNotifier.value = stateNotifier.value.copyWith(
        userName: _signupNameController.text,
        isLoggedIn: true,
        isGuest: false,
      );
      Navigator.pushNamed(context, '/gender');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all parameters to build your account.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppPalette.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tulip',
          style: TextStyle(fontFamily: 'Playfair Display', color: AppPalette.textDark, fontWeight: FontWeight.bold),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppPalette.secondary,
          labelColor: AppPalette.secondary,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Plus Jakarta Sans'),
          tabs: const [
            Tab(text: 'LOGIN'),
            Tab(text: 'CREATE ACCOUNT'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Login view
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome Back',
                    style: TextStyle(fontFamily: 'Playfair Display', fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Enter credentials to unlock custom fashion matching parameters.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 36),
                  _buildTextField('Email Address', _loginEmailController, false, TextInputType.emailAddress),
                  const SizedBox(height: 20),
                  _buildTextField('Password', _loginPasswordController, true, TextInputType.visiblePassword),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Verification reset code forwarded to registered Email.')),
                        );
                      },
                      child: const Text('Forgot Password?', style: TextStyle(color: AppPalette.secondary, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.secondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Authenticate Securely', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            // Signup view
            SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    'Create Profile',
                    style: TextStyle(fontFamily: 'Playfair Display', fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text('Join to create your face geometry maps.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 24),
                  _buildTextField('Full Name', _signupNameController, false, TextInputType.name),
                  const SizedBox(height: 16),
                  _buildTextField('Email Address', _signupEmailController, false, TextInputType.emailAddress),
                  const SizedBox(height: 16),
                  _buildTextField('Password', _signupPasswordController, true, TextInputType.visiblePassword),
                  const SizedBox(height: 16),
                  _buildTextField('Confirm Password', _signupConfirmController, true, TextInputType.visiblePassword),
                  const SizedBox(height: 28),
                  ElevatedButton(
                    onPressed: _submitSignup,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.secondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 54),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: const Text('Build Profile Account', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController ctrl, bool obs, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0, color: AppPalette.textDark)),
        const SizedBox(height: 8),
        TextField(
          controller: ctrl,
          obscureText: obs,
          keyboardType: type,
          cursorColor: AppPalette.secondary,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppPalette.borderLight),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppPalette.borderLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppPalette.secondary),
            ),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmController.dispose();
    super.dispose();
  }
}

/// ===========================================================================
/// SCREEN 4: GENDER SELECTION SCREEN
/// ===========================================================================
class GenderSelectionScreen extends StatefulWidget {
  const GenderSelectionScreen({Key? key}) : super(key: key);

  @override
  State<GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<GenderSelectionScreen> {
  String _selectedGender = 'Female';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Tell us about yourself',
                style: TextStyle(fontFamily: 'Playfair Display', fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                'Our dynamic stylist systems fine-tune visual catalogs and haircuts specifically matching your gender profile.',
                style: TextStyle(color: Colors.black54, height: 1.5),
              ),
              const SizedBox(height: 44),
              _buildGenderCard('👩 Female', 'Female', 'Curtain bangs, makeup palettes, elegant style catalogs'),
              const SizedBox(height: 20),
              _buildGenderCard('👨 Male', 'Male', 'Beard styles, architectural fades, robust palettes'),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  final stateNotifier = AppStateManager.of(context).stateNotifier;
                  stateNotifier.value = stateNotifier.value.copyWith(gender: _selectedGender);
                  Navigator.pushNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Proceed', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGenderCard(String title, String key, String subtitle) {
    bool isSelected = _selectedGender == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppPalette.secondary : AppPalette.borderLight,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: AppPalette.secondary.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 8))]
              : [],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? AppPalette.secondary : AppPalette.textDark,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                  ),
                ],
              ),
            ),
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppPalette.secondary : Colors.grey.shade400,
                  width: 2,
                ),
                color: isSelected ? AppPalette.secondary : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                  : null,
            )
          ],
        ),
      ),
    );
  }
}

/// ===========================================================================
/// SCREEN 5: HOME SCREEN (DASHBOARD)
/// ===========================================================================
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserPreferences>(
      valueListenable: AppStateManager.of(context).stateNotifier,
      builder: (context, userPrefs, child) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Greeting row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CURATED STYLE STAGE',
                            style: TextStyle(fontSize: 10, letterSpacing: 2, fontWeight: FontWeight.bold, color: AppPalette.secondary),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Hello, ${userPrefs.userName}',
                            style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppPalette.primary.withOpacity(0.3),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppPalette.primary),
                        ),
                        child: Center(
                          child: Text(
                            userPrefs.userName.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, color: AppPalette.secondary, fontSize: 16),
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 36),
                  Expanded(
                    child: ListView(
                      children: [
                        // AI scanner primary card
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/ai_analysis'),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppPalette.secondary, Color(0xFF765F4A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: AppPalette.secondary.withOpacity(0.2),
                                  blurRadius: 15,
                                  offset: const Offset(0, 8),
                                )
                              ],
                            ),
                            child: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(Icons.blur_circular, size: 40, color: AppPalette.primary),
                                SizedBox(height: 20),
                                Text(
                                  '📸 Analyze My Face',
                                  style: TextStyle(fontFamily: 'Playfair Display', fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Use standard local camera sensors to calculate biometric balances instantly.',
                                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.5),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Manual profile selection card
                        _buildMenuCard(
                          context,
                          '✍️ Manual Input Analysis',
                          'Directly select your specific skin metrics & facial shapes.',
                          Icons.tune,
                          '/manual_analysis',
                        ),
                        const SizedBox(height: 20),
                        // Saved recommendations drawer card
                        _buildSavedItemsCard(context, userPrefs),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: _buildBottomNav(context, 0),
        );
      },
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, String text, IconData icon, String route) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPalette.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppPalette.accentBeige,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppPalette.secondary, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(text, style: const TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedItemsCard(BuildContext context, UserPreferences userPrefs) {
    int count = userPrefs.savedItems.length;
    return GestureDetector(
      onTap: () {
        if (count == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No recommendations saved yet.')),
          );
        } else {
          Navigator.pushNamed(context, '/recommendations');
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppPalette.borderLight),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(Icons.favorite, color: Colors.pink.shade300, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📚 Saved Recommendations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                  const SizedBox(height: 4),
                  Text(
                    count == 0 ? 'No items saved.' : 'You have $count style guidelines saved in vault.',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 14),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(BuildContext context, int current) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppPalette.borderLight, width: 0.5)),
      ),
      child: BottomNavigationBar(
        currentIndex: current,
        onTap: (index) {
          if (index == 0) Navigator.pushNamed(context, '/home');
          if (index == 1) Navigator.pushNamed(context, '/manual_analysis');
          if (index == 2) Navigator.pushNamed(context, '/marketplace');
        },
        backgroundColor: Colors.white,
        selectedItemColor: AppPalette.secondary,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.tune), label: 'Configure'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_bag_outlined), label: 'Shop'),
        ],
      ),
    );
  }
}

/// ===========================================================================
/// SCREEN 6: AI ANALYSIS CAPTURE SCREEN
/// ===========================================================================
class AiAnalysisScreen extends StatelessWidget {
  const AiAnalysisScreen({Key? key}) : super(key: key);

  void _runAnalysisMock(BuildContext context, String face, String tone, String undertone) {
    final stateNotifier = AppStateManager.of(context).stateNotifier;
    stateNotifier.value = stateNotifier.value.copyWith(
      faceShape: face,
      skinTone: tone,
      undertone: undertone,
    );
    Navigator.pushNamed(context, '/processing');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppPalette.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Analyze My Face', style: TextStyle(fontFamily: 'Playfair Display', color: AppPalette.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'AI Face Map Scanner',
                style: TextStyle(fontFamily: 'Playfair Display', fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('Capture or select photo references to analyze features.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 24),
              // Checklist banner
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('🛡️ SECURE SCANNING REQUIREMENTS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10, letterSpacing: 1.5, color: AppPalette.secondary)),
                    SizedBox(height: 12),
                    _CheckItem('Ensure face is centered in direct portrait view'),
                    SizedBox(height: 8),
                    _CheckItem('Optimize room lighting directly on your skin'),
                    SizedBox(height: 8),
                    _CheckItem('Avoid sunglasses, hats, or digital filtering'),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final image = await picker.pickImage(source: ImageSource.camera);
                  if (image != null) {
                    if (!context.mounted) return;
                    _runAnalysisMock(context, 'Heart', 'Fair', 'Warm');
                  }
                },
                icon: const Icon(Icons.camera_alt),
                label: const Text('Open Device Camera', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 14),
              OutlinedButton.icon(
                onPressed: () async {
                  final picker = ImagePicker();
                  final image = await picker.pickImage(source: ImageSource.gallery);
                  if (image != null) {
                    if (!context.mounted) return;
                    _runAnalysisMock(context, 'Oval', 'Medium', 'Neutral');
                  }
                },
                icon: const Icon(Icons.photo_library),
                label: const Text('Upload from Gallery', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppPalette.secondary,
                  side: const BorderSide(color: AppPalette.secondary),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
              const SizedBox(height: 36),
              const Center(
                child: Text(
                  'OR RUN SIMULATION PRESET FOR SCREENING',
                  style: TextStyle(fontSize: 10, letterSpacing: 1.0, fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.1,
                children: [
                  _buildPresetItem(context, '👩 Oval/Fair', 'Oval', 'Fair', 'Cool'),
                  _buildPresetItem(context, '🧔 Round/Deep', 'Round', 'Deep', 'Warm'),
                  _buildPresetItem(context, '🧑 Square/Med', 'Square', 'Medium', 'Neutral'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPresetItem(BuildContext context, String name, String shape, String skin, String under) {
    return GestureDetector(
      onTap: () => _runAnalysisMock(context, shape, skin, under),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: AppPalette.borderLight),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, color: AppPalette.secondary),
          ),
        ),
      ),
    );
  }
}

class _CheckItem extends StatelessWidget {
  final String text;
  const _CheckItem(this.text, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle, size: 16, color: Colors.green),
        const SizedBox(width: 10),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 12))),
      ],
    );
  }
}

/// ===========================================================================
/// SCREEN 7: MANUAL ANALYSIS SCREEN
/// ===========================================================================
class ManualAnalysisScreen extends StatefulWidget {
  const ManualAnalysisScreen({Key? key}) : super(key: key);

  @override
  State<ManualAnalysisScreen> createState() => _ManualAnalysisScreenState();
}

class _ManualAnalysisScreenState extends State<ManualAnalysisScreen> {
  String _shape = 'Oval';
  String _skin = 'Medium';
  String _undertone = 'Cool';

  void _triggerHelpQuiz() {
    showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return _UndertoneQuizDialog(onFinish: (result) {
          setState(() {
            _undertone = result;
          });
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppPalette.textDark, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Manual Analysis', style: TextStyle(fontFamily: 'Playfair Display', color: AppPalette.textDark, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Direct Specification',
                style: TextStyle(fontFamily: 'Playfair Display', fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              const Text('Provide your parameters directly for on-the-fly style guidance.', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              // Dropdowns
              _buildDropdown('Face Shape Selection', _shape, ['Oval', 'Round', 'Square', 'Heart', 'Diamond'], (val) {
                if (val != null) setState(() => _shape = val);
              }),
              const SizedBox(height: 20),
              _buildDropdown('Skin Tone Matrix', _skin, ['Fair', 'Medium', 'Deep'], (val) {
                if (val != null) setState(() => _skin = val);
              }),
              const SizedBox(height: 20),
              _buildDropdown('Skin Undertone Profile', _undertone, ['Cool', 'Warm', 'Neutral'], (val) {
                if (val != null) setState(() => _undertone = val);
              }),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: _triggerHelpQuiz,
                icon: const Icon(Icons.help_outline),
                label: const Text('Help Me Find My Undertone', style: TextStyle(fontWeight: FontWeight.bold)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppPalette.secondary,
                  side: const BorderSide(color: AppPalette.secondary),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  final stateNotifier = AppStateManager.of(context).stateNotifier;
                  stateNotifier.value = stateNotifier.value.copyWith(
                    faceShape: _shape,
                    skinTone: _skin,
                    undertone: _undertone,
                  );
                  Navigator.pushNamed(context, '/processing');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppPalette.secondary,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Generate Style Matrix', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.0, color: AppPalette.textDark)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppPalette.borderLight),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: AppPalette.secondary),
              items: options.map((opt) {
                return DropdownMenuItem<String>(
                  value: opt,
                  child: Text(opt, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

/// Helper Modal: Undertone Quiz
class _UndertoneQuizDialog extends StatefulWidget {
  final ValueChanged<String> onFinish;
  const _UndertoneQuizDialog({Key? key, required this.onFinish}) : super(key: key);

  @override
  State<_UndertoneQuizDialog> createState() => _UndertoneQuizDialogState();
}

class _UndertoneQuizDialogState extends State<_UndertoneQuizDialog> {
  int _currentStep = 1;
  String? _q1, _q2, _q3;

  void _answer(String ans) {
    if (_currentStep == 1) {
      _q1 = ans;
      setState(() => _currentStep = 2);
    } else if (_currentStep == 2) {
      _q2 = ans;
      setState(() => _currentStep = 3);
    } else if (_currentStep == 3) {
      _q3 = ans;
      _calculateResult();
    }
  }

  void _calculateResult() {
    int cool = 0;
    int warm = 0;

    if (_q1 == 'cool') cool++; else if (_q1 == 'warm') warm++;
    if (_q2 == 'cool') cool++; else if (_q2 == 'warm') warm++;
    if (_q3 == 'cool') cool++; else if (_q3 == 'warm') warm++;

    String finalResult = 'Neutral';
    if (cool > warm) {
      finalResult = 'Cool';
    } else if (warm > cool) {
      finalResult = 'Warm';
    }

    widget.onFinish(finalResult);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Calculated Undertone is: $finalResult')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppPalette.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Undertone Finder', style: TextStyle(fontFamily: 'Playfair Display', fontWeight: FontWeight.bold)),
          Text('$_currentStep/3', style: const TextStyle(fontSize: 12, color: AppPalette.secondary)),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_currentStep == 1) ...[
            const Text('What is the dominant pigment of the veins on your wrists?', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            _buildQuizButton('Blue or Purple veins', 'cool'),
            _buildQuizButton('Green or Olive veins', 'warm'),
            _buildQuizButton('Mixed or Hard to tell', 'neutral'),
          ] else if (_currentStep == 2) ...[
            const Text('How does your skin react to direct intensive sunlight?', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            _buildQuizButton('Burns easily, rarely tans', 'cool'),
            _buildQuizButton('Tans easily, rarely burns', 'warm'),
            _buildQuizButton('Burns initially, then tans', 'neutral'),
          ] else if (_currentStep == 3) ...[
            const Text('Which jewelry metals compliment your natural skin luster?', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 20),
            _buildQuizButton('Silver & White Golds', 'cool'),
            _buildQuizButton('Yellow Golds & Brass', 'warm'),
            _buildQuizButton('Both look equally beautiful', 'neutral'),
          ]
        ],
      ),
    );
  }

  Widget _buildQuizButton(String label, String code) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: ElevatedButton(
        onPressed: () => _answer(code),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: AppPalette.textDark,
          shadowColor: Colors.transparent,
          side: const BorderSide(color: AppPalette.borderLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ),
    );
  }
}

/// ===========================================================================
/// SCREEN 8: PROCESSING ANIMATION SCREEN
/// ===========================================================================
class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({Key? key}) : super(key: key);

  @override
  State<ProcessingScreen> createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _spinController;
  int _progress = 0;
  String _statusMessage = 'Mapping facial dimensions...';

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _runSequence();
  }

  void _runSequence() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() { _progress = 35; _statusMessage = 'Evaluating color values...'; });
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() { _progress = 70; _statusMessage = 'Matching perfect custom style guidelines...'; });
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) {
      setState(() => _progress = 100);
      Navigator.pushReplacementNamed(context, '/results');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              RotationTransition(
                turns: _spinController,
                child: Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    color: AppPalette.accentBeige.withOpacity(0.4),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.hourglass_empty_rounded, size: 48, color: AppPalette.secondary),
                ),
              ),
              const SizedBox(height: 44),
              const Text(
                'AI Engine Sync',
                style: TextStyle(fontFamily: 'Playfair Display', fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                _statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey, height: 1.4),
              ),
              const SizedBox(height: 36),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _progress / 100.0,
                  color: AppPalette.secondary,
                  backgroundColor: AppPalette.borderLight,
                  minHeight: 6,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }
}

/// ===========================================================================
/// SCREEN 9: ANALYTIC RESULTS SCREEN
/// ===========================================================================
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserPreferences>(
      valueListenable: AppStateManager.of(context).stateNotifier,
      builder: (context, userPrefs, child) {
        return Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Stylist Map Matrix',
                    style: TextStyle(fontFamily: 'Playfair Display', fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text('Geometric face values analyzed successfully.', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 36),
                  _buildResultsCard('Face Structure', userPrefs.faceShape, Icons.face_retouching_natural, 'Corrective eyewear, hair parameters'),
                  const SizedBox(height: 16),
                  _buildResultsCard('Skin Tone', userPrefs.skinTone, Icons.palette, 'Luster classification metrics'),
                  const SizedBox(height: 16),
                  _buildResultsCard('Undertone', userPrefs.undertone, Icons.bloodtype, 'Color palette guidelines selection'),
                  const Spacer(),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/recommendations'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppPalette.secondary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Unlock Custom Guidelines', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildResultsCard(String category, String value, IconData icon, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppPalette.borderLight),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppPalette.accentBeige,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppPalette.secondary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(category, style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppPalette.textDark)),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
              ],
            ),
          )
        ],
      ),
    );
  }
}

/// ===========================================================================
/// SCREEN 10: RECOMMENDATION HUB (TABS SCREEN)
/// ===========================================================================
class RecommendationHubScreen extends StatefulWidget {
  const RecommendationHubScreen({Key? key}) : super(key: key);

  @override
  State<RecommendationHubScreen> createState() => _RecommendationHubScreenState();
}

class _RecommendationHubScreenState extends State<RecommendationHubScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  void _saveItem(String item) {
    final stateNotifier = AppStateManager.of(context).stateNotifier;
    final currentList = List<String>.from(stateNotifier.value.savedItems);
    if (currentList.contains(item)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item already saved in vault.')),
      );
      return;
    }
    currentList.add(item);
    stateNotifier.value = stateNotifier.value.copyWith(savedItems: currentList);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Saved "$item" to Style Vault')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserPreferences>(
      valueListenable: AppStateManager.of(context).stateNotifier,
      builder: (context, userPrefs, child) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppPalette.textDark, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Style Guide Hub', style: TextStyle(fontFamily: 'Playfair Display', color: AppPalette.textDark, fontWeight: FontWeight.bold)),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppPalette.secondary,
              labelColor: AppPalette.secondary,
              unselectedLabelColor: Colors.grey,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: const [
                Tab(icon: Icon(Icons.face, size: 18), text: 'HAIRCUTS'),
                Tab(icon: Icon(Icons.palette_outlined, size: 18), text: 'COLORS'),
                Tab(icon: Icon(Icons.remove_red_eye, size: 18), text: 'EYEWEAR'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildHaircutsTab(userPrefs),
              _buildColorsTab(userPrefs),
              _buildEyewearTab(userPrefs),
            ],
          ),
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppPalette.borderLight, width: 0.5)),
            ),
            child: ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/marketplace'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppPalette.secondary,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Shop matched styling products', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHaircutsTab(UserPreferences userPrefs) {
    List<Map<String, String>> hairstyles = [];
    if (userPrefs.gender == 'Female') {
      if (userPrefs.faceShape == 'Oval') {
        hairstyles = [
          {"name": "Beachy Waves & Side-Part", "why": "Soft, flowing waves highlight the natural balance of your oval face without covering any features."},
          {"name": "Curtain Bangs with Layers", "why": "Curtain bangs frame your cheekbones beautifully and keep the focus centered on your eyes."}
        ];
      } else if (userPrefs.faceShape == 'Round') {
        hairstyles = [
          {"name": "Long Angled Bob", "why": "An asymmetrical, structured cut below the chin pulls the eye downwards, elongating rounder cheeks."},
          {"name": "High Crown Bun with tendrils", "why": "Creating vertical volume on top creates a more oval proportion and adds instant sophistication."}
        ];
      } else {
        hairstyles = [
          {"name": "Whispy Layered Cut", "why": "Layers neutralize a prominent jawline by softening sharp angular structures."},
          {"name": "Beveled Classic Lob", "why": "Soft curl-ins at the collarbones diminish square contours."}
        ];
      }
    } else {
      if (userPrefs.faceShape == 'Oval') {
        hairstyles = [
          {"name": "Textured Slick-Back", "why": "Keeps clean forehead visible, accentuating clean, symmetrical dimensions."},
          {"name": "Classic Side Part", "why": "Provides clean-shaven masculine refinement suited to executive profiles."}
        ];
      } else if (userPrefs.faceShape == 'Round') {
        hairstyles = [
          {"name": "Classic Pompadour", "why": "Creates high crown elevation which slims down wide cheeks dramatically."},
          {"name": "Undercut Fade", "why": "Extremely tight sides slim your temple profiles instantly."}
        ];
      } else {
        hairstyles = [
          {"name": "Buzz Cut & Fade", "why": "Leverages and emphasizes your jaw structure for a powerful look."},
          {"name": "Textured Quiff", "why": "Brings organic height and balance to angled diamond cheekbones."}
        ];
      }
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: hairstyles.length,
      itemBuilder: (context, index) {
        final item = hairstyles[index];
        return Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppPalette.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['name']!, style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.bold)),
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: AppPalette.secondary),
                      onPressed: () => _saveItem(item['name']!),
                    )
                  ],
                ),
                const SizedBox(height: 8),
                Text(item['why']!, style: const TextStyle(fontSize: 12, height: 1.5, color: Colors.black54)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildColorsTab(UserPreferences userPrefs) {
    List<Map<String, dynamic>> colors = [];
    String desc = "";

    if (userPrefs.undertone == 'Cool') {
      colors = [
        {"name": "Emerald Green", "color": const Color(0xFF097969)},
        {"name": "Royal Sapphire", "color": const Color(0xFF0F52BA)},
        {"name": "Deep Ruby", "color": const Color(0xFF9B111E)},
        {"name": "Rich Charcoal", "color": const Color(0xFF36454F)}
      ];
      desc = "Your skin possesses rose, pink, or bluish baseline factors. Vivid jewel tones and cool deep neutrals balance and illuminate your features perfectly.";
    } else if (userPrefs.undertone == 'Warm') {
      colors = [
        {"name": "Terracotta Clay", "color": const Color(0xFFE2725B)},
        {"name": "Olive Earth", "color": const Color(0xFF556B2F)},
        {"name": "Rich Ochre", "color": const Color(0xFFCC7722)},
        {"name": "Desert Sand", "color": const Color(0xFFD2B48C)}
      ];
      desc = "Peachy, golden, and honey components dictate your surface. Rich earth-based hues complement and enrich this natural glow.";
    } else {
      colors = [
        {"name": "Burgundy Wine", "color": const Color(0xFF800020)},
        {"name": "Sage Jade", "color": const Color(0xFF8FBC8F)},
        {"name": "Soft Charcoal", "color": const Color(0xFF4A4A4A)},
        {"name": "Muted Navy", "color": const Color(0xFF2F4F4F)}
      ];
      desc = "A highly versatile balance of cool and warm parameters. Most colors suit you, but muted secondary tones bring out the best in you.";
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppPalette.borderLight),
            ),
            child: Text(desc, style: const TextStyle(fontSize: 12, height: 1.5, color: Colors.black54)),
          ),
          const SizedBox(height: 24),
          const Text('RECOMMENDED PALETTE', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11, letterSpacing: 1.5)),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.8,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) {
              final colorItem = colors[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppPalette.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colorItem['color'],
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        colorItem['name'],
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    )
                  ],
                ),
              );
            },
          )
        ],
      ),
    );
  }

  Widget _buildEyewearTab(UserPreferences userPrefs) {
    List<Map<String, String>> eyewear = [];
    if (userPrefs.faceShape == 'Round') {
      eyewear = [
        {"type": "Rectangular Frames", "desc": "Adds angular contrast to softer cheek curves."},
        {"type": "Wayfarer Structures", "desc": "Classic robust temples add dynamic architectural definitions."}
      ];
    } else if (userPrefs.faceShape == 'Square') {
      eyewear = [
        {"type": "Classic Rounded Frames", "desc": "Soft round geometries reduce jawline harshness."},
        {"type": "Aviator Profiles", "desc": "Teardrop glass lines contour high brow architectures."}
      ];
    } else {
      eyewear = [
        {"type": "Clubmaster Horn-Rims", "desc": "Draws attention upwards, perfect for balanced oval frames."},
        {"type": "Cat-Eye Geometries", "desc": "Complements narrow jawlines beautifully."}
      ];
    }

    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: eyewear.length,
      itemBuilder: (context, index) {
        final item = eyewear[index];
        return Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppPalette.borderLight),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item['type']!, style: const TextStyle(fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text(item['desc']!, style: const TextStyle(fontSize: 12, height: 1.5, color: Colors.black54)),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// ===========================================================================
/// SCREEN 11: PRODUCT MARKETPLACE SCREEN
/// ===========================================================================
class MarketplaceScreen extends StatelessWidget {
  const MarketplaceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<UserPreferences>(
      valueListenable: AppStateManager.of(context).stateNotifier,
      builder: (context, userPrefs, child) {
        List<Map<String, String>> products = [];
        
        if (userPrefs.undertone == 'Cool') {
          products.add({
            "name": "Savile Indigo Wool Coat",
            "brand": "Sartorial Paris",
            "price": "\$349",
            "tag": "Indigo Palette",
            "type": "Coat"
          });
        } else {
          products.add({
            "name": "Merino Camel Trench",
            "brand": "Maison de Style",
            "price": "\$399",
            "tag": "Warm Palette",
            "type": "Coat"
          });
        }

        if (userPrefs.faceShape == 'Round') {
          products.add({
            "name": "Acetate Rectangular Frames",
            "brand": "Optika Atelier",
            "price": "\$189",
            "tag": "Frame Corrective",
            "type": "Glasses"
          });
        } else {
          products.add({
            "name": "Clubmaster Classic Horn",
            "brand": "Silhouette Eyewear",
            "price": "\$210",
            "tag": "Frame Corrective",
            "type": "Glasses"
          });
        }

        if (userPrefs.gender == 'Female') {
          products.add({
            "name": "Silk Luster Wave Oil",
            "brand": "Orbis Botanicals",
            "price": "\$42",
            "tag": "Style Finish",
            "type": "Oil"
          });
        } else {
          products.add({
            "name": "Barber Crown Matte Pomade",
            "brand": "Kensington Pomades",
            "price": "\$32",
            "tag": "Style Finish",
            "type": "Pomade"
          });
        }

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppPalette.textDark, size: 18),
              onPressed: () => Navigator.pop(context),
            ),
            title: const Text('Tulip Shop', style: TextStyle(fontFamily: 'Playfair Display', color: AppPalette.textDark, fontWeight: FontWeight.bold)),
          ),
          body: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Matched Outfits & Styling Elements',
                        style: TextStyle(fontFamily: 'Playfair Display', fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Products matched specifically to your ${userPrefs.faceShape} face / ${userPrefs.undertone} undertone.',
                        style: const TextStyle(fontSize: 11, color: Colors.grey),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(24),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final p = products[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppPalette.borderLight),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppPalette.accentBeige,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Icon(
                                  p['type'] == 'Coat'
                                      ? Icons.checkroom
                                      : p['type'] == 'Glasses'
                                          ? Icons.remove_red_eye
                                          : Icons.science_outlined,
                                  color: AppPalette.secondary,
                                  size: 30,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p['tag']!.toUpperCase(),
                                    style: const TextStyle(color: AppPalette.secondary, fontSize: 9, fontWeight: FontWeight.bold, letterSpacing: 1.0),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(p['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  const SizedBox(height: 2),
                                  Text(p['brand']!, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                                  const SizedBox(height: 4),
                                  Text(p['price']!, style: const TextStyle(fontWeight: FontWeight.bold, color: AppPalette.textDark, fontSize: 12)),
                                ],
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Deep linking redirecting to third-party merchant: ${p['brand']}')),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppPalette.textDark,
                                foregroundColor: Colors.white,
                                minimumSize: const Size(60, 40),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                              ),
                              child: const Text('View', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
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
}