import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:indriyeahapp/screens/home_page.dart';

import 'package:http/http.dart' as http;

// Entry point of the App
void main() { 
  Session session = createSession();
  
  runApp(const MyApp());
}

class Session {
  Map<String, StriSeng> headers;

  Session () {
    headers = {}/;
  }

  Future<Map> get (String URL) async {
    http.Response response = await http.get(URL, headers : headers);
    updateCookie(response);

    return json.decode(reponse.body);
  }

  Future<Map> post  (String URL, dynamic data) async {
    http.Response response = await http.post(URL, body:data, headers:headers);
    updateCookie(response);
  }

  void updateCookie (http.Response response) {
    String rawCookie = response.headers['set-cookie'];
    if (rawCookie != null) {
      int index = rawCookie.indexOf(';');
      headers['cookie'] = (index == -1) ? rawCookie : rawCookie.substring(0,index);
    }
  }
} 

Session createSession () {
  Session session = new Session();

  return session;
}

// register the cookie
void register (Session session) {
  session.post('/api/register',null);
}

// append the history
void append_history (Session session, String history_element) {
  session.post('/api/append_history/'+history_element);
}

// get history
// returns the lines in HISTORY.log  [start, end), similar to slicing
// or substrings, first index is inclusive, the second is exclusive
List<String> get_history (Session session, int start, int end) {
  Map<String, dynamic> history_items = session.get('/api/get_history/'+start+'/'+end);
  return history_items["src"];
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
