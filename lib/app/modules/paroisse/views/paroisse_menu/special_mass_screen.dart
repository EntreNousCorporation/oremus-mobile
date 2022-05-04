import 'package:accordion/accordion.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_masse_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class SpecialMassScreen extends StatelessWidget {
  const SpecialMassScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ParoisseMasseController>(builder: (logic) {
      if (logic.isSpecialMassDataProcessing.isTrue) {
        return LottieLoadingView(
          size: Get.width / 4,
        );
      } else {
        if (logic.hasSpecialMassData.isTrue) {
          return FadeIn(
              duration: const Duration(milliseconds: 500),
              child: SmartRefresher(
                controller: logic.refreshNotRecurrentController,
                onRefresh: logic.onSpecialMassesRefresh,
                child: ListView.builder(
                  itemCount: logic.specialMasses.length,
                  itemBuilder: (context, index) {
                    var specialMass = logic.specialMasses[index];
                    return ListTile(
                      title: Text('${specialMass.name}'),
                      subtitle: Text('${specialMass.startDate}'),
                    );
                  },
                ),
              ));
        } else {
          return NotFoundScreen(
              message: 'Horaires non disponible pour l\'instant');
        }
      }
    });
  }
}
