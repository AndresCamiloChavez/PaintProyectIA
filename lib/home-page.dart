import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class HomPage extends StatelessWidget {
  const HomPage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Column(children: [
          Lottie.network(
              'https://assets10.lottiefiles.com/packages/lf20_ytego1wb.json'),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(5),
            child: Text(
              '¡Vamos a dibujar!',
              style: TextStyle(
                  fontSize: 30,
                  fontStyle: FontStyle.normal,
                  fontWeight: FontWeight.w700),
            ),
          )
        ]),
      ),
    );
  }
}
