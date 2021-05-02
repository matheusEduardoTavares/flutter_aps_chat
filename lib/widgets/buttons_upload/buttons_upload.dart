import 'package:flutter/material.dart';

class ButtonsUpload extends StatefulWidget {
  @override
  _ButtonsUploadState createState() => _ButtonsUploadState();
}

class _ButtonsUploadState extends State<ButtonsUpload> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          heroTag: '1',
          mini: true,
          child: Icon(
            Icons.image,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () async {
            
          }
        ),
        FloatingActionButton(
          heroTag: '2',
          mini: true,
          child: Icon(
            Icons.camera_alt,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            print('Capturar imagem');
          }
        ),
        FloatingActionButton(
          heroTag: '3',
          mini: true,
          child: Icon(
            Icons.upload_file,
            color: Colors.white,
            size: 20,
          ),
          onPressed: () {
            print('Enviar arquivo');
          }
        ),
      ],
    );
  }
}