import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:aps_chat/pages/message_component/message_component.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({
    @required this.items,
    @required this.chatCollection,
    Key key,
  }) : super(key: key);

  final List<QueryDocumentSnapshot> items;
  final CollectionReference chatCollection;

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  String _message = '';
  TextEditingController _messageController;

  @override 
  void initState() {
    super.initState();

    _messageController = TextEditingController();
  }
  
  Future<void> _showErrorDialog() => showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    pageBuilder: (_, __, ___) => AlertDialog(
      title: Text('Erro'),
      content: Text('Erro ao enviar a mensagem. Consulte um administrador'),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: widget.items.length,
            itemBuilder: (ctx, index) => MessageComponent(
              content: widget.items[index]['content'],
              belongsToMe: HomePage.loggedUser.id == widget.items[index]['userId'],
              userId: widget.items[index]['userId'],
              isImage: widget.items[index]['isImage'],
              isSystem: widget.items[index]['isSystem'],
              createdAt: widget.items[index]['createdAt'],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Digite uma mensagem',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  controller: _messageController,
                  textCapitalization: TextCapitalization.sentences,
                  onChanged: (value) {
                    setState(() {
                      _message = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              FloatingActionButton(
                child: const Icon(
                  Icons.send,
                  size: 30,
                ),
                backgroundColor: _message.isEmpty ? Colors.grey : null,
                onPressed: _message.isEmpty ? null : () {
                  try {
                    widget.chatCollection.add({
                      'userId': HomePage.loggedUser.id,
                      'content': _message,
                      'isImage': false,
                      'isSystem': false,
                      'createdAt': Timestamp.now(),
                    });

                    setState(() {
                      _message = '';
                      _messageController.clear();
                    });
                  }
                  catch (_) {
                    _showErrorDialog();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override 
  void dispose() {
    _messageController?.dispose();

    super.dispose();
  }
}