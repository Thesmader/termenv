import 'dart:io';

import 'color.dart';
import 'profile.dart';
import 'screen.dart';
import 'style.dart';
import 'termenv.dart';

/// Default global output
var output = Output();

class Output with Screen {
  Output({
    this.fgColor = const NoColor(),
    this.bgColor = const NoColor(),
    IOSink? writer,
    Map<String, String>? environment,
  }) : environment = environment ?? Platform.environment {
    profile = envColorProfile();
  }

  late final Profile profile;
  final Map<String, String> environment;
  Color fgColor;
  Color bgColor;

  Style string(String s) => profile.string(s);

  Color? foregroundColor() {
    if (!_isTTY()) {
      return null;
    }

    fgColor = _foregroundColor() ?? fgColor;
    return fgColor;
  }

  Color? backgroundColor() {
    if (!_isTTY()) {
      return null;
    }

    bgColor = _backgroundColor() ?? bgColor;
    return bgColor;
  }

  Color? _foregroundColor() {
    final echoMode = stdin.echoMode;
    final lineMode = stdin.lineMode;
    stdin
      ..echoMode = false
      ..lineMode = false;
    final status = _termStatusReport(10);
    stdin
      ..echoMode = echoMode
      ..lineMode = lineMode;

    if (status != null) {
      final color = _xTermColor(status);
      return color;
    }

    final colorFGBG = environment['COLORFGBG'];
    if (colorFGBG != null) {
      if (colorFGBG.contains(';')) {
        final c = int.tryParse(colorFGBG.split(';').firstOrNull ?? '');
        if (c != null) {
          return ANSIColor(c);
        }
      }
    }

    return ANSIColor(7);
  }

  Color? _backgroundColor() {
    final echoMode = stdin.echoMode;
    final lineMode = stdin.lineMode;
    stdin
      ..echoMode = false
      ..lineMode = false;
    final status = _termStatusReport(11);
    stdin
      ..echoMode = echoMode
      ..lineMode = lineMode;

    if (status != null) {
      final color = _xTermColor(status);
      return color;
    }

    final colorFGBG = environment['COLORFGBG'];
    if (colorFGBG != null) {
      if (colorFGBG.contains(';')) {
        final c = int.tryParse(colorFGBG.split(';').lastOrNull ?? '');
        if (c != null) {
          return ANSIColor(c);
        }
      }
    }

    return ANSIColor(0);
  }

  Color? _xTermColor(String? s) {
    if (s == null) {
      return null;
    }
    if (s.length < 24 || s.length > 25) {
      return null;
    }

    if (s.endsWith('\x07')) {
      s = s.substring(0, s.length - '\x07'.length);
    } else if (s.endsWith('\x1b')) {
      s = s.substring(0, s.length - '\x1b'.length);
    } else if (s.endsWith('\x1b\\')) {
      s = s.substring(0, s.length - '\x1b\\'.length);
    } else {
      return null;
    }

    s = s.substring(4, s.length);

    if (!s.startsWith(';rgb:')) {
      return null;
    }

    s = s.substring(';rgb:'.length, s.length);

    final hex = s.split('/').map((e) => e.substring(0, 2)).fold(
          '#',
          (previousValue, element) => previousValue + element,
        );
    return RGBColor(hex);
  }

  String? _termStatusReport(int sequence) {
    final term = environment['TERM'];
    if (term == null || term == '') {
      return null;
    }

    if (term.startsWith('screen') || term.startsWith('tmux') || environment.containsKey('TMUX')) {
      return null;
    }

    stdout.write('$seqOSC$sequence;?$seqST');
    // stdout.write('${seqCSI}6n');

    final response = StringBuffer();
    while (true) {
      final d = stdin.readByteSync();

      if (d != -1) {
        response.write(String.fromCharCode(d));
      }
      if (d == 7 || d == 92 || d == 33) {
        break;
      }
      // if (d == 82) {
      //   return null;
      // }
    }

    if (response.isNotEmpty) {
      return response.toString();
    }
    return null;
  }

  Profile envColorProfile() {
    if (envNoColor()) {
      return Profile.ascii;
    }
    final profile = colorProfile();
    if (_cliColorForced() && profile == Profile.ascii) {
      return Profile.ansi;
    }
    return profile;
  }

  String hyperlink({required String link, required String text}) =>
      '${seqOSC}8;;$link$seqST$text${seqOSC}8;;$seqST';

  Profile colorProfile() {
    if (!_isTTY()) {
      return Profile.ascii;
    }

    if (environment['GOOGLE_CLOUD_SHELL'] == 'true') {
      return Profile.trueColor;
    }

    final term = environment['TERM'] ?? '';
    final colorTerm = environment['COLORTERM'] ?? '';

    switch (colorTerm.toLowerCase()) {
      case '24bit':
      case 'truecolor':
        if (term.startsWith('screen') == true) {
          if (environment['TERM_PROGRAM'] != 'tmux') {
            return Profile.ansi256;
          }
        }
        return Profile.trueColor;
      case 'yes':
      case 'true':
        return Profile.ansi256;
    }

    switch (term) {
      case 'xterm-kitty':
      case 'wezterm':
        return Profile.trueColor;
      case 'linux':
        return Profile.ansi;
    }

    if (term.contains('256color')) {
      return Profile.ansi256;
    }

    if (term.contains('color')) {
      return Profile.ansi;
    }

    if (term.contains('ansi')) {
      return Profile.ansi;
    }
    return Profile.ascii;
  }

  bool envNoColor() {
    if (environment.containsKey('NO_COLOR') && environment['NO_COLOR'] != "") {
      return true;
    }

    if (environment['CLICOLOR'] == '0' && !_cliColorForced()) {
      return true;
    }

    return false;
  }

  bool _cliColorForced() {
    final forced = environment['CLICOLOR_FORCE'];
    if (forced != null && forced != "") {
      return forced != '0';
    }
    return false;
  }

  bool _isTTY() {
    if ((environment['CI']?.length ?? 0) > 0) {
      return false;
    }

    return stdout.hasTerminal;
  }

  void notify({required String title, required String body}) {
    stdout.write('${seqOSC}777;notify;$title;$body$seqST');
  }
}
