import 'package:flutter/material.dart';
import 'package:flutter_animator/flutter_animator.dart';
import 'package:get/get.dart';
import 'package:oremusapp/app/commons/components/lottie_loader_widget.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/modules/massrequesthistory/controller/mass_request_history_detail_controller.dart';
import 'package:oremusapp/app/modules/massrequesthistory/views/widget/mass_request_status_timeline.dart';

class MassRequestStateView extends StatelessWidget {
  const MassRequestStateView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetX<MassRequestHistoryDetailController>(
      builder: (controller) {
        if (controller.isDataProcessing.isTrue) {
          return Center(
            child: LottieLoadingView(size: Get.width / 6),
          );
        } else if (controller.massRequestStatuses.isEmpty) {
          return _buildEmptyState();
        } else {
          return FadeIn(
            child: MassRequestStatusTimeline(
              statusHistory: controller.massRequestStatuses,
              availableStatuses: controller.availableStatuses,
            ),
          );
        }
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(
            Icons.history_toggle_off_rounded,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun historique de statut disponible',
            style: TextStyles.montserratSemiBold(
              textSize: TextSizes.fourteen,
              textColor: Colors.grey[600]!,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
