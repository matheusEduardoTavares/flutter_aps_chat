import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:aps_chat/utils/users_utilities/user_utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageComponent extends StatelessWidget {
  const MessageComponent({
    Key key,
    @required this.content,
    @required this.belongsToMe,
    @required this.isImage,
    @required this.createdAt,
    @required this.userId,
    this.isSystem = false,
    this.createdBy,
  }) : super(key: key);

  final String content;
  final bool isImage;
  final bool belongsToMe;
  final bool isSystem;
  final Timestamp createdAt;
  final String userId;
  final String createdBy;

  String _getMessageUser(String notification) {
    if (!notification.contains('/') || createdBy == null) {
      return notification;
    }
    else if (createdBy != null && createdBy != HomePage.loggedUser.id) {
      return 'Esta conversa é entre você e ${UserUtilities.getUserById(createdBy)['name']}';
    }
    String finalMessage = '';
    final messageInArray = notification.split('/');
    for (final currentMessage in messageInArray) {
      final user = UserUtilities.getUserById(currentMessage);
      if (user == null) {
        finalMessage += currentMessage;
      }
      else {
        finalMessage += user['name'];
      }
    }

    return finalMessage;
  }

  @override
  Widget build(BuildContext context) {
    QueryDocumentSnapshot user;
    if (!isSystem) {
      user = HomePage.allUsers.firstWhere((user) => user.id == userId);
    }

    return Align(
      alignment: belongsToMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(50.0)
        ),
        color: isSystem ? Colors.red : (belongsToMe ? Theme.of(context).primaryColor : Theme.of(context).accentColor),
        elevation: 8,
        child: Column(
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.4,
              height: 10,
              child: FittedBox(
                child: Text(
                  isSystem ? 'Mensagem do sistema' : '${user.get("name")}, ${DateFormat("dd/MM/yyyy HH:mm:ss").format(createdAt.toDate())}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * (isSystem ? 1.0 : 0.5),
              padding: const EdgeInsets.all(15),
              child: isImage ? Text('imagem') : Text(
                !isSystem ? content : _getMessageUser(content), 
                style: TextStyle(
                  color: Colors.white,
                ),
                // textAlign: isSystem ? TextAlign.center : (belongsToMe ? TextAlign.right : TextAlign.left),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}