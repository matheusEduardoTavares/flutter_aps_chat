import 'dart:async';
import 'dart:io';

import 'package:aps_chat/utils/check_internet_connection/check_internet_connection.dart';
import 'package:aps_chat/utils/custom_dialogs/custom_dialogs.dart';
import 'package:aps_chat/widgets/buttons_upload/buttons_upload.dart';
import 'package:aps_chat/widgets/message_component/message_component.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:keyboard_visibility/keyboard_visibility.dart';

import 'package:path/path.dart' as path;

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
  final _cameraPaths = <String>[];
  final _filesGallery = <File>[];
  final _allFiles = <File>[];
  var _isKeyboardOpen = false;
  KeyboardVisibilityNotification keyboardListener;
  String _message = '';
  TextEditingController _messageController;
  final _scrollController = ScrollController();
  FocusNode _messageFocus;

  @override 
  void initState() {
    super.initState();

    _messageFocus = FocusNode();

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

  void _addImages(List<String> newPaths) {
    setState(() {
      _cameraPaths.addAll(newPaths);
    });
  }

  void _addGalleryImages(List<File> newFiles) {
    setState(() {
      _filesGallery.addAll(newFiles);
    });

  }
  void _addFiles(List<File> newFiles) {
    setState(() {
      _allFiles.addAll(newFiles);
    });
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

  Widget _buildImage(String path) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: InkWell(
        onTap: () async {
          final isConfirmClose = await CustomDialogs.confirmationDialog(
            content: const Text('Confirma a deleção desta imagem ?'),
          );

          if (isConfirmClose != null && isConfirmClose) {
            setState(() {
              _cameraPaths.removeAt(_cameraPaths.indexOf(path));
            });
          }
        },
        child: CircleAvatar(
          backgroundImage: FileImage(
            File(path),
          ),
        ),
      ),
    );
  }

  Widget _buildGalleryImage(File file) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: InkWell(
        onTap: () async {
          final isConfirmClose = await CustomDialogs.confirmationDialog(
            content: const Text('Confirma a deleção desta imagem ?'),
          );

          if (isConfirmClose != null && isConfirmClose) {
            setState(() {
              _filesGallery.removeAt(_filesGallery.indexOf(file));
            });
          }
        },
        child: CircleAvatar(
          backgroundImage: FileImage(
            file,
          ),
        ),
      ),
    );
  }

  Widget _buildAllFiles(File file) {
    return Padding(
      padding: const EdgeInsets.only(left: 5.0),
      child: InkWell(
        onTap: () async {
          final isConfirmClose = await CustomDialogs.confirmationDialog(
            content: Text('Confirma a deleção do arquivo ${path.basename(file.path)}?'),
          );

          if (isConfirmClose != null && isConfirmClose) {
            setState(() {
              _allFiles.removeAt(_allFiles.indexOf(file));
            });
          }
        },
        child: Container(
          width: 60,
          child: Column(
            children: [
              Icon(
                Icons.file_copy,
                size: 40,
                color: Theme.of(context).accentColor,
              ),
              FittedBox(
                child: Text(
                  '${path.basename(file.path)}',
                  style: TextStyle(color: Theme.of(context).accentColor)
                )
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _sendMessage() async {
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

      if (_message?.trim()?.isNotEmpty ?? false) {
        widget.chatCollection.add({
          'userId': HomePage.loggedUser.id,
          'content': hasFilterMessage ? _message?.trim()?.substring(0, 1200) : _message?.trim(),
          'isImage': false,
          'isFile': false,
          'isSystem': false,
          'filename': '',
          'createdAt': Timestamp.now(),
          'createdBy': HomePage.loggedUser.id,
        });
      }

      for (var currentIndex = 0; currentIndex < _cameraPaths.length; currentIndex++) {
        if (currentIndex == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              content: Text('Iniciando o envio das imagens capturadas para o servidor ...', style: TextStyle(color: Colors.white)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              padding: const EdgeInsets.all(10.0),
              elevation: 5,
              width: MediaQuery.of(context).size.width * 0.8,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        final ref = FirebaseStorage.instance.ref()
          .child('images_chat_take')
          .child(_cameraPaths[currentIndex]);

        await ref.putFile(File(_cameraPaths[currentIndex]));
        final url = await ref.getDownloadURL();

        await widget.chatCollection.add({
          'userId': HomePage.loggedUser.id,
          'content': url,
          'isImage': true,
          'isFile': false,
          'isSystem': false,
          'filename': '',
          'createdAt': Timestamp.now(),
          'createdBy': HomePage.loggedUser.id,
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            content: Text('Imagem capturada ${currentIndex + 1} / ${_cameraPaths.length} enviada !!', style: TextStyle(color: Colors.white)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.all(10.0),
            elevation: 5,
            width: MediaQuery.of(context).size.width * 0.8,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      for (var currentIndex = 0; currentIndex < _filesGallery.length; currentIndex++) {
        if (currentIndex == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              content: Text('Iniciando o envio das imagens da galeria para o servidor ...', style: TextStyle(color: Colors.white)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              padding: const EdgeInsets.all(10.0),
              elevation: 5,
              width: MediaQuery.of(context).size.width * 0.8,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        final ref = FirebaseStorage.instance.ref()
          .child('images_chat_gallery')
          .child(_filesGallery[currentIndex].path);

        await ref.putFile(_filesGallery[currentIndex]);
        final url = await ref.getDownloadURL();

        await widget.chatCollection.add({
          'userId': HomePage.loggedUser.id,
          'content': url,
          'isImage': true,
          'isFile': false,
          'isSystem': false,
          'filename': '',
          'createdAt': Timestamp.now(),
          'createdBy': HomePage.loggedUser.id,
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            content: Text('Imagem da galeria ${currentIndex + 1} / ${_filesGallery.length} enviada !!', style: TextStyle(color: Colors.white)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0)
            ),
            padding: const EdgeInsets.all(10.0),
            elevation: 5,
            width: MediaQuery.of(context).size.width * 0.8,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      for (var currentIndex = 0; currentIndex < _allFiles.length; currentIndex++) {
        if (currentIndex == 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              backgroundColor: Theme.of(context).primaryColor,
              content: const Text('Iniciando o envio dos arquivos para o servidor ...', style: TextStyle(color: Colors.white)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
              padding: const EdgeInsets.all(10.0),
              elevation: 5,
              width: MediaQuery.of(context).size.width * 0.8,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        final filename = path.basename(_allFiles[currentIndex].path);

        final ref = FirebaseStorage.instance.ref()
          .child('files')
          .child(filename);

        await ref.putFile(_allFiles[currentIndex]);
        final url = await ref.getDownloadURL();

        await widget.chatCollection.add({
          'userId': HomePage.loggedUser.id,
          'content': url,
          'isImage': false,
          'isFile': true,
          'filename': filename,
          'isSystem': false,
          'createdAt': Timestamp.now(),
          'createdBy': HomePage.loggedUser.id,
        });

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: Theme.of(context).primaryColor,
            content: Text('Arquivo ${currentIndex + 1} / ${_allFiles.length} enviado !!', style: TextStyle(color: Colors.white)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            padding: const EdgeInsets.all(10.0),
            elevation: 5,
            width: MediaQuery.of(context).size.width * 0.8,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      setState(() {
        _message = '';
        _messageController.clear();
        _cameraPaths.clear();
        _filesGallery.clear();
        _allFiles.clear();
      });

      final hasInternet = await CheckInternetConnection.hasInternetConnection();

      if (!hasInternet) {
        _showErrorDialog(
          title: const Text('Sem conexão'),
          content: const Text('Você está sem conexão com a internet no momento.'
            ' Assim que possuir internet a mensagem será enviada, porém, todas as '
            'fotos e arquivos serão perdidos'
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
  }
  
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
              isFile: widget.items[index]['isFile'],
              filename: widget.items[index]['filename'],
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
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (_cameraPaths.isNotEmpty)
                          ..._cameraPaths.map((img) => _buildImage(img)).toList(),
                        if (_filesGallery.isNotEmpty)
                          ..._filesGallery.map((img) => _buildGalleryImage(img)).toList(),
                        if (_allFiles.isNotEmpty)
                          ..._allFiles.map((img) => _buildAllFiles(img)).toList(),
                        ButtonsUpload(
                          addImages: _addImages,
                          messageFocus: _messageFocus,
                          addGalleryImages: _addGalleryImages,
                          addFiles: _addFiles,
                        )
                      ],
                    ),
                  ),
                ),
              Form(
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        onFieldSubmitted: (_message?.trim()?.isEmpty ?? true) && _cameraPaths.isEmpty && _filesGallery.isEmpty && _allFiles.isEmpty ? 
                          null : (value) async {
                          _sendMessage();
                          Timer(
                            Duration(milliseconds: 300),
                            () {
                              _scrollController
                                .jumpTo(_scrollController.position.minScrollExtent);
                            });
                          _messageFocus.requestFocus();
                        },
                        decoration: InputDecoration(
                          labelText: 'Digite uma mensagem',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        focusNode: _messageFocus,
                        controller: _messageController,
                        textInputAction: TextInputAction.send,
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
                      backgroundColor: (_message?.trim()?.isEmpty ?? true) && _cameraPaths.isEmpty && _filesGallery.isEmpty && _allFiles.isEmpty ? Colors.grey : null,
                      onPressed: (_message?.trim()?.isEmpty ?? true) && _cameraPaths.isEmpty && _filesGallery.isEmpty && _allFiles.isEmpty ? null : () async {
                        await _sendMessage();
                      },
                    )
                  ],
                ),
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
    _messageFocus?.dispose();

    super.dispose();
  }
}