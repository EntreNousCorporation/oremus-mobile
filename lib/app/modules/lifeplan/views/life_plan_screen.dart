import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/lifeplan/controller/life_plan_controller.dart';
import 'package:oremusapp/app/modules/lifeplan/views/life_plan_item.dart';
import 'package:oremusapp/app/modules/lifeplan/views/user_life_plan_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class LifePlanScreen extends StatelessWidget {
  const LifePlanScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<LifePlanController>(
      builder: (controller) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            backgroundColor: Colors.grey[50],
            body: Column(
              children: [
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
                      Tab(text: 'Mes plans'),
                      Tab(text: 'Plans suggérés'),
                    ],
                    onTap: (index) {
                      controller.selectedTab.value = index;
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
                controller.goToCreateOrEditPlan();
              },
              backgroundColor: colorGreenSemiLight,
              child: const Icon(Icons.add, color: colorWhite),
            )
                : const SizedBox()),
          ),
        );
      },
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
          onEdit: () => controller.goToCreateOrEditPlan(userPlan: userPlan),
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
          onSelect: () => controller.goToCreateOrEditPlan(lifePlan: plan),
        );
      },
    );
  }
}
