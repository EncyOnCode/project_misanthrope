import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:rosu_pp_dart/rosu_pp_dart.dart';

import 'logger.dart';

/// Ensures the native rosu-pp library is available for FFI.
Future<void> ensureNativeLibraryAvailable() async {
  final libName = Platform.isWindows
      ? 'native.dll'
      : Platform.isMacOS
          ? 'libnative.dylib'
          : 'libnative.so';

  final inCwd = File(libName);
  if (inCwd.existsSync()) return;

  final fromBin = File('bin/$libName');
  if (fromBin.existsSync()) {
    try {
      await fromBin.copy(libName);
      Log.i('Copied $libName from bin/ to CWD for rosu-pp');
    } on Object catch (e) {
      Log.w('Failed to copy $libName from bin/: $e');
    }
  }
}

/// Downloads .osu file bytes by beatmap id.
Future<Uint8List> fetchOsuFile(int beatmapId) async {
  final uri = Uri.parse('https://osu.ppy.sh/osu/$beatmapId');
  Log.i('Downloading .osu for beatmapId=$beatmapId');
  final r = await http.get(uri);
  if (r.statusCode != 200 || r.bodyBytes.isEmpty) {
    throw RosuPPException('Failed to download .osu (HTTP ${r.statusCode})', r.statusCode);
  }
  return r.bodyBytes;
}

/// Converts string mods like HD, DT, NC ... to rosu_pp_dart OsuMod list.
List<OsuMod> modsFromStrings(Iterable<String> mods) {
  final result = <OsuMod>[];
  for (final raw in mods) {
    final m = raw.toUpperCase();
    switch (m) {
      case 'NF':
        result.add(OsuMod.nf);
        break;
      case 'EZ':
        result.add(OsuMod.ez);
        break;
      case 'TD':
        result.add(OsuMod.td);
        break;
      case 'HD':
        result.add(OsuMod.hd);
        break;
      case 'HR':
        result.add(OsuMod.hr);
        break;
      case 'SD':
        result.add(OsuMod.sd);
        break;
      case 'DT':
        result.add(OsuMod.dt);
        break;
      case 'RX':
        result.add(OsuMod.rx);
        break;
      case 'HT':
        result.add(OsuMod.ht);
        break;
      case 'NC':
        result.add(OsuMod.nc);
        break;
      case 'FL':
        result.add(OsuMod.fl);
        break;
      case 'AU':
        result.add(OsuMod.au);
        break;
      case 'SO':
        result.add(OsuMod.so);
        break;
      case 'AP':
        result.add(OsuMod.ap);
        break;
      case 'PF':
        result.add(OsuMod.pf);
        break;
      case 'FI':
        result.add(OsuMod.fi);
        break;
      case 'RD':
        result.add(OsuMod.rd);
        break;
      case 'CN':
        result.add(OsuMod.cn);
        break;
      case 'TP':
        result.add(OsuMod.tp);
        break;
      case 'MR':
        result.add(OsuMod.mr);
        break;
      case 'CL':
        result.add(OsuMod.cl);
        break;
      default:
        // Key mods like K1..K9 or others
        final km = RegExp(r'^K([1-9])').firstMatch(m);
        if (km != null) {
          switch (km.group(1)) {
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
        }
        break;
    }
  }
  // dedupe
  final seen = <OsuMod>{};
  final deduped = <OsuMod>[];
  for (final m in result) {
    if (seen.add(m)) deduped.add(m);
  }
  return deduped;
}

CalcResult calcFromBytes(
  Uint8List bytes, {
  required List<OsuMod> mods,
  double? acc,
  int? combo,
  int? nMiss,
  int? n300,
  int? n100,
  int? n50,
  int? nGeki,
  int? nKatu,
}) {
  final src = MapSource$Bytes(bytes);
  final settings = BeatmapSettings(
    mods: mods,
    acc: acc,
    combo: combo,
    nMiss: nMiss,
    n300: n300,
    n100: n100,
    n50: n50,
    nGeki: nGeki,
    nKatu: nKatu,

  );
  return RosuPP.calculate(settings, map: src);
}

