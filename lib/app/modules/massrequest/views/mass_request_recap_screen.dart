import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_input_formatter/custom_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:like_button/like_button.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';
import 'package:oremusapp/app/modules/massrequest/controller/mass_request_controller.dart';
import 'package:oremusapp/app/modules/massrequest/controller/mass_request_recap_controller.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/custom_card.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/info_section.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/intent_type_description_widget.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/mass_hour_filter.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/mass_repetition_filter.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/mass_type_filter.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/payment_method_filter.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/shimmer_price.dart';
import 'package:oremusapp/generated/assets.dart';

class MassRequestRecapScreen extends StatelessWidget {
  const MassRequestRecapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MassRequestRecapController>(
      builder: (controller) {
        return KeyboardDismisser(
          child: PopScope(
            canPop: controller.unlockBackButton.value,
            child: Scaffold(
              resizeToAvoidBottomInset: true,
              backgroundColor: colorWhite,
              body: NotificationListener<OverscrollIndicatorNotification>(
                onNotification: (notification) {
                  notification.disallowIndicator();
                  return false;
                },
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    // En-tête extensible avec image de couverture
                    SliverAppBar(
                      expandedHeight: AppConstants.kExpandedHeight,
                      collapsedHeight: 100,
                      floating: false,
                      pinned: true,
                      backgroundColor: colorGreen,
                      elevation: 6,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                      ),
                      // Bouton retour
                      leading: Container(
                        margin: const EdgeInsets.only(left: 8, top: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Get.back();
                            Get.delete<FilterMassRequestDateController>(
                              force: true,
                            );
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: colorWhite,
                            size: 22,
                          ),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            controller.paroisseSelected.value.name ?? '-',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.eighteen,
                              textColor: colorWhite,
                            ),
                          ),
                        ),
                        background: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Image de couverture
                                (controller
                                            .paroisseSelected
                                            .value
                                            .coverImage
                                            ?.link
                                            ?.isNotEmpty ==
                                        true)
                                    ? CachedNetworkImage(
                                      imageUrl:
                                          controller
                                              .paroisseSelected
                                              .value
                                              .coverImage
                                              ?.link ??
                                          '',
                                      fit: BoxFit.cover,
                                      placeholder:
                                          (context, url) => LottieLoadingView(
                                            size: Get.width / 6,
                                          ),
                                      errorWidget:
                                          (context, url, error) => Image.asset(
                                            Assets.imagesBgLogin,
                                            width: Get.width,
                                            height: Get.width,
                                            fit: BoxFit.cover,
                                          ),
                                    )
                                    : Image.asset(
                                      Assets.imagesBgLogin,
                                      width: Get.width,
                                      height: Get.width,
                                      fit: BoxFit.cover,
                                    ),
                                // Superposition ombrée
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.7),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Formulaire de demande de messe
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate([
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Recapitulatif de la demande de messe',
                                style: TextStyles.montserratBold(
                                  textSize: TextSizes.sixteen,
                                  textColor: colorGreenSemiLight,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Carte d'informations
                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 15,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                // Section type de demande
                                InfoSection(
                                  label: 'Type de demande',
                                  value:
                                      controller
                                          .massRequestTypeSelected
                                          .value
                                          ?.name
                                          ?.fr ??
                                      '-',
                                  isFirst: false,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                ),

                                // Séparateur
                                _buildDivider(),

                                // Section date
                                controller.canShowSingleDate()
                                    ? Column(
                                      children: [
                                        InfoSection(
                                          label: 'Date',
                                          value: controller.showDate(),
                                          isFirst: false,
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 20,
                                            vertical: 5,
                                          ),
                                        ),
                                        // Séparateur
                                        _buildDivider(),
                                      ],
                                    )
                                    : const SizedBox.shrink(),

                                // Section Intention de priere
                                InfoSection(
                                  label: 'Intention de prière',
                                  value:
                                      controller.prayerIntentSelected.value ??
                                      '-',
                                  isFirst: true,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                ),

                                // Séparateur
                                _buildDivider(),

                                // Section montant
                                InfoSection(
                                  label: 'Montant',
                                  value:
                                      '${controller.price.value.toString().split('.').first.amountFormat()} FCFA',
                                  isFirst: false,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                ),

                                // Bouton afficher les horaires
                                !controller.canShowSingleDate()
                                    ? Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                        20,
                                        0,
                                        20,
                                        20,
                                      ),
                                      child: Column(
                                        children: [
                                          // Séparateur
                                          _buildDivider(),
                                          GestureDetector(
                                            onTap: () {
                                              //controller.showMassHours();
                                            },
                                            child: Container(
                                              width: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 14,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: colorGreen.withValues(
                                                  alpha: 0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: colorGreen.withValues(
                                                    alpha: 0.3,
                                                  ),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(
                                                    Icons.access_time_rounded,
                                                    color: colorGreen,
                                                    size: 20,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Afficher les horaires',
                                                    style:
                                                        TextStyles.montserratSemiBold(
                                                          textSize:
                                                              TextSizes
                                                                  .fourteen,
                                                          textColor: colorGreen,
                                                        ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),

                          CustomCard(content: const PaymentMethodFilter()),
                          const SizedBox(height: 24),
                          Material(
                            borderRadius: BorderRadius.circular(10.0),
                            elevation: 10,
                            color: colorWhite,
                            shadowColor: colorGrey2.withValues(alpha: 0.5),
                            child: TextFormField(
                              controller: controller.phoneNumberController,
                              keyboardAppearance: Brightness.light,
                              style: TextStyles.montserratMedium(
                                textColor: colorBlack,
                              ),
                              readOnly: !controller.useOtherNumber.value,
                              maxLines: 1,
                              cursorColor: colorBlue,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                CustomNumberInputFormatter(
                                  formatType: FormatType.phoneNumber,
                                  separator: ' ',
                                  groupBy: 2,
                                  maxLength: 10,
                                )
                              ],
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                  top: 16,
                                  left: 16,
                                  right: 0,
                                  bottom: 0,
                                ),
                                filled: true,
                                fillColor: colorWhite,
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: colorWhite,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: colorWhite,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                labelText: 'Numéro à débiter',
                                labelStyle: TextStyles.montserratRegular(
                                  textColor: colorBlack,
                                  textSize: TextSizes.sixteen,
                                ),
                              ),
                              onChanged: (value) {
                                controller.checkForm();
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Switch(
                                value: controller.useOtherNumber.value,
                                onChanged: (value) {
                                  controller.toggleUseOtherNumber();
                                },
                              ),
                              Text(
                                'Utiliser un autre numéro',
                                style: TextStyles.montserratSemiBold(
                                  textSize: TextSizes.fourteen,
                                  textColor: colorGreen,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 32),

                          // Bouton continuer
                          CustomButton(
                            text: 'Continuer',
                            borderRadius: 12,
                            textSize: TextSizes.sixteen,
                            bgcolor:
                                controller.isValidForm.isTrue
                                    ? colorGreen
                                    : colorGrey1.withValues(alpha: 0.5),
                            borderColor:
                                controller.isValidForm.isTrue
                                    ? colorGreen
                                    : colorGreen.withValues(alpha: 0),
                            actionColor: colorGreen.withValues(alpha: 0.5),
                            enabled: controller.isValidForm.value,
                            action: () {
                              controller.doSendMassRequest();
                            },
                          ),
                          const SizedBox(height: 16),
                        ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Divider(
        height: 1,
        thickness: 1,
        color: Colors.grey.withValues(alpha: 0.2),
      ),
    );
  }
}
