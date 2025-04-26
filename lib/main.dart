import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:json_theme/json_theme.dart';
//import 'package:json_theme/json_theme.dart';
import 'package:sadovod/View/splash_screen.dart';
import 'package:sadovod/theme/app_theme.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


/*
надо попробовать использовать этот Widget для остановки в списке на определенном элементе
https://pub.dev/packages/scrollable_positioned_list/example
*/

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://lixmqqrrbeooilttgkbl.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxpeG1xcXJyYmVvb2lsdHRna2JsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDI2NzExNjYsImV4cCI6MjA1ODI0NzE2Nn0.T8oqCyR5SRuf5G9gFxTStMgrgBvf8r-xy3VJbz-c6H0',
    //debug: true,
    realtimeClientOptions: const RealtimeClientOptions(
      timeout: Duration(seconds: 30), // Увеличиваем таймаут
    ),
  );

  final themeStr = await rootBundle.loadString('assets/appainter_theme.json');
  final themeJson = json.decode(themeStr);
  final theme = ThemeDecoder.decodeThemeData(
    themeJson,
    validate: true,
  ) ?? ThemeData();

  runApp(MyApp(theme: theme));
}

class MyApp extends StatelessWidget {
  final ThemeData theme;
  //required this.theme
  //const MyApp({super.key, required this.theme});
  MyApp({super.key, required this.theme,});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sadovod',
      debugShowCheckedModeBanner: false,
      //theme: theme,
      theme: AppTheme.lightTheme(), // Светлая тема по умолчанию
      //darkTheme: AppTheme.darkTheme(), // Тёмная тема
      themeMode: ThemeMode.system,
      home: SplashScreen(),
    );
  }



}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
