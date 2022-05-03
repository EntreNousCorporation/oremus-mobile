
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:like_button/like_button.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu/paroisse_presby_team_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/presby_team_item.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ParoisseBresbyTeamScreen extends StatelessWidget {
  const ParoisseBresbyTeamScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: GetX<ParoissePresbyTeamController>(
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
                                'assets/images/bg_login.jpg',
                                width: Get.width,
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
                          Separators.normalVertical(),
                          _.isDataProcessing.isTrue ? Expanded(
                            child: Center(
                              child: LottieLoadingView(
                                size: Get.width / 4,
                              ),
                            ),
                          ) : _.hasData.isTrue ? Expanded(
                            child: FadeIn(
                              duration: const Duration(milliseconds: 500),
                              child: SmartRefresher(
                                controller: _.refreshController,
                                onRefresh: _.onRefresh,
                                child: ListView.builder(
                                    itemCount: _.presbyTeams.length,
                                    itemBuilder: (context, index) {
                                      var user = _.presbyTeams[index];
                                      return PresbyTeamItem(user: user);
                                    }),
                              ),
                            ),
                          ) : Expanded(child: NotFoundScreen(message: _.getTypeMessage(_.code.value))),
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
