
import 'package:accordion/accordion.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu_detail_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/day_item.dart';

class ParoisseMenuDetailScreen extends StatelessWidget {
  const ParoisseMenuDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: GetBuilder<ParoisseMenuDetailController>(
          initState: (state) {},
          builder: (_) {
            return KeyboardDismisser(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: CustomScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  slivers: [
                    SliverAppBar(
                      expandedHeight: Get.width / 1.7,
                      floating: false,
                      pinned: true,
                      backgroundColor: colorGreen,
                      elevation: 10,
                      shadowColor: colorGrey2.withOpacity(0.8),
                      leading: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                      ),
                      actions: [
                        IconButton(
                          onPressed: () {
                            _.goToMap();
                          },
                          icon: const Icon(Icons.map_rounded),
                        ),
                      ],
                      flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          title: Padding(
                            padding:
                            const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              '${_.paroisseSelected.value.name}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyles.montserratBold(
                                  textSize: TextSizes.eighteen,
                                  textColor: colorWhite),
                            ),
                          ),
                          background: (_.paroisseSelected.value.coverImage?.link
                              ?.isNotEmpty ==
                              true)
                              ? Stack(
                            children: [
                              Hero(
                                tag: 'tag${_.indexDaySelected.value}',
                                child: CachedNetworkImage(
                                  width: Get.width,
                                  height: Get.width,
                                  imageUrl: _.paroisseSelected.value
                                      .coverImage?.link ??
                                      '',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      LottieLoadingView(
                                          size: Get.width / 6),
                                  errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                                ),
                              ),
                              Container(
                                height: Get.width,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black54.withOpacity(0.3),
                                ),
                              ),
                            ],
                          )
                              : Stack(
                            children: [
                              Hero(
                                tag: 'tag${_.indexDaySelected.value}',
                                child: Image.asset(
                                  'assets/images/bg_login.jpg',
                                  width: Get.width,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                height: Get.width,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: Colors.black54.withOpacity(0.3),
                                ),
                              ),
                            ],
                          )),
                    ),
                    const SliverPadding(
                        padding: EdgeInsets.symmetric(vertical: 8)),
                    SliverFillRemaining(
                      child: Column(
                        children: [
                          Hero(
                            tag: _.code.value,
                            child: Text(
                              _.getTypeTitle(_.code.value),
                              textAlign: TextAlign.center,
                              style: TextStyles.montserratBold(
                                textSize: TextSizes.eighteen,
                                textColor: colorGreenSemiLight,
                              ),
                            ),
                          ),
                          _.liturgicalCelebrations.value.isNotEmpty ? Expanded(
                            child: Accordion(
                              disableScrolling: false,
                              maxOpenSections: 1,
                              leftIcon: SvgPicture.asset(_.code.value == 'HM' ? 'assets/images/messe.svg' : 'assets/images/confession_icon.svg', height: 25, color: colorWhite,),
                              headerBackgroundColor: colorGreenSemiLight,
                              contentBorderColor: colorGreenSemiLight,
                              children:
                              _.liturgicalCelebrations.value.map((value) {
                                return AccordionSection(
                                  isOpen: false,
                                  header: Text(
                                    '${value.name}',
                                    style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.sixteen,
                                        textColor: colorWhite),
                                  ),
                                  content: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: Get.width / 10,
                                        width: Get.width,
                                        child: ListView.builder(
                                            itemCount:
                                            value.openingTime?.length,
                                            shrinkWrap: true,
                                            scrollDirection: Axis.horizontal,
                                            itemBuilder: (context, index) {
                                              var openingTime =
                                              value.openingTime?[index];
                                              return DayItem(
                                                  openingTime: openingTime);
                                            }),
                                      ),
                                      Separators.minimunVertical(),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: Get.width/4),
                                        child: Divider(color: colorBrown.withOpacity(0.5)),
                                      ),
                                      GetX<ParoisseMenuDetailController>(
                                        builder: (logic) {
                                          return Column(
                                            children: _.openingTime.value.slots?.map((timeSlot) {
                                              return Row(
                                                children: [
                                                  Visibility(
                                                    visible: false,
                                                    child: Container(
                                                      height: 25,
                                                      width: 5,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(10),
                                                        color: colorBrown,
                                                      ),
                                                    ),
                                                  ),
                                                  const Icon(Icons.access_time, size: 25,),
                                                  Padding(
                                                    padding:
                                                    const EdgeInsets.all(8.0),
                                                    child: Text(
                                                      '${_.getTime(timeSlot.startTime ?? '')}',
                                                      style: TextStyles
                                                          .montserratSemiBold(
                                                          textSize:
                                                          TextSizes.eighteen,
                                                          textColor: colorBlack),
                                                    ),
                                                  ),
                                                ],
                                              );
                                            }).toList() ?? [],
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                            ),
                            /*child: NotFoundScreen(
                              message: '${_.getTypeMessage(_.code.value)}',
                            ),*/
                          ) : Expanded(child: NotFoundScreen(message: 'Horaires non disponible pour l\'instant')),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            );
          }),
    );
  }
}
