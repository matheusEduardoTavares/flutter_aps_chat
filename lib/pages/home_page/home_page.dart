import 'package:aps_chat/utils/custom_dialogs/custom_dialogs.dart';
import 'package:aps_chat/widgets/chat_component/chat_component.dart';
import 'package:aps_chat/widgets/user_custom_drawer/user_custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static List<QueryDocumentSnapshot> allUsers;
  static QueryDocumentSnapshot loggedUser;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _users = FirebaseFirestore.instance.collection('users');
  TabController _tabController;

  final _loggedUser = FirebaseAuth.instance.currentUser;

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
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: _tabs.length);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Inicial'),
        bottom: TabBar(
          controller: _tabController,
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
          HomePage.allUsers = users?.docs ?? [];
          final allUsersWithoutMe = (users?.docs ?? [])
            ..removeWhere((user) => user.id == _loggedUser.uid);

          HomePage.loggedUser = (users?.docs ?? [])
            .firstWhere((user) => user.id == _loggedUser.uid, orElse: () => null);

          return TabBarView(
            controller: _tabController,
            children: [
              Center(
                child: ChatComponent(),
              ),
              Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: allUsersWithoutMe.length,
                      itemBuilder: (ctx, index) => ListTile(
                        title: Text('${allUsersWithoutMe[index]["name"]}'),
                        onTap: () async {
                          final isCreateNewChat = await CustomDialogs.confirmationDialog();

                          if (isCreateNewChat == null || !isCreateNewChat) {
                            return;
                          }

                          _tabController.animateTo(0);

                          final loggedUser = HomePage.loggedUser;
                          final selectedUser = allUsersWithoutMe[index];

                          final newChat = FirebaseFirestore.instance.collection('allChats').doc(
                            '${loggedUser.id}, ${selectedUser.id}'
                          );

                          await newChat.set({
                            'createdAt': Timestamp.now(),
                            'name': '${selectedUser['name']}',
                            'users': [
                              loggedUser.id,
                              selectedUser.id
                            ],
                          });

                          final newCollection = newChat.collection('chat');
                          newCollection.add({
                            'createdAt': Timestamp.now(),
                            'content': 'Esta conversa é apenas entre você e ${selectedUser['name']}',
                            'isImage': false,
                            'isSystem': true,
                            'userId': 'Global',
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        }
      ),
    );
  }
}