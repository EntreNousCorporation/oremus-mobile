import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/app_navigation_bar.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/home/controller/home_controller.dart';
import 'package:oremusapp/app/modules/home/views/widget/search_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var screensize = MediaQuery.of(context).size;

    final double serviceItemHeight =
        (screensize.height - kToolbarHeight - 24) / 11;
    final double serviceItemWidth = screensize.width / 5;

    final double operationItemHeight =
        (screensize.height - kToolbarHeight - 24) / 9;
    final double operationItemWidth = screensize.width / 4;

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
                    resizeToAvoidBottomInset: true,
                    body: SafeArea(
                      child: Container(
                        color: colorGrey4,
                        padding: const EdgeInsets.only(
                            top: 24, bottom: 0, left: 16, right: 16),
                        child: Column(
                          children: [
                            AppNavigationBar(
                              title: 'Accueil',
                              showBackButton: false,
                            ),
                            Expanded(
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
                                              childAspectRatio: 3/2,
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
                          ],
                        ),
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
