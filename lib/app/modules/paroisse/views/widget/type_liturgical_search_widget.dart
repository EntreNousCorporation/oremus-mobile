import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/filter/filter_paroisse_controller.dart';

class TypeLiturgicalSearchWidget extends StatelessWidget {
  const TypeLiturgicalSearchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<FilterParoisseController>(builder: (logic) {
      return TextFormField(
        controller: logic.typeLiturgicalSearchController,
        keyboardAppearance: Brightness.light,
        style: TextStyles.montserratMedium(
          textColor: colorBlack,
          textSize: TextSizes.fifteen,
        ),
        maxLines: 1,
        cursorColor: colorGreenSemiLight,
        keyboardType: TextInputType.text,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          contentPadding:
          const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          filled: true,
          fillColor: colorWhite,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: colorGreenSemiLight.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(16),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: colorGreyDrawer),
            borderRadius: BorderRadius.circular(16),
          ),
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: 'Rechercher un type de lieu...',
          hintStyle: TextStyles.montserratRegular(
            textColor: Colors.grey[500]!,
            textSize: TextSizes.fourteen,
          ),
          prefixIcon: const Padding(
            padding: EdgeInsets.only(left: 16, right: 8),
            child: Icon(
              Icons.search,
              color: colorGreenSemiLight,
              size: 22,
            ),
          ),
          suffixIcon: logic.isTypeLiturgicalSearchFieldEmpty.isFalse
              ? FadeIn(
            child: IconButton(
              onPressed: () {
                //clean search bar
                logic.resetTypeLiturgicalSearch();
              },
              icon: Icon(
                Icons.cancel_rounded,
                color: Colors.grey[400]!,
                size: 20,
              ),
            ),
          )
              : null,
        ),
        onChanged: (value) {
          logic.isTypeLiturgicalSearchFieldEmpty.value = value.isEmpty;
          logic.updateTypeLiturgicalFilter(value);
          if (value.isEmpty) {
            logic.resetTypeLiturgicalSearch();
          }
        },
      );
    });
  }
}
