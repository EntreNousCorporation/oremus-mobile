import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/activity_response.dart';
import 'package:oremusapp/generated/assets.dart';

class ActivityItem extends StatelessWidget {
  const ActivityItem({Key? key, required this.activity}) : super(key: key);

  final ActivityResponse activity;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Card Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colorGreenSemiLight.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                // Activity Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(
                    color: colorGreenSemiLight,
                    shape: BoxShape.circle,
                  ),
                  child: SvgPicture.asset(
                    Assets.imagesGroup,
                    height: 16,
                    colorFilter: const ColorFilter.mode(colorWhite, BlendMode.srcIn),
                  ),
                ),
                const SizedBox(width: 12),

                // Activity Title
                Expanded(
                  child: Text(
                    activity.name ?? '-',
                    style: TextStyles.montserratSemiBold(
                      textSize: TextSizes.sixteen,
                      textColor: colorGreenSemiLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Card Content
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Description
                if (activity.description?.isNotEmpty == true)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.description,
                        size: 16,
                        color: colorGreenSemiLight.withValues(alpha: 0.7),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          activity.description ?? '',
                          style: TextStyles.montserratRegular(
                            textSize: TextSizes.fourteen,
                            textColor: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                // Organizer
                if (activity.organizer?.isNotEmpty == true)
                  Column(
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.person,
                            size: 16,
                            color: colorGreenSemiLight.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              activity.organizer ?? '',
                              style: TextStyles.montserratMediumItalic(
                                textSize: TextSizes.fifteen,
                                textColor: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}