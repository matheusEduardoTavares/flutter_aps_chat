import 'package:aps_chat/utils/get_images/get_images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class SplashPage extends StatelessWidget {
  final _defaultBackgroundColor = Color.fromRGBO(0, 88, 82, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _defaultBackgroundColor,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'APS Chat',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
            ),
          ),
          const SizedBox(height: 20),
          Image.asset(
            GetImages.chatImage,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 20),
          SpinKitThreeBounce(
            size: 20.0,
            itemBuilder: (BuildContext context, int index) {
              return DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0)
                ),
              );
            },
          )
        ],
      ),
    );
  }
}