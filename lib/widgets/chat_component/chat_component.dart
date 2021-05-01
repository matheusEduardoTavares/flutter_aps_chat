import 'package:aps_chat/utils/pages_configs/pages_configs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatComponent extends StatelessWidget {
  final allChats = FirebaseFirestore.instance.collection('allChats');

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
        
        final chats = data?.docs ?? [];

        final verifyIfGlobalChatExists = chats.firstWhere(
          (chat) => chat.get('name') == 'Global',
          orElse: () => null,
        );

        if (verifyIfGlobalChatExists == null) {
          final globalChat = allChats.doc('Global');
          globalChat.collection('chat').add({
            'content': 'Este chat contém todos os usuários do sistema',
            'userId': 'Global',
            'isImage': false,
            'isSystem': true,
            'createdAt': Timestamp.now(),
          });
          globalChat.set({
            'name': 'Global',
            'createdAt': Timestamp.now(),
          });
        }
        
        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                reverse: true,
                itemCount: chats.length,
                itemBuilder: (ctx, index) => ListTile(
                  title: Center(
                    child: Text(
                      'Chat ${chats[index].get("name")}',
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushNamed(
                      PagesConfigs.chatDataPage,
                      arguments: <String, dynamic>{
                        'docChatName': '${chats[index].id}',
                      },
                    );
                  },
                ),
              ),
            ),
          ],
        );
      }
    );
  }
}