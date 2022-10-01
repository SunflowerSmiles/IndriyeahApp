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
        colorScheme:
            ColorScheme.fromSwatch(primarySwatch: Colors.deepPurple).copyWith(
          secondary: Colors.pink.shade200,
        ),
        // textTheme: Typography.whiteRedmond.copyWith(title),
      ),
      home: const HomePage(),
    );
  }
}
