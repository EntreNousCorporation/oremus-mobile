import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/about/controller/about_controller.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorGrey4,
      body: GetBuilder<AboutController>(
        assignId: true,
        builder: (logic) {
          return Stack(
            children: [
              // Header gradient background
              Container(
                height: Platform.isAndroid ? 200 : 220,
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
                                'À propos',
                                style: TextStyle(
                                  color: colorWhite,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 48), // Balance for the back button
                        ],
                      ),
                    ),

                    // Logo and app name area
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
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
                                  'OREMUS',
                                  style: TextStyles.montserratBold(
                                      textSize: 20,
                                      textColor: colorWhite
                                  ),
                                ),
                                Text(
                                  'Au cœur de l\'information chrétienne',
                                  style: TextStyles.montserratRegular(
                                      textSize: 14,
                                      textColor: colorWhite.withValues(alpha: 0.9)
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Content area
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Container(
                          margin: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              // Mission card
                              _buildContentCard(
                                icon: Icons.lightbulb_outline,
                                title: 'Notre mission',
                                content: _buildMissionContent(),
                              ),

                              const SizedBox(height: 16),

                              // Vision card
                              _buildContentCard(
                                icon: Icons.visibility_outlined,
                                title: 'Notre vision',
                                content: _buildVisionContent(),
                              ),

                              const SizedBox(height: 16),

                              // Contact card
                              _buildContentCard(
                                icon: Icons.mail_outline_rounded,
                                title: 'Contactez-nous',
                                content: _buildContactContent(context),
                              ),

                              const SizedBox(height: 24),

                              // Thank you note
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: colorGreen1.withValues(alpha: 0.5),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    const Icon(
                                      Icons.favorite_outline,
                                      color: colorGreenSemiLight,
                                      size: 24,
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Nous remercions tous nos bienfaiteurs, contributeurs et mentors pour leur apport sous toutes formes.',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratItalic(
                                        textSize: 14,
                                        textColor: Colors.grey[700]!,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Bouton "Soutenir Oremus"
                              ElevatedButton(
                                onPressed: () {
                                  logic.moveToDonation();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: colorGreenSemiLight,
                                  foregroundColor: colorWhite,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.favorite, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Soutenir Oremus',
                                      style: TextStyles.montserratBold(
                                        textSize: 14,
                                        textColor: colorWhite,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 20),
                            ],
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

  Widget _buildContentCard({
    required IconData icon,
    required String title,
    required Widget content,
  }) {
    return Container(
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorGreen1.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: colorGreenSemiLight,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyles.montserratBold(
                    textSize: 16,
                    textColor: colorGreenSemiLight,
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(
            height: 1,
            thickness: 1,
            color: colorGreen1.withValues(alpha: 0.2),
          ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(16),
            child: content,
          ),
        ],
      ),
    );
  }

  Widget _buildMissionContent() {
    return RichText(
      text: TextSpan(
        style: TextStyles.montserratRegular(
          textSize: 14,
          textColor: Colors.grey[800]!,
        ),
        children: const [
          TextSpan(
            text: '"',
          ),
          TextSpan(
            text: '85% ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: 'de Chrétiens interrogés souhaitent un service PLUS pour faciliter l\'accès aux services ecclésiastiques"\n\n',
          ),
          TextSpan(
            text: 'L\'application ',
          ),
          TextSpan(
            text: 'Oremus ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: 'est le fruit des réflexions et des actions d\'un groupe de Chrétiens Catholiques visant la digitalisation et la simplification de l\'accès aux services ecclésiastiques grâce à la technologie digitale.',
          ),
        ],
      ),
    );
  }

  Widget _buildVisionContent() {
    return RichText(
      text: TextSpan(
        style: TextStyles.montserratRegular(
          textSize: 14,
          textColor: Colors.grey[800]!,
        ),
        children: const [
          TextSpan(
            text: '"Allez ! De toutes les nations faites des disciples" ',
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: 'Matthieu 28:19\n\n',
            style: TextStyle(
              fontStyle: FontStyle.italic,
            ),
          ),
          TextSpan(
            text: 'Le Seigneur envoie en mission les ',
          ),
          TextSpan(
            text: 'laïcs ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: 'que nous sommes dans toutes les nations y compris dans le digital considéré comme un autre univers (métaverse).\n\n',
          ),
          TextSpan(
            text: 'Votre contribution est la bienvenue.',
          ),
        ],
      ),
    );
  }

  Widget _buildContactContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Vous pouvez nous contacter par mail :',
          style: TextStyles.montserratRegular(
            textSize: 14,
            textColor: Colors.grey[800]!,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            if (await canLaunchUrl(Uri(path: "mailto:oremus.civ@gmail.com?subject=Besoin d'information&body=")) ==
                true) {
              launchUrl(Uri(path: "mailto:oremus.civ@gmail.com?subject=Besoin d'information&body="));
            } else {
              log("Can't launch url");
            }
          },
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: colorGreen1.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: colorGreenSemiLight.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: const Row(
              children: [
                Icon(
                  Icons.email_outlined,
                  size: 20,
                  color: colorGreenSemiLight,
                ),
                SizedBox(width: 12),
                Text(
                  'oremus.civ@gmail.com',
                  style: TextStyle(
                    fontSize: 15,
                    color: colorGreenSemiLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
