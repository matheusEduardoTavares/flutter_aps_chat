import 'package:aps_chat/pages/chat_page/chat_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CurrentChat extends StatefulWidget {
  const CurrentChat({
    @required this.docChatName,
    this.docChatStream,
  });

  final String docChatName;
  final String docChatStream;

  @override
  _CurrentChatState createState() => _CurrentChatState();
}

class _CurrentChatState extends State<CurrentChat> {
  CollectionReference _chatCollection;

  @override 
  void initState() {
    super.initState();

    _chatCollection = FirebaseFirestore.instance.collection('allChats').doc(widget.docChatName)
      .collection('chat');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _chatCollection.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final QuerySnapshot data = snapshot.data ?? [];
        final List<QueryDocumentSnapshot> texts = data?.docs ?? [];
        
        return Scaffold(
          appBar: AppBar(
            title: Text(widget.docChatName),
          ),
          body: ChatPage(
            items: texts,
            chatCollection: _chatCollection,
          ),
        );
      }
    );
  }
}