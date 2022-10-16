import 'package:flutter/material.dart';
import 'package:get/route_manager.dart';
import 'package:paint/home-page.dart';
import 'package:paint/main_binding.dart';

import 'main2.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomPage(),
      initialBinding: MainBinding(),
    );
  }
}