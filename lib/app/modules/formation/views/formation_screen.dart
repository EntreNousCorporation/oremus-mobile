import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/app_navigation_bar.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/modules/formation/controller/formation_controller.dart';

class FormationScreen extends StatelessWidget {
  const FormationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Container(
      color: colorGreen,
      child: SafeArea(
        child: GetBuilder<FormationController>(
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
                              title: 'Formation',
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
                                    children: [],
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
