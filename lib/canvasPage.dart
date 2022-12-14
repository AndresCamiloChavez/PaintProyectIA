import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite/tflite.dart';

class CanvasPainting extends StatefulWidget {
  @override
  _CanvasPaintingState createState() => _CanvasPaintingState();
}

class _CanvasPaintingState extends State<CanvasPainting> {
  GlobalKey globalKey = GlobalKey();

  List<TouchPoints?> points = [];
  double opacity = 1.0;
  StrokeCap strokeType = StrokeCap.round;
  double strokeWidth = 3.0;
  Color selectedColor = Colors.black;
  dynamic currentPath = '';
  dynamic salida;

  @override
  void initState() {
    super.initState();
    loadModel();
  }

/**
 * Para seleccionar el tamaño de la brocha
 */
  Future<void> _pickStroke() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ClipOval(
          child: AlertDialog(
            actions: <Widget>[
              ElevatedButton(
                child: Icon(
                  Icons.clear,
                ),
                onPressed: () {
                  strokeWidth = 3.0;
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Icon(
                  Icons.brush,
                  size: 24,
                ),
                onPressed: () {
                  strokeWidth = 10.0;
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Icon(
                  Icons.brush,
                  size: 40,
                ),
                onPressed: () {
                  strokeWidth = 30.0;
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Icon(
                  Icons.brush,
                  size: 60,
                ),
                onPressed: () {
                  strokeWidth = 50.0;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

/**
 * Para seleccionar la opacidad del marker
 */
  Future<void> _opacity() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return ClipOval(
          child: AlertDialog(
            actions: <Widget>[
              MaterialButton(
                child: Icon(
                  Icons.opacity,
                  size: 24,
                ),
                onPressed: () {
                  //most transparent
                  opacity = 0.1;
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                child: Icon(
                  Icons.opacity,
                  size: 40,
                ),
                onPressed: () {
                  opacity = 0.5;
                  Navigator.of(context).pop();
                },
              ),
              MaterialButton(
                child: Icon(
                  Icons.opacity,
                  size: 60,
                ),
                onPressed: () {
                  //not transparent at all.
                  opacity = 1.0;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

/**
 * Para guardar la imagen generada en el canvas y guardarla en el dispositivo
 */
  Future<void> _save() async {
    final RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    //Verificamos los permisos para acceder al storage
    if (!(await Permission.storage.status.isGranted))
      await Permission.storage.request();

    final result = await ImageGallerySaver.saveImage(
        Uint8List.fromList(pngBytes),
        quality: 100,
        name: "canvas_image");
    print('resultado $result');
    currentPath = result['filePath'];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            points.add(TouchPoints(
                points: renderBox.globalToLocal(details.globalPosition),
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
        },
        onPanStart: (details) {
          setState(() {
            RenderBox renderBox = context.findRenderObject() as RenderBox;
            points.add(TouchPoints(
                points: renderBox.globalToLocal(details.globalPosition),
                paint: Paint()
                  ..strokeCap = strokeType
                  ..isAntiAlias = true
                  ..color = selectedColor.withOpacity(opacity)
                  ..strokeWidth = strokeWidth));
          });
        },
        onPanEnd: (details) {
          setState(() {
            points.add(null);
          });
        },
        child: RepaintBoundary(
          key: globalKey,
          child: Stack(
            children: <Widget>[
              Container(
                width: double.infinity,
                height: double.infinity,
                child: Image.asset(
                  "assets/white.jpeg",
                  fit: BoxFit.cover,
                ),
              ),
              CustomPaint(
                size: Size.infinite,
                painter: MyPainter(
                  pointsList: points,
                ),
              ),
              Container(
                width: double.infinity,
                margin: EdgeInsets.symmetric(vertical: 50, horizontal: 20),
                child: Positioned(
                  top: 100,
                  child: Bounce(
                    infinite: true,
                    duration: Duration(milliseconds: 900),
                    animate: true,
                    manualTrigger: false,
                    child: Flexible(
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        height: 70,
                        decoration: const BoxDecoration(
                            color: Colors.blue,
                            borderRadius:
                                BorderRadius.all(Radius.circular(20))),
                        child: Text(
                          (salida != null)
                              ? 'Eso es -> ${salida[0]['label'].toString().substring(2)}'
                              : 'No hay un resultado',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          textAlign: ui.TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: "paint_stroke",
            child: Icon(Icons.brush),
            tooltip: 'Stroke',
            onPressed: () {
              //min: 0, max: 50
              setState(() {
                _pickStroke();
              });
            },
          ),
          FloatingActionButton(
            heroTag: "paint_opacity",
            child: Icon(Icons.opacity),
            tooltip: 'Opacidad',
            onPressed: () {
              //min:0, max:1
              setState(() {
                _opacity();
              });
            },
          ),
          FloatingActionButton(
              heroTag: "erase",
              backgroundColor: Colors.red,
              child: const Icon(Icons.delete),
              tooltip: "Eliminar",
              onPressed: () {
                setState(() {
                  points.clear();
                });
              }),
          FloatingActionButton(
              backgroundColor: Colors.green,
              heroTag: "Válidar",
              child: Icon(Icons.check),
              tooltip: "Válidar",
              onPressed: () async {
                await _save();
                clasifyImage();
                setState(() {});
              }),
          // FloatingActionButton(
          //   backgroundColor: Colors.white,
          //   heroTag: "color_red",
          //   child: colorMenuItem(Colors.red),
          //   tooltip: 'Color',
          //   onPressed: () {
          //     setState(() {
          //       selectedColor = Colors.red;
          //     });
          //   },
          // ),
          // FloatingActionButton(
          //   backgroundColor: Colors.white,
          //   heroTag: "color_green",
          //   child: colorMenuItem(Colors.green),
          //   tooltip: 'Color',
          //   onPressed: () {
          //     setState(() {
          //       selectedColor = Colors.green;
          //     });
          //   },
          // ),
          // FloatingActionButton(
          //   backgroundColor: Colors.white,
          //   heroTag: "color_pink",
          //   child: colorMenuItem(Colors.pink),
          //   tooltip: 'Color',
          //   onPressed: () {
          //     setState(() {
          //       selectedColor = Colors.pink;
          //     });
          //   },
          // ),
          // FloatingActionButton(
          //   backgroundColor: Colors.white,
          //   heroTag: "color_blue",
          //   child: colorMenuItem(Colors.blue),
          //   tooltip: 'Color',
          //   onPressed: () {
          //     setState(() {
          //       selectedColor = Colors.blue;
          //     });
          //   },
          // )
        ],
      ),
    );
  }

  Widget colorMenuItem(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 8.0),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/model_unquant.tflite', labels: 'assets/labels.txt');
  }

  clasifyImage() async {
    var output = await Tflite.runModelOnImage(
        path: currentPath,
        numResults: 2,
        threshold: 0.5,
        imageMean: 127.5,
        imageStd: 127.5);

    setState(() {
      salida = output;
    });
  }
}

class MyPainter extends CustomPainter {
  MyPainter({required this.pointsList});

  // Lista de puntos en la pantalla
  List<TouchPoints?> pointsList;
  List<Offset> offsetPoints = [];

  //A dibujar
  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < pointsList.length - 1; i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i]!.points, pointsList[i + 1]!.points,
            pointsList[i]!.paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        offsetPoints.clear();
        offsetPoints.add(pointsList[i]!.points);
        offsetPoints.add(Offset(
            pointsList[i]!.points.dx + 0.1, pointsList[i]!.points.dy + 0.1));
        canvas.drawPoints(
            ui.PointMode.points, offsetPoints, pointsList[i]!.paint);
      }
    }
  }
  //Volver a construir el canvas con los nuevos cambios
  @override
  bool shouldRepaint(MyPainter oldDelegate) => true;
}

class TouchPoints {
  Paint paint;
  Offset points;
  TouchPoints({required this.points, required this.paint});
}
