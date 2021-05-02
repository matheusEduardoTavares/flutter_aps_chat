import 'package:aps_chat/providers/theme_config_provider/theme_config_provider.dart';
import 'package:aps_chat/widgets/global_custom_drawer/global_custom_drawer.dart';
import 'package:aps_chat/widgets/opacity_request/opacity_request.dart';
import 'package:aps_chat/widgets/user_custom_drawer/user_custom_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ConfigPage extends StatefulWidget {
  @override
  _ConfigPageState createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final _auth = FirebaseAuth.instance;
  var _isUpdate = false;

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> mapArguments = ModalRoute.of(context)?.settings?.arguments ?? {};
    final bool isUseDrawer = mapArguments.containsKey('isUseDrawer') && 
      mapArguments['isUseDrawer'] != null ? mapArguments['isUseDrawer'] : true;

    final provider = Provider.of<ThemeConfigProvider>(context);
    final brightnessTheme = provider.appBrightness;
    final isDarkTheme = brightnessTheme == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Configurações'),
        centerTitle: true,
      ),
      drawer: isUseDrawer ? (_auth.currentUser != null ? UserCustomDrawer() : GlobalCustomDrawer()) : null,
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