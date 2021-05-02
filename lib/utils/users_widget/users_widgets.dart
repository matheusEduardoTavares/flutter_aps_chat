import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:aps_chat/utils/custom_dialogs/custom_dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersWidgets extends StatefulWidget {
  const UsersWidgets({
    @required this.allChatsWithMe,
    @required this.tabController,
  });

  final List<QueryDocumentSnapshot> allChatsWithMe;
  final TabController tabController;

  @override
  _UsersWidgetsState createState() => _UsersWidgetsState();
}

class _UsersWidgetsState extends State<UsersWidgets> {
  final _usersSelected = <QueryDocumentSnapshot>[];

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

  Widget _getLeading(QueryDocumentSnapshot us) {
    final _defaultIcon = const Icon(
      Icons.person_outline,
      size: 20,
    );

    try {
      final imageUrl = us['imageUrl'];

      return CircleAvatar(
        backgroundImage: NetworkImage(
          imageUrl,
        ),
      );
    }
    catch (_) {
      print('aqui tem erro');
      return CircleAvatar(
        child: Center(child: _defaultIcon),
      );
    }
  }

  void _addOrRemoveUser(int index) {
    final isRemoveUser = _usersSelected.contains(HomePage.allUsersWithoutMe[index]);

    if (isRemoveUser) {
      setState(() {
        _usersSelected.remove(HomePage.allUsersWithoutMe[index]);
      });
    }
    else {
      setState(() {
        _usersSelected.add(HomePage.allUsersWithoutMe[index]);
      });
    }    
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Text(
            'Clique no usuário para criar um chat individual e clique'
            ' em sua imagem / ícone ou fique pressionando no usuário desejado '
            'para adicioná-lo à lista e permitir a '
            'criação de um grupo'
          ),
        ),
        Expanded(
          child: HomePage.allUsersWithoutMe.isEmpty ? Center(
            child: const Text('Não há nenhum outro usuário além de você'),
          ) : ListView.builder(
            itemCount: HomePage.allUsersWithoutMe.length,
            itemBuilder: (ctx, index) => Card(
              elevation: 5,
              child: InkWell(
                onLongPress: 
                  () => _addOrRemoveUser(index),
                onTap: () {
                  _showErrorDialog(
                    context: context,
                  );
                },
                child: ListTile(
                  leading: !_usersSelected.contains(HomePage.allUsersWithoutMe[index]) 
                    ? InkWell(
                        child: _getLeading(HomePage.allUsersWithoutMe[index]),
                        onTap: () => _addOrRemoveUser(index),
                    ) :
                    InkWell(
                      onTap: () => _addOrRemoveUser(index),
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        color: Theme.of(context).accentColor,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.greenAccent,
                          size: 35,
                        ),
                      ),
                    ),
                  title: Text(
                    '${HomePage.allUsersWithoutMe[index]["name"]}',
                    textAlign: TextAlign.end,
                  ),
                  enabled: widget.allChatsWithMe.where((currentChat) => currentChat['users'].
                    contains(HomePage.allUsersWithoutMe[index].id)).toList().isEmpty,
                  onTap: () async {
                    final isCreateNewChat = await CustomDialogs.confirmationDialog();

                    if (isCreateNewChat == null || !isCreateNewChat) {
                      return;
                    }

                    widget.tabController.animateTo(0);

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
        ),
        const SizedBox(height: 10),
        if (_usersSelected.isNotEmpty)
          ElevatedButton(
            child: const Text('Criar grupo'),
            onPressed: () {
              print('clicado');
            },
          ),
      ],
    );
  }
}