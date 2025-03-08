import 'package:flutter/material.dart';
import 'package:flutter_animator/widgets/fading_entrances/fade_in.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/custom_header.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/components/not_found_page.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/profile/controller/profile_controller.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorWhite,
      appBar: AppBar(
        elevation: applyElevation(),
        shadowColor: colorGrey2.withValues(alpha: 0.8),
        backgroundColor: colorGreen,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colorWhite,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        title: Text(
          'Mon profil',
          style: TextStyles.montserratBold(
              textSize: TextSizes.twenty, textColor: colorWhite),
        ),
      ),
      body: GetX<ProfileController>(builder: (_) {
        return PopScope(
          canPop: _.unlockBackButton.value,
          child: AbsorbPointer(
            absorbing: _.lockScreen.value,
            child: KeyboardDismisser(
              child: Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  SmartRefresher(
                    controller: _.refreshController,
                    onRefresh: _.getProfile,
                    header: const CustomClassicHeader(),
                    child: Container(
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
                              ? NotificationListener<
                              OverscrollIndicatorNotification>(
                            onNotification: (notification) {
                              notification.disallowIndicator();
                              return false;
                            },
                            child: Expanded(
                              child: SingleChildScrollView(
                                physics:
                                const BouncingScrollPhysics(),
                                child: FadeIn(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: 0,
                                      bottom: 0,
                                      left: 16,
                                      right: 16,
                                    ),
                                    child: Padding(
                                      padding:
                                      const EdgeInsets.symmetric(
                                        horizontal: 16.0,
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: [
                                          Separators
                                              .maximumVertical(),
                                          Stack(
                                            alignment:
                                            Alignment.bottomRight,
                                            children: [
                                              Hero(
                                                tag: 'avatar',
                                                child: Material(
                                                  borderRadius:
                                                  BorderRadius
                                                      .circular(
                                                      110.0),
                                                  elevation: 6,
                                                  color: colorWhite,
                                                  shadowColor:
                                                  colorGrey2
                                                      .withValues(alpha:
                                                  0.5),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        110),
                                                    child: Container(
                                                      color:
                                                      colorGreenlight2,
                                                      child: SizedBox(
                                                        width: 110,
                                                        height: 110,
                                                        child: SvgPicture
                                                            .asset(
                                                            'assets/images/avatar.svg'),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Visibility(
                                                visible: false,
                                                child: Positioned(
                                                  right: 10,
                                                  child: Material(
                                                    borderRadius:
                                                    BorderRadius
                                                        .circular(
                                                        90.0),
                                                    elevation: 10,
                                                    color: colorWhite,
                                                    shadowColor:
                                                    colorGrey2
                                                        .withValues(alpha:
                                                    0.5),
                                                    child: const Icon(
                                                      Icons
                                                          .add_circle,
                                                      color:
                                                      colorPurpleLight,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          Separators.normalVertical(),
                                          Text(
                                            '${_.userInfo.value.firstname} ${_.userInfo.value.lastname}',
                                            textAlign:
                                            TextAlign.center,
                                            style: TextStyles
                                                .montserratBold(
                                                textSize:
                                                TextSizes
                                                    .eighteen,
                                                textColor:
                                                colorBlack),
                                          ),
                                          Separators
                                              .minimunVertical(),
                                          Text(
                                            '${_.userInfo.value.email}',
                                            textAlign:
                                            TextAlign.center,
                                            style: TextStyles
                                                .montserratRegular(
                                                textSize:
                                                TextSizes
                                                    .eighteen,
                                                textColor:
                                                colorGrey1),
                                          ),
                                          Separators
                                              .minimunVertical(),
                                          Text(
                                            '${_.userInfo.value.phone?.phoneFormat()}',
                                            textAlign:
                                            TextAlign.center,
                                            style: TextStyles
                                                .montserratRegular(
                                                textSize:
                                                TextSizes
                                                    .eighteen,
                                                textColor:
                                                colorGrey1),
                                          ),
                                          Separators
                                              .maximumVertical(),
                                          Separators
                                              .maximumVertical(),
                                          GestureDetector(
                                            onTap: () {
                                              _.goToFavorites();
                                            },
                                            child: Material(
                                              elevation: 6,
                                              color: colorGrey2,
                                              shadowColor: colorGrey2
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                              BorderRadius
                                                  .circular(50),
                                              child: SizedBox(
                                                height: 50,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          Separators
                                                              .normalHorizontal(),
                                                          const Icon(Icons
                                                              .favorite),
                                                          Separators
                                                              .minimunHorizontal(),
                                                          Text(
                                                            'Mes favoris',
                                                            textAlign:
                                                            TextAlign
                                                                .center,
                                                            style: TextStyles.montserratRegular(
                                                                textSize: TextSizes
                                                                    .fourteen,
                                                                textColor:
                                                                colorBlack),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Icon(Icons
                                                        .arrow_forward_ios_rounded),
                                                    Separators
                                                        .normalHorizontal(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Separators.normalVertical(),
                                          GestureDetector(
                                            onTap: () {
                                              _.goToEditPassword();
                                            },
                                            child: Material(
                                              elevation: 6,
                                              color: colorGrey2,
                                              shadowColor: colorGrey2
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                              BorderRadius
                                                  .circular(50),
                                              child: SizedBox(
                                                height: 50,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          Separators
                                                              .normalHorizontal(),
                                                          const Icon(
                                                              Icons
                                                                  .lock),
                                                          Separators
                                                              .minimunHorizontal(),
                                                          Hero(
                                                            tag:
                                                            'update-password',
                                                            child:
                                                            Text(
                                                              'Modifier votre mot de passe',
                                                              textAlign:
                                                              TextAlign.center,
                                                              style: TextStyles.montserratRegular(
                                                                  textSize:
                                                                  TextSizes.fourteen,
                                                                  textColor: colorBlack),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    const Icon(Icons
                                                        .arrow_forward_ios_rounded),
                                                    Separators
                                                        .normalHorizontal(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          Separators.normalVertical(),
                                          Visibility(
                                            visible: false,
                                            child: Material(
                                              elevation: 6,
                                              color: colorGrey2,
                                              shadowColor: colorGrey2
                                                  .withValues(alpha: 0.5),
                                              borderRadius:
                                              BorderRadius
                                                  .circular(50),
                                              child: SizedBox(
                                                height: 50,
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Row(
                                                        children: [
                                                          Separators
                                                              .normalHorizontal(),
                                                          const Icon(Icons
                                                              .fingerprint_rounded),
                                                          Separators
                                                              .minimunHorizontal(),
                                                          Expanded(
                                                            child:
                                                            Text(
                                                              'Connexion biométrique',
                                                              textAlign:
                                                              TextAlign.start,
                                                              maxLines:
                                                              2,
                                                              overflow:
                                                              TextOverflow.ellipsis,
                                                              style: TextStyles.montserratRegular(
                                                                  textSize:
                                                                  TextSizes.fourteen,
                                                                  textColor: colorBlack),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    Switch(
                                                        activeColor:
                                                        colorGreenSemiLight,
                                                        value: _
                                                            .isActive
                                                            .value,
                                                        onChanged:
                                                            (value) {
                                                          _.updateBiometriqueUI();
                                                          _.showMessageBiometrique(
                                                              value);
                                                        }),
                                                    Separators
                                                        .normalHorizontal(),
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
                            ),
                          )
                              : _.hasError.isTrue ? Expanded(
                            child: NotFoundScreen(
                              message: _.errorMessage.value,
                              doAction: () {
                                _.getProfile();
                              },
                            ),
                          ) : Expanded(
                            child: NotFoundScreen(
                              message: "Aucune information trouvée !",
                              buttonTitle: 'Rafraîchir',
                              doAction: () {
                                _.getProfile();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    child: TextButton.icon(
                      onPressed: () {
                        _.showDeleteAccountDialog();
                      },
                      icon: Image.asset(
                        'assets/images/delete-friend.png',
                        height: 20,
                        color: colorRed1.withValues(alpha: 0.6),
                      ),
                      label: Text(
                        'Supprimer mon compte',
                        style: TextStyles.montserratBold(
                          textSize: TextSizes.fourteen,
                          textColor: colorRed1.withValues(alpha: 0.6),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
