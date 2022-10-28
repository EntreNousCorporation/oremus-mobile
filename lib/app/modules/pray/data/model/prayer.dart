import 'package:oremusapp/app/modules/paroisse/data/model/place_response.dart';

class Prayer {
  dynamic identifier;
  String? code;
  TranslateContent? title;
  TranslateContent? content;

  bool? isExpand = false;

  Prayer({
    this.identifier,
    this.code,
    this.title,
    this.content,
    this.isExpand,
  });

  Prayer.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    code = json['code'];
    content = json['content'] != null
        ? TranslateContent.fromJson(json['content'])
        : null;
    title = json['title'] != null
        ? TranslateContent.fromJson(json['title'])
        : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['code'] = code;
    data['description'] = content?.toJson();
    data['title'] = title?.toJson();
    return data;
  }
}
