import 'package:cached_network_image/cached_network_image.dart';
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
        title: Text(nameAppBar ?? 'Imagem do ${user['name']}'),
      ),
      body: PageView(
        children: [
          Row(
            children: [
              Container(
                height: MediaQuery.of(context).size.height,
                width: MediaQuery.of(context).size.width,
                child: CachedNetworkImage(
                  imageUrl: url ?? user['imageUrl'],
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
              )
            ],
          ),
        ],
      ),
    );
  }
}