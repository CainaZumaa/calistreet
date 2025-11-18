import 'logger.dart';

class AppError {
  final String message;
  final String? code;
  final Object? originalError;
  final StackTrace? stackTrace;
  final Map<String, dynamic>? context;

  AppError({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
    this.context,
  });

  @override
  String toString() => message;
}

class ErrorHandler {
  static String handleError(
    Object error, {
    StackTrace? stackTrace,
    String? context,
  }) {
    final errorMessage = _extractErrorMessage(error);
    final errorCode = _extractErrorCode(error);

    Logger.error(
      context ?? 'ErrorHandler',
      'Erro capturado: $errorMessage',
      error: error,
      stackTrace: stackTrace,
      extra: {'code': errorCode, 'context': context},
    );

    return _getUserFriendlyMessage(error, errorMessage);
  }

  static String _extractErrorMessage(Object error) {
    final errorStr = error.toString();

    // Tenta extrair mensagem mais específica de diferentes tipos de erro
    if (errorStr.contains('Exception:')) {
      return errorStr.split('Exception:').last.trim();
    }

    if (errorStr.contains('Error:')) {
      return errorStr.split('Error:').last.trim();
    }

    return errorStr;
  }

  static String? _extractErrorCode(Object error) {
    final errorStr = error.toString();

    // Códigos HTTP comuns
    if (errorStr.contains('400')) return 'BAD_REQUEST';
    if (errorStr.contains('401')) return 'UNAUTHORIZED';
    if (errorStr.contains('403')) return 'FORBIDDEN';
    if (errorStr.contains('404')) return 'NOT_FOUND';
    if (errorStr.contains('422')) return 'VALIDATION_ERROR';
    if (errorStr.contains('500')) return 'SERVER_ERROR';
    if (errorStr.contains('503')) return 'SERVICE_UNAVAILABLE';

    // Erros de rede
    if (errorStr.contains('SocketException') || errorStr.contains('network')) {
      return 'NETWORK_ERROR';
    }

    // Erros de autenticação
    if (errorStr.contains('authentication') || errorStr.contains('login')) {
      return 'AUTH_ERROR';
    }

    return null;
  }

  static String _getUserFriendlyMessage(Object error, String technicalMessage) {
    final errorStr = error.toString().toLowerCase();

    // Mensagens de autenticação
    if (errorStr.contains('email ou senha incorretos') ||
        errorStr.contains('invalid login credentials')) {
      return 'Email ou senha incorretos. Verifique suas credenciais e tente novamente.';
    }

    if (errorStr.contains('user already registered') ||
        errorStr.contains('email já está cadastrado')) {
      return 'Este email já está cadastrado. Tente fazer login ou use outro email.';
    }

    if (errorStr.contains('password should be at least')) {
      return 'A senha deve ter pelo menos 6 caracteres.';
    }

    if (errorStr.contains('invalid email')) {
      return 'Email inválido. Verifique o formato do email.';
    }

    // Erros de rede
    if (errorStr.contains('socketexception') ||
        errorStr.contains('network') ||
        errorStr.contains('connection')) {
      return 'Erro de conexão. Verifique sua internet e tente novamente.';
    }

    // Erros de validação
    if (errorStr.contains('422') || errorStr.contains('validation')) {
      return 'Erro de validação. Verifique os dados informados.';
    }

    // Erros de servidor
    if (errorStr.contains('500') || errorStr.contains('server error')) {
      return 'Erro no servidor. Tente novamente em alguns instantes.';
    }

    // Erros de permissão
    if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      return 'Você não tem permissão para realizar esta ação.';
    }

    // Erros de não encontrado
    if (errorStr.contains('404') || errorStr.contains('not found')) {
      return 'Recurso não encontrado.';
    }

    // Erro genérico
    return 'Ocorreu um erro inesperado. Tente novamente mais tarde.';
  }

  static AppError createAppError({
    required String message,
    String? code,
    Object? originalError,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      message: message,
      code: code,
      originalError: originalError,
      stackTrace: stackTrace,
      context: context,
    );
  }
}
