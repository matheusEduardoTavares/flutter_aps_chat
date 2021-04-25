import 'dart:convert';
import 'package:meta/meta.dart';

class User {
  int id;
  String name;
  String password;
  bool isDarkTheme;
  bool isLogged;
  User({
    this.id,
    @required this.name,
    @required this.password,
    @required this.isDarkTheme,
    this.isLogged = false,
  });

  User copyWith({
    int id,
    String name,
    String password,
    bool isDarkTheme,
    bool isLogged,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      password: password ?? this.password,
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
      isLogged: isLogged ?? this.isLogged,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'isDarkTheme': isDarkTheme,
      'isLogged': isLogged
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'isDarkTheme': isDarkTheme ? 1 : 0,
      'isLogged': isLogged ? 1 : 0,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      password: map['password'],
      isDarkTheme: map['isDarkTheme'],
      isLogged: map['isLogged'],
    );
  }

  factory User.fromDbMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      password: map['password'],
      isDarkTheme: map['isDarkTheme'] == 1 ? true : false,
      isLogged: map['isLogged'] == 1 ? true : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) => User.fromMap(json.decode(source));

  @override
  String toString() => 'User(id: $id, name: $name, password: $password, isDarkTheme: $isDarkTheme, isLogged: $isLogged)';
}
