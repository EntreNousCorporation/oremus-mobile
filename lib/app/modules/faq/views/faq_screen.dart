import 'dart:developer';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/faq/controller/faq_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorGrey4,
      body: GetBuilder<FaqController>(
        builder: (controller) {
          return Stack(
            children: [
              // Header gradient background
              Container(
                height: 200,
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
                bottom: false,
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
                              child: Text(
                                'Foire aux questions',
                                style: TextStyle(
                                  color: colorWhite,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 8),
                      child: Text(
                        'Questions fréquentes de la communauté',
                        textAlign: TextAlign.center,
                        style: TextStyles.montserratRegular(
                          textColor: Colors.white.withValues(alpha: 0.9),
                          textSize: 14,
                        ),
                      ),
                    ),

                    // Introduction card
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: colorGreen1.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: SvgPicture.asset(
                                'assets/images/logo.svg',
                                height: 30,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Bienvenue dans la FAQ',
                                    style: TextStyles.montserratBold(
                                      textSize: 16,
                                      textColor: colorGreenSemiLight,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Trouvez des réponses à vos questions sur l\'application Oremus',
                                    style: TextStyles.montserratRegular(
                                      textSize: 14,
                                      textColor: Colors.grey[600]!,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // FAQ content area
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.only(top: 0),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: _buildFaqContent(context),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFaqContent(BuildContext context) {
    return Column(
      children: [
        // FAQ items
        _buildFaqItem(
          context: context,
          question: 'Pourquoi choisir l\'application Oremus ?',
          answer:
              'L\'application Oremus est un nouveau service PLUS permettant l\'accès à un certain nombre de services ecclésiastiques à distance. Avec l\'application Oremus vous trouvez en un seul endroit toutes les informations sur vos paroisses (horaires des messes, heures d\'ouvertures des bureaux, contacts utiles, équipes presbytérales, etc) et bientôt vous pourrez accéder à d\'autres services à distance.',
          isFirst: true,
        ),

        _buildFaqItem(
          context: context,
          question: 'Comment utiliser l\'application Oremus ?',
          answer:
              'Pour utiliser l\'application Oremus, il faut l\'installer à partir de Play Store pour les utilisateurs Android ou à partir de Apple Store pour les utilisateurs d\'iOS.',
        ),

        _buildFaqItem(
          context: context,
          question: 'Qui est l\'auteur de l\'application Orémus ?',
          answer:
              'L\'application Orémus a été pensée et créée par un groupe de professionnels chrétiens catholiques désireux de mettre à profit la puissance de la technologie digitale afin de faciliter, simplifier et amplifier l\'accès aux services ecclésiastiques.',
        ),

        _buildFaqItem(
          context: context,
          question: 'Comment est financée l\'application Orémus ?',
          answer:
              "Le lancement de l'application Orémus a été financé par un groupe de professionnels chrétiens catholiques désireux de mettre à profit la puissance de la technologie digitale afin de faciliter, simplifier et amplifier l'accès aux services ecclésiastiques.\n\nPour la pérennité de l'application Oremus, un modèle adapté de financement de l'application sera mis en place de sorte que l'application puisse s'autofinancer et perdurer dans le temps",
        ),

        _buildFaqItem(
          context: context,
          question: 'Comment soutenir Orémus ?',
          answer: '',
          hasRichText: true,
          richTextWidget: _buildSupportRichText(context),
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildFaqItem({
    required BuildContext context,
    required String question,
    required String answer,
    bool hasRichText = false,
    Widget? richTextWidget,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: Container(
        margin: EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: isLast ? 20 : 12,
          top: isFirst ? 0 : 0,
        ),
        padding: EdgeInsets.only(
          left: 8,
          right: 8,
          bottom: isLast ? 20 : 12,
          top: isFirst ? 0 : 0,
        ),
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          expandedAlignment: Alignment.topLeft,
          iconColor: colorGreenSemiLight,
          collapsedIconColor: Colors.grey,
          backgroundColor: Colors.white,
          collapsedBackgroundColor: Colors.white,
          enableFeedback: true,
          title: Text(
            question,
            style: TextStyles.montserratMedium(
              textSize: 15,
              textColor: colorGreenSemiLight,
            ),
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorGreen1.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.question_answer_outlined,
              color: colorGreenSemiLight,
              size: 18,
            ),
          ),
          children: [
            hasRichText
                ? richTextWidget!
                : Text(
                    answer,
                    style: TextStyles.montserratRegular(
                      textSize: 14,
                      textColor: Colors.grey[800]!,
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportRichText(BuildContext context) {
    return RichText(
      textAlign: TextAlign.start,
      text: TextSpan(
        text:
            "Vous pouvez faire partir des donateurs (donatrices) de l'application Orémus en nous faisant un don. Pour ce faire, vous pouvez nous contacter par mail ",
        style: TextStyles.montserratRegular(
          textSize: 14,
          textColor: Colors.grey[800]!,
        ),
        children: <TextSpan>[
          TextSpan(
              text: 'oremus.civ@gmail.com.',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorGreen,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final String email = Uri.encodeFull(
                      "mailto:oremus.civ@gmail.com?subject=Dons&body=");
                  if (await canLaunch(email)) {
                    launch(email);
                  } else {
                    log("Can't launch url");
                  }
                }),
          TextSpan(
            text:
                '\n\nVous pouvez également encourager l\'équipe en nous écrivant par mail ',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
          TextSpan(
              text: 'oremus.civ@gmail.com.',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: colorGreen,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  final String email = Uri.encodeFull(
                      "mailto:oremus.civ@gmail.com?subject=Encouragement&body=");
                  if (await canLaunch(email)) {
                    launch(email);
                  } else {
                    log("Can't launch url");
                  }
                }),
          TextSpan(
            text:
                '\n\nEnfin vous pouvez partager l\'application à votre famille, vos amis et connaissances.',
            style: TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }
}
