import 'package:flutter/material.dart';
import 'package:indriyeahapp/screens/home_page.dart';

// Entry point of the App
void main() {
  runApp(const App());
}

// TODO: add the loading/ initial animation
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'indri.yeah',
      theme: ThemeData(
        colorScheme: const ColorScheme.light().copyWith(
          background: Colors.white,
          primary: const Color.fromARGB(255, 249, 252, 217),
          onPrimary: const Color.fromARGB(255, 39, 59, 74),
          secondary: const Color.fromARGB(255, 157, 114, 190),
          secondaryContainer: const Color.fromARGB(255, 177, 146, 216),
          onSecondary: const Color.fromARGB(255, 254, 241, 153),
        ),
      ),
      darkTheme: ThemeData(),
      home: const HomePage(),
    );
  }
}
