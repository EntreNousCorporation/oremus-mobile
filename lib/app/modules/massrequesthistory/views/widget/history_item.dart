import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/mass_request_history_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class HistoryItem extends StatelessWidget {
  const HistoryItem({Key? key, required this.massRequest}) : super(key: key);

  final MassRequestResponse? massRequest;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MassRequestHistoryController>(builder: (logic) {
      return GestureDetector(
        onTap: () {
          logic.moveToHistoryDetail(massRequest);
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
              // Upper section with mass request details
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
                        Assets.imagesIconPray,
                        colorFilter: const ColorFilter.mode(colorGreenSemiLight, BlendMode.srcIn),
                      ),
                    ),
                    const SizedBox(width: 14),

                    // Mass request details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            massRequest?.typeOfMassRequest?.name?.fr ?? '-',
                            textAlign: TextAlign.start,
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.sixteen,
                              textColor: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "${massRequest?.prayerIntent}",
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.montserratMedium(
                              textSize: TextSizes.fourteen,
                              textColor: Colors.grey[700]!,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorGreenSemiLight.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              getCustomDate(massRequest?.updatedAt ?? ''),
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
                            color: getColor(massRequest?.status?.code),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          massRequest?.status?.name?.fr ?? '-',
                          style: TextStyles.montserratSemiBold(
                            textSize: TextSizes.fifteen,
                            textColor: getColor(massRequest?.status?.code),
                          ),
                        ),
                      ],
                    ),

                    // Retry payment button (if applicable)
                    Visibility(
                      visible: logic.canRedoPayment(massRequest),
                      child: GestureDetector(
                        onTap: () {
                          logic.doSendMassRequest(massRequest);
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