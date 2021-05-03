import 'dart:io';

import 'package:aps_chat/pages/home_page/home_page.dart';
import 'package:aps_chat/utils/check_internet_connection/check_internet_connection.dart';
import 'package:aps_chat/utils/textformfields_validator/textformfields_validator.dart';
import 'package:aps_chat/widgets/user_custom_drawer/user_custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

class UserData extends StatefulWidget {
  const UserData({
    this.isUseDrawer = false,
  });

  final bool isUseDrawer;

  @override
  _UserDataState createState() => _UserDataState();
}

class _UserDataState extends State<UserData> {
  User _user = FirebaseAuth.instance.currentUser;
  final _users = FirebaseFirestore.instance.collection('users');

  var _hasErroGetImage = false;

  TextEditingController _nameController;
  TextEditingController _emailController;

  final _formKey = GlobalKey<FormState>();
  var _isLoadingRequest = false;
  var _isAddImage = false;
  final _getImage = ImagePicker();
  String _selectedImagePath;
  File _fileWithImage;
  var _valueChanged = false;

  @override 
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: HomePage.loggedUser.get('name'));
    _emailController = TextEditingController(text: HomePage.loggedUser.get('email'));
  }

  Future<void> _showErrorDialog({bool isErrorMailAlreadyExists, String message, String title}) => showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    pageBuilder: (_, __, ___) => AlertDialog(
      title: Text(title ?? 'Erro'),
      content: Text(message ?? (isErrorMailAlreadyExists ? 
        'E-mail já está em uso. Por favor, use outro e-mail' : 'Ocorreu um erro'
        ' ao atualizar os dados, por favor, contate algum administrador')),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  Future<void> _showSuccessDialog() => showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    pageBuilder: (_, __, ___) => AlertDialog(
      title: Text('Dados Atualizados com Sucesso !'),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  // Widget _buildTakePictureComponent({@required Widget child}) {
  //   return InkWell(
  //     onTap: () async {
  //       try {
  //         final image = await _getImage.getImage(
  //           source: ImageSource.camera,
  //           imageQuality: 50,
  //         );

  //         if (image != null) {
  //           setState(() {
  //             _valueChanged = true;
  //             _selectedImagePath = image.path;
  //             _fileWithImage = File(
  //               _selectedImagePath,
  //             );
  //             _isAddImage = true;
  //           });
  //         }
  //       }
  //       catch (e) {
  //         _showErrorDialog(
  //           message: 'Erro ao tirar ao capturar imagem'
  //         );
  //       }
  //     },
  //     child: child,
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizar dados'),
      ),
      drawer: widget.isUseDrawer ? UserCustomDrawer() : null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    if (_hasErroGetImage)
                      const Text('Clique no ícone / imagem para trocar a foto'),
                    const SizedBox(height: 10),
                    _hasErroGetImage ? InkWell(
                      onTap: () async {
                        try {
                          final image = await _getImage.getImage(
                            source: ImageSource.camera,
                            imageQuality: 50,
                          );

                          if (image != null) {
                            setState(() {
                              _valueChanged = true;
                              _selectedImagePath = image.path;
                              _fileWithImage = File(
                                _selectedImagePath,
                              );
                              _isAddImage = true;
                            });
                          }
                        }
                        on PlatformException catch(e) {
                          if (e.code == 'no_available_camera') {
                            _showErrorDialog(
                              message: 'A câmera do dispositivo não pode ser encontrada'
                            );
                          }
                          else {
                            _showErrorDialog(
                              message: 'Ocorreu um erro ao abrir a câmera'
                            );
                          }
                        }
                        catch (e) {
                          _showErrorDialog(
                            message: 'Ocorreu um erro ao abrir a câmera'
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                          child: _selectedImagePath == null ? Icon(
                            Icons.person_outline,
                            color: Theme.of(context).brightness == Brightness.light ?
                              Colors.black : Colors.white,
                          ) : CircleAvatar(
                                radius: 100,
                                backgroundImage: FileImage(
                                  _fileWithImage,
                                ),
                                onBackgroundImageError: (_, __) {
                                  setState(() {
                                    _hasErroGetImage = true;
                                  });
                                },
                              ),
                        ),
                      ),
                    ) : CircleAvatar(
                      radius: 100,
                      backgroundImage: NetworkImage(
                      _user?.photoURL ?? '',
                      ),
                      onBackgroundImageError: (_, __) {
                        setState(() {
                          _hasErroGetImage = true;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nome do usuário',
                      ),
                      validator: TextFormFieldsValidator.validators['name'],
                      textInputAction: TextInputAction.next,
                      textCapitalization: TextCapitalization.words,
                      onChanged: (_) {
                        setState(() {
                          _valueChanged = true;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'E-mail',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: TextFormFieldsValidator.validators['email'],
                      textInputAction: TextInputAction.next,
                      onChanged: (_) {
                        setState(() {
                          _valueChanged = true;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Container(
                        height: 50,
                        child: ElevatedButton(
                          style: !_valueChanged ? Theme.of(context).elevatedButtonTheme.style.copyWith(
                            backgroundColor: MaterialStateProperty.all(
                              Colors.grey,
                            ),
                          ) : null,
                          child: _isLoadingRequest ? Center(child: CircularProgressIndicator()) : const Text('Atualizar dados'),
                          onPressed: _valueChanged ? () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              try {
                                setState(() {
                                  _isLoadingRequest = true;
                                });

                                final hasInternet = await 
                                  CheckInternetConnection.hasInternetConnection();

                                if (!hasInternet) {
                                  setState(() {
                                    _isLoadingRequest = false;
                                  });

                                  await _showErrorDialog(
                                    isErrorMailAlreadyExists: false,
                                    title: 'Sem conexão',
                                    message: 'Você está sem internet e por isso não pode atualizar os dados'
                                  );

                                  return;
                                }

                                final mail = _emailController.value.text.trim();
                                final name = _nameController.value.text.trim();

                                if (mail != _user.email) {
                                  final isAlreadyEmail = HomePage.allUsers.where(
                                    (user) => user.get('email') == mail);

                                  if (isAlreadyEmail.isNotEmpty) {
                                    _showErrorDialog(
                                      isErrorMailAlreadyExists: true,
                                    );
                                    return;
                                  }
                                  await _user.updateEmail(mail);
                                  await _users.doc(_user.uid).update({
                                    'email': mail,
                                  });
                                }
                                if (name != _user.displayName) {
                                  await _user.updateProfile(
                                    displayName: name,
                                  );

                                  await _users.doc(_user.uid).update({
                                    'name': name,
                                    'updatedAt': Timestamp.now(),
                                  });
                                }

                                if (_isAddImage) {
                                  final ref = FirebaseStorage.instance.ref()
                                    .child('images_profile')
                                    .child('${_user.uid}.jpg');

                                  await ref.putFile(_fileWithImage);
                                  final url = await ref.getDownloadURL();

                                  await _user.updateProfile(
                                    photoURL: url,
                                  );

                                  await _users.doc(HomePage.loggedUser.id).update({
                                    'imageUrl': url,
                                    'updatedAt': Timestamp.now(),
                                  });
                                }

                                await _showSuccessDialog();

                                setState(() {});
                              }
                              catch (e) {
                                if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
                                  _showErrorDialog(isErrorMailAlreadyExists: true);
                                }
                                else {
                                  _showErrorDialog(isErrorMailAlreadyExists: false);
                                }
                                rethrow;
                              }
                              finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoadingRequest = false;
                                  });
                                }
                              }
                            }
                          } : null,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}