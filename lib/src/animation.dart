import 'package:flutter/material.dart';
import 'dart:math';

class AnimationPage extends StatelessWidget {
  const AnimationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: _ComplexAnimation()));
  }
}

class _ComplexAnimation extends StatefulWidget {
  const _ComplexAnimation({Key? key}) : super(key: key);

  @override
  State<_ComplexAnimation> createState() => _ComplexAnimationState();
}

class _ComplexAnimationState extends State<_ComplexAnimation> with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _rotateController;
  late final AnimationController _shapeController;

  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotateAnimation;
  late final Animation<double> _borderRadiusAnimation;

  @override
  void initState() {
    super.initState();
    final duration = const Duration(seconds: 1);

    _fadeController = AnimationController(vsync: this, duration: duration);
    _fadeAnimation = CurvedAnimation(parent: _fadeController, curve: Curves.easeIn);

    _rotateController = AnimationController(vsync: this, duration: duration);
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: pi * 2,
    ).animate(CurvedAnimation(parent: _rotateController, curve: Curves.easeInOutCubic));

    _shapeController = AnimationController(vsync: this, duration: duration);

    _borderRadiusAnimation = Tween<double>(
      begin: 0,
      end: 50,
    ).animate(CurvedAnimation(parent: _shapeController, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _rotateController.dispose();
    _shapeController.dispose();
    super.dispose();
  }

  Future<void> _startSequentialAnimation() async {
    await _fadeController.forward(from: 0);
    await _rotateController.forward(from: 0);
    await _shapeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Explicit-animation demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: Listenable.merge([_fadeController, _rotateController, _shapeController]),
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.rotate(
                    angle: _rotateAnimation.value,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(_borderRadiusAnimation.value),
                      ),
                      alignment: Alignment.center,
                      child: const Text('animated object', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 40),
            ElevatedButton(onPressed: _startSequentialAnimation, child: const Text('animate')),
            ElevatedButton(
              onPressed: () async {
                await _rotateController.reverse();
                await _shapeController.reverse();
                await _fadeController.reverse();
              },
              child: const Text('reverse'),
            ),
          ],
        ),
      ),
    );
  }
}
