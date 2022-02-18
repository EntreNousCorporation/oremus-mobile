import 'package:oremusapp/app/provider/remote/to_json_interface.dart';

class DataRequest<T extends ToJsonInterface> {
  T? data;
  List<T>? datas;
  String? user;
  String? start;
  String? end;
  int? size;
  int? index;
  DataRequest({data, datas, user, size, start, end, index});

  factory DataRequest.fromJson(Map<String, dynamic> json) {
    return DataRequest(
      user: json['user'],
      size: json['size'],
      start: json['start'],
      end: json['end'],
      index: json['index'],
      data: json['data'],
      datas: json["datas"] == null
          ? null
          : List<T>.from(json["datas"].map((x) => x.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user,
      'size': size,
      'start': start,
      'end': end,
      'index': index,
      'data': data == null ? null : data?.toJson(),
      'datas': datas == null
          ? null
          : List<dynamic>.from(datas!.map((x) => x.toJson())),
    };
  }
}

class EmptyDataRequest extends ToJsonInterface {

  EmptyDataRequest();

  EmptyDataRequest.fromJson(Map<String, dynamic> json);

  @override
  Map<String, dynamic>? toJson() {
    final Map<String, dynamic>? data = <String, dynamic>{};
    return data;
  }
}
