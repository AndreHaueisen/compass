import 'package:flutter/material.dart';
import 'dart:math';
import 'package:aeyrium_sensor/aeyrium_sensor.dart';
import 'package:flutter/services.dart';

void main() {
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Compass(),
    );
  }
}

class Compass extends StatefulWidget {
  @override
  _CompassState createState() => _CompassState();
}

class _CompassState extends State<Compass> with TickerProviderStateMixin {
  AnimationController cntller;
  var subs;
  var height = 0.0;

  @override
  void initState() {
    cntller = AnimationController(vsync: this, lowerBound: -3, upperBound: 3);

    subs = AeyriumSensor.sensorEvents.listen((SensorEvent event) {
      cntller.animateTo(event.roll, duration: Duration(milliseconds: 100));
      height = cntller.value < -2 ? 36 : 0;
    });

    super.initState();
  }

  @override
  void dispose() {
    cntller.dispose();
    subs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image(
              image: AssetImage(
                'res/bg.jpeg',
              ),
              fit: BoxFit.fitHeight),
          Center(
            child: Container(
              height: width,
              width: width,
              padding: const EdgeInsets.all(48),
              child: Container(
                decoration: BoxDecoration(
                  image: DecorationImage(image: AssetImage('res/comp.jpeg')),
                  shape: BoxShape.circle,
                ),
                child: AnimatedBuilder(
                  animation: cntller,
                  builder: (_, __) {
                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.rotationZ(cntller.value),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          CustomPaint(
                            painter: StarPainter(),
                            size: Size.square(width),
                          ),
                          AnimatedSize(
                            vsync: this,
                            duration: Duration(seconds: 4),
                            child: Image(
                              image: AssetImage('res/logo.png'),
                              height: height,
                            ),
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StarPainter extends CustomPainter {
  Paint pDark;

  final titles = ["N", "NE", "E", "SE", "S", "SW", "W", "NW"];
  final txtPtr = TextPainter(textAlign: TextAlign.center, textDirection: TextDirection.ltr);
  final txtStl = TextStyle(color: Color(0xFFEDC394), fontSize: 24, fontFamily: 'Calli', fontWeight: FontWeight.bold);

  StarPainter() {
    pDark = Paint();
    pDark.color = Color(0XCC502814);
    pDark.style = PaintingStyle.fill;
    pDark.maskFilter = MaskFilter.blur(BlurStyle.solid, 2);
    pDark.blendMode = BlendMode.colorBurn;
  }

  @override
  void paint(Canvas cavs, Size sze) {
    cavs.save();
    cavs.translate(sze.width / 2, sze.height / 2);

    var pth1 = Path();
    
    final double sizeStep = 40 / 2;

    for (int i = 0; i < 8; i++) {
      pth1.moveTo(0, -30);
      pth1.lineTo(-sizeStep, -50);
      pth1.lineTo(0, - sze.height / 2 + 25);
      pth1.lineTo(sizeStep, -50);
      pth1.close();

      cavs.save();
      cavs.translate(0, -sze.height / 2);

      txtPtr.text = TextSpan(style: txtStl, text: titles[i]);
      txtPtr.layout();
      txtPtr.paint(cavs, Offset(-txtPtr.width / 2, -(txtPtr.height / 2) - 18));

      cavs.restore();

      cavs.rotate(2 * pi / 8);
      cavs.drawPath(pth1, pDark);
    }

    cavs.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
