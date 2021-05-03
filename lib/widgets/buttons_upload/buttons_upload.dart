import 'package:aps_chat/utils/details_pages/details_pages.dart';
import 'package:flutter/material.dart';

typedef AddImages = void Function(List<String>);

class ButtonsUpload extends StatefulWidget {
  const ButtonsUpload({
    @required this.addImages,
  });

  final AddImages addImages;

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
            final imagesPath = await Navigator.of(context).pushNamed(
              DetailsPages.cameraPage,
              arguments: {
                'addImages': widget.addImages,
              }
            );

            final images = List<String>.from(imagesPath ?? []);

            if (images != null && images.isNotEmpty) {
              widget.addImages(imagesPath);
            }
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