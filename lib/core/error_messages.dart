import 'errors.dart';

/// Converts internal errors to user-friendly Telegram messages (in Russian).
/// Avoids leaking raw error text into chat.
String toUserMessage(Object error) {
  // Network/HTTP errors
  if (error is NetworkException) {
    final code = error.statusCode;
    final path = error.uri.path;

    if (code == 404) {
      if (path.contains('/users')) {
        return '⚠️ Пользователь с таким никнеймом не найден.';
      }
      if (path.contains('/beatmaps')) {
        return '⚠️ Карта не найдена.';
      }
      return '⚠️ Ресурс не найден.';
    }

    if (code == 400) {
      return 'Некорректный запрос. Проверьте параметры.';
    }
    if (code == 401 || code == 403) {
      return 'Нет доступа к данным osu! (ошибка авторизации). Попробуйте позже.';
    }
    if (code == 429) {
      return 'Слишком много запросов к osu! API. Попробуйте позже.';
    }
    if (code >= 500) {
      return 'Проблема на стороне osu! (серверная ошибка). Попробуйте позже.';
    }

    return 'Не удалось получить данные osu! (HTTP $code). Попробуйте позже.';
  }

  // Generic fallback
  final text = error.toString();
  if (text.contains('osu! token error')) {
    return 'Проблема авторизации с osu! API. Попробуйте позже.';
  }
  return 'Произошла непредвиденная ошибка. Попробуйте позже.';
}
