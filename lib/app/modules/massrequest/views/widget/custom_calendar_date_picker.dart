import 'package:flutter/material.dart';

class CustomCalendarDatePicker extends StatelessWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final Function(DateTime) onDateChanged;
  final bool Function(DateTime) selectableDayPredicate;

  const CustomCalendarDatePicker({Key? key,
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onDateChanged,
    required this.selectableDayPredicate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: GestureDetector(
        onTapUp: (TapUpDetails details) {
          _handleTap(context, details.globalPosition);
        },
        child: CalendarDatePicker(
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: lastDate,
          onDateChanged: onDateChanged,
          selectableDayPredicate: selectableDayPredicate,
        ),
      ),
    );
  }

  void _handleTap(BuildContext context, Offset globalPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPosition = box.globalToLocal(globalPosition);
    final DateTime? tappedDate = _hitTestCalendar(context, localPosition);
    if (tappedDate != null) {
      onDateChanged(tappedDate);
    }
  }

  DateTime? _hitTestCalendar(BuildContext context, Offset localPosition) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final size = box.size;
    final double cellWidth = size.width / 7;
    final double cellHeight = (size.height - 100) / 6; // Approximation

    final int col = (localPosition.dx / cellWidth).floor();
    final int row = ((localPosition.dy - 100) / cellHeight).floor();

    if (row < 0 || row >= 6 || col < 0 || col >= 7) return null;

    final int daysToAdd = row * 7 + col - (initialDate.weekday - 1);
    return DateTime(initialDate.year, initialDate.month, 1).add(Duration(days: daysToAdd));
  }
}