import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

// ============================================================================
// ÉCRAN D'INTRODUCTION CINÉMATIQUE & ANIMATION HAUT DE GAMME FIDNESS
// DESIGN : CYBER-LUXE / APPLE KEYNOTE / FINTECH DÉCISIONNELLE
// ============================================================================

class FidnessCinematicSplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const FidnessCinematicSplashScreen({
    super.key,
    required this.onComplete,
  });

  @override
  State<FidnessCinematicSplashScreen> createState() =>
      _FidnessCinematicSplashScreenState();
}

class _FidnessCinematicSplashScreenState
    extends State<FidnessCinematicSplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _timelineCtrl;
  late final AnimationController _ambientLoopCtrl;

  // Animations chorégraphiées
  late final Animation<double> _nebulaFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _shimmerSweep;
  late final Animation<double> _textFade;
  late final Animation<double> _textSpacing;
  late final Animation<double> _telemetryFade;
  late final Animation<double> _buttonSlide;

  // Liste des messages de démarrage télémétrique
  final List<String> _bootSteps = [
    'Initialisation du noyau neural FIDNESS v4.2...',
    'Chiffrement des tunnels DWH PostgreSQL 17.7...',
    'Synchronisation Multi-Tenant (Bondin & Stiel)...',
    'Prêt pour le pilotage décisionnel en temps réel.',
  ];
  int _currentStepIdx = 0;
  Timer? _stepTimer;
  Timer? _autoCompleteTimer;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();

    // Boucle d'ambiance infinie (particules, orbes, rotation lente)
    _ambientLoopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    // Timeline cinématique principale (durée 3.4 secondes)
    _timelineCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3400),
    );

    // 1. Éveil du fond et du halo
    _nebulaFade = CurvedAnimation(
      parent: _timelineCtrl,
      curve: const Interval(0.0, 0.35, curve: Curves.easeOut),
    );

    // 2. Émergence dynamique et rebond du logo
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.18)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 65,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.18, end: 1.0)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 35,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _timelineCtrl,
        curve: const Interval(0.12, 0.52),
      ),
    );

    _logoOpacity = CurvedAnimation(
      parent: _timelineCtrl,
      curve: const Interval(0.12, 0.42, curve: Curves.easeIn),
    );

    // 3. Balayage lumineux (Shimmer sweep sur le logo)
    _shimmerSweep = Tween<double>(begin: -1.2, end: 2.2).animate(
      CurvedAnimation(
        parent: _timelineCtrl,
        curve: const Interval(0.42, 0.72, curve: Curves.easeInOutCubic),
      ),
    );

    // 4. Apparition du texte et convergence du letter-spacing
    _textFade = CurvedAnimation(
      parent: _timelineCtrl,
      curve: const Interval(0.48, 0.75, curve: Curves.easeOut),
    );

    _textSpacing = Tween<double>(begin: 9.0, end: 3.5).animate(
      CurvedAnimation(
        parent: _timelineCtrl,
        curve: const Interval(0.48, 0.78, curve: Curves.easeOutCubic),
      ),
    );

    // 5. Apparition de la jauge et télémétrie
    _telemetryFade = CurvedAnimation(
      parent: _timelineCtrl,
      curve: const Interval(0.65, 0.90, curve: Curves.easeOut),
    );

    // 6. Révélation du bouton interactif
    _buttonSlide = CurvedAnimation(
      parent: _timelineCtrl,
      curve: const Interval(0.80, 1.0, curve: Curves.easeOutBack),
    );

    // Déclenchement de la chronologie
    _timelineCtrl.forward();

    // Défilement du texte télémétrique
    _stepTimer = Timer.periodic(const Duration(milliseconds: 750), (timer) {
      if (!mounted) return;
      if (_currentStepIdx < _bootSteps.length - 1) {
        setState(() => _currentStepIdx++);
      } else {
        timer.cancel();
      }
    });

    // Auto-transition douce après 5.5s si l'utilisateur ne clique pas
    _autoCompleteTimer = Timer(const Duration(milliseconds: 5500), () {
      if (mounted && !_isExiting) {
        _finishAndEnter();
      }
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _autoCompleteTimer?.cancel();
    _timelineCtrl.dispose();
    _ambientLoopCtrl.dispose();
    super.dispose();
  }

  void _finishAndEnter() {
    if (_isExiting) return;
    setState(() => _isExiting = true);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF030612),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Fond cosmique profond avec particules interactives et nébuleuse
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _ambientLoopCtrl,
              builder: (context, _) {
                return CustomPaint(
                  painter: _FidnessCosmicSplashPainter(
                    ambientProgress: _ambientLoopCtrl.value,
                    nebulaOpacity: _nebulaFade.value,
                  ),
                );
              },
            ),
          ),

          // 2. Bouton discret "Passer" en haut à droite
          Positioned(
            top: 24,
            right: 20,
            child: SafeArea(
              child: GestureDetector(
                onTap: _finishAndEnter,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.16),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Passer',
                        style: TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: Color(0xFF94A3B8),
                        size: 11,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 3. Contenu central héroïque
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 3),

                    // CŒUR HÉROÏQUE : LOGO FIDNESS ANIMÉ & ANNEAUX QUANTIQES
                    _buildHeroAnimatedLogo(),

                    const SizedBox(height: 36),

                    // TITRE DE MARQUE FIDNESS AVEC TYPOGRAPHIE CINÉMATIQUE
                    _buildBrandTypography(),

                    const SizedBox(height: 12),

                    // BADGE OFFICIEL HOLOGRAPHIQUE
                    _buildDecisionBadge(),

                    const Spacer(flex: 2),

                    // TÉLÉMÉTRIE DE DÉMARRAGE & JAUGE NEURALE
                    _buildTelemetryProgress(),

                    const SizedBox(height: 28),

                    // BOUTON INTERACTIF PRINCIPAL "ENTRER DANS LE HUB"
                    _buildEnterButton(),

                    const Spacer(flex: 2),

                    // MENTIONS DE SÉCURITÉ BAS DE PAGE
                    FadeTransition(
                      opacity: _telemetryFade,
                      child: const Text(
                        'FIDNESS OS • MOTEUR DÉCISIONNEL MULTI-TENANT PRO',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // WIDGET : LOGO CENTRAL SPECTACULAIRE AVEC ANNEAUX ORBITAUX ET FAISCEAU
  // ==========================================================================
  Widget _buildHeroAnimatedLogo() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _timelineCtrl,
        _ambientLoopCtrl,
      ]),
      builder: (context, _) {
        final scale = _logoScale.value;
        final opacity = _logoOpacity.value;
        final shimmer = _shimmerSweep.value;
        final loop = _ambientLoopCtrl.value;

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: scale,
            child: SizedBox(
              width: 170,
              height: 170,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Anneau externe dynamique 1 (rotation anti-horaire)
                  Transform.rotate(
                    angle: -loop * 2 * math.pi,
                    child: CustomPaint(
                      size: const Size(170, 170),
                      painter: _QuantumTechRingPainter(
                        color: const Color(0xFF3B82F6),
                        pulse: math.sin(loop * 2 * math.pi),
                        dashCount: 24,
                      ),
                    ),
                  ),

                  // Anneau externe dynamique 2 (rotation horaire dorée/orange)
                  Transform.rotate(
                    angle: loop * 2 * math.pi * 0.75,
                    child: CustomPaint(
                      size: const Size(146, 146),
                      painter: _QuantumTechRingPainter(
                        color: const Color(0xFFFF5400),
                        pulse: math.cos(loop * 2 * math.pi),
                        dashCount: 16,
                      ),
                    ),
                  ),

                  // Halo d'aura énergétique pulsante
                  Container(
                    width: 124,
                    height: 124,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF4F6BF7)
                              .withValues(alpha: 0.55 + (math.sin(loop * 4 * math.pi) * 0.15)),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                        BoxShadow(
                          color: const Color(0xFFFF5400)
                              .withValues(alpha: 0.35 + (math.cos(loop * 4 * math.pi) * 0.10)),
                          blurRadius: 28,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  // Médaillon central en verre pur et chrome
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const RadialGradient(
                        center: Alignment(-0.25, -0.35),
                        radius: 1.1,
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFF1F5F9),
                          Color(0xFFE2E8F0),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white,
                        width: 3.5,
                      ),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black54,
                          blurRadius: 25,
                          offset: Offset(0, 14),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Logo vectoriel officiel FIDNESS
                          Center(
                            child: CustomPaint(
                              size: const Size(60, 68),
                              painter: _FidnessVectorLogoPainter(),
                            ),
                          ),

                          // Faisceau lumineux diagonal (Shimmer Beam)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _ShimmerBeamPainter(
                                progress: shimmer,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================================
  // WIDGET : TYPOGRAPHIE DE MARQUE FIDNESS ANIMÉE
  // ==========================================================================
  Widget _buildBrandTypography() {
    return AnimatedBuilder(
      animation: _timelineCtrl,
      builder: (context, _) {
        final opacity = _textFade.value;
        final spacing = _textSpacing.value;

        return Opacity(
          opacity: opacity.clamp(0.0, 1.0),
          child: Column(
            children: [
              ShaderMask(
                shaderCallback: (bounds) {
                  return const LinearGradient(
                    colors: [
                      Color(0xFFFFFFFF),
                      Color(0xFF93C5FD),
                      Color(0xFFFFB088),
                    ],
                    stops: [0.0, 0.65, 1.0],
                  ).createShader(bounds);
                },
                child: Text(
                  'FIDNESS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: spacing,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'BI & AI DECISION HUB',
                style: TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 3.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================================
  // WIDGET : BADGE DÉCISIONNEL HOLOGRAPHIQUE
  // ==========================================================================
  Widget _buildDecisionBadge() {
    return FadeTransition(
      opacity: _textFade,
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withValues(alpha: 0.65),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
              blurRadius: 16,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, size: 13, color: Color(0xFFFFB020)),
            SizedBox(width: 7),
            Text(
              'POWERED BY FIDNESS • ENTERPRISE SUITE',
              style: TextStyle(
                color: Color(0xFFE2E8F0),
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // WIDGET : PROGRESSION TÉLÉMÉTRIQUE & NOYAU DÉCISIONNEL
  // ==========================================================================
  Widget _buildTelemetryProgress() {
    return FadeTransition(
      opacity: _telemetryFade,
      child: Column(
        children: [
          // Texte d'état dynamique
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            child: Text(
              _bootSteps[_currentStepIdx],
              key: ValueKey<int>(_currentStepIdx),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF38BDF8),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Barre de chargement stylisée avec éclat néon
          AnimatedBuilder(
            animation: _timelineCtrl,
            builder: (context, _) {
              final double progress = ((_timelineCtrl.value - 0.40) / 0.60)
                  .clamp(0.05, 1.0);

              return Container(
                width: 260,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Stack(
                  children: [
                    FractionallySizedBox(
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF3B82F6),
                              Color(0xFF06B6D4),
                              Color(0xFFFF5400),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF06B6D4).withValues(alpha: 0.7),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ==========================================================================
  // WIDGET : BOUTON PRINCIPAL GLOWING "ENTRER DANS LE HUB"
  // ==========================================================================
  Widget _buildEnterButton() {
    return AnimatedBuilder(
      animation: Listenable.merge([_buttonSlide, _ambientLoopCtrl]),
      builder: (context, _) {
        final scale = _buttonSlide.value;
        final loop = _ambientLoopCtrl.value;
        final glowPulse = 0.5 + (0.5 * math.sin(loop * 4 * math.pi));

        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: _finishAndEnter,
            child: Container(
              height: 52,
              constraints: const BoxConstraints(maxWidth: 290),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF1D3993),
                    Color(0xFF3B82F6),
                    Color(0xFFFF5400),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3B82F6).withValues(alpha: 0.35 + (0.25 * glowPulse)),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: const Color(0xFFFF5400).withValues(alpha: 0.20 + (0.15 * glowPulse)),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.bolt_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'ACCÉDER AU HUB DÉCISIONNEL',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 19,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ============================================================================
// PAINTERS : EFFETS VISUELS ET CHROMATIQUES HAUTE PERFORMANCE
// ============================================================================

/// Fond cosmique profond avec nébuleuse et particules lumineuses
class _FidnessCosmicSplashPainter extends CustomPainter {
  final double ambientProgress;
  final double nebulaOpacity;

  _FidnessCosmicSplashPainter({
    required this.ambientProgress,
    required this.nebulaOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    // Dégradé de fond spatial
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0.0, -0.2),
        radius: 1.3,
        colors: [
          Color(0xFF0F1E4A),
          Color(0xFF070D22),
          Color(0xFF02040A),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    if (nebulaOpacity <= 0) return;

    // Nébuleuse lumineuse 1 : Bleu royal / Saphir
    final neb1Paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.3),
        radius: 0.85,
        colors: [
          const Color(0xFF2563EB).withValues(alpha: 0.28 * nebulaOpacity),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, neb1Paint);

    // Nébuleuse lumineuse 2 : Ambre / Orange éclatant
    final neb2Paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.5, 0.4),
        radius: 0.75,
        colors: [
          const Color(0xFFFF5400).withValues(alpha: 0.18 * nebulaOpacity),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, neb2Paint);

    // Nébuleuse lumineuse 3 : Cyan électrique sous le logo
    final neb3Paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 0.0),
        radius: 0.45,
        colors: [
          const Color(0xFF06B6D4).withValues(alpha: 0.22 * nebulaOpacity),
          Colors.transparent,
        ],
      ).createShader(rect);
    canvas.drawRect(rect, neb3Paint);

    // Particules cosmiques flottantes
    final particlePaint = Paint()..style = PaintingStyle.fill;
    const int count = 38;
    for (int i = 0; i < count; i++) {
      final double seed = i * 43.17;
      final double xRatio = (math.sin(seed) * 0.5 + 0.5);
      final double initialY = (math.cos(seed * 1.3) * 0.5 + 0.5);
      // Déplacement vertical lent avec bouclage
      final double yRatio = (initialY - (ambientProgress * 0.4) + i * 0.1) % 1.0;

      final double px = xRatio * size.width;
      final double py = yRatio * size.height;
      final double radius = 1.0 + (i % 3) * 1.1;

      final double pulse = math.sin((ambientProgress * 2 * math.pi) + i);
      final double alpha = (0.25 + 0.55 * (pulse * 0.5 + 0.5)) * nebulaOpacity;

      if (i % 4 == 0) {
        particlePaint.color = const Color(0xFFFF8800).withValues(alpha: alpha);
      } else if (i % 3 == 0) {
        particlePaint.color = const Color(0xFF38BDF8).withValues(alpha: alpha);
      } else {
        particlePaint.color = Colors.white.withValues(alpha: alpha);
      }

      canvas.drawCircle(Offset(px, py), radius, particlePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _FidnessCosmicSplashPainter oldDelegate) {
    return oldDelegate.ambientProgress != ambientProgress ||
        oldDelegate.nebulaOpacity != nebulaOpacity;
  }
}

/// Anneaux holographiques à segments quantiques
class _QuantumTechRingPainter extends CustomPainter {
  final Color color;
  final double pulse;
  final int dashCount;

  _QuantumTechRingPainter({
    required this.color,
    required this.pulse,
    required this.dashCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 4;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8 + (pulse * 0.4)
      ..strokeCap = StrokeCap.round;

    final double step = (2 * math.pi) / dashCount;
    final double dashAngle = step * 0.55;

    for (int i = 0; i < dashCount; i++) {
      final double startAngle = i * step;
      final double alpha =
          0.3 + 0.5 * (math.sin(i * 0.7 + pulse * 2) * 0.5 + 0.5);
      paint.color = color.withValues(alpha: alpha.clamp(0.1, 0.9));

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _QuantumTechRingPainter oldDelegate) {
    return oldDelegate.pulse != pulse || oldDelegate.color != color;
  }
}

/// Balayage lumineux métallique en diagonale sur le logo
class _ShimmerBeamPainter extends CustomPainter {
  final double progress;

  _ShimmerBeamPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    final double xOffset = progress * w * 1.5;

    final paint = Paint()
      ..shader = LinearGradient(
        begin: const Alignment(-1.0, -1.0),
        end: const Alignment(1.0, 1.0),
        colors: [
          Colors.transparent,
          Colors.white.withValues(alpha: 0.55),
          const Color(0xFF67E8F9).withValues(alpha: 0.45),
          Colors.transparent,
        ],
        stops: const [0.0, 0.45, 0.55, 1.0],
      ).createShader(
        Rect.fromLTWH(xOffset - 40, -20, 80, h + 40),
      )
      ..blendMode = BlendMode.screen;

    final path = Path()
      ..moveTo(xOffset - 35, 0)
      ..lineTo(xOffset + 25, 0)
      ..lineTo(xOffset + 5, h)
      ..lineTo(xOffset - 55, h)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ShimmerBeamPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// Logo officiel vectoriel FIDNESS (F stylisé avec gemme orange)
class _FidnessVectorLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Pastille orange supérieure
    canvas.drawCircle(
      Offset(w * 0.27, h * 0.11),
      w * 0.115,
      Paint()..color = const Color(0xFFFF5500),
    );

    final royalBluePaint = Paint()..color = const Color(0xFF183499);
    final cobaltBluePaint = Paint()..color = const Color(0xFF4F6BF7);

    // Tronc vertical supérieur
    final upperStemPath = Path()
      ..moveTo(w * 0.15, h * 0.36)
      ..quadraticBezierTo(w * 0.15, h * 0.23, w * 0.28, h * 0.23)
      ..lineTo(w * 0.39, h * 0.23)
      ..lineTo(w * 0.39, h * 0.62)
      ..lineTo(w * 0.15, h * 0.62)
      ..close();
    canvas.drawPath(upperStemPath, royalBluePaint);

    // Tronc vertical inférieur
    final lowerStemPath = Path()
      ..moveTo(w * 0.15, h * 0.69)
      ..lineTo(w * 0.39, h * 0.69)
      ..lineTo(w * 0.39, h * 0.86)
      ..lineTo(w * 0.28, h * 0.86)
      ..quadraticBezierTo(w * 0.15, h * 0.86, w * 0.15, h * 0.75)
      ..close();
    canvas.drawPath(lowerStemPath, royalBluePaint);

    // Barre transversale haute (Cobalt)
    final topBarPath = Path()
      ..moveTo(w * 0.45, h * 0.23)
      ..lineTo(w * 0.90, h * 0.23)
      ..lineTo(w * 0.90, h * 0.28)
      ..quadraticBezierTo(w * 0.90, h * 0.37, w * 0.77, h * 0.37)
      ..lineTo(w * 0.45, h * 0.37)
      ..close();
    canvas.drawPath(topBarPath, cobaltBluePaint);

    // Barre transversale intermédiaire (Cobalt)
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
