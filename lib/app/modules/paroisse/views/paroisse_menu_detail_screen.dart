import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/home/views/widget/menu_grid_item.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu_controller.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu_detail_controller.dart';

class ParoisseMenuDetailScreen extends StatelessWidget {
  const ParoisseMenuDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetBuilder<ParoisseMenuDetailController>(
            initState: (state) {},
            builder: (_) {
              return KeyboardDismisser(
                child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  body: CustomScrollView(
                    slivers: [
                      SliverAppBar(
                        expandedHeight: Get.width / 1.7,
                        floating: false,
                        pinned: true,
                        backgroundColor: colorGreen,
                        elevation: 10,
                        shadowColor: colorGrey2.withOpacity(0.8),
                        leading: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: const Icon(Icons.arrow_back_ios_rounded),
                        ),
                        actions: [
                          GestureDetector(
                            onTap: () {},
                            child: const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Icon(Icons.map_rounded),
                            ),
                          ),
                        ],
                        flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            title: Text(
                              '${_.paroisseSelected.value.name}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: TextStyles.montserratBold(
                                  textSize: TextSizes.eighteen,
                                  textColor: colorWhite),
                            ),
                            background: (_.paroisseSelected.value.coverImage
                                        ?.link?.isNotEmpty ==
                                    true)
                                ? Stack(
                                    children: [
                                      Hero(
                                        tag: 'tag${_.indexSelected.value}',
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
                                          color:
                                              Colors.black54.withOpacity(0.3),
                                        ),
                                      ),
                                    ],
                                  )
                                : Stack(
                                    children: [
                                      Hero(
                                        tag: 'tag${_.indexSelected.value}',
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
                                          color:
                                              Colors.black54.withOpacity(0.3),
                                        ),
                                      ),
                                    ],
                                  )),
                      ),
                      const SliverPadding(
                          padding: EdgeInsets.symmetric(vertical: 8)),
                      SliverFillRemaining(
                        child: Center(
                          child: Column(
                            children: [
                              Hero(
                                tag: _.code.value,
                                child: Text(
                                  _.getTypeTitle(_.code.value),
                                  textAlign: TextAlign.center,
                                  style: TextStyles.montserratBold(
                                    textSize: TextSizes.eighteen,
                                    textColor: colorGreen,
                                  ),
                                ),
                              ),
                              Expanded(
                                  child: NotFoundScreen(
                                message: '${_.getTypeMessage(_.code.value)}',
                              )),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
