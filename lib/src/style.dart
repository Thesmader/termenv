import 'package:termenv/src/color.dart';

import 'profile.dart';
import 'termenv.dart';

const seqReset = '0',
    seqBold = '1',
    seqFaint = '2',
    seqItalic = '3',
    seqUnderline = '4',
    seqBlink = '5',
    seqReverse = '7',
    seqCrossOut = '9',
    seqOverline = '53';

class Style {
  Style({
    required this.profile,
    required this.string,
  }) : styles = [];
  final Profile profile;
  final String string;
  final List<String> styles;

  Style foreground(Color? c) {
    if (c == null) {
      return this;
    }
    return this..styles.add(c.sequence(false));
  }

  Style background(Color? c) {
    if (c == null) {
      return this;
    }
    return this..styles.add(c.sequence(true));
  }

  Style bold() => this..styles.add(seqBold);

  Style faint() => this..styles.add(seqFaint);

  Style italic() => this..styles.add(seqItalic);

  Style underline() => this..styles.add(seqUnderline);

  Style overline() => this..styles.add(seqOverline);

  Style blink() => this..styles.add(seqBlink);

  Style reverse() => this..styles.add(seqReverse);

  Style crossOut() => this..styles.add(seqCrossOut);

  @override
  String toString() => styled(string);

  String styled(String s) {
    if (profile == Profile.ascii) {
      return s;
    }
    if (styles.isEmpty) {
      return s;
    }

    final seq = styles.join(';');
    if (seq.isEmpty) {
      return s;
    }

    // return '$seqCSI${seq}m$s$seqCSI${seqReset}m';
    return '$seqCSI${seq}m$s$seqCSI${seqReset}m';
  }
}

Style string(String s) => Style(profile: Profile.ansi, string: s);
