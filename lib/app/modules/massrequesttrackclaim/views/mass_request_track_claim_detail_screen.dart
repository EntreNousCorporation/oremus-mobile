import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/utils.dart';
import 'package:oremusapp/app/modules/massrequesttrackclaim/controller/mass_request_track_claim_detail_controller.dart';
import 'package:oremusapp/generated/assets.dart';

class MassRequestTrackClaimDetailScreen extends StatelessWidget {
  const MassRequestTrackClaimDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: GetX<MassRequestTrackClaimDetailController>(builder: (_) {
        return KeyboardDismisser(
          child: Scaffold(
            resizeToAvoidBottomInset: true,
            body: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (notification) {
                notification.disallowIndicator();
                return false;
              },
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    expandedHeight: AppConstants.kExpandedHeight,
                    collapsedHeight: 100,
                    floating: false,
                    pinned: true,
                    backgroundColor: colorGreen,
                    elevation: 10,
                    shadowColor: colorGrey2.withValues(alpha: 0.8),
                    leading: IconButton(
                      onPressed: () {
                        Get.back();
                      },
                      icon: const Icon(Icons.arrow_back_ios_rounded, color: colorWhite,),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            _.paroisseSelected.value.name ?? '',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyles.montserratBold(
                                textSize: TextSizes.eighteen,
                                textColor: colorWhite),
                          ),
                        ),
                        background: (_.paroisseSelected.value.coverImage?.link
                                    ?.isNotEmpty ==
                                true)
                            ? Stack(
                                children: [
                                  CachedNetworkImage(
                                    width: Get.width,
                                    height: Get.width,
                                    imageUrl: _.paroisseSelected.value
                                            .coverImage?.link ??
                                        '',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        LottieLoadingView(size: Get.width / 6),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                  Container(
                                    height: Get.width,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.black54.withValues(alpha: 0.3),
                                    ),
                                  ),
                                ],
                              )
                            : Stack(
                                children: [
                                  Image.asset(
                                    Assets.imagesBgLogin,
                                    width: Get.width,
                                    height: Get.width,
                                    fit: BoxFit.cover,
                                  ),
                                  Container(
                                    height: Get.width,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.black54.withValues(alpha: 0.3),
                                    ),
                                  ),
                                ],
                              )),
                  ),
                  const SliverPadding(padding: EdgeInsets.symmetric(vertical: 8)),
                  SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                    sliver: SliverToBoxAdapter(
                      child: Column(
                        children: [
                          Separators.minimunVertical(),
                          Text(
                            'Détails réclamation',
                            textAlign: TextAlign.center,
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.eighteen,
                              textColor: colorGreenSemiLight,
                            ),
                          ),
                          Separators.normalVertical(),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(
                                color:
                                    getColor(_.claimSelected.value?.status?.code),
                              ),
                            ),
                            child: Icon(
                              getIcon(_.claimSelected.value?.status?.code),
                              color:
                                  getColor(_.claimSelected.value?.status?.code),
                              size: Get.width / 10,
                            ),
                          ),
                          Separators.customSizeVertical(10),
                          Text(
                            _.claimSelected.value?.status?.name?.fr ?? '-',
                            textAlign: TextAlign.center,
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.eighteen,
                              textColor:
                                  getColor(_.claimSelected.value?.status?.code),
                            ),
                          ),
                          Separators.normalVertical(),
                          SizedBox(
                            width: double.maxFinite,
                            child: Material(
                              borderRadius: BorderRadius.circular(10.0),
                              elevation: 10,
                              color: colorWhite,
                              shadowColor: colorGrey2.withValues(alpha: 0.5),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  children: [
                                    Text(
                                      'Paroisse',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.fourteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.minimunVertical(),
                                    Text(
                                      _.claimSelected.value?.massRequest?.worshipPlace?.name ?? '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.sixteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.normalVertical(),
                                    Text(
                                      'Type de réclamation',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.fourteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.minimunVertical(),
                                    Text(
                                      _.claimSelected.value?.typeOfClaim?.name
                                              ?.fr ??
                                          '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.sixteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.normalVertical(),
                                    Text(
                                      'Description de la réclamation',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.fourteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.minimunVertical(),
                                    Text(
                                      _.claimSelected.value?.description ?? '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.sixteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.normalVertical(),
                                    Text(
                                      'Créée le',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.fourteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.minimunVertical(),
                                    Text(
                                      getDateTime(
                                          _.claimSelected.value?.createdAt ??
                                              ' - '),
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.sixteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.normalVertical(),
                                    Text(
                                      'Modifiée le',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.fourteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.minimunVertical(),
                                    Text(
                                      getDateTime(
                                          _.claimSelected.value?.updatedAt ??
                                              ' - '),
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.sixteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.normalVertical(),
                                    Text(
                                      'Observation',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratRegular(
                                        textSize: TextSizes.fourteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.minimunVertical(),
                                    Text(
                                      _.claimSelected.value?.observation ?? '-',
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratSemiBold(
                                        textSize: TextSizes.fourteen,
                                        textColor: colorBlack,
                                      ),
                                    ),
                                    Separators.normalVertical(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Separators.normalVertical(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
