import 'package:termenv/src/profile.dart';
import 'package:termenv/termenv.dart' as termenv;

void main() {
  final p = termenv.colorProfile();

  final bold = termenv.string('bold').bold();
  final faint = termenv.string('faint').faint();
  final italic = termenv.string('italic').italic();
  final underline = termenv.string('underline').underline();
  final crossOut = termenv.string('crossOut').crossOut();

  print('\n\t$bold $faint $italic $underline $crossOut');

  var red = termenv.string('red').foreground(p.color('#E88388'));
  var green = termenv.string('green').foreground(p.color("#A8CC8C"));
  var yellow = termenv.string('yellow').foreground(p.color("#DBAB79"));
  var blue = termenv.string('blue').foreground(p.color("#71BEF2"));
  var magenta = termenv.string('magenta').foreground(p.color("#D290E4"));
  var cyan = termenv.string('cyan').foreground(p.color("#66C2CD"));
  var gray = termenv.string('gray').foreground(p.color("#B9BFCA"));

  print('\n\t$red $green $yellow $blue $magenta $cyan $gray');

  red = termenv.string('red').foreground(p.color('0')).background(p.color('#E88388'));
  green = termenv.string('green').foreground(p.color('0')).background(p.color("#A8CC8C"));
  yellow = termenv.string('yellow').foreground(p.color('0')).background(p.color("#DBAB79"));
  blue = termenv.string('blue').foreground(p.color('0')).background(p.color("#71BEF2"));
  magenta = termenv.string('magenta').foreground(p.color('0')).background(p.color("#D290E4"));
  cyan = termenv.string('cyan').foreground(p.color('0')).background(p.color("#66C2CD"));
  gray = termenv.string('gray').foreground(p.color('0')).background(p.color("#B9BFCA"));

  print('\n\t$red $green $yellow $blue $magenta $cyan $gray');
  print('\n');

  print('\n\tStyles can also be combined');

  final italicUnderline = termenv.string('italicUnderline').italic().underline();
  final faintCrossOut = termenv.string('faintCrossOut').faint().crossOut();
  final italicBlue = termenv.string('italicBlue').italic().foreground(p.color('#71BEF2'));
  final boldOnRed =
      termenv.string('boldOnRed').bold().foreground(p.color('0')).background(p.color('#E88388'));

  print('\n\t$italicUnderline $faintCrossOut $italicBlue $boldOnRed');
  print('\n');
}
