import 'package:flutter/material.dart';
import 'dart:math';
import 'package:aeyrium_sensor/aeyrium_sensor.dart';
import 'package:flutter/services.dart';


void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_){
    runApp(MyApp());
  });
}

// find . -name "*.dart" | xargs cat | wc -c

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Compass(),
    );
  }
}

class Compass extends StatefulWidget {
  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> with SingleTickerProviderStateMixin {

  AnimationController cntller;

  @override
  void initState() {
    cntller = AnimationController(vsync: this, lowerBound: -3, upperBound: 3);

    AeyriumSensor.sensorEvents.listen((SensorEvent event) {
      cntller.animateTo(event.roll, duration: Duration(milliseconds: 100));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image(image: AssetImage('res/bg.jpeg',), fit: BoxFit.fitHeight),
          Center(
          child: Container(
            height: MediaQuery.of(context).size.width,
            width: MediaQuery.of(context).size.width,
            child: Container(
              padding: const EdgeInsets.all(48),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('res/comp.jpeg')),
                  shape: BoxShape.circle,
                ),
                child:
                    AnimatedBuilder(
                      animation: cntller,
                      builder: (_, __){
                        return Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationZ(cntller.value),
                          child: CustomPaint(
                            painter: StarPainter(),
                            size: Size.square(MediaQuery.of(context).size.width),
                          ),
                        );
                      },
                    ),
              ),
            ),
          ),
        ),],
      ),
    );
  }
}



class StarPainter extends CustomPainter {

  var pDark;
  var pBright;

  static var arrowBrightClr = const Color.fromRGBO(237, 195, 148, 1);
  static var arrowDarkClr = const Color.fromRGBO(80, 40, 20, .7);

  final titles = ["N", "E", "S", "W"];
  final txtPtr = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);
  final txtStl = TextStyle(color: arrowBrightClr, fontSize: 24, fontFamily: 'Calli');

  StarPainter() {
    pDark = Paint();
    pDark.color = arrowDarkClr;
    pDark.style = PaintingStyle.fill;

    pBright = Paint();
    pBright.color = arrowBrightClr;
    pBright.style = PaintingStyle.fill;
  }

  @override
  void paint(Canvas cavs, Size sze) {

    cavs.save();
    cavs.translate(sze.width / 2, sze.height / 2);

    var pth1 = Path();
    var pth2 = Path();

    final double arrowHeight = sze.height / 2;
    final double arrowWidth = 40;

    for (int i = 0; i < 4; i++) {

      pth1.moveTo(0, 0);
      pth1.relativeLineTo(-arrowWidth / 2, -20);
      pth1.relativeLineTo(arrowWidth / 2, -(arrowHeight - 20));
      pth1.close();

      pth2.moveTo(0, 0);
      pth2.relativeLineTo(arrowWidth / 2, -20);
      pth2.relativeLineTo(-arrowWidth / 2, -(arrowHeight - 20));
      pth2.close();

      cavs.save();
      cavs.translate(0, -sze.height/2);

      txtPtr.text = TextSpan(style: txtStl, text: titles[i]);
      txtPtr.layout();
      txtPtr.paint(cavs, Offset(-txtPtr.width / 2, -(txtPtr.height / 2) - 18));

      cavs.restore();

      cavs.rotate(2 * pi / 4);
      cavs.drawPath(pth1, pDark);
      cavs.drawPath(pth2, pBright);
    }

    cavs.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
