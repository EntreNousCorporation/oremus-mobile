import 'package:flutter/material.dart';
import 'package:flutter_fadein/flutter_fadein.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/customhome/views/widget/search_widget.dart';
import 'package:oremusapp/app/modules/pray/controller/pray_controller.dart';

class PrayScreen extends StatelessWidget {
  const PrayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetX<PrayController>(
            builder: (_) {
              return WillPopScope(
                onWillPop: () async => _.unlockBackButton.value,
                child: KeyboardDismisser(
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
                                      size: 25,
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
                                            right: 16,
                                          ),
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
                                      message: "Aucune prière trouvée !",
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
