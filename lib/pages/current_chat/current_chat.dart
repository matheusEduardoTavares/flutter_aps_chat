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

    _chatCollection = FirebaseFirestore.instance.collection('allChats').doc(widget.docChatStream)
      .collection('chat');
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _chatCollection.orderBy('createdAt', descending: true).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        final QuerySnapshot data = snapshot.data ?? [];
        final List<QueryDocumentSnapshot> texts = data?.docs ?? [];

        var finalChatName = widget.docChatName;

        if (finalChatName.contains(',')) {
          finalChatName = finalChatName.substring(finalChatName.indexOf(','), finalChatName.length);
        }
        
        return Scaffold(
          appBar: MediaQuery.of(context).orientation == Orientation.portrait ? AppBar(
            title: Text(finalChatName),
          ) : null,
          body: ChatPage(
            items: texts,
            chatCollection: _chatCollection,
          ),
        );
      }
    );
  }
}