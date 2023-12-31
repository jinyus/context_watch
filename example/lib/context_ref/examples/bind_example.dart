import 'package:context_plus/context_plus.dart';
import 'package:flutter/material.dart';

import '../example.dart';

final _counterNotifier = Ref<ValueNotifier<int>>();

class BindExample extends StatelessWidget {
  const BindExample({super.key});

  @override
  Widget build(BuildContext context) {
    final counterNotifier = context.use(() => ValueNotifier(0));
    _counterNotifier.bind(context, counterNotifier);
    return const _Child();
  }
}

class _Child extends StatelessWidget {
  const _Child();

  @override
  Widget build(BuildContext context) {
    return CounterExample(
      counter: _counterNotifier.watch(context),
      onIncrement: () => _counterNotifier.of(context).value += 1,
    );
  }
}
