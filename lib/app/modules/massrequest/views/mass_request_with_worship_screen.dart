import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/components/button.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/constants.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/controller/mass_request_with_worship_controller.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/intent_type_description_with_worship_widget.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/mass_type_with_worship_filter.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/mass_without_repetition_filter.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/mass_without_worship_hour_filter.dart';
import 'package:oremusapp/app/modules/massrequest/views/widget/shimmer_price.dart';
import 'package:oremusapp/generated/assets.dart';

class MassRequestWithWorshipScreen extends StatelessWidget {
  const MassRequestWithWorshipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorGreen,
      child: GetX<MassRequestWithWorshipController>(builder: (_) {
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
                    // En-tête extensible avec image de couverture
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
                          bottomLeft: Radius.circular(24),
                          bottomRight: Radius.circular(24),
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
                            'Faire une demande de messe',
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
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
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
                              bottomLeft: Radius.circular(24),
                              bottomRight: Radius.circular(24),
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
                                        width: Get.width,
                                        height: Get.width,
                                        fit: BoxFit.cover,
                                      ),
                                )
                                    : Image.asset(
                                  Assets.imagesBgLogin,
                                  width: Get.width,
                                  height: Get.width,
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

                    // Formulaire de demande de messe
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 24,
                      ),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            // Section paroisse
                            _buildSectionTitle(
                              icon: Icons.church_outlined,
                              title: 'Choisir une paroisse',
                            ),
                            const SizedBox(height: 12),
                            _buildSelectionCard(
                              onTap: () {
                                _.goToWorshipChoice();
                              },
                              content: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      _.paroisseSelected.value.identifier == null
                                          ? 'Sélectionner une paroisse'
                                          : '${_.paroisseSelected.value.name}',
                                      style: TextStyles.montserratSemiBold(
                                        textColor: _.paroisseSelected.value.identifier == null
                                            ? colorGrey1
                                            : colorBlack,
                                        textSize: TextSizes.fifteen,
                                      ),
                                    ),
                                  ),
                                  Icon(
                                    _.paroisseSelected.value.identifier != null
                                        ? Icons.check_circle_outline_rounded
                                        : Icons.arrow_forward_ios_rounded,
                                    size: 22,
                                    color: _.paroisseSelected.value.identifier != null
                                        ? colorGreen
                                        : colorGrey1,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),

                            // Section type de demande
                            _buildSectionTitle(
                              icon: Icons.category_outlined,
                              title: 'Type de demande de messe',
                            ),
                            const SizedBox(height: 12),
                            _buildCard(
                              content: const MassTypeWithWorshipFilter(),
                            ),
                            const SizedBox(height: 24),

                            // Section répétition
                            _buildSectionTitle(
                              icon: Icons.repeat_outlined,
                              title: 'Répétition',
                            ),
                            const SizedBox(height: 12),
                            _buildCard(
                              content: const MassTypeWithoutRepetitionFilter(),
                            ),
                            const SizedBox(height: 24),

                            // Section dates multiples (conditionnelle)
                            if (_.massRequestTypeRepetitionSelected.value?.code == RepetitionType.many.name) ...[
                              _buildSelectionCard(
                                onTap: () {
                                  _.goToDatesChoice();
                                },
                                content: _.isDatesProcessing.isTrue
                                    ? const ShimmerPrice(height: 50)
                                    : Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Choisir les horaires de messe',
                                      style: TextStyles.montserratSemiBold(
                                        textColor: colorGrey1,
                                        textSize: TextSizes.fifteen,
                                      ),
                                    ),
                                    Icon(
                                      (_.datesChoosen.length > 1 &&
                                          _.massRequestTypeRepetitionSelected.value?.code == RepetitionType.many.name)
                                          ? Icons.check_circle
                                          : Icons.calendar_month,
                                      size: 22,
                                      color: _.worshipHours.isNotEmpty
                                          ? colorGreen
                                          : colorGrey1,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Section date unique (conditionnelle)
                            if (_.massRequestTypeRepetitionSelected.value?.code == RepetitionType.once.name) ...[
                              _buildSectionTitle(
                                icon: Icons.event_outlined,
                                title: 'Date et heure',
                              ),
                              const SizedBox(height: 12),
                              _buildCard(
                                content: Row(
                                  children: [
                                    // Date
                                    Expanded(
                                      flex: 2,
                                      child: GestureDetector(
                                        onTap: () {
                                          if (_.selectedDate.value == null) return;
                                          _.showPicker(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                            horizontal: 16,
                                          ),
                                          decoration: BoxDecoration(
                                            color: colorGreen.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color: _.selectedDate.value != null
                                                  ? colorGreen.withValues(alpha: 0.3)
                                                  : Colors.red.withValues(alpha: 0.3),
                                            ),
                                          ),
                                          child: _.isDatesProcessing.isTrue
                                              ? const ShimmerPrice(height: 24)
                                              : Row(
                                            children: [
                                              Icon(
                                                Icons.calendar_today_rounded,
                                                size: 20,
                                                color: _.selectedDate.value != null
                                                    ? colorGreen
                                                    : Colors.red,
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Text(
                                                  _.selectedDate.value?.dayToDisplay ?? 'Choisir une date',
                                                  style: TextStyles.montserratSemiBold(
                                                    textColor: _.selectedDate.value != null
                                                        ? colorBlack
                                                        : Colors.red,
                                                    textSize: TextSizes.fourteen,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    // Espace
                                    const SizedBox(width: 12),
                                    // Heure
                                    Expanded(
                                      child: Container(
                                        decoration: BoxDecoration(
                                          color: colorGreen.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: colorGreen.withValues(alpha: 0.3),
                                          ),
                                        ),
                                        child: const MassWithoutWorshipHourFilter(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 24),
                            ],

                            // Section intention de messe
                            _buildSectionTitle(
                              icon: Icons.message_outlined,
                              title: 'Intention de messe',
                            ),
                            const SizedBox(height: 12),
                            _buildCard(
                              content: const IntentTypeDescriptionWithWorshipWidget(),
                            ),
                            const SizedBox(height: 32),

                            // Section tarif
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: colorGreenlight2,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: _.isPricingProcessing.isTrue
                                  ? const ShimmerPrice(height: 50)
                                  : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: colorGreen.withValues(alpha: 0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.receipt_long_rounded,
                                      color: colorGreen,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Tarif',
                                        style: TextStyles.montserratMedium(
                                          textColor: colorGreySeparator,
                                          textSize: TextSizes.fourteen,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _.getPrice().value,
                                        style: TextStyles.montserratBold(
                                          textColor: colorBlack,
                                          textSize: TextSizes.twenty_four,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 32),

                            // Bouton continuer
                            CustomButton(
                              text: 'Continuer',
                              borderRadius: 12,
                              textSize: TextSizes.sixteen,
                              bgcolor: _.isValidForm.isTrue
                                  ? colorGreen
                                  : colorGrey1.withValues(alpha: 0.5),
                              borderColor: _.isValidForm.isTrue
                                  ? colorGreen
                                  : colorGreen.withValues(alpha: 0),
                              actionColor: colorGreen.withValues(alpha: 0.5),
                              enabled: _.isValidForm.value,
                              action: () {
                                _.doSendMassRequest();
                              },
                            ),
                            const SizedBox(height: 16),
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

  // Titre de section avec icône
  Widget _buildSectionTitle({required IconData icon, required String title}) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: colorGreenSemiLight.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: colorGreenSemiLight,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyles.montserratSemiBold(
            textColor: colorGrey1,
            textSize: TextSizes.fifteen,
          ),
        ),
      ],
    );
  }

  // Carte de base pour les contenus
  Widget _buildCard({required Widget content}) {
    return Container(
      decoration: BoxDecoration(
        color: colorWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: content,
    );
  }

  // Carte cliquable pour les sélections
  Widget _buildSelectionCard({required VoidCallback onTap, required Widget content}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: colorWhite,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: content,
      ),
    );
  }
}
