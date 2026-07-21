import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/keys_provider.dart';
import '../theme/app_theme.dart';
import 'keys_list_screen.dart';
import 'add_keys_screen.dart';
import 'app_control_screen.dart';
import 'offers_manager_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      body: Consumer<KeysProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(24, 60, 24, 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('KeyMaster', style: GoogleFonts.cairo(fontSize: 26, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                            Text('لوحة التحكم', style: GoogleFonts.cairo(fontSize: 13, color: AppTheme.gold, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.refresh_rounded, color: AppTheme.gold),
                        onPressed: () => provider.loadData(),
                      ),
                    ],
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(child: _StatCard(
                        icon: Icons.key_rounded,
                        iconColor: AppTheme.gold,
                        title: 'الإجمالي',
                        value: '${provider.totalCount}',
                        subtitle: 'مفتاح',
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        icon: Icons.check_circle_rounded,
                        iconColor: AppTheme.success,
                        title: 'نشط',
                        value: '${provider.activeCount}',
                        subtitle: 'مفتاح',
                      )),
                    ],
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(top: 12)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    children: [
                      Expanded(child: _StatCard(
                        icon: Icons.hourglass_empty_rounded,
                        iconColor: AppTheme.warning,
                        title: 'منتهي',
                        value: '${provider.expiredCount}',
                        subtitle: 'مفتاح',
                      )),
                      const SizedBox(width: 12),
                      Expanded(child: _StatCard(
                        icon: Icons.new_releases_rounded,
                        iconColor: AppTheme.cyan,
                        title: 'جديد',
                        value: '${provider.unusedCount}',
                        subtitle: 'مفتاح',
                      )),
                    ],
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(top: 32)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      _MenuButton(
                        icon: Icons.add_circle_rounded,
                        color: AppTheme.gold,
                        title: 'إضافة مفاتيح',
                        subtitle: 'توليد مفاتيح جديدة',
                        onTap: () => Navigator.push(context, _SlideRoute(page: const AddKeysScreen())),
                      ),
                      const SizedBox(height: 12),
                      _MenuButton(
                        icon: Icons.list_alt_rounded,
                        color: AppTheme.cyan,
                        title: 'قائمة المفاتيح',
                        subtitle: 'عرض وإدارة المفاتيح',
                        onTap: () => Navigator.push(context, _SlideRoute(page: const KeysListScreen())),
                      ),
                      const SizedBox(height: 12),
                      _MenuButton(
                        icon: Icons.local_fire_department_rounded,
                        color: const Color(0xFFFF6B35),
                        title: 'إدارة العروض 🔥',
                        subtitle: 'إضافة وتعديل عروض نار',
                        onTap: () => Navigator.push(context, _SlideRoute(page: const OffersManagerScreen())),
                      ),
                      const SizedBox(height: 12),
                      _MenuButton(
                        icon: Icons.settings_rounded,
                        color: AppTheme.purple,
                        title: 'تحكم التطبيق',
                        subtitle: 'إعدادات App Control',
                        onTap: () => Navigator.push(context, _SlideRoute(page: const AppControlScreen())),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverPadding(padding: EdgeInsets.only(bottom: 40)),
            ],
          );
        },
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glowCard(glowColor: iconColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 8),
              Text(title, style: GoogleFonts.cairo(color: AppTheme.textSecondary, fontSize: 12)),
            ],
          ),
          const SizedBox(height: 12),
          Text(value, style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w900)),
          Text(subtitle, style: GoogleFonts.cairo(color: AppTheme.textMuted, fontSize: 11)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1);
  }
}

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _MenuButton({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: AppTheme.glowCard(glowColor: color),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: GoogleFonts.cairo(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: color, size: 18),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _SlideRoute extends PageRouteBuilder {
  final Widget page;
  _SlideRoute({required this.page}) : super(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      final slide = Tween<Offset>(begin: const Offset(0.12, 0.0), end: Offset.zero).animate(curved);
      final fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
      return FadeTransition(opacity: fade, child: SlideTransition(position: slide, child: child));
    },
    transitionDuration: const Duration(milliseconds: 360),
  );
}
