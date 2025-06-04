class CreateLifePlanRequest {
  final String code;
  final List<String> slots;

  CreateLifePlanRequest({
    required this.code,
    required this.slots,
  });

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'slots': slots,
    };
  }
}

// Nouveau modèle pour la mise à jour (PUT)
class UpdateLifePlanRequest {
  final List<String> slots;

  UpdateLifePlanRequest({
    required this.slots,
  });

  Map<String, dynamic> toJson() {
    return {
      'slots': slots,
    };
  }
}

// Classe utilitaire pour convertir TimeSlot en String
class TimeSlotRequest {
  final int hour;
  final int minute;
  final int second;
  final int nano;

  TimeSlotRequest({
    required this.hour,
    required this.minute,
    this.second = 0,
    this.nano = 0,
  });

  // Convertit en format string "HH:mm:ss" attendu par l'API
  String toTimeString() {
    final h = hour.toString().padLeft(2, '0');
    final m = minute.toString().padLeft(2, '0');
    final s = second.toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  Map<String, dynamic> toJson() {
    return {
      'hour': hour,
      'minute': minute,
      'second': second,
      'nano': nano,
    };
  }
}
