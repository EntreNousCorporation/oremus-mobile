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
import 'package:oremusapp/app/commons/formatters/upper_case_text_formatter.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/connexion/controller/connexion_controller.dart';

class ConnexionScreen extends StatefulWidget {
  const ConnexionScreen({Key? key}) : super(key: key);

  @override
  _ConnexionScreenState createState() => _ConnexionScreenState();
}

class _ConnexionScreenState extends State<ConnexionScreen> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;

    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: KeyboardDismisser(
        child: Scaffold(
            backgroundColor: colorWhite,
            resizeToAvoidBottomInset: true,
            body: SingleChildScrollView(
              child: SafeArea(
                child: GetX<ConnexionController>(
                  initState: (_) {},
                  builder: (_) {
                    return WillPopScope(
                      onWillPop: () async => _.unlockBackButton.value,
                      child: AbsorbPointer(
                        absorbing: _.lockScreen.value,
                        child: Container(
                          padding: const EdgeInsets.only(bottom: 20, left: 24, right: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Separators.maximumVertical(),
                              Separators.maximumVertical(),
                              Separators.maximumVertical(),
                              Text(
                                'Bienvenue',
                                style: TextStyles.avenirBold(
                                    textSize: TextSizes.thirty_two,
                                    textColor: colorBlack1),
                              ),
                              Container(
                                height: screensize.height / 8,
                              ),
                              Form(
                                key: _formKey,
                                child: Column(
                                  children: [
                                    MyTextField(
                                      controller: _.phoneController,
                                      hintText: 'Téléphone',
                                      labelText: '',
                                      prefixIcon: "assets/images/icon_user.svg",
                                      //suffixIcon: _.isValidEmail.isTrue ? const Icon(Icons.check_circle) : null,
                                      prefixIconColor: colorGrey1,
                                      keyboardType: TextInputType.number,
                                      maskInputs: [
                                        ObjectSeparatorInputFormatter(groupBy: 2),
                                        FilteringTextInputFormatter.allow(
                                            RegExp(AppConstants.INPUT_NUM_REGEX)),
                                      ],
                                      onChanged: (value) {
                                        _.checkForm();
                                      },
                                    ),
                                    Separators.maximumVertical(),
                                    MyTextField(
                                      controller: _.passwordController,
                                      hintText: 'Mot de passe',
                                      labelText: '',
                                      isPassword: true,
                                      prefixIcon: "assets/images/icon_passwd.svg",
                                      prefixIconColor: colorGrey1,
                                      onChanged: (value) {
                                        _.checkForm();
                                      },
                                    ),
                                    Separators.normalVertical(),
                                    Row(mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          'Mot de passe oublié ?',
                                          style: TextStyles.avenirDemiBold(
                                              textSize: TextSizes.sixteen,
                                              textColor: colorPurpleLight),
                                        ),
                                      ],
                                    ),
                                    Separators.normalVertical(),
                                    Separators.normalVertical(),
                                    SizedBox(
                                      width: Get.width/2,
                                      child: CustomButton(
                                        text: _.submitText.value,
                                        textSize: 17,
                                        bgcolor: _.isValidForm.isTrue ? colorBlueDark : colorBlue2,
                                        borderColor: _.isValidForm.isTrue ? colorBlueDark : colorBlue2,
                                        enabled: _.isValidForm.value,
                                        action: () {
                                          _.connectUser();
                                        },
                                      ),
                                    ),
                                    Separators.normalVertical(),
                                    Visibility(
                                      visible: false,
                                      child: Text(
                                        'Connectez-vous via',
                                        style: TextStyles.avenirDemiBold(
                                            textSize: TextSizes.sixteen,
                                            textColor: colorGrey1),
                                      ),
                                    ),
                                    Separators.normalVertical(),
                                    Visibility(
                                      visible: false,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(right: 12.0),
                                            child: SvgPicture.asset(
                                              'assets/images/google_logo.svg',
                                              height: 35,
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.only(left: 12.0),
                                            child: SvgPicture.asset(
                                              'assets/images/facebook_logo.svg',
                                              height: 35,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
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
            )),
      ),
    );
  }
}
