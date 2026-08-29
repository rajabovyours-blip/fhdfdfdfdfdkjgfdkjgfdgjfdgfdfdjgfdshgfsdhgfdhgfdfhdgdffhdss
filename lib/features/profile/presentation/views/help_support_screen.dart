import 'package:flutter/material.dart';
import 'package:milliy_metr/core/theme/app_colors_extension.dart';
import 'package:milliy_metr/l10n/l10n_extension.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: Text(
          l10n.helpAndSupport,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: context.colors.background,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          // FAQ Section
          _buildSectionHeader(context, l10n.faq),
          _buildFaqTile(context, l10n.faqDelivery, l10n.faqDeliveryAnswer),
          _buildFaqTile(context, l10n.faqPayment, l10n.faqPaymentAnswer),
          _buildFaqTile(context, l10n.faqReturn, l10n.faqReturnAnswer),
          _buildFaqTile(context, l10n.faqWarranty, l10n.faqWarrantyAnswer),

          Container(height: 8, color: context.colors.surface),

          // Contact Section
          _buildSectionHeader(context, l10n.contactSupport),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                buildSocialTile(
                  context: context,
                  iconWidget: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF229ED9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset('assets/svg/telegram.svg', colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn)),
                  ),
                  title: l10n.contactViaTelegram,
                  subtitle: '@milliy_metr',
                  onTap: () => _launchUrl('https://t.me/milliy_metr', external: true),
                ),
                buildSocialTile(
                  context: context,
                  iconWidget: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF833AB4), Color(0xFFFD1D1D), Color(0xFFFCB045)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: SvgPicture.asset('assets/svg/instagram.svg'),
                  ),
                  title: l10n.ourInstagramPage,
                  subtitle: '@milliy_metr',
                  onTap: () => _launchUrl('https://instagram.com/milliy_metr', external: true),
                ),
                buildSocialTile(
                  context: context,
                  iconWidget: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 20),
                  ),
                  title: l10n.customerSupport,
                  subtitle: '+998 50 072 33 33',
                  onTap: () => _launchUrl('tel:+998500723333'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          Container(height: 8, color: context.colors.surface),

          // About Section
          _buildSectionHeader(context, l10n.aboutApp),
          ListTile(
            leading: Icon(Icons.info_outline, color: context.colors.textMedium),
            title: Text(
              l10n.appVersion,
              style: TextStyle(color: context.colors.textHigh, fontSize: 15),
            ),
            trailing: Text(
              '1.0.0',
              style: TextStyle(color: context.colors.textMedium, fontSize: 14),
            ),
          ),
          ListTile(
            leading: Icon(Icons.privacy_tip_outlined, color: context.colors.textMedium),
            title: Text(
              l10n.privacyPolicy,
              style: TextStyle(color: context.colors.textHigh, fontSize: 15),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: context.colors.textMedium, size: 20),
            onTap: () => _launchUrl('https://milliymetr.uz/privacy'),
          ),
          ListTile(
            leading: Icon(Icons.description_outlined, color: context.colors.textMedium),
            title: Text(
              l10n.termsOfUse,
              style: TextStyle(color: context.colors.textHigh, fontSize: 15),
            ),
            trailing: Icon(Icons.chevron_right_rounded, color: context.colors.textMedium, size: 20),
            onTap: () => _launchUrl('https://milliymetr.uz/terms'),
          ),

          const SizedBox(height: 32),

          // Logo
          Center(
            child: Column(
              children: [
                Image.asset(
                  'assets/images/milliy_metr_logo_transparent.png',
                  height: 64,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 8),
                Text(
                  'Milliy Metr',
                  style: TextStyle(
                    color: context.colors.textHigh,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: TextStyle(
          color: context.colors.textMedium,
          fontSize: 13,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildFaqTile(BuildContext context, String question, String answer) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 20),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        leading:
            Icon(Icons.help_outline, color: context.colors.primary, size: 22),
        title: Text(
          question,
          style: TextStyle(color: context.colors.textHigh, fontSize: 15),
        ),
        iconColor: context.colors.textMedium,
        collapsedIconColor: context.colors.textMedium,
        children: [
          Text(
            answer,
            style: TextStyle(
              color: context.colors.textMedium,
              fontSize: 14,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSocialTile({
    required BuildContext context,
    required Widget iconWidget,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF16181F) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFE5E7EB),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: iconWidget,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            color: isDark ? Colors.white54 : Colors.black54,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }

  Future<void> _launchUrl(String url, {bool external = false}) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(
        uri,
        mode: external ? LaunchMode.externalApplication : LaunchMode.platformDefault,
      );
    } catch (e) {
      debugPrint('Could not launch $url');
    }
  }
}
