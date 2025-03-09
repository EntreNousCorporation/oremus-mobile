import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/donationhistory/controller/donation_history_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class DonationHistoryItem extends StatelessWidget {
  const DonationHistoryItem({Key? key, required this.donation}) : super(key: key);

  final DonationResponse? donation;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DonationHistoryController>(builder: (logic) {
      return GestureDetector(
        onTap: () {
          logic.moveToHistoryDetail(donation);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Column(
            children: [
              // Upper section with donation details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorGreenSemiLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SvgPicture.asset(
                          Assets.imagesVolunteer,
                          colorFilter: const ColorFilter.mode(colorGreenSemiLight, BlendMode.srcIn)
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Donation details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Don pour',
                            textAlign: TextAlign.start,
                            style: TextStyles.montserratMedium(
                              textSize: TextSizes.thirteen,
                              textColor: Colors.grey[600]!,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            donation?.isForOremus == false ? donation?.worshipPlace?.name ?? '-' : 'Oremus',
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.sixteen,
                              textColor: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorGreenSemiLight.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              getCustomDate(donation?.updatedAt ?? ''),
                              style: TextStyles.montserratMedium(
                                textSize: TextSizes.twelve,
                                textColor: colorGreenSemiLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Arrow indicator
                    Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              // Divider
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: Colors.grey[200],
                  height: 1,
                ),
              ),

              // Status and action section
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Status indicator
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: getColor(donation?.status?.code),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          donation?.status?.name?.fr ?? '-',
                          style: TextStyles.montserratSemiBold(
                            textSize: TextSizes.fifteen,
                            textColor: getColor(donation?.status?.code),
                          ),
                        ),
                      ],
                    ),

                    // Retry payment button (if applicable)
                    Visibility(
                      visible: logic.canRedoPayment(donation),
                      child: GestureDetector(
                        onTap: () {
                          logic.doSendDonation(donation);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: colorGreenSemiLight.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: colorGreenSemiLight.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.refresh_rounded,
                                color: colorGreenSemiLight,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Réessayer',
                                style: TextStyles.montserratSemiBold(
                                  textSize: TextSizes.thirteen,
                                  textColor: colorGreenSemiLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}