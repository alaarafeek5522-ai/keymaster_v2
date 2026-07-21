import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/offer_model.dart';
import '../providers/keys_provider.dart';
import '../theme/app_theme.dart';
import 'add_offer_screen.dart';

class OffersManagerScreen extends StatelessWidget {
  const OffersManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgDark,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('إدارة العروض 🔥', style: GoogleFonts.cairo(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_rounded, color: AppTheme.gold),
            onPressed: () => _addOffer(context),
          ),
        ],
      ),
      body: Consumer<KeysProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.gold));
          }

          final offers = _getOffers(provider);
          
          if (offers.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.local_fire_department_rounded, color: AppTheme.textMuted, size: 64),
                  const SizedBox(height: 16),
                  Text('لا توجد عروض', style: GoogleFonts.cairo(color: AppTheme.textMuted, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('اضغط + لإضافة عرض جديد', style: GoogleFonts.cairo(color: AppTheme.textMuted, fontSize: 12)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: offers.length,
            itemBuilder: (ctx, i) {
              final offer = offers[i];
              return Slidable(
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) => _editOffer(context, offer),
                      backgroundColor: AppTheme.gold.withOpacity(0.2),
                      foregroundColor: AppTheme.gold,
                      icon: Icons.edit,
                      label: 'تعديل',
                      borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                    ),
                    SlidableAction(
                      onPressed: (_) => _deleteOffer(context, offer),
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
                      color: offer.active ? AppTheme.gold.withOpacity(0.2) : AppTheme.error.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Image thumbnail
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: offer.imageUrl.isNotEmpty
                            ? Image.network(
                                offer.imageUrl,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  width: 60,
                                  height: 60,
                                  color: AppTheme.bgElevated,
                                  child: Icon(Icons.image_not_supported, color: AppTheme.textMuted),
                                ),
                              )
                            : Container(
                                width: 60,
                                height: 60,
                                color: AppTheme.bgElevated,
                                child: Icon(Icons.local_fire_department, color: AppTheme.gold.withOpacity(0.3)),
                              ),
                      ),
                      const SizedBox(width: 14),
                      
                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    offer.title,
                                    style: GoogleFonts.cairo(
                                      color: AppTheme.textPrimary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: offer.active ? AppTheme.success.withOpacity(0.1) : AppTheme.error.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    offer.active ? 'نشط' : 'معطل',
                                    style: GoogleFonts.cairo(
                                      color: offer.active ? AppTheme.success : AppTheme.error,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              offer.message,
                              style: GoogleFonts.cairo(color: AppTheme.textSecondary, fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      
                      // Toggle active
                      Switch(
                        value: offer.active,
                        onChanged: (v) => _toggleOffer(context, offer, v),
                        activeColor: AppTheme.gold,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(delay: (i * 50).ms);
            },
          );
        },
      ),
    );
  }

  List<OfferModel> _getOffers(KeysProvider provider) {
    final data = provider.appControl; // This should be full data
    // We need to access the raw data
    return [];
  }

  void _addOffer(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddOfferScreen(
          onSave: (offer) => _saveOffer(context, offer),
        ),
      ),
    );
  }

  void _editOffer(BuildContext context, OfferModel offer) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddOfferScreen(
          offer: offer,
          onSave: (updated) => _saveOffer(context, updated),
        ),
      ),
    );
  }

  void _toggleOffer(BuildContext context, OfferModel offer, bool active) {
    final updated = offer.copyWith(active: active);
    _saveOffer(context, updated);
  }

  Future<void> _deleteOffer(BuildContext context, OfferModel offer) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppTheme.bgCard,
        title: Text('حذف العرض', style: GoogleFonts.cairo(color: AppTheme.textPrimary)),
        content: Text('هل تريد حذف "${offer.title}"؟', style: GoogleFonts.cairo(color: AppTheme.textSecondary)),
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

    if (confirm == true) {
      // TODO: Implement delete
    }
  }

  Future<void> _saveOffer(BuildContext context, OfferModel offer) async {
    // TODO: Implement save to Gist
  }
}
