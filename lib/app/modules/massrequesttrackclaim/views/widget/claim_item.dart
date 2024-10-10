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
        child: Material(
          borderRadius: BorderRadius.circular(10.0),
          elevation: 10,
          color: colorWhite,
          shadowColor: colorGrey2.withOpacity(0.5),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: colorGreen)),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: SvgPicture.asset(
                          Assets.imagesChecklist,
                          height: Get.width / 15,
                          colorFilter: const ColorFilter.mode(colorOrangeLight4, BlendMode.srcIn),
                        ),
                      ),
                    ),
                    Separators.minimunHorizontal(),
                    Separators.minimunHorizontal(),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            claimData?.typeOfClaim?.name?.fr ?? '-',
                            textAlign: TextAlign.start,
                            style: TextStyles.montserratMedium(
                              textSize: TextSizes.fifteen,
                              textColor: colorBlue,
                            ),
                          ),
                          Separators.minimunVertical(),
                          Text(
                            'Créée le ${getDateTime(claimData?.createdAt ?? ' - ')}',
                            textAlign: TextAlign.start,
                            style: TextStyles.montserratRegular(
                              textSize: TextSizes.thirteen,
                              textColor: colorGreySeparator,
                            ),
                          ),
                          Separators.minimunVertical(),
                          Text(
                            'Modifiée le ${getDateTime(claimData?.updatedAt ?? ' - ')}',
                            textAlign: TextAlign.start,
                            style: TextStyles.montserratRegular(
                              textSize: TextSizes.thirteen,
                              textColor: colorGreySeparator,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 15,
                      color: colorGrey1,
                    ),
                  ],
                ),
                const Divider(color: colorTurquois),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      claimData?.massRequest?.worshipPlace?.name ?? '-',
                      textAlign: TextAlign.center,
                      style: TextStyles.montserratSemiBold(
                        textSize: TextSizes.thirteen,
                        textColor: colorBlack,
                      ),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.circle,
                      color: getColor(claimData?.status?.code),
                      size: 12,
                    ),
                    Separators.customSizeHorizontal(3),
                    Text(
                      claimData?.status?.name?.fr ?? '-',
                      textAlign: TextAlign.center,
                      style: TextStyles.montserratMedium(
                        textSize: TextSizes.thirteen,
                        textColor: getColor(claimData?.status?.code),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
