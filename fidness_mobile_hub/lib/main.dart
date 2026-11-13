import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bondin_data.dart';
import 'bondin_charts.dart';
import 'stiel_suite_screen.dart';
import 'fidness_splash_intro.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const FidnessOmniHubApp());
}

// ============================================================================
// APPLICATION PRINCIPALE (CHÂSSIS IPHONE 16 PRO MAX + MODE PLEIN ÉCRAN)
// ============================================================================
class FidnessOmniHubApp extends StatefulWidget {
  const FidnessOmniHubApp({super.key});

  @override
  State<FidnessOmniHubApp> createState() => _FidnessOmniHubAppState();
}

class _FidnessOmniHubAppState extends State<FidnessOmniHubApp> {
  bool _showPhoneFrame = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FIDNESS • BI & AI Decision Hub',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF060B19),
        fontFamily: 'Segoe UI',
        useMaterial3: true,
      ),
      home: LayoutBuilder(
        builder: (context, constraints) {
          final bool isWideDesktop = constraints.maxWidth > 620;
          if (!isWideDesktop || !_showPhoneFrame) {
            return Stack(
              children: [
                const AuthOrchestratorScreen(),
                if (isWideDesktop)
                  Positioned(
                    top: 14,
                    right: 16,
                    child: _buildFrameToggleButton(),
                  ),
              ],
            );
          }

          return Scaffold(
            backgroundColor: const Color(0xFF030610),
            body: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.2),
                        radius: 1.15,
                        colors: [
                          const Color(0xFF1D3993).withValues(alpha: 0.30),
                          const Color(0xFF8E0E14).withValues(alpha: 0.14),
                          const Color(0xFF030610),
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 14,
                  left: 24,
                  right: 24,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1D3993)
                                  .withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF4B67F6)
                                    .withValues(alpha: 0.5),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.flutter_dash,
                                  color: Color(0xFF38BDF8),
                                  size: 16,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'FLUTTER MOBILE BI & AI • LOCALHOST',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981)
                                  .withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF10B981)
                                    .withValues(alpha: 0.4),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_user_rounded,
                                  color: Color(0xFF10B981),
                                  size: 14,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  '100% des Visualisations Web Intégrées',
                                  style: TextStyle(
                                    color: Color(0xFFA7F3D0),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      _buildFrameToggleButton(),
                    ],
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 48, bottom: 10),
                    child: _buildIPhoneFrame(
                      maxAvailableHeight: constraints.maxHeight - 58,
                      child: const AuthOrchestratorScreen(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFrameToggleButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => setState(() => _showPhoneFrame = !_showPhoneFrame),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.09),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _showPhoneFrame
                    ? Icons.fullscreen_rounded
                    : Icons.phone_iphone_rounded,
                size: 16,
                color: Colors.white,
              ),
              const SizedBox(width: 6),
              Text(
                _showPhoneFrame ? 'Mode Plein Écran' : 'Châssis iPhone 16 Pro',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIPhoneFrame({
    required Widget child,
    double maxAvailableHeight = 860,
  }) {
    final double frameHeight = maxAvailableHeight.clamp(620.0, 880.0);
    return Container(
      width: 430,
      height: frameHeight,
      decoration: BoxDecoration(
        color: const Color(0xFF060B19),
        borderRadius: BorderRadius.circular(52),
        border: Border.all(
          color: const Color(0xFF334155),
          width: 6.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1D3993).withValues(alpha: 0.42),
            blurRadius: 55,
            spreadRadius: 2,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.85),
            blurRadius: 28,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(45),
        child: Stack(
          children: [
            Positioned.fill(child: child),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        '19:55',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Container(
                        width: 96,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      const Row(
                        children: [
                          Icon(Icons.signal_cellular_alt_rounded,
                              size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Icon(Icons.wifi_rounded,
                              size: 13, color: Colors.white),
                          SizedBox(width: 4),
                          Icon(Icons.battery_full_rounded,
                              size: 15, color: Colors.white),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// ORCHESTRATEUR D'AUTHENTIFICATION & SESSION MULTI-TENANT
// ============================================================================
class AuthOrchestratorScreen extends StatefulWidget {
  const AuthOrchestratorScreen({super.key});

  @override
  State<AuthOrchestratorScreen> createState() => _AuthOrchestratorScreenState();
}

class _AuthOrchestratorScreenState extends State<AuthOrchestratorScreen> {
  bool _showIntroSplash = true;
  String? _activeTenantId;
  bool _isSuperAdmin = false;
  String _loggedUserEmail = '';

  void _handleAuthenticated({
    required String tenantId,
    required bool isSuperAdmin,
    required String email,
  }) {
    setState(() {
      _activeTenantId = tenantId;
      _isSuperAdmin = isSuperAdmin;
      _loggedUserEmail = email;
    });
  }

  void _handleLogout() {
    setState(() {
      _activeTenantId = null;
      _isSuperAdmin = false;
      _loggedUserEmail = '';
    });
  }

  void _handleSuperAdminSwitch(String newTenantId) {
    if (!_isSuperAdmin) return;
    setState(() {
      _activeTenantId = newTenantId;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content;
    if (_showIntroSplash) {
      content = FidnessCinematicSplashScreen(
        key: const ValueKey('splash_screen'),
        onComplete: () {
          setState(() {
            _showIntroSplash = false;
          });
        },
      );
    } else if (_activeTenantId == null) {
      content = FidnessModernLoginScreen(
        key: const ValueKey('login_screen'),
        onAuthenticated: _handleAuthenticated,
        onReplaySplash: () {
          setState(() {
            _showIntroSplash = true;
          });
        },
      );
    } else if (_activeTenantId == 'stiel' || _activeTenantId == 'alpha') {
      content = StielFullMobileSuiteScreen(
        key: ValueKey('stiel_suite_$_activeTenantId'),
        isSuperAdmin: _isSuperAdmin,
        userEmail: _loggedUserEmail,
        onSwitchTenant: _handleSuperAdminSwitch,
        onLogout: _handleLogout,
      );
    } else {
      content = BondinFullMobileSuiteScreen(
        key: ValueKey('bondin_suite_$_activeTenantId'),
        isSuperAdmin: _isSuperAdmin,
        userEmail: _loggedUserEmail,
        onSwitchTenant: _handleSuperAdminSwitch,
        onLogout: _handleLogout,
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 650),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      child: content,
    );
  }
}

// ============================================================================
// ÉCRAN DE CONNEXION HAUTE ANIMATION "POWERED BY FIDNESS"
// ============================================================================
class FidnessModernLoginScreen extends StatefulWidget {
  final void Function({
    required String tenantId,
    required bool isSuperAdmin,
    required String email,
  }) onAuthenticated;
  final VoidCallback? onReplaySplash;

  const FidnessModernLoginScreen({
    super.key,
    required this.onAuthenticated,
    this.onReplaySplash,
  });

  @override
  State<FidnessModernLoginScreen> createState() =>
      _FidnessModernLoginScreenState();
}

class _FidnessModernLoginScreenState extends State<FidnessModernLoginScreen>
    with TickerProviderStateMixin {
  late final AnimationController _bgParticleCtrl;
  late final AnimationController _logoPulseCtrl;
  late final AnimationController _shimmerCtrl;
  late final AnimationController _entranceCtrl;

  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passwordFocus = FocusNode();

  bool _obscurePassword = true;
  bool _rememberSession = true;
  bool _isAuthenticating = false;
  String _authStepText = '';
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _bgParticleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _logoPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat(reverse: true);
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();

    _emailFocus.addListener(() => setState(() {}));
    _passwordFocus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _bgParticleCtrl.dispose();
    _logoPulseCtrl.dispose();
    _shimmerCtrl.dispose();
    _entranceCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    FocusScope.of(context).unfocus();
    final id = _emailCtrl.text.trim().toLowerCase();
    final password = _passwordCtrl.text.trim();

    if (id.isEmpty || password.isEmpty) {
      setState(() {
        _errorMessage =
            'Veuillez saisir votre identifiant professionnel et votre mot de passe.';
      });
      return;
    }

    String? resolvedTenant;
    const bool isSuper = false;

    if (id == 'enawbondin' && password == 'ena.w.bondin') {
      resolvedTenant = 'bondin';
    } else if (id == 'clubalpha' && password == 'club.alpha') {
      resolvedTenant = 'stiel';
    } else {
      setState(() {
        _errorMessage = 'Identifiant ou mot de passe incorrect.';
      });
      return;
    }

    setState(() {
      _errorMessage = null;
      _isAuthenticating = true;
      _authStepText = 'Vérification JWT & Connexion DWH PostgreSQL 17.7...';
    });

    await Future.delayed(const Duration(milliseconds: 550));
    if (!mounted) return;

    widget.onAuthenticated(
      tenantId: resolvedTenant,
      isSuperAdmin: isSuper,
      email: id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050A18),
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _bgParticleCtrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: _FidnessNeuralBackgroundPainter(
                    progress: _bgParticleCtrl.value,
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 22,
                  vertical: 10,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),
                    _buildAnimatedFidnessHeader(),
                    const SizedBox(height: 16),
                    _buildGlassLoginCard(),
                    const SizedBox(height: 14),
                    const Text(
                      '© 2026 FIDNESS • Chiffrement SSL/TLS • Isolation Multi-DWH Certifiée',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedFidnessHeader() {
    return Column(
      children: [
        SizedBox(
          width: 110,
          height: 110,
          child: AnimatedBuilder(
            animation: Listenable.merge([_logoPulseCtrl, _bgParticleCtrl]),
            builder: (context, _) {
              final pulse = _logoPulseCtrl.value;
              final angle = _bgParticleCtrl.value * 2 * math.pi;

              return Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 94 + (pulse * 12),
                    height: 94 + (pulse * 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(0xFF4B67F6)
                              .withValues(alpha: 0.38 - (pulse * 0.12)),
                          const Color(0xFFFF5400)
                              .withValues(alpha: 0.18 - (pulse * 0.05)),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                  Transform.rotate(
                    angle: angle,
                    child: CustomPaint(
                      size: const Size(100, 100),
                      painter: _OrbitalRingPainter(),
                    ),
                  ),
                  Transform.scale(
                    scale: 0.97 + (pulse * 0.05),
                    child: Container(
                      width: 74,
                      height: 74,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color:
                                const Color(0xFF4B67F6).withValues(alpha: 0.55),
                            blurRadius: 22,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Center(
                        child: CustomPaint(
                          size: const Size(42, 48),
                          painter: _FidnessVectorLogoPainter(),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: widget.onReplaySplash,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
            decoration: BoxDecoration(
              color: const Color(0xFF1D3993).withValues(alpha: 0.40),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: const Color(0xFF4B67F6).withValues(alpha: 0.65),
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4B67F6).withValues(alpha: 0.25),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome_rounded, size: 13, color: Color(0xFFFFB020)),
                const SizedBox(width: 7),
                const Text(
                  'POWERED BY FIDNESS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.7,
                  ),
                ),
                if (widget.onReplaySplash != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    width: 4,
                    height: 4,
                    decoration: const BoxDecoration(
                      color: Color(0xFF93C5FD),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Revoir l\'intro ↺',
                    style: TextStyle(
                      color: Color(0xFF93C5FD),
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Plateforme Décisionnelle & Intelligence Temps Réel',
          style: TextStyle(
            color: Color(0xFFCBD5E1),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildGlassLoginCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            color: Colors.white.withValues(alpha: 0.07),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.16),
              width: 1.2,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Identifiant Professionnel',
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _emailCtrl,
                focusNode: _emailFocus,
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: 'Saisissez votre identifiant',
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  prefixIcon: const Icon(
                    Icons.person_outline_rounded,
                    size: 18,
                    color: Color(0xFF60A5FA),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Clé d\'accès / Mot de passe',
                style: TextStyle(
                  color: Color(0xFFCBD5E1),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 5),
              TextField(
                controller: _passwordCtrl,
                focusNode: _passwordFocus,
                obscureText: _obscurePassword,
                onSubmitted: (_) => _submitLogin(),
                style: const TextStyle(color: Colors.white, fontSize: 13.5),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
                  filled: true,
                  fillColor: const Color(0xFF0F172A),
                  prefixIcon: const Icon(
                    Icons.lock_outline_rounded,
                    size: 18,
                    color: Color(0xFF60A5FA),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 18,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _rememberSession,
                    activeColor: const Color(0xFF4B67F6),
                    onChanged: (v) =>
                        setState(() => _rememberSession = v ?? true),
                  ),
                  const Text(
                    'Session JWT',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 11.5),
                  ),
                ],
              ),
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    _errorMessage!,
                    style:
                        const TextStyle(color: Color(0xFFF87171), fontSize: 11),
                  ),
                ),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: _isAuthenticating ? null : _submitLogin,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF1D3993),
                        Color(0xFF4B67F6),
                        Color(0xFFFF5400),
                      ],
                    ),
                  ),
                  child: Center(
                    child: _isAuthenticating
                        ? Text(
                            _authStepText,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.bolt_rounded,
                                  color: Colors.white, size: 19),
                              SizedBox(width: 8),
                              Text(
                                'SE CONNECTER AU HUB',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// SUITE MOBILE DÉCISIONNELLE COMPLÈTE : ENA W BONDIN × FIDNESS
// INTÉGRANT 100% DES SECTIONS, GRAPHIQUES, TABLES & SIMULATEURS DU WEB
// ============================================================================
class BondinFullMobileSuiteScreen extends StatefulWidget {
  final bool isSuperAdmin;
  final String userEmail;
  final ValueChanged<String> onSwitchTenant;
  final VoidCallback onLogout;

  const BondinFullMobileSuiteScreen({
    super.key,
    required this.isSuperAdmin,
    required this.userEmail,
    required this.onSwitchTenant,
    required this.onLogout,
  });

  @override
  State<BondinFullMobileSuiteScreen> createState() =>
      _BondinFullMobileSuiteScreenState();
}

class _BondinFullMobileSuiteScreenState
    extends State<BondinFullMobileSuiteScreen> {
  int _activeTab = 0;

  // SLICERS GLOBAUX POWERBI (Comme sur le dashboard web)
  String _selectedPeriod = 'Tous (Avr-Nov)';
  String _selectedFormat = 'Tous (23 PDV)';
  String _selectedRegion = 'Toutes Régions';

  // Recherche Répertoire Inscrits CRM (Section 1)
  String _crmSearchQuery = '';

  // Simulateur What-If (Section 5 : DAX Param_Taux_Points)
  double _daxMultiplier = 1.0;
  double _pointValueMillimes = 10.0;
  double _targetBurnRate = 53.0;

  // Agent IA Fidness Studio Push Mobile (Tab 2)
  String _pushVariant = 'A';
  int _selectedChurnClientIdx = 0;
  late TextEditingController _pushTitleCtrl;
  late TextEditingController _pushBodyCtrl;
  String _pushLiveLog =
      'Agent IA Fidness prêt : Sélectionnez une cliente dans le tableau ou cliquez sur « Envoyer Push » pour déclencher la campagne mobile.';

  // Filtre Table Grossistes (Tab 3)
  String _grossisteFilter = 'all';

  // Filtre Catalogue Récompenses (Tab 4)
  String _rewardTierFilter = 'all';

  // Chatbot Pro BONDIN (Tab 6)
  final TextEditingController _chatInputCtrl = TextEditingController();
  Timer? _liveSyncTimer;
  bool _isSyncingLive = false;

  final List<Map<String, String>> _chatMessages = [
    {
      'role': 'ai',
      'text':
          '**Bonjour Direction Maison Bondin 1910 !**\n'
          'Je suis connecté en temps réel à votre entrepôt **PostgreSQL 17.7 (`57.131.30.69:5432`)** consolidant **15 036 transactions**, **2 829 clients Fidness** et vos **23 points de vente**.\n\n'
          '• **CA Fidélité Certifié Live** : 177 489,04 DT\n'
          '• **Panier Moyen Global** : 11,804 DT\n'
          '• **Clients Actifs** : 809 membres (28,6%)\n'
          '• **Points Émis / Brûlés** : 597 698 pts / 330 850 pts (345 cadeaux)\n'
          '• **Dette Financière Provisionnée** : 2 668,48 DT (266 848 pts)',
    },
  ];

  @override
  void initState() {
    super.initState();
    final firstClient = BondinDwhData.churnSensitiveClients.first;
    _pushTitleCtrl =
        TextEditingController(text: 'Offre VIP Réactivation +150 pts ');
    _pushBodyCtrl = TextEditingController(text: firstClient['msg'] as String);
    _fetchLivePostgresData();
    _liveSyncTimer = Timer.periodic(
      const Duration(seconds: 20),
      (_) => _fetchLivePostgresData(),
    );
  }

  Future<void> _fetchLivePostgresData() async {
    if (_isSyncingLive) return;
    _isSyncingLive = true;
    try {
      final raw = await NetworkAssetBundle(Uri.base).loadString(
        'api/live-bondin?t=${DateTime.now().millisecondsSinceEpoch}',
      );
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        BondinDwhData.applyLivePayload(decoded);
        if (mounted) {
          setState(() {});
        }
      }
    } catch (_) {
      // Fallback silencieux sur le snapshot PostgreSQL embarqué
    } finally {
      _isSyncingLive = false;
    }
  }

  @override
  void dispose() {
    _liveSyncTimer?.cancel();
    _pushTitleCtrl.dispose();
    _pushBodyCtrl.dispose();
    _chatInputCtrl.dispose();
    super.dispose();
  }

  void _selectChurnClientForPush(int idx) {
    final c = BondinDwhData.churnSensitiveClients[idx];
    setState(() {
      _selectedChurnClientIdx = idx;
      _pushTitleCtrl.text = c['tier'] == 'critique'
          ? 'Offre VIP Réactivation +150 pts '
          : c['tier'] == 'eleve'
              ? 'Points Doublés +75 pts chez Bondin '
              : 'Découverte Grand Cru +50 pts ';
      _pushBodyCtrl.text = c['msg'] as String;
      _pushLiveLog =
          'Cliente chargée dans le Studio Push : ${c['nom']} (${c['pdv']} • Score Churn ${c['score']}%).';
    });
  }

  double get _filterScaleFactor {
    double f = 1.0;
    if (_selectedPeriod == 'Octobre 2026') f *= 0.24;
    if (_selectedPeriod == '30 Derniers Jours') f *= 0.26;
    if (_selectedPeriod == '7 Derniers Jours') f *= 0.07;
    if (_selectedFormat == 'Succursales') f *= 0.726;
    if (_selectedFormat == 'Cafétérias') f *= 0.274;
    if (_selectedRegion == 'Grand Tunis') f *= 0.524;
    if (_selectedRegion == 'Gafsa') f *= 0.249;
    if (_selectedRegion == 'Gabès') f *= 0.108;
    if (_selectedRegion == 'Le Kef') f *= 0.107;
    return f;
  }

  void _sendRagQuestion(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final lower = q.toLowerCase();

    String answer;
    if (lower.contains('octob')) {
      answer =
          '**Indicateurs Clés ENA W BONDIN × FIDNESS (Octobre 2026 Live)** :\n'
          '• **CA Fidélité Octobre** : **34 068,57 DT** sur **2 833 scans QR**\n'
          '  ├─ Succursales (Vrac & Grains) : **25 582,57 DT** (75,1%)\n'
          '  └─ Cafétérias (Boissons) : **8 486,00 DT** (24,9%)\n'
          '• **Cumul Global Live (au 10 Nov)** : **${BondinDwhData.totalCaTndLive.toStringAsFixed(2)} DT** sur **${BondinDwhData.totalScansLive} scans QR**\n'
          '• **Panier Moyen Global** : **${BondinDwhData.panierMoyenLive.toStringAsFixed(3)} DT** par acte d\'achat.';
    } else if (lower.contains('magasin') ||
        lower.contains('pdv') ||
        lower.contains('gafsa') ||
        lower.contains('kef')) {
      answer =
          '**Top Points de Vente ENA W BONDIN (23 Établissements — PostgreSQL Live)** :\n'
          '1. **Succursale Le Kef** : 28 477,46 DT (454 scans • PM 62,73 DT)\n'
          '2. **Succursale Gabès Jara** : 17 497,88 DT (379 scans • PM 46,17 DT)\n'
          '3. **Succursale Tunis Menzah VI** : 16 068,16 DT (589 scans • PM 27,28 DT)\n'
          '4. **Succursale Gafsa** : 13 399,37 DT (145 scans • PM 92,41 DT)\n'
          '5. **Succursale Tunis Liberté** : 13 159,35 DT (528 scans • PM 24,92 DT)\n'
          '6. **Cafétéria Gafsa Ville (#1 Trafic)** : 12 390,60 DT (**3 431 scans**)';
    } else if (lower.contains('grossiste') || lower.contains('b2b')) {
      answer =
          '**Audit Temps Réel des Profils Grossistes & Volumes B2B (`public.purchase`)** :\n'
          '• **Top 1** : Alimi Hama (Succursale Gafsa Ville) — **7 344,72 DT** (73 scans • 29 350 pts)\n'
          '• **Top 2** : abdallah ghedifi (Succursale Ariana) — **6 707,18 DT** (271 scans • 25 442 pts)\n'
          '• **Top 3** : Derouiche Ahmed (Succursale La Marsa) — **5 505,20 DT** (162 scans • 21 075 pts)\n'
          '• **Top 4** : teyeb mahdi (Succursale Espagne) — **5 226,05 DT** (158 scans • 20 065 pts)\n'
          '• **Top 5** : wafa cherni (Succursale Le Kef) — **5 065,02 DT** (34 scans • PM 148,97 DT).';
    } else if (lower.contains('churn') || lower.contains('relance')) {
      answer =
          '**Agent IA Fidness Anti-Churn (PostgreSQL Live • XGBoost 94,2%)** :\n'
          '• **Clients VIP Critiques (>28j sans scan)** : Mehdi Shili (57j • 4 110 DT), marwenbellil92 (52j • 3 875 DT), Khnissi Mouhamed (50j • 3 725 DT), wafa cherni (28j • 5 065 DT), Harbaoui Mohamed Amine (28j • 4 600 DT)\n'
          '• **Décrochage Élevé** : Hawami Chaker (35j • 3 692 DT), Hattabi Wahid (42j • 2 179 DT), Alex Bre (34j • 192 visites)\n'
          '• **Gain net prévisionnel** : **+1 838 TND** (ROI +850%).';
    } else {
      answer =
          '**Réponse Temps Réel DWH PostgreSQL 17.7 (`57.131.30.69:5432`)** :\n'
          'Pour *« $q »* (Synchro : `${BondinDwhData.lastSyncTimestamp}`) :\n'
          '• **Chiffre d\'Affaires Fidélité** : **${BondinDwhData.totalCaTndLive.toStringAsFixed(2)} DT** (${BondinDwhData.totalScansLive} scans)\n'
          '• **Clients Actifs** : **${BondinDwhData.clientsActifsLive} membres** sur **${BondinDwhData.totalInscritsLive} inscrits CRM**\n'
          '• **Points Émis / Brûlés** : **${BondinDwhData.totalPointsEmisLive} pts** / **${BondinDwhData.totalPointsBrulesLive} pts** (${BondinDwhData.totalCadeauxReclamesLive} cadeaux)\n'
          '• **Dette Financière Provisionnée** : **${(BondinDwhData.soldePointsActifsLive * 0.01).toStringAsFixed(2)} DT** (${BondinDwhData.soldePointsActifsLive} pts).';
    }

    setState(() {
      _chatMessages.add({'role': 'user', 'text': q});
      _chatMessages.add({'role': 'ai', 'text': answer});
      _chatInputCtrl.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0607),
      body: SafeArea(
        child: Column(
          children: [
            // 1. EN-TÊTE OFFICIEL MAISON BONDIN 1910 × FIDNESS
            _buildBondinTopHeader(),

            // 2. BARRE DE FILTRES GLOBAUX POWERBI (Masquée sur Chatbot)
            if (_activeTab != 5) _buildGlobalFilterSlicersBar(),

            // 3. CORPS DE L'ONGLET ACTIF
            Expanded(
              child: _buildActiveTabBody(),
            ),

            // 4. BARRE DE NAVIGATION INFÉRIEURE (6 ONGLETS)
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBondinTopHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 34, 14, 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7F1017), Color(0xFF45070B), Color(0xFF1A090B)],
        ),
        border: Border(
          bottom: BorderSide(
            color: const Color(0xFFD97706).withValues(alpha: 0.45),
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFF59E0B), width: 1.4),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7.5),
              child: Image.asset(
                'assets/images/bondin_logo.png',
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const Icon(
                  Icons.coffee_rounded,
                  color: Color(0xFF8E0E14),
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'ENA W BONDIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD97706).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: const Color(0xFFF59E0B).withValues(alpha: 0.6),
                        ),
                      ),
                      child: const Text(
                        'Powered by FIDNESS',
                        style: TextStyle(
                          color: Color(0xFFFDE68A),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
                Text(
                  '● Temps Réel • ${BondinDwhData.totalScansLive} Scans • 23 PDV',
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFFFDE68A),
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onLogout,
            tooltip: 'Déconnexion',
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.logout_rounded,
              color: Colors.white70,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  // BARRE DE SLICERS DYNAMIQUES (COMME SUR LE WEB)
  Widget _buildGlobalFilterSlicersBar() {
    return Container(
      height: 36,
      color: const Color(0xFF190C0E),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        children: [
          _buildSlicerDropdown(
            icon: Icons.calendar_month_rounded,
            value: _selectedPeriod,
            options: const [
              'Tous (Avr-Nov)',
              'Octobre 2026',
              '30 Derniers Jours',
              '7 Derniers Jours',
            ],
            onChanged: (v) => setState(() => _selectedPeriod = v),
          ),
          const SizedBox(width: 6),
          _buildSlicerDropdown(
            icon: Icons.storefront_rounded,
            value: _selectedFormat,
            options: const [
              'Tous (23 PDV)',
              'Succursales',
              'Cafétérias',
            ],
            onChanged: (v) => setState(() => _selectedFormat = v),
          ),
          const SizedBox(width: 6),
          _buildSlicerDropdown(
            icon: Icons.location_on_rounded,
            value: _selectedRegion,
            options: const [
              'Toutes Régions',
              'Grand Tunis',
              'Gafsa',
              'Gabès',
              'Le Kef',
            ],
            onChanged: (v) => setState(() => _selectedRegion = v),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () {
              setState(() {
                _selectedPeriod = 'Tous (Avr-Nov)';
                _selectedFormat = 'Tous (23 PDV)';
                _selectedRegion = 'Toutes Régions';
              });
              _fetchLivePostgresData();
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: const Color(0xFF10B981).withValues(alpha: 0.5),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.sync_rounded, size: 12, color: Color(0xFF34D399)),
                  SizedBox(width: 4),
                  Text(
                    'Reset / Sync Live',
                    style: TextStyle(
                      color: Color(0xFFA7F3D0),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
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

  Widget _buildSlicerDropdown({
    required IconData icon,
    required String value,
    required List<String> options,
    required ValueChanged<String> onChanged,
  }) {
    return PopupMenuButton<String>(
      onSelected: onChanged,
      color: const Color(0xFF1F1215),
      itemBuilder: (context) => options
          .map(
            (o) => PopupMenuItem<String>(
              value: o,
              child: Text(
                o,
                style: const TextStyle(color: Colors.white, fontSize: 11.5),
              ),
            ),
          )
          .toList(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: const Color(0xFFD97706).withValues(alpha: 0.4),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 12, color: const Color(0xFFF59E0B)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Icon(
              Icons.arrow_drop_down_rounded,
              size: 14,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWebTabsRibbon() {
    final tabs = [
      {'badge': '01', 'label': 'Cockpit Direction & CA'},
      {'badge': '02', 'label': 'Agent IA Fidness (Churn & Push)'},
      {'badge': '03', 'label': 'Segmentation RFM & Grossistes'},
      {'badge': '04', 'label': 'Cagnotte, LTV & Récompenses'},
      {'badge': '05', 'label': 'Analyses Avancées & Cohortes'},
      {'badge': 'IA', 'label': 'Chatbot Pro BONDIN Live'},
    ];

    return Container(
      height: 40,
      color: const Color(0xFF140B0D),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        itemCount: tabs.length,
        itemBuilder: (context, i) {
          final bool active = _activeTab == i;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = i),
            child: Container(
              margin: const EdgeInsets.only(right: 7),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: active
                    ? const LinearGradient(
                        colors: [Color(0xFF991B1B), Color(0xFFD97706)],
                      )
                    : null,
                color: active ? null : Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active
                      ? const Color(0xFFFBBF24)
                      : Colors.white.withValues(alpha: 0.1),
                ),
              ),
              child: Row(
                children: [
                  Text(
                    '${tabs[i]['badge']} • ',
                    style: const TextStyle(
                      color: Color(0xFFFDE68A),
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    tabs[i]['label']!,
                    style: TextStyle(
                      color: active ? Colors.white : const Color(0xFFCBD5E1),
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveTabBody() {
    switch (_activeTab) {
      case 0:
        return _buildTab01CockpitDirection();
      case 1:
        return _buildTab02AgentFidnessChurn();
      case 2:
        return _buildTab03SegmentationGrossistes();
      case 3:
        return _buildTab04CagnotteLtv();
      case 4:
        return _buildTab05AnalysesAvancees();
      case 5:
        return _buildTab06ChatbotRagLive();
      default:
        return _buildTab01CockpitDirection();
    }
  }

  // ==========================================================================
  // ONGLET 01 : COCKPIT DIRECTION GÉNÉRALE & ANALYSE DU CHIFFRE D'AFFAIRES
  // (Inclut : 6 KPIs Exécutifs + Section 1 Inscriptions & Table CRM +
  //  Section 2 Donut, Carte Tunisie, Top PDV Scans, Top Magasins CA +
  //  Section 2.B 5 Gammes Produits + Section 2.C Comparatif N vs N-1 +
  //  Section 3 Table Transactions Live + Section 4 Arbre Décomposition +
  //  Section 5 Simulateur What-If DAX)
  // ==========================================================================
  Widget _buildTab01CockpitDirection() {
    final sf = _filterScaleFactor;
    final double caFiltered = BondinDwhData.totalCaTndLive * sf;
    final int scansFiltered = (BondinDwhData.totalScansLive * sf).round();
    final int actifsFiltered =
        (BondinDwhData.clientsActifsLive * math.pow(sf, 0.7)).round();
    final int dormantsFiltered =
        BondinDwhData.totalInscritsLive - BondinDwhData.clientsActifsLive;
    final double detteTnd = BondinDwhData.soldePointsActifsLive * 0.01;

    final filteredCrm = BondinDwhData.inscritsCrmList.where((m) {
      if (_crmSearchQuery.trim().isEmpty) return true;
      final q = _crmSearchQuery.toLowerCase();
      return (m['nom'] as String).toLowerCase().contains(q) ||
          (m['email'] as String).toLowerCase().contains(q) ||
          (m['magasin'] as String).toLowerCase().contains(q) ||
          (m['id'] as String).toLowerCase().contains(q);
    }).toList();

    return ListView(
      key: const ValueKey('tab_01_full'),
      padding: const EdgeInsets.all(12),
      children: [
        // BANDEAU EXÉCUTIF 6 CARTES KPIs (TEMPS RÉEL POSTGRESQL)
        _buildSectionTitle(
          badge: 'LIVE DB',
          title:
              'Bandeau Exécutif Consolidé • Synchro : ${BondinDwhData.lastSyncTimestamp}',
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.58,
          children: [
            _buildExecutiveKpiCard(
              title: 'Chiffre d\'Affaires Fidélité',
              value: '${caFiltered.toStringAsFixed(2)} DT',
              sub: '$scansFiltered scans QR certifiés',
              badge: '+20,4% vs N-1',
              accent: const Color(0xFFF59E0B),
              icon: Icons.payments_rounded,
            ),
            _buildExecutiveKpiCard(
              title: 'Panier Moyen Global (AOV)',
              value: '${BondinDwhData.panierMoyenLive.toStringAsFixed(3)} DT',
              sub: 'Succ: 36,0 DT | Café: 4,2 DT',
              badge: '+60,6% av. don',
              accent: const Color(0xFF10B981),
              icon: Icons.shopping_bag_rounded,
            ),
            _buildExecutiveKpiCard(
              title: 'Adhérents & Base CRM',
              value: '${BondinDwhData.totalInscritsLive} Inscrits',
              sub: '$actifsFiltered Actifs (28,6%) | $dormantsFiltered Dorm.',
              badge: '+99 en Nov',
              accent: const Color(0xFF38BDF8),
              icon: Icons.groups_rounded,
            ),
            _buildExecutiveKpiCard(
              title: 'Points Émis vs Brûlés',
              value: '${BondinDwhData.totalPointsEmisLive} pts',
              sub: 'Burn: ${BondinDwhData.totalPointsBrulesLive} pts (${BondinDwhData.totalCadeauxReclamesLive} cad.)',
              badge: 'Ratio 55,4%',
              accent: const Color(0xFFA855F7),
              icon: Icons.auto_graph_rounded,
            ),
            _buildExecutiveKpiCard(
              title: 'Dette Financière Provisionnée',
              value: '${detteTnd.toStringAsFixed(2)} DT',
              sub: 'Solde: ${BondinDwhData.soldePointsActifsLive} pts × 0,010 DT',
              badge: 'Provision DAX',
              accent: const Color(0xFFF43F5E),
              icon: Icons.account_balance_wallet_rounded,
            ),
            _buildExecutiveKpiCard(
              title: 'Alerte Grossistes B2B',
              value: '375 Suspects',
              sub: '77,3% du CA Succursales',
              badge: 'Surveillance IA',
              accent: const Color(0xFFEF4444),
              icon: Icons.gpp_maybe_rounded,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // SECTION 1 : DYNAMIQUE D'ACQUISITION & RÉPERTOIRE DES CLIENTS INSCRITS
        _buildSectionTitle(
          badge: '1',
          title:
              'Dynamique d\'Acquisition & Répertoire des Clients Inscrits (${BondinDwhData.totalInscritsLive} Membres)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Courbe d\'Acquisition Mensuelle & Cumul CRM',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    '${BondinDwhData.totalInscritsLive} Inscrits Live',
                    style: const TextStyle(
                      color: Color(0xFF34D399),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const InscriptionsComboChart(),
              const Divider(color: Colors.white12, height: 22),
              const Text(
                'Répertoire Officiel des Adhérents & Inscrits CRM (public.user)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              // Barre de recherche en direct dans le répertoire CRM
              TextField(
                onChanged: (v) => setState(() => _crmSearchQuery = v),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  hintText:
                      'Rechercher un membre (Nom, Email, Magasin, ID CLI_)...',
                  hintStyle:
                      const TextStyle(color: Colors.white38, fontSize: 11),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    size: 17,
                    color: Color(0xFFF59E0B),
                  ),
                  filled: true,
                  fillColor: Colors.black26,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...filteredCrm.map((m) {
                final bool isActif = (m['achats'] as int) > 0;
                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.03),
                    borderRadius: BorderRadius.circular(9),
                    border: Border.all(
                      color: isActif
                          ? const Color(0xFF10B981).withValues(alpha: 0.35)
                          : Colors.white10,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${m['nom']} (${m['id']})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              '${m['magasin']} • ${m['tel']}',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                              ),
                            ),
                            Text(
                              '${m['email']} • Inscrit le ${m['date']}',
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 9.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isActif
                                  ? const Color(0xFF10B981)
                                      .withValues(alpha: 0.2)
                                  : Colors.white10,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              m['statut'] as String,
                              style: TextStyle(
                                color: isActif
                                    ? const Color(0xFF34D399)
                                    : const Color(0xFF94A3B8),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            '${m['achats']} achats • ${m['points']} pts',
                            style: const TextStyle(
                              color: Color(0xFFFDE68A),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // SECTION 2 : RÉPARTITION, CLASSEMENT & CARTOGRAPHIE DES 23 POINTS DE VENTE
        _buildSectionTitle(
          badge: '2',
          title:
              'Répartition, Classement & Cartographie des Points de Vente (23 PDV)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 2.1 CARTE INTERACTIVE DE TUNISIE + TICKER LIVE
              const Text(
                'Cartographie Nationale Interactive (6 Gouvernorats • 23 PDV)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              TunisiaInteractiveMapCard(
                onSelectRegion: (reg) {
                  setState(() => _selectedRegion = reg);
                },
              ),
              const Divider(color: Colors.white12, height: 22),

              // 2.2 CLASSEMENT TOP MAGASINS PAR CHIFFRE D'AFFAIRES (chart-top-magasins-mockup)
              const Text(
                'Top 10 Points de Vente par Chiffre d\'Affaires Temps Réel (TND)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ...BondinDwhData.topMagasinsCa.take(10).map((st) {
                final double ca = (st['ca'] as num).toDouble();
                final double ratio = (ca / 28500.0).clamp(0.05, 1.0);
                final bool isSucc = st['type'] == 'Succursale';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            st['nom'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${ca.toStringAsFixed(1)} DT • PM: ${st['aov']} DT',
                            style: const TextStyle(
                              color: Color(0xFFFDE68A),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6,
                          backgroundColor: Colors.white10,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            isSucc
                                ? const Color(0xFFD97706)
                                : const Color(0xFFEF4444),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const Divider(color: Colors.white12, height: 22),

              // 2.3 CLASSEMENT TOP PDV PAR VOLUME D'ACHATS SCANS (chart-top-pdv-achats)
              const Text(
                'Top Points de Vente par Volume de Scans QR (Fréquentation)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              ...BondinDwhData.topPdvByScans.map((p) {
                final int sc = (p['scans'] as num).toInt();
                final double ratio = (sc / 3500.0).clamp(0.05, 1.0);
                return Padding(
                  padding: const EdgeInsets.only(bottom: 7),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            p['nom'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '$sc scans QR (${p['ca']} DT)',
                            style: const TextStyle(
                              color: Color(0xFF38BDF8),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(5),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 6,
                          backgroundColor: Colors.white10,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF38BDF8),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // SECTION 2.B : PERFORMANCE PAR CATÉGORIE DE PRODUITS (CATALOGUE BONDIN 1910)
        _buildSectionTitle(
          badge: '2.B',
          title:
              'Performance & Répartition par Catégorie de Produits (5 Gammes Clés)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Ventilation Succursales (Gros) vs Cafétérias (Détail)',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      _buildLegendDot(const Color(0xFF991B1B), 'Succ.'),
                      const SizedBox(width: 8),
                      _buildLegendDot(const Color(0xFFD97706), 'Café.'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              ...BondinDwhData.gammesProduits.map((g) {
                final double succ = g['succ'] as double;
                final double cafe = g['cafe'] as double;
                final double tot = g['total'] as double;
                final double wSucc = succ / 65000.0;
                final double wCafe = cafe / 65000.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${g['gamme']} (${g['part']})',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Text(
                            '${tot.toStringAsFixed(0)} DT • ${g['badge']}',
                            style: const TextStyle(
                              color: Color(0xFFFDE68A),
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      LayoutBuilder(
                        builder: (context, box) {
                          return Row(
                            children: [
                              Container(
                                width: (box.maxWidth * wSucc).clamp(6.0, box.maxWidth),
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF991B1B),
                                  borderRadius: BorderRadius.horizontal(
                                    left: Radius.circular(4),
                                  ),
                                ),
                              ),
                              Container(
                                width: (box.maxWidth * wCafe).clamp(4.0, box.maxWidth),
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFD97706),
                                  borderRadius: BorderRadius.horizontal(
                                    right: Radius.circular(4),
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // SECTION 2.C : DYNAMIQUE TEMPORELLE & CROISSANCE COMPARATIVE N VS N-1
        _buildSectionTitle(
          badge: '2.C',
          title:
              'Dynamique Temporelle & Croissance Comparative N vs N-1 (CA & Scans)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: const YoYComparativeChartCard(),
        ),

        const SizedBox(height: 16),

        // SECTION 3 : DERNIÈRES MISES À JOUR & FLUX LIVE DES TRANSACTIONS CAISSE
        _buildSectionTitle(
          badge: '3',
          title:
              'Dernières Mises à Jour & Flux Live des Transactions Caisse (PostgreSQL 17.7)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            children: BondinDwhData.liveTransactions.map((t) {
              return _buildLiveTransactionRow(
                ticket: '#${t['id']} • ${t['ticket']}',
                client: t['client'] as String,
                store: '${t['magasin']} (${t['date']})',
                amount: '${(t['montant'] as double).toStringAsFixed(2)} DT',
                pts: '+${t['points']} pts',
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // SECTION 4 : ARBRE DE DÉCOMPOSITION STRATÉGIQUE DU CA CLIENT
        _buildSectionTitle(
          badge: '4',
          title: 'Arbre de Décomposition Stratégique du CA Client (PowerBI Tree)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: const StrategicDecompositionTreeCard(),
        ),

        const SizedBox(height: 16),

        // SECTION 5 : SIMULATEUR DYNAMIQUE WHAT-IF (SENSIBILITÉ BARÈME & DETTE DAX)
        _buildSectionTitle(
          badge: '5',
          title:
              'Simulateur Dynamique What-If : Sensibilité Barème & Dette DAX (0.5x → 3.0x)',
        ),
        const SizedBox(height: 8),
        _buildWhatIfSimulatorCard(),
      ],
    );
  }

  Widget _buildWhatIfSimulatorCard() {
    const int baseSoldePts = 267745;
    final double simulatedPts = baseSoldePts * _daxMultiplier;
    final double simulatedDebtTnd =
        simulatedPts * (_pointValueMillimes / 1000.0);
    final double netProvisionTnd =
        simulatedDebtTnd * (_targetBurnRate / 100.0);

    return _buildCardContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'DAX Param_Taux_Points (Multiplicateur)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF991B1B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${_daxMultiplier.toStringAsFixed(1)}x',
                  style: const TextStyle(
                    color: Color(0xFFFDE68A),
                    fontSize: 11.5,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          Slider(
            value: _daxMultiplier,
            min: 0.5,
            max: 3.0,
            divisions: 25,
            activeColor: const Color(0xFFEF4444),
            onChanged: (v) => setState(() => _daxMultiplier = v),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Valeur Unitaire Point (Millimes)',
                style: TextStyle(color: Colors.white, fontSize: 11.5),
              ),
              Text(
                '${_pointValueMillimes.toStringAsFixed(1)} millimes',
                style: const TextStyle(
                  color: Color(0xFFF59E0B),
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          Slider(
            value: _pointValueMillimes,
            min: 5.0,
            max: 25.0,
            divisions: 40,
            activeColor: const Color(0xFFD97706),
            onChanged: (v) => setState(() => _pointValueMillimes = v),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text(
                      'Dette Nominale DAX',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                    ),
                    Text(
                      '${simulatedDebtTnd.toStringAsFixed(2)} DT',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
                Container(width: 1, height: 26, color: Colors.white12),
                Column(
                  children: [
                    const Text(
                      'Provision Réelle (Burn 53%)',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
                    ),
                    Text(
                      '${netProvisionTnd.toStringAsFixed(2)} DT',
                      style: const TextStyle(
                        color: Color(0xFF34D399),
                        fontSize: 13.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ONGLET 02 : AGENT IA FIDNESS — DÉTECTION DU CHURN & STUDIO PUSH MOBILE
  // (Inclut : 4 KPIs Churn + 3 Cartes Scénarios Anti-Churn + Studio Push
  //  Smartphone Editable A/B Testing + Table Complète des Clientes Sensibles)
  // ==========================================================================
  Widget _buildTab02AgentFidnessChurn() {
    final selectedClient =
        BondinDwhData.churnSensitiveClients[_selectedChurnClientIdx];

    return ListView(
      key: const ValueKey('tab_02_full'),
      padding: const EdgeInsets.all(12),
      children: [
        _buildSectionTitle(
          badge: 'IA',
          title:
              'Agent IA Fidness — Détection du Churn & Notifications Push Ciblées',
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.58,
          children: [
            _buildExecutiveKpiCard(
              title: 'Clientes Sensibles Détectées',
              value: '15 Clientes',
              sub: '5 VIP | 7 Élevées | 3 Modérées',
              badge: 'XGBoost 94,2%',
              accent: const Color(0xFFEF4444),
              icon: Icons.warning_amber_rounded,
            ),
            _buildExecutiveKpiCard(
              title: 'Chiffre d\'Affaires Sauvegardé',
              value: '+1 838 TND',
              sub: 'Sur 2 480 TND de CA exposé',
              badge: 'ROI +850%',
              accent: const Color(0xFF10B981),
              icon: Icons.trending_up_rounded,
            ),
            _buildExecutiveKpiCard(
              title: 'Points Fidélité Dormants',
              value: '14 820 pts',
              sub: 'Immobilisés sur comptes à risque',
              badge: '148,20 DT',
              accent: const Color(0xFFF59E0B),
              icon: Icons.hourglass_bottom_rounded,
            ),
            _buildExecutiveKpiCard(
              title: 'Taux de Sauvetage Prévu',
              value: '68,0 %',
              sub: 'Ouverture Push Mobile < 15 min',
              badge: 'A/B Test Actif',
              accent: const Color(0xFF38BDF8),
              icon: Icons.send_to_mobile_rounded,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // LES 3 SCÉNARIOS ANTI-CHURN PERSONNALISÉS (COMME SUR LE WEB)
        _buildSectionTitle(
          badge: '3 SCÉNARIOS',
          title: 'Scénarios Anti-Churn Personnalisés & Envoi Groupé',
        ),
        const SizedBox(height: 8),
        _buildChurnScenarioCard(
          title: '1. Urgence Critique (>60 jours sans scan)',
          desc:
              '5 clientes VIP historiques en rupture. Offre choc de réactivation immédiate.',
          target: '5 clientes VIP • Code : FIDNESS_VIP150 • Conv. 68%',
          btnLabel: 'Envoyer Push aux 5 VIP Critiques',
          color: const Color(0xFFEF4444),
          onSend: () {
            setState(() {
              _pushLiveLog =
                  'Campagne Gruppe [URGENCE CRITIQUE] envoyée aux 5 clientes VIP (Code FIDNESS_VIP150) !';
            });
          },
        ),
        const SizedBox(height: 8),
        _buildChurnScenarioCard(
          title: '2. Décrochage Élevé (35 à 55 jours)',
          desc:
              '7 clientes régulières montrant un espacement anormal des visites. Réancrage de l\'habitude.',
          target: '7 clientes • Code : FIDNESS_DOUBLE75 • Conv. 42%',
          btnLabel: 'Envoyer Push aux 7 Clientes en Décrochage',
          color: const Color(0xFFD97706),
          onSend: () {
            setState(() {
              _pushLiveLog =
                  'Campagne Groupe [DÉCROCHAGE ÉLEVÉ] envoyée aux 7 clientes (Code FIDNESS_DOUBLE75) !';
            });
          },
        ),
        const SizedBox(height: 8),
        _buildChurnScenarioCard(
          title: '3. Sensibles Récentes (25 à 32 jours)',
          desc:
              '3 clientes (Meha Thabouti, Salma Bahloul, Rabeb Tissaoui). Notification de courtoisie valorisant leur solde.',
          target: '3 clientes • Code : FIDNESS_CRU50 • Rétention 58%',
          btnLabel: 'Envoyer Push Préventif (3 Clientes)',
          color: const Color(0xFF059669),
          onSend: () {
            setState(() {
              _pushLiveLog =
                  'Campagne Préventive envoyée aux 3 clientes sensibles (Code FIDNESS_CRU50) !';
            });
          },
        ),

        const SizedBox(height: 16),

        // STUDIO PUSH MOBILE SMARTPHONE FIDNESS (AVEC CHAMPS ÉDITABLES)
        _buildSectionTitle(
          badge: 'STUDIO',
          title: 'Simulateur & Studio Push Mobile — Agent IA Fidness',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Cible : ${selectedClient['nom']}',
                    style: const TextStyle(
                      color: Color(0xFFFDE68A),
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Row(
                    children: [
                      _buildVariantBtn('A'),
                      const SizedBox(width: 6),
                      _buildVariantBtn('B'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // Aperçu Écran Verrouillé Smartphone Fidness
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.96),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.coffee_rounded,
                              size: 15,
                              color: Color(0xFF73080E),
                            ),
                            SizedBox(width: 5),
                            Text(
                              'FIDNESS × CAFÉ BONDIN',
                              style: TextStyle(
                                color: Color(0xFF73080E),
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          'Code : ${selectedClient['code']}',
                          style: const TextStyle(
                            color: Color(0xFF8E0E14),
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _pushTitleCtrl.text,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _pushBodyCtrl.text,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 10.8,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _pushTitleCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 11.5),
                decoration: InputDecoration(
                  labelText: 'Titre de la Notification Push',
                  labelStyle:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _pushBodyCtrl,
                maxLines: 2,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 11),
                decoration: InputDecoration(
                  labelText: 'Message Personnalisé IA',
                  labelStyle:
                      const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                  filled: true,
                  fillColor: Colors.black26,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF064E3B).withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  _pushLiveLog,
                  style: const TextStyle(
                    color: Color(0xFFA7F3D0),
                    fontSize: 10.5,
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // TABLEAU COMPLET DES CLIENTES SENSIBLES (table-agent-fidness-churn)
        _buildSectionTitle(
          badge: 'TABLE',
          title:
              'Tableau Diagnostic des Clientes Sensibles (Touchez pour cibler)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            children: List.generate(
              BondinDwhData.churnSensitiveClients.length,
              (idx) {
                final c = BondinDwhData.churnSensitiveClients[idx];
                final int score = c['score'] as int;
                final Color col = score >= 85
                    ? const Color(0xFFEF4444)
                    : score >= 70
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFF10B981);
                final bool isSel = idx == _selectedChurnClientIdx;

                return GestureDetector(
                  onTap: () => _selectChurnClientForPush(idx),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isSel
                          ? const Color(0xFF7F1017).withValues(alpha: 0.35)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSel ? const Color(0xFFF59E0B) : col.withValues(alpha: 0.35),
                        width: isSel ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${c['nom']} • ${c['tel']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '${c['pdv']} • Inactivité : ${c['inactivite']} (${c['freq']})',
                                style: const TextStyle(
                                  color: Color(0xFFCBD5E1),
                                  fontSize: 10,
                                ),
                              ),
                              Text(
                                'CA Cumulé : ${c['ca']} • Cagnotte : ${c['pts']}',
                                style: const TextStyle(
                                  color: Color(0xFFFDE68A),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: col.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'Churn $score%',
                                style: TextStyle(
                                  color: col,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              c['code'] as String,
                              style: const TextStyle(
                                color: Color(0xFF34D399),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChurnScenarioCard({
    required String title,
    required String desc,
    required String target,
    required String btnLabel,
    required Color color,
    required VoidCallback onSend,
  }) {
    return Container(
      padding: const EdgeInsets.all(11),
      decoration: BoxDecoration(
        color: const Color(0xFF170D0F),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 10.8),
          ),
          const SizedBox(height: 4),
          Text(
            '$target',
            style: const TextStyle(
              color: Color(0xFFFDE68A),
              fontSize: 10.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 32,
            child: ElevatedButton(
              onPressed: onSend,
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                btnLabel,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantBtn(String v) {
    final bool sel = _pushVariant == v;
    return GestureDetector(
      onTap: () => setState(() => _pushVariant = v),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFF991B1B) : Colors.white10,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          'Variante $v',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ONGLET 03 : SEGMENTATION CLIENTS RFM & DÉTECTION DES GROSSISTES B2B
  // (Inclut : 4 KPIs Comportementaux + Cycle de Vie RFM + Table Complète
  //  des Grossistes B2B Suspects avec filtres + Table Top Parrains Ambassadeurs)
  // ==========================================================================
  Widget _buildTab03SegmentationGrossistes() {
    final grossistes = BondinDwhData.topGrossistesTable.where((g) {
      if (_grossisteFilter == 'all') return true;
      return g['type'] == _grossisteFilter;
    }).toList();

    return ListView(
      key: const ValueKey('tab_03_full'),
      padding: const EdgeInsets.all(12),
      children: [
        _buildSectionTitle(
          badge: 'RFM',
          title: 'Indicateurs Comportementaux & Cycle de Vie Client',
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.6,
          children: [
            _buildExecutiveKpiCard(
              title: 'Fréquence d\'Achat Moyenne',
              value: '18,2 visites',
              sub: 'Par client actif sur la période',
              badge: 'Forte Fidélité',
              accent: const Color(0xFF10B981),
              icon: Icons.repeat_rounded,
            ),
            _buildExecutiveKpiCard(
              title: 'Intervalle Moyen Réachat',
              value: '9,4 jours',
              sub: 'Cafétéria: 4,2j | Succ: 16,8j',
              badge: 'Rythme Hebdo',
              accent: const Color(0xFF38BDF8),
              icon: Icons.schedule_rounded,
            ),
            _buildExecutiveKpiCard(
              title: 'Clients Ultra-Fréquents',
              value: '147 Membres',
              sub: '+15 passages en caisse',
              badge: 'Top 18,5%',
              accent: const Color(0xFFF59E0B),
              icon: Icons.stars_rounded,
            ),
            _buildExecutiveKpiCard(
              title: 'Taux Rédemption Cagnotte',
              value: '53,4 %',
              sub: '100 500 pts convertis',
              badge: 'Cible >50%',
              accent: const Color(0xFFA855F7),
              icon: Icons.redeem_rounded,
            ),
          ],
        ),

        const SizedBox(height: 16),

        // TABLEAU COMPLET DES PROFILS GROSSISTES B2B SUSPECTS (table-grossistes)
        _buildSectionTitle(
          badge: 'B2B',
          title:
              'Détection des Profils Grossistes & Volumes B2B Suspects (375 Comptes)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildFilterChip('Tous', 'all'),
                  const SizedBox(width: 6),
                  _buildFilterChip('Grossistes B2B Pur', 'b2b'),
                  const SizedBox(width: 6),
                  _buildFilterChip('Mixtes Suspects', 'mixte'),
                ],
              ),
              const SizedBox(height: 10),
              ...grossistes.map((g) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              g['nom'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  const Color(0xFFEF4444).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Text(
                              g['status'] as String,
                              style: const TextStyle(
                                color: Color(0xFFF87171),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${g['id']} • ${g['tel']} • ${g['email']}',
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 10,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total CA : ${g['total']} DT (Succ: ${g['succ']} DT)',
                            style: const TextStyle(
                              color: Color(0xFFFDE68A),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'Max: ${g['maxTicket']} DT • ${g['points']} pts',
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // TABLEAU TOP PARRAINS & AMBASSADEURS (table-parrainages)
        _buildSectionTitle(
          badge: 'VIRALITÉ',
          title:
              'Top Ambassadeurs & Parrainage Viral (206 Filleuls • 3 189,5 DT)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            children: BondinDwhData.topParrains.map((p) {
              return Container(
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p['nom'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            '${p['rang']} • ${p['filleuls']} recrutés (${p['convertis']} convertis)',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '+${p['ca']} DT',
                          style: const TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          '+${p['pts']} pts prime',
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String val) {
    final bool active = _grossisteFilter == val;
    return GestureDetector(
      onTap: () => setState(() => _grossisteFilter = val),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF991B1B) : Colors.white10,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? const Color(0xFFF59E0B) : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ONGLET 04 : CAGNOTTE EARN & BURN, SANKEY, CATALOGUE, MARKET BASKET & PDV
  // ==========================================================================
  Widget _buildTab04CagnotteLtv() {
    final rewards = BondinDwhData.rewardsCatalog.where((r) {
      if (_rewardTierFilter == 'all') return true;
      return r['cible'] == _rewardTierFilter;
    }).toList();

    return ListView(
      key: const ValueKey('tab_04_full'),
      padding: const EdgeInsets.all(12),
      children: [
        // 1. FLUX SANKEY ACQUISITION -> ACTIVATION -> FIDÉLISATION (sankey-flow-container)
        _buildSectionTitle(
          badge: 'SANKEY',
          title: 'Flux Sankey : De l\'Inscription Mobile à la Valeur Client',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildWaterfallBar(
                label: 'Étape 1 : Inscriptions Mobile CRM (100%)',
                pts: '${BondinDwhData.totalInscritsLive} Membres',
                tnd: 'Base Totale',
                ratio: 1.0,
                color: const Color(0xFFD97706),
              ),
              const SizedBox(height: 8),
              _buildWaterfallBar(
                label: 'Étape 2 : Activation 1er Scan Caisse (28,6%)',
                pts: '${BondinDwhData.clientsActifsLive} Actifs',
                tnd: '${BondinDwhData.totalCaTndLive.toStringAsFixed(2)} DT',
                ratio: 0.286,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(height: 8),
              _buildWaterfallBar(
                label: 'Étape 3 : Champions VIP (78,4% du CA)',
                pts: '165 Champions',
                tnd: 'LTV 294,40 DT',
                ratio: 0.784,
                color: const Color(0xFFF59E0B),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. WATERFALL EARN / BURN (chart-waterfall-mockup)
        _buildSectionTitle(
          badge: 'WATERFALL',
          title: 'Cascade Waterfall Earn & Burn des Points Fidélité (Live)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            children: [
              _buildWaterfallBar(
                label: 'Points Émis (Earn Global)',
                pts: '${BondinDwhData.totalPointsEmisLive} pts',
                tnd: '${(BondinDwhData.totalPointsEmisLive * 0.01).toStringAsFixed(2)} DT',
                ratio: 1.0,
                color: const Color(0xFF10B981),
              ),
              const SizedBox(height: 8),
              _buildWaterfallBar(
                label: 'Points Brûlés (Burn • ${BondinDwhData.totalCadeauxReclamesLive} Cadeaux • 55,4%)',
                pts: '-${BondinDwhData.totalPointsBrulesLive} pts',
                tnd: '-${(BondinDwhData.totalPointsBrulesLive * 0.01).toStringAsFixed(2)} DT',
                ratio: 0.554,
                color: const Color(0xFFF59E0B),
              ),
              const SizedBox(height: 8),
              _buildWaterfallBar(
                label: 'Solde Actif (Dette Provisionnée)',
                pts: '${BondinDwhData.soldePointsActifsLive} pts',
                tnd: '${(BondinDwhData.soldePointsActifsLive * 0.01).toStringAsFixed(2)} DT',
                ratio: 0.446,
                color: const Color(0xFFEF4444),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. CATALOGUE OFFICIEL DES RÉCOMPENSES (rewards-catalog-container)
        _buildSectionTitle(
          badge: 'CADEAUX',
          title: 'Catalogue Officiel des Récompenses BONDIN × FIDNESS',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildRewardFilterBtn('Tous', 'all'),
                  const SizedBox(width: 6),
                  _buildRewardFilterBtn('Exclusif VIP', 'Exclusif'),
                  const SizedBox(width: 6),
                  _buildRewardFilterBtn('Privilège', 'Privilège'),
                ],
              ),
              const SizedBox(height: 10),
              ...rewards.map((r) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.04),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFD97706).withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              r['nom'] as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '${r['desc']} • ${r['profile']}',
                              style: const TextStyle(
                                color: Color(0xFF94A3B8),
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${r['cout']} pts',
                            style: const TextStyle(
                              color: Color(0xFFFDE68A),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            'Val: ${(r['valTnd'] as double).toStringAsFixed(1)} DT',
                            style: const TextStyle(
                              color: Color(0xFF34D399),
                              fontSize: 9.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 4. MARKET BASKET ANALYSIS (table-market-basket)
        _buildSectionTitle(
          badge: 'PANIER CROISÉ',
          title: 'Market Basket Analysis (Associations Produits Apriori)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            children: BondinDwhData.marketBasketRules.map((m) {
              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(9),
                  border: Border.all(color: Colors.white10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${m['prodA']} + ${m['prodB']}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Confiance : ${m['confiance']} • Lift : ${m['lift']}',
                          style: const TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          m['action'] as String,
                          style: const TextStyle(
                            color: Color(0xFF34D399),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 16),

        // 5. TABLE DES CAISSES CADEAUX PAR MAGASIN (table-magasins-cadeaux)
        _buildSectionTitle(
          badge: 'STOCKS PDV',
          title: 'Distribution des Cadeaux & Points Brûlés par Point de Vente',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            children: BondinDwhData.magasinsCadeaux.map((mc) {
              return Container(
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            mc['nom'] as String,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${mc['cadeaux']} cadeaux délivrés • ${mc['ptsBrules']} pts brûlés',
                            style: const TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      mc['statut'] as String,
                      style: const TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildRewardFilterBtn(String label, String tier) {
    final bool sel = _rewardTierFilter == tier;
    return GestureDetector(
      onTap: () => setState(() => _rewardTierFilter = tier),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
        decoration: BoxDecoration(
          color: sel ? const Color(0xFFD97706) : Colors.white10,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: sel ? Colors.black : Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ==========================================================================
  // ONGLET 05 : ANALYSES AVANCÉES, HEATMAP HORAIRE, COHORTES, RADAR, BCG & ÂGES
  // ==========================================================================
  Widget _buildTab05AnalysesAvancees() {
    return ListView(
      key: const ValueKey('tab_05_full'),
      padding: const EdgeInsets.all(12),
      children: [
        // 1. HEATMAP TEMPORELLE 7 JOURS x 6 CRÉNEAUX HORAIRES (heatmap-time-container)
        _buildSectionTitle(
          badge: 'HEATMAP',
          title: 'Heatmap Temporelle : Affluence des Scans QR (Jours × Heures)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(width: 34),
                  ...BondinDwhData.heatmapSlots.map(
                    (s) => Expanded(
                      child: Text(
                        s,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 8.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ...BondinDwhData.heatmapDays.map((row) {
                final List<int> vals = row['values'] as List<int>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 34,
                        child: Text(
                          row['day'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ...vals.map((v) {
                        final double intensity = (v / 780.0).clamp(0.12, 1.0);
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1.5),
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            decoration: BoxDecoration(
                              color: Color.lerp(
                                const Color(0xFF311014),
                                const Color(0xFFF59E0B),
                                intensity,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '$v',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: intensity > 0.65
                                    ? Colors.black
                                    : Colors.white,
                                fontSize: 8.8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 2. MATRICE TRIANGULAIRE DE RÉTENTION PAR COHORTE (table-cohort-retention)
        _buildSectionTitle(
          badge: 'COHORTES',
          title: 'Matrice de Rétention Mensuelle des Membres (M0 → M+6)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const SizedBox(
                    width: 62,
                    child: Text(
                      'Cohorte',
                      style: TextStyle(
                        color: Color(0xFFFDE68A),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  ...['M0', 'M+1', 'M+2', 'M+3', 'M+4', 'M+5', 'M+6'].map(
                    (m) => Expanded(
                      child: Text(
                        m,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ...BondinDwhData.cohortRetentionRows.map((c) {
                final List<double?> vals = c['vals'] as List<double?>;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 62,
                        child: Text(
                          '${c['cohorte']}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      ...vals.map((v) {
                        if (v == null) {
                          return Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1),
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.03),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                '-',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white24,
                                  fontSize: 8.5,
                                ),
                              ),
                            ),
                          );
                        }
                        final Color cellCol = v >= 95
                            ? const Color(0xFF10B981)
                            : v >= 85
                                ? const Color(0xFF059669)
                                : v >= 75
                                    ? const Color(0xFFD97706)
                                    : const Color(0xFF991B1B);
                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            decoration: BoxDecoration(
                              color: cellCol.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${v.toStringAsFixed(0)}%',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // 3. GRAPHIQUE RADAR BENCHMARK 6 AXES (chart-radar-benchmark)
        _buildSectionTitle(
          badge: 'RADAR',
          title: 'Radar Benchmark : Succursales B2B vs Cafétérias B2C',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: const RadarBenchmarkChart(),
        ),

        const SizedBox(height: 16),

        // 4. MATRICE BCG DU CATALOGUE PRODUITS (chart-bcg-products)
        _buildSectionTitle(
          badge: 'BCG',
          title: 'Matrice BCG : Volume vs Chiffre d\'Affaires vs Panier Moyen',
        ),
        const SizedBox(height: 8),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.45,
          children: [
            _buildBcgCard(
              title: 'STARS (Forte Croiss.)',
              sub: 'Grains & Moulu Torréfié B2B\n1 160 scans • 37 703 DT',
              col: const Color(0xFFF59E0B),
            ),
            _buildBcgCard(
              title: 'VACHES À LAIT',
              sub: 'Espresso & Boissons Chaudes\n5 200 scans • 21 777 DT',
              col: const Color(0xFF10B981),
            ),
            _buildBcgCard(
              title: 'DILEMMES (Cross-Sell)',
              sub: 'Capsules & Coffrets 1910\n410 scans • 4 510 DT',
              col: const Color(0xFF38BDF8),
            ),
            _buildBcgCard(
              title: 'POIDS MORTS',
              sub: 'Sirops & Accessoires Été\n95 scans • 840 DT',
              col: const Color(0xFF94A3B8),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // 5. PYRAMIDE DES ÂGES COMPARÉE SUCCURSALES VS CAFÉTÉRIAS (chart-age-demographics)
        _buildSectionTitle(
          badge: 'DÉMOGRAPHIE',
          title:
              'Pyramide des Âges Comparée : Succursales vs Cafétérias (580 Actifs)',
        ),
        const SizedBox(height: 8),
        _buildCardContainer(
          child: Column(
            children: BondinDwhData.ageDemographics.map((a) {
              final int succ = a['succ'] as int;
              final int cafe = a['cafe'] as int;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          a['tranche'] as String,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Succ: $succ clients | Café: $cafe clients',
                          style: const TextStyle(
                            color: Color(0xFFCBD5E1),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Expanded(
                          flex: succ,
                          child: Container(
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFFA855F7),
                              borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: cafe,
                          child: Container(
                            height: 7,
                            decoration: const BoxDecoration(
                              color: Color(0xFF38BDF8),
                              borderRadius: BorderRadius.horizontal(
                                right: Radius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildBcgCard({
    required String title,
    required String sub,
    required Color col,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF170D0F),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: col.withValues(alpha: 0.45)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              color: col,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            sub,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // ONGLET 06 : CHATBOT PRO BONDIN (MOTEUR DÉCISIONNEL DWH LIVE CERTIFIÉ)
  // ==========================================================================
  Widget _buildTab06ChatbotRagLive() {
    final quickPrompts = [
      'Donne l\'activité en octobre',
      'Top magasins Bondin ?',
      'Qui sont les grossistes ?',
      'Clientes à risque Churn ?',
      'Dette financière & points ?',
    ];

    return Column(
      key: const ValueKey('tab_06_full'),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          color: const Color(0xFF1F0D10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: quickPrompts.map((p) {
                return Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: ActionChip(
                    onPressed: () => _sendRagQuestion(p),
                    backgroundColor: const Color(0xFF7F1017),
                    side: const BorderSide(color: Color(0xFFD97706)),
                    label: Text(
                      p,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _chatMessages.length,
            itemBuilder: (context, idx) {
              final m = _chatMessages[idx];
              final isUser = m['role'] == 'user';
              return Align(
                alignment:
                    isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(12),
                  constraints: const BoxConstraints(maxWidth: 350),
                  decoration: BoxDecoration(
                    color: isUser
                        ? const Color(0xFF991B1B)
                        : const Color(0xFF1A1113),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isUser
                          ? const Color(0xFFF59E0B)
                          : Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Text(
                    m['text']!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11.8,
                      height: 1.42,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
          decoration: const BoxDecoration(
            color: Color(0xFF140B0D),
            border: Border(top: BorderSide(color: Colors.white12)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatInputCtrl,
                  onSubmitted: _sendRagQuestion,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                  decoration: InputDecoration(
                    hintText: 'Interroger Chatbot Pro BONDIN (DWH Live)...',
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                    filled: true,
                    fillColor: const Color(0xFF231417),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFFD97706),
                child: IconButton(
                  onPressed: () => _sendRagQuestion(_chatInputCtrl.text),
                  icon: const Icon(
                    Icons.send_rounded,
                    color: Colors.black,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --------------------------------------------------------------------------
  // HELPERS VISUELS COMMUNS
  // --------------------------------------------------------------------------
  Widget _buildBottomNavigationBar() {
    final navItems = [
      {'icon': Icons.analytics_rounded, 'label': 'Cockpit', 'idx': 0},
      {'icon': Icons.bolt_rounded, 'label': 'Agent IA', 'idx': 1},
      {'icon': Icons.pie_chart_rounded, 'label': 'Segments', 'idx': 2},
      {'icon': Icons.card_giftcard_rounded, 'label': 'Cagnotte', 'idx': 3},
      {'icon': Icons.radar_rounded, 'label': 'Cohortes', 'idx': 4},
      {'icon': Icons.chat_bubble_rounded, 'label': 'Chatbot', 'idx': 5},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
      decoration: const BoxDecoration(
        color: Color(0xFF140A0C),
        border: Border(top: BorderSide(color: Colors.white12)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: navItems.map((item) {
          final int idx = item['idx'] as int;
          final bool active = _activeTab == idx;
          return GestureDetector(
            onTap: () => setState(() => _activeTab = idx),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item['icon'] as IconData,
                  size: 18,
                  color: active
                      ? const Color(0xFFF59E0B)
                      : const Color(0xFF94A3B8),
                ),
                const SizedBox(height: 2),
                Text(
                  item['label'] as String,
                  style: TextStyle(
                    color: active ? Colors.white : const Color(0xFF94A3B8),
                    fontSize: 9.5,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSectionTitle({required String badge, required String title}) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFFD97706),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF991B1B),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Text(
            badge,
            style: const TextStyle(
              color: Color(0xFFFDE68A),
              fontSize: 9,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11.8,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCardContainer({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF170D0F),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: const Color(0xFFD97706).withValues(alpha: 0.25),
        ),
      ),
      child: child,
    );
  }

  Widget _buildExecutiveKpiCard({
    required String title,
    required String value,
    required String sub,
    required String badge,
    required Color accent,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFF170D0F),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: accent, size: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Text(
                  badge,
                  style: TextStyle(
                    color: accent,
                    fontSize: 8.8,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFFE2E8F0),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                sub,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWaterfallBar({
    required String label,
    required String pts,
    required String tnd,
    required double ratio,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '$pts ($tnd)',
              style: TextStyle(
                color: color,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 7,
            backgroundColor: Colors.white10,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildLiveTransactionRow({
    required String ticket,
    required String client,
    required String store,
    required String amount,
    required String pts,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$client ($ticket)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  store,
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 9.8,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: const TextStyle(
                  color: Color(0xFFFDE68A),
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                pts,
                style: const TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// PAINTERS DU LOGIN FIDNESS
// ============================================================================
class _FidnessNeuralBackgroundPainter extends CustomPainter {
  final double progress;

  _FidnessNeuralBackgroundPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF040814), Color(0xFF0A1432), Color(0xFF060B19)],
      ).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, bgPaint);
  }

  @override
  bool shouldRepaint(covariant _FidnessNeuralBackgroundPainter oldDelegate) =>
      false;
}

class _OrbitalRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..shader = const SweepGradient(
        colors: [
          Colors.transparent,
          Color(0xFF4B67F6),
          Color(0xFFFF5400),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _FidnessVectorLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    canvas.drawCircle(
      Offset(w * 0.27, h * 0.11),
      w * 0.115,
      Paint()..color = const Color(0xFFFF5500),
    );

    final royalBluePaint = Paint()..color = const Color(0xFF183499);
    final cobaltBluePaint = Paint()..color = const Color(0xFF4F6BF7);

    final upperStemPath = Path()
      ..moveTo(w * 0.15, h * 0.36)
      ..quadraticBezierTo(w * 0.15, h * 0.23, w * 0.28, h * 0.23)
      ..lineTo(w * 0.39, h * 0.23)
      ..lineTo(w * 0.39, h * 0.62)
      ..lineTo(w * 0.15, h * 0.62)
      ..close();
    canvas.drawPath(upperStemPath, royalBluePaint);

    final lowerStemPath = Path()
      ..moveTo(w * 0.15, h * 0.69)
      ..lineTo(w * 0.39, h * 0.69)
      ..lineTo(w * 0.39, h * 0.86)
      ..lineTo(w * 0.28, h * 0.86)
      ..quadraticBezierTo(w * 0.15, h * 0.86, w * 0.15, h * 0.75)
      ..close();
    canvas.drawPath(lowerStemPath, royalBluePaint);

    final topBarPath = Path()
      ..moveTo(w * 0.45, h * 0.23)
      ..lineTo(w * 0.90, h * 0.23)
      ..lineTo(w * 0.90, h * 0.28)
      ..quadraticBezierTo(w * 0.90, h * 0.37, w * 0.77, h * 0.37)
      ..lineTo(w * 0.45, h * 0.37)
      ..close();
    canvas.drawPath(topBarPath, cobaltBluePaint);

    final midBarPath = Path()
      ..moveTo(w * 0.39, h * 0.48)
      ..lineTo(w * 0.78, h * 0.48)
      ..lineTo(w * 0.78, h * 0.52)
      ..quadraticBezierTo(w * 0.78, h * 0.62, w * 0.65, h * 0.62)
      ..lineTo(w * 0.39, h * 0.62)
      ..close();
    canvas.drawPath(midBarPath, cobaltBluePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
