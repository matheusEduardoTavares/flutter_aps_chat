import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:aps_chat/utils/custom_dialogs/custom_dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersListComponent extends StatelessWidget {
  const UsersListComponent({
    this.tabController,
  });

  final TabController tabController;

  Future<void> _showErrorDialog({
    @required BuildContext context,
    Widget title, 
    Widget content, 
    List<Widget> actions,
  }) => showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    pageBuilder: (_, __, ___) => AlertDialog(
      title: title ?? const Text('Erro'),
      content: content ?? const Text('Você já está em um chat particular com este usuário'),
      actions: actions ?? [
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

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

        return Column(
          children: [
            Expanded(
              child: HomePage.allUsersWithoutMe.isEmpty ? Center(
                child: const Text('Não há nenhum outro usuário além de você'),
              ) : ListView.builder(
                itemCount: HomePage.allUsersWithoutMe.length,
                itemBuilder: (ctx, index) => InkWell(
                  onLongPress: () {
                    print('onLongPress');
                  },
                  onTap: () {
                    _showErrorDialog(
                      context: context,
                    );
                  },
                  child: ListTile(
                    title: Text('${HomePage.allUsersWithoutMe[index]["name"]}'),
                    enabled: allChatsWithMe.where((currentChat) => currentChat['users'].
                      contains(HomePage.allUsersWithoutMe[index].id)).toList().isEmpty,
                    onTap: () async {
                      final isCreateNewChat = await CustomDialogs.confirmationDialog();

                      if (isCreateNewChat == null || !isCreateNewChat) {
                        return;
                      }

                      tabController.animateTo(0);

                      final loggedUser = HomePage.loggedUser;
                      final selectedUser = HomePage.allUsersWithoutMe[index];

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
                        'content': 'Esta conversa é apenas entre você e /${selectedUser.id}/',
                        'isImage': false,
                        'isSystem': true,
                        'userId': 'Global',
                        'createdBy': loggedUser.id,
                      });
                    },
                  ),
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}