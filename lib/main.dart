import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indriyeahapp/screens/home_page.dart';

// Entry point of the App
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Brightness pltformBrightness = Brightness.light;
    return CupertinoApp(
      builder: (BuildContext context, Widget? child) {
        pltformBrightness = MediaQuery.of(context).platformBrightness;
        return child!;
      },
      debugShowCheckedModeBanner: false,
      title: 'Indri.yeah',
      theme: CupertinoThemeData(brightness: pltformBrightness),
      home: const HomePage(),
    );
  }
}
