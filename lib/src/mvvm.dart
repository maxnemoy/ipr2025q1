import 'package:flutter/material.dart';

class MvvmDemo extends StatelessWidget {
  const MvvmDemo({super.key});
  @override
  Widget build(BuildContext context) {
    return CounterViewModelProvider(viewModel: CounterViewModel(), child: const CounterMvvmPage());
  }
}

class CounterModel {
  final int value;
  const CounterModel(this.value);
}

class CounterViewModel extends ChangeNotifier {
  CounterModel _model = const CounterModel(0);

  CounterModel get model => _model;

  void increment() {
    _model = CounterModel(_model.value + 1);
    notifyListeners();
  }
}

class CounterViewModelProvider extends InheritedWidget {
  final CounterViewModel viewModel;
  const CounterViewModelProvider({required this.viewModel, required super.child, super.key});

  static CounterViewModel of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<CounterViewModelProvider>();
    assert(provider != null, 'No CounterViewModelProvider found in context');
    return provider!.viewModel;
  }

  @override
  bool updateShouldNotify(CounterViewModelProvider oldWidget) => viewModel != oldWidget.viewModel;
}

class CounterMvvmPage extends StatefulWidget {
  const CounterMvvmPage({super.key});
  @override
  State<CounterMvvmPage> createState() => _CounterMvvmPageState();
}

class _CounterMvvmPageState extends State<CounterMvvmPage> {
  late CounterViewModel viewModel;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    viewModel = CounterViewModelProvider.of(context);
    viewModel.addListener(_update);
  }

  @override
  void dispose() {
    viewModel.removeListener(_update);
    super.dispose();
  }

  void _update() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MVVM Counter')),
      body: Center(child: Text('Value: ${viewModel.model.value}')),
      floatingActionButton: FloatingActionButton(onPressed: viewModel.increment, child: const Icon(Icons.add)),
    );
  }
}
