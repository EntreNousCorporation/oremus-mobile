import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_activity_movement_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/activity_item.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ParoisseActivityMovementController>(builder: (logic) {
      if (logic.isActivityDataProcessing.isTrue) {
        return Center(
          child: LottieLoadingView(
            size: Get.width / 4,
          ),
        );
      } else {
        if (logic.hasActivityData.isTrue) {
          return FadeIn(
            duration: const Duration(milliseconds: 500),
            child: ListView.builder(
                itemCount: logic.activities.length,
                itemBuilder: (context, index) {
                  var activity = logic.activities[index];
                  return ActivityItem(activity: activity);
                }),
          );
        } else {
          return NotFoundScreen(
              message: 'Activités non disponible pour l\'instant');
        }
      }
    });
  }
}
