import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:aps_chat/utils/details_pages/details_pages.dart';
import 'package:aps_chat/utils/users_utilities/user_utilities.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MessageComponent extends StatefulWidget {
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

  @override
  _MessageComponentState createState() => _MessageComponentState();
}

class _MessageComponentState extends State<MessageComponent> {
  var _userHasImage = true;

  String _getMessageUser(String notification) {
    if (!notification.contains('/') || widget.createdBy == null) {
      return notification;
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

  Widget _getImage(QueryDocumentSnapshot us) {
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
      setState(() {
        _userHasImage = false;
      });
      return CircleAvatar(
        child: Center(child: _defaultIcon),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    QueryDocumentSnapshot user;
    if (!widget.isSystem) {
      user = HomePage.allUsers.firstWhere((user) => user.id == widget.userId);
    }

    return Stack(
      children: [
        Align(
          alignment: widget.belongsToMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0)
            ),
            color: widget.isSystem ? Colors.red : (widget.belongsToMe ? Theme.of(context).primaryColor : Theme.of(context).accentColor),
            elevation: 8,
            child: Column(
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  height: 10,
                  child: FittedBox(
                    child: Text(
                      widget.isSystem ? 'Mensagem do sistema' : '${user.get("name")}, ${DateFormat("dd/MM/yyyy HH:mm:ss").format(widget.createdAt.toDate())}',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * (widget.isSystem ? 1.0 : 0.5),
                  padding: const EdgeInsets.all(15),
                  child: widget.isImage ? Text('imagem') : Text(
                    !widget.isSystem ? widget.content : _getMessageUser(widget.content), 
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
        ),
        if (!widget.isSystem)
          Container(
            height: 30,
            child: GestureDetector(
              child: _getImage(UserUtilities.getUserById(widget.userId)),
              onTap: _userHasImage ? () {
                Navigator.of(context).pushNamed(
                  DetailsPages.imagePage,
                  arguments: <String, dynamic> {
                    'user': UserUtilities.getUserById(widget.userId),
                  }
                );
              } : null,
            ),
            alignment: widget.belongsToMe ? Alignment.topRight : Alignment.topLeft
          ),
      ],
    );
  }
}