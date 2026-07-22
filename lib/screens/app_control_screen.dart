import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/keys_provider.dart';
import '../theme/app_theme.dart';

class AppControlScreen extends StatefulWidget {
  const AppControlScreen({super.key});
  @override
  State<AppControlScreen> createState() => _AppControlScreenState();
}

class _AppControlScreenState extends State<AppControlScreen> {
  bool _forceStop = false;
  bool _forceUpdate = false;

  late final TextEditingController _stopMsgCtrl;
  late final TextEditingController _updateMsgCtrl;
  late final TextEditingController _updateUrlCtrl;
  late final TextEditingController _messageCtrl;
  late final TextEditingController _messageTitleCtrl;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final control = context.read<KeysProvider>().appControl;
    _forceStop = control['force_stop'] == true;
    _forceUpdate = control['force_update'] == true;

    _stopMsgCtrl = TextEditingController(text: control['force_stop_msg']?.toString() ?? 'التطبيق موقوف مؤقتاً');
    _updateMsgCtrl = TextEditingController(text: control['force_update_msg']?.toString() ?? 'يوجد تحديث جديد');
    _updateUrlCtrl = TextEditingController(text: control['update_url']?.toString() ?? '');
    _messageCtrl = TextEditingController(text: control['message']?.toString() ?? '');
    _messageTitleCtrl = TextEditingController(text: control['message_title']?.toString() ?? 'تنبيه');
  }

  @override
  void dispose() {
    _stopMsgCtrl.dispose();
    _updateMsgCtrl.dispose();
    _updateUrlCtrl.dispose();
    _messageCtrl.dispose();
    _messageTitleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    final success = await context.read<KeysProvider>().updateAppControl({
      'force_stop': _forceStop,
      'force_stop_msg': _stopMsgCtrl.text.isEmpty ? 'التطبيق موقوف مؤقتاً' : _stopMsgCtrl.text,
      'force_update': _forceUpdate,
      'force_update_msg': _updateMsgCtrl.text.isEmpty ? 'يوجد تحديث جديد' : _updateMsgCtrl.text,
      'update_url': _updateUrlCtrl.text,
      'message': _messageCtrl.text,
      'message_title': _messageTitleCtrl.text.isEmpty ? 'تنبيه' : _messageTitleCtrl.text,
    });

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ تم الحفظ', style: GoogleFonts.cairo()),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ فشل الحفظ', style: GoogleFonts.cairo()),
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
        title: Text('تحكم التطبيق', style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildSection(
              icon: Icons.block_rounded,
              color: AppTheme.error,
              title: 'إيقاف التطبيق',
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('إيقاف التطبيق', style: GoogleFonts.cairo(color: AppTheme.textPrimary)),
                    subtitle: Text('منع جميع المستخدمين من الاستخدام', style: GoogleFonts.cairo(color: AppTheme.textSecondary, fontSize: 12)),
                    value: _forceStop,
                    activeColor: AppTheme.error,
                    onChanged: (v) => setState(() => _forceStop = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_forceStop) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _stopMsgCtrl,
                      style: GoogleFonts.cairo(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'رسالة الإيقاف',
                        hintStyle: GoogleFonts.cairo(color: AppTheme.textMuted),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildSection(
              icon: Icons.system_update_rounded,
              color: AppTheme.warning,
              title: 'فرض تحديث',
              child: Column(
                children: [
                  SwitchListTile(
                    title: Text('فرض تحديث', style: GoogleFonts.cairo(color: AppTheme.textPrimary)),
                    subtitle: Text('إجبار المستخدمين على التحديث', style: GoogleFonts.cairo(color: AppTheme.textSecondary, fontSize: 12)),
                    value: _forceUpdate,
                    activeColor: AppTheme.warning,
                    onChanged: (v) => setState(() => _forceUpdate = v),
                    contentPadding: EdgeInsets.zero,
                  ),
                  if (_forceUpdate) ...[
                    const SizedBox(height: 8),
                    TextField(
                      controller: _updateMsgCtrl,
                      style: GoogleFonts.cairo(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'رسالة التحديث',
                        hintStyle: GoogleFonts.cairo(color: AppTheme.textMuted),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _updateUrlCtrl,
                      style: GoogleFonts.cairo(color: AppTheme.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'رابط التحديث',
                        hintStyle: GoogleFonts.cairo(color: AppTheme.textMuted),
                      ),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            _buildSection(
              icon: Icons.campaign_rounded,
              color: AppTheme.cyan,
              title: 'رسالة عامة',
              child: Column(
                children: [
                  TextField(
                    controller: _messageTitleCtrl,
                    style: GoogleFonts.cairo(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: 'عنوان الرسالة',
                      hintStyle: GoogleFonts.cairo(color: AppTheme.textMuted),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _messageCtrl,
                    style: GoogleFonts.cairo(color: AppTheme.textPrimary),
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'محتوى الرسالة',
                      hintStyle: GoogleFonts.cairo(color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
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
                onPressed: _isLoading ? null : _save,
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
                              const Icon(Icons.save_rounded, color: AppTheme.bgDark, size: 20),
                              const SizedBox(width: 10),
                              Text('حفظ الإعدادات', style: GoogleFonts.cairo(color: AppTheme.bgDark, fontSize: 17, fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required IconData icon, required Color color, required String title, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.glowCard(glowColor: color),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 12),
              Text(title, style: GoogleFonts.cairo(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
