import 'package:aps_chat/utils/check_internet_connection/check_internet_connection.dart';
import 'package:aps_chat/utils/details_pages/details_pages.dart';
import 'package:aps_chat/utils/textformfields_validator/textformfields_validator.dart';
import 'package:aps_chat/widgets/global_custom_drawer/global_custom_drawer.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _emailController;
  TextEditingController _passwordController;

  final _formKey = GlobalKey<FormState>();
  final _auth = FirebaseAuth.instance;
  var _showInvisiblePassword = true;
  var _isLoadingRequest = false;

  Future<void> _showErrorDialog({bool isErrorCredentials, String title, Widget content}) => showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: '',
    pageBuilder: (_, __, ___) => AlertDialog(
      title: Text(title ?? 'Erro'),
      content: content ?? Text(isErrorCredentials ? 
        'E-mail e ou senha inválidos' : 'Ocorreu um erro'
        ', por favor, contate algum administrador'),
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

    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
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
              Form(
                key: _formKey,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'E-mail',
                        ),
                        validator: TextFormFieldsValidator.validators['email'],
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
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
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 50,
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  child: _isLoadingRequest ? Center(child: CircularProgressIndicator()) : const Text('LOGIN'),
                  onPressed: () async {
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
                            isErrorCredentials: false,
                            title: 'Sem conexão',
                            content: const Text('Você está sem internet e por isso não pode realizar login')
                          );

                          return;
                        }
                        
                        await _auth.signInWithEmailAndPassword(
                          email: _emailController.value.text.trim(), 
                          password: _passwordController.value.text,
                        );
                      }
                      on FirebaseAuthException catch (_) {
                        _showErrorDialog(isErrorCredentials: true);
                      }
                      catch (_) {
                        _showErrorDialog(isErrorCredentials: false);
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
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextButton(
                  child: const Text('Ainda não possui conta ? Crie uma conta'),
                  onPressed: () {
                    print('clicado em criar conta');
                    GlobalCustomDrawer.changePage(DetailsPages.signUpPage);
                    Navigator.of(context).pushReplacementNamed(DetailsPages.signUpPage);
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
    _emailController?.dispose();
    _passwordController?.dispose();

    super.dispose();
  }
}