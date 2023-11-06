import 'color.dart';
import 'output.dart';
import 'profile.dart';

const seqESC = '\x1b';
const seqBEL = '\u0007';
const seqCSI = '$seqESC[';
const seqOSC = '$seqESC]';
const seqST = seqESC + r'\';

Profile colorProfile() => output.colorProfile();

String hyperlink({required String link, required String text}) =>
    output.hyperlink(link: link, text: text);

void notify({required String title, required String body}) =>
    output.notify(title: title, body: body);

Color? foregroundColor() => output.foregroundColor();
Color? backgroundColor() => output.backgroundColor();
