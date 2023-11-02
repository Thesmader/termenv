import 'dart:math';

import 'package:color_models/color_models.dart';

import 'ansicolors.dart';

const seqCodeForeground = '38';
const seqCodeBackground = '48';

abstract final class Color {
  const Color();
  String sequence(bool bg);
}

final class NoColor implements Color {
  const NoColor();

  @override
  String sequence(bool _) => '';
}

final class ANSIColor implements Color {
  const ANSIColor(this.c);
  final int c;

  @override
  String sequence(bool bg) {
    int bgMod(int _) {
      if (bg) {
        return _ + 10;
      }
      return _;
    }

    if (c < 8) {
      return '${bgMod(c) + 30}';
    }

    return '${bgMod(c - 8) + 90}';
  }

  @override
  String toString() => ansiHex[c];
}

final class ANSI256Color implements Color {
  const ANSI256Color(this.value);
  final int value;

  @override
  String sequence(bool bg) {
    var prefix = seqCodeForeground;
    if (bg) {
      prefix = seqCodeBackground;
    }

    return '$prefix;5;$value';
  }

  @override
  String toString() => ansiHex[value];
}

final class RGBColor implements Color {
  const RGBColor(this.hex);
  final String hex;

  int get r => _hexToRGB(hex).r;
  int get g => _hexToRGB(hex).g;
  int get b => _hexToRGB(hex).b;

  @override
  String sequence(bool bg) {
    try {
      final (:r, :g, :b) = _hexToRGB(hex);
      var prefix = seqCodeForeground;
      if (bg) {
        prefix = seqCodeBackground;
      }
      return '$prefix;2;$r;$g;$b';
    } catch (e) {
      return '';
    }
  }

  @override
  String toString() => hex.startsWith('#') ? hex : '#$hex';

  ({int r, int g, int b}) _hexToRGB(String c) {
    c = c.replaceAll('#', '');
    if (c.length != 3 && c.length != 6) {
      throw ArgumentError.value(
        c,
        'c',
        'must be a 3 or 6 digit hex code',
      );
    }
    if (c.length == 3) {
      c = c.split('').map((_) => _ * 2).join('');
    }

    final r = int.parse(c.substring(0, 2), radix: 16);
    final g = int.parse(c.substring(2, 4), radix: 16);
    final b = int.parse(c.substring(4, 6), radix: 16);

    return (r: r, g: g, b: b);
  }
}

/// Converts an [RGBColor] to an [ANSI256Color] close to the original color.
/// The implementation is taken from [muesli/termenv](https://github.com/muesli/termenv/blob/3b3da4b2b15b58ed5e4dca32bcbc6088dff1cf99/color.go#L161).
ANSI256Color hexToANSI256Color(RGBColor c) {
  int v2ci(double v) {
    if (v < 48) {
      return 0;
    }
    if (v < 115) {
      return 1;
    }
    return ((v - 35) / 40).round();
  }

  // Calculate the nearest 0-based color index at 16..231
  final r = v2ci(c.r.toDouble());
  final g = v2ci(c.g.toDouble());
  final b = v2ci(c.b.toDouble());
  final ci = 36 * r + 6 * g + b;

  // Calculate represented colors back from index
  final i2cv = [0, 0x5f, 0x87, 0xaf, 0xd7, 0xff];
  final cr = i2cv[r];
  final cg = i2cv[g];
  final cb = i2cv[b];

  // Calculate the nearest 0-based grey index at 232..255
  final average = (r + g + b) / 3;
  final int grayIdx;
  if (average > 238) {
    grayIdx = 23;
  } else {
    grayIdx = (average - 3) ~/ 10;
  }

  final gv = 8 + 10 * grayIdx;

  final c2 = RgbColor(cr / 255, cg / 255, cb / 255);
  final g2 = RgbColor(gv / 255, gv / 255, gv / 255);

  final colorDist = _distanceHSLuv(RgbColor.fromHex(c.hex), c2);
  final grayDist = _distanceHSLuv(RgbColor.fromHex(c.hex), g2);

  if (colorDist <= grayDist) {
    return ANSI256Color(16 + ci);
  }
  return ANSI256Color(232 + grayIdx);
}

ANSIColor ansi256ToANSIColor(ANSI256Color c) {
  int r = 0;
  var md = double.maxFinite;

  final h = RgbColor.fromHex(ansiHex[c.value]);

  for (var i = 0; i <= 15; i++) {
    final hb = RgbColor.fromHex(ansiHex[i]);
    final d = _distanceHSLuv(h, hb);

    if (d < md) {
      md = d.toDouble();
      r = i;
    }
  }

  return ANSIColor(r);
}

num _distanceHSLuv(RgbColor c1, RgbColor c2) {
  final HslColor(hue: h1, saturation: s1, lightness: l1) = c1.toHslColor();
  final HslColor(hue: h2, saturation: s2, lightness: l2) = c2.toHslColor();

  return sqrt((pow((h1 - h2) / 100.0, 2) + pow(s1 - s2, 2) + pow(l1 - l2, 2)));
}
