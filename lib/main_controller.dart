import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:get/get.dart';

import 'main.dart';

class MainController extends GetxController{
  RxDouble strokeWidth = 2.0.obs;
  Rx<Color> selectedColor = Colors.black.obs;

}