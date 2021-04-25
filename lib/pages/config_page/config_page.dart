import 'package:aps_chat/providers/configs/configs.dart';
import 'package:aps_chat/providers/user_provider/user_provider.dart';
import 'package:aps_chat/widgets/opacity_request/opacity_request.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfigPage extends StatefulWidget {
  ConfigPage({
    this.isUserPage = false,
  });

  final bool isUserPage;

  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  var _isUpdate = false;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<Configs>(context);
    final brightnessTheme = provider.appBrightness;
    final isDarkTheme = brightnessTheme == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        centerTitle: true,
      ),
      body: OpacityRequest(
        isLoading: _isUpdate,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Usar Tema "Dark"'),
                Switch(
                  value: isDarkTheme,
                  onChanged: (value) async {
                    setState(() {
                      _isUpdate = true;
                    });

                    await provider.changeTheme(
                      Provider.of<UserProvider>(context, listen: false)
                    );

                    setState(() {
                      _isUpdate = false;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}