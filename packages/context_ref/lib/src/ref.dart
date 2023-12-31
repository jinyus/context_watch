import 'package:flutter/widgets.dart';

import 'context_ref_root.dart';

abstract interface class ReadOnlyRef<T> {}

class Ref<T> implements ReadOnlyRef<T> {
  Ref(); // Must not be const

  T bind(BuildContext context, T value) {
    ContextRefRoot.of(context).bind(
      context: context,
      ref: this,
      provider: () => value,
    );
    return value;
  }

  void bindLazy(
    BuildContext context,
    T Function() provider,
  ) {
    ContextRefRoot.of(context).bind(
      context: context,
      ref: this,
      provider: provider,
    );
  }

  ReadOnlyRef<T> get readOnly => this;
}

extension ContextRefExt<T> on ReadOnlyRef<T> {
  T of(BuildContext context) => ContextRefRoot.of(context).get(context, this);
}
