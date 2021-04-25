import 'package:aps_chat/providers/theme_config_provider/theme_config_provider.dart';
import 'package:aps_chat/widgets/custom_drawer/custom_drawer.dart';
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
    final provider = Provider.of<ThemeConfigProvider>(context);
    final brightnessTheme = provider.appBrightness;
    final isDarkTheme = brightnessTheme == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        centerTitle: true,
      ),
      drawer: CustomDrawer(),
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

                    await provider.changeTheme();

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