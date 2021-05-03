import 'package:aps_chat/utils/custom_dialogs/custom_dialogs.dart';
import 'package:aps_chat/widgets/camera_utilities/camera_utilities.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';

class CameraPage extends StatefulWidget {
  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  CameraController _cameraController;
  var _isLoading = true;
  final _paths = <String>[];
  var _quantityImagesCaptured = 0;
  final _appBar = AppBar(
    title: const Text('Capturar imagens'),
  );
  var _isLoadingImage = false;

  @override 
  void initState() {
    super.initState();

    _cameraController = CameraController(
      CameraUtilities.camera,
      ResolutionPreset.medium,
    );

    Permission.camera.request().then((status) {
      if (status == PermissionStatus.granted) {
        Permission.speech.request().then((status) {
          if (status == PermissionStatus.granted) {
            _initializeCamera();
          }
          else if (status.isPermanentlyDenied) {
            _showErrorDialog().then((_) {
              openAppSettings().then((_) {
                Permission.speech.isGranted.then((isGranted) {
                  if (isGranted != null && isGranted) {
                    _initializeCamera();
                  }
                  else {
                    Navigator.of(context).pop();
                  }
                });
              });
            });
          }
          else {
            _showErrorDialog().then((value) => Navigator.of(context).pop());
          }
        });
      }
      else if (status.isPermanentlyDenied) {
        _showErrorDialog().then((_) {
          openAppSettings().then((_) {
            Permission.camera.isGranted.then((isGranted) {
              if (isGranted != null && isGranted) {
                Permission.speech.request().then((status) {
                  if (status == PermissionStatus.granted) {
                    _initializeCamera();
                  }
                  else if (status.isPermanentlyDenied) {
                    _showErrorDialog().then((_) {
                      openAppSettings().then((_) {
                        Permission.speech.isGranted.then((isGranted) {
                          if (isGranted != null && isGranted) {
                            _initializeCamera();
                          }
                          else {
                            Navigator.of(context).pop();
                          }
                        });
                      });
                    });
                  }
                  else {
                    _showErrorDialog().then((value) => Navigator.of(context).pop());
                  }
                });
              }
              else {
                Navigator.of(context).pop();
              }
            });
          });
        });
      }
      else {
        _showErrorDialog().then((value) => Navigator.of(context).pop());
      }
    });
  }

  void _initializeCamera() {
    _cameraController.initialize().then((_) {
      _cameraController.setFlashMode(FlashMode.off).then((_) => setState(() => _isLoading = false))
        .onError((_, __) => setState(() => _isLoading = false));
    });
  }

  Future<void> _showErrorDialog({Widget title, Widget content, List<Widget> actions}) => showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    pageBuilder: (_, __, ___) => AlertDialog(
      title: title ?? const Text('Erro'),
      content: content ?? const Text('É necessário aceitar todas as permissões antes de continuar'),
      actions: actions ?? [
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final tenPorcentPageSize = size.width * 0.1;

    return Scaffold(
      appBar: _appBar,
      body: _isLoading ? Center(
        child: CircularProgressIndicator(),
      ) : Stack(
        children: [
          Container(
            width: size.width,
            height: size.height - _appBar.preferredSize.height - MediaQuery.of(context).padding.top,
            child: CameraPreview(_cameraController),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(0, 0, 0, 0.5)
              ),
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Quantidade de fotos tiradas: $_quantityImagesCaptured', 
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                ),
              ),
            ),
          ),
          Positioned(
            right: tenPorcentPageSize,
            bottom: tenPorcentPageSize,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: '${widget.hashCode}-${DateTime.now()}-1',
                  child: Icon(Icons.camera, size: 40),
                  onPressed: () async {
                    setState(() {
                      _isLoadingImage = true;
                    });
                    final file = await _cameraController.takePicture();
                    await Future.delayed(const Duration(seconds: 1));
                    if (file != null) {
                      setState(() {
                        _paths.add(
                          path.join('${DateTime.now()}', file.path),
                        );
                        _quantityImagesCaptured++;
                        _isLoadingImage = false;
                      });
                    }
                  }
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.5)
                  ),
                  child: const Center(
                    child: Text(
                      'Capturar imagem',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  )
                ),
              ],
            ),
          ),
          Positioned(
            left: tenPorcentPageSize,
            bottom: tenPorcentPageSize,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton(
                  heroTag: '${widget.hashCode}-${DateTime.now()}-2',
                  child: Icon(Icons.close, size: 40),
                  onPressed: () async {
                    if (_quantityImagesCaptured == 0) {
                      Navigator.of(context).pop();
                      return;
                    }

                    final isConfirmClose = await CustomDialogs.confirmationDialog(
                      content: const Text('Deseja realmente sair ?'
                        ' Todas imagens tiradas serão perdidas'
                      ),
                    );

                    if (isConfirmClose != null && isConfirmClose) {
                      Navigator.of(context).pop();
                    }
                  }
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(0, 0, 0, 0.5)
                  ),
                  child: const Center(
                    child: Text(
                      'Sair',
                      style: TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  )
                ),
              ],
            ),
          ),
          if (_quantityImagesCaptured > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Column(
                children: [
                  FloatingActionButton(
                    heroTag: '${widget.hashCode}-${DateTime.now()}-3',
                    child: Icon(Icons.check, size: 40),
                    onPressed: _isLoadingImage ? null : () {
                      Navigator.of(context).pop(_paths);
                    }
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(0, 0, 0, 0.5)
                    ),
                    child: const Center(
                      child: Text(
                        'Finalizar',
                        style: TextStyle(color: Colors.white, fontSize: 15),
                      ),
                    )
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  @override 
  void dispose() {
    _cameraController?.dispose();

    super.dispose();
  }
}