import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/dotted_vertical_line.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/mass_request_history_controller.dart';

class MassRequestStateView extends StatelessWidget {
  const MassRequestStateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<MassRequestHistoryController>(
      builder: (logic) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
              ),
              child: Text(
                'État de la livraison',
                textAlign: TextAlign.center,
                style: TextStyles.montserratSemiBold(
                  textSize: TextSizes.sixteen,
                  textColor: colorBlack,
                ),
              ),
            ),
            Separators.minimunVertical(),
            Container(
              width: double.maxFinite,
              padding: EdgeInsets.all(
                  20),
              margin: EdgeInsets.only(
                left: 24,
                right: 24,
              ),
              decoration: BoxDecoration(
                color: colorWhite,
                borderRadius:
                BorderRadius.circular(
                    10),
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            8),
                        decoration: BoxDecoration(
                            //color: logic.readyColor.value,
                            color: colorBlack,
                            borderRadius:
                            BorderRadius.circular(100)),
                        child: SvgPicture.asset(
                          'Assets.imagesBoxTime',
                          height: 30,
                          colorFilter:
                          const ColorFilter
                              .mode(
                              colorWhite,
                              BlendMode
                                  .srcIn),
                        ),
                      ),
                      Separators.minimunHorizontal(),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            'Prêt',
                            textAlign: TextAlign
                                .center,
                            style: TextStyles
                                .montserratSemiBold(
                              textSize:
                              TextSizes
                                  .sixteen,
                              textColor:
                              colorBlack,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons
                                    .watch_later_rounded,
                                size:17,
                              ),
                              Separators.minimunHorizontal(),
                              Text(
                                //logic.getDeliveryReadyDate(),
                                '',
                                textAlign:
                                TextAlign
                                    .center,
                                style: TextStyles
                                    .montserratRegular(
                                  textSize:
                                  TextSizes
                                      .sixteen,
                                  textColor:
                                  colorBlack,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            //logic.readyTitle.value,
                            '',
                            textAlign:
                            TextAlign
                                .center,
                            style: TextStyles
                                .montserratSemiBold(
                              textSize:
                              TextSizes
                                  .sixteen,
                              textColor:
                              colorBlack,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Separators.minimunVertical(),
                  Container(
                    height: 50,
                    padding:
                    EdgeInsets.symmetric(
                        horizontal:
                        22,
                    ),
                    child: DottedVerticalline(
                      //color: logic.readyColor.value,
                      color: colorBlack,
                    ),
                  ),
                  Separators.minimunVertical(),

                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            8),
                        decoration: BoxDecoration(
                            //color: logic.readyColor.value,
                            color: colorBlack,
                            borderRadius:
                            BorderRadius.circular(100)),
                        child: SvgPicture.asset(
                          'Assets.imagesBoxTime',
                          height: 30,
                          colorFilter:
                          const ColorFilter
                              .mode(
                              colorWhite,
                              BlendMode
                                  .srcIn),
                        ),
                      ),
                      Separators.minimunHorizontal(),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            'Prêt',
                            textAlign: TextAlign
                                .center,
                            style: TextStyles
                                .montserratSemiBold(
                              textSize:
                              TextSizes
                                  .sixteen,
                              textColor:
                              colorBlack,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons
                                    .watch_later_rounded,
                                size: 17,
                              ),
                              Separators
                                  .minimunHorizontal(),
                              Text(
                                //logic.getDeliveryReadyDate(),
                                '',
                                textAlign:
                                TextAlign
                                    .center,
                                style: TextStyles
                                    .montserratRegular(
                                  textSize:
                                  TextSizes
                                      .sixteen,
                                  textColor:
                                  colorBlack,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            //logic.readyTitle.value,
                            '',
                            textAlign:
                            TextAlign
                                .center,
                            style: TextStyles
                                .montserratSemiBold(
                              textSize:
                              TextSizes
                                  .sixteen,
                              textColor:
                              colorBlack,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Separators.minimunVertical(),
                  Container(
                    height: 50,
                    padding:
                    EdgeInsets.symmetric(
                        horizontal:
                        22,
                    ),
                    child: DottedVerticalline(
                      //color: logic.readyColor.value,
                      color: colorBlack,
                    ),
                  ),
                  Separators.minimunVertical(),

                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            8),
                        decoration: BoxDecoration(
                          //color: logic.pickedColor.value,
                          color: colorBlack,
                          borderRadius: BorderRadius
                              .circular(
                              100),
                        ),
                        child: SvgPicture.asset(
                          'Assets.imagesTruckFast',
                          height: 30,
                          colorFilter:
                          const ColorFilter
                              .mode(
                              colorWhite,
                              BlendMode
                                  .srcIn),
                        ),
                      ),
                      Separators
                          .minimunHorizontal(),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            'Récupéré',
                            textAlign: TextAlign
                                .center,
                            style: TextStyles
                                .montserratSemiBold(
                              textSize:
                              TextSizes
                                  .sixteen,
                              //textColor: logic.pickedDisabledColor.value,
                              textColor: colorBlack,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons
                                    .watch_later_rounded,
                                size: 17,
                                //color: logic.pickedDisabledColor.value,
                                color: colorBlack,
                              ),
                              Separators
                                  .minimunHorizontal(),
                              Text(
                                //logic.pickedTitle.value,
                                '',
                                textAlign:
                                TextAlign
                                    .start,
                                style: TextStyles
                                    .montserratRegular(
                                  textSize:
                                  TextSizes
                                      .sixteen,
                                  //textColor: logic.pickedDisabledColor.value,
                                  textColor: colorBlack,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Separators.minimunVertical(),
                  Container(
                    height: 50,
                    padding:
                    EdgeInsets.symmetric(
                        horizontal:
                        22),
                    child: DottedVerticalline(
                      //color: logic.pickedColor.value,
                      color: colorBlack,
                    ),
                  ),
                  Separators.minimunVertical(),

                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(
                            8),
                        decoration: BoxDecoration(
                            //color: logic.deliveredColor.value,
                            color: colorBlack,
                            borderRadius:
                            BorderRadius.circular(
                                100)),
                        child: SvgPicture.asset(
                          'Assets.imagesTickSquare',
                          height: 30,
                          colorFilter:
                          const ColorFilter
                              .mode(colorWhite, BlendMode.srcIn,),
                        ),
                      ),
                      Separators
                          .minimunHorizontal(),
                      Column(
                        crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                        children: [
                          Text(
                            'Livré',
                            textAlign: TextAlign
                                .center,
                            style: TextStyles
                                .montserratBold(
                              textSize: TextSizes
                                  .sixteen,
                              //textColor: logic.deliveredDisabledColor.value,
                              textColor: colorBlack,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons
                                    .watch_later_rounded,
                                size: 17,
                                //color: logic.deliveredDisabledColor.value,
                                color: colorBlack,
                              ),
                              Separators
                                  .minimunHorizontal(),
                              Text(
                                //logic.deliveredTitle.value,
                                '',
                                textAlign:
                                TextAlign
                                    .center,
                                style: TextStyles
                                    .montserratBold(
                                  textSize: TextSizes
                                      .sixteen,
                                  //textColor: logic.deliveredDisabledColor.value,
                                  textColor: colorBlack,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
