import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/controller/filter_mass_request_date_controller.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/shimmer_price.dart';
import 'package:oremusapp/app/modules/reportproblem/controller/report_problem_controller.dart';
import 'package:oremusapp/app/modules/reportproblem/views/widget/report_problem_description_widget.dart';
import 'package:oremusapp/app/modules/reportproblem/views/widget/report_problem_type_filter.dart';
import 'package:oremusapp/generated/assets.dart';

class ReportProblemScreen extends StatelessWidget {
  const ReportProblemScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: GetX<ReportProblemController>(builder: (_) {
        return KeyboardDismisser(
          child: WillPopScope(
            onWillPop: () async => _.unlockBackButton.value,
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
                      snap: false,
                      pinned: true,
                      backgroundColor: colorGreen,
                      elevation: 10,
                      shadowColor: colorGrey2.withOpacity(0.8),
                      leading: IconButton(
                        onPressed: () {
                          Get.back();
                          Get.delete<FilterMassRequestDateController>(
                              force: true);
                        },
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            _.paroisseSelected.value.name ?? '-',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.eighteen,
                              textColor: colorWhite,
                            ),
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
                                      color: Colors.black54.withOpacity(0.3),
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
                                      color: Colors.black54.withOpacity(0.3),
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Separators.minimunVertical(),
                            Text(
                              'Signaler un problème',
                              textAlign: TextAlign.center,
                              style: TextStyles.montserratBold(
                                textSize: TextSizes.eighteen,
                                textColor: colorGreenSemiLight,
                              ),
                            ),
                            Separators.normalVertical(),
                            Separators.maximum1Vertical(),
                            Text(
                              'Veuillez saisir votre e-mail pour recevoir un retour',
                              style: TextStyles.montserratMedium(
                                textColor: colorGrey1,
                                textSize: TextSizes.fourteen,
                              ),
                            ),
                            Separators.customSizeVertical(8),
                          Material(
                            borderRadius: BorderRadius.circular(10.0),
                            elevation: 10,
                            color: colorWhite,
                            shadowColor: colorGrey2.withOpacity(0.5),
                            child: TextFormField(
                              controller: _.emailController,
                              keyboardAppearance: Brightness.light,
                              style: TextStyles.montserratSemiBold(textColor: colorBlack),
                              maxLines: 1,
                              autofocus: true,
                              cursorColor: colorBlue,
                              keyboardType: TextInputType.emailAddress,
                              //textInputAction: TextInputAction.done,
                              decoration: InputDecoration(
                                contentPadding:
                                const EdgeInsets.only(top: 16, left: 16, right: 0, bottom: 0),
                                filled: true,
                                fillColor: colorWhite,
                                border: InputBorder.none,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: colorGreen),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(color: colorTransparent),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                errorBorder: InputBorder.none,
                                disabledBorder: UnderlineInputBorder(
                                  borderSide: const BorderSide(color: colorGrey1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                hintText: '',
                                hintStyle: TextStyles.montserratItalic(
                                  textColor: colorPurpleLight,
                                  textSize: TextSizes.fourteen,
                                ),
                              ),
                              onChanged: (value) {
                                _.checkForm();
                              },
                            ),
                          ),
                            Separators.maximumVertical(),
                            Text(
                              'Objet',
                              style: TextStyles.montserratMedium(
                                textColor: colorGrey1,
                                textSize: TextSizes.fourteen,
                              ),
                            ),
                            Separators.customSizeVertical(8),
                            Material(
                              borderRadius: BorderRadius.circular(10.0),
                              elevation: 10,
                              color: colorWhite,
                              shadowColor: colorGrey2.withOpacity(0.5),
                              child: _.isReportProblemTypeProcessing.isTrue
                                  ? const ShimmerPrice(height: 50)
                                  : Material(
                                      borderRadius: BorderRadius.circular(10.0),
                                      elevation: 10,
                                      color: colorWhite,
                                      shadowColor: colorGrey2.withOpacity(0.5),
                                      child: const ReportProblemTypeFilter(),
                                    ),
                            ),
                            Separators.maximumVertical(),
                            Text(
                              'Description',
                              style: TextStyles.montserratMedium(
                                textColor: colorGrey1,
                                textSize: TextSizes.fourteen,
                              ),
                            ),
                            Separators.customSizeVertical(8),
                            Material(
                              borderRadius: BorderRadius.circular(10.0),
                              elevation: 10,
                              color: colorWhite,
                              shadowColor: colorGrey2.withOpacity(0.5),
                              child: const ReportProblemDescriptionWidget(),
                            ),
                            Separators.maximum1Vertical(),
                            Material(
                              borderRadius: BorderRadius.circular(10.0),
                              elevation: 10,
                              color: colorWhite,
                              shadowColor: colorGrey2.withOpacity(0.5),
                              child: CustomButton(
                                text: 'Envoyer',
                                borderRadius: 10,
                                textSize: TextSizes.sixteen,
                                bgcolor: _.isValidForm.isTrue
                                    ? colorGreen
                                    : colorGrey1.withOpacity(0.5),
                                borderColor: _.isValidForm.isTrue
                                    ? colorGreen
                                    : colorGreen.withOpacity(0),
                                actionColor: colorGreen.withOpacity(0.5),
                                enabled: _.isValidForm.value,
                                action: () {
                                  _.doSendReportProblem();
                                },
                              ),
                            ),
                            Separators.maximum1Vertical(),
                          ],
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
    );
  }
}
