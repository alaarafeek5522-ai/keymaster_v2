import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/keys_provider.dart';
import '../theme/app_theme.dart';

class KeysListScreen extends StatelessWidget {
  const KeysListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('المفاتيح', style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Consumer<KeysProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
          }

          final keys = provider.keys.values.toList();

          if (keys.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.key_off_rounded, color: AppTheme.textMuted, size: 64),
                  const SizedBox(height: 16),
                  Text('لا يوجد مفاتيح', style: GoogleFonts.cairo(color: AppTheme.textMuted, fontSize: 16)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: keys.length,
            itemBuilder: (ctx, i) {
              final key = keys[i];
              return Slidable(
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        Clipboard.setData(ClipboardData(text: key.key));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تم نسخ المفتاح', style: GoogleFonts.cairo()),
                            backgroundColor: AppTheme.gold,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      },
                      backgroundColor: AppTheme.cyan.withOpacity(0.2),
                      foregroundColor: AppTheme.cyan,
                      icon: Icons.copy,
                      label: 'نسخ',
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    ),
                    SlidableAction(
                      onPressed: (_) => Share.share(key.key),
                      backgroundColor: AppTheme.gold.withOpacity(0.2),
                      foregroundColor: AppTheme.gold,
                      icon: Icons.share,
                      label: 'مشاركة',
                    ),
                  ],
                ),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.bgCard,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: key.statusColor.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: key.statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          key.isUsed ? Icons.key_rounded : Icons.key_off_rounded,
                          color: key.statusColor,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(key.key, style: GoogleFonts.cairo(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              letterSpacing: 1,
                            )),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: key.statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(key.status, style: GoogleFonts.cairo(
                                    color: key.statusColor,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  )),
                                ),
                                const SizedBox(width: 8),
                                if (key.daysLeft != null)
                                  Text('${key.daysLeft} يوم', style: GoogleFonts.cairo(
                                    color: AppTheme.textSecondary,
                                    fontSize: 11,
                                  )),
                              ],
                            ),
                          ],
                        ),
                      ),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: AppTheme.textSecondary),
                        color: AppTheme.bgElevated,
                        onSelected: (value) async {
                          switch (value) {
                            case 'toggle':
                              await provider.toggleKey(key.key);
                              break;
                            case 'reset':
                              await provider.resetDevice(key.key);
                              break;
                            case 'delete':
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  backgroundColor: AppTheme.bgCard,
                                  title: Text('حذف المفتاح', style: GoogleFonts.cairo(color: AppTheme.textPrimary)),
                                  content: Text('هل تريد حذف ${key.key}؟', style: GoogleFonts.cairo(color: AppTheme.textSecondary)),
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
                              if (confirm == true) await provider.deleteKey(key.key);
                              break;
                          }
                        },
                        itemBuilder: (_) => [
                          PopupMenuItem(
                            value: 'toggle',
                            child: Row(
                              children: [
                                Icon(key.active ? Icons.block : Icons.check_circle, color: key.active ? AppTheme.error : AppTheme.success),
                                const SizedBox(width: 8),
                                Text(key.active ? 'تعطيل' : 'تفعيل', style: GoogleFonts.cairo()),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'reset',
                            child: Row(
                              children: [
                                const Icon(Icons.restart_alt, color: AppTheme.cyan),
                                const SizedBox(width: 8),
                                Text('إعادة تعيين', style: GoogleFonts.cairo()),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                const Icon(Icons.delete, color: AppTheme.error),
                                const SizedBox(width: 8),
                                Text('حذف', style: GoogleFonts.cairo(color: AppTheme.error)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (i * 40).ms).slideX(begin: 0.1);
            },
          );
        },
      ),
    );
  }
}
