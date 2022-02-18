
import 'package:oremusapp/app/provider/remote/to_json_interface.dart';

class Status  extends ToJsonInterface {
  String? message;
  String? code;

  Status({message, code});

  Status.fromJson(Map<String, dynamic> json) {
      message = json['message'];
      code = json['code'];

  }

  Map<String, dynamic> toJson() {
    return
      {
        'message': message,
        'code': code,
      };
  }
}
