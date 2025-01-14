import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:like_button/like_button.dart';
import 'package:oremusapp/app/commons/buttons_tabbar.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_activity_movement_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/activity_movement/activity_screen.dart';
import 'package:oremusapp/app/modules/paroisse/views/paroisse_menu/activity_movement/movement_screen.dart';
import 'package:oremusapp/generated/assets.dart';

class ParoisseActivityMovementScreen extends StatelessWidget {
  const ParoisseActivityMovementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: GetX<ParoisseActivityMovementController>(
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
                        floating: false,
                        pinned: true,
                        backgroundColor: colorGreen,
                        elevation: 10,
                        shadowColor: colorGrey2.withOpacity(0.8),
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
                              _.paroisseSelected.value.isFavorite = !isLiked;
                              if (isLiked) {
                                _.removeFavorite(_.paroisseSelected.value, isLiked);
                              } else {
                                _.saveFavorite(_.paroisseSelected.value, isLiked);
                              }
                              return !isLiked;
                            },
                            size: 25,
                            circleColor: const CircleColor(
                                start: Color(0xff93291E),
                                end: Color(0xFFED213A)),
                            bubblesColor: const BubblesColor(
                              dotPrimaryColor: Color(0xFFED213A),
                              dotSecondaryColor: Color(0xff93291E),
                            ),
                            likeBuilder: (bool isLiked) {
                              return Icon(
                                isLiked
                                    ? Icons.favorite
                                    : Icons.favorite_border,
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
                                CachedNetworkImage(
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
                                Image.asset(
                                  Assets.imagesBgLogin,
                                  width: Get.width,
                                  height: Get.width,
                                  fit: BoxFit.cover,
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
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: <Widget>[
                              ButtonsTabBar(
                                backgroundColor: colorGreenSemiLight,
                                unselectedBackgroundColor: Colors.transparent,
                                unselectedLabelStyle: TextStyles.montserratBold(
                                  textSize: TextSizes.fourteen,
                                  textColor: colorBlack,
                                ),
                                contentPadding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                borderWidth: 1,
                                labelStyle: TextStyles.montserratBold(
                                  textSize: TextSizes.fourteen,
                                  textColor: colorWhite,
                                ),
                                borderColor: colorGreenSemiLight,
                                tabs: _.menusTab.map((e) {
                                  return Tab(text: e);
                                }).toList(),
                              ),
                              const Expanded(
                                child: TabBarView(
                                  children: <Widget>[
                                    Center(
                                      child: ActivityScreen(),
                                    ),
                                    Center(
                                      child: MovementScreen(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
