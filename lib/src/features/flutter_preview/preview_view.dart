import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:kitob_dart/kitob_dart.dart';

import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../code/console_view.dart';
import 'renderer.dart';

/// O'quvchi yozgan Flutter kodini haqiqiy widgetlar sifatida chizadigan telefon oynasi.
///
/// Kod [KitobDart] interpretatorida bajariladi; `build()` natijasi haqiqiy Flutter
/// widgetlariga aylantiriladi, tugmalar esa o'quvchining callback'larini chaqiradi.
class FlutterPreview extends StatefulWidget {
  const FlutterPreview({super.key, required this.source, this.height = 520, this.onRuntime, this.onJumpToLine});
  final String source;
  final double height;

  /// Baholash uchun: muvaffaqiyatli ochilgan runtime.
  final void Function(FlutterRuntime? rt, List<Diagnostic> diagnostics, RuntimeErrorInfo? error)? onRuntime;
  final void Function(int line)? onJumpToLine;

  @override
  State<FlutterPreview> createState() => _FlutterPreviewState();
}

class _FlutterPreviewState extends State<FlutterPreview> implements FlutterHost {
  // Har yangi ishga tushirishda yangi kalitlar — eski Navigator holati qayta ishlatilmasin.
  var _navigatorKey = GlobalKey<NavigatorState>();
  var _messengerKey = GlobalKey<ScaffoldMessengerState>();
  FlutterRuntime? _rt;
  PreviewScope? _scope;
  List<Diagnostic> _diagnostics = const [];
  RuntimeErrorInfo? _error;
  String? _callbackError;
  int _generation = 0;
  int _stdoutSeen = 0;
  final List<String> _logs = [];

  /// Kod ichidagi Future.delayed / Timer uchun haqiqiy vaqt taymeri.
  Timer? _wake;

  @override
  void initState() {
    super.initState();
    _open();
  }

  @override
  void didUpdateWidget(FlutterPreview old) {
    super.didUpdateWidget(old);
    if (old.source != widget.source) _open();
  }

  void _open() {
    _wake?.cancel();
    _wake = null;
    _scope?.dispose();
    final (rt, diags, err) = FlutterRuntime.open(widget.source, host: this);
    _rt = rt;
    _diagnostics = diags;
    _error = err;
    _callbackError = null;
    _logs.clear();
    _stdoutSeen = 0;
    _scope = rt == null ? null : PreviewScope(rt, _onCallbackError, afterCallback: () => _later(() {
          if (mounted) setState(_collectLogs);
        }));
    _generation++;
    _navigatorKey = GlobalKey<NavigatorState>();
    _messengerKey = GlobalKey<ScaffoldMessengerState>();
    _collectLogs();
    widget.onRuntime?.call(rt, diags, err);
  }

  void _collectLogs() {
    final rt = _rt;
    if (rt == null) return;
    final out = rt.stdout;
    if (out.length > _stdoutSeen) {
      _logs.addAll(out.substring(_stdoutSeen).split('\n').where((l) => l.isNotEmpty));
      _stdoutSeen = out.length;
      if (_logs.length > 50) _logs.removeRange(0, _logs.length - 50);
    }
  }

  void _onCallbackError(Object e) {
    setState(() {
      _callbackError = e is FlutterRunError ? '${e.info.explanation}\n${e.info.message}' : '$e';
    });
  }

  void _later(VoidCallback fn) {
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) => fn());
    } else {
      fn();
    }
  }

  // ───── FlutterHost ─────

  @override
  void onSetState(KInstance state) {
    _later(() {
      _scope?.refreshers[state]?.call();
      if (mounted) setState(_collectLogs);
    });
  }

  @override
  void onPush(Object? route) {
    final scope = _scope;
    if (route is! FNode || scope == null) return;
    final builder = route.named['builder'];
    if (builder == null) return;
    final renderer = KitobRenderer(scope);
    _later(() => _navigatorKey.currentState?.push(MaterialPageRoute<void>(
          builder: (c) => renderer.render(scope.rt.call(builder, [scope.rt.context])),
        )));
  }

  @override
  void onPop() => _later(() => _navigatorKey.currentState?.maybePop());

  @override
  void onSnackBar(Object? snackBar) {
    final scope = _scope;
    if (snackBar is! FNode || scope == null) return;
    final content = snackBar.named['content'];
    _later(() => _messengerKey.currentState
      ?..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: KitobRenderer(scope).render(content))));
  }

  @override
  void scheduleWake(Duration delay) {
    _wake?.cancel();
    final rt = _rt;
    _wake = Timer(delay, () {
      if (!mounted || !identical(rt, _rt)) return;
      try {
        rt!.pump();
        setState(_collectLogs);
      } on FlutterRunError catch (e) {
        _onCallbackError(e);
      }
    });
  }

  @override
  double get screenWidth => 360;
  @override
  double get screenHeight => widget.height;
  @override
  bool get isDark => false;

  @override
  void dispose() {
    _wake?.cancel();
    _scope?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final k = context.k;
    final scope = _scope;
    Widget screen;
    if (_diagnostics.any((d) => d.isError)) {
      screen = Padding(padding: const EdgeInsets.all(12), child: ProblemsView(diagnostics: _diagnostics, compact: true));
    } else if (_error != null) {
      screen = SingleChildScrollView(padding: const EdgeInsets.all(12), child: RuntimeErrorCard(error: _error!, onJumpToLine: widget.onJumpToLine));
    } else if (scope != null) {
      final root = KitobRenderer(scope).render(scope.rt.root);
      screen = PreviewHostScope(
        navigatorKey: _navigatorKey,
        messengerKey: _messengerKey,
        child: KeyedSubtree(
          key: ValueKey(_generation),
          // MaterialApp yozilmagan bo'lsa ham widgetlar ishlashi uchun minimal muhit.
          child: _needsApp(scope.rt.root) ? _BareApp(navigatorKey: _navigatorKey, messengerKey: _messengerKey, child: root) : root,
        ),
      );
    } else {
      screen = const SizedBox();
    }

    return Column(mainAxisSize: MainAxisSize.min, children: [
      Semantics(
        label: 'Flutter preview oynasi',
        container: true,
        child: Container(
          height: widget.height,
          constraints: const BoxConstraints(maxWidth: 380),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(34),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 10))],
          ),
          padding: const EdgeInsets.all(8),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(27),
            child: MediaQuery(
              data: MediaQuery.of(context).copyWith(padding: const EdgeInsets.only(top: 24), viewPadding: const EdgeInsets.only(top: 24)),
              child: Theme(
                data: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
                child: ColoredBox(color: Colors.white, child: screen),
              ),
            ),
          ),
        ),
      ),
      if (_callbackError != null) ...[
        const SizedBox(height: 10),
        PreviewErrorBox(title: _callbackError!),
      ],
      if (_logs.isNotEmpty) ...[
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 380, maxHeight: 120),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: k.console, borderRadius: BorderRadius.circular(12)),
          child: SingleChildScrollView(
            reverse: true,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Konsol (print)'.uz, style: TextStyle(color: k.textMuted, fontSize: 11, fontWeight: FontWeight.w700)),
              for (final l in _logs) Text(l, style: TextStyle(fontFamily: 'JetBrainsMono', fontSize: 12, color: k.consoleText)),
            ]),
          ),
        ),
      ],
    ]);
  }

  bool _needsApp(Object? root) {
    final rt = _rt;
    if (rt == null) return false;
    if (root is FNode) return root.type != 'MaterialApp';
    // O'quvchi class'i MaterialApp qaytarishi mumkin — bir qadam tekshiramiz.
    if (rt.isStateless(root)) {
      try {
        final built = rt.build(root as KInstance);
        return !(built is FNode && built.type == 'MaterialApp');
      } catch (_) {
        return true;
      }
    }
    return true;
  }
}

class _BareApp extends StatelessWidget {
  const _BareApp({required this.navigatorKey, required this.messengerKey, required this.child});
  final GlobalKey<NavigatorState> navigatorKey;
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  final Widget child;

  @override
  Widget build(BuildContext context) => MaterialApp(
    navigatorKey: navigatorKey,
    scaffoldMessengerKey: messengerKey,
    debugShowCheckedModeBanner: false,
    theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
    home: Material(child: child),
  );
}
