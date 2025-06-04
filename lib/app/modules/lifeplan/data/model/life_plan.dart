import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/remote/to_json_interface.dart';

import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/remote/to_json_interface.dart';

class LifePlan extends ToJsonInterface {
  final int? identifier;
  final String? code;
  final Translate? name;
  final List<TimeSlot>? slots;

  LifePlan({
    this.identifier,
    this.code,
    this.name,
    this.slots,
  });

  factory LifePlan.fromJson(Map<String, dynamic> json) {
    List<TimeSlot>? parsedSlots;

    // Gérer les slots qui peuvent être soit des strings soit des objets
    if (json['slots'] != null) {
      parsedSlots = [];
      for (var slot in json['slots']) {
        if (slot is String) {
          // Format "HH:mm:ss" depuis l'API
          parsedSlots.add(TimeSlot.fromString(slot));
        } else if (slot is Map<String, dynamic>) {
          // Format objet
          parsedSlots.add(TimeSlot.fromJson(slot));
        }
      }
    }

    return LifePlan(
      identifier: json['identifier'],
      code: json['code'],
      name: json['name'] != null ? Translate.fromJson(json['name']) : null,
      slots: parsedSlots,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'code': code,
      'name': name?.toJson(),
      'slots': slots?.map((e) => e.toJson()).toList(),
    };
  }
}

class TimeSlot extends ToJsonInterface {
  final int? hour;
  final int? minute;
  final int? second;
  final int? nano;

  TimeSlot({
    this.hour,
    this.minute,
    this.second,
    this.nano,
  });

  // Constructeur pour créer un TimeSlot depuis une string "HH:mm:ss"
  factory TimeSlot.fromString(String timeString) {
    final parts = timeString.split(':');
    return TimeSlot(
      hour: parts.isNotEmpty ? int.tryParse(parts[0]) ?? 0 : 0,
      minute: parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0,
      second: parts.length > 2 ? int.tryParse(parts[2]) ?? 0 : 0,
      nano: 0,
    );
  }

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      hour: json['hour'],
      minute: json['minute'],
      second: json['second'],
      nano: json['nano'],
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
      'second': second,
      'nano': nano,
    };
  }

  String getFormattedTime() {
    final h = hour?.toString().padLeft(2, '0') ?? '00';
    final m = minute?.toString().padLeft(2, '0') ?? '00';
    return '$h:$m';
  }

  // Méthode pour trier les créneaux
  int compareTo(TimeSlot other) {
    final thisMinutes = (hour ?? 0) * 60 + (minute ?? 0);
    final otherMinutes = (other.hour ?? 0) * 60 + (other.minute ?? 0);
    return thisMinutes.compareTo(otherMinutes);
  }
}