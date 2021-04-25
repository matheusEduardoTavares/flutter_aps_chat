import 'package:aps_chat/models/transitions_page.dart';
import 'package:flutter/material.dart';

class DetailsPage {
  const DetailsPage({
    @required this.name,
    @required this.goToNamedRoute,
    @required this.transitionsPage,
    this.leading,
    this.title,
  });

  final String name;
  final String goToNamedRoute;
  final Widget leading;
  final Widget title;
  final TransitionsPage transitionsPage;
}