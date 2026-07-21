import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import '../models/offer_model.dart';
import '../services/image_upload_service.dart';
import '../theme/app_theme.dart';

class AddOfferScreen extends StatefulWidget {
  final OfferModel? offer; // null = add, existing = edit
  final Function(OfferModel) onSave;

  const AddOfferScreen({super.key, this.offer, required this.onSave});

  @override
  State<AddOfferScreen> createState() => _AddOfferScreenState();
}

class _AddOfferScreenState extends State<AddOfferScreen> {
  final _titleCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _telegramCtrl = TextEditingController();
  
  File? _selectedImage;
  String? _existingImageUrl;
  bool _isLoading = false;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    if (widget.offer != null) {
      _isEditing = true;
      _titleCtrl.text = widget.offer!.title;
      _messageCtrl.text = widget.offer!.message;
      _whatsappCtrl.text = widget.offer!.whatsapp;
      _telegramCtrl.text = widget.offer!.telegram;
      _existingImageUrl = widget.offer!.imageUrl;
    } else {
      // Defaults
      _whatsappCtrl.text = 'https://wa.me/+201093150781';
      _telegramCtrl.text = 'https://t.me/X_Abo_Abbas_x';
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200, maxHeight: 1200);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final message = _messageCtrl.text.trim();
    final whatsapp = _whatsappCtrl.text.trim();
    final telegram = _telegramCtrl.text.trim();

    if (title.isEmpty || message.isEmpty) {
      _showError('عنوان ووصف العرض مطلوبين');
      return;
    }

    setState(() => _isLoading = true);

    String imageUrl = _existingImageUrl ?? '';

    // Upload new image if selected
    if (_selectedImage != null) {
      final fileName = 'offer_${DateTime.now().millisecondsSinceEpoch}${path.extension(_selectedImage!.path)}';
      final uploaded = await ImageUploadService.uploadImage(_selectedImage!, fileName);
      if (uploaded != null) {
        imageUrl = uploaded;
        // Delete old image if editing
        if (_isEditing && _existingImageUrl != null && _existingImageUrl!.isNotEmpty) {
          final oldFileName = path.basename(_existingImageUrl!);
          await ImageUploadService.deleteImage(oldFileName);
        }
      } else {
        setState(() => _isLoading = false);
        _showError('فشل رفع الصورة');
        return;
      }
    }

    final offer = OfferModel(
      id: widget.offer?.id ?? 'offer_${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      message: message,
      imageUrl: imageUrl,
      whatsapp: whatsapp,
      telegram: telegram,
      active: widget.offer?.active ?? true,
      createdAt: widget.offer?.createdAt ?? DateTime.now(),
    );

    widget.onSave(offer);
    
    if (mounted) {
      setState(() => _isLoading = false);
      Navigator.pop(context);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.cairo()),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          _isEditing ? 'تعديل عرض' : 'إضافة عرض جديد',
          style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Image picker
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: AppTheme.bgElevated,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.gold.withOpacity(0.2)),
                ),
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(_selectedImage!, fit: BoxFit.cover),
                      )
                    : _existingImageUrl != null && _existingImageUrl!.isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Image.network(_existingImageUrl!, fit: BoxFit.cover),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_photo_alternate_rounded, color: AppTheme.gold.withOpacity(0.5), size: 50),
                              const SizedBox(height: 8),
                              Text('اضغط لاختيار صورة', style: GoogleFonts.cairo(color: AppTheme.textMuted)),
                            ],
                          ),
              ),
            ).animate().fadeIn(duration: 400.ms),

            const SizedBox(height: 24),

            // Title
            TextField(
              controller: _titleCtrl,
              style: GoogleFonts.cairo(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'عنوان العرض',
                hintStyle: GoogleFonts.cairo(color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.title_rounded, color: AppTheme.gold),
              ),
            ).animate().fadeIn(delay: 100.ms),

            const SizedBox(height: 16),

            // Message
            TextField(
              controller: _messageCtrl,
              style: GoogleFonts.cairo(color: AppTheme.textPrimary),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'وصف العرض',
                hintStyle: GoogleFonts.cairo(color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.description_rounded, color: AppTheme.gold),
              ),
            ).animate().fadeIn(delay: 200.ms),

            const SizedBox(height: 16),

            // WhatsApp
            TextField(
              controller: _whatsappCtrl,
              style: GoogleFonts.cairo(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'رابط واتساب',
                hintStyle: GoogleFonts.cairo(color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.chat_rounded, color: Color(0xFF25D366)),
              ),
            ).animate().fadeIn(delay: 300.ms),

            const SizedBox(height: 16),

            // Telegram
            TextField(
              controller: _telegramCtrl,
              style: GoogleFonts.cairo(color: AppTheme.textPrimary),
              decoration: InputDecoration(
                hintText: 'رابط تلجرام',
                hintStyle: GoogleFonts.cairo(color: AppTheme.textMuted),
                prefixIcon: const Icon(Icons.telegram, color: Color(0xFF0088CC)),
              ),
            ).animate().fadeIn(delay: 400.ms),

            const SizedBox(height: 32),

            // Save button
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
                              Text('حفظ العرض', style: GoogleFonts.cairo(color: AppTheme.bgDark, fontSize: 17, fontWeight: FontWeight.bold)),
                            ],
                          ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }
}
