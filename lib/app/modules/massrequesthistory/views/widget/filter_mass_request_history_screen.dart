import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/loader_widget.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/filter_mass_request_history_controller.dart';
import 'package:oremusapp/app/modules/massrequesthistory/views/widget/mass_request_type_search_widget.dart';
import 'package:oremusapp/app/modules/massrequesthistory/views/widget/type_data_item.dart';

class FilterMassRequestHistoryScreen extends StatelessWidget {
  const FilterMassRequestHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetX<FilterMassRequestHistoryController>(builder: (_) {
          return PopScope(
            canPop: false,
            child: KeyboardDismisser(
              child: Scaffold(
                backgroundColor: Colors.grey[50],
                appBar: AppBar(
                  backgroundColor: colorGreen,
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  title: Text(
                    'Filtrer les demandes',
                    style: TextStyles.montserratBold(
                      textSize: TextSizes.eighteen,
                      textColor: colorWhite,
                    ),
                  ),
                  actions: [
                    // Bouton d'annulation
                    Container(
                      margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: () {
                          _.doResetFilter();
                          _.goBackToMassRequestHistory();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: colorWhite,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
                body: Column(
                  children: [
                    // En-tête avec titre et bouton de réinitialisation
                    Container(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                      color: Colors.white,
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: colorGreenSemiLight.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.filter_list,
                              color: colorGreenSemiLight,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Options de filtre',
                                  style: TextStyles.montserratBold(
                                    textSize: TextSizes.seventeen,
                                    textColor: colorGreenSemiLight,
                                  ),
                                ),
                                Text(
                                  'Affinez votre recherche',
                                  style: TextStyles.montserratRegular(
                                    textSize: TextSizes.thirteen,
                                    textColor: Colors.grey[600]!,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          TextButton.icon(
                            onPressed: () {
                              _.doResetFilter();
                            },
                            icon: const Icon(
                              Icons.refresh,
                              color: colorGreenSemiLight,
                              size: 18,
                            ),
                            label: Text(
                              'Réinitialiser',
                              style: TextStyles.montserratMedium(
                                textSize: TextSizes.thirteen,
                                textColor: colorGreenSemiLight,
                              ),
                            ),
                            style: TextButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              backgroundColor: colorGreenSemiLight.withValues(alpha: 0.1),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Section de filtres
                    Expanded(
                      child: NotificationListener<OverscrollIndicatorNotification>(
                        onNotification: (notification) {
                          notification.disallowIndicator();
                          return false;
                        },
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Section de type de demande
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Type de demande',
                                      style: TextStyles.montserratSemiBold(
                                        textColor: colorGreenSemiLight,
                                        textSize: TextSizes.fifteen,
                                      ),
                                    ),
                                    const SizedBox(height: 12),

                                    // Barre de recherche
                                    const SizedBox(
                                      height: 48,
                                      child: MassRequestTypeSearchWidget(),
                                    ),
                                    const SizedBox(height: 16),

                                    // Liste horizontale des types sélectionnés
                                    _.isMassRequestDataProcessing.isTrue
                                        ? Center(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        child: LoadingView(
                                          size: Get.width / 20,
                                          color: colorGreenSemiLight,
                                        ),
                                      ),
                                    )
                                        : _.hasMassRequestData.isTrue && _.massRequestTypesTemp.isNotEmpty
                                        ? Container(
                                      padding: const EdgeInsets.symmetric(vertical: 8),
                                      height: 60,
                                      child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          physics: const BouncingScrollPhysics(),
                                          itemCount: _.massRequestTypesTemp.length,
                                          itemBuilder: (context, index) {
                                            var typeData = _.massRequestTypesTemp[index];
                                            return TypeDataItem(
                                              typeData: typeData,
                                              key: ValueKey(typeData.code),
                                            );
                                          }),
                                    )
                                        : Container(
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                      alignment: Alignment.center,
                                      child: Text(
                                        'Aucun type sélectionné',
                                        style: TextStyles.montserratRegular(
                                          textSize: TextSizes.fourteen,
                                          textColor: Colors.grey[500]!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Espace pour d'autres filtres futurs
                              const SizedBox(height: 20),

                              // Informations sur les filtres
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: colorGreenSemiLight.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorGreenSemiLight.withValues(alpha: 0.2),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.info_outline,
                                      color: colorGreenSemiLight,
                                      size: 24,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        "Les filtres vous permettent de trouver rapidement vos demandes de messe. Appliquez un ou plusieurs filtres selon vos besoins.",
                                        style: TextStyles.montserratRegular(
                                          textSize: TextSizes.thirteen,
                                          textColor: Colors.grey[700]!,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Bouton d'application des filtres
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 8,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: CustomButton(
                        text: 'Appliquer les filtres',
                        textSize: TextSizes.sixteen,
                        borderRadius: 12,
                        actionColor: colorGreenSemiLight.withValues(alpha: 0.8),
                        enabled: _.enabledApplyButton.value,
                        borderColor: _.enabledApplyButton.value
                            ? colorGreenSemiLight
                            : Colors.grey[300]!,
                        bgcolor: _.enabledApplyButton.value
                            ? colorGreenSemiLight
                            : Colors.grey[300]!,
                        textColor: colorWhite,
                        action: () {
                          _.goBackToMassRequestHistory();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
