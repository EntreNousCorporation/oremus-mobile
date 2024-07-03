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

  final MassRequestData massRequest;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MassRequestHistoryController>(builder: (logic) {
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
                          massRequest.prayerIntent ?? '-',
                          textAlign: TextAlign.center,
                          style: TextStyles.montserratMedium(
                            textSize: TextSizes.fifteen,
                            textColor: colorBlack,
                          ),
                        ),
                        Separators.minimunVertical(),
                        Text(
                          massRequest.typeOfMassRequest?.name?.fr ?? '-',
                          textAlign: TextAlign.center,
                          style: TextStyles.montserratMedium(
                            textSize: TextSizes.thirteen,
                            textColor: colorBlue,
                          ),
                        ),
                        Separators.minimunVertical(),
                        Text(
                          getDateTime(massRequest.endDate ?? '-'),
                          textAlign: TextAlign.center,
                          style: TextStyles.montserratRegular(
                            textSize: TextSizes.ten,
                            textColor: colorGreySeparator,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    "${massRequest.price.toString().split('.').first.amountFormat()} FCFA",
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
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () {
                      logic.moveToMassRequestClaims(massRequest);
                    },
                    child: Container(
                      color: colorTransparent,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.real_estate_agent_rounded,
                            color: colorTurquois,
                          ),
                          Separators.customSizeVertical(3),
                          Text(
                            'Faire une \nréclamation',
                            textAlign: TextAlign.center,
                            style: TextStyles.montserratMedium(
                              textSize: TextSizes.twelve,
                              textColor: colorTurquois,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Separators.normalHorizontal(),
                  GestureDetector(
                    onTap: () {
                      logic.moveToMassRequest(massRequest);
                    },
                    child: Container(
                      color: colorTransparent,
                      child: Column(
                        children: [
                          const Icon(
                            Icons.history_rounded,
                            color: colorTurquois,
                          ),
                          Separators.customSizeVertical(3),
                          Text(
                            'Répéter\n',
                            textAlign: TextAlign.center,
                            style: TextStyles.montserratMedium(
                              textSize: TextSizes.twelve,
                              textColor: colorTurquois,
                            ),
                          ),
                        ],
                      ),
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
