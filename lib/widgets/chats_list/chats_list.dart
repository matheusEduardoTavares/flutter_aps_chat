import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:aps_chat/utils/details_pages/details_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatsList extends StatelessWidget {
  final allChats = FirebaseFirestore.instance.collection('allChats');

  String _getOtherUserName(QueryDocumentSnapshot user) {
    List<String> users = user.id.split(', ');
    final listUsers = List<QueryDocumentSnapshot>.from(HomePage.allUsersWithoutMe);
    if (users == null || users.isEmpty || users.first == 'Global') {
      return user['name'];
    }

    else if (users.length == 2) {
      users.removeWhere((userId) => userId == HomePage.loggedUser.id);
      final user = listUsers.firstWhere((us) => us.id == users.first);
      return user['name'];
    }

    users.removeWhere((userId) => userId == HomePage.loggedUser.id);
    String message = '';
    for (final us in users) {
      final internalUser = listUsers.firstWhere((usFunction) => usFunction.id == us);
      message += '${internalUser["name"]}, ';
    }
    final allUsersOnGroup = message.substring(0, message.length - 2);
    return allUsersOnGroup;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: allChats.orderBy('createdAt', descending: true).snapshots(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final QuerySnapshot data = snapshot.data;
        
        final chats = data?.docs;

        final verifyIfGlobalChatExists = chats?.firstWhere(
          (chat) => chat.get('name') == 'Global',
          orElse: () => null,
        ) ?? null;

        if (verifyIfGlobalChatExists == null) {
          final globalChat = allChats.doc('Global');
          globalChat.collection('chat').add({
            'content': 'Este chat contém todos os usuários do sistema',
            'userId': 'Global',
            'isImage': false,
            'isSystem': true,
            'createdAt': Timestamp.now(),
            'createdBy': 'Global',
          });
          globalChat.set({
            'name': 'Global',
            'createdAt': Timestamp.now(),
            'users': [],
          });
        }

        final chatsAssociatedsWithMe = chats?.where(
          (chat) {
            final List containedUsers = chat['users'];
            return containedUsers == null || containedUsers.isEmpty || containedUsers.contains(HomePage.loggedUser.id);
          }
        )?.toList() ?? [];
        
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: chatsAssociatedsWithMe.length,
                itemBuilder: (ctx, index) {
                  final usersOnChat = List<String>.from(chatsAssociatedsWithMe[index]['users']);
                  return Card(
                    elevation: 5,
                    child: ListTile(
                      title: Text(
                        '${_getOtherUserName(chatsAssociatedsWithMe[index])}',
                        textAlign: TextAlign.end,
                      ),
                      leading: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            usersOnChat.isEmpty ? 'Todos usuários' : (
                              usersOnChat.length == 2 ? 'Privado' : 'Grupo'
                            ),
                            style: TextStyle(color: Theme.of(context).accentColor),
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pushNamed(
                          DetailsPages.chatDataPage,
                          arguments: <String, dynamic>{
                            'docChatName': _getOtherUserName(chatsAssociatedsWithMe[index]),
                            'docChatStream': '${chatsAssociatedsWithMe[index].id}',
                          },
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }
    );
  }
}