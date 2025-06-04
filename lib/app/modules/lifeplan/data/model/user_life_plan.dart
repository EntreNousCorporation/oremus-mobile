import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';
import 'package:oremusapp/app/modules/signin/data/model/signin_response.dart';
import 'package:oremusapp/app/remote/to_json_interface.dart';

class UserLifePlan extends ToJsonInterface {
  final int? identifier;
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;
  final String? modifiedBy;
  final SigninResponse? user;
  final LifePlan? lifePlan;
  final List<TimeSlot>? slots;

  UserLifePlan({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.user,
    this.lifePlan,
    this.slots,
  });

  factory UserLifePlan.fromJson(Map<String, dynamic> json) {
    List<TimeSlot>? parsedSlots;

    // Gérer les slots qui peuvent être soit des strings soit des objets
    if (json['slots'] != null) {
      parsedSlots = [];
      for (var slot in json['slots']) {
        if (slot is String) {
          parsedSlots.add(TimeSlot.fromString(slot));
        } else if (slot is Map<String, dynamic>) {
          parsedSlots.add(TimeSlot.fromJson(slot));
        }
      }
    }

    return UserLifePlan(
      identifier: json['identifier'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      createdBy: json['createdBy'],
      modifiedBy: json['modifiedBy'],
      user: json['user'] != null ? SigninResponse.fromJson(json['user']) : null,
      lifePlan: json['lifePlan'] != null ? LifePlan.fromJson(json['lifePlan']) : null,
      slots: parsedSlots,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'identifier': identifier,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'createdBy': createdBy,
      'modifiedBy': modifiedBy,
      'user': user?.toJson(),
      'lifePlan': lifePlan?.toJson(),
      'slots': slots?.map((e) => e.toJson()).toList(),
    };
  }
}