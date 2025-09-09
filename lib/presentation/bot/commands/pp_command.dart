import '../../../core/logger.dart';
import '../../../core/parsing.dart';
import 'package:http/http.dart' as http;
import 'package:rosu_pp_dart/rosu_pp_dart.dart';
import 'package:teledart/model.dart' show TeleDartMessage;

import '../command_base.dart';
import '../bot_api.dart';
import '../../../core/pp_calc.dart' as pp;

class PpCommand extends BotCommand {
  @override
  List<String> get names => ['pp'];

  @override
  List<String> get cyrAliases => ['����'];

  @override
  Future<void> handle(TeleDartMessage m) async {
    try {
      final text = m.text ?? '';
      final beatmapId = extractBeatmapId(text);
      if (beatmapId == null) {
        await _reply(
          m,
          'Не удалось распознать ссылку на карту (beatmap).\nПример: /pp https://osu.ppy.sh/beatmapsets/773995#osu/1622719 HDDT 98.5',
        );
        return;
      }

      final (mods, acc) = _parseModsAndAcc(text);

      // Ensure native lib is discoverable by rosu_pp_dart.
      await pp.ensureNativeLibraryAvailable();

      // Download the .osu file directly from osu! website (no auth required).
      final uri = Uri.parse('https://osu.ppy.sh/osu/$beatmapId');
      Log.i('Downloading .osu for beatmapId=$beatmapId -> $uri');
      final resp = await http.get(uri);
      if (resp.statusCode != 200 || resp.bodyBytes.isEmpty) {
        await m.reply(
          'Не удалось скачать .osu файл (HTTP ${resp.statusCode}).',
        );
        return;
      }

      final source = MapSource$Bytes(resp.bodyBytes);
      final settings = BeatmapSettings(mods: mods, acc: acc);

      // Compute PP using provided mods and accuracy only (approximate by design).
      final result = RosuPP.calculate(settings, map: source);

      final ppStr = _fmt(result.pp);
      final starsStr = result.stars != null ? _fmt(result.stars!) : null;
      final maxPpStr = result.maxPp != null ? _fmt(result.maxPp!) : null;

      final modsStr =
          mods.isEmpty ? 'NoMod' : mods.map((e) => e.name.toUpperCase()).join('');
      final accStr = acc != null ? '${_fmt(acc)}%' : '–';

      final lines = <String>[
        'PP: $ppStr',
        'Моды: $modsStr | Точность: $accStr',
        if (starsStr != null) '★: $starsStr',
        if (maxPpStr != null) 'Max PP: $maxPpStr',
      ];
      await _reply(m, lines.join('\n'));
    } on RosuPPException catch (e) {
      Log.e('rosu_pp error', e);
      await _reply(m, 'Не удалось вычислить PP: ${e.message}');
    } on Object catch (e) {
      Log.e('Unhandled /pp error', e as Object?);
      await _reply(m, 'Произошла ошибка при расчёте PP. Попробуйте позже.');
    }
  }

  // Parses mods and accuracy from the command text.
  // Returns (mods, accPercent).
  (List<OsuMod>, double?) _parseModsAndAcc(String text) {
    final tokens = text.trim().split(RegExp(r'\s+'));
    // Drop the command token
    final args = tokens.where((t) => !t.startsWith('/pp')).toList(growable: false);

    String modsSpec = '';
    double? acc;

    final numRe = RegExp(r'^(\d+(?:[.,]\d+)?)%?$');
    for (final t in args) {
      if (t.contains('osu.ppy.sh')) {
        continue; // link is handled via extractBeatmapId
      }
      final m = numRe.firstMatch(t);
      if (m != null) {
        final raw = m.group(1)!.replaceAll(',', '.');
        final v = double.tryParse(raw);
        if (v != null) acc = v <= 1 ? v * 100 : v.clamp(0, 100);
        continue;
      }
      // Potential mods token (letters/numbers like K4, SV2, COOP, HDDT etc.)
      if (RegExp(r'^[a-zA-Z0-9+]+$').hasMatch(t) && !RegExp(r'^\d+$').hasMatch(t)) {
        modsSpec += t;
      }
    }

    final mods = _parseMods(modsSpec);
    return (mods, acc);
  }

  List<OsuMod> _parseMods(String raw) {
    if (raw.isEmpty) return const [];
    var s = raw.toUpperCase().replaceAll('+', '').replaceAll('|', '').replaceAll(',', '');
    final result = <OsuMod>[];

    OsuMod? tryTake(String code) => _modsMap[code];

    while (s.isNotEmpty) {
      // Longest tokens first
      if (s.startsWith('COOP')) {
        result.add(OsuMod.coop);
        s = s.substring(4);
        continue;
      }
      if (s.startsWith('SV2')) {
        result.add(OsuMod.sv2);
        s = s.substring(3);
        continue;
      }
      final kMatch = RegExp(r'^K([1-9])').firstMatch(s);
      if (kMatch != null) {
        final d = kMatch.group(1)!;
        switch (d) {
          case '1':
            result.add(OsuMod.k1);
            break;
          case '2':
            result.add(OsuMod.k2);
            break;
          case '3':
            result.add(OsuMod.k3);
            break;
          case '4':
            result.add(OsuMod.k4);
            break;
          case '5':
            result.add(OsuMod.k5);
            break;
          case '6':
            result.add(OsuMod.k6);
            break;
          case '7':
            result.add(OsuMod.k7);
            break;
          case '8':
            result.add(OsuMod.k8);
            break;
          case '9':
            result.add(OsuMod.k9);
            break;
        }
        s = s.substring(2);
        continue;
      }

      if (s.length >= 2) {
        final code = s.substring(0, 2);
        final mod = tryTake(code);
        if (mod != null) {
          result.add(mod);
          s = s.substring(2);
          continue;
        }
      }
      // Unknown/unsupported token, drop one char to avoid infinite loop
      s = s.substring(1);
    }

    // Deduplicate while preserving order
    final seen = <OsuMod>{};
    final deduped = <OsuMod>[];
    for (final m in result) {
      if (seen.add(m)) deduped.add(m);
    }
    return deduped;
  }

  static const _modsMap = <String, OsuMod>{
    'NF': OsuMod.nf,
    'EZ': OsuMod.ez,
    'TD': OsuMod.td,
    'HD': OsuMod.hd,
    'HR': OsuMod.hr,
    'SD': OsuMod.sd,
    'DT': OsuMod.dt,
    'RX': OsuMod.rx,
    'HT': OsuMod.ht,
    'NC': OsuMod.nc,
    'FL': OsuMod.fl,
    'AU': OsuMod.au,
    'SO': OsuMod.so,
    'AP': OsuMod.ap,
    'PF': OsuMod.pf,
    'FI': OsuMod.fi,
    'RD': OsuMod.rd,
    'CN': OsuMod.cn,
    'TP': OsuMod.tp,
    'MR': OsuMod.mr,
    'CL': OsuMod.cl,
  };

  String _fmt(num v) => v.toStringAsFixed(2);

  // No user-score enrichment: /pp remains approximate by design.

  Future<void> _reply(
    TeleDartMessage m,
    String text, {
    String? parseMode,
  }) async {
    await BotApi.sendMessage(
      m.chat.id,
      text,
      messageThreadId: m.messageThreadId,
      replyToMessageId: m.messageId,
      parseMode: parseMode,
    );
  }
}

