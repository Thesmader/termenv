import 'color.dart';

import 'style.dart';

/// Profile is a color profile: Ascii, ANSI, ANSI256, or TrueColor.
enum Profile {
  /// TrueColor, 24-bit color profile
  trueColor,

  /// ANSI256, 8-bit profile
  ansi256,

  /// ANSI, 4-bit profile
  ansi,

  /// Ascii, 1-bit profile
  ascii,
}

extension ProfileMethods on Profile {
  Style string(String s) => Style(string: s, profile: this);
  Color convert(Color c) {
    if (this == Profile.ascii) {
      return NoColor();
    }
    switch (c) {
      case NoColor():
      case ANSIColor():
        return c;
      case ANSI256Color():
        if (this == Profile.ansi) {
          return ansi256ToANSIColor(c);
        }
        return c;
      case RGBColor():
        if (this == Profile.trueColor) {
          return c;
        }
        final ac = hexToANSI256Color(c);
        if (this == Profile.ansi) {
          return ansi256ToANSIColor(ac);
        }
        return ac;
    }

    return c;
  }

  Color? color(String s) {
    if (s.isEmpty) {
      return null;
    }

    Color c;

    if (s.startsWith('#')) {
      c = RGBColor(s);
    } else {
      final i = int.tryParse(s);
      if (i == null) {
        return null;
      }

      if (i < 16) {
        c = ANSIColor(i);
      } else {
        c = ANSI256Color(i);
      }
    }

    return convert(c);
  }
}
