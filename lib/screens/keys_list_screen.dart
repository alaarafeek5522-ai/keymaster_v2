import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/key_model.dart';
import '../providers/keys_provider.dart';
import '../theme/app_theme.dart';

class KeysListScreen extends StatefulWidget {
  const KeysListScreen({super.key});

  @override
  State<KeysListScreen> createState() => _KeysListScreenState();
}

class _KeysListScreenState extends State<KeysListScreen> {
  String _filter = 'all'; // all, active, expired, unused, disabled

  List<KeyModel> _getFilteredKeys(List<KeyModel> allKeys) {
    switch (_filter) {
      case 'active':
        return allKeys.where((k) => k.active && !k.isExpired && k.isUsed).toList();
      case 'expired':
        return allKeys.where((k) => k.isExpired).toList();
      case 'unused':
        return allKeys.where((k) => !k.isUsed).toList();
      case 'disabled':
        return allKeys.where((k) => !k.active).toList();
      default:
        return allKeys;
    }
  }

  void _copyKey(String key) {
    Clipboard.setData(ClipboardData(text: key));
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✅ تم نسخ المفتاح', style: GoogleFonts.cairo()),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _toggleKey(KeyModel keyModel) async {
    final provider = context.read<KeysProvider>();
    final success = await provider.toggleKey(keyModel.key);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل التحديث', style: GoogleFonts.cairo()),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _deleteKey(KeyModel keyModel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text('حذف المفتاح', style: GoogleFonts.cairo(color: AppTheme.textPrimary)),
        content: Text('هل تريد حذف المفتاح "${keyModel.key}"؟', style: GoogleFonts.cairo(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('حذف', style: GoogleFonts.cairo(color: AppTheme.error)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<KeysProvider>();
      final success = await provider.deleteKey(keyModel.key);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم الحذف', style: GoogleFonts.cairo()),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ فشل الحذف', style: GoogleFonts.cairo()),
            backgroundColor: AppTheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  Future<void> _resetDevice(KeyModel keyModel) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text('إعادة تعيين الجهاز', style: GoogleFonts.cairo(color: AppTheme.textPrimary)),
        content: Text('هل تريد إعادة تعيين الجهاز للمفتاح "${keyModel.key}"؟', style: GoogleFonts.cairo(color: AppTheme.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء', style: GoogleFonts.cairo(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('إعادة تعيين', style: GoogleFonts.cairo(color: AppTheme.warning)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final provider = context.read<KeysProvider>();
      final success = await provider.resetDevice(keyModel.key);
      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ تم إعادة التعيين', style: GoogleFonts.cairo()),
            backgroundColor: AppTheme.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('قائمة المفاتيح', style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.gold),
            onPressed: () => context.read<KeysProvider>().loadData(),
          ),
        ],
      ),
      body: Consumer<KeysProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
          }

          final allKeys = provider.keys.values.toList()..sort((a, b) => b.key.compareTo(a.key));
          final filteredKeys = _getFilteredKeys(allKeys);

          return Column(
            children: [
              // Filter chips
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _FilterChip(label: 'الكل', selected: _filter == 'all', onTap: () => setState(() => _filter = 'all')),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'نشط', selected: _filter == 'active', onTap: () => setState(() => _filter = 'active')),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'جديد', selected: _filter == 'unused', onTap: () => setState(() => _filter = 'unused')),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'منتهي', selected: _filter == 'expired', onTap: () => setState(() => _filter = 'expired')),
                      const SizedBox(width: 8),
                      _FilterChip(label: 'معطل', selected: _filter == 'disabled', onTap: () => setState(() => _filter = 'disabled')),
                    ],
                  ),
                ),
              ),

              // Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      '${filteredKeys.length} مفتاح',
                      style: GoogleFonts.cairo(color: AppTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // List
              Expanded(
                child: filteredKeys.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.key_off_rounded, color: AppTheme.textMuted, size: 64),
                            const SizedBox(height: 16),
                            Text('لا توجد مفاتيح', style: GoogleFonts.cairo(color: AppTheme.textMuted, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredKeys.length,
                        itemBuilder: (ctx, i) {
                          final keyModel = filteredKeys[i];
                          return _buildKeyCard(keyModel, i);
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildKeyCard(KeyModel keyModel, int index) {
    return Slidable(
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => _resetDevice(keyModel),
            backgroundColor: AppTheme.warning.withOpacity(0.2),
            foregroundColor: AppTheme.warning,
            icon: Icons.phonelink_erase_rounded,
            label: 'إعادة تعيين',
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
          ),
          SlidableAction(
            onPressed: (_) => _deleteKey(keyModel),
            backgroundColor: AppTheme.error.withOpacity(0.2),
            foregroundColor: AppTheme.error,
            icon: Icons.delete,
            label: 'حذف',
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: keyModel.statusColor.withOpacity(0.2),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Status dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: keyModel.statusColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: keyModel.statusColor.withOpacity(0.4), blurRadius: 8, spreadRadius: 1),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Key text
                Expanded(
                  child: Text(
                    keyModel.key,
                    style: GoogleFonts.cairo(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),

                // 🔑 زر نسخ المفتاح
                GestureDetector(
                  onTap: () => _copyKey(keyModel.key),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.gold.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.gold.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.copy_rounded, color: AppTheme.gold, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'نسخ',
                          style: GoogleFonts.cairo(
                            color: AppTheme.gold,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Toggle active
                Switch(
                  value: keyModel.active,
                  onChanged: (v) => _toggleKey(keyModel),
                  activeColor: AppTheme.gold,
                  activeTrackColor: AppTheme.gold.withOpacity(0.3),
                  inactiveThumbColor: AppTheme.error,
                  inactiveTrackColor: AppTheme.error.withOpacity(0.3),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Info row
            Row(
              children: [
                _InfoBadge(
                  icon: Icons.timer_rounded,
                  text: '${keyModel.duration} ${keyModel.unit}',
                  color: AppTheme.cyan,
                ),
                const SizedBox(width: 8),
                _InfoBadge(
                  icon: Icons.info_outline_rounded,
                  text: keyModel.status,
                  color: keyModel.statusColor,
                ),
                if (keyModel.daysLeft != null) ...[
                  const SizedBox(width: 8),
                  _InfoBadge(
                    icon: Icons.hourglass_bottom_rounded,
                    text: '${keyModel.daysLeft} يوم متبقي',
                    color: AppTheme.warning,
                  ),
                ],
              ],
            ),

            if (keyModel.deviceId != null && keyModel.deviceId!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'الجهاز: ${keyModel.deviceId}',
                style: GoogleFonts.cairo(color: AppTheme.textMuted, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(delay: (index * 50).ms);
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.gold.withOpacity(0.15) : AppTheme.bgElevated,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppTheme.gold.withOpacity(0.3) : Colors.white.withOpacity(0.06),
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: GoogleFonts.cairo(
            color: selected ? AppTheme.gold : AppTheme.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _InfoBadge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _InfoBadge({
    required this.icon,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            text,
            style: GoogleFonts.cairo(color: color, fontSize: 11, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
