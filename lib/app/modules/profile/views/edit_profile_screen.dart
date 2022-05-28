import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/text_field.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/formatters/object_separator_input_formatter.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/profile/controller/edit_profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetBuilder<EditProfileController>(
            initState: (state) {},
            builder: (_) {
              return KeyboardDismisser(
                child: Scaffold(
                  backgroundColor: colorGrey4,
                  resizeToAvoidBottomInset: true,
                  appBar: AppBar(
                    elevation: applyElevation(),
                    shadowColor: colorGrey2.withOpacity(0.8),
                    leading: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.arrow_back_ios_rounded),
                    ),
                    title: Text(
                      'Modifier votre profil',
                      style: TextStyles.montserratBold(
                          textSize: TextSizes.sixteen, textColor: colorWhite),
                    ),
                    centerTitle: true,
                    backgroundColor: colorGreen,
                  ),
                  body: Container(
                    color: colorGrey4,
                    width: double.infinity,
                    child: SingleChildScrollView(
                      child: FadeIn(
                        duration: const Duration(milliseconds: 500),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: Column(
                            children: [
                              Separators.maximumVertical(),
                              Separators.maximumVertical(),
                              Visibility(
                                visible: false,
                                child: Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Hero(
                                      tag: 'avatar',
                                      child: Material(
                                        borderRadius:
                                            BorderRadius.circular(110.0),
                                        elevation: 6,
                                        color: colorWhite,
                                        shadowColor:
                                            colorGrey2.withOpacity(0.5),
                                        child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(110),
                                          child: Container(
                                            color: colorGreenlight2,
                                            child: SizedBox(
                                              width: 110,
                                              height: 110,
                                              child: SvgPicture.asset(
                                                  'assets/images/avatar.svg'),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      right: 0,
                                      child: Material(
                                        borderRadius:
                                            BorderRadius.circular(90.0),
                                        elevation: 10,
                                        color: colorWhite,
                                        shadowColor:
                                            colorGrey2.withOpacity(0.5),
                                        child: const Icon(
                                          Icons.add_circle,
                                          color: colorPurpleLight,
                                          size: 35,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Visibility(
                                visible: false,
                                child: Separators.maximumVertical(),
                              ),
                              Visibility(
                                visible: false,
                                child: Separators.maximumVertical(),
                              ),
                              Material(
                                elevation: 6,
                                color: colorGrey2,
                                shadowColor: colorGrey2.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    color: colorWhite,
                                  ),
                                  child: Form(
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 32,
                                          right: 32,
                                          top: 32,
                                          bottom: 32),
                                      child: Column(
                                        children: [
                                          MyTextField(
                                            focusNode: _.lastnameFocusNode,
                                            controller: _.lastnameController,
                                            hintText: '',
                                            labelText: 'Nom',
                                            prefixIcon:
                                                "assets/images/icon_user.svg",
                                            prefixIconColor: colorGrey1,
                                            keyboardType: TextInputType.name,
                                            maskInputs: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(AppConstants
                                                      .INPUT_NAME_REGEX)),
                                            ],
                                            onChanged: (value) {
                                              _.checkForm();
                                            },
                                            errorText:
                                                _.lastnameErrorMessage.value,
                                          ),
                                          Separators.normalVertical(),
                                          MyTextField(
                                            focusNode: _.firstnameFocusNode,
                                            controller: _.firstnameController,
                                            hintText: '',
                                            labelText: 'Prénom(s)',
                                            prefixIcon:
                                                "assets/images/icon_user.svg",
                                            //suffixIcon: _.isValidEmail.isTrue ? const Icon(Icons.check_circle) : null,
                                            prefixIconColor: colorGrey1,
                                            keyboardType: TextInputType.name,
                                            maskInputs: [
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(AppConstants
                                                      .INPUT_NAME_REGEX)),
                                            ],
                                            onChanged: (value) {
                                              _.checkForm();
                                            },
                                            errorText:
                                                _.firstnameErrorMessage.value,
                                          ),
                                          Separators.normalVertical(),
                                          MyTextField(
                                            focusNode: _.phoneFocusNode,
                                            controller: _.phoneController,
                                            hintText: '',
                                            labelText: 'Téléphone',
                                            prefixIcon:
                                                "assets/images/icon_phone.svg",
                                            //suffixIcon: _.isValidEmail.isTrue ? const Icon(Icons.check_circle) : null,
                                            prefixIconColor: colorGrey1,
                                            keyboardType: TextInputType.phone,
                                            maxLength: 14,
                                            maskInputs: [
                                              ObjectSeparatorInputFormatter(
                                                  groupBy: 2),
                                              FilteringTextInputFormatter.allow(
                                                  RegExp(AppConstants
                                                      .INPUT_NUM_REGEX)),
                                            ],
                                            onChanged: (value) {
                                              _.checkForm();
                                            },
                                            errorText:
                                                _.phoneErrorMessage.value,
                                          ),
                                          Visibility(
                                            visible: false,
                                            child: Separators.normalVertical(),
                                          ),
                                          Visibility(
                                            visible: false,
                                            child: MyTextField(
                                              focusNode: _.emailFocusNode,
                                              controller: _.emailController,
                                              readOnly: true,
                                              hintText: '',
                                              labelText: 'E-mail',
                                              prefixIcon:
                                                  "assets/images/icon_enveloppe.svg",
                                              //suffixIcon: _.isValidEmail.isTrue ? const Icon(Icons.check_circle) : null,
                                              prefixIconColor: colorGrey1,
                                              keyboardType:
                                                  TextInputType.emailAddress,
                                              textCapitalization:
                                                  TextCapitalization.none,
                                              enabled: false,
                                              onChanged: (value) {
                                                _.checkForm();
                                              },
                                              errorText:
                                                  _.emailErrorMessage.value,
                                            ),
                                          ),
                                          Separators.maximumVertical(),
                                          Separators.maximumVertical(),
                                          SizedBox(
                                            width: Get.width,
                                            height: 40,
                                            child: CustomButton(
                                              paddingVertical: 5,
                                              icon:
                                                  'assets/images/icon_arrow_right.svg',
                                              text: 'Mettre à jour',
                                              bgcolor: _.isValidForm.isTrue
                                                  ? colorGreen
                                                  : colorGrey1.withOpacity(0.5),
                                              borderColor: _.isValidForm.isTrue
                                                  ? colorGreen
                                                  : colorGreen.withOpacity(0),
                                              actionColor:
                                                  colorGreen.withOpacity(0.5),
                                              enabled: _.isValidForm.value,
                                              action: () {
                                                _.updateProfile();
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
