import 'dart:math';

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
import 'package:oremusapp/app/modules/paroisse/views/widget/day1_item.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/day_item.dart';

class ParoisseMenuDetailScreen extends StatelessWidget {
  ParoisseMenuDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
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
                                  content: ListView.builder(
                                    physics: const NeverScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: value.openingTime?.length,
                                      itemBuilder: (context, i) {
                                      var openingTime = value.openingTime?[i];
                                        return Day1Item(openingTime: openingTime);
                                      }),
                                );
                              }).toList(),
                            ),
                            /*child: NotFoundScreen(
                              message: '${_.getTypeMessage(_.code.value)}',
                            ),*/
                                )
                              : Expanded(
                                  child: NotFoundScreen(
                                      message:
                                          'Horaires non disponible pour l\'instant')),
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

  final List<Events> listOfEvents = [
    Events(time: "5pm", eventName: "New Icon", description: "Mobile App"),
    Events(time: "3 - 4pm", eventName: "Design Stand Up", description: "Hangouts"),
    Events(time: "12pm", eventName: "Lunch Break", description: "Main Room"),
    Events(time: "9 - 11am", eventName: "Finish Home Screen", description: "Web App"),
  ];

  final List<Color> listOfColors = [Constants.kPurpleColor,Constants.kGreenColor,Constants.kRedColor];


}
class Events {
  final String time;
  final String eventName;
  final String description;

  Events({required this.time, required this.eventName, required this.description});

}

class Constants {
  static const kPurpleColor = Color(0xFFB97DFE);
  static const kRedColor = Color(0xFFFE4067);
  static const kGreenColor = Color(0xFFADE9E3);
}
