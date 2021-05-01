import 'package:aps_chat/widgets/chat_component/chat_component.dart';
import 'package:aps_chat/widgets/user_custom_drawer/user_custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final _users = FirebaseFirestore.instance.collection('users');
  final _loggedUser = FirebaseAuth.instance.currentUser;
  static List<QueryDocumentSnapshot> allUsers;
  static QueryDocumentSnapshot loggedUser;

  final _tabs = [
    Tab(
      child: const Text('Chats'),
      icon: Icon(Icons.message),
    ),
    Tab(
      child: const Text('Usuários'),
      icon: Icon(Icons.people),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Página Inicial'),
          bottom: TabBar(
            tabs: _tabs,
          ),
        ),
        drawer: UserCustomDrawer(),
        body: StreamBuilder(
          stream: _users.snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }

            final QuerySnapshot users = snapshot.data;
            allUsers = users?.docs ?? [];
            final allUsersWithoutMe = (users?.docs ?? [])
              ..removeWhere((user) => user.id == _loggedUser.uid);

            loggedUser = (users?.docs ?? [])
              .firstWhere((user) => user.id == _loggedUser.uid, orElse: () => null);


            if (allUsersWithoutMe.isEmpty) {
              return const Center(
                child: Text('Você ainda não possui usuários cadastrados'),
              );
            }

            return TabBarView(
              children: [
                Center(
                  child: ChatComponent(),
                ),
                Column(
                  children: [
                    const Text('Por enquanto só aparece o nome dos usuários. Em construção também :)'),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.builder(
                        itemCount: allUsersWithoutMe.length,
                        itemBuilder: (ctx, index) => ListTile(
                          // leading: Text('${allUsersWithoutMe[index]["createdAt"]}'),
                          title: Text('${allUsersWithoutMe[index]["name"]}'),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}