import 'package:flutter/material.dart';
import 'package:ipr2025q1/src/animation.dart';
import 'package:ipr2025q1/src/custom_paint.dart';
import 'package:ipr2025q1/src/gesture.dart';
import 'package:ipr2025q1/src/life_cycle.dart';
import 'package:ipr2025q1/src/mvc.dart';
import 'package:ipr2025q1/src/mvi.dart';
import 'package:ipr2025q1/src/mvvm.dart';
import 'package:ipr2025q1/src/stream.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: _HomePage());
  }
}

final pages = {
  'Gesture': Gesture(),
  'Draggable + AutoScroll': GestureDragAutoScrollDemo(),
  'Stream': StreamScreen(),
  'Animation': AnimationPage(),
  'MVC': MvcDemo(),
  'MVI': MviDemo(),
  'MVVM': MvvmDemo(),
  'LifeCycle': LifecycleDemoPage(),
  'CustomPaint': CustomPaintDemo(),
};

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: pages.entries
            .map(
              (e) => ListTile(
                title: Text(e.key),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => e.value));
                },
              ),
            )
            .toList(),
      ),
    );
  }
}
