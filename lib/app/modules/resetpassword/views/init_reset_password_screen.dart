import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/text_field.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/resetpassword/controller/init_reset_password_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class InitResetPasswordScreen extends StatelessWidget {
  const InitResetPasswordScreen({Key? key}) : super(key: key);

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
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16.0),
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
                      ),
                      Expanded(
                        child: SingleChildScrollView(
                          padding: EdgeInsets.only(top: Get.height/7),
                          reverse: false,
                          child: SafeArea(
                            child: GetX<InitResetPasswordController>(
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
                                                      focusNode:
                                                          _.emailFocusNode,
                                                      controller:
                                                          _.emailController,
                                                      hintText: '',
                                                      labelText: 'E-mail',
                                                      prefixIcon:
                                                          "assets/images/icon_enveloppe.svg",
                                                      //suffixIcon: _.isValidEmail.isTrue ? const Icon(Icons.check_circle) : null,
                                                      prefixIconColor:
                                                          colorGrey1,
                                                      keyboardType:
                                                          TextInputType
                                                              .emailAddress,
                                                      textCapitalization:
                                                          TextCapitalization
                                                              .none,
                                                      onChanged: (value) {
                                                        _.checkForm();
                                                      },
                                                      errorText: _
                                                          .emailErrorMessage
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
                                                          _.doInitResetPassword();
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
                    ],
                  ),
                )),
          ),
        ),
      ),
    );
  }
}
