import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:aps_chat/utils/users_widget/users_widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersListComponent extends StatelessWidget {
  const UsersListComponent({
    this.tabController,
  });

  final TabController tabController;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection('allChats').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final QuerySnapshot data = snapshot.data;
        final chats = data.docs;
        final allChatsWithMe = chats?.where((currentChat) {
          if (currentChat['name'] == 'Global') {
            return false;
          }
          final listUsersIntoChat = List<String>.from(currentChat['users'] ?? []);
          return listUsersIntoChat.contains(HomePage.loggedUser.id);
        })?.toList() ?? [];

        return UsersWidgets(
          allChatsWithMe: allChatsWithMe,
          tabController: tabController,
        );
      }
    );
  }
}