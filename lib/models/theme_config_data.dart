import 'dart:convert';
import 'package:meta/meta.dart';

class ThemeConfigData {
  bool isDarkTheme;
  ThemeConfigData({
    @required this.isDarkTheme,
  });

  ThemeConfigData copyWith({
    bool isDarkTheme,
  }) {
    return ThemeConfigData(
      isDarkTheme: isDarkTheme ?? this.isDarkTheme,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'isDarkTheme': isDarkTheme,
    };
  }

  Map<String, dynamic> toDbMap() {
    return {
      'isDarkTheme': isDarkTheme ? 1 : 0,
    };
  }

  factory ThemeConfigData.fromMap(Map<String, dynamic> map) {
    return ThemeConfigData(
      isDarkTheme: map['isDarkTheme'],
    );
  }

  factory ThemeConfigData.fromDbMap(Map<String, dynamic> map) {
    return ThemeConfigData(
      isDarkTheme: map['isDarkTheme'] == 1 ? true : false,
    );
  }

  String toJson() => json.encode(toMap());

  factory ThemeConfigData.fromJson(String source) => ThemeConfigData.fromMap(json.decode(source));
}
