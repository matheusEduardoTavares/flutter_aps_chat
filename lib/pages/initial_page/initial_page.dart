import 'package:aps_chat/providers/configs/configs.dart';
import 'package:aps_chat/providers/user_provider/user_provider.dart';
import 'package:aps_chat/utils/db_util.dart';
import 'package:aps_chat/utils/navigator_config.dart';
import 'package:aps_chat/utils/pages_configs/pages_configs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class InitialPage extends StatefulWidget {

  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final _primaryColor = Colors.purple;
  final _accentColor = Colors.orangeAccent;

  @override 
  void initState() {
    super.initState();

    DbUtil.initDb().then((_) {
      DbUtil.getData().then((user) {
        if (user != null) {
          Provider.of<UserProvider>(context, listen: false).updateUser(user.first);
        }
        Navigator.of(NavigatorConfig.navKey.currentState.overlay.context)
          .pushReplacementNamed(PagesConfigs.loginPage);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<Configs>(
          create: (ctx) => Configs(),
          lazy: true,
        ),
        ChangeNotifierProvider<UserProvider>(
          create: (ctx) => UserProvider(),
          lazy: true,
        ),
      ],
      builder: (ctx, _) {
        final brightness = Provider.of<Configs>(ctx).appBrightness;
        final _isDarkMode = brightness == Brightness.dark;
        return MaterialApp(
          title: 'ProjectComplete',
          initialRoute: PagesConfigs.splashPage,
          routes: PagesConfigs.pages,
          navigatorKey: NavigatorConfig.navKey,
          theme: ThemeData(
            floatingActionButtonTheme: FloatingActionButtonThemeData(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            appBarTheme: AppBarTheme(
              backgroundColor: _primaryColor,
              brightness: Brightness.dark,
              centerTitle: true,
            ),
            primaryColor: _primaryColor,
            accentColor: _accentColor,
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(_primaryColor),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.all(
                  _isDarkMode ? Colors.white : _primaryColor,
                ),
                overlayColor: MaterialStateProperty.all(
                  _isDarkMode ? Colors.grey.withOpacity(0.2) : 
                    Colors.purple.withOpacity(0.2)
                ),
              ),
            ),
            brightness: brightness,
          ),
        );
      },
    );
  }
}