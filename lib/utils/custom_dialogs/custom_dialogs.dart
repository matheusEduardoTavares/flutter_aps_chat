import 'package:aps_chat/utils/navigator_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class CustomDialogs {
  static Future<bool> confirmationDialog({
    Widget confirmation,
    Widget content,
    List<Widget> actions,
  }) async {
    return showGeneralDialog<bool>(
      context: NavigatorConfig.navKey.currentState.overlay.context,
      barrierDismissible: true,
      barrierLabel: '${DateTime.now()}',
      pageBuilder: (ctx, _, __) => AlertDialog(
        title: confirmation ?? const Text('Confirmação'),
        content: content ?? const Text('Você confirma a criação de um chat com este(s) usuário(s) ?'),
        actions: actions ?? [
          TextButton(
            child: Text('CANCELAR'),
            onPressed: () => Navigator.of(NavigatorConfig.navKey.currentState.overlay.context).pop(false),
          ),
          TextButton(
            child: Text('CONFIRMAR'),
            onPressed: () => Navigator.of(NavigatorConfig.navKey.currentState.overlay.context).pop(true),
          ),
        ],
      ),
    );
  } 
}