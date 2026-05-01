import 'package:flutter/material.dart';
import 'pages/list_page.dart';
import 'pages/scan_page.dart';
import 'pages/debug_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '發票小助手',
      theme: ThemeData(primarySwatch: Colors.pink),
      
      initialRoute: '/scan', 
      
      routes: {
        '/scan': (context) => ScanPage(),
        '/list': (context) => ListPage(),
        '/debug': (context) => const DebugPage(),
      },
    );
  }
}