import 'package:flutter/material.dart';
import 'package:oremusapp/app/commons/timeline/flutter_timeline.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:intl/intl.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';

class MassRequestStatusTimeline extends StatelessWidget {
  final List<MassRequestStatusData> statusHistory;
  final List<MassRequestAvailablesStatusesData> availableStatuses;

  const MassRequestStatusTimeline({
    Key? key,
    required this.statusHistory,
    required this.availableStatuses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Organiser les statuts disponibles par code pour faciliter la recherche
    Map<String, MassRequestAvailablesStatusesData> statusesMap = {};
    for (var status in availableStatuses) {
      statusesMap[status.code ?? ''] = status;
    }

    // Trier l'historique des statuts par date (du plus ancien au plus récent)
    List<MassRequestStatusData> sortedHistory = List.from(statusHistory);
    sortedHistory.sort((a, b) =>
        DateTime.parse(a.createdAt ?? '').compareTo(DateTime.parse(b.createdAt ?? '')));

    // Calculer les statuts futurs potentiels (pas encore atteints)
    String currentStatusCode = sortedHistory.last.status?.code ?? '';
    List<String> possibleNextStatuses = _getPossibleNextStatuses(
        currentStatusCode,
        statusesMap
    );

    return TimelineTheme(
      data: TimelineThemeData(
        lineColor: Colors.grey[300]!,
        itemGap: 24.0,
      ),
      child: Timeline(
        indicatorSize: 28,
        isLeftAligned: true,
        events: _buildTimelineEvents(sortedHistory, statusesMap, possibleNextStatuses),
      ),
    );
  }

  List<TimelineEventDisplay> _buildTimelineEvents(
      List<MassRequestStatusData> sortedHistory,
      Map<String, MassRequestAvailablesStatusesData> statusesMap,
      List<String> possibleNextStatuses
      ) {
    List<TimelineEventDisplay> events = [];

    // Ajouter les statuts déjà atteints
    for (var i = 0; i < sortedHistory.length; i++) {
      var statusEvent = sortedHistory[i];
      bool isLatestStatus = i == sortedHistory.length - 1;

      events.add(
        TimelineEventDisplay(
          child: _buildStatusItem(
            statusEvent.status?.name?.fr ?? '',
            statusEvent.createdAt,
            isCompleted: true,
            isLatest: isLatestStatus,
          ),
          indicator: _buildStatusIndicator(
            isCompleted: true,
            isLatest: isLatestStatus,
          ),
        ),
      );
    }

    // Ajouter les statuts futurs potentiels (grisés)
    for (var nextStatusCode in possibleNextStatuses) {
      var nextStatus = statusesMap[nextStatusCode];
      if (nextStatus != null) {
        events.add(
          TimelineEventDisplay(
            child: _buildStatusItem(
              nextStatus.name?.fr ?? '',
              null,
              isCompleted: false,
              isLatest: false,
            ),
            indicator: _buildStatusIndicator(
              isCompleted: false,
              isLatest: false,
            ),
          ),
        );
      }
    }

    return events;
  }

  Widget _buildStatusIndicator({
    required bool isCompleted,
    required bool isLatest,
  }) {
    Color indicatorColor = isCompleted
        ? (isLatest ? colorGreenSemiLight : Colors.grey[400]!)
        : Colors.grey[300]!;

    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: indicatorColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: isLatest
            ? [
          BoxShadow(
            color: colorGreenSemiLight.withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 1,
          )
        ]
            : null,
      ),
      child: isCompleted
          ? const Icon(
        Icons.check,
        size: 14,
        color: Colors.white,
      )
          : null,
    );
  }

  Widget _buildStatusItem(
      String statusName,
      String? dateStr,
      {
        required bool isCompleted,
        required bool isLatest,
      }
      ) {
    // Formatter la date si elle existe
    String formattedDate = '';
    if (dateStr != null) {
      DateTime date = DateTime.parse(dateStr);
      formattedDate = DateFormat('dd MMM yyyy à HH:mm').format(date);
    }

    return Container(
      margin: const EdgeInsets.only(left: 12, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom du statut
          Text(
            statusName,
            style: TextStyles.montserratSemiBold(
              textSize: TextSizes.fifteen,
              textColor: isCompleted
                  ? (isLatest ? colorGreenSemiLight : colorBlack)
                  : Colors.grey[500]!,
            ),
          ),

          // Date (si disponible)
          if (dateStr != null) ...[
            const SizedBox(height: 4),
            Text(
              formattedDate,
              style: TextStyles.montserratRegular(
                textSize: TextSizes.thirteen,
                textColor: Colors.grey[600]!,
              ),
            ),
          ],

          // Badge "En cours" pour le statut actuel
          if (isLatest) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: colorGreenSemiLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorGreenSemiLight.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Text(
                'En cours',
                style: TextStyles.montserratSemiBold(
                  textSize: TextSizes.eleven,
                  textColor: colorGreenSemiLight,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Logique pour déterminer les statuts futurs possibles en fonction du statut actuel
  List<String> _getPossibleNextStatuses(
      String currentStatusCode,
      Map<String, MassRequestAvailablesStatusesData> statusesMap
      ) {
    switch (currentStatusCode) {
      case 'REQUEST_INITIATED':
        return ['REQUEST_PAID'];
      case 'REQUEST_PAID':
        return ['REQUEST_ACCEPTED', 'REQUEST_REFUSED'];
      case 'REQUEST_ACCEPTED':
        return ['REQUEST_ASSUMED'];
      case 'REQUEST_ASSUMED':
      // Statut final, pas d'étapes suivantes
        return [];
      case 'REQUEST_REFUSED':
      // Statut final, pas d'étapes suivantes
        return [];
      default:
        return [];
    }
  }
}
