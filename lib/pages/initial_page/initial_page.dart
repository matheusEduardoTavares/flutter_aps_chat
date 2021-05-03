import 'package:aps_chat/pages/camera_page/camera_page.dart';
import 'package:aps_chat/pages/chat_loading_stream/chat_loading_stream.dart';
import 'package:aps_chat/pages/image_page/image_page.dart';
import 'package:aps_chat/providers/theme_config_provider/theme_config_provider.dart';
import 'package:aps_chat/utils/colors_default/colors_default.dart';
import 'package:aps_chat/utils/db_util.dart';
import 'package:aps_chat/utils/navigator_config.dart';
import 'package:aps_chat/utils/details_pages/details_pages.dart';
import 'package:aps_chat/widgets/camera_utilities/camera_utilities.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
          availableCameras().then((cameras) {
            CameraUtilities.camera = cameras?.first;
          });
          Navigator.of(ctx)
            .pushReplacementNamed(DetailsPages.authPage);
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
          initialRoute: DetailsPages.splashPage,
          routes: DetailsPages.pages,
          navigatorKey: NavigatorConfig.navKey,
          onGenerateRoute: (settings) {
            if (settings?.name == DetailsPages.chatDataPage) {
              final Map<String, dynamic> data = settings?.arguments;

              final docChatName = data['docChatName'];
              final docChatStream = data['docChatStream'];

              return MaterialPageRoute(
                builder: (ctx) => ChatLoadingStream(
                  docChatName: docChatName,
                  docChatStream: docChatStream,
                ),
              );
            }
            else if (settings?.name == DetailsPages.imagePage) {
              final Map<String, dynamic> data = settings?.arguments;

              final QueryDocumentSnapshot user = data['user'];
              final String url = data['url'];
              final String nameAppBar = data['nameAppBar'];

              return MaterialPageRoute(
                builder: (ctx) => ImagePage(
                  user: user,
                  url: url,
                  nameAppBar: nameAppBar,
                ),
              );
            }
            else if (settings?.name == DetailsPages.cameraPage) {
              return MaterialPageRoute(
                builder: (ctx) => CameraPage(),
              );
            }

            return null;
          },
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