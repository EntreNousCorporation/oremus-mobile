import 'package:oremusapp/app/modules/donation/data/model/donation_response.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/life_plan.dart';
import 'package:oremusapp/app/modules/lifeplan/data/model/user_life_plan.dart';
import 'package:oremusapp/app/modules/massrequest/data/model/mass_request_response.dart';
import 'package:oremusapp/app/modules/massrequestclaim/data/model/claim_response.dart';
import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';
import 'package:oremusapp/app/remote/to_json_interface.dart';

class DataResponse<T extends ToJsonInterface> {
  dynamic count;
  dynamic page;
  dynamic pageSize;
  Pageable? pageable;
  dynamic totalPages;
  dynamic totalElements;
  bool? last;
  bool? first;
  dynamic numberOfElements;
  Sort? sort;
  dynamic number;
  dynamic size;
  bool? empty;
  T? content;
  List<T?>? contents;

  DataResponse({
    this.count,
    this.page,
    this.pageSize,
    this.pageable,
    this.totalPages,
    this.totalElements,
    this.last,
    this.first,
    this.numberOfElements,
    this.sort,
    this.number,
    this.size,
    this.empty,
    this.content,
    this.contents,
  });

  factory DataResponse.fromJson(Map<String, dynamic> json) {
    T? item;
    List<T?>? items;

    if (json['content'] != null) {
      if (json['content'] is List) {
        items = json['content'].map<T?>((x) {
          switch (T) {
            case MassRequestResponse:
              return MassRequestResponse.fromJson(x) as T;
            case ClaimData:
              return ClaimData.fromJson(x) as T;
            case ContentPlace:
              return ContentPlace.fromJson(x) as T;
            case DonationResponse:
              return DonationResponse.fromJson(x) as T;
            case LifePlan:
              return LifePlan.fromJson(x) as T;
            case UserLifePlan:
              return UserLifePlan.fromJson(x) as T;
            default:
              return null;
          }
        }).toList();
      } else {
        item = [json["content"]]
            .map<T?>((x) {
              switch (T) {
                case MassRequestResponse:
                  return MassRequestResponse.fromJson(x) as T;
                case ClaimData:
                  return ClaimData.fromJson(x) as T;
                case ContentPlace:
                  return ContentPlace.fromJson(x) as T;
                case DonationResponse:
                  return DonationResponse.fromJson(x) as T;
                case LifePlan:
                  return LifePlan.fromJson(x) as T;
                case UserLifePlan:
                  return UserLifePlan.fromJson(x) as T;
                default:
                  return null;
              }
            })
            .toList()
            .first;
      }
    }

    return DataResponse(
      count: json['count'],
      page: json['page'],
      pageSize: json['pageSize'],
      pageable: json['pageable'] is Map<String, dynamic>
          ? Pageable.fromJson(json['pageable'])
          : null,
      totalPages: json['totalPages'],
      totalElements: json['totalElements'],
      last: json['last'],
      first: json['first'],
      numberOfElements: json['numberOfElements'],
      sort: json['sort'] is Map<String, dynamic>
          ? Sort.fromJson(json['sort'])
          : null,
      number: json['number'],
      size: json['size'],
      empty: json['empty'],
      content: item,
      contents: items,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'page': page,
      'pageSize': pageSize,
      'pageable': pageable?.toJson(),
      'totalPages': totalPages,
      'last': last,
      'first': first,
      'numberOfElements': numberOfElements,
      'sort': sort?.toJson(),
      'number': number,
      'size': size,
      'empty': empty,
      'content': content?.toJson(),
      'contents': contents != null
          ? List<T>.from(contents!.map((x) => (x as ToJsonInterface).toJson()))
          : null,
    };
  }
}

class Pageable {
  Sort? sort;
  dynamic pageNumber;
  dynamic pageSize;
  dynamic offset;
  bool? paged;
  bool? unpaged;

  Pageable({
    this.sort,
    this.pageNumber,
    this.pageSize,
    this.offset,
    this.paged,
  });

  Pageable.fromJson(Map<String, dynamic> json) {
    sort = json['sort'] is Map<String, dynamic>
        ? Sort.fromJson(json['sort'])
        : null;
    pageNumber = json['pageNumber'];
    pageSize = json['pageSize'];
    offset = json['offset'];
    paged = json['paged'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['sort'] = sort?.toJson();
    data['pageNumber'] = pageNumber;
    data['pageSize'] = pageSize;
    data['offset'] = offset;
    data['paged'] = paged;
    return data;
  }
}

class Sort {
  bool? unsorted;
  bool? sorted;
  bool? empty;

  Sort({
    this.unsorted,
    this.sorted,
    this.empty,
  });

  Sort.fromJson(Map<String, dynamic> json) {
    unsorted = json['unsorted'];
    sorted = json['sorted'];
    empty = json['empty'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['unsorted'] = unsorted;
    data['sorted'] = sorted;
    data['empty'] = empty;
    return data;
  }
}
