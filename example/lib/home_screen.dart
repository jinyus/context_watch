import 'package:example/examples/context_plus_screen_state_example_screen.dart';
import 'package:example/examples/context_watch_listenable_example_screen.dart';
import 'package:example/examples/counter_with_propagation_example_screen.dart';
import 'package:flutter/material.dart';
import 'package:url_router/url_router.dart';

import 'benchmarks/context_watch/benchmark_screen.dart';
import 'examples/rainbow_example_screen.dart';
import 'examples/context_ref_bind_example_screen.dart';
import 'examples/context_ref_bind_value_example_screen.dart';
import 'examples/context_ref_nested_scopes_example_screen.dart';
import 'examples/context_watch_example_screen.dart';
import 'examples/counter_example_screen.dart';
import 'other/context_watch_hot_reload_test_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('context_plus'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            alignment: WrapAlignment.center,
            spacing: 24,
            runSpacing: 24,
            children: [
              _Group(
                title: 'Examples',
                children: [
                  OutlinedButton(
                    onPressed: () => context.url = CounterExampleScreen.urlPath,
                    child: const Text(CounterExampleScreen.title),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.url =
                        CounterWithPropagationExampleScreen.urlPath,
                    child:
                        const Text(CounterWithPropagationExampleScreen.title),
                  ),
                ],
              ),
              _Group(
                title: 'context_ref',
                children: [
                  OutlinedButton(
                    onPressed: () => context.url = BindExampleScreen.urlPath,
                    child: const Text(BindExampleScreen.title),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () =>
                        context.url = BindValueExampleScreen.urlPath,
                    child: const Text(BindValueExampleScreen.title),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () =>
                        context.url = NestedScopesExampleScreen.urlPath,
                    child: const Text(NestedScopesExampleScreen.title),
                  ),
                ],
              ),
              _Group(
                title: 'context_watch',
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        context.url = ContextWatchExampleScreen.urlPath,
                    child: const Text(ContextWatchExampleScreen.title),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.url =
                        ContextWatchListenableExampleScreen.urlPath,
                    child:
                        const Text(ContextWatchListenableExampleScreen.title),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.url = BenchmarkScreen.urlPath,
                    child: const Text(BenchmarkScreen.title),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () =>
                        context.url = ContextWatchHotReloadTestScreen.urlPath,
                    child: const Text(ContextWatchHotReloadTestScreen.title),
                  ),
                ],
              ),
              _Group(
                title: 'context_plus',
                children: [
                  OutlinedButton(
                    onPressed: () =>
                        context.url = ContextPlusBindWatchExampleScreen.urlPath,
                    child: const Text(ContextPlusBindWatchExampleScreen.title),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.url =
                        ContextPlusScreenStateExampleScreen.urlPath,
                    child:
                        const Text(ContextPlusScreenStateExampleScreen.title),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({
    required this.title,
    required this.children,
  });

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Theme.of(context).colorScheme.primary,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}
