import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/home/controller/home_controller.dart';
import 'package:oremusapp/app/modules/home/views/widget/image_slider.dart';
import 'package:oremusapp/app/modules/home/views/widget/menu_grid_item.dart';
import 'package:oremusapp/app/modules/home/views/widget/search_widget.dart';
import 'package:oremusapp/app/modules/home/views/widget/slider_indicator.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetBuilder<HomeController>(
            initState: (state) {},
            builder: (_) {
              return WillPopScope(
                onWillPop: () async => _.unlockBackButton.value,
                child: KeyboardDismisser(
                  child: Scaffold(
                    resizeToAvoidBottomInset: false,
                    appBar: AppBar(
                      elevation: 0,
                      backgroundColor: colorGreen,
                      centerTitle: true,
                      leading: const IconButton(
                        icon: Icon(Icons.menu, color: colorWhite,),
                        onPressed: null,
                      ),
                      title: Text(
                        'Accueil',
                        style: TextStyles
                            .montserratBold(
                            textSize:
                            TextSizes
                                .twenty,
                            textColor:
                            colorWhite),
                      ),
                    ),
                    body: Column(
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
                        Separators.normalVertical(),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: SizedBox(
                            height: (Get.width / 10),
                            child: const SearchWidget(),
                          ),
                        ),
                        Separators.normalVertical(),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: GridView.builder(
                              physics:
                              const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 3 / 2,
                                crossAxisCount: 2,
                                crossAxisSpacing: 0.0,
                                mainAxisSpacing: 0.0,
                              ),
                              itemCount: _.menus.length,
                              itemBuilder:
                                  (context, index) {
                                var menu = _.menus[index];
                                return MenuGridItem(item: menu);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
      ),
    );
  }
}
