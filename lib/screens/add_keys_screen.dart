import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/keys_provider.dart';
import '../theme/app_theme.dart';

class AddKeysScreen extends StatefulWidget {
  const AddKeysScreen({super.key});
  @override
  State<AddKeysScreen> createState() => _AddKeysScreenState();
}

class _AddKeysScreenState extends State<AddKeysScreen> {
  int _count = 1;
  int _duration = 30;
  String _unit = 'days';

  bool _isLoading = false;

  Future<void> _generate() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    final success = await context.read<KeysProvider>().addKeys(_count, _duration, _unit);

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم إنشاء $_count مفاتيح', style: GoogleFonts.cairo()),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل الإنشاء', style: GoogleFonts.cairo()),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('إضافة مفاتيح', style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: AppTheme.glowCard(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.gold.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
                        ),
                        child: const Icon(Icons.add_circle_rounded, color: AppTheme.gold, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('توليد مفاتيح', style: GoogleFonts.cairo(fontSize: 18, fontWeight: FontWeight.w900, color: AppTheme.textPrimary)),
                          Text('إنشاء مفاتيح تفعيل جديدة', style: GoogleFonts.cairo(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  Text('عدد المفاتيح', style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _NumberSelector(
                    value: _count,
                    min: 1,
                    max: 50,
                    onChanged: (v) => setState(() => _count = v),
                  ),

                  const SizedBox(height: 20),

                  Text('المدة', style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  _NumberSelector(
                    value: _duration,
                    min: 1,
                    max: 365,
                    onChanged: (v) => setState(() => _duration = v),
                  ),

                  const SizedBox(height: 20),

                  Text('وحدة المدة', style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _UnitChip(label: 'أيام', selected: _unit == 'days', onTap: () => setState(() => _unit = 'days')),
                      const SizedBox(width: 8),
                      _UnitChip(label: 'ساعات', selected: _unit == 'hours', onTap: () => setState(() => _unit = 'hours')),
                      const SizedBox(width: 8),
                      _UnitChip(label: 'أسابيع', selected: _unit == 'weeks', onTap: () => setState(() => _unit = 'weeks')),
                    ],
                  ),

                  const SizedBox(height: 28),

                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: EdgeInsets.zero,
                      ),
                      onPressed: _isLoading ? null : _generate,
                      child: Ink(
                        decoration: BoxDecoration(
                          gradient: _isLoading
                              ? const LinearGradient(colors: [AppTheme.textMuted, AppTheme.textMuted])
                              : const LinearGradient(colors: [AppTheme.gold, AppTheme.goldDim]),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [BoxShadow(color: AppTheme.gold.withOpacity(0.3), blurRadius: 16, offset: const Offset(0, 6))],
                        ),
                        child: Center(
                          child: _isLoading
                              ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: AppTheme.bgDark, strokeWidth: 2.5))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.auto_fix_high_rounded, color: AppTheme.bgDark, size: 20),
                                    const SizedBox(width: 10),
                                    Text('توليد المفاتيح', style: GoogleFonts.cairo(color: AppTheme.bgDark, fontSize: 17, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}

class _NumberSelector extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;

  const _NumberSelector({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.bgElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, color: AppTheme.gold),
            onPressed: value > min ? () => onChanged(value - 1) : null,
          ),
          Text('$value', style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontSize: 20, fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: AppTheme.gold),
            onPressed: value < max ? () => onChanged(value + 1) : null,
          ),
        ],
      ),
    );
  }
}

class _UnitChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _UnitChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.gold.withOpacity(0.15) : AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.gold.withOpacity(0.3) : Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Text(label,
          style: GoogleFonts.cairo(
            color: selected ? AppTheme.gold : AppTheme.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
