import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dialogs.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/services/notification_consent_manager.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/settings/controller/settings_controller.dart';
import 'package:oremusapp/main.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGrey3,
      child: GetX<SettingsController>(builder: (controller) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Personnalisez votre expérience spirituelle',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorGreenSemiLight,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            /*
            // Section Apparence
            SliverToBoxAdapter(
              child: _buildSectionHeader(context, 'Apparence', 'Personnalisez l\'interface'),
            ),

            SliverToBoxAdapter(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorGreen1.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    _buildSettingTile(
                      context,
                      icon: Icons.dark_mode_outlined,
                      title: 'Thème sombre',
                      subtitle: 'Réduisez la luminosité de l\'écran',
                      trailing: Switch(
                        value: false,
                        activeColor: colorGreenSemiLight,
                        onChanged: (value) {},
                      ),
                    ),
                    const Divider(height: 1, indent: 72),
                    _buildSettingTile(
                      context,
                      icon: Icons.text_fields_rounded,
                      title: 'Taille du texte',
                      subtitle: 'Ajustez la taille de la police',
                      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {},
                    ),
                  ],
                ),
              ),
            ),
            */

            // Section Compte
            if (isUserConnected.value) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                    context, 'Compte', 'Gérez vos informations personnelles'),
              ),
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colorGreen1.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      _buildSettingTile(
                        context,
                        icon: Icons.account_circle_outlined,
                        title: 'Mon profil',
                        subtitle: 'Modifiez vos informations',
                        trailing:
                            const Icon(Icons.chevron_right, color: Colors.grey),
                        onTap: () {
                          controller.moveToProfile();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Section Notifications
            if (isUserConnected.value) ...[
              SliverToBoxAdapter(
                child: _buildSectionHeader(
                    context, 'Notifications', 'Préférences de communication'),
              ),
              SliverToBoxAdapter(
                child: Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: colorGreen1.withValues(alpha: 0.5)),
                  ),
                  child: Column(
                    children: [
                      _buildNotificationSetting(context, controller),
                    ],
                  ),
                ),
              ),
            ],

            // Section À propos
            SliverToBoxAdapter(
              child: _buildSectionHeader(
                  context, 'À propos', 'Informations sur l\'application'),
            ),

            SliverToBoxAdapter(
              child: Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorGreen1.withValues(alpha: 0.5)),
                ),
                child: Column(
                  children: [
                    _buildSettingTile(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: 'OREMUS',
                      subtitle: 'En savoir plus sur OREMUS',
                      trailing:
                          const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        controller.moveToAbout();
                      },
                    ),
                    const Divider(height: 1, indent: 72),
                    _buildSettingTile(
                      context,
                      icon: Icons.support_outlined,
                      title: 'F.A.Q',
                      subtitle: 'Questions fréquentes de la communauté',
                      trailing:
                      const Icon(Icons.chevron_right, color: Colors.grey),
                      onTap: () {
                        controller.moveToFaq();
                      },
                    ),
                    const Divider(height: 1, indent: 72),
                    _buildSettingTile(
                      context,
                      icon: Icons.description_outlined,
                      title: 'Conditions d\'utilisation',
                      subtitle: 'Lisez nos conditions',
                      trailing:
                      const Icon(Icons.open_in_new_rounded, color: Colors.grey),
                      onTap: () {
                        doLaunchUrl(AppConstants.CGU_URL);
                      },
                    ),
                    const Divider(height: 1, indent: 72),
                    _buildSettingTile(
                      context,
                      icon: Icons.info_outline_rounded,
                      title: 'Version',
                      subtitle: 'Oremus $versionName _$versionCode',
                      trailing: null,
                    ),
                  ],
                ),
              ),
            ),

            // Espace en bas pour éviter que le dernier élément soit caché
            const SliverToBoxAdapter(
              child: SizedBox(height: 32),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildSectionHeader(
      BuildContext context, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorGreenSemiLight,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSetting(
      BuildContext context, SettingsController controller) {
    return _buildSettingTile(
      context,
      icon: Icons.notifications_active_outlined,
      title: 'Notifications',
      subtitle: 'Recevez des rappels et des intentions de prière',
      trailing: controller.isLoading.value
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(colorGreenSemiLight),
              ),
            )
          : FutureBuilder<bool>(
              future: NotificationConsentManager().hasUserConsented(),
              builder: (context, snapshot) {
                final hasConsented = snapshot.data ?? false;
                return Switch(
                  value: hasConsented,
                  activeColor: colorGreenSemiLight,
                  onChanged: (value) async {
                    controller.isLoading.value = true;
                    try {
                      if (value) {
                        await controller.doCheckAndRequestConsent();
                      } else {
                        await controller.doDisableNotifications();
                        showNotification(
                          message: 'Notifications désactivées avec succès',
                          bgColor: colorGreenSemiLight,
                        );
                      }
                    } finally {
                      controller.isLoading.value = false;
                    }
                    controller.update();
                  },
                );
              },
            ),
    );
  }

  Widget _buildSettingTile(
    BuildContext context, {
    IconData? icon,
    required String title,
    required String subtitle,
    required Widget? trailing,
    String? customIcon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: colorGreen1.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: customIcon?.isNotEmpty == true
                  ? SvgPicture.asset(
                      customIcon!,
                      width: 22,
                      height: 22,
                      color: colorGreenSemiLight,
                    )
                  : Icon(
                      icon,
                      color: colorGreenSemiLight,
                      size: 22,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }
}
