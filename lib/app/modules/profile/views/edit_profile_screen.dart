import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/text_field.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/formatters/object_separator_input_formatter.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/profile/controller/edit_profile_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorGrey4,
      resizeToAvoidBottomInset: true,
      body: GetBuilder<EditProfileController>(
        builder: (_) {
          return KeyboardDismisser(
            child: Stack(
              children: [
                // Header gradient background
                Container(
                  height: 220,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: colorGreen,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(0),
                      bottomRight: Radius.circular(0),
                    ),
                  ),
                ),

                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // Custom app bar
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: colorWhite,
                                  size: 20,
                                ),
                                onPressed: () {
                                  Get.back();
                                },
                              ),
                            ),
                            Expanded(
                              child: Center(
                                child: Text(
                                  'Modifier votre profil',
                                  style: TextStyles.montserratBold(
                                    textColor: colorWhite,
                                    textSize: 20,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                                width:
                                    48), // Balancer l'espace pour le bouton de retour
                          ],
                        ),
                      ),

                      // Form content
                      Expanded(
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: FadeIn(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  const SizedBox(height: 20),

                                  // Avatar (actuellement masqué mais redesigné)
                                  Visibility(
                                    visible: false,
                                    child: _buildAvatarSection(),
                                  ),

                                  // Form card
                                  Container(
                                    margin: const EdgeInsets.only(
                                        top: 20, bottom: 30),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black
                                              .withValues(alpha: 0.05),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(24),
                                      child: Form(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Section title
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 4, bottom: 16),
                                              child: Text(
                                                'Informations personnelles',
                                                style:
                                                    TextStyles.montserratBold(
                                                  textSize: 16,
                                                  textColor:
                                                      colorGreenSemiLight,
                                                ),
                                              ),
                                            ),

                                            // Lastname field
                                            _buildStyledTextField(
                                              context: context,
                                              focusNode: _.lastnameFocusNode,
                                              controller: _.lastnameController,
                                              labelText: 'Nom',
                                              prefixIcon: Assets.imagesIconUser,
                                              //errorText: _.lastnameErrorMessage.value,
                                              onChanged: (value) =>
                                                  _.checkForm(),
                                              maskInputs: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(AppConstants
                                                        .INPUT_NAME_REGEX)),
                                              ],
                                            ),

                                            const SizedBox(height: 16),

                                            // Firstname field
                                            _buildStyledTextField(
                                              context: context,
                                              focusNode: _.firstnameFocusNode,
                                              controller: _.firstnameController,
                                              labelText: 'Prénom(s)',
                                              prefixIcon: Assets.imagesIconUser,
                                              errorText: _.firstnameErrorMessage.value,
                                              onChanged: (value) =>
                                                  _.checkForm(),
                                              textCapitalization:
                                                  TextCapitalization.words,
                                              maskInputs: [
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(AppConstants
                                                        .INPUT_NAME_REGEX)),
                                              ],
                                            ),

                                            const SizedBox(height: 16),

                                            // Phone field
                                            _buildStyledTextField(
                                              context: context,
                                              focusNode: _.phoneFocusNode,
                                              controller: _.phoneController,
                                              labelText: 'Téléphone',
                                              prefixIcon:
                                                  Assets.imagesIconPhone,
                                              errorText:
                                                  _.phoneErrorMessage.value,
                                              onChanged: (value) =>
                                                  _.checkForm(),
                                              keyboardType: TextInputType.phone,
                                              maxLength: 14,
                                              maskInputs: [
                                                ObjectSeparatorInputFormatter(
                                                    groupBy: 2),
                                                FilteringTextInputFormatter
                                                    .allow(RegExp(AppConstants
                                                        .INPUT_NUM_REGEX)),
                                              ],
                                            ),

                                            // Email field (hidden)
                                            Visibility(
                                              visible: false,
                                              child: Column(
                                                children: [
                                                  const SizedBox(height: 16),
                                                  _buildStyledTextField(
                                                    context: context,
                                                    focusNode: _.emailFocusNode,
                                                    controller:
                                                        _.emailController,
                                                    labelText: 'E-mail',
                                                    prefixIcon: Assets
                                                        .imagesIconEnveloppe,
                                                    errorText: _
                                                        .emailErrorMessage
                                                        .value,
                                                    onChanged: (value) =>
                                                        _.checkForm(),
                                                    keyboardType: TextInputType
                                                        .emailAddress,
                                                    textCapitalization:
                                                        TextCapitalization.none,
                                                    readOnly: true,
                                                    enabled: false,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),

                                  // Update button
                                  _buildUpdateButton(_),

                                  const SizedBox(height: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Hero(
              tag: 'avatar',
              child: Material(
                elevation: 8,
                shadowColor: Colors.black26,
                shape: const CircleBorder(),
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(60),
                    child: Container(
                      width: 120,
                      height: 120,
                      color: colorGreen1.withValues(alpha: 0.3),
                      child: SvgPicture.asset(Assets.imagesAvatar),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: colorGreen,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          'Modifier votre photo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: colorGreen,
          ),
        ),
      ],
    );
  }

  Widget _buildStyledTextField({
    required BuildContext context,
    required FocusNode focusNode,
    required TextEditingController controller,
    required String labelText,
    required String prefixIcon,
    String? errorText = '',
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? maskInputs,
    int? maxLength,
    bool readOnly = false,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorGrey4,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText?.isNotEmpty == true
                  ? Colors.red.shade300
                  : focusNode.hasFocus
                      ? colorGreenSemiLight.withValues(alpha: 0.5)
                      : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: MyTextField(
            focusNode: focusNode,
            controller: controller,
            hintText: '',
            labelText: labelText,
            prefixIcon: prefixIcon,
            prefixIconColor: colorGreenSemiLight,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            maskInputs: maskInputs,
            maxLength: maxLength,
            readOnly: readOnly,
            enabled: enabled,
            onChanged: onChanged,
            errorText: errorText,
          ),
        ),
        if (errorText?.isNotEmpty == true)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText ?? '',
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUpdateButton(EditProfileController controller) {
    return Container(
      width: double.infinity,
      height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: controller.isValidForm.value
            ? () => controller.updateProfile()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              controller.isValidForm.value ? colorGreen : Colors.grey.shade300,
          foregroundColor: Colors.white,
          elevation: controller.isValidForm.value ? 3 : 0,
          shadowColor: Colors.black26,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Mettre à jour',
              style: TextStyles.montserratBold(
                textSize: 16,
                textColor: controller.isValidForm.value
                    ? Colors.white
                    : Colors.grey.shade600,
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.check_circle_outline,
              color: controller.isValidForm.value
                  ? Colors.white
                  : Colors.grey.shade600,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
