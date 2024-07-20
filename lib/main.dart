import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';

import 'Home Screen/homeScreen.dart';

void main()async{
  await Hive.initFlutter();
  await Hive.openBox('weatherBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const homeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
