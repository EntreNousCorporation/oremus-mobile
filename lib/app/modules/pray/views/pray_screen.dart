import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/image_displayer.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/pray/controller/pray_controller.dart';
import 'package:oremusapp/app/modules/pray/views/custom_prayers_screen.dart';
import 'package:oremusapp/app/modules/pray/views/mini_missel_screen.dart';
import 'package:oremusapp/app/modules/pray/views/pray_item.dart';
import 'package:oremusapp/generated/assets.dart';
import 'package:pull_to_refresh_simple/pull_to_refresh_simple.dart';

class PrayScreen extends StatelessWidget {
  const PrayScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: SafeArea(
        bottom: false,
        child: GetX<PrayController>(
          builder: (controller) {
            return PopScope(
              canPop: controller.unlockBackButton.value,
              child: KeyboardDismisser(
                child: Scaffold(
                  resizeToAvoidBottomInset: true,
                  body: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 16,
                        ),
                        decoration: BoxDecoration(
                          color: colorWhite,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: colorGreenSemiLight.withValues(
                                  alpha: 0.1,
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: colorGreenSemiLight,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Prières',
                                  style: TextStyles.montserratBold(
                                    textSize: TextSizes.eighteen,
                                    textColor: colorGreenSemiLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Découvrez des prières inspirantes',
                                  style: TextStyles.montserratRegular(
                                    textSize: TextSizes.thirteen,
                                    textColor: Colors.grey[600]!,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Main content area
                      Expanded(
                        child: DefaultTabController(
                          length: 2,
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                color: colorWhite,
                                child: Container(
                                  height: 45,
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: colorGrey1.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: TabBar(
                                    indicator: BoxDecoration(
                                      color: colorGreen,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    labelColor: colorWhite,
                                    unselectedLabelColor: colorGrey1,
                                    tabs: [
                                      Tab(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const ImageDisplayer(
                                              icon: Assets.imagesIconPray,
                                              height: 18,
                                              color: colorBlack,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Prières du missel',
                                                style:
                                                    TextStyles.montserratMedium(
                                                      textSize:
                                                          TextSizes.fourteen,
                                                      textColor: colorBlack,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Tab(
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const ImageDisplayer(
                                              icon: Assets.imagesIconPray,
                                              height: 18,
                                              color: colorBlack,
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                'Prières ordinaires',
                                                style:
                                                    TextStyles.montserratMedium(
                                                      textSize:
                                                          TextSizes.fourteen,
                                                      textColor: colorBlack,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Contenu des tabs
                              const Expanded(
                                child: TabBarView(
                                  children: [
                                    // Tab des mini missel
                                    MiniMisselScreen(),

                                    // Tab des prieres ordinaires
                                    CustomPrayersScreen(),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
