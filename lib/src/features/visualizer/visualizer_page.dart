import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/design_system/adaptive.dart';
import '../../core/design_system/components.dart';
import '../../core/design_system/rich_text.dart';
import '../../core/design_system/tokens.dart';
import '../code/code_controller.dart';
import '../code/code_editor.dart';
import 'visualizer_view.dart';

const _samples = <String, String>{
  'O\'zgaruvchilar': 'void main() {\n  int yosh = 18;\n  yosh = yosh + 1;\n  print(yosh);\n}\n',
  'for sikli': "void main() {\n  var jami = 0;\n  for (var i = 1; i <= 4; i++) {\n    jami += i;\n  }\n  print(jami);\n}\n",
  'if / else': "void main() {\n  var ball = 72;\n  if (ball >= 90) {\n    print('A');\n  } else if (ball >= 70) {\n    print('B');\n  } else {\n    print('C');\n  }\n}\n",
  'Funksiya va rekursiya': 'int faktorial(int n) {\n  if (n <= 1) return 1;\n  return n * faktorial(n - 1);\n}\n\nvoid main() {\n  print(faktorial(4));\n}\n',
  'List bilan ishlash': "void main() {\n  var l = [3, 8, 1];\n  var eng = l[0];\n  for (final x in l) {\n    if (x > eng) eng = x;\n  }\n  print(eng);\n}\n",
  'Class va obyekt': "class Hisob {\n  int balans = 0;\n  void qosh(int s) {\n    balans += s;\n  }\n}\n\nvoid main() {\n  var h = Hisob();\n  h.qosh(100);\n  h.qosh(50);\n  print(h.balans);\n}\n",
};

class VisualizerPage extends StatefulWidget {
  const VisualizerPage({super.key, this.initialCode});
  final String? initialCode;

  @override
  State<VisualizerPage> createState() => _VisualizerPageState();
}

class _VisualizerPageState extends State<VisualizerPage> {
  late final _ctrl = CodeEditingController(text: widget.initialCode ?? _samples.values.first);
  String? _visualized;

  @override
  void initState() {
    super.initState();
    _visualized = _ctrl.text;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    extendBodyBehindAppBar: true,
    appBar: KTopBar(title: 'Kod vizualizatori', onBack: () => context.canPop() ? context.pop() : context.go('/practice'), showBack: !context.isExpanded),
    body: Builder(builder: (context) => ListView(
      padding: pagePadding(context),
      children: [
        ContentWidth(
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            RichUz('Kodni yozing yoki namunani tanlang, so\'ng **Vizualizatsiya** tugmasini bosing. Har bir qadam interpretator haqiqatda bajargan amaldir.',
                style: context.text.bodyMedium),
            const SizedBox(height: 12),
            Wrap(spacing: 8, runSpacing: 8, children: [
              for (final e in _samples.entries)
                ActionChip(
                  label: Text(e.key.uz),
                  onPressed: () => setState(() {
                    _ctrl.text = e.value;
                    _visualized = e.value;
                  }),
                ),
            ]),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(KRadius.lg),
              child: KitobCodeEditor(controller: _ctrl, expands: false, minLines: 6, onRun: () => setState(() => _visualized = _ctrl.text)),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerLeft,
              child: KButton(label: 'Vizualizatsiya', icon: Icons.slow_motion_video_rounded, onPressed: () => setState(() => _visualized = _ctrl.text)),
            ),
            const SizedBox(height: 16),
            if (_visualized != null) VisualizerView(key: ValueKey(_visualized), code: _visualized!),
          ]),
        ),
      ],
    )),
  );
}
