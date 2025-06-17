import 'package:flutter/material.dart';
import 'package:ipr2025q1/router_objects.dart';

part 'some_page.router.dart';

@ScreenRoute(isModal: true)
class SomePage extends StatelessWidget {
  final int someIntParam;
  final String someStringParam;

  const SomePage({super.key, required this.someIntParam, required this.someStringParam});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
