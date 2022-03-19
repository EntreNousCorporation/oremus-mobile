import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/paroisse/controller/paroisse_controller.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/image_slider.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/search_widget.dart';
import 'package:oremusapp/app/modules/paroisse/views/widget/slider_indicator.dart';

class ParoisseScreen extends StatelessWidget {
  const ParoisseScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetX<ParoisseController>(
            initState: (state) {},
            builder: (_) {
              return WillPopScope(
                onWillPop: () async => _.unlockBackButton.value,
                child: KeyboardDismisser(
                  child: Scaffold(
                    resizeToAvoidBottomInset: true,
                    body: Container(
                      color: colorGrey4,
                      //padding: const EdgeInsets.only(top: 24, bottom: 0, left: 16, right: 16),
                      child: Column(
                        children: [
                          Stack(
                            children: [
                              SizedBox(
                                width: Get.width,
                                child: CarouselSlider.builder(
                                  carouselController: _.carouselController,
                                  itemCount: _.imgList.length,
                                  itemBuilder: (BuildContext context,
                                      int itemIndex, int pageViewIndex) {
                                    final image = _.imgList[itemIndex];
                                    return ImageSlider(image: image);
                                  },
                                  options: _.carouselOptions,
                                ),
                              ),
                              Positioned(
                                bottom: 0.0,
                                left: 0.0,
                                right: 0.0,
                                child: SliderIndicator(controller: _),
                              ),
                            ],
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  top: 24, bottom: 0, left: 16, right: 16),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        height: (Get.width / 9),
                                        child: const SearchWidget(),
                                      ),
                                      Separators.maximumVertical(),
                                      GridView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        gridDelegate:
                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                          childAspectRatio: 3 / 2,
                                          crossAxisCount: 2,
                                          crossAxisSpacing: 16.0,
                                          mainAxisSpacing: 16.0,
                                        ),
                                        itemCount: _.operations.length,
                                        itemBuilder: (context, index) {
                                          var operation = _.operations[index];
                                          return Material(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                            elevation: 0,
                                            child: Center(
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  const Icon(Icons.search),
                                                  Separators.normalVertical(),
                                                  const Text('Localisation'),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
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
