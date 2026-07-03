import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massreadings/controller/mass_readings_controller.dart';
import 'package:oremusapp/app/modules/massreadings/data/model/mass_readings.dart';

/// Ecran de consultation des lectures de la messe du jour.
/// Affiche par la coquille home (drawer "Textes de Messe").
class MassReadingsScreen extends StatelessWidget {
  const MassReadingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: SafeArea(
        bottom: false,
        child: GetX<MassReadingsController>(
          builder: (controller) {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(color: colorGreen),
              );
            }
            if (controller.hasError.value) {
              return _stateMessage(
                icon: Icons.wifi_off_rounded,
                message:
                    "Les lectures du jour ne sont pas disponibles pour le moment.",
                onRetry: controller.loadToday,
              );
            }
            final data = controller.massReadings.value;
            if (data == null || data.readings.isEmpty) {
              return _stateMessage(
                icon: Icons.menu_book_rounded,
                message: "Aucune lecture disponible pour aujourd'hui.",
                onRetry: controller.loadToday,
              );
            }
            return _content(data);
          },
        ),
      ),
    );
  }

  Widget _content(MassReadings data) {
    return Column(
      children: [
        _header(data),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            itemCount: data.readings.length,
            separatorBuilder: (_, __) => const SizedBox(height: 14),
            itemBuilder: (_, i) => _readingCard(data.readings[i]),
          ),
        ),
      ],
    );
  }

  Widget _header(MassReadings data) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: colorWhite,
        boxShadow: [
          BoxShadow(
            color: colorBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: _liturgicalColor(data.couleur).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.menu_book_rounded,
              color: _liturgicalColor(data.couleur),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  (data.fete?.isNotEmpty == true) ? data.fete! : 'Messe du jour',
                  style: TextStyles.montserratBold(
                    textSize: TextSizes.eighteen,
                    textColor: colorGreenSemiLight,
                  ),
                ),
                if (data.date?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    data.date!,
                    style: TextStyles.montserratRegular(
                      textSize: TextSizes.thirteen,
                      textColor: colorGrey1,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _readingCard(Reading reading) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorGrey2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (reading.titre?.isNotEmpty == true)
            Text(
              reading.titre!,
              style: TextStyles.montserratBold(
                textSize: TextSizes.fifteen,
                textColor: colorGreenSemiLight,
              ),
            ),
          if (reading.reference?.isNotEmpty == true) ...[
            const SizedBox(height: 2),
            Text(
              reading.reference!,
              style: TextStyles.montserratMedium(
                textSize: TextSizes.thirteen,
                textColor: colorGrey1,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Html(
            data: reading.contenu ?? '',
            style: {
              '#': Style(
                fontFamily: 'montserrat_regular',
                fontSize: FontSize(TextSizes.fifteen),
                margin: Margins.zero,
              ),
            },
          ),
        ],
      ),
    );
  }

  Widget _stateMessage({
    required IconData icon,
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colorGrey1),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyles.montserratRegular(
                textSize: TextSizes.fifteen,
                textColor: colorGrey1,
              ),
            ),
            const SizedBox(height: 20),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: colorGreen),
              label: Text(
                'Réessayer',
                style: TextStyles.montserratMedium(
                  textSize: TextSizes.fourteen,
                  textColor: colorGreen,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Mappe la couleur liturgique AELF vers une couleur d'accent.
  Color _liturgicalColor(String? couleur) {
    switch (couleur?.toLowerCase()) {
      case 'rouge':
        return colorRed;
      case 'blanc':
        return colorGrey1;
      case 'violet':
        return const Color(0xFF6A4C93);
      case 'rose':
        return const Color(0xFFD16BA5);
      case 'vert':
      default:
        return colorGreenSemiLight;
    }
  }
}
