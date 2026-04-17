import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/image_displayer.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequest/controller/mass_request_recap_controller.dart';
import 'package:oremusapp/app/modules/payment/data/model/payment_status_data.dart';
import 'package:oremusapp/generated/assets.dart';

class PaymentMethodFilter extends StatelessWidget {
  const PaymentMethodFilter({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MassRequestRecapController>(builder: (logic) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Mode de paiement',
            style: TextStyles.montserratSemiBold(
              textColor: colorBlack,
              textSize: TextSizes.fourteen,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 100,
            child: logic.paymentMethods.isEmpty
                ? Center(
                    child: Text(
                      'Chargement...',
                      style: TextStyles.montserratRegular(
                        textColor: colorGrey1,
                        textSize: TextSizes.fourteen,
                      ),
                    ),
                  )
                : ListView.separated(
              physics: const BouncingScrollPhysics(),
                    scrollDirection: Axis.horizontal,
                    itemCount: logic.paymentMethods.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final paymentMethod = logic.paymentMethods[index];
                      final isSelected =
                          logic.paymentMethodSelected.value?.code ==
                              paymentMethod.code;
                      return GestureDetector(
                        onTap: () {
                          logic.paymentMethodSelected.value = paymentMethod;
                          logic.checkForm();
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 90,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorGreen.withValues(alpha: 0.08)
                                : colorWhite,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: isSelected
                                  ? colorGreen
                                  : Colors.grey.withValues(alpha: 0.25),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              // Check icon
                              if (isSelected)
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: Container(
                                    width: 15,
                                    height: 15,
                                    decoration: const BoxDecoration(
                                      color: colorGreen,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.check,
                                      color: colorWhite,
                                      size: 14,
                                    ),
                                  ),
                                ),
                              // Content
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: SizedBox(
                                        height: 36,
                                        width: 36,
                                        child: CachedNetworkImage(
                                          imageUrl: paymentMethod.logo ?? '',
                                          fit: BoxFit.contain,
                                          errorWidget:
                                              (context, error, stackTrace) {
                                            return const ImageDisplayer(
                                              icon: Assets.imagesLogo,
                                              fit: BoxFit.contain,
                                            );
                                          },
                                          progressIndicatorBuilder:
                                              (context, child, loadingProgress) {
                                            return Center(
                                              child: SizedBox(
                                                width: 16,
                                                height: 16,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  value: loadingProgress
                                                              .progress !=
                                                          null
                                                      ? loadingProgress
                                                              .progress ??
                                                          0 /
                                                              loadingProgress
                                                                  .totalSize!
                                                      : null,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      paymentMethod.name?.fr ?? '-',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                      style: TextStyles.montserratMedium(
                                        textColor: isSelected
                                            ? colorGreen
                                            : colorBlack,
                                        textSize: TextSizes.twelve,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      );
    });
  }
}
