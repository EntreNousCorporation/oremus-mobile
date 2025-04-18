class RosaryFileData {
  int? identifier;
  String? bucketName;
  FileInfo? file;

  RosaryFileData({this.identifier, this.bucketName, this.file});

  RosaryFileData.fromJson(Map<String, dynamic> json) {
    identifier = json['identifier'];
    bucketName = json['bucketName'];
    file = json['file'] != null ? FileInfo.fromJson(json['file']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['identifier'] = identifier;
    data['bucketName'] = bucketName;
    if (file != null) {
      data['file'] = file!.toJson();
    }
    return data;
  }
}

class FileInfo {
  String? name;
  String? link;

  FileInfo({this.name, this.link});

  FileInfo.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    link = json['link'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['name'] = name;
    data['link'] = link;
    return data;
  }
}