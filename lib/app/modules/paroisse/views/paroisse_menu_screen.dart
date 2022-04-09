import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_menu_controller.dart';

class ParoisseMenuScreen extends StatelessWidget {
  const ParoisseMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetBuilder<ParoisseMenuController>(
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
                        backgroundColor: colorWhite,
                        flexibleSpace: FlexibleSpaceBar(
                            centerTitle: true,
                            title: Text(
                              '${_.paroisseSelected.value.name}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                              ),
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
                                          color: Colors.black54.withOpacity(0.3),),
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
                                            color: Colors.black54.withOpacity(0.3),),
                                      ),
                                    ],
                                  )),
                      ),
                    ],
                  ),
                ),
              );
            }),
      ),
    );
  }
}
