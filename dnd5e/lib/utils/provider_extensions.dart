import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

extension ProviderReadMaybe on BuildContext {
  T? readOrNull<T>() {
    try {
      return read<T>();
    } catch (_) {
      return null;
    }
  }
}