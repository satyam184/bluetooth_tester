import 'package:flutter/material.dart';
import 'package:nrf/utils/widgets/animated_snackbar.dart';

extension BuildContextExtension<T> on BuildContext {
  // text styles
  TextStyle? get displayMedium => Theme.of(this).textTheme.displayMedium;
  TextStyle? get displaySmall => Theme.of(this).textTheme.displaySmall;
  TextStyle? get headineLarge => Theme.of(this).textTheme.headlineLarge;
  TextStyle? get headlineMedium => Theme.of(this).textTheme.headlineMedium;
  TextStyle? get headlineSmall => Theme.of(this).textTheme.headlineSmall;
  TextStyle? get titleLarge => Theme.of(this).textTheme.titleLarge;
  TextStyle? get titleMedium => Theme.of(this).textTheme.titleMedium;
  TextStyle? get titleSmall => Theme.of(this).textTheme.titleSmall;
  TextStyle? get labelLarge => Theme.of(this).textTheme.labelLarge;
  TextStyle? get bodySmall => Theme.of(this).textTheme.bodySmall;
  TextStyle? get bodyMedium => Theme.of(this).textTheme.bodyMedium;
  TextStyle? get bodyLarge => Theme.of(this).textTheme.bodyLarge;
  TextStyle? get labelMedium => Theme.of(this).textTheme.labelMedium;
  TextStyle? get lableSmall => Theme.of(this).textTheme.labelSmall;

  // colors

  Color get primaryColor => Theme.of(this).primaryColor;

  // pop ups

  Future<T?> showBottomSheet(
    Widget child, {
    bool isScrollControlled = true,
    Color? background,
    Color? barrierColor,
  }) {
    return showModalBottomSheet(
      context: this,
      barrierColor: barrierColor,
      isScrollControlled: isScrollControlled,
      backgroundColor: background,
      builder: (context) => Container(),
    );
  }

  void showDefaultSnackbar(String message, Color backgroundColor) {
    AnimatedSnackbar.show(
      context: this,
      message: message,
      backgroundColor: backgroundColor,
    );
  }
}
