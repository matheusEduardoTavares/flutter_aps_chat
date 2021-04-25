import 'package:aps_chat/models/user.dart';
import 'package:flutter/widgets.dart';

class UserProvider with ChangeNotifier {
  User _user;

  void updateUser(User user) {
    _user = user;

    notifyListeners();
  }

  User get user => _user?.copyWith();
}