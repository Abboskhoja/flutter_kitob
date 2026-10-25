/// FLUTTER_KITOB o'quv Dart dvigateli.
///
/// O'quvchi yozgan Dart kodini haqiqatan tahlil qiladi va bajaradi:
/// lexer → parser → statik tekshiruv (checker) → interpretator (+ trace).
/// Sof Dart — Android, iOS va Web'da bir xil ishlaydi, internet talab qilmaydi.
library;

export 'src/diagnostics.dart' show Diagnostic, Severity, LineMap;
export 'src/engine.dart' show KitobDart, KitobSession, EvalOutcome;
export 'src/formatter.dart' show formatDart;
export 'src/highlighter.dart' show HighlightToken, HighlightKind, highlightDart;
export 'src/interpreter.dart'
    show FlutterRuntime, FlutterHost, FlutterRunError, FNode, FColor, FEnum, FIcon, FlutterType, WidgetDesc, flutterIconNames;
export 'src/runtime.dart' show KInstance, KFunction, NativeFunction;
export 'src/values.dart' show KDouble;
export 'src/result.dart';
