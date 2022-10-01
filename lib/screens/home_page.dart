import "package:flutter/material.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const <Widget>[
            Card(child: Text("Test")),
            Card(child: Text("Test")),
            Text(
              'Welcome to indri.yeah',
            )
          ],
        ),
      ),
    );
  }
}
