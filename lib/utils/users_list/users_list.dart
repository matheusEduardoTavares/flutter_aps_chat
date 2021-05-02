import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:aps_chat/utils/check_internet_connection/check_internet_connection.dart';
import 'package:aps_chat/utils/custom_dialogs/custom_dialogs.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UsersList extends StatefulWidget {
  const UsersList({
    @required this.allChatsWithMe,
    @required this.tabController,
  });

  final List<QueryDocumentSnapshot> allChatsWithMe;
  final TabController tabController;

  @override
  _UsersListState createState() => _UsersListState();
}

class _UsersListState extends State<UsersList> {
  final _usersSelected = <QueryDocumentSnapshot>[];
  var _isLoadingCreateGroup = false;

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

  Future<void> _showNetworkError({String message, String title}) => showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    pageBuilder: (_, __, ___) => AlertDialog(
      title: Text(title ?? 'Sem conexão'),
      content: Text(message ?? 'Você está sem internet e por isso não conseguirá criar o grupo'),
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
      children: [
        if (HomePage.allUsersWithoutMe.length <= 2)
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Clique no usuário para criar um chat individual e clique'
              ' em sua imagem / ícone ou fique pressionando no usuário desejado '
              'para adicioná-lo à lista e permitir a '
              'criação de um grupo (precisa selecionar pelo menos 2 usuários)'
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
                    contains(HomePage.allUsersWithoutMe[index].id) && 
                      currentChat['users'].length == 2).toList().isEmpty,
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
        if (_usersSelected.length >= 2)
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width * 0.8,
            child: ElevatedButton(
              child: _isLoadingCreateGroup ? Center(
                child: CircularProgressIndicator(),
              ) : const Text('Criar grupo'),
              onPressed: _isLoadingCreateGroup ? () {} : () async {
                final hasInternet = await CheckInternetConnection.
                  hasInternetConnection();

                if (!hasInternet) {
                  _showNetworkError();
                  return;
                }

                String usersName = '';
                String usersId = '';
                for (final currentUser in _usersSelected) {
                  usersName += '${currentUser["name"]}, ';
                  usersId += '${currentUser.id}, ';
                }

                usersName = usersName.substring(0, usersName.lastIndexOf(','));
                usersId = usersId.substring(0, usersId.lastIndexOf(','));

                final isCreateNewChat = await CustomDialogs.confirmationDialog(
                  content: Text(
                    'Você confirma a criação de um grupo com os '
                    'usuários $usersName ?'
                  )
                );

                if (isCreateNewChat == null || !isCreateNewChat) {
                  return;
                }

                final loggedUser = HomePage.loggedUser;

                final groupName = await CustomDialogs.textChooseDialog();

                if (groupName == null) {
                  return;
                }

                setState(() {
                  _isLoadingCreateGroup = true;
                });

                final newChat = FirebaseFirestore.instance.collection('allChats').doc(
                  '${loggedUser.id}, $usersId'
                );

                await newChat.set({
                  'createdAt': Timestamp.now(),
                  'name': groupName,
                  'users': [
                    loggedUser.id,
                    ..._usersSelected.map((usSelected) => usSelected.id).toList(),
                  ],
                });

                final newCollection = newChat.collection('chat');
                newCollection.add({
                  'createdAt': Timestamp.now(),
                  'content': 'Esta conversa é apenas entre /${HomePage.loggedUser.id}/, '
                    '${_usersSelected.map((usSelected) => "/${usSelected.id}/").toList().join(", ")}',
                  'isImage': false,
                  'isSystem': true,
                  'userId': 'Global',
                  'createdBy': loggedUser.id,
                });

                setState(() {
                  _isLoadingCreateGroup = false;
                });

                widget.tabController.animateTo(0);
              },
            ),
          ),
        if (_usersSelected.length >= 2)
          const SizedBox(height: 10),
      ],
    );
  }
}