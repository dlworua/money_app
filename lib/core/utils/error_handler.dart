import '../exceptions/app_exceptions.dart';
import '../services/logger_service.dart';

class ErrorHandler {
  static void handleError(
    Object error, 
    StackTrace stackTrace, {
    String? context,
    bool shouldRethrow = false,
  }) {
    String message = 'Unknown error occurred';
    
    if (error is AppException) {
      message = error.message;
      LoggerService.error('AppException in $context: $message', error, stackTrace);
    } else if (error is Exception) {
      message = error.toString();
      LoggerService.error('Exception in $context: $message', error, stackTrace);
    } else {
      message = error.toString();
      LoggerService.error('Error in $context: $message', error, stackTrace);
    }
    
    if (shouldRethrow) {
      throw error;
    }
  }
  
  static String getErrorMessage(Object error) {
    if (error is AppException) {
      return error.message;
    } else if (error is Exception) {
      return '오류가 발생했습니다: ${error.toString()}';
    } else {
      return '알 수 없는 오류가 발생했습니다';
    }
  }
}