import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';

class SearchWidget extends StatelessWidget {
  const SearchWidget({Key? key}) : super(key: key);

  // Méthode pour détecter si la saisie est une heure
  bool _isTimeFormat(String query) {
    if (query.trim().isEmpty) return false;
    RegExp timeRegex = RegExp(r'^([0-1]?[0-9]|2[0-3]):[0-5][0-9](:[0-5][0-9])?$');
    return timeRegex.hasMatch(query.trim());
  }

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
            // MISE À JOUR du hint text pour indiquer les deux possibilités
            hintText: 'Recherche par nom, adresse, diocèse, description OU heure (ex: 10:00)',
            hintStyle: TextStyles.montserratItalic(
                textColor: colorPurpleLight, textSize: TextSizes.fourteen),

            suffixIcon: logic.isSearchFieldEmpty.isFalse
                ? FadeIn(
              child: IconButton(
                onPressed: () {
                  // Utiliser clearSearch() au lieu de resetSearch()
                  logic.clearSearch();
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
                // Quand le champ devient vide, faire une recherche vide
                logic.currentSearchType.value = SearchType.simple;
                logic.isTimeFormatSearch.value = false;
                logic.scheduleQuery.value = '';
                logic.getParoisses(); // Recherche avec query vide
              } else {
                // Toute saisie utilise la recherche simple
                logic.currentSearchType.value = SearchType.simple;

                // Détecter si c'est un format d'heure pour l'affichage du bandeau
                if (_isTimeFormat(value)) {
                  logic.isTimeFormatSearch.value = true;
                } else {
                  logic.isTimeFormatSearch.value = false;
                }
              }
            },
        ),
      );
    });
  }
}
