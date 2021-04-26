import 'package:aps_chat/widgets/user_custom_drawer/user_custom_drawer.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página Inicial'),
      ),
      drawer: UserCustomDrawer(),
      body: Center(
        child: Text('LOGADO !!'),
      ),
    );
  }
}