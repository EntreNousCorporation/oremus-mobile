import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<ParoisseController>(builder: (logic) {
      return Material(
        borderRadius: BorderRadius.circular(10.0),
        elevation: 10,
        color: colorWhite,
        shadowColor: colorGrey2.withValues(alpha: 0.5),
        child: TextFormField(
          controller: logic.searchController,
          keyboardAppearance: Brightness.light,
          style: TextStyles.montserratMedium(textColor: colorBlack),
          maxLines: 1,
          cursorColor: colorBlue,
          keyboardType: TextInputType.text,
          textInputAction: TextInputAction.search,
          onFieldSubmitted: (value) {
            logic.doLaunchSimpleSearch();
          },
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.only(top: 16, left: 16, right: 0, bottom: 0),
            filled: true,
            fillColor: colorWhite,
            border: InputBorder.none,
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: colorWhite),
              borderRadius: BorderRadius.circular(8),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: colorWhite),
              borderRadius: BorderRadius.circular(8),
            ),
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: 'Recherche par nom',
            hintStyle: TextStyles.montserratItalic(
                textColor: colorPurpleLight, textSize: TextSizes.fourteen),
            //prefixIcon: const Icon(Icons.search, color: colorPurpleLight,),
            suffixIcon: logic.isSearchFieldEmpty.isFalse
                ? FadeIn(
                    child: IconButton(
                      onPressed: () {
                        //clean search bar
                        logic.resetSearch();
                        logic.getParoisses();
                      },
                      icon: const Icon(Icons.cancel,
                          color: colorPurpleLight, size: 20),
                    ),
                  )
                : null,
          ),
          onChanged: (value) {
            logic.currentSimpleSearchValue.value = value;
            logic.isSearchFieldEmpty.value = value.isEmpty;
            if (value.isEmpty) {
              logic.getParoisses();
            }
          },
        ),
      );
    });
  }
}
