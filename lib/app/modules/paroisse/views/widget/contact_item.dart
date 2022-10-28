import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_contact_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/movement_response.dart';

class ContactItem extends StatelessWidget {
  ContactItem({Key? key, required this.contact}) : super(key: key);

  Contact contact;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParoisseContactController>(builder: (logic) {
      return InkWell(
        onTap: logic.code.value == 'IP' ? () {
          logic.launchUrl(contact.url ?? '');
        } : null,
        child: Ink(
          child: Padding(
            padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 24.0),
            child: Material(
              borderRadius: BorderRadius.circular(10.0),
              elevation: 10,
              shadowColor: colorGrey2.withOpacity(0.5),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: (contact.numbers?.isNotEmpty == true &&
                          contact.emails?.isNotEmpty == true)
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      logic.code.value == 'IP'
                          ? 'assets/images/icon_infos_paroissiales.svg'
                          : 'assets/images/contacts.svg',
                      height: 30,
                      color: colorGreenSemiLight,
                    ),
                    Separators.normalHorizontal(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            logic.getContactName(contact.name ?? ''),
                            style: TextStyles.montserratSemiBold(
                              textSize: TextSizes.sixteen,
                              textColor: colorGreenSemiLight,
                            ),
                          ),

                          //Telephone
                          Column(
                            children: contact.numbers?.map((e) {
                                  return InkWell(
                                    onTap: () {
                                      logic.launchPhone(e);
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(5.0),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.phone_android_rounded,
                                            color: colorBlack.withOpacity(0.5),
                                            size: 15,
                                          ),
                                          Separators.minimunHorizontal(),
                                          Text(
                                            contact.numbers?.first ?? '',
                                            style: TextStyles.montserratRegular(
                                              textSize: TextSizes.fourteen,
                                              textColor:
                                                  colorBlack.withOpacity(0.5),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }).toList() ??
                                [],
                          ),
                          Visibility(
                            visible: contact.emails?.isNotEmpty == true,
                            child: Separators.normalVertical(),
                          ),

                          //Emails
                          Column(
                            children: contact.emails?.map((e) {
                                  return InkWell(
                                    onTap: () {
                                      logic.launchEmail(e);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.email_rounded,
                                          color: colorBlack.withOpacity(0.5),
                                          size: 15,
                                        ),
                                        Separators.minimunHorizontal(),
                                        Text(
                                          contact.emails?.first ?? '',
                                          style: TextStyles.montserratRegular(
                                            textSize: TextSizes.fourteen,
                                            textColor: colorBlack.withOpacity(0.5),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList() ??
                                [],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}
