import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({
    @required this.user,
  });

  final QueryDocumentSnapshot user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Imagem do ${user['name']}'),
      ),
      body: PageView(
        children: [
          Row(
            children: [
              Image.network(
                user['imageUrl'],
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