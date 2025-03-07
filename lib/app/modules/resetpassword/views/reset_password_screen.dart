import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/text_field.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/resetpassword/controller/reset_password_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
          image: DecorationImage(
        image: AssetImage(Assets.imagesBgLogin),
        fit: BoxFit.cover,
      )),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
        child: FadeIn(
          child: KeyboardDismisser(
            child: Scaffold(
                backgroundColor: Colors.transparent,
                resizeToAvoidBottomInset: true,
                body: SafeArea(
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, left: 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Separators.maximumVertical(),
                            IconButton(
                              onPressed: () {
                                Get.back();
                              },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: colorWhite,
                                size: 30,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Center(
                          child: SingleChildScrollView(
                            reverse: false,
                            child: SafeArea(
                              child: GetX<ResetPasswordController>(
                                builder: (_) {
                                  return WillPopScope(
                                    onWillPop: () async =>
                                        _.unlockBackButton.value,
                                    child: AbsorbPointer(
                                      absorbing: _.lockScreen.value,
                                      child: Container(
                                        padding: const EdgeInsets.only(
                                            bottom: 20, left: 32, right: 32),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          //mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              "Réinitialiser votre mot de passe",
                                              style: TextStyles.montserratBold(
                                                  textSize:
                                                      TextSizes.twenty_four,
                                                  textColor: colorWhite),
                                            ),
                                            Separators.normalVertical(),
                                            Container(
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                                color: colorWhite,
                                              ),
                                              child: Form(
                                                key: _.formSigninKey,
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 32,
                                                          right: 32,
                                                          top: 32,
                                                          bottom: 32),
                                                  child: Column(
                                                    children: [
                                                      MyTextField(
                                                        focusNode: _
                                                            .newPasswordFocusNode,
                                                        controller: _
                                                            .newPasswordController,
                                                        hintText: '',
                                                        labelText:
                                                            'Nouveau mot de passe',
                                                        isPassword: true,
                                                        prefixIcon:
                                                            'assets/images/icon_password_profil.svg',
                                                        prefixIconColor:
                                                            colorGrey1,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .none,
                                                        onChanged: (value) {
                                                          _.checkForm();
                                                        },
                                                        errorText: _
                                                            .newPasswordErrorMessage
                                                            .value,
                                                      ),
                                                      Separators
                                                          .maximumVertical(),
                                                      MyTextField(
                                                        focusNode: _
                                                            .confPasswordFocusNode,
                                                        controller: _
                                                            .confPasswordController,
                                                        hintText: '',
                                                        labelText:
                                                            'Confirmer le mot de passe',
                                                        isPassword: true,
                                                        prefixIcon:
                                                            'assets/images/icon_password_profil.svg',
                                                        prefixIconColor:
                                                            colorGrey1,
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .none,
                                                        onChanged: (value) {
                                                          _.checkForm();
                                                        },
                                                        errorText: _
                                                            .confPasswordErrorMessage
                                                            .value,
                                                      ),
                                                      Separators
                                                          .maximumVertical(),
                                                      SizedBox(
                                                        width: Get.width / 3.5,
                                                        height: 40,
                                                        child: CustomButton(
                                                          paddingVertical: 5,
                                                          icon:
                                                              'assets/images/icon_arrow_right.svg',
                                                          bgcolor: _.isValidForm
                                                                  .isTrue
                                                              ? colorGreen
                                                              : colorGrey1
                                                                  .withValues(alpha: 
                                                                      0.5),
                                                          borderColor: _
                                                                  .isValidForm
                                                                  .isTrue
                                                              ? colorGreen
                                                              : colorGreen
                                                                  .withValues(alpha: 
                                                                      0),
                                                          actionColor:
                                                              colorGreen
                                                                  .withValues(alpha: 
                                                                      0.5),
                                                          enabled: _.isValidForm
                                                              .value,
                                                          action: () {
                                                            _.doResetPassword();
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
