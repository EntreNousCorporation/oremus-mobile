import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';

class ScheduleApiResponse {
  List<ContentPlace>? content;
  PageInfo? page;

  ScheduleApiResponse({this.content, this.page});

  ScheduleApiResponse.fromJson(Map<String, dynamic> json) {
    if (json['content'] != null) {
      content = <ContentPlace>[];
      json['content'].forEach((v) {
        content!.add(ContentPlace.fromJson(v));
      });
    }
    page = json['page'] != null ? PageInfo.fromJson(json['page']) : null;
  }
}

class PageInfo {
  int? size;
  int? number;
  int? totalElements;
  int? totalPages;

  PageInfo({this.size, this.number, this.totalElements, this.totalPages});

  PageInfo.fromJson(Map<String, dynamic> json) {
    size = json['size'];
    number = json['number'];
    totalElements = json['totalElements'];
    totalPages = json['totalPages'];
  }

  // Convertir vers le format DataResponse
  bool get isLast => (number != null && totalPages != null) ? ((number ?? 0) + 1) >= (totalPages ?? 0 ): true;
}