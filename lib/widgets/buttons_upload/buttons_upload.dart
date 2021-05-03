import 'dart:io';

import 'package:aps_chat/utils/details_pages/details_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_absolute_path/flutter_absolute_path.dart';
import 'package:multi_image_picker/multi_image_picker.dart';

typedef AddImages = void Function(List<String>);
typedef AddGalleryImages = void Function(List<File>);

class ButtonsUpload extends StatefulWidget {
  const ButtonsUpload({
    @required this.addImages,
    @required this.messageFocus,
    @required this.addGalleryImages,
  });

  final AddImages addImages;
  final AddGalleryImages addGalleryImages;
  final FocusNode messageFocus;

  @override
  _ButtonsUploadState createState() => _ButtonsUploadState();
}

class _ButtonsUploadState extends State<ButtonsUpload> {
  final images = <Asset>[];

  Future<void> _showErrorDialog({Widget title, Widget content, List<Widget> actions}) => showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    pageBuilder: (_, __, ___) => AlertDialog(
      title: title ?? const Text('Erro'),
      content: content ?? const Text('Erro ao buscar a imagem. Consulte um administrador'),
      actions: actions ?? [
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  Future<void> _getImagesGallery() async {
    List<Asset> resultList = <Asset>[];

    try {
      resultList = await MultiImagePicker.pickImages(
        maxImages: 10,
        enableCamera: true,
        selectedAssets: images,
        cupertinoOptions: CupertinoOptions(takePhotoIcon: "chat"),
        materialOptions: MaterialOptions(
          actionBarColor: "#2A5064",
          actionBarTitle: "Chat Aps",
          allViewTitle: "Pegar imagens da galeria",
          useDetailsView: false,
          selectCircleStrokeColor: "#000000",
        ),
      );
    } catch (_) {
      _showErrorDialog();
    }

    if (!mounted) return;

    final allImages = <File>[];
    for (final img in resultList) {
      final path = await FlutterAbsolutePath.getAbsolutePath(img.identifier);
      final newImage = File(path);
      allImages.add(newImage);
    }

    widget.addGalleryImages?.call(allImages);
  }

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
            widget.messageFocus?.unfocus();
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
          onPressed: () async {
            widget.messageFocus?.unfocus();
            
            await _getImagesGallery();
          }
        ),
        // FloatingActionButton(
        //   heroTag: '3',
        //   mini: true,
        //   child: Icon(
        //     Icons.upload_file,
        //     color: Colors.white,
        //     size: 20,
        //   ),
        //   onPressed: () {
        //     widget.messageFocus?.unfocus();
        //     print('Enviar arquivo');
        //   }
        // ),
      ],
    );
  }
}