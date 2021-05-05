import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:aps_chat/widgets/users_list/users_list.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersLoadingStream extends StatelessWidget {
  const UsersLoadingStream({
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

        return UsersList(
          allChatsWithMe: allChatsWithMe,
          tabController: tabController,
        );
      }
    );
  }
}