import 'dart:io';

import 'color.dart';
import 'output.dart';
import 'style.dart';
import 'termenv.dart';

// Cursor positioning
String seqCursorUp(int n) => '${n}A';
String seqCursorDown(int n) => '${n}B';
String seqCursorForward(int n) => '${n}C';
String seqCursorBack(int n) => '${n}D';
String seqCursorNextLine(int n) => '${n}E';
String seqCursorPreviousLine(int n) => '${n}F';
String seqCursorHorizontalAbsolute(int n) => '${n}G';
String seqCursorPosition(int row, int column) => '$row;${column}H';
String seqEraseDisplay(int n) => '${n}J';
String seqEraseLine(int n) => '${n}K';
String seqScrollUp(int n) => '${n}S';
String seqScrollDown(int n) => '${n}T';
const seqSaveCursorPosition = 's';
const seqRestoreCursorPosition = 'u';
String seqChangeScrollingRegion(int top, int bottom) => '$top;${bottom}r';
String seqInsertLine(int n) => '${n}L';
String seqDeleteLine(int n) => '${n}M';

// Explicit seqEraseLine values
const seqEraseLineRight = '0K';
const seqEraseLineLeft = '1K';
const seqEraseEntireLine = '2K';

// Mouse
const seqEnableMousePress = '?9h';
const seqDisableMousePress = '?9l';
const seqEnableMouse = '?1000h';
const seqDisableMouse = '?1000l';
const seqEnableMouseHilite = '?1001h';
const seqDisableMouseHilite = '?1001l';
const seqEnableMouseCellMotion = '?1002h';
const seqDisableMouseCellMotion = '?1002l';
const seqEnableMouseAllMotion = '?1003h';
const seqDisableMouseAllMotion = '?1003l';
const seqEnableMouseExtended = '?1006h';
const seqDisableMouseExtended = '?1006l';
const enableMousePixels = '?1016h';
const disableMousePixels = '?1016l';

// Screen
const seqRestoreScreen = '?47l';
const seqSaveScreen = '?47h';
const seqAltScreen = '?1049h';
const seqExitAltScreen = '?1049l';

// Bracketed paste
const seqEnableBracketedPaste = '?2004h';
const seqDisableBracketedPaste = '?2004l';
const seqStartBracketedPaste = '200~';
const seqEndBracketedPaste = '201~';

// Session
String seqSetWindowTitle(String title) => '2;$title\x07';
String seqSetForegroundColor(String color) => '10;$color\x07';
String seqSetBackgroundColor(String color) => '11;$color\x07';
String seqSetCursorColor(String color) => '12;$color\x07';
const seqShowCursor = '?25h';
const seqHideCursor = '?25l';

mixin Screen on Output {
  /// Reset output to its default style, removing any active styles.
  void reset() => stdout.write('$seqCSI${seqReset}m');

  /// Set the output's foreground color to [color]
  void setForegroundColor(Color color) =>
      stdout.write('$seqOSC${seqSetForegroundColor(color.toString())}');

  /// Set the output's background color to [color]
  void setBackgroundColor(Color color) =>
      stdout.write('$seqOSC${seqSetBackgroundColor(color.toString())}');

  /// Set the output's cursor color to [color]
  void setCursorColor(Color color) => stdout.write('$seqOSC${seqSetCursorColor(color.toString())}');

  /// Restores a previously saved screen state
  void restoreScreen() => stdout.write('$seqCSI$seqRestoreScreen');

  /// Saves the current screen state
  void saveScreen() => stdout.write('$seqCSI$seqSaveScreen');

  /// Switches to the alternate screen buffer. Restore the previous screen using [exitAltScreen]
  void altScreen() => stdout.write('$seqCSI$seqAltScreen');

  /// Exits the alternate screen buffer, restoring the previous screen
  void exitAltScreen() => stdout.write('$seqCSI$seqExitAltScreen');

  /// Clears the visible portion of the terminal
  void clearScreen() {
    stdout.write('$seqCSI${seqEraseDisplay(2)}');
    moveCursor(1, 1);
  }

  /// Moves the cursor to a given position specified by [row] and [column]
  void moveCursor(int row, int column) => stdout.write('$seqCSI${seqCursorPosition(row, column)}');

  /// Hides the cursor
  void hideCursor() => stdout.write('$seqCSI$seqHideCursor');

  /// Shows the cursor
  void showCursor() => stdout.write('$seqCSI$seqShowCursor');

  /// Saves the current cursor position
  void saveCursorPosition() => stdout.write('$seqCSI$seqSaveCursorPosition');

  /// Restores a saved cursor position
  void restoreCursorPosition() => stdout.write('$seqCSI$seqRestoreCursorPosition');

  /// Moves the cursor up [n] lines
  void cursorUp([int n = 1]) => stdout.write('$seqCSI${seqCursorUp(n)}');

  /// Moves the cursor down [n] lines
  void cursorDown([int n = 1]) => stdout.write('$seqCSI${seqCursorDown(n)}');

  /// Moves the cursor forward [n] columns
  void cursorForward([int n = 1]) => stdout.write('$seqCSI${seqCursorForward(n)}');

  /// Moves the cursor back [n] columns
  void cursorBack([int n = 1]) => stdout.write('$seqCSI${seqCursorBack(n)}');

  /// Moves the cursor down [n] lines and places it at the beginning of the line
  void cursorNextLine([int n = 1]) => stdout.write('$seqCSI${seqCursorNextLine(n)}');

  /// Moves the cursor up [n] lines and places it at the beginning of the line
  void cursorPrevLine([int n = 1]) => stdout.write('$seqCSI${seqCursorPreviousLine(n)}');

  /// Clears the current line
  void clearLine() => stdout.write('$seqCSI$seqEraseEntireLine');

  /// Clears the line to the left of the cursor
  void clearLineLeft() => stdout.write('$seqCSI$seqEraseLineLeft');

  /// Clears the line to the right of the cursor
  void clearLineRight() => stdout.write('$seqCSI$seqEraseLineRight');

  /// Clears [n] lines
  void clearLines(int n) {
    final clearLine = '$seqCSI$seqEraseEntireLine';
    final cursorUp = '$seqCSI${seqCursorUp(1)}';

    stdout.write('$clearLine${'$cursorUp$clearLine' * n}');
  }

  /// Sets the scrolling region of the terminal from [top] to [bottom]
  void changeScrollingRegion(int top, int bottom) =>
      stdout.write('$seqCSI${seqChangeScrollingRegion(top, bottom)}');

  /// Inserts [n] lines at the top of the scrolling region, pushing existing lines down
  void insertLines(int n) => stdout.write('$seqCSI${seqInsertLine(n)}');

  /// Deletes [n] lines, pulling any lines below them up
  void deleteLines(int n) => stdout.write('$seqCSI${seqDeleteLine(n)}');

  /// Enables X10 mouse mode
  void enableMousePress() => stdout.write('$seqCSI$seqEnableMousePress');

  /// Disables X10 mouse mode
  void disableMousePress() => stdout.write('$seqCSI$seqDisableMousePress');

  /// Enables mouse tracking mode
  void enableMouse() => stdout.write('$seqCSI$seqEnableMouse');

  /// Disables mouse tracking mode
  void disableMouse() => stdout.write('$seqCSI$seqDisableMouse');

  /// Enables Hilite mouse tracking mode
  void enableMouseHilite() => stdout.write('$seqCSI$seqEnableMouseHilite');

  /// Disables Hilite mouse tracking mode
  void disableMouseHilite() => stdout.write('$seqCSI$seqDisableMouseHilite');

  /// Enables Cell Motion mouse tracking mode
  void enableMouseCellMotion() => stdout.write('$seqCSI$seqEnableMouseCellMotion');

  /// Disables Cell Motion mouse tracking mode
  void disableMouseCellMotion() => stdout.write('$seqCSI$seqDisableMouseCellMotion');

  /// Enables All Motion mouse mode
  void enableMouseAllMotion() => stdout.write('$seqCSI$seqEnableMouseAllMotion');

  /// Disables All Motion mouse mode
  void disableMouseAllMotion() => stdout.write('$seqCSI$seqDisableMouseAllMotion');

  /// Enables Extended mouse mode (SGR). This should be enabled in conjunction with
  /// [enableMouseCellMotion], and [enableMouseAllMotion]
  void enableMouseExtended() => stdout.write('$seqCSI$seqEnableMouseExtended');

  /// Disables Extended mouse mode (SGR)
  void disableMouseExtended() => stdout.write('$seqCSI$seqDisableMouseExtended');

  /// Enables Pixel motion mouse mode (SGR-Pixels). This should be enabled in conjunction with
  /// [enableMouseCellMotion], and [enableMouseAllMotion]
  void enableMousePixels() => stdout.write('$seqCSI$enableMousePixels');

  /// Disables Pixel motion mouse mode (SGR-Pixels)
  void disableMousePixels() => stdout.write('$seqCSI$disableMousePixels');

  /// Sets the terminal window title
  void setWindowTitle(String title) => stdout.write('$seqOSC${seqSetWindowTitle(title)}');

  /// Enables bracketed paste
  void enableBracketedPaste() => stdout.write('$seqCSI$seqEnableBracketedPaste');

  /// Disables bracketed paste
  void disableBracketedPaste() => stdout.write('$seqCSI$seqDisableBracketedPaste');
}
