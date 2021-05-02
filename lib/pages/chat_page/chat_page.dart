import 'dart:async';

import 'package:aps_chat/utils/check_internet_connection/check_internet_connection.dart';
import 'package:aps_chat/utils/custom_dialogs/custom_dialogs.dart';
import 'package:aps_chat/widgets/buttons_upload/buttons_upload.dart';
import 'package:aps_chat/widgets/message_component/message_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

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
  var _isKeyboardOpen = false;
  KeyboardVisibilityNotification keyboardListener;
  String _message = '';
  TextEditingController _messageController;
  final _scrollController = ScrollController();

  @override 
  void initState() {
    super.initState();

    keyboardListener = KeyboardVisibilityNotification()..
      addNewListener(
        onChange: (bool visible) {
          setState(() {
            _isKeyboardOpen = visible;
          });
        },
      );

    _messageController = TextEditingController();
  }
  
  Future<void> _showErrorDialog({Widget title, Widget content, List<Widget> actions}) => showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    pageBuilder: (_, __, ___) => AlertDialog(
      title: title ?? const Text('Erro'),
      content: content ?? const Text('Erro ao enviar a mensagem. Consulte um administrador'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            controller: _scrollController,
            itemCount: widget.items.length,
            itemBuilder: (ctx, index) => MessageComponent(
              content: widget.items[index]['content'],
              belongsToMe: HomePage.loggedUser.id == widget.items[index]['userId'],
              userId: widget.items[index]['userId'],
              isImage: widget.items[index]['isImage'],
              isSystem: widget.items[index]['isSystem'],
              createdAt: widget.items[index]['createdAt'],
              createdBy: widget.items[index]['createdBy'],
            ),
          ),
        ),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            children: [
              if (!_isKeyboardOpen)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          //Todo: Colocar as imagens capturadas aqui
                        ],
                      ),
                      ButtonsUpload()
                    ],
                  ),
                ),
              Row(
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
                    backgroundColor: _message?.trim()?.isEmpty ?? true ? Colors.grey : null,
                    onPressed: _message?.trim()?.isEmpty ?? true ? null : () async {
                      bool hasFilterMessage = false;
                      try {
                        if (_message.length > 1200) {
                          final isConfirmContinue = await CustomDialogs.confirmationDialog(
                            title: const Text('Aviso de perda de informações'),
                            content: const Text(
                              'O texto digitado é muito grande. O limite são 1200 caracteres.'
                              ' Confirme se deseja enviar a mensagem mesmo assim. '
                              'Será enviado apenas os primeiros 1200 caracteres'
                            ),
                          );

                          if (isConfirmContinue == null || !isConfirmContinue) {
                            return;
                          }

                          hasFilterMessage = true;
                        }

                        widget.chatCollection.add({
                          'userId': HomePage.loggedUser.id,
                          'content': hasFilterMessage ? _message?.trim()?.substring(0, 1200) : _message?.trim(),
                          'isImage': false,
                          'isSystem': false,
                          'createdAt': Timestamp.now(),
                          'createdBy': HomePage.loggedUser.id,
                        });

                        setState(() {
                          _message = '';
                          _messageController.clear();
                        });

                        final hasInternet = await CheckInternetConnection.hasInternetConnection();

                        if (!hasInternet) {
                          _showErrorDialog(
                            title: const Text('Sem conexão'),
                            content: const Text('Você está sem conexão com a internet no momento.'
                              ' Assim que possuir internet a mensagem será enviada'
                            )
                          );
                        }

                        Timer(
                          Duration(milliseconds: 300),
                          () => _scrollController
                              .jumpTo(_scrollController.position.minScrollExtent));

                        // _scrollController.animateTo(_scrollController.position.maxScrollExtent, duration: Duration(seconds: 2), curve: Curves.fastOutSlowIn);  
                      }
                      catch (_) {
                        _showErrorDialog();
                      }
                    },
                  )
                ],
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
    keyboardListener?.dispose();

    super.dispose();
  }
}