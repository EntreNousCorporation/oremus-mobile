import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Bientôt disponible',
        style: TextStyles.montserratRegular(
            textSize: TextSizes.twenty,
            textColor: colorBlack),
      ),
    );
  }
}
