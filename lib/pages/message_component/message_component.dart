import 'package:aps_chat/pages/home_page/home_page.dart';
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
  }) : super(key: key);

  final String content;
  final bool isImage;
  final bool belongsToMe;
  final bool isSystem;
  final Timestamp createdAt;
  final String userId;

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
              height: 10,
              child: FittedBox(
                child: Text(
                  isSystem ? 'Mensagem do sistema' : '${user.get("name")}, ${DateFormat("dd/MM/yyyy hh:mm:ss").format(createdAt.toDate())}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * (isSystem ? 1.0 : 0.5),
              padding: const EdgeInsets.all(15),
              child: isImage ? Text('imagem') : Text(
                content, 
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