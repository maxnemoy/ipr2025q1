import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MvcDemo extends StatelessWidget {
  const MvcDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return CounterController(model: CounterModel(0), child: CounterPage());
  }
}

class CounterModel {
  final int value;

  CounterModel(this.value);
}

class CounterController extends InheritedWidget {
  final ValueNotifier<CounterModel> _model;

  ValueListenable<CounterModel> get model => _model;

  CounterController({super.key, required CounterModel model, required super.child}) : _model = ValueNotifier(model);

  void increment() => _model.value = CounterModel(_model.value.value + 1);

  @override
  bool updateShouldNotify(CounterController oldWidget) => _model.value.value != oldWidget.model.value.value;

  static CounterController of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<CounterController>()!;
  }
}

class CounterPage extends StatefulWidget {
  const CounterPage({super.key});

  @override
  State<CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<CounterPage> {
  @override
  Widget build(BuildContext context) {
    final controller = CounterController.of(context);

    return Builder(
      builder: (context) {
        return Scaffold(
          appBar: AppBar(title: const Text('MVC (Inherited) Counter')),
          body: Center(
            child: ValueListenableBuilder(
              valueListenable: controller.model,
              builder: (context, value, _) => Text('Value: ${value.value}'),
            ),
          ),
          floatingActionButton: FloatingActionButton(onPressed: controller.increment, child: const Icon(Icons.add)),
        );
      },
    );
  }
}
