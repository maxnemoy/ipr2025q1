import 'dart:math';

import 'package:flutter/material.dart';

class AnimationPage2 extends StatelessWidget {
  const AnimationPage2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: Center(child: _StaggeredAnimation()));
  }
}

class _StaggeredAnimation extends StatefulWidget {
  @override
  State<_StaggeredAnimation> createState() => _StaggeredAnimationState();
}

class _StaggeredAnimationState extends State<_StaggeredAnimation> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _rotateAnimation;
  late final Animation<double> _borderRadiusAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(seconds: 3), vsync: this);

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
    );
    _rotateAnimation = Tween<double>(begin: 0, end: pi * 2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.6, curve: Curves.easeInOut),
      ),
    );
    _borderRadiusAnimation = Tween<double>(begin: 0, end: 50).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AnimatedBuilder(
          animation: _controller,
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
        ElevatedButton(onPressed: () => _controller.forward(from: 0), child: const Text('animate')),
        ElevatedButton(onPressed: () => _controller.reverse(), child: const Text('reverse')),
      ],
    );
  }
}
