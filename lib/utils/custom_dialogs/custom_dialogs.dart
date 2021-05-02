import 'package:aps_chat/utils/navigator_config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

abstract class CustomDialogs {
  static Future<bool> confirmationDialog({
    Widget title,
    Widget content,
    List<Widget> actions,
  }) async {
    return showGeneralDialog<bool>(
      context: NavigatorConfig.navKey.currentState.overlay.context,
      barrierDismissible: true,
      barrierLabel: '${DateTime.now()}',
      pageBuilder: (ctx, _, __) => AlertDialog(
        title: title ?? const Text('Confirmação'),
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

  static Future<String> textChooseDialog({
    Widget title,
    Widget content,
    List<Widget> actions,
  }) async {
    final _formKey = GlobalKey<FormState>();
    String _selectedMessage = '';
    return showGeneralDialog<String>(
      context: NavigatorConfig.navKey.currentState.overlay.context,
      barrierDismissible: true,
      barrierLabel: '${DateTime.now()}',
      pageBuilder: (ctx, _, __) => AlertDialog(
        title: title ?? const Text('Digite o nome do grupo'),
        content: content ?? Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Nome do grupo',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.length < 4) {
                    return 'O grupo deve ter ao menos 4 caracteres';
                  }

                  return null;
                },
                onChanged: (newValue) {
                  _selectedMessage = newValue;
                },
                autovalidateMode: AutovalidateMode.onUserInteraction,
              ),
            ],
          ),
        ),
        actions: actions ?? [
          TextButton(
            child: Text('CANCELAR'),
            onPressed: () => Navigator.of(NavigatorConfig.navKey.currentState.overlay.context).pop(),
          ),
          TextButton(
            child: Text('CONFIRMAR'),
            onPressed: () {
              if (_formKey.currentState.validate() ?? false) {
                Navigator.of(NavigatorConfig.navKey.currentState.overlay.context).pop(_selectedMessage);
              }
            },
          ),
        ],
      ),
    );
  }
}