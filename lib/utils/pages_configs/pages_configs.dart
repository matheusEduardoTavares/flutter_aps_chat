import 'package:aps_chat/models/details_page.dart';
import 'package:aps_chat/pages/config_page/config_page.dart';
import 'package:aps_chat/pages/login_page/login_page.dart';
import 'package:aps_chat/pages/signup_page/signup_page.dart';
import 'package:aps_chat/pages/splash_page/splash_page.dart';
import 'package:flutter/material.dart';

abstract class PagesConfigs {
  static const loginPage = '/loginPage';
  static const splashPage = '/splashPage';
  static const configsPage = '/configsPage';
  static const signUpPage = '/signUpPage';

  static final pages = <String, WidgetBuilder>{
    splashPage: (ctx) => SplashPage(),
    loginPage: (ctx) => LoginPage(),
    configsPage: (ctx) => ConfigPage(),
    signUpPage: (ctx) => SignUpPage(),
  };

  static final detailsPage = <DetailsPage>[
    DetailsPage(
      goToNamedRoute: loginPage,
      name: 'Login',
      leadingData: Icons.login,
    ),
    DetailsPage(
      goToNamedRoute: signUpPage,
      name: 'Criar conta',
      leadingData: Icons.create,
    ),
    DetailsPage(
      goToNamedRoute: configsPage,
      name: 'Configurações',
      leadingData: Icons.settings,
    ),
  ];
}