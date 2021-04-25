import 'package:flutter/material.dart';

class OpacityRequest extends StatelessWidget {
  const OpacityRequest({
    Key key,
    @required this.child,
    @required this.isLoading,
  }) : super(key: key);

  final Widget child;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Opacity(
          child: child,
          opacity: isLoading ? 0.5 : 1.0,
        ),
        if (isLoading)
          Center(
            child: CircularProgressIndicator(),
          ),
      ],
    );
  }
}
