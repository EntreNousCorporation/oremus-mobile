import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/text_field.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/editpassword/controller/edit_password_controller.dart';

class EditPasswordScreen extends StatelessWidget {
  const EditPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: KeyboardDismisser(
          child: Scaffold(
            backgroundColor: colorWhite,
            resizeToAvoidBottomInset: true,
            appBar: AppBar(
              leading: GestureDetector(
                onTap: () {
                  Get.back();
                },
                child: const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Icon(Icons.arrow_back_ios_rounded),
                ),
              ),
              title: Hero(
                tag: 'update-password',
                child: Text(
                  'Modifier votre mot de passe',
                  style: TextStyles.montserratBold(
                      textSize: TextSizes.sixteen,
                      textColor: colorWhite),
                ),
              ),
              centerTitle: true,
              backgroundColor: colorGreen,
            ),
            body: Center(
              child: SingleChildScrollView(
                reverse: false,
                child: SafeArea(
                  child: GetX<EditPasswordController>(
                    initState: (_) {},
                    builder: (_) {
                      return WillPopScope(
                        onWillPop: () async => _.unlockBackButton.value,
                        child: AbsorbPointer(
                          absorbing: _.lockScreen.value,
                          child: Container(
                            padding: const EdgeInsets.only(
                                bottom: 20, left: 32, right: 32),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              //mainAxisAlignment: MainAxisAlignment.center,
                              children: [
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
                                      key: _.formSigninKey,
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 32,
                                            right: 32,
                                            top: 32,
                                            bottom: 32),
                                        child: Column(
                                          children: [
                                            MyTextField(
                                              focusNode: _.passwordFocusNode,
                                              controller: _.passwordController,
                                              hintText: '',
                                              labelText: 'Ancien mot de passe',
                                              isPassword: true,
                                              prefixIcon:
                                                  "assets/images/icon_password_profil.svg",
                                              prefixIconColor: colorGrey1,
                                              textCapitalization:
                                                  TextCapitalization.none,
                                              onChanged: (value) {
                                                _.checkForm();
                                              },
                                              errorText:
                                                  _.passwordErrorMessage.value,
                                            ),
                                            Separators.maximumVertical(),
                                            MyTextField(
                                              focusNode: _.newPasswordFocusNode,
                                              controller:
                                                  _.newPasswordController,
                                              hintText: '',
                                              labelText: 'Nouveau mot de passe',
                                              isPassword: true,
                                              prefixIcon:
                                                  'assets/images/icon_password_profil.svg',
                                              prefixIconColor: colorGrey1,
                                              textCapitalization:
                                                  TextCapitalization.none,
                                              onChanged: (value) {
                                                _.checkForm();
                                              },
                                              errorText: _
                                                  .newPasswordErrorMessage
                                                  .value,
                                            ),
                                            Separators.maximumVertical(),
                                            MyTextField(
                                              focusNode:
                                                  _.confPasswordFocusNode,
                                              controller:
                                                  _.confPasswordController,
                                              hintText: '',
                                              labelText:
                                                  'Confirmer le mot de passe',
                                              isPassword: true,
                                              prefixIcon:
                                                  'assets/images/icon_password_profil.svg',
                                              prefixIconColor: colorGrey1,
                                              textCapitalization:
                                                  TextCapitalization.none,
                                              onChanged: (value) {
                                                _.checkForm();
                                              },
                                              errorText: _
                                                  .confPasswordErrorMessage
                                                  .value,
                                            ),
                                            Separators.maximumVertical(),
                                            Separators.maximumVertical(),
                                            SizedBox(
                                              height: 40,
                                              child: CustomButton(
                                                paddingVertical: 5,
                                                text: 'Modifier',
                                                icon:
                                                    'assets/images/icon_arrow_right.svg',
                                                bgcolor: _.isValidForm.isTrue
                                                    ? colorGreen
                                                    : colorGrey1
                                                        .withOpacity(0.5),
                                                borderColor: _
                                                        .isValidForm.isTrue
                                                    ? colorGreen
                                                    : colorGreen.withOpacity(0),
                                                actionColor:
                                                    colorGreen.withOpacity(0.5),
                                                enabled: _.isValidForm.value,
                                                action: () {
                                                  _.updatePassword();
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
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/*
* Separators.maximumVertical(),
                    MyTextField(
                      focusNode: _.passwordFocusNode,
                      controller: _.passwordController,
                      hintText: '',
                      labelText: 'Ancien mot de passe',
                      prefixIcon: "assets/images/icon_password_profil.svg",
                      //suffixIcon: _.isValidEmail.isTrue ? const Icon(Icons.check_circle) : null,
                      prefixIconColor: colorGrey1,
                      keyboardType: TextInputType.emailAddress,
                      textCapitalization: TextCapitalization.none,
                      onChanged: (value) {
                        _.checkForm();
                      },
                      errorText: _.passwordErrorMessage.value,
                    ),
                    Separators.normalVertical(),
                    MyTextField(
                      focusNode: _.newPasswordFocusNode,
                      controller: _.newPasswordController,
                      hintText: '',
                      labelText: 'Nouveau mot de passe',
                      isPassword: true,
                      prefixIcon: 'assets/images/icon_password_profil.svg',
                      prefixIconColor: colorGrey1,
                      textCapitalization: TextCapitalization.none,
                      onChanged: (value) {
                        _.checkForm();
                      },
                      errorText: _.newPasswordErrorMessage.value,
                    ),
                    Separators.maximumVertical(),
                    SizedBox(
                      width: Get.width / 3.5,
                      height: 40,
                      child: CustomButton(
                        paddingVertical: 5,
                        icon: 'assets/images/icon_arrow_right.svg',
                        bgcolor: _.isValidForm.isTrue
                            ? colorGreen
                            : colorGrey1.withOpacity(0.5),
                        borderColor: _.isValidForm.isTrue
                            ? colorGreen
                            : colorGreen.withOpacity(0),
                        actionColor: colorGreen.withOpacity(0.5),
                        enabled: _.isValidForm.value,
                        action: () {
                          //_.connectUser();
                        },
                      ),
                    ),
*
* */
