import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/text_field.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/editpassword/controller/edit_password_controller.dart';

class EditPasswordScreen extends StatelessWidget {
  const EditPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorGrey4,
      resizeToAvoidBottomInset: true,
      body: GetX<EditPasswordController>(
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
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),

                // Main content
                SafeArea(
                  child: Column(
                    children: [
                      // Custom app bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
                            const Expanded(
                              child: Center(
                                child: Hero(
                                  tag: 'update-password',
                                  child: Material(
                                    color: Colors.transparent,
                                    child: Text(
                                      'Modifier votre mot de passe',
                                      style: TextStyle(
                                        color: colorWhite,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 48), // Pour équilibrer le bouton de retour
                          ],
                        ),
                      ),

                      // Form content
                      Expanded(
                        child: PopScope(
                          canPop: _.unlockBackButton.value,
                          child: AbsorbPointer(
                            absorbing: _.lockScreen.value,
                            child: SingleChildScrollView(
                              physics: const BouncingScrollPhysics(),
                              child: Padding(
                                padding: const EdgeInsets.all(20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Security icon
                                    Center(
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        margin: const EdgeInsets.only(top: 10, bottom: 30),
                                        decoration: BoxDecoration(
                                          color: colorGreen1.withValues(alpha: 0.3),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.lock_outline_rounded,
                                          size: 40,
                                          color: colorGreenSemiLight,
                                        ),
                                      ),
                                    ),

                                    // Password form card
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(alpha: 0.05),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(24),
                                        child: Form(
                                          key: _.formSigninKey,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Section title
                                              const Padding(
                                                padding: EdgeInsets.only(left: 4, bottom: 20),
                                                child: Text(
                                                  'Sécurité du compte',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: colorGreenSemiLight,
                                                  ),
                                                ),
                                              ),

                                              // Current password field
                                              _buildStyledTextField(
                                                context: context,
                                                focusNode: _.passwordFocusNode,
                                                controller: _.passwordController,
                                                labelText: 'Ancien mot de passe',
                                                prefixIcon: "assets/images/icon_password_profil.svg",
                                                errorText: _.passwordErrorMessage.value,
                                                onChanged: (value) => _.checkForm(),
                                                isPassword: true,
                                              ),

                                              const SizedBox(height: 20),

                                              // New password field
                                              _buildStyledTextField(
                                                context: context,
                                                focusNode: _.newPasswordFocusNode,
                                                controller: _.newPasswordController,
                                                labelText: 'Nouveau mot de passe',
                                                prefixIcon: "assets/images/icon_password_profil.svg",
                                                errorText: _.newPasswordErrorMessage.value,
                                                onChanged: (value) => _.checkForm(),
                                                isPassword: true,
                                              ),

                                              const SizedBox(height: 20),

                                              // Confirm password field
                                              _buildStyledTextField(
                                                context: context,
                                                focusNode: _.confPasswordFocusNode,
                                                controller: _.confPasswordController,
                                                labelText: 'Confirmer le mot de passe',
                                                prefixIcon: "assets/images/icon_password_profil.svg",
                                                errorText: _.confPasswordErrorMessage.value,
                                                onChanged: (value) => _.checkForm(),
                                                isPassword: true,
                                              ),

                                              // Password requirements hint
                                              Padding(
                                                padding: const EdgeInsets.only(top: 16, left: 4),
                                                child: Text(
                                                  'Le mot de passe doit contenir au moins 8 caractères, une lettre majuscule, une minuscule et un chiffre.',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey[600],
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(height: 30),

                                    // Update button
                                    _buildUpdateButton(_),
                                  ],
                                ),
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

  Widget _buildStyledTextField({
    required BuildContext context,
    required FocusNode focusNode,
    required TextEditingController controller,
    required String labelText,
    required String prefixIcon,
    required String errorText,
    required Function(String) onChanged,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: colorGrey4,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: errorText.isNotEmpty
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
            isPassword: isPassword,
            keyboardType: keyboardType,
            textCapitalization: textCapitalization,
            onChanged: onChanged,
            errorText: '',  // On gère l'affichage de l'erreur nous-mêmes
          ),
        ),
        if (errorText.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 4),
            child: Text(
              errorText,
              style: TextStyle(
                fontSize: 12,
                color: Colors.red.shade600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildUpdateButton(EditPasswordController controller) {
    return Container(
      width: double.infinity,
      height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: ElevatedButton(
        onPressed: controller.isValidForm.value
            ? () => controller.updatePassword()
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.isValidForm.value
              ? colorGreen
              : Colors.grey.shade300,
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
              'Modifier le mot de passe',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: controller.isValidForm.value
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
