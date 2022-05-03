import 'dart:developer';

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:like_button/like_button.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_office_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/day_office_item.dart';

class ParoisseOfficeScreen extends StatelessWidget {
  const ParoisseOfficeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: GetX<ParoisseOfficeController>(
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
                        LikeButton(
                          isLiked: _.paroisseSelected.value.isFavorite,
                          onTap: (isLiked) async {
                            log('isLiked => $isLiked');
                            _.paroisseSelected.value.isFavorite = !isLiked;
                            if (isLiked) {
                              _.removeFavorite(
                                  _.paroisseSelected.value, isLiked);
                            } else {
                              _.saveFavorite(_.paroisseSelected.value, isLiked);
                            }
                            return !isLiked;
                          },
                          size: 25,
                          circleColor: const CircleColor(
                              start: Color(0xff93291E), end: Color(0xFFED213A)),
                          bubblesColor: const BubblesColor(
                            dotPrimaryColor: Color(0xFFED213A),
                            dotSecondaryColor: Color(0xff93291E),
                          ),
                          likeBuilder: (bool isLiked) {
                            return Icon(
                              isLiked ? Icons.favorite : Icons.favorite_border,
                              color: isLiked
                                  ? const Color(0xFFED213A)
                                  : colorWhite,
                              size: 25,
                            );
                          },
                        ),
                        Separators.minimunHorizontal(),
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
                                      tag:
                                          'tag${_.paroisseSelected.value.identifier}',
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
                                      tag:
                                          'tag${_.paroisseSelected.value.identifier}',
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
                              'Horaires des bureaux',
                              textAlign: TextAlign.center,
                              style: TextStyles.montserratBold(
                                textSize: TextSizes.eighteen,
                                textColor: colorGreenSemiLight,
                              ),
                            ),
                          ),
                          _.isDataProcessing.isTrue
                              ? Expanded(
                                  child: Center(
                                    child: LottieLoadingView(
                                      size: Get.width / 4,
                                    ),
                                  ),
                                )
                              : _.hasData.isTrue
                                  ? Expanded(
                                      child: FadeIn(
                                        duration:
                                            const Duration(milliseconds: 500),
                                        child: Accordion(
                                          disableScrolling: false,
                                          maxOpenSections: 1,
                                          leftIcon: SvgPicture.asset(
                                            'assets/images/calendar.svg',
                                            height: 25,
                                            color: colorWhite,
                                          ),
                                          headerBackgroundColor:
                                              colorGreenSemiLight,
                                          contentBorderColor:
                                              colorGreenSemiLight,
                                          children:
                                              _.offices.value.map((value) {
                                            return AccordionSection(
                                              sectionOpeningHapticFeedback:
                                                  SectionHapticFeedback.medium,
                                              sectionClosingHapticFeedback:
                                                  SectionHapticFeedback.medium,
                                              isOpen: true,
                                              header: Text(
                                                '${value.name}',
                                                style: TextStyles
                                                    .montserratSemiBold(
                                                        textSize:
                                                            TextSizes.sixteen,
                                                        textColor: colorWhite),
                                              ),
                                              content: ListView.builder(
                                                  padding: const EdgeInsets.all(0),
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemCount:
                                                      value.openingTime?.length,
                                                  itemBuilder: (context, i) {
                                                    var openingTime =
                                                        value.openingTime?[i];
                                                    return DayOfficeItem(
                                                        openingTime:
                                                            openingTime);
                                                  }),
                                            );
                                          }).toList(),
                                        ),
                                      ),
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
}
