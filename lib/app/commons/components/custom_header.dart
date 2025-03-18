import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CustomClassicHeader extends StatelessWidget {
  const CustomClassicHeader({Key? key, this.textColor, this.textSize}) : super(key: key);

  final Color? textColor;
  final double? textSize;

  @override
  Widget build(BuildContext context) {
    return ClassicHeader(
      textStyle: TextStyles.montserratRegular(
          textColor: textColor ?? colorGreyDrawer, textSize: textSize ?? 14),
      completeText: '',
      completeIcon: LottieLoadingView(
        file: 'assets/images/lottie-success-1.zip',
        size: Get.width / 10,
        color: textColor,
      ),
      completeDuration: const Duration(milliseconds: 2000),
      spacing: 8,
      refreshingText: '',
      refreshingIcon: LottieLoadingView(
        size: Get.width / 10,
      ),
      releaseText: 'Relâcher pour rafraîchir',
      releaseIcon: Icon(
        Icons.autorenew_rounded,
        color: textColor ?? colorGreyDrawer,
      ),
      idleText: 'Tirez vers le bas pour actualiser',
      idleIcon: Icon(
        Icons.arrow_downward_rounded,
        color: textColor ?? colorGreyDrawer,
      ),
    );
  }
}
