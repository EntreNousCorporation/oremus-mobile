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
                            massRequest?.typeOfMassRequest?.name?.fr ?? '-',
                            textAlign: TextAlign.start,
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.fifteen,
                              textColor: colorBlack,
                            ),
                          ),
                          Separators.minimunVertical(),
                          Text(
                            "${massRequest?.prayerIntent}",
                            textAlign: TextAlign.start,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyles.montserratMedium(
                              textSize: TextSizes.thirteen,
                              textColor: colorBlack,
                            ),
                          ),
                          Separators.minimunVertical(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                getCustomDate(massRequest?.updatedAt ?? ''),
                                textAlign: TextAlign.center,
                                style: TextStyles.montserratMedium(
                                  textSize: TextSizes.twelve,
                                  textColor: colorTurquois,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 15, color: colorGrey1,),
                  ],
                ),
                const Divider(color: colorTurquois),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.circle,
                          color: getColor(massRequest?.status?.code),
                          size: 15,
                        ),
                        Separators.customSizeHorizontal(3),
                        Text(
                          massRequest?.status?.name?.fr ?? '-',
                          textAlign: TextAlign.center,
                          style: TextStyles.montserratMedium(
                            textSize: TextSizes.fifteen,
                            textColor: getColor(massRequest?.status?.code),
                          ),
                        ),
                      ],
                    ),
                    Visibility(
                      visible: logic.canRedoPayment(massRequest),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          GestureDetector(
                            onTap: () {
                              logic.doSendMassRequest(massRequest);
                            },
                            child: Container(
                              color: colorTransparent,
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.money,
                                    color: colorGreen4,
                                  ),
                                  Separators.customSizeVertical(3),
                                  Text(
                                    'Réessayer\nle paiement',
                                    textAlign: TextAlign.center,
                                    style: TextStyles.montserratMedium(
                                      textSize: TextSizes.twelve,
                                      textColor: colorGreen4,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
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
