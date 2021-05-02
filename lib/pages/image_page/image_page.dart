import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({
    this.user,
    this.nameAppBar,
    this.url,
  });

  final QueryDocumentSnapshot user;
  final String nameAppBar;
  final String url;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Imagem do ${nameAppBar ?? user['name']}'),
      ),
      body: PageView(
        children: [
          Row(
            children: [
              Image.network(
                url ?? user['imageUrl'],
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
              ),
            ],
          ),
        ],
      ),
    );
  }
}