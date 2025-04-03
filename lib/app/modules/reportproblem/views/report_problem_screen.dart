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
          child: PopScope(
            canPop: _.unlockBackButton.value,
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
                    // En-tête avec image de fond
                    SliverAppBar(
                      expandedHeight: AppConstants.kExpandedHeight,
                      collapsedHeight: 100,
                      floating: false,
                      pinned: true,
                      backgroundColor: colorGreen,
                      elevation: 6,
                      shadowColor: Colors.black.withValues(alpha: 0.2),
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(0),
                          bottomRight: Radius.circular(0),
                        ),
                      ),
                      // Bouton retour
                      leading: Container(
                        margin: const EdgeInsets.only(left: 8, top: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          onPressed: () {
                            Get.back();
                            Get.delete<FilterMassRequestDateController>(force: true);
                          },
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: colorWhite,
                            size: 22,
                          ),
                        ),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                        background: Container(
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: const BorderRadius.only(
                              bottomLeft: Radius.circular(0),
                              bottomRight: Radius.circular(0),
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                // Image de couverture
                                (_.paroisseSelected.value.coverImage?.link?.isNotEmpty == true)
                                    ? CachedNetworkImage(
                                  imageUrl: _.paroisseSelected.value.coverImage?.link ?? '',
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      LottieLoadingView(size: Get.width / 6),
                                  errorWidget: (context, url, error) =>
                                      Image.asset(
                                        Assets.imagesBgLogin,
                                        fit: BoxFit.cover,
                                      ),
                                )
                                    : Image.asset(
                                  Assets.imagesBgLogin,
                                  fit: BoxFit.cover,
                                ),
                                // Superposition ombrée
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withValues(alpha: 0.7),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Contenu du formulaire
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Section de titre et d'introduction
                            Padding(
                              padding: const EdgeInsets.only(top: 24, bottom: 16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: colorGreenSemiLight.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.report_problem_outlined,
                                      color: colorGreenSemiLight,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Signaler un problème',
                                          style: TextStyles.montserratBold(
                                            textSize: TextSizes.seventeen,
                                            textColor: colorGreenSemiLight,
                                          ),
                                        ),
                                        Text(
                                          'Nous vous répondrons dans les plus brefs délais',
                                          style: TextStyles.montserratRegular(
                                            textSize: TextSizes.thirteen,
                                            textColor: Colors.grey[600]!,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Section de saisie d'email
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Votre adresse e-mail',
                                    style: TextStyles.montserratSemiBold(
                                      textColor: colorGreenSemiLight,
                                      textSize: TextSizes.fifteen,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _.emailController,
                                    keyboardAppearance: Brightness.light,
                                    style: TextStyles.montserratSemiBold(textColor: colorBlack),
                                    maxLines: 1,
                                    autofocus: true,
                                    cursorColor: colorGreenSemiLight,
                                    keyboardType: TextInputType.emailAddress,
                                    decoration: InputDecoration(
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                      filled: true,
                                      fillColor: Colors.grey[50],
                                      hintText: 'Saisissez votre email',
                                      hintStyle: TextStyles.montserratRegular(
                                        textColor: Colors.grey[400]!,
                                        textSize: TextSizes.fourteen,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: const BorderSide(color: colorGreenSemiLight, width: 1.5),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.email_outlined,
                                        color: colorGreenSemiLight,
                                        size: 20,
                                      ),
                                    ),
                                    onChanged: (value) {
                                      _.checkForm();
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Nous utiliserons cette adresse pour vous contacter',
                                    style: TextStyles.montserratRegular(
                                      textSize: TextSizes.twelve,
                                      textColor: Colors.grey[600]!,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Section d'objet du problème
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Objet du problème',
                                    style: TextStyles.montserratSemiBold(
                                      textColor: colorGreenSemiLight,
                                      textSize: TextSizes.fifteen,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  _.isReportProblemTypeProcessing.isTrue
                                      ? const ShimmerPrice(height: 50)
                                      : const ReportProblemTypeFilter(),
                                ],
                              ),
                            ),

                            // Section de description du problème
                            Container(
                              margin: const EdgeInsets.only(bottom: 24),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Description',
                                    style: TextStyles.montserratSemiBold(
                                      textColor: colorGreenSemiLight,
                                      textSize: TextSizes.fifteen,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  const ReportProblemDescriptionWidget(),
                                ],
                              ),
                            ),

                            // Bouton d'envoi
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.only(bottom: 40),
                              height: 54,
                              child: CustomButton(
                                text: 'Envoyer',
                                borderRadius: 12,
                                textSize: TextSizes.sixteen,
                                bgcolor: _.isValidForm.isTrue
                                    ? colorGreenSemiLight
                                    : Colors.grey[300]!,
                                borderColor: _.isValidForm.isTrue
                                    ? colorGreenSemiLight
                                    : Colors.grey[300]!,
                                textColor: _.isValidForm.isTrue
                                    ? colorWhite
                                    : Colors.grey[500]!,
                                actionColor: colorGreenSemiLight.withValues(alpha: 0.8),
                                enabled: _.isValidForm.value,
                                action: () {
                                  _.doSendReportProblem();
                                },
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
          ),
        );
      }),
    );
  }
}