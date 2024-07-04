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

  final ClaimData claimData;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MassRequestTrackClaimController>(builder: (logic) {
      return Material(
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
                    child: SvgPicture.asset(Assets.imagesIconPray,
                        height: Get.width / 10,
                        colorFilter: const ColorFilter.mode(
                            colorGreen, BlendMode.srcIn)),
                  ),
                  Separators.minimunHorizontal(),
                  Separators.minimunHorizontal(),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          claimData.massRequest?.typeOfMassRequest?.name?.fr ??
                              '-',
                          textAlign: TextAlign.center,
                          style: TextStyles.montserratMedium(
                            textSize: TextSizes.fifteen,
                            textColor: colorBlue,
                          ),
                        ),
                        Separators.minimunVertical(),
                        Text(
                          getDateTime(claimData.createdAt ?? '-'),
                          textAlign: TextAlign.center,
                          style: TextStyles.montserratRegular(
                            textSize: TextSizes.thirteen,
                            textColor: colorGreySeparator,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${claimData.massRequest?.price.toString().split('.').first.amountFormat()} FCFA",
                    textAlign: TextAlign.center,
                    style: TextStyles.montserratBold(
                      textSize: TextSizes.fifteen,
                      textColor: colorBlack,
                    ),
                  ),
                ],
              ),
              const Divider(color: colorTurquois),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      claimData.typeOfClaim?.name?.fr ?? '-',
                      textAlign: TextAlign.start,
                      style: TextStyles.montserratMedium(
                        textSize: TextSizes.thirteen,
                        textColor: colorBlack,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.circle,
                    color: getColor(claimData.status?.code),
                    size: 12,
                  ),
                  Separators.customSizeHorizontal(3),
                  Text(
                    claimData.status?.name?.fr ?? '-',
                    textAlign: TextAlign.center,
                    style: TextStyles.montserratMedium(
                      textSize: TextSizes.thirteen,
                      textColor: getColor(claimData.status?.code),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
