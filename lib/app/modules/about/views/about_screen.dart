import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 32.0, left: 16.0, right: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(
              thickness: 0.2,
              color: colorGrey1,
            ),
            Separators.minimunVertical(),
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(200),
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                Separators.minimunHorizontal(),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Oremus',
                        style: TextStyles.montserratBold(
                            textSize: TextSizes.sixteen, textColor: colorBlack),
                      ),
                      Text(
                        'Au coeur de l\'information chrétienne',
                        style: TextStyles.montserratRegular(
                            textSize: TextSizes.fourteen, textColor: colorGrey1),
                      ),
                    ],
                  ),
                )
              ],
            ),
            Separators.minimunVertical(),
            const Divider(
              thickness: 0.2,
              color: colorGrey1,
            ),
            Separators.maximumVertical(),
            RichText(
              textAlign: TextAlign.justify,
              text: TextSpan(
                text: '"',
                style: TextStyles.montserratRegular(
                    textSize: TextSizes.fourteen, textColor: colorBlack),
                children: <TextSpan>[
                  TextSpan(
                      text: '85% ',
                      style: TextStyles.montserratSemiBold(
                          textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                  TextSpan(
                      text: 'de Chrétiens interrogés souhaitent un service PLUS pour faciliter l’accès aux services ecclésiastiques" \n\n',
                      style: TextStyles.montserratRegular(
                          textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                  TextSpan(
                      text: 'L’application ',
                      style: TextStyles.montserratRegular(
                          textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                  TextSpan(
                      text: 'Oremus ',
                      style: TextStyles.montserratSemiBold(
                          textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                  TextSpan(
                      text: 'est le fruit des réflexions et des actions d’un groupe de Chrétiens Catholiques visant la digitalisation et la simplification de l’accès aux services ecclésiastiques grâce à la technologie digitale.\n\n',
                      style: TextStyles.montserratRegular(
                          textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                  TextSpan(
                    text: '"Allez ! De toutes les nations faites des disciples" ',
                    style: TextStyles.montserratSemiBoldItalic(
                        textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                  TextSpan(
                    text: 'Matthieu 28:19\n\n',
                    style: TextStyles.montserratItalic(
                        textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                  TextSpan(
                    text: 'Le Seigneur envoie en mission les ',
                    style: TextStyles.montserratRegular(
                        textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                  TextSpan(
                    text: 'laïcs ',
                    style: TextStyles.montserratSemiBold(
                        textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                  TextSpan(
                    text: 'que nous sommes dans toutes les nations y compris dans le digital considéré comme un autre univers (métaverse).\n\n',
                    style: TextStyles.montserratRegular(
                        textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                  TextSpan(
                    text: 'Votre contribution est la bienvenue.\n\n',
                    style: TextStyles.montserratRegular(
                        textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                  TextSpan(
                    text: 'Vous pouvez nous contacter par mail ',
                    style: TextStyles.montserratRegular(
                        textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                  TextSpan(
                    text: 'oremus.civ@gmail.com \n\nte',
                    style: TextStyles.montserratRegular(
                        textSize: TextSizes.fourteen, textColor: colorBlue2),
                      recognizer: TapGestureRecognizer()..onTap = () async {
                        if (await canLaunch(Uri.encodeFull("mailto:oremus.civ@gmail.com?subject=Besoin d'information&body=")) == true) {
                          launch(Uri.encodeFull("mailto:oremus.civ@gmail.com?subject=Besoin d'information&body="));
                        } else {
                          log("Can't launch url");
                        }
                      }
                  ),
                  /*TextSpan(
                    text: 'ou sur whatsapp au ',
                    style: TextStyles.montserratRegular(
                        textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                  TextSpan(
                    text: '07 58 30 39 59\n\n',
                    style: TextStyles.montserratRegular(
                        textSize: TextSizes.fourteen, textColor: colorBlue2),
                    recognizer: TapGestureRecognizer()..onTap = () async {
                      if (await canLaunch("https://wa.me/2250758303959") == true) {
                        launch("https://wa.me/2250758303959");
                      } else {
                        log("Can't launch phone number");
                      }
                    }
                  ),*/
                  TextSpan(
                    text: 'Nous remercions tous nos bienfaiteurs, contributeurs et mentors pour leur apport sous toutes formes.',
                    style: TextStyles.montserratRegular(
                        textSize: TextSizes.fourteen, textColor: colorBlack),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
