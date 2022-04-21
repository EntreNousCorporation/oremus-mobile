class CustomException implements Exception {
  final message;
  final code;

  CustomException(this.code, this.message);

  @override
  String toString() {
    return "$code: $message";
  }
}

class FetchDataException extends CustomException {
  FetchDataException(code, message)
      : super(message, "Error During Communication: ");
}

class BadRequestException extends CustomException {
  BadRequestException(code, message) : super(code, "Invalid Request: $message");
}

class UnauthorisedException extends CustomException {
  UnauthorisedException(code, message) : super(code, "Unauthorised: $message");
}

class InvalidInputException extends CustomException {
  InvalidInputException(code, message) : super(code, "Invalid Input: $message");
}