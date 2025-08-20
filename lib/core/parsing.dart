({String user, String mode}) parseArgs(
  String? text, {
  String defaultMode = 'osu',
}) {
  final parts = (text ?? '').trim().split(RegExp(r'\s+'));
  if (parts.length < 2) return (user: '', mode: defaultMode);
  final args = parts.sublist(1);
  final modes = {'osu', 'taiko', 'fruits', 'mania'};
  var mode = defaultMode;
  if (args.isNotEmpty && modes.contains(args.last.toLowerCase())) {
    mode = args.removeLast().toLowerCase();
  }
  return (user: args.join(' ').trim(), mode: mode);
}

bool matchAlias(String? text, String alias, String botUsername) {
  if (text == null) return false;
  final t = text.trim().toLowerCase();
  if (!t.startsWith('/')) return false;
  final a = alias.toLowerCase();
  final withAt = '/$a@${botUsername.toLowerCase()}';
  return t == '/$a' ||
      t.startsWith('/$a ') ||
      t == withAt ||
      t.startsWith('$withAt ');
}
