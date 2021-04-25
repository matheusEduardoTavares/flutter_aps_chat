import 'dart:async';

import 'package:aps_chat/providers/user_provider/user_provider.dart';
import 'package:aps_chat/utils/db_util.dart';
import 'package:flutter/material.dart';

class Configs with ChangeNotifier {
  var appBrightness = Brightness.light;

  bool get isDarkTheme => appBrightness == Brightness.dark;

  Future<void> changeTheme([UserProvider provider]) async {
    appBrightness = appBrightness == Brightness.dark ? 
      Brightness.light : Brightness.dark;

    notifyListeners();

    if (provider.user != null) {
      final newUser = provider.user.copyWith(isDarkTheme: isDarkTheme);
      await DbUtil.updateData(newUser.toDbMap());
      provider.updateUser(newUser);
    }
  }

  void updateConfig(bool isDarkTheme) {
    appBrightness = isDarkTheme ? Brightness.dark : Brightness.light;

    notifyListeners();
  }
}