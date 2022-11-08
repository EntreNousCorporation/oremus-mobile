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
      : super(code, message);
}

class BadRequestException extends CustomException {
  BadRequestException(code, message) : super(code, message);
}

class UnauthorisedException extends CustomException {
  UnauthorisedException(code, message) : super(code, message);
}

class ConflictedException extends CustomException {
  ConflictedException(code, message) : super(code, message);
}

class InvalidInputException extends CustomException {
  InvalidInputException(code, message) : super(code, message);
}

class InternalServerErrorException extends CustomException {
  InternalServerErrorException(code, message) : super(code, message);
}
