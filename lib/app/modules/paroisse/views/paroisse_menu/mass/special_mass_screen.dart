import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:jiffy/jiffy.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_mass_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SpecialMassScreen extends StatelessWidget {
  const SpecialMassScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: GetX<ParoisseMassController>(builder: (logic) {
        if (logic.isSpecialMassDataProcessing.isTrue) {
          return Center(
            child: LottieLoadingView(
              size: Get.width / 4,
            ),
          );
        } else {
          if (logic.hasSpecialMassData.isTrue) {
            return FadeIn(
              child: SmartRefresher(
                controller: logic.refreshNotRecurrentController,
                onRefresh: logic.onSpecialMassesRefresh,
                header: const CustomClassicHeader(),
                child: ListView.builder(
                  itemCount: logic.specialMasses.length,
                  padding: const EdgeInsets.only(top: 16),
                  itemBuilder: (context, index) {
                    final value = logic.specialMasses[index];
                    final bool isExpired = isEventExpired(value);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // En-tête de la carte
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            decoration: BoxDecoration(
                              color: isExpired ? Colors.grey[200] : colorGreenSemiLight.withValues(alpha: 0.1),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Icône de la messe spéciale
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isExpired ? Colors.grey[400] : colorGreenSemiLight,
                                    shape: BoxShape.circle,
                                  ),
                                  child: SvgPicture.asset(
                                    'assets/images/messe.svg',
                                    height: 16,
                                    colorFilter: const ColorFilter.mode(colorWhite, BlendMode.srcIn),
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Titre de la messe spéciale
                                Expanded(
                                  child: Text(
                                    value.name ?? '-',
                                    style: TextStyles.montserratSemiBold(
                                      textSize: TextSizes.sixteen,
                                      textColor: isExpired ? Colors.grey[600]! : colorGreenSemiLight,
                                    ),
                                  ),
                                ),

                                // Badge "Passé" si l'événement est expiré
                                if (isExpired)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    child: Text(
                                      'Passé',
                                      style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.twelve,
                                        textColor: Colors.grey[700]!,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),

                          // Contenu de la carte
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: value.slots?.isNotEmpty == true
                                ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Date de la messe
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 16,
                                      color: isExpired ? Colors.grey[400] : colorGreenSemiLight.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      Jiffy.parse(value.startDate ?? '-').format(pattern: 'dd MMMM yyyy'),
                                      style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.fifteen,
                                        textColor: isExpired ? Colors.grey[500]! : Colors.black87,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),

                                // Horaires des messes
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.access_time,
                                      size: 16,
                                      color: isExpired ? Colors.grey[400] : colorGreenSemiLight.withValues(alpha: 0.7),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: value.slots?.map((timeSlot) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                            decoration: BoxDecoration(
                                              color: isExpired ? Colors.grey[100] : colorGreenSemiLight.withValues(alpha: 0.1),
                                              borderRadius: BorderRadius.circular(20),
                                              border: Border.all(
                                                color: isExpired ? Colors.grey[300]! : colorGreenSemiLight.withValues(alpha: 0.3),
                                              ),
                                            ),
                                            child: Text(
                                              '${logic.getTime(timeSlot.startTime ?? '')}',
                                              style: TextStyles.montserratSemiBold(
                                                textSize: TextSizes.fourteen,
                                                textColor: isExpired ? Colors.grey[500]! : colorGreenSemiLight,
                                              ),
                                            ),
                                          );
                                        }).toList() ?? [],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                                : _buildEmptyMassHours(),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          } else {
            return _buildEmptyState('Aucune messe spéciale n\'est programmée pour l\'instant');
          }
        }
      }),
    );
  }

  // Widget pour afficher un message quand les horaires ne sont pas disponibles
  Widget _buildEmptyMassHours() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.event_busy,
            size: 32,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 12),
          Text(
            'Horaires non disponibles pour l\'instant',
            style: TextStyles.montserratSemiBold(
              textSize: TextSizes.fourteen,
              textColor: Colors.grey[600]!,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // État vide amélioré
  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: colorGreen.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_busy,
              size: 40,
              color: colorGreen.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            message,
            style: TextStyles.montserratBold(
              textSize: TextSizes.eighteen,
              textColor: colorGreenSemiLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
