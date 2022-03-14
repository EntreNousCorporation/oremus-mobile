import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8.0),
      elevation: 2,
      child: TextFormField(
        keyboardAppearance: Brightness.light,
        style: TextStyles.avenirMedium(
            textColor: colorBlack),
        maxLines: 1,
        cursorColor: colorBlue,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          contentPadding: const EdgeInsets.only(top: 16, left: 16, right: 0, bottom: 0),
          filled: true,
          fillColor: colorWhite,
          border: InputBorder.none,
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: colorWhite),
            borderRadius:
            BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(
                color: colorWhite),
            borderRadius:
            BorderRadius.circular(8),
          ),
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: 'Recherche',
          labelStyle: TextStyles.avenirMedium(),
          prefixIcon: null,
          suffixIcon: const Icon(Icons.search),
        ),
      ),
    );
  }
}
