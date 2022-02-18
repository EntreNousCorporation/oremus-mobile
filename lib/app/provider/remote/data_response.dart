
import 'package:oremusapp/app/provider/remote/status.dart';
import 'package:oremusapp/app/provider/remote/to_json_interface.dart';

class DataResponse<T extends ToJsonInterface> extends Object {
  Status? status;
  bool? hasError;
  int? count;
  T? item;
  List<T?>? items;

  DataResponse({
    this.status,
    this.hasError,
    this.count,
    this.item,
    this.items,
  });

  factory DataResponse.fromJson(Map<String, dynamic> json) {
    List<T?>? _items = json['items'] == null
        ? null
        : json['items'].map<T?>((x) {
            switch (T) {
              /*
              case Activite:
                return Activite.fromJson(x) as T;
                */
              default:
                return null;
            }
          }).toList();

    return DataResponse(
        status: Status.fromJson(json['status']),
        hasError: json['hasError'],
        count: json['count'],
        //item: _item,
        items: _items);
  }

  Map<String, dynamic> toJson() {
    return {
      'hasError': hasError,
      'status': status?.toJson(),
      'count': count,
      //'item': this.item?.toJson(),
      'items': items != null
          ? List<T>.from(items!.map((x) => (x as ToJsonInterface).toJson()))
          : null,
    };
  }
}
