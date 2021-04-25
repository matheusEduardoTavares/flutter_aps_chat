import 'package:aps_chat/utils/pages_configs/pages_configs.dart';
import 'package:aps_chat/utils/textformfields_validator/textformfields_validator.dart';
import 'package:aps_chat/widgets/custom_drawer/custom_drawer.dart';
import 'package:flutter/material.dart';

typedef ValidatorsFunction = String Function(String);

class SignUpPage extends StatefulWidget {

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
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
        title: const Text('Criar Conta'),
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
                          labelText: 'Nome do usuário',
                        ),
                        validator: TextFormFieldsValidator.validators['name'],
                      ),
                      const SizedBox(height: 20),
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
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Confirmar Senha',
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
                child: ElevatedButton(
                  child: const Text('Criar Conta'),
                  onPressed: () {
                  },
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: TextButton(
                  child: const Text('Já possui conta ? Faça o login'),
                  onPressed: () {
                    print('clicado em fazer login');
                    CustomDrawer.changePage(PagesConfigs.loginPage);
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

    super.dispose();
  }
}