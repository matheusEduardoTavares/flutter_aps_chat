import 'dart:io';

import 'package:aps_chat/utils/textformfields_validator/textformfields_validator.dart';
import 'package:aps_chat/widgets/user_custom_drawer/user_custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserData extends StatefulWidget {
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

  @override 
  void initState() {
    super.initState();

    _nameController = TextEditingController(text: _user.displayName);
    _emailController = TextEditingController(text: _user.email);
  }

  @override 
  void didUpdateWidget(UserData oldWidget) {
    setState(() {
      _user = FirebaseAuth.instance.currentUser;
    });

    super.didUpdateWidget(oldWidget);
  }

  Future<void> _showErrorDialog({bool isErrorMailAlreadyExists, String message}) => showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    pageBuilder: (_, __, ___) => AlertDialog(
      title: Text('Erro'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atualizar dados'),
      ),
      drawer: UserCustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: Column(
                  children: [
                    _hasErroGetImage ? InkWell(
                      onTap: () async {
                        try {
                          final image = await _getImage.getImage(
                            source: ImageSource.camera,
                            imageQuality: 50,
                          );

                          if (image != null) {
                            setState(() {
                              _selectedImagePath = image.path;
                              _isAddImage = true;
                            });
                          }
                        }
                        catch (e) {
                          _showErrorDialog(
                            message: 'Erro ao tirar ao capturar imagem'
                          );
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person_outline,
                        ),
                      ),
                    ) : CircleAvatar(
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
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.8,
                      child: Container(
                        height: 50,
                        child: ElevatedButton(
                          child: _isLoadingRequest ? Center(child: CircularProgressIndicator()) : const Text('Criar Conta'),
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              try {
                                setState(() {
                                  _isLoadingRequest = true;
                                });
                                final mail = _emailController.value.text.trim();
                                final name = _nameController.value.text.trim();

                                if (mail != _user.email) {
                                  await _user.updateEmail(mail);
                                  await _users.doc(_users.id).update({
                                    'email': mail,
                                  });
                                }
                                if (name != _user.displayName) {
                                  if (_isAddImage) {
                                    await _user.updateProfile(
                                      displayName: name,
                                      photoURL: _selectedImagePath,
                                    );

                                    await _users.doc(_users.id).update({
                                      'name': name,
                                    });

                                    final ref = FirebaseStorage.instance.ref()
                                      .child('images_profile')
                                      .child('$_selectedImagePath.jpg');

                                    await ref.putFile(File(_selectedImagePath));
                                    final url = await ref.getDownloadURL();

                                    await _users.doc(_users.id).set({
                                      'imageUrl': url,
                                      'updatedAt': Timestamp.now(),
                                    });

                                  }
                                  else {
                                    await _user.updateProfile(
                                      displayName: name,
                                    );

                                    await _users.doc(_users.id).update({
                                      'name': name,
                                    });

                                    await _users.doc(_users.id).set({
                                      'updatedAt': Timestamp.now(),
                                    });
                                  }
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
                              }
                              finally {
                                if (mounted) {
                                  setState(() {
                                    _isLoadingRequest = false;
                                  });
                                }
                              }
                            }
                          },
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