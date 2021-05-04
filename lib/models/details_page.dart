import 'package:flutter/material.dart';
class DetailsPage {
  const DetailsPage({
    @required this.name,
    @required this.goToNamedRoute,
    this.leading,
    this.title,
    this.leadingData,
    this.isPushReplacement,
  });

  final String name;
  final String goToNamedRoute;
  final Widget leading;
  final Widget title;
  final IconData leadingData;
  final bool isPushReplacement;
}