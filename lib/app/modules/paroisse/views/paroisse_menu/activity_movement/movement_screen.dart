import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_activity_movement_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/movement_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class MovementScreen extends StatelessWidget {
  const MovementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorWhite,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
        child: Column(
          children: [
            // Contenu principal
            Expanded(
              child: GetX<ParoisseActivityMovementController>(
                builder: (logic) {
                  // Affichage de l'état de chargement
                  if (logic.isMovementDataProcessing.isTrue) {
                    return _buildLoadingState();
                  } else {
                    // Vérification s'il y a des données d'activités
                    if (logic.hasMovementData.isTrue) {
                      return _buildMovementList(logic);
                    } else {
                      // Écran affiché quand il n'y a pas d'activités
                      return _buildEmptyState(
                        'Aucun mouvement n\'est disponible pour l\'instant',
                      );
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Liste des mouvements
  Widget _buildMovementList(ParoisseActivityMovementController logic) {
    return SmartRefresher(
      controller: logic.refreshMovementsController,
      onRefresh: logic.onRefreshMouvements,
      header: const CustomClassicHeader(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: logic.movements.length,
        itemBuilder: (context, index) {
          var movement = logic.movements[index];
          return MovementItem(movement: movement);
        },
      ),
    );
  }

  // État de chargement
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LottieLoadingView(
            size: Get.width / 3,
          ),
          const SizedBox(height: 16),
          Text(
            'Chargement des mouvements...',
            style: TextStyles.montserratMedium(
              textSize: TextSizes.sixteen,
              textColor: colorGreenSemiLight.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  // État vide (quand aucun mouvement n'est disponible)
  Widget _buildEmptyState(String message) {
    return Center(
      child: FadeIn(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation ou illustration
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: colorGreen.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.group_off_rounded,
                  size: 56,
                  color: colorGreenSemiLight.withOpacity(0.7),
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
              const SizedBox(height: 16),

              // Message supplémentaire
              Text(
                'Revenez plus tard ou contactez l\'administrateur de la paroisse pour plus d\'informations.',
                style: TextStyles.montserratRegular(
                  textSize: TextSizes.fourteen,
                  textColor: colorBlack.withOpacity(0.6),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Bouton pour rafraîchir
              ElevatedButton(
                onPressed: () {
                  // Action de rafraîchissement
                  Get.find<ParoisseActivityMovementController>().onRefreshActivities();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorGreenSemiLight,
                  foregroundColor: colorWhite,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  'Rafraîchir',
                  style: TextStyles.montserratMedium(
                    textSize: TextSizes.sixteen,
                    textColor: colorWhite,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
