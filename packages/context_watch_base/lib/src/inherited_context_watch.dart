import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

typedef WatchSelector = Object? Function(Object? value);

abstract interface class ContextWatchSubscription {
  void cancel();
}

enum ContextWatchSelectorParameterType {
  value,
  observable,
}

abstract class ContextWatcher<TObservable extends Object> {
  var _rebuildIfNeeded = InheritedContextWatchElement._neverRebuild;

  bool _canHandle(Object observable) => observable is TObservable;

  /// Triggers a rebuild of the [context] if it is interested in the [observable]
  /// value change notification.
  @protected
  @nonVirtual
  void rebuildIfNeeded(
    BuildContext context,
    Object observable, {
    required Object? value,
    ContextWatchSelectorParameterType selectorParameterType =
        ContextWatchSelectorParameterType.value,
  }) =>
      _rebuildIfNeeded(
        context,
        observable,
        value: value,
        selectorParameterType: selectorParameterType,
      );

  @protected
  @useResult
  ContextWatchSubscription createSubscription<T>(
    BuildContext context,
    TObservable observable,
  );
}

class InheritedContextWatch extends InheritedWidget {
  const InheritedContextWatch({
    super.key,
    required this.watchers,
    required super.child,
  });

  final List<ContextWatcher> watchers;

  static InheritedContextWatchElement of(BuildContext context) {
    final element =
        context.getElementForInheritedWidgetOfExactType<InheritedContextWatch>()
            as InheritedContextWatchElement?;
    assert(
      element != null,
      'No InheritedContextWatch found. Did you forget to add a ContextWatchRoot widget?',
    );
    return element!;
  }

  @override
  InheritedContextWatchElement createElement() =>
      InheritedContextWatchElement(this);

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}

class InheritedContextWatchElement extends InheritedElement {
  InheritedContextWatchElement(super.widget) {
    for (final watcher in (widget as InheritedContextWatch).watchers) {
      watcher._rebuildIfNeeded = _rebuildIfNeeded;
    }
    SchedulerBinding.instance
        .addPostFrameCallback((_) => _isFirstFrame = false);
  }

  bool _isFirstFrame = true;

  final _contextData = HashMap<BuildContext, _ContextData>.identity();

  bool get _isBuildPhase {
    final phase = SchedulerBinding.instance.schedulerPhase;
    return phase == SchedulerPhase.persistentCallbacks ||
        _isFirstFrame && phase == SchedulerPhase.idle;
  }

  Duration get _currentFrameTimeStamp {
    if (_isFirstFrame) {
      return Duration.zero;
    }
    return SchedulerBinding.instance.currentFrameTimeStamp;
  }

  @override
  void updated(covariant InheritedContextWatch oldWidget) {
    super.updated(oldWidget);
    for (final watcher in oldWidget.watchers) {
      watcher._rebuildIfNeeded = _neverRebuild;
    }
    for (final watcher in (widget as InheritedContextWatch).watchers) {
      watcher._rebuildIfNeeded = _rebuildIfNeeded;
    }
  }

  @nonVirtual
  ContextWatchSubscription? watch<T>(
    BuildContext context,
    Object observable, {
    dynamic selector,
  }) {
    // Make [context] dependent on this element so that we can get notified
    // when the [context] is removed from the tree.
    context.dependOnInheritedElement(this);

    final contextData = _fetchContextData(context);
    if (contextData == null) {
      return null;
    }

    contextData.observableLastFrame[observable] = _currentFrameTimeStamp;

    if (selector != null) {
      final selectors = contextData.observableSelectors[observable] ??= {};
      selectors.add(selector);
    } else {
      contextData.entirelyWatchedObservables.add(observable);
    }

    final existingSubscription =
        contextData.observableSubscriptions[observable];
    if (existingSubscription != null) {
      return existingSubscription;
    }

    final watcher = (super.widget as InheritedContextWatch)
        .watchers
        .firstWhere((element) => element._canHandle(observable), orElse: () {
      throw UnsupportedError(
        'No ContextWatcher found for ${observable.runtimeType}',
      );
    });
    final subscription = watcher.createSubscription<T>(context, observable);
    contextData.observableSubscriptions[observable] = subscription;
    return subscription;
  }

  @nonVirtual
  void updateContextLastFrame(BuildContext context) {
    _fetchContextData(context);
  }

  @nonVirtual
  _ContextData? _fetchContextData(BuildContext context) {
    if (!_isBuildPhase) {
      // Don't update subscriptions outside of the widget's build() method
      return null;
    }

    final contextData = _contextData[context] ??= _ContextData();
    final frame = _currentFrameTimeStamp;

    if (contextData.lastFrame != frame) {
      // It's a new frame, so let's clear all selectors as they might've changed
      contextData.observableSelectors.clear();
      contextData.entirelyWatchedObservables.clear();
      contextData.lastFrame = frame;
    }
    return contextData;
  }

  @override
  void removeDependent(Element dependent) {
    _unwatchContext(dependent);
    super.removeDependent(dependent);
  }

  @override
  void unmount() {
    for (final contextData in _contextData.values) {
      for (final subscription in contextData.observableSubscriptions.values) {
        subscription.cancel();
      }
    }
    _contextData.clear();
    for (final watcher in (widget as InheritedContextWatch).watchers) {
      watcher._rebuildIfNeeded = _neverRebuild;
    }
    super.unmount();
  }

  static void _neverRebuild(
    BuildContext context,
    Object observable, {
    required Object? value,
    required ContextWatchSelectorParameterType selectorParameterType,
  }) {}

  void _rebuildIfNeeded(
    BuildContext context,
    Object observable, {
    required Object? value,
    required ContextWatchSelectorParameterType selectorParameterType,
  }) {
    if (!context.mounted) {
      _unwatch(context, observable);
      return;
    }

    final contextData = _contextData[context];
    if (contextData == null) {
      _unwatch(context, observable);
      return;
    }

    final contextLastFrame = contextData.lastFrame;
    final observableLastFrame = contextData.observableLastFrame[observable];
    if (observableLastFrame != contextLastFrame) {
      _unwatch(context, observable);
      return;
    }

    final isWatchedEntirely =
        contextData.entirelyWatchedObservables.contains(observable);
    final selectors = contextData.observableSelectors[observable];

    final oldSelectedValues = contextData.observableSelectedValues[observable];
    if (selectors == null || selectors.isEmpty) {
      /// `watchOnly()` was_not used during the last build

      final shouldRebuild =
          // If `watch()` was used during the last build, we need to rebuild
          isWatchedEntirely ||
              // If `watchOnly()` was used before, but not anymore, we need to rebuild
              oldSelectedValues != null && oldSelectedValues.isNotEmpty;
      contextData.observableSelectedValues.remove(observable);
      if (shouldRebuild) {
        (context as Element).markNeedsBuild();
      }
      return;
    }

    /// `watchOnly()` was used during the last build
    final newSelectedValues = switch (selectorParameterType) {
      ContextWatchSelectorParameterType.value => <Object?>[
          for (final selector in selectors)
            _select(selector: selector, argument: value),
        ],
      ContextWatchSelectorParameterType.observable => <Object?>[
          for (final selector in selectors)
            _select(selector: selector, argument: observable),
        ],
    };
    final shouldRebuild =
        // If `watch()` was used during the last build, we need to rebuild
        isWatchedEntirely ||
            // If old and new selected values are different, we need to rebuild
            !listEquals(newSelectedValues, oldSelectedValues);
    contextData.observableSelectedValues[observable] = newSelectedValues;
    if (shouldRebuild) {
      (context as Element).markNeedsBuild();
    }
  }

  void _unwatch(
    BuildContext context,
    Object observable,
  ) {
    final contextData = _contextData[context];
    if (contextData == null) {
      return;
    }

    final subscription = contextData.observableSubscriptions.remove(observable);
    subscription?.cancel();
  }

  void _unwatchContext(BuildContext context) {
    final contextData = _contextData.remove(context);
    if (contextData == null) {
      return;
    }

    for (final subscription in contextData.observableSubscriptions.values) {
      subscription.cancel();
    }
  }
}

class _ContextData {
  Duration? lastFrame;
  final observableLastFrame = HashMap<Object, Duration>.identity();
  final observableSubscriptions =
      HashMap<Object, ContextWatchSubscription>.identity();
  final observableSelectors =
      // Observable -> {Object? Function(Object?)}
      HashMap<Object, Set<dynamic>>.identity();
  final observableSelectedValues =
      // Observable -> Selected values
      HashMap<Object, List<Object?>?>.identity();
  final entirelyWatchedObservables = HashSet<Object>.identity();
}

Object? _select({
  required dynamic selector,
  required Object? argument,
}) {
  if (argument == null) {
    return null;
  }
  return selector(argument);
}
