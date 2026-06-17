import 'package:mycharacterlist/core/errors/app_exception.dart';
import 'package:mycharacterlist/core/errors/app_messages.dart';

abstract final class ErrorMapper {
  static String userMessage(
    Object error, {
    String fallback = AppMessages.unknownError,
  }) {
    if (error is AppException) {
      return error.message;
    }

    if (error is StateError) {
      return error.message;
    }

    if (error is FormatException && error.message.isNotEmpty) {
      return error.message;
    }

    return fallback;
  }
}
