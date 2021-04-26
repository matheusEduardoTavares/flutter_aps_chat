import 'package:aps_chat/providers/theme_config_provider/theme_config_provider.dart';
import 'package:aps_chat/utils/colors_default/colors_default.dart';
import 'package:aps_chat/utils/db_util.dart';
import 'package:aps_chat/utils/navigator_config.dart';
import 'package:aps_chat/utils/pages_configs/pages_configs.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class InitialPage extends StatefulWidget {

  @override
  _InitialPageState createState() => _InitialPageState();
}

class _InitialPageState extends State<InitialPage> {
  final _defaultBorderRadius = BorderRadius.circular(30.0);

  @override 
  void initState() {
    super.initState();

    DbUtil.initDb().then((_) {
      DbUtil.getTheme().then((isDarkTheme) {
        final ctx = NavigatorConfig.navKey.currentState.overlay.context;
        if (isDarkTheme != null) {
          Provider.of<ThemeConfigProvider>(ctx, listen: false)
            .updateTheme(isDarkTheme);
        }

        Firebase.initializeApp().then((_) {
          Navigator.of(ctx)
            .pushReplacementNamed(PagesConfigs.authPage);
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeConfigProvider>(
          create: (ctx) => ThemeConfigProvider(),
          lazy: true,
        ),
      ],
      builder: (ctx, _) {
        final brightness = Provider.of<ThemeConfigProvider>(ctx).appBrightness;
        return MaterialApp(
          title: 'ProjectComplete',
          initialRoute: PagesConfigs.splashPage,
          routes: PagesConfigs.pages,
          navigatorKey: NavigatorConfig.navKey,
          theme: ThemeData(
            iconTheme: IconThemeData(
              color: Colors.white,
              size: 60,
            ),
            primaryColor: ColorsDefault.blueColor,
            accentColor: ColorsDefault.marineColor,
            brightness: brightness,
            appBarTheme: AppBarTheme(
              centerTitle: true,
              brightness: Brightness.dark,
            ),
            inputDecorationTheme: InputDecorationTheme(
              border: OutlineInputBorder(
                borderRadius: _defaultBorderRadius,
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ButtonStyle(
                shape: MaterialStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: _defaultBorderRadius,
                  ),
                ),
                backgroundColor: MaterialStateProperty.all(
                  ColorsDefault.blueColor,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}