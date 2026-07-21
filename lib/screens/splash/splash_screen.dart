import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loah_app/core/services/auth_service.dart';
import 'package:loah_app/core/theme/app_theme.dart';
import 'package:loah_app/main.dart';
import '../auth/login_screen.dart';

class SplashScreenVistoso extends StatefulWidget {
  const SplashScreenVistoso({super.key});


  @override
  State<SplashScreenVistoso> createState() => _SplashScreenVistosoState();
}

class _SplashScreenVistosoState extends State<SplashScreenVistoso>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<double> _logoFade;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoRotation;
  late final Animation<double> _titleFade;
  late final Animation<double> _taglineFade;
  late final Animation<double> _progress;

  bool _leaving = false;
  bool _navigated = false; // Evita navegação duplicada
  final AuthService _authService = AuthService();
  StreamSubscription<User?>? _authSubscription;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2600),
      vsync: this,
    );

    _logoFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut)),
    );
    _logoScale = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.75, curve: Curves.easeOutBack)),
    );
    _logoRotation = Tween<double>(begin: -0.3, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.85, curve: Curves.easeOut)),
    );
    _titleFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.5, 0.85, curve: Curves.easeOut)),
    );
    _taglineFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.6, 1.0, curve: Curves.easeOut)),
    );
    // Barra de progresso acompanha a animação inteira, do início ao fim.
    _progress = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // Escuta alterações no estado de autenticação.
    // O Firebase Auth persiste automaticamente o refresh token no
    // dispositivo, restaurando a sessão entre aberturas do app.
    _authSubscription = _authService.authStateChanges.listen((user) {
      if (!mounted || _navigated) return;
      if (user != null) {
        // Utilizador já tem sessão ativa → navega para o dashboard
        _navigateToRoot();
      }
    });

    // Fallback: quando a animação terminar, se ninguém estiver
    // autenticado → navega para o ecrã de login.
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted && !_navigated) {
        final user = _authService.currentUser;
        if (user != null) {
          _navigateToRoot();
        } else {
          _navigateToLogin();
        }
      }
    });
  }

  void _navigateToRoot() {
    if (_navigated) return;
    _navigated = true;
    _authSubscription?.cancel();
    setState(() => _leaving = true);
    Future.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, anim, __) => const RootShell(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
        (route) => false,
      );
    });
  }

  void _navigateToLogin() {
    if (_navigated) return;
    _navigated = true;
    _authSubscription?.cancel();
    setState(() => _leaving = true);
    Future.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, anim, __) => const LoginScreen(),
          transitionsBuilder: (_, anim, __, child) =>
              FadeTransition(opacity: anim, child: child),
        ),
      );
    });
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = context.loahColors;
    final isDark = theme.brightness == Brightness.dark;

    final backgroundGradient = isDark
        ? [
            colors.accentBlue.withValues(alpha: 0.10),
            const Color(0xFF0F1115),
            const Color(0xFF0F1115),
          ]
        : [
            colors.accentBlue.withValues(alpha: 0.08),
            const Color(0xFFF8FAFC),
            const Color(0xFFFFFFFF),
          ];

    return Scaffold(
      body: AnimatedOpacity(
        opacity: _leaving ? 0 : 1,
        duration: const Duration(milliseconds: 260),
        child: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: backgroundGradient,
                  ),
                ),
              ),
            ),
            // Padrão de pontinhos decorativo, igual à moldura das outras
            // telas do app — bem sutil, não compete com o conteúdo.
            Positioned.fill(
              child: CustomPaint(
                painter: _DotGridPainter(
                  color: (isDark ? Colors.white : Colors.black).withValues(alpha: 0.05),
                ),
              ),
            ),
            // Brilho duplo: azul no canto superior direito, roxo no
            // inferior esquerdo — dá profundidade sem ficar poluído.
            Positioned(
              top: -120,
              right: -120,
              child: _Glow(color: colors.accentBlue, size: 360, opacity: 0.20),
            ),
            const Positioned(
              bottom: -140,
              left: -140,
              child: _Glow(color: Colors.deepPurpleAccent, size: 380, opacity: 0.14),
            ),
            SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (_, __) => Opacity(
                                opacity: _logoFade.value,
                                child: Transform.rotate(
                                  angle: _logoRotation.value,
                                  child: Transform.scale(
                                    scale: _logoScale.value,
                                    child: Image.asset(
                                      'assets/images/logo.png',
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.contain,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 18),
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (_, __) => Opacity(
                                opacity: _titleFade.value,
                                child: Text(
                                  'Sincronize sua vida',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            AnimatedBuilder(
                              animation: _controller,
                              builder: (_, __) => Opacity(
                                opacity: _taglineFade.value,
                                child: Text(
                                  'Tudo num so lugar',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: context.textSecondary,
                                    fontWeight: FontWeight.w500,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // Barra de carregamento fina, preenchendo junto com a
                  // animação de entrada — dá a sensação de "algo está
                  // acontecendo" em vez de só uma espera parada.
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40, left: 60, right: 60),
                    child: AnimatedBuilder(
                      animation: _progress,
                      builder: (_, __) => ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: LinearProgressIndicator(
                          value: _progress.value,
                          minHeight: 3,
                          backgroundColor: colors.cardBackgroundAlt,
                          valueColor: AlwaysStoppedAnimation(colors.accentBlue),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable soft radial glow blob used for the decorative corner lights.
class _Glow extends StatelessWidget {
  final Color color;
  final double size;
  final double opacity;

  const _Glow({required this.color, required this.size, required this.opacity});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color.withValues(alpha: opacity), Colors.transparent],
        ),
      ),
    );
  }
}

/// Subtle dot-grid background, matching the decorative bezel pattern used
/// elsewhere in the app's mockups.
class _DotGridPainter extends CustomPainter {
  final Color color;
  const _DotGridPainter({required this.color});

  static const double _spacing = 22;
  static const double _radius = 1.1;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    for (double y = 0; y < size.height; y += _spacing) {
      for (double x = 0; x < size.width; x += _spacing) {
        canvas.drawCircle(Offset(x, y), _radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DotGridPainter oldDelegate) => oldDelegate.color != color;
}

