import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/profile/controller/profile_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetX<ProfileController>(
            initState: (state) {},
            builder: (_) {
              return KeyboardDismisser(
                child: SmartRefresher(
                  controller: _.refreshController,
                  onRefresh: _.getProfile,
                  child: Scaffold(
                    resizeToAvoidBottomInset: true,
                    body: Container(
                      color: colorGrey4,
                      width: double.infinity,
                      child: Column(
                        children: [
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
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 0,
                                    bottom: 0,
                                    left: 16,
                                    right: 16),
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [

                                  ],
                                ),
                              ),
                            ),
                          )
                              : Expanded(
                              child: NotFoundScreen(
                                message: "Aucune paroisse trouvée !",
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
