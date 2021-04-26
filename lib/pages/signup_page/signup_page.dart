import 'package:aps_chat/utils/pages_configs/pages_configs.dart';
import 'package:aps_chat/utils/textformfields_validator/textformfields_validator.dart';
import 'package:aps_chat/widgets/global_custom_drawer/global_custom_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

typedef ValidatorsFunction = String Function(String);

class SignUpPage extends StatefulWidget {

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  TextEditingController _nameController;
  TextEditingController _emailController;
  TextEditingController _passwordController;

  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance.collection('users');
  var _showInvisiblePassword = true;
  var _isLoadingRequest = false;

  Future<void> _showErrorDialog(bool isErrorMailAlreadyExists) => showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    pageBuilder: (_, __, ___) => AlertDialog(
      title: Text('Erro'),
      content: Text(isErrorMailAlreadyExists ? 
        'E-mail já está em uso. Por favor, use outro e-mail' : 'Ocorreu um erro'
        ', por favor, contate algum administrador'),
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
      title: Text('Conta Criada com Sucesso !'),
      actions: [
        TextButton(
          child: Text('OK'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    ),
  );

  @override 
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
      drawer: GlobalCustomDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30.0),
                  ),
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // const Spacer(),
              Form(
                key: _formKey,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nome do usuário',
                        ),
                        validator: TextFormFieldsValidator.validators['name'],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: TextFormFieldsValidator.validators['email'],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: _showInvisiblePassword,
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: 'Senha',
                          suffixIcon: IconButton(
                            icon: Icon(_showInvisiblePassword ? 
                              Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _showInvisiblePassword = !_showInvisiblePassword),
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                        validator: TextFormFieldsValidator.validators['password'],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        obscureText: _showInvisiblePassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
                          suffixIcon: IconButton(
                            icon: Icon(_showInvisiblePassword ? 
                              Icons.visibility_off : Icons.visibility),
                            onPressed: () => setState(() => _showInvisiblePassword = !_showInvisiblePassword),
                            color: Theme.of(context).accentColor,
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.value.text) {
                            return 'Senhas estão diferentes';
                          }

                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
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
                          final passwordField = _passwordController.value.text;
                          final currentUser = await _auth.createUserWithEmailAndPassword(
                            email: mail, 
                            password: passwordField,
                          );

                          await _auth.signInWithEmailAndPassword(
                            email: mail, 
                            password: passwordField,
                          );

                          final data = {
                            'name': _nameController.value.text.trim(),
                            'email': currentUser.user.email,
                            'createdAt': Timestamp.now(),
                          };

                          await _firestore.doc(
                            currentUser.user.uid,
                          ).set(data);

                          await _showSuccessDialog();

                          Navigator.of(context)
                            .pushReplacementNamed(PagesConfigs.homePage);
                        }
                        catch (e) {
                          if (e is FirebaseAuthException && e.code == 'email-already-in-use') {
                            _showErrorDialog(true);
                          }
                          else {
                            _showErrorDialog(false);
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
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextButton(
                  child: const Text('Já possui conta ? Faça o login'),
                  onPressed: () {
                    print('clicado em fazer login');
                    GlobalCustomDrawer.changePage(PagesConfigs.loginPage);
                    Navigator.of(context).pushReplacementNamed(PagesConfigs.loginPage);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override 
  void dispose() {
    _nameController?.dispose();
    _passwordController?.dispose();
    _emailController?.dispose();

    super.dispose();
  }
}