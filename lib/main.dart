import 'dart:ffi';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sutta/pages/sutta_mapper_page.dart';
import 'package:sqlite3/open.dart';

void main() {
  final scriptDir = File(Platform.script.toFilePath()).parent;
  final libraryNextToScript = File('${scriptDir.path}\\sqlite3.dll');

  if( libraryNextToScript .existsSync() ) {
    open.overrideForAll(() {
      return DynamicLibrary.open(libraryNextToScript.path);
    });
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: const SuttaMapperPage(),
    );
  }
}
