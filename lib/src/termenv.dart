import 'output.dart';
import 'profile.dart';

const seqESC = '\x1b';
const seqBEL = '\u0007';
const seqCSI = '$seqESC[';
const seqOSC = '$seqESC]';
const seqST = seqESC + r'\';

Profile colorProfile() => output.colorProfile();
