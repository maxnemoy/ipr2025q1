import 'dart:async';
import 'package:flutter/material.dart';

class MviDemo extends StatelessWidget {
  const MviDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return CounterMviController(child: const CounterMviPage());
  }
}

class CounterState {
  final int value;
  const CounterState(this.value);
}

enum CounterIntent { increment }

class CounterMviController extends InheritedWidget {
  final _stateController = StreamController<CounterState>.broadcast();
  final ValueNotifier<CounterState> _current = ValueNotifier(CounterState(0));

  CounterMviController({super.key, required super.child}) {
    _stateController.add(_current.value);
  }

  Stream<CounterState> get state => _stateController.stream;

  void addIntent(CounterIntent intent) {
    switch (intent) {
      case CounterIntent.increment:
        _current.value = CounterState(_current.value.value + 1);
        _stateController.add(_current.value);
    }
  }

  static CounterMviController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterMviController>()!;
  }

  @override
  bool updateShouldNotify(covariant CounterMviController oldWidget) => false;
}

class CounterMviPage extends StatefulWidget {
  const CounterMviPage({super.key});

  @override
  State<CounterMviPage> createState() => _CounterMviPageState();
}

class _CounterMviPageState extends State<CounterMviPage> {
  late CounterMviController controller;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller = CounterMviController.of(context);
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<CounterState>(
      stream: controller.state,
      initialData: const CounterState(0),
      builder: (context, snapshot) {
        final state = snapshot.data ?? const CounterState(0);
        return Scaffold(
          appBar: AppBar(title: const Text('MVI (Stream) Counter')),
          body: Center(child: Text('Value: ${state.value}')),
          floatingActionButton: FloatingActionButton(
            onPressed: () => controller.addIntent(CounterIntent.increment),
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}
