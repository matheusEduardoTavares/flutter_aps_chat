import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

abstract class UserUtilities {
  static QueryDocumentSnapshot getUserById(String id) {
    final user = HomePage.allUsers.firstWhere((us) => us.id == id, orElse: () => null);

    return user;
  }
}