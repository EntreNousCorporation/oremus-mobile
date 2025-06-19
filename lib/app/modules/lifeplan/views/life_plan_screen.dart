import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/image_displayer.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/life_plan_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/views/life_plan_item.dart';
import 'package:oremusapp/app/modules/lifeplan/views/user_life_plan_item.dart';
import 'package:oremusapp/app/modules/lifeplan/views/widgets/background_operations_indicator.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:oremusapp/main.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LifePlanScreen extends StatelessWidget {
  const LifePlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LifePlanController>(
      builder: (controller) {
        return Obx(() {
          // Vérifier si l'utilisateur est connecté
          if (!isUserConnected.value) {
            return _buildAuthenticationRequired(controller);
          }

          return DefaultTabController(
            length: 2,
            child: Scaffold(
              backgroundColor: Colors.grey[50],
              body: Column(
                children: [
                  BackgroundOperationsIndicator(controller: controller),
                  // Tab Bar
                  Container(
                    color: colorWhite,
                    child: TabBar(
                      indicatorColor: colorGreenSemiLight,
                      labelColor: colorGreenSemiLight,
                      unselectedLabelColor: Colors.grey,
                      labelStyle: TextStyles.montserratSemiBold(
                        textSize: TextSizes.fourteen,
                      ),
                      tabs: const [
                        Tab(text: 'Mon plan de vie'),
                        Tab(text: 'Activités suggérées'),
                      ],
                      onTap: (index) {
                        controller.selectedTab.value = index;
                        // Charger les données selon l'onglet sélectionné
                        if (index == 0) {
                          controller.checkAndLoadUserPlans();
                        } else {
                          controller.checkAndLoadAvailablePlans();
                        }
                      },
                    ),
                  ),

                  // Tab Views
                  Expanded(
                    child: SmartRefresher(
                      controller: controller.refreshController,
                      onRefresh: controller.onRefresh,
                      enablePullDown: true,
                      header: const WaterDropHeader(
                        waterDropColor: colorGreenSemiLight,
                      ),
                      child: TabBarView(
                        children: [
                          // Mes plans
                          _buildUserPlansTab(controller),
                          // Plans suggérés
                          _buildAvailablePlansTab(controller),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // FAB conditionnel basé sur l'onglet sélectionné
              floatingActionButton: Obx(() => controller.selectedTab.value == 0
                  ? FloatingActionButton(
                      onPressed: () {
                        //controller.testLongNotification(context);
                        controller.checkAndCreatePlan();
                      },
                      backgroundColor: colorGreenSemiLight,
                      child: const Icon(Icons.add, color: colorWhite),
                    )
                  : const SizedBox()),
            ),
          );
        });
      },
    );
  }

  // Widget affiché quand l'authentification est requise
  Widget _buildAuthenticationRequired(LifePlanController controller) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icône principale
            Container(
              width: 100,
              height: 100,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const ImageDisplayer(
                icon: Assets.imagesAssignment,
                color: colorGreen,
              ),
            ),

            const SizedBox(height: 32),

            // Titre principal
            Text(
              'Plan de vie',
              style: TextStyles.montserratBold(
                textSize: TextSizes.twenty_four,
                textColor: colorBlack,
              ),
            ),

            const SizedBox(height: 16),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Créez et gérez vos plans de vie personnalisés avec des rappels intelligents',
                textAlign: TextAlign.center,
                style: TextStyles.montserratMedium(
                  textSize: TextSizes.sixteen,
                  textColor: Colors.grey[600]!,
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Fonctionnalités
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  _buildFeatureItem(
                    icon: Icons.calendar_today_outlined,
                    title: 'Planning personnalisé',
                    description: 'Organisez vos activités selon votre rythme',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: Icons.notifications_outlined,
                    title: 'Rappels intelligents',
                    description: 'Synchronisation avec votre calendrier',
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(
                    icon: Icons.trending_up_outlined,
                    title: 'Suivi des progrès',
                    description: 'Historique de vos plans et activités',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 50),

            // Bouton de connexion
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    Future.delayed(const Duration(milliseconds: 250), () {
                      controller.moveToLogin('USER_PLANS');
                    });
                    //controller.checkIfUserIsConnected('USER_PLANS');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorGreen,
                    elevation: 2,
                    shadowColor: colorGreen.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    'Se connecter pour continuer',
                    style: TextStyles.montserratBold(
                      textSize: TextSizes.sixteen,
                      textColor: colorWhite,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  // Widget pour les éléments de fonctionnalités
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: colorGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: colorGreen,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyles.montserratSemiBold(
                  textSize: TextSizes.sixteen,
                  textColor: colorBlack,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyles.montserratRegular(
                  textSize: TextSizes.fourteen,
                  textColor: Colors.grey[600]!,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserPlansTab(LifePlanController controller) {
    if (controller.isLoadingUser.value) {
      return Center(
        child: LottieLoadingView(size: Get.width / 4),
      );
    }

    if (!controller.hasUserPlans.value) {
      return NotFoundScreen(
        message: "Vous n'avez pas encore de plan de vie",
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.userLifePlans.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final userPlan = controller.userLifePlans[index];
        return UserLifePlanItem(
          userLifePlan: userPlan,
          onEdit: () => controller.checkAndCreatePlan(userPlan: userPlan),
          onDelete: () => controller.deleteLifePlan(userPlan),
        );
      },
    );
  }

  Widget _buildAvailablePlansTab(LifePlanController controller) {
    if (controller.isLoadingAvailable.value) {
      return Center(
        child: LottieLoadingView(size: Get.width / 4),
      );
    }

    if (!controller.hasAvailablePlans.value) {
      return NotFoundScreen(
        message: "Aucun plan de vie disponible",
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: controller.availableLifePlans.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final plan = controller.availableLifePlans[index];
        return LifePlanItem(
          lifePlan: plan,
          onSelect: () => controller.checkAndCreatePlan(lifePlan: plan),
        );
      },
    );
  }
}
