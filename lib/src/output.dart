import 'dart:io';

import 'color.dart';
import 'profile.dart';
import 'style.dart';
import 'termenv.dart';

/// Default global output
var output = Output();

class Output {
  Output({
    this.assumeTTY = false,
    this.unsafe = false,
    this.fgColor = const NoColor(),
    this.bgColor = const NoColor(),
    IOSink? writer,
    Map<String, String>? environment,
  }) : environment = environment ?? Platform.environment {
    profile = envColorProfile();
  }

  late final Profile profile;
  final Map<String, String> environment;
  final bool assumeTTY;
  final bool unsafe;
  Color fgColor;
  Color bgColor;

  Style string(String s) => profile.string(s);

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
    if (assumeTTY || unsafe) {
      return true;
    }

    if ((environment['CI']?.length ?? 0) > 0) {
      return false;
    }

    return stdout.hasTerminal;
  }

  void notify({required String title, required String body}) {
    stdout.write('${seqOSC}777;notify;$title;$body$seqST');
  }
}
