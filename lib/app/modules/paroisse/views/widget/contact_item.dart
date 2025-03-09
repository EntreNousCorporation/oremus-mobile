import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_contact_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/movement_response.dart';
import 'package:oremusapp/generated/assets.dart';

class ContactItem extends StatelessWidget {
  const ContactItem({Key? key, required this.contact}) : super(key: key);

  final Contact contact;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParoisseContactController>(builder: (logic) {
      return InkWell(
        onTap: logic.code.value == 'IP'
            ? () {
          doLaunchUrl(contact.url ?? '');
        }
            : null,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: (contact.numbers?.isNotEmpty == true &&
                  contact.emails?.isNotEmpty == true)
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                // Icône du contact
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: colorGreen.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      logic.code.value == 'IP'
                          ? Assets.imagesIconInfosParoissiales
                          : Assets.imagesContacts,
                      height: 24,
                      colorFilter: const ColorFilter.mode(colorGreenSemiLight, BlendMode.srcIn),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // Informations du contact
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom du contact
                      Text(
                        logic.getContactName(contact.name ?? ''),
                        style: TextStyles.montserratSemiBold(
                          textSize: TextSizes.sixteen,
                          textColor: colorGreenSemiLight,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Téléphones
                      if (contact.numbers != null && contact.numbers!.isNotEmpty)
                        ...contact.numbers!.map((phone) => _buildContactDetail(
                          icon: Icons.phone_android_rounded,
                          text: phone,
                          onTap: () => doLaunchPhone(phone),
                        )),

                      // Espacement entre téléphones et emails
                      if (contact.numbers?.isNotEmpty == true &&
                          contact.emails?.isNotEmpty == true)
                        const SizedBox(height: 8),

                      // Emails
                      if (contact.emails != null && contact.emails!.isNotEmpty)
                        ...contact.emails!.map((email) => _buildContactDetail(
                          icon: Icons.email_rounded,
                          text: email,
                          onTap: () => doLaunchEmail(email),
                        )),
                    ],
                  ),
                ),

                // Boutons d'action rapide
                if (logic.code.value == 'IP' && contact.url != null && contact.url!.isNotEmpty)
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colorGreen.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.open_in_new_rounded,
                        color: colorGreenSemiLight,
                        size: 20,
                      ),
                      onPressed: () {
                        doLaunchUrl(contact.url ?? '');
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  // Méthode pour construire un détail de contact (téléphone ou email)
  Widget _buildContactDetail({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Ink(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          decoration: BoxDecoration(
            color: colorGreen.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: colorGreenSemiLight,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: TextStyles.montserratMedium(
                    textSize: TextSizes.fourteen,
                    textColor: Colors.grey[800]!,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}