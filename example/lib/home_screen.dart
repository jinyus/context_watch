import 'package:flutter/material.dart';
import 'package:url_router/url_router.dart';

import 'context_watch/benchmark_screen.dart';
import 'context_watch/hot_reload_test_screen.dart';
import 'examples/context_ref_bind_example_screen.dart';
import 'examples/context_ref_bind_value_example_screen.dart';
import 'examples/context_ref_nested_scopes_example_screen.dart';

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
                title: 'context_ref',
                children: [
                  OutlinedButton(
                    onPressed: () => context.url = BindExampleScreen.urlPath,
                    child: const Text('Ref.bind()'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () =>
                        context.url = BindValueExampleScreen.urlPath,
                    child: const Text('Ref.bindValue()'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () =>
                        context.url = NestedScopesExampleScreen.urlPath,
                    child: const Text('Nested Scopes'),
                  ),
                ],
              ),
              _Group(
                title: 'context_watch',
                children: [
                  OutlinedButton(
                    onPressed: () => context.url = BenchmarkScreen.urlPath,
                    child: const Text('Benchmark'),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => context.url = HotReloadTestScreen.urlPath,
                    child: const Text('Hot Reload Test'),
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
