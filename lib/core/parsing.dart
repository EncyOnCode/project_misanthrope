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

/// Tries to extract a beatmap id from arbitrary text: accepts
/// - direct ids (digits)
/// - links like:
///   - https://osu.ppy.sh/beatmaps/{id}
///   - https://osu.ppy.sh/b/{id}
///   - https://osu.ppy.sh/beatmapsets/{set}#<mode>/{id}
int? extractBeatmapId(String? text) {
  if (text == null || text.trim().isEmpty) return null;
  final t = text.trim();

  // If the first token is pure digits, consider it an id.
  final firstToken = t.split(RegExp(r"\s+")).skip(1).firstOrNull ?? '';
  final tokenDigits = RegExp(r'^\d{3,}$');
  if (tokenDigits.hasMatch(firstToken)) {
    return int.tryParse(firstToken);
  }

  // Scan entire text for any known link patterns.
  final patterns = <RegExp>[
    RegExp(r'osu\.ppy\.sh\/beatmaps\/(\d+)', caseSensitive: false),
    RegExp(r'osu\.ppy\.sh\/b\/(\d+)', caseSensitive: false),
    RegExp(r'osu\.ppy\.sh\/beatmapsets\/\d+#[a-z]+\/(\d+)', caseSensitive: false),
  ];
  for (final re in patterns) {
    final m = re.firstMatch(t);
    if (m != null && m.groupCount >= 1) {
      return int.tryParse(m.group(1)!);
    }
  }

  // Fallback: any digits anywhere (avoid tiny numbers)
  final anyDigits = RegExp(r'(\d{5,})');
  final m = anyDigits.firstMatch(t);
  if (m != null) return int.tryParse(m.group(1)!);
  return null;
}

extension on Iterable<String> {
  String? get firstOrNull => isEmpty ? null : first;
}
