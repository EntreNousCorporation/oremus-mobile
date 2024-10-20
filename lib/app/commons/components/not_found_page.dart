import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/generated/assets.dart';

class NotFoundScreen extends StatelessWidget {
  NotFoundScreen(
      {this.lottieIcon = Assets.imagesLottieEmptySearch,
      this.repeated = false,
      this.circled = true,
        this.doAction,
        this.buttonTitle,
        this.textSize,
        this.separatorWidget,
      required this.message,
      Key? key})
      : super(key: key);
  var lottieIcon;
  var repeated;
  var circled;
  var message = '';
  String? buttonTitle = '';
  Function? doAction;
  Widget? separatorWidget;
  double? textSize;

  @override
  Widget build(BuildContext context) {
    return FadeIn(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: circled
                ? BorderRadius.circular(
                    Get.width / 2,
                  )
                : const BorderRadius.all(Radius.elliptical(0, 0)),
            child: Container(
              color: colorWhite,
              child: Lottie.asset(lottieIcon,
                  repeat: repeated, width: Get.width / 2.5),
            ),
          ),
          Separators.normalVertical(),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: Get.width/10),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyles.montserratMedium(
                  textSize: TextSizes.eighteen, textColor: colorBlack),
            ),
          ),
          Visibility(
            visible: doAction != null,
            child: Column(
              children: [
                separatorWidget ?? Separators.normalVertical(),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: Get.width / 10),
                  child: CustomButton(
                    text: buttonTitle ?? 'Réessayer',
                    textSize: textSize ?? TextSizes.seventeen,
                    textColor: colorGreen,
                    borderColor: colorTransparent,
                    bgcolor: colorWhite,
                    textDecoration: TextDecoration.underline,
                    action: doAction?.call,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
