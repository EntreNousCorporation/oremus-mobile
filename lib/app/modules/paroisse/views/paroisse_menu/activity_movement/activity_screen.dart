import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_activity_movement_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/activity_item.dart';
import 'package:pull_to_refresh_simple/pull_to_refresh_simple.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: GetX<ParoisseActivityMovementController>(
        builder: (logic) {
          // Affichage de l'état de chargement
          if (logic.isActivityDataProcessing.isTrue) {
            return Center(
              child: LottieLoadingView(
                size: Get.width / 4,
              ),
            );
          } else {
            // Vérification s'il y a des données d'activités
            if (logic.hasActivityData.isTrue) {
              return FadeIn(
                preferences: const AnimationPreferences(
                  duration: Duration(milliseconds: 400),
                  offset: Duration(milliseconds: 100),
                ),
                child: SmartRefresher(
                  controller: logic.refreshActivitiesController,
                  onRefresh: logic.onRefreshActivities,
                  header: const CustomClassicHeader(),
                  child: ListView.builder(
                      padding: const EdgeInsets.only(top: 16),
                      itemCount: logic.activities.length,
                      itemBuilder: (context, index) {
                        var activity = logic.activities[index];
                        return ActivityItem(activity: activity);
                      }),
                ),
              );
            } else {
              // Écran affiché quand il n'y a pas d'activités
              return _buildEmptyState(
                'Aucune activité n\'est disponible pour l\'instant',
              );
            }
          }
        },
      ),
    );
  }

  // Widget pour l'état vide (quand aucune activité n'est disponible)
  Widget _buildEmptyState(String message) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Conteneur avec icône
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

          // Message d'état vide
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
