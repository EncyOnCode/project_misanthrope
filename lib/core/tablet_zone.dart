import 'dart:math' as math;

/// Tablet-to-game mapping utilities.
///
/// Defines helpers to convert a physical tablet active area (in millimeters)
/// to a new target area given a screen resolution and a game window
/// resolution. It covers three common scenarios:
///
/// - Matching game edges to the full screen: scale by `W/w` and `H/h`.
/// - Mapping tablet directly to the game window: scale by `w/W` and `h/H`.
/// - Keeping shape by a single scale factor: width-only, height-only, or
///   geometric mean of both ratios.
///
/// Notation used in formulas:
/// - `W, H`: screen width/height (pixels)
/// - `w, h`: game window width/height (pixels)
/// - `A, B`: current tablet area width/height (millimeters)
///
/// All inputs must be positive; additionally `w <= W` and `h <= H`.

/// Physical tablet zone in millimeters.
class TabletZone {
  final double widthMm;
  final double heightMm;

  const TabletZone(this.widthMm, this.heightMm)
      : assert(widthMm > 0),
        assert(heightMm > 0);

  @override
  String toString() =>
      'TabletZone(widthMm: ${widthMm.toStringAsFixed(6)}, heightMm: ${heightMm.toStringAsFixed(6)})';
}

/// Offset (pixels) from the screen's top-left to the top-left of the centered
/// game window.
class GameWindowOffset {
  final double offsetX;
  final double offsetY;

  const GameWindowOffset(this.offsetX, this.offsetY);

  @override
  String toString() =>
      'GameWindowOffset(offsetX: ${offsetX.toStringAsFixed(6)}, offsetY: ${offsetY.toStringAsFixed(6)})';
}

/// How to pick a single scale factor when keeping shape.
enum KeepShapeStrategy { width, height, geomean }

void _validateDimensions({
  required double screenW,
  required double screenH,
  required double gameW,
  required double gameH,
}) {
  if (screenW <= 0 || screenH <= 0 || gameW <= 0 || gameH <= 0) {
    throw ArgumentError('All dimensions must be > 0.');
  }
  if (gameW > screenW || gameH > screenH) {
    throw ArgumentError(
      'Game window must not exceed screen: game=($gameW x $gameH), screen=($screenW x $screenH).',
    );
  }
}

void _validateTablet({
  required double tabletWmm,
  required double tabletHmm,
}) {
  if (tabletWmm <= 0 || tabletHmm <= 0) {
    throw ArgumentError('Tablet area must be > 0 mm.');
  }
}

/// Scale tablet so its edges align with the game edges mapped to the screen.
///
/// Formula: `A' = A * W / w`, `B' = B * H / h`.
///
/// Use when your original tablet area `[A x B]` was tuned for a game window
/// of size `[w x h]`, and you want to keep the same in-game reach when the
/// game is displayed on a screen `[W x H]`. This expands the tablet zone by
/// the ratios of screen-to-game pixels separately per axis.
TabletZone zoneMatchGameEdges(
  double screenW,
  double screenH,
  double gameW,
  double gameH,
  double tabletWmm,
  double tabletHmm,
) {
  _validateDimensions(screenW: screenW, screenH: screenH, gameW: gameW, gameH: gameH);
  _validateTablet(tabletWmm: tabletWmm, tabletHmm: tabletHmm);
  final double newW = tabletWmm * screenW / gameW;
  final double newH = tabletHmm * screenH / gameH;
  return TabletZone(newW, newH);
}

/// Map the tablet area directly to the game window (not the full screen).
///
/// Formula: `A' = A * w / W`, `B' = B * h / H`.
///
/// Use when the tablet should map 1:1 into the game sub-rectangle inside the
/// screen (e.g., you capture the game window region only). This shrinks the
/// tablet zone by the ratios of game-to-screen pixels.
TabletZone zoneMapDirectToGame(
  double screenW,
  double screenH,
  double gameW,
  double gameH,
  double tabletWmm,
  double tabletHmm,
) {
  _validateDimensions(screenW: screenW, screenH: screenH, gameW: gameW, gameH: gameH);
  _validateTablet(tabletWmm: tabletWmm, tabletHmm: tabletHmm);
  final double newW = tabletWmm * gameW / screenW;
  final double newH = tabletHmm * gameH / screenH;
  return TabletZone(newW, newH);
}

/// Keep shape by a single scale factor `s` derived from pixel ratios.
///
/// Scale factor choices:
/// - `KeepShapeStrategy.width`   → `s = W / w`
/// - `KeepShapeStrategy.height`  → `s = H / h`
/// - `KeepShapeStrategy.geomean` → `s = sqrt((W / w) * (H / h))`
///
/// Returns `TabletZone(A * s, B * s)`.
///
/// Use when you prefer uniform scaling (same factor on both axes) to maintain
/// the physical aspect ratio of the tablet zone, choosing which pixel ratio
/// (or their geometric mean) should drive the scaling.
TabletZone zoneKeepShape(
  double screenW,
  double screenH,
  double gameW,
  double gameH,
  double tabletWmm,
  double tabletHmm,
  KeepShapeStrategy strategy,
) {
  _validateDimensions(screenW: screenW, screenH: screenH, gameW: gameW, gameH: gameH);
  _validateTablet(tabletWmm: tabletWmm, tabletHmm: tabletHmm);
  final double rw = screenW / gameW;
  final double rh = screenH / gameH;
  final double s;
  switch (strategy) {
    case KeepShapeStrategy.width:
      s = rw;
      break;
    case KeepShapeStrategy.height:
      s = rh;
      break;
    case KeepShapeStrategy.geomean:
      s = math.sqrt(rw * rh);
      break;
  }
  return TabletZone(tabletWmm * s, tabletHmm * s);
}

/// When a game window `[w x h]` is centered on screen `[W x H]`, returns the
/// top-left offset from the screen origin to the game window origin.
///
/// Formula: `offsetX = (W - w) / 2`, `offsetY = (H - h) / 2`.
GameWindowOffset gameWindowOffset(
  double screenW,
  double screenH,
  double gameW,
  double gameH,
) {
  _validateDimensions(screenW: screenW, screenH: screenH, gameW: gameW, gameH: gameH);
  final double dx = (screenW - gameW) / 2.0;
  final double dy = (screenH - gameH) / 2.0;
  return GameWindowOffset(dx, dy);
}

/// Returns true when two doubles are within `eps`.
bool close(double a, double b, [double eps = 1e-9]) => (a - b).abs() <= eps;

