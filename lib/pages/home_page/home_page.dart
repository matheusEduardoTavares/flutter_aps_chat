import 'package:aps_chat/widgets/chat_component/chat_component.dart';
import 'package:aps_chat/widgets/user_custom_drawer/user_custom_drawer.dart';
import 'package:aps_chat/widgets/users_list_component/users_list_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  static List<QueryDocumentSnapshot> allUsers;
  static List<QueryDocumentSnapshot> allUsersWithoutMe;
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
          final usersOtherMemoryAddress = List<QueryDocumentSnapshot>.from(HomePage.allUsers);
          HomePage.allUsersWithoutMe = (usersOtherMemoryAddress ?? [])
            ..removeWhere((user) => user.id == _loggedUser.uid);

          HomePage.loggedUser = (users?.docs ?? [])
            .firstWhere((user) => user.id == _loggedUser.uid, orElse: () => null);

          return TabBarView(
            controller: _tabController,
            children: [
              Center(
                child: ChatComponent(),
              ),
              UsersListComponent(
                tabController: _tabController,
              ),
            ],
          );
        }
      ),
    );
  }
}