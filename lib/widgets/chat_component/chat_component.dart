import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatComponent extends StatelessWidget {
  final allChats = FirebaseFirestore.instance.collection('allChats');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: allChats.orderBy('createdAt', descending: true).snapshots(),
      builder: (ctx, snapshot) {
        return Center(
          child: Text('Em desenvolvimento'),
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final QuerySnapshot data = snapshot.data;
        final chats = data?.docs ?? [];

        // final verifyIfGlobalChatExists = chats.firstWhere(
        //   (chat) => chat.get('name') == 'Global',
        //   orElse: () => null,
        // );

        // if (verifyIfGlobalChatExists == null) {
        //   allChats.doc('Global').get();
        // }
        
        return ListView.builder(
          reverse: true,
          itemCount: chats.length,
          itemBuilder: (ctx, index) => ListTile(
            leading: Text('$index.'),
            title: Text(
              '${chats[index].get("name")}',
            ),
            // onTap: () {
            //   Navigator.of(context)
            //     .pushNamed(

            //       arguments: '${chats[index].get("name")}',
            //     ),
            // },
          ),
        );
      }
    );
  }
}