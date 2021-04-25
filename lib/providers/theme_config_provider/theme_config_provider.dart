import 'dart:async';

import 'package:aps_chat/utils/db_util.dart';
import 'package:flutter/material.dart';

class ThemeConfigProvider with ChangeNotifier {
  var appBrightness = Brightness.light;

  bool get isDarkTheme => appBrightness == Brightness.dark;

  Future<void> changeTheme() async {
    appBrightness = appBrightness == Brightness.dark ? 
      Brightness.light : Brightness.dark;

    notifyListeners();

    await DbUtil.saveTheme(isDarkTheme);
  }

  void updateTheme(bool isDarkTheme) {
    appBrightness = isDarkTheme ? Brightness.dark : Brightness.light;

    notifyListeners();
  }
}