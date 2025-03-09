import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/model/claim_response.dart';
import 'package:oremusapp/app/modules/massrequesttrackclaim/controller/mass_request_track_claim_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class ClaimItem extends StatelessWidget {
  const ClaimItem({Key? key, required this.claimData}) : super(key: key);

  final ClaimData? claimData;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MassRequestTrackClaimController>(builder: (logic) {
      return GestureDetector(
        onTap: () {
          logic.moveToTrackClaimDetails(claimData);
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
              // Upper section with claim details
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Icon container
                    Container(
                      width: 50,
                      height: 50,
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorGreenSemiLight.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: SvgPicture.asset(
                        Assets.imagesChecklist,
                        colorFilter: const ColorFilter.mode(colorOrangeLight4, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Claim details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            claimData?.typeOfClaim?.name?.fr ?? '-',
                            textAlign: TextAlign.start,
                            style: TextStyles.montserratSemiBold(
                              textSize: TextSizes.sixteen,
                              textColor: colorGreenSemiLight,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // Date information in a cleaner format
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_rounded,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Créée le ${getDateTime(claimData?.createdAt ?? ' - ')}',
                                style: TextStyles.montserratRegular(
                                  textSize: TextSizes.thirteen,
                                  textColor: Colors.grey[600]!,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              const Icon(
                                Icons.update_rounded,
                                size: 14,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Modifiée le ${getDateTime(claimData?.updatedAt ?? ' - ')}',
                                style: TextStyles.montserratRegular(
                                  textSize: TextSizes.thirteen,
                                  textColor: Colors.grey[600]!,
                                ),
                              ),
                            ],
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

              // Divider with lighter color
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Divider(
                  color: Colors.grey[200],
                  height: 1,
                ),
              ),

              // Bottom section with parish and status
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Parish name with icon
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.church_outlined,
                            color: colorGreenSemiLight,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              claimData?.massRequest?.worshipPlace?.name ?? '-',
                              style: TextStyles.montserratSemiBold(
                                textSize: TextSizes.fourteen,
                                textColor: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Status indicator with enhanced styling
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: getColor(claimData?.status?.code).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: getColor(claimData?.status?.code).withValues(alpha: 0.4),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: getColor(claimData?.status?.code),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            claimData?.status?.name?.fr ?? '-',
                            style: TextStyles.montserratMedium(
                              textSize: TextSizes.thirteen,
                              textColor: getColor(claimData?.status?.code),
                            ),
                          ),
                        ],
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
