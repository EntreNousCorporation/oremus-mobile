import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_input_formatter/custom_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/donation/controller/donation_recap_controller.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/info_section.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/payment_method_filter.dart';
import 'package:oremusapp/generated/assets.dart';

class DonationRecapScreen extends StatelessWidget {
  const DonationRecapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DonationRecapController>(
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
                                'Recapitulatif du Don',
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

                                // Section montant
                                InfoSection(
                                  label: 'Montant',
                                  value: controller.getAmount(),
                                  isFirst: false,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                ),

                                // Séparateur
                                _buildDivider(),

                                // Section Description
                                InfoSection(
                                  label: 'Description',
                                  value: controller.getDescription(),
                                  isFirst: true,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          PaymentMethodFilter(controller: controller),
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
                                onChanged: controller.enableUseOtherNumberSwitch.value ? (value) {
                                  controller.toggleUseOtherNumber();
                                } : null,
                              ),
                              Text(
                                'Utiliser un autre numéro',
                                style: TextStyles.montserratSemiBold(
                                  textSize: TextSizes.fourteen,
                                  textColor: controller.enableUseOtherNumberSwitch.value ? colorGreen: colorGreySeparator,
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
                              controller.doSendDonation();
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
