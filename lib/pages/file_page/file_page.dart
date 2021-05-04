import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

class FilePage extends StatefulWidget {
  const FilePage({
    @required this.filename,
    @required this.url,
  });

  final String filename;
  final String url;


  @override
  _FilePageState createState() => _FilePageState();
}

class _FilePageState extends State<FilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Baixar o arquivo'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Nome do arquivo: ${widget.filename}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark ? 
                  Colors.white : Colors.black,
                fontSize: 30.0,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            child: const Text('Clique aqui para baixar o arquivo'),
            onPressed: () {
              launch(widget.url);
            },
          ),
        ],
      ),
    );
  }
}