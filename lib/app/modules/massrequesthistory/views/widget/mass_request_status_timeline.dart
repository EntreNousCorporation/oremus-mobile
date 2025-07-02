import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:oremusapp/app/commons/theme/app_colors.dart';
import 'package:oremusapp/app/commons/theme/app_dimension.dart';
import 'package:oremusapp/app/commons/theme/app_text_theme.dart';
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

    // Créer un Set des codes de statuts déjà atteints pour éviter les doublons
    Set<String> achievedStatusCodes = sortedHistory
        .map((status) => status.status?.code ?? '')
        .toSet();

    // Calculer tous les statuts à venir selon le flow complet
    List<TimelineItemData> futureStatuses = _getAllFutureStatuses(
        sortedHistory.isNotEmpty ? sortedHistory.last.status?.code ?? '' : '',
        statusesMap,
        achievedStatusCodes
    );

    return _buildCustomTimeline(sortedHistory, statusesMap, futureStatuses);
  }

  Widget _buildCustomTimeline(
      List<MassRequestStatusData> sortedHistory,
      Map<String, MassRequestAvailablesStatusesData> statusesMap,
      List<TimelineItemData> futureStatuses
      ) {
    List<Widget> timelineItems = [];
    int totalItems = sortedHistory.length + futureStatuses.length;

    // Ajouter les statuts déjà atteints
    for (var i = 0; i < sortedHistory.length; i++) {
      var statusEvent = sortedHistory[i];
      bool isLatestStatus = i == sortedHistory.length - 1;
      String statusCode = statusEvent.status?.code ?? '';
      bool isLastItem = (i == totalItems - 1);

      timelineItems.add(
        _buildTimelineItem(
          indicator: _buildStatusIndicator(
            isCompleted: true,
            isLatest: isLatestStatus,
            statusCode: statusCode, // Passer le code de statut
          ),
          child: _buildStatusItem(
            statusEvent.status?.name?.fr ?? '',
            statusEvent.createdAt,
            isCompleted: true,
            isLatest: isLatestStatus,
            statusCode: statusCode,
          ),
          lineColor: colorGreenSemiLight, // Ligne verte pour les étapes passées
          showLine: !isLastItem,
        ),
      );
    }

    // Ajouter les statuts futurs
    for (var i = 0; i < futureStatuses.length; i++) {
      var futureStatus = futureStatuses[i];
      bool isLastItem = (sortedHistory.length + i == totalItems - 1);

      if (futureStatus.isParallel) {
        // Affichage spécial pour les statuts parallèles (Accepté/Refusé)
        timelineItems.add(
          _buildTimelineItem(
            indicator: _buildStatusIndicator(
              isCompleted: false,
              isLatest: false,
              statusCode: '', // Pas de code spécifique pour les statuts parallèles
            ),
            child: _buildParallelStatusItem(futureStatus.parallelStatuses!, statusesMap),
            lineColor: Colors.grey[300]!, // Ligne grise pour les étapes futures
            showLine: !isLastItem,
          ),
        );
      } else {
        // Affichage normal pour un statut unique
        var status = statusesMap[futureStatus.statusCode];
        if (status != null) {
          timelineItems.add(
            _buildTimelineItem(
              indicator: _buildStatusIndicator(
                isCompleted: false,
                isLatest: false,
                statusCode: futureStatus.statusCode ?? '',
              ),
              child: _buildStatusItem(
                status.name?.fr ?? '',
                null,
                isCompleted: false,
                isLatest: false,
                statusCode: futureStatus.statusCode ?? '',
              ),
              lineColor: Colors.grey[300]!, // Ligne grise pour les étapes futures
              showLine: !isLastItem,
            ),
          );
        }
      }
    }

    return Column(
      children: timelineItems,
    );
  }

  Widget _buildTimelineItem({
    required Widget indicator,
    required Widget child,
    required Color lineColor,
    required bool showLine,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Colonne avec l'indicateur et la ligne
        Column(
          children: [
            // Indicateur
            indicator,
            // Ligne de connexion
            if (showLine) ...[
              Container(
                width: 2,
                height: 48,
                color: lineColor,
              ),
            ],
          ],
        ),
        // Contenu à droite
        Expanded(child: child),
      ],
    );
  }

  Widget _buildStatusIndicator({
    required bool isCompleted,
    required bool isLatest,
    String statusCode = '',
  }) {
    // Vérifier si c'est un statut refusé
    bool isRefused = statusCode == 'REQUEST_REFUSED';

    Color indicatorColor;
    if (isCompleted) {
      indicatorColor = isRefused ? Colors.red[600]! : colorGreenSemiLight;
    } else {
      indicatorColor = Colors.grey[300]!;
    }

    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: indicatorColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: isLatest
            ? [
          BoxShadow(
            color: isRefused
                ? Colors.red.withValues(alpha: 0.3)
                : colorGreenSemiLight.withValues(alpha: 0.3),
            blurRadius: 6,
            spreadRadius: 1,
          )
        ]
            : null,
      ),
      child: isCompleted
          ? Icon(
        isRefused ? Icons.close : Icons.check, // Croix pour refusé, coche pour accepté
        size: 16,
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
        String statusCode = '',
      }
      ) {
    // Formatter la date si elle existe
    String formattedDate = '';
    if (dateStr != null) {
      DateTime date = DateTime.parse(dateStr);
      formattedDate = DateFormat('dd MMM yyyy à HH:mm').format(date);
    }

    // Vérifier si c'est un statut final
    bool isFinalStatus = statusCode == 'REQUEST_ACCEPTED' || statusCode == 'REQUEST_REFUSED';
    // Vérifier si c'est un statut refusé
    bool isRefused = statusCode == 'REQUEST_REFUSED';

    // Déterminer la couleur du texte
    Color textColor;
    if (isCompleted) {
      textColor = isRefused ? Colors.red[600]! : colorGreenSemiLight;
    } else {
      textColor = Colors.grey[500]!;
    }

    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom du statut
          Text(
            statusName,
            style: TextStyles.montserratSemiBold(
              textSize: TextSizes.fifteen,
              textColor: textColor,
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

          // Badge "En cours" pour le statut actuel (sauf pour les statuts finaux)
          if (isLatest && !isFinalStatus) ...[
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

  // Widget spécial pour afficher les statuts parallèles - OPTION 2 : badges discrets
  Widget _buildParallelStatusItem(
      List<String> parallelStatusCodes,
      Map<String, MassRequestAvailablesStatusesData> statusesMap
      ) {
    return Container(
      margin: const EdgeInsets.only(left: 16, bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prochaines étapes possibles',
            style: TextStyles.montserratSemiBold(
              textSize: TextSizes.fifteen,
              textColor: Colors.grey[500]!,
            ),
          ),
          const SizedBox(height: 12),
          // Affichage des badges discrets en ligne
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: parallelStatusCodes.map((statusCode) {
              var status = statusesMap[statusCode];
              if (status == null) return Container();

              bool isAccepted = statusCode == 'REQUEST_ACCEPTED';

              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Point discret
                  Container(
                    width: 4,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isAccepted ? Colors.green[400] : Colors.red[400],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Texte simple
                  Text(
                    status.name?.fr ?? '',
                    style: TextStyles.montserratMedium(
                      textSize: TextSizes.fourteen,
                      textColor: Colors.grey[600]!,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Calculer tous les statuts futurs selon le flow : Initié → Payé → Pris en charge → Accepté/Refusé
  List<TimelineItemData> _getAllFutureStatuses(
      String currentStatusCode,
      Map<String, MassRequestAvailablesStatusesData> statusesMap,
      Set<String> achievedStatusCodes
      ) {
    List<TimelineItemData> futureStatuses = [];

    // Flow complet : Initié → Payé → Pris en charge → Accepté/Refusé
    List<String> completeFlow = [
      'REQUEST_INITIATED',  // Initié
      'REQUEST_PAID',       // Payé
      'REQUEST_ASSUMED',    // Pris en charge
      // Accepté/Refusé seront gérés séparément comme statuts parallèles
    ];

    // Ajouter TOUS les statuts manquants du flow principal (pas seulement les suivants)
    for (String statusCode in completeFlow) {
      if (!achievedStatusCodes.contains(statusCode)) {
        futureStatuses.add(TimelineItemData(statusCode: statusCode));
      }
    }

    // Toujours ajouter les statuts finaux parallèles (Accepté/Refusé) s'ils ne sont pas encore atteints
    if (!achievedStatusCodes.contains('REQUEST_ACCEPTED') &&
        !achievedStatusCodes.contains('REQUEST_REFUSED')) {
      futureStatuses.add(TimelineItemData(
          isParallel: true,
          parallelStatuses: ['REQUEST_ACCEPTED', 'REQUEST_REFUSED']
      ));
    }

    return futureStatuses;
  }
}

// Classe helper pour gérer les statuts futurs
class TimelineItemData {
  final String? statusCode;
  final bool isParallel;
  final List<String>? parallelStatuses;

  TimelineItemData({
    this.statusCode,
    this.isParallel = false,
    this.parallelStatuses,
  });
}
