import 'package:context_plus/context_plus.dart';
import 'package:flutter/material.dart';

import '../../other/example.dart';

final _counterNotifier = Ref<ValueNotifier<int>>();

class Example extends StatelessWidget {
  const Example({super.key});

  @override
  Widget build(BuildContext context) {
    _counterNotifier.bind(context, () => ValueNotifier(0));
    return const _Child1();
  }
}

class _Child1 extends StatelessWidget {
  const _Child1();

  @override
  Widget build(BuildContext context) {
    return const _Child2();
  }
}

class _Child2 extends StatelessWidget {
  const _Child2();

  @override
  Widget build(BuildContext context) {
    return CounterExample(
      onTap: () => _counterNotifier.of(context).value += 1,
      counter: _counterNotifier.watch(context),
    );
  }
}
