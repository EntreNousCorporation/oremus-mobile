import 'dart:developer';

import 'package:accordion/accordion.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: 16.0, left: 8.0, right: 8.0),
        child: Accordion(
          disableScrolling: true,
          maxOpenSections: 1,
          leftIcon: SvgPicture.asset('assets/images/logo.svg', height: 30,),
          headerBackgroundColor: colorGreenSemiLight,
          contentBorderColor: colorGreenSemiLight,
          children: [
            AccordionSection(
              isOpen: false,
              header: Text('Pourquoi choisir l’application Oremus ?', style: TextStyles.montserratSemiBold(
                  textSize: TextSizes.sixteen, textColor: colorWhite),),
              content: Text('L’application Oremus est un nouveau service PLUS permettant l’accès à un certain nombre de services ecclésiastiques à distance. Avec l’application Oremus vous trouvez en un seul endroit toutes les informations sur vos paroisses (horaires des messes, heures d’ouvertures des bureaux, contacts utiles, équipes presbytérales, etc) et bientôt vous pourrez accéder à d’autres services à distance.', style: TextStyles.montserratRegular(
                  textSize: TextSizes.fourteen, textColor: colorBlack),),
            ),
            AccordionSection(
              isOpen: false,
              header: Text('Comment utiliser l’application Oremus ?', style: TextStyles.montserratSemiBold(
                  textSize: TextSizes.sixteen, textColor: colorWhite),),
              content: Text('Pour utiliser l’application Oremus, il faut l’installer à partir de Play Store pour les utilisateurs Android ou à partir de Apple Store pour les utilisateurs d’iOS.', style: TextStyles.montserratRegular(
                  textSize: TextSizes.fourteen, textColor: colorBlack),),
            ),
            AccordionSection(
              isOpen: false,
              header: Text('Qui est l’auteur de l’application Orémus ?', style: TextStyles.montserratSemiBold(
                  textSize: TextSizes.sixteen, textColor: colorWhite),),
              content: Text('L’application Orémus a été pensée et créée par un groupe de professionnels chrétiens catholiques désireux de mettre à profit la puissance de la technologie digitale afin de faciliter, simplifier et amplifier l’accès aux services ecclésiastiques.', style: TextStyles.montserratRegular(
                  textSize: TextSizes.fourteen, textColor: colorBlack),),
            ),
            AccordionSection(
              isOpen: false,
              header: Text('Comment est financée l’application Orémus ?', style: TextStyles.montserratSemiBold(
                  textSize: TextSizes.sixteen, textColor: colorWhite),),
              content: Text("Le lancement de l’application Orémus a été financé par un groupe de professionnels chrétiens catholiques désireux de mettre à profit la puissance de la technologie digitale afin de faciliter, simplifier et amplifier l’accès aux services ecclésiastiques.\n\nPour la pérennité de l’application Oremus, un modèle adapté de financement de l’application sera mis en place de sorte que l’application puisse s’autofinancer et perdurer dans le temps", style: TextStyles.montserratRegular(
                  textSize: TextSizes.fourteen, textColor: colorBlack),),
            ),
            AccordionSection(
              isOpen: false,
              header: Text('Comment soutenir Orémus ?', style: TextStyles.montserratSemiBold(
                  textSize: TextSizes.sixteen, textColor: colorWhite),),
              content: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  text: "Vous pouvez faire partir des donateurs (donatrices) de l’application Orémus en nous faisant un don. Pour ce faire, vous pouvez nous contacter par mail ",
                  style: TextStyles.montserratRegular(
                      textSize: TextSizes.fourteen, textColor: colorBlack),
                  children: <TextSpan>[
                    TextSpan(
                        text: 'oremus.civ@gmail.com.',
                        style: TextStyles.montserratRegular(
                            textSize: TextSizes.fourteen, textColor: colorBlue2),
                        recognizer: TapGestureRecognizer()..onTap = () async {
                          if (await canLaunch(Uri.encodeFull("mailto:oremus.civ@gmail.com?subject=Dons&body=")) == true) {
                            launch(Uri.encodeFull("mailto:oremus.civ@gmail.com?subject=Dons&body="));
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
                        text: '0758303959\n\n',
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
                      text: '\n\nVous pouvez également encourager l’équipe en nous écrivant par mail ',
                      style: TextStyles.montserratRegular(
                          textSize: TextSizes.fourteen, textColor: colorBlack),
                    ),
                    TextSpan(
                        text: 'oremus.civ@gmail.com.',
                        style: TextStyles.montserratRegular(
                            textSize: TextSizes.fourteen, textColor: colorBlue2),
                        recognizer: TapGestureRecognizer()..onTap = () async {
                          if (await canLaunch(Uri.encodeFull("mailto:oremus.civ@gmail.com?subject=Encouragement&body=")) == true) {
                            launch(Uri.encodeFull("mailto:oremus.civ@gmail.com?subject=Encouragement&body="));
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
                        text: '0758303959\n\n',
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
                      text: '\n\nEnfin vous pouvez partager l’application à votre famille, vos amis et connaissances.',
                      style: TextStyles.montserratRegular(
                          textSize: TextSizes.fourteen, textColor: colorBlack),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
