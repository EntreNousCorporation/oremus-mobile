import 'package:oremusapp/app/modules/paroisse/data/model/liturgical_celebration_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/modules/profile/data/model/profile.dart';
import 'package:oremusapp/app/remote/to_json_interface.dart';

class MassRequestResponse extends ToJsonInterface {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? startDate;
  String? traceId;
  dynamic price;
  String? endDate;
  String? prayerIntent;
  WorshipPlace? worshipPlace;
  List<PriceData>? bookings;
  Status? status;
  Status? typeOfMassRequest;
  Profile? user;

  String? paymentUrl;
  String? paymentStatus;
  String? paymentId;
  String? transactionId;

  MassRequestResponse({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.startDate,
    this.traceId,
    this.price,
    this.endDate,
    this.prayerIntent,
    this.worshipPlace,
    this.status,
    this.typeOfMassRequest,
    this.user,
    this.paymentUrl,
    this.paymentStatus,
    this.paymentId,
    this.transactionId,
    this.bookings,
  });

  MassRequestResponse.fromJson(Map<String, dynamic> json) {
    paymentUrl = json['paymentUrl'];
    paymentStatus = json['paymentStatus'];
    paymentId = json['paymentId'];
    transactionId = json['transactionId'];

    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    startDate = json['startDate'];
    traceId = json['traceId'];
    price = json['price'];
    endDate = json['endDate'];
    prayerIntent = json['prayerIntent'];
    worshipPlace = json['worshipPlace'] != null
        ? WorshipPlace.fromJson(json['worshipPlace'])
        : null;
    status = json['status'] != null ? Status.fromJson(json['status']) : null;
    typeOfMassRequest = json['typeOfMassRequest'] != null
        ? Status.fromJson(json['typeOfMassRequest'])
        : null;
    user = json['user'] != null ? Profile.fromJson(json['user']) : null;
    if (json['bookings'] != null) {
      bookings = <PriceData>[];
      json['bookings'].forEach((v) {
        bookings?.add(PriceData.fromJson(v));
      });
    }
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['paymentUrl'] = paymentUrl;
    data['paymentStatus'] = paymentStatus;
    data['paymentId'] = paymentId;
    data['transactionId'] = transactionId;

    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['startDate'] = startDate;
    data['traceId'] = traceId;
    data['price'] = price;
    data['endDate'] = endDate;
    data['prayerIntent'] = prayerIntent;
    if (worshipPlace != null) {
      data['worshipPlace'] = worshipPlace?.toJson();
    }
    if (status != null) {
      data['status'] = status!.toJson();
    }
    if (typeOfMassRequest != null) {
      data['typeOfMassRequest'] = typeOfMassRequest?.toJson();
    }
    if (user != null) {
      data['user'] = user?.toJson();
    }
    if (bookings != null) {
      data['bookings'] = bookings?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class MassRequestData {
  String? prayerIntent;
  int? worshipPlace;
  String? typeOfMassRequest;
  List<PriceData?>? slots;
  bool? forceDuplicateCreation;

  MassRequestData({
    this.prayerIntent,
    this.worshipPlace,
    this.typeOfMassRequest,
    this.slots,
    this.forceDuplicateCreation,
  });

  MassRequestData.fromJson(Map<String, dynamic> json) {
    prayerIntent = json['prayerIntent'];
    worshipPlace = json['worshipPlace'];
    typeOfMassRequest = json['typeOfMassRequest'];
    forceDuplicateCreation = json['forceDuplicateCreation'];
    if (json['slots'] != null) {
      slots = <PriceData>[];
      json['slots'].forEach((v) {
        slots?.add(PriceData.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['prayerIntent'] = prayerIntent;
    data['worshipPlace'] = worshipPlace;
    data['typeOfMassRequest'] = typeOfMassRequest;
    data['forceDuplicateCreation'] = forceDuplicateCreation;
    if (slots != null) {
      data['slots'] = slots?.map((v) => v?.toJson()).toList();
    }
    return data;
  }
}

class WorshipPlace {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? name;
  String? massInfo;
  dynamic massRequestPrice;
  String? status;
  Typee? type;
  String? description;
  Address? address;
  Diocese? diocese;
  String? parent;
  Localisation? localisation;
  CoverImage? coverImage;

  WorshipPlace({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.name,
    this.massInfo,
    this.massRequestPrice,
    this.status,
    this.type,
    this.description,
    this.address,
    this.diocese,
    this.parent,
    this.localisation,
    this.coverImage,
  });

  WorshipPlace.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    name = json['name'];
    massInfo = json['massInfo'];
    massRequestPrice = json['massRequestPrice'];
    status = json['status'];
    type = json['type'] != null ? Typee.fromJson(json['type']) : null;
    description = json['description'];
    address =
        json['address'] != null ? Address.fromJson(json['address']) : null;
    diocese =
        json['diocese'] != null ? Diocese.fromJson(json['diocese']) : null;
    parent = json['parent'];
    localisation = json['localisation'] != null
        ? Localisation.fromJson(json['localisation'])
        : null;
    coverImage = json['coverImage'] != null
        ? CoverImage.fromJson(json['coverImage'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['name'] = name;
    data['massInfo'] = massInfo;
    data['massRequestPrice'] = massRequestPrice;
    data['status'] = status;
    if (type != null) {
      data['type'] = type?.toJson();
    }
    data['description'] = description;
    if (address != null) {
      data['address'] = address?.toJson();
    }
    if (diocese != null) {
      data['diocese'] = diocese?.toJson();
    }
    data['parent'] = parent;
    if (localisation != null) {
      data['localisation'] = localisation?.toJson();
    }
    if (coverImage != null) {
      data['coverImage'] = coverImage?.toJson();
    }
    return data;
  }
}

class Typee {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? code;
  Translate? translate;

  Typee({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.code,
    this.translate,
  });

  Typee.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    code = json['code'];
    translate = json['translate'] != null
        ? Translate.fromJson(json['translate'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['code'] = code;
    if (translate != null) {
      data['translate'] = translate!.toJson();
    }
    return data;
  }
}

class Translate {
  dynamic identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? fr;
  String? en;

  Translate({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.fr,
    this.en,
  });

  Translate.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    fr = json['fr'];
    en = json['en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['fr'] = fr;
    data['en'] = en;
    return data;
  }
}

class Status {
  String? code;
  Translate? name;

  Status({this.code, this.name});

  Status.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'] != null ? Translate.fromJson(json['name']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (name != null) {
      data['name'] = name!.toJson();
    }
    return data;
  }
}

class TypeData {
  String? code;
  Name? name;
  Name? template;

  TypeData({
    this.code,
    this.name,
    this.template,
  });

  TypeData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'] != null ? Name.fromJson(json['name']) : null;
    template =
        json['template'] != null ? Name.fromJson(json['template']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (name != null) {
      data['name'] = name?.toJson();
    }
    if (template != null) {
      data['template'] = template?.toJson();
    }
    return data;
  }
}

class MassTypeRepetitionData {
  String? code;
  String? name;

  MassTypeRepetitionData({
    this.code,
    this.name,
  });

  MassTypeRepetitionData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    name = json['name'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['name'] = name;
    return data;
  }
}

class PrayerIntentData {
  String? code;
  Name? defaultText;

  PrayerIntentData({this.code, this.defaultText});

  PrayerIntentData.fromJson(Map<String, dynamic> json) {
    code = json['code'];
    defaultText =
        json['defaultText'] != null ? Name.fromJson(json['defaultText']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    if (defaultText != null) {
      data['defaultText'] = defaultText?.toJson();
    }
    return data;
  }
}

class Name {
  int? identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? fr;
  String? en;

  Name({
    this.identifier,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.modifiedBy,
    this.fr,
    this.en,
  });

  Name.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    fr = json['fr'];
    en = json['en'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['fr'] = fr;
    data['en'] = en;
    return data;
  }
}

class PriceResponse {
  dynamic price;

  PriceResponse({
    this.price,
  });

  PriceResponse.fromJson(Map<String, dynamic> json) {
    price = json['price'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['price'] = price;
    return data;
  }
}

class PriceData {
  String? dayOfWeek;
  String? day;
  String? dayToDisplay;
  String? celebrationType;
  String? name;
  bool? isDaySelected;
  bool? isSpecial;
  int? repeat;
  int? identifier;
  List<Slot>? slots;
  List<DateTime>? dates;

  PriceData({
    this.dayOfWeek,
    this.day,
    this.dayToDisplay,
    this.celebrationType,
    this.repeat,
    this.identifier,
    this.isDaySelected = false,
    this.isSpecial,
    this.slots,
    this.name,
    List<DateTime>? dates,
  }) : dates = dates ?? [];

  // Méthode pour cloner un PriceData avec une nouvelle date
  PriceData cloneWithDate(DateTime date) {
    return PriceData(
      dayOfWeek: dayOfWeek,
      repeat: repeat,
      slots: slots,
      name: name,
      day: day,
      dayToDisplay: dayToDisplay,
      celebrationType: celebrationType,
      identifier: identifier,
      dates: [date],
    );
  }

  PriceData.fromJson(Map<String, dynamic> json) {
    day = json['day'];
    dayToDisplay = json['dayToDisplay'];
    dayOfWeek = json['dayOfWeek'];
    isDaySelected = json['isDaySelected'];
    isSpecial = json['isSpecial'];
    celebrationType = json['celebrationType'];
    repeat = json['repeat'];
    name = json['name'];
    identifier = json['identifier'];
    if (json['slots'] != null) {
      slots = <Slot>[];
      json['slots'].forEach((v) {
        slots?.add(Slot.fromJson(v));
      });
    }
    // Parsing des dates
    if (json['dates'] != null) {
      dates = <DateTime>[];
      json['dates'].forEach((v) {
        dates?.add(DateTime.parse(v)); // Assure que la date est parsée correctement
      });
    } else {
      dates = [];
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['day'] = day;
    data['dayToDisplay'] = dayToDisplay;
    data['dayOfWeek'] = dayOfWeek;
    data['isDaySelected'] = isDaySelected;
    data['celebrationType'] = celebrationType;
    data['repeat'] = repeat;
    data['name'] = name;
    data['identifier'] = identifier;
    if (slots != null) {
      data['slots'] = slots?.map((v) => v.toJson()).toList();
    }
    if (dates != null) {
      data['dates'] = dates?.map((date) => date.toIso8601String()).toList();
    }
    return data;
  }
}

class StartTime {
  int? hour;
  int? minute;
  int? second;
  int? nano;

  StartTime({this.hour, this.minute, this.second, this.nano});

  StartTime.fromJson(Map<String, dynamic> json) {
    hour = json['hour'];
    minute = json['minute'];
    second = json['second'];
    nano = json['nano'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['hour'] = hour;
    data['minute'] = minute;
    data['second'] = second;
    data['nano'] = nano;
    return data;
  }
}

class MassRequestStatusData {
  int? identifier;
  String? createdAt;
  String? updatedAt;
  String? createdBy;
  String? modifiedBy;
  String? traceId;
  int? massRequestId;
  Status? status;

  MassRequestStatusData(
      {this.identifier,
      this.createdAt,
      this.updatedAt,
      this.createdBy,
      this.modifiedBy,
      this.traceId,
      this.massRequestId,
      this.status});

  MassRequestStatusData.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    createdAt = json['createdAt'];
    updatedAt = json['updatedAt'];
    createdBy = json['createdBy'];
    modifiedBy = json['modifiedBy'];
    traceId = json['traceId'];
    massRequestId = json['massRequestId'];
    status = json['status'] != null ? Status.fromJson(json['status']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['createdBy'] = createdBy;
    data['modifiedBy'] = modifiedBy;
    data['traceId'] = traceId;
    data['massRequestId'] = massRequestId;
    if (status != null) {
      data['status'] = status?.toJson();
    }
    return data;
  }
}
