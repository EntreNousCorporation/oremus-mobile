import 'dart:developer';

import 'package:accordion/accordion.dart';
import 'package:accordion/controllers.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:like_button/like_button.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/timeline/flutter_timeline.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_office_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/day_office_item.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseOfficeScreen extends StatelessWidget {
  const ParoisseOfficeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: GetX<ParoisseOfficeController>(
          builder: (_) {
            return KeyboardDismisser(
              child: Scaffold(
                resizeToAvoidBottomInset: true,
                body: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (notification) {
                    notification.disallowIndicator();
                    return false;
                  },
                  child: CustomScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    slivers: [
                      SliverAppBar(
                        expandedHeight: AppConstants.kExpandedHeight,
                        collapsedHeight: 100,
                        floating: false,
                        pinned: true,
                        backgroundColor: colorGreen,
                        elevation: 10,
                        shadowColor: colorGrey2.withValues(alpha: 0.8),
                        leading: IconButton(
                          onPressed: () {
                            Get.back();
                          },
                          icon: const Icon(Icons.arrow_back_ios_rounded, color: colorWhite,),
                        ),
                        actions: [
                          IconButton(
                            onPressed: () {
                              _.goToReportProblem();
                            },
                            icon: SvgPicture.asset(Assets.imagesWarning, colorFilter: const ColorFilter.mode(colorWhite, BlendMode.srcIn),),
                          ),
                          Separators.minimunHorizontal(),
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
                            icon: const Icon(Icons.map_rounded, color: colorWhite,),
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
                                          color: Colors.black54.withValues(alpha: 0.3),
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
                                          height: Get.width,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Container(
                                        height: Get.width,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                          color: Colors.black54.withValues(alpha: 0.3),
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
                                          child: SmartRefresher(
                                            controller: _.refreshController,
                                            onRefresh: _.onRefresh,
                                            header: const CustomClassicHeader(),
                                            child: Accordion(
                                              disableScrolling: true,
                                              maxOpenSections: 1,
                                              leftIcon: SvgPicture.asset(
                                                Assets.imagesCalendar,
                                                height: 25,
                                                colorFilter: const ColorFilter.mode(colorWhite, BlendMode.srcIn),
                                              ),
                                              headerBackgroundColor:
                                                  colorGreenSemiLight,
                                              contentBorderColor:
                                                  colorGreenSemiLight,
                                              children:
                                                  _.offices.map((value) {
                                                return AccordionSection(
                                                  headerPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
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
                                                  content: value.openingTime?.isNotEmpty == true ? TimelineTheme(
                                                    data: TimelineThemeData(lineColor: colorGrey1),
                                                    child: Timeline(
                                                      indicatorSize: 24,
                                                      events: value.openingTime!.map((openingTime) {
                                                        return TimelineEventDisplay(
                                                          child: DayOfficeItem(openingTime: openingTime),
                                                          indicator: Container(
                                                            width: 16,
                                                            height: 16,
                                                            decoration: BoxDecoration(
                                                              color: getCurrentDay() ==
                                                                  getDay(openingTime.dayOfWeek)
                                                                  ? colorGreenSemiLight
                                                                  : colorGrey1,
                                                              borderRadius: BorderRadius.circular(18),
                                                            ),
                                                            child: getCurrentDay() ==
                                                                getDay(openingTime.dayOfWeek)
                                                                ? const Icon(
                                                              Icons.check_circle,
                                                              size: 18,
                                                              color: colorWhite,
                                                            )
                                                                : const Icon(
                                                              Icons.circle,
                                                              size: 18,
                                                              color: colorWhite,
                                                            ),
                                                          ),
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ) : Text(
                                                    'Horaires non disponibles pour l\'instant',
                                                    style: TextStyles
                                                        .montserratSemiBold(
                                                        textSize:
                                                        TextSizes.fourteen,
                                                        textColor: colorBlack),
                                                  ),
                                                );
                                              }).toList(),
                                            ),
                                          ),
                                        ),
                                      )
                                    : Expanded(
                                        child: NotFoundScreen(
                                            message:
                                                'Horaires non disponibles pour l\'instant')),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
    );
  }
}
