typedef ValidatorsFunction = String Function(String);

abstract class TextFormFieldsValidator {
  static final validators = <String, ValidatorsFunction>{
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
    'email': (value) {
      bool isEmailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
        .hasMatch(value);
      
      if (value == null || value.isEmpty) {
        return 'Digite um e-mail';
      }
      else if (!isEmailValid) {
        return 'Digite um e-mail válido';
      }

      return null;
    },
  };
}