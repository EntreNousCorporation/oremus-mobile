import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_presby_team_controller.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_user.dart';

class PresbyTeamItem extends StatelessWidget {
  const PresbyTeamItem({Key? key, required this.user}) : super(key: key);

  final PlaceUser user;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ParoissePresbyTeamController>(builder: (logic) {
      return Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.0),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                // Action au clic si nécessaire
              },
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Icône avec fond rond
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorGreenSemiLight.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: SvgPicture.asset(
                        'assets/images/priest_icon.svg',
                        height: 24,
                        colorFilter: const ColorFilter.mode(colorGreenSemiLight, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Informations textuelles
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Nom complet
                          Text(
                            '${user.firstname} ${user.lastname}',
                            style: TextStyles.montserratSemiBold(
                              textSize: TextSizes.sixteen,
                              textColor: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),

                          // Type/Rôle avec indicateur visuel
                          Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: colorGreenSemiLight,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  '${logic.getPresbyType(user.type ?? '')}',
                                  style: TextStyles.montserratRegular(
                                    textSize: TextSizes.fourteen,
                                    textColor: colorGreenSemiLight,
                                  ),
                                ),
                              ),
                            ],
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
