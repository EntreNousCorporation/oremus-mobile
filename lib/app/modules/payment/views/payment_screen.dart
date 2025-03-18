import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:keyboard_dismisser/keyboard_dismisser.dart';
import 'package:oremusapp/app/commons/enums.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/modules/payment/controller/payment_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PaymentScreen extends StatelessWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return KeyboardDismisser(
      child: Scaffold(
        backgroundColor: colorWhite,
        body: PopScope(
          canPop: false,
          child: GetX<PaymentController>(builder: (logic) {
            return Column(
              children: [
                // Header avec design amélioré
                SizedBox(height: MediaQuery.of(context).padding.top),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Bouton retour avec animation
                          Container(
                            decoration: BoxDecoration(
                              color: colorGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: IconButton(
                              onPressed: () {
                                logic.doBack();
                              },
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: colorGreen,
                                size: 22,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Titre avec style amélioré
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Paiement sécurisé',
                                  style: TextStyles.montserratBold(
                                    textSize: TextSizes.eighteen,
                                    textColor: colorBlack,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getPaymentTypeText(logic),
                                  style: TextStyles.montserratRegular(
                                    textSize: TextSizes.thirteen,
                                    textColor: Colors.grey[600]!,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Indicateur de sécurité
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.lock_outline_rounded,
                                  color: colorGreen,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Sécurisé',
                                  style: TextStyles.montserratMedium(
                                    textSize: TextSizes.twelve,
                                    textColor: colorGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Indicateur de progression (visible uniquement pendant le chargement)
                      logic.isDataProcessing.value
                          ? Container(
                        margin: const EdgeInsets.only(top: 16, bottom: 4),
                        child: LinearProgressIndicator(
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(colorGreen),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      )
                          : const SizedBox(height: 4),
                    ],
                  ),
                ),

                // Contenu WebView avec indicateur de chargement
                Expanded(
                  child: Stack(
                    children: [
                      // WebView
                      WebViewWidget(controller: logic.webViewController.value),

                      // Overlay de chargement
                      logic.isDataProcessing.value
                          ? Container(
                        color: Colors.white,
                        width: double.infinity,
                        height: double.infinity,
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              LottieLoadingView(size: 120),
                              const SizedBox(height: 20),
                              Text(
                                'Préparation de votre paiement...',
                                style: TextStyles.montserratMedium(
                                  textSize: TextSizes.sixteen,
                                  textColor: colorGreen,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Veuillez patienter',
                                style: TextStyles.montserratRegular(
                                  textSize: TextSizes.fourteen,
                                  textColor: Colors.grey[600]!,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          : const SizedBox.shrink(),
                    ],
                  ),
                ),

                // Footer avec informations sur la sécurité
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.shield_outlined, color: colorGreen, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Paiement sécurisé par',
                        style: TextStyles.montserratRegular(
                          textSize: TextSizes.twelve,
                          textColor: Colors.grey[600]!,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Cinetpay',
                        style: TextStyles.montserratBold(
                          textSize: TextSizes.twelve,
                          textColor: colorGreen,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  // Fonction pour obtenir le texte descriptif en fonction du type de paiement
  String _getPaymentTypeText(PaymentController logic) {
    switch (logic.paymentType.value) {
      case PaymentType.donation:
        return "Finalisation de votre don";
      case PaymentType.massRequest:
        return "Paiement pour votre demande de messe";
      default:
        return "Finalisation de votre transaction";
    }
  }
}