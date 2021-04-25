import 'package:aps_chat/utils/pages_configs/pages_configs.dart';
import 'package:aps_chat/utils/textformfields_validator/textformfields_validator.dart';
import 'package:aps_chat/widgets/custom_drawer/custom_drawer.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _nameController;

  TextEditingController _passwordController;

  @override 
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      drawer: CustomDrawer(),
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
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Email',
                        ),
                        validator: TextFormFieldsValidator.validators['email'],
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Senha',
                        ),
                        validator: TextFormFieldsValidator.validators['password'],
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: ElevatedButton(
                  child: const Text('LOGIN'),
                  onPressed: () {
                    print('clicado');
                    Navigator.of(context).pushNamed(PagesConfigs.configsPage);
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
                    CustomDrawer.changePage(PagesConfigs.signUpPage);
                    Navigator.of(context).pushReplacementNamed(PagesConfigs.signUpPage);
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

    super.dispose();
  }
}