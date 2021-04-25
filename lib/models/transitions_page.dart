import 'package:flutter/material.dart';

class TransitionsPage<T> {
  const TransitionsPage({
    @required this.builder,
    this.fullscreenDialog,
    this.maintainState,
    this.arguments,
    this.hasAnimation = true,
    this.isUserPage = false,
  });

  final WidgetBuilder builder;
  final bool fullscreenDialog;
  final bool maintainState;
  final T arguments;
  final bool hasAnimation;
  final bool isUserPage;
}