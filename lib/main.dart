import 'dart:math';
import 'package:flutter/material.dart';
import 'package:aeyrium_sensor/aeyrium_sensor.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Compass(),
    );
  }
}

class Compass extends StatefulWidget {
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> with TickerProviderStateMixin {
  AnimationController cntller;
  var subs;
  var height = 0.0;
  var lastEvent = 0.0;

  void initState() {
    cntller = AnimationController(vsync: this, lowerBound: -3, upperBound: 3);

    subs = AeyriumSensor.sensorEvents.listen((SensorEvent event) {
      if((event.roll-lastEvent).abs() > 0.015) {
        cntller.animateTo(event.roll, duration: Duration(milliseconds: 400), curve: Curves.decelerate);
        if(event.pitch > 1.45) height = 48;
      }
      lastEvent = event.roll;
    });
    super.initState();
  }

  void dispose() {
    cntller.dispose();
    subs.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
        body: Stack(fit: StackFit.expand, children: [
      Image(
          image: AssetImage('res/bg.jpeg'),
          fit: BoxFit.fitHeight),
      Center(child: Container(
              height: width,
              width: width,
              padding: EdgeInsets.all(48),
              child: Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage('res/comp.jpeg')),
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedBuilder(
                      animation: cntller,
                      builder: (_, __) => Transform(
                          alignment: Alignment.center,
                          transform: Matrix4.rotationZ(cntller.value),
                          child: Stack(alignment: Alignment.center, children: [
                            CustomPaint(
                              painter: StarPainter(),
                              size: Size.square(width),
                            ),
                            AnimatedSize(
                              vsync: this,
                              duration: Duration(seconds: 4),
                              curve: Curves.elasticIn,
                              child: Image(
                                image: AssetImage('res/eg.png'),
                                height: height,
                              ))]))))))]));
  }
}

class StarPainter extends CustomPainter {
  final Paint pDark = Paint();

  final titles = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
  final pTxt = TextPainter(textDirection: TextDirection.ltr);
  final stlTxt = TextStyle(color: Color(0xFFEDC394), fontSize: 24, fontFamily: 'Calli', fontWeight: FontWeight.bold);

  StarPainter() {
    pDark
      ..color = Color(0XCC502814)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.colorBurn
      ..maskFilter = MaskFilter.blur(BlurStyle.solid, 2);
  }

  @override
  void paint(Canvas cavs, Size sze) {
    cavs.save();
    cavs.translate(sze.width / 2, sze.height / 2);

    final pth1 = Path();
    final double sizeStep = 40 / 2;

    for (int i = 0; i < 8; i++) {
      pth1.moveTo(0, -30);
      pth1.lineTo(-sizeStep, -50);
      pth1.lineTo(0, -sze.height / 2 + 25);
      pth1.lineTo(sizeStep, -50);
      pth1.close();

      cavs.save();
      cavs.translate(0, -sze.height / 2);

      pTxt.text = TextSpan(style: stlTxt, text: titles[i]);
      pTxt.layout();
      pTxt.paint(cavs, Offset(-pTxt.width / 2, -(pTxt.height / 2) - 18));

      cavs.restore();
      cavs.rotate(2 * pi / 8);
      cavs.drawPath(pth1, pDark);
    }

    cavs.restore();
  }

  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
