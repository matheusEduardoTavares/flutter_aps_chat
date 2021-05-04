import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:aps_chat/utils/details_pages/details_pages.dart';
import 'package:aps_chat/utils/users_utilities/user_utilities.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
    this.filename = '',
    this.isSystem = false,
    this.isFile = false,
    this.createdBy,
  }) : super(key: key);

  final String content;
  final bool isImage;
  final bool belongsToMe;
  final bool isSystem;
  final bool isFile;
  final String filename;
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
    print(HomePage.loggedUser.id);
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
                  child: widget.isFile ? InkWell(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        DetailsPages.filePage,
                        arguments: {
                          'filename': widget.filename,
                          'url': widget.content,
                        }
                      );
                    },
                    child: Column(
                      children: [
                        Icon(
                          widget.filename.endsWith('.pdf') ? Icons.picture_as_pdf :
                            Icons.file_copy,
                          size: 80,
                          color: widget.belongsToMe ? Theme.of(context).accentColor
                            : Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          widget.filename,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12.0,
                          ),
                          textAlign: TextAlign.center,
                        )
                      ],
                    ),
                  ) : (widget.isImage ? GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushNamed(
                        DetailsPages.imagePage,
                        arguments: <String, dynamic> {
                          'user': UserUtilities.getUserById(widget.userId),
                          'nameAppBar': 'Imagem',
                          'url': widget.content,
                        }
                      );
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20.0),
                      child: CachedNetworkImage(
                        imageUrl: widget.content,
                        placeholder: (_, __) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        },
                        errorWidget: (ctx, __, ___) {
                          return Column(
                            children: [
                              const Text('Algo deu errado ao carregar a imagem'),
                              const SizedBox(height: 16),
                              Icon(
                                Icons.error,
                                color: Theme.of(ctx).errorColor,
                                size: 40,
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ) : Text(
                    !widget.isSystem ? widget.content : _getMessageUser(widget.content), 
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    // textAlign: isSystem ? TextAlign.center : (belongsToMe ? TextAlign.right : TextAlign.left),
                    textAlign: TextAlign.center,
                  )),
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