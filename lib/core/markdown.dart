/// Экранируем все спецсимволы Markdown V2:
/// _ * [ ] ( ) ~ ` > # + - = | { } . ! \
/// См. https://core.telegram.org/bots/api#markdownv2-style
String escapeMdV2(String text) {
  final re = RegExp(r'([_\*\[\]\(\)~`>#+\-=|{}\.!\\])');
  return text.replaceAllMapped(re, (m) => '\\${m[1]}');
}

/// Ссылка в Markdown V2. Экранируем только видимый текст, URL оставляем как есть.
/// Важно: если в URL будут ')' или '\\', их тоже нужно экранировать вручную.
String linkMdV2(String label, String url) => '[${escapeMdV2(label)}]($url)';
