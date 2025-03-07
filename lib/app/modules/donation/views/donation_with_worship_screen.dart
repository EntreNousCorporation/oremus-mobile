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
import 'package:oremusapp/app/modules/donation/controller/donation_with_worship_controller.dart';
import 'package:oremusapp/app/modules/donation/views/widget/amount_without_worship_widget.dart';
import 'package:oremusapp/generated/assets.dart';

class DonationWithWorshipScreen extends StatelessWidget {
  const DonationWithWorshipScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: colorWhite,
      child: GetX<DonationWithWorshipController>(builder: (_) {
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
                    SliverAppBar(
                      expandedHeight: AppConstants.kExpandedHeight,
                      collapsedHeight: 100,
                      floating: false,
                      snap: false,
                      pinned: true,
                      backgroundColor: colorGreen,
                      elevation: 10,
                      shadowColor: colorGrey2.withValues(alpha: 0.8),
                      leading: IconButton(
                        onPressed: () {
                          Get.back();
                        },
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                      ),
                      flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,
                        title: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Faire un don',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: TextStyles.montserratBold(
                              textSize: TextSizes.eighteen,
                              textColor: colorWhite,
                            ),
                          ),
                        ),
                        background: Stack(
                          children: [
                            // Use either the parish image or default background
                            _.selectedEntityType.value == EntityType.worship.name &&
                                _.paroisseSelected.value.coverImage?.link?.isNotEmpty == true
                                ? CachedNetworkImage(
                              width: Get.width,
                              height: Get.width,
                              imageUrl: _.paroisseSelected.value.coverImage?.link ?? '',
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  LottieLoadingView(size: Get.width / 6),
                              errorWidget: (context, url, error) =>
                              const Icon(Icons.error),
                            )
                                : Image.asset(
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
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 24),
                      sliver: SliverList(
                        delegate: SliverChildListDelegate(
                          [
                            Separators.minimunVertical(),

                            // Entity selection section
                            Text(
                              'À qui souhaitez-vous faire un don ?',
                              style: TextStyles.montserratMedium(
                                textColor: colorGrey1,
                                textSize: TextSizes.sixteen,
                              ),
                            ),
                            Separators.customSizeVertical(16),

                            // Entity selection cards
                            Row(
                              children: [
                                // Oremus card
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _.selectEntityType(EntityType.oremus.name);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      decoration: BoxDecoration(
                                        color: _.selectedEntityType.value == EntityType.oremus.name
                                            ? colorGreen.withValues(alpha: 0.1)
                                            : colorWhite,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: _.selectedEntityType.value == EntityType.oremus.name
                                              ? colorGreen
                                              : colorGrey2,
                                          width: _.selectedEntityType.value == EntityType.oremus.name ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _.selectedEntityType.value == EntityType.oremus.name
                                                  ? colorGreen
                                                  : colorGrey2.withValues(alpha: 0.2),
                                            ),
                                            child: Icon(
                                              Icons.home_work_outlined,
                                              color: _.selectedEntityType.value == EntityType.oremus.name
                                                  ? colorWhite
                                                  : colorGrey1,
                                              size: 28,
                                            ),
                                          ),
                                          Separators.customSizeVertical(8),
                                          Text(
                                            'OREMUS',
                                            style: TextStyles.montserratBold(
                                              textColor: _.selectedEntityType.value == EntityType.oremus.name
                                                  ? colorGreen
                                                  : colorGrey1,
                                              textSize: TextSizes.fourteen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                // Paroisse card
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      _.selectEntityType(EntityType.worship.name);
                                    },
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 200),
                                      padding: const EdgeInsets.symmetric(vertical: 20),
                                      decoration: BoxDecoration(
                                        color: _.selectedEntityType.value == EntityType.worship.name
                                            ? colorGreen.withValues(alpha: 0.1)
                                            : colorWhite,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: _.selectedEntityType.value == EntityType.worship.name
                                              ? colorGreen
                                              : colorGrey2,
                                          width: _.selectedEntityType.value == EntityType.worship.name ? 2 : 1,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: _.selectedEntityType.value == EntityType.worship.name
                                                  ? colorGreen
                                                  : colorGrey2.withValues(alpha: 0.2),
                                            ),
                                            child: Icon(
                                              Icons.church_outlined,
                                              color: _.selectedEntityType.value == EntityType.worship.name
                                                  ? colorWhite
                                                  : colorGrey1,
                                              size: 28,
                                            ),
                                          ),
                                          Separators.customSizeVertical(8),
                                          Text(
                                            'PAROISSE',
                                            style: TextStyles.montserratBold(
                                              textColor: _.selectedEntityType.value == EntityType.worship.name
                                                  ? colorGreen
                                                  : colorGrey1,
                                              textSize: TextSizes.fourteen,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Separators.customSizeVertical(25),

                            // Parish selection section (visible only if paroisse is selected)
                            if (_.selectedEntityType.value == EntityType.worship.name)
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Choisir une paroisse',
                                    style: TextStyles.montserratMedium(
                                      textColor: colorGrey1,
                                      textSize: TextSizes.sixteen,
                                    ),
                                  ),
                                  Separators.customSizeVertical(8),
                                  GestureDetector(
                                    onTap: () {
                                      _.goToWorshipChoice();
                                    },
                                    child: Material(
                                      borderRadius: BorderRadius.circular(10.0),
                                      elevation: 4,
                                      color: colorWhite,
                                      shadowColor: colorGrey2.withValues(alpha: 0.5),
                                      child: Container(
                                        padding: const EdgeInsets.all(15),
                                        width: double.maxFinite,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            _.paroisseSelected.value.identifier == null
                                                ? Text(
                                              'Sélectionner une paroisse',
                                              style: TextStyles.montserratMedium(
                                                textColor: colorGrey1,
                                                textSize: TextSizes.fourteen,
                                              ),
                                            )
                                                : Text(
                                              '${_.paroisseSelected.value.name}',
                                              style: TextStyles.montserratBold(
                                                textColor: colorBlack,
                                                textSize: TextSizes.fourteen,
                                              ),
                                            ),
                                            Icon(
                                              _.paroisseSelected.value.identifier != null
                                                  ? Icons.edit
                                                  : Icons.arrow_drop_down_rounded,
                                              size: 25,
                                              color: colorGreen,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Separators.customSizeVertical(25),
                                ],
                              ),

                            // Amount section
                            Text(
                              'Montant (FCFA)',
                              style: TextStyles.montserratMedium(
                                textColor: colorGrey1,
                                textSize: TextSizes.sixteen,
                              ),
                            ),
                            Separators.customSizeVertical(8),
                            Material(
                              borderRadius: BorderRadius.circular(10.0),
                              elevation: 4,
                              color: colorWhite,
                              shadowColor: colorGrey2.withValues(alpha: 0.5),
                              child: const AmountWithoutWorshipWidget(),
                            ),
                            Separators.minimunVertical(),
                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 20, color: colorGreen),
                                Separators.customSizeHorizontal(4),
                                Text(
                                  'Le montant minimum est de 100 FCFA',
                                  style: TextStyles.montserratRegular(
                                    textColor: colorGrey1,
                                    textSize: TextSizes.fourteen,
                                  ),
                                ),
                              ],
                            ),
                            Separators.maximum1Vertical(),
                            Separators.normalVertical(),

                            // Submit button
                            Material(
                              borderRadius: BorderRadius.circular(10.0),
                              elevation: 4,
                              color: colorWhite,
                              shadowColor: colorGrey2.withValues(alpha: 0.5),
                              child: CustomButton(
                                text: 'Continuer',
                                borderRadius: 10,
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
                                  _.doSendDonation();
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