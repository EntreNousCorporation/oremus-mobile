import 'package:oremusapp/app/remote/to_json_interface.dart';

class FavoriteData extends ToJsonInterface {
  dynamic userId;
  dynamic worshipPlaceId;

  FavoriteData({
    this.userId,
    this.worshipPlaceId,
  });

  FavoriteData.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    worshipPlaceId = json['worshipPlaceId'];
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userId'] = userId;
    data['worshipPlaceId'] = worshipPlaceId;
    return data;
  }
}
