import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_activity_movement_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/activity_item.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/movement_item.dart';

class MovementScreen extends StatelessWidget {
  const MovementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ParoisseActivityMovementController>(builder: (logic) {
      if (logic.isMovementDataProcessing.isTrue) {
        return Expanded(
          child: Center(
            child: LottieLoadingView(
              size: Get.width / 4,
            ),
          ),
        );
      } else {
        if (logic.hasMovementData.isTrue) {
          return FadeIn(
            duration: const Duration(milliseconds: 500),
            child: ListView.builder(
                itemCount: logic.movements.length,
                itemBuilder: (context, index) {
                  var activity = logic.movements[index];
                  return MovementItem(movement: activity);
                }),
          );
        } else {
          return NotFoundScreen(
              message: 'Mouvements non disponible pour l\'instant');
        }
      }
    });
  }
}
