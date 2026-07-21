import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/keys_provider.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _shimmerCtrl;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2000))..repeat();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    
    await context.read<KeysProvider>().loadData();
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          pageBuilder: (_, a, __) => const DashboardScreen(),
          transitionsBuilder: (_, a, __, child) => FadeTransition(opacity: a, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() { _shimmerCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Stack(
        children: [
          Positioned(
            top: -100, right: -80,
            child: Container(
              width: 350, height: 350,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.gold.withOpacity(0.05),
                boxShadow: [BoxShadow(color: AppTheme.gold.withOpacity(0.08), blurRadius: 100, spreadRadius: 50)],
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.bgCard,
                    boxShadow: [
                      BoxShadow(color: AppTheme.gold.withOpacity(0.3), blurRadius: 50, spreadRadius: 5),
                      BoxShadow(color: AppTheme.gold.withOpacity(0.15), blurRadius: 100, spreadRadius: 20),
                      BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10)),
                    ],
                    border: Border.all(color: AppTheme.gold.withOpacity(0.2), width: 2),
                  ),
                  child: const Icon(Icons.vpn_key_rounded, color: AppTheme.gold, size: 60),
                ).animate().fadeIn(duration: 600.ms).scale(begin: const Offset(0.8, 0.8)),

                const SizedBox(height: 40),

                AnimatedBuilder(
                  animation: _shimmerCtrl,
                  builder: (_, __) => ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: const [AppTheme.gold, AppTheme.goldGlow, AppTheme.cyan, AppTheme.goldGlow, AppTheme.gold],
                      stops: [
                        0.0,
                        (_shimmerCtrl.value - 0.15).clamp(0.0, 1.0),
                        _shimmerCtrl.value.clamp(0.0, 1.0),
                        (_shimmerCtrl.value + 0.15).clamp(0.0, 1.0),
                        1.0,
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ).createShader(bounds),
                    child: Text('KeyMaster',
                      style: GoogleFonts.cairo(fontSize: 36, fontWeight: FontWeight.w900, color: AppTheme.gold)),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.2),

                const SizedBox(height: 8),

                Text('V2 PREMIUM',
                  style: GoogleFonts.cairo(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted, letterSpacing: 6),
                ).animate().fadeIn(delay: 200.ms),

                const SizedBox(height: 60),

                Consumer<KeysProvider>(
                  builder: (context, provider, _) {
                    if (provider.error != null) {
                      return Text(
                        '⚠️ ${provider.error}',
                        style: GoogleFonts.cairo(color: AppTheme.error, fontSize: 13),
                      ).animate().shake();
                    }
                    return const SizedBox(
                      width: 180,
                      child: LinearProgressIndicator(
                        backgroundColor: AppTheme.bgElevated,
                        valueColor: AlwaysStoppedAnimation(AppTheme.gold),
                        minHeight: 3,
                      ),
                    ).animate().fadeIn();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
