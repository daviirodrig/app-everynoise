import 'package:dynamic_color/dynamic_color.dart';
import 'package:flutter/material.dart';

import 'home.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  static final _defaultLightColorScheme =
      ColorScheme.fromSwatch(primarySwatch: Colors.pink);

  static final _defaultDarkColorScheme = ColorScheme.fromSwatch(
      primarySwatch: Colors.pink, brightness: Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (lightDynamic, darkDynamic) {
        return MaterialApp(
          title: 'Everynoise',
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: lightDynamic ?? _defaultLightColorScheme,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: darkDynamic ?? _defaultDarkColorScheme,
          ),
          themeMode: ThemeMode.dark,
          home: const MyHomePage(title: 'EveryNoise'),
        );
      },
    );
  }
}
