import 'package:aps_chat/utils/pages_configs/pages_configs.dart';
import 'package:flutter/material.dart';

typedef ValidatorsFunction = String Function(String);

class LoginPage extends StatefulWidget {

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController _nameController;

  TextEditingController _passwordController;

  final validators = <String, ValidatorsFunction>{
    'name': (value) {
      if (value == null || value.isEmpty) {
        return 'Digite um nome';
      }
      else if (value.length < 3) {
        return 'O nome deve conter pelo menos 4 caracteres';
      }

      return null;
    },
    'password': (value) {
      if (value == null || value.isEmpty) {
        return 'Digite uma senha';
      }
      else if (value.length < 6) {
        return 'A senha deve conter pelo menos 7 caracteres';
      }

      return null;
    },
  };

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
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                  ),
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.person,
                    ),
                    const SizedBox(height: 10),
                    const Text('Login'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Nome do usuário',
                      ),
                      validator: validators['name'],
                    ),
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Senha',
                      ),
                      validator: validators['password'],
                    ),
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
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                child: const Text('LOGIN'),
                onPressed: () {
                  print('clicado');
                  Navigator.of(context).pushNamed(PagesConfigs.configsPage);
                },
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