import 'dart:async';
import 'package:flutter/material.dart';

class LifecycleDemoPage extends StatefulWidget {
  const LifecycleDemoPage({super.key});

  @override
  State<LifecycleDemoPage> createState() => _LifecycleDemoPageState();
}

class _LifecycleDemoPageState extends State<LifecycleDemoPage> {
  final GlobalKey<_LifecycleState> _lifecycleKey = GlobalKey<_LifecycleState>();
  late StreamController<int> _controller;
  late Stream<int> _broadcastStream;
  int _count = 0;
  bool _show = true;

  @override
  void initState() {
    super.initState();
    _controller = StreamController<int>();
    _broadcastStream = _controller.stream.asBroadcastStream();
  }

  void _addValue() => _controller.add(++_count);

  void _changeStream() {
    _controller.close();
    _controller = StreamController<int>();
    _broadcastStream = _controller.stream.asBroadcastStream();
    _count = 0;
    setState(() {});
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(onPressed: _addValue, child: const Text('Добавить значение')),
              ElevatedButton(onPressed: _changeStream, child: const Text('Сменить стрим')),
              ElevatedButton(
                onPressed: () => setState(() => _show = !_show),
                child: Text(_show ? 'Скрыть виджет' : 'Показать виджет'),
              ),
            ],
          ),
          if (_show) _Lifecycle(key: _lifecycleKey, stream: _broadcastStream, label: 'Демонстрация жизненного цикла'),
        ],
      ),
    );
  }
}

class _Lifecycle extends StatefulWidget {
  final Stream<int> stream;
  final String label;
  const _Lifecycle({super.key, required this.stream, required this.label});

  @override
  State<_Lifecycle> createState() => _LifecycleState();
}

class _LifecycleState extends State<_Lifecycle> {
  late StreamSubscription<int> _subscription;
  int? _latestValue;
  int _updates = 0;

  @override
  void initState() {
    super.initState();
    debugPrint('витжет создан');
    _subscribe();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    debugPrint('готов контекст');
  }

  @override
  void didUpdateWidget(covariant _Lifecycle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.stream != oldWidget.stream) {
      debugPrint('обновился стрим');
      _subscription.cancel();
      _subscribe();
    } else {
      debugPrint('параметр изменился, но стрим прежний');
    }
  }

  void _subscribe() {
    _subscription = widget.stream.listen((value) {
      setState(() {
        _latestValue = value;
        _updates++;
      });
    });
  }

  @override
  void deactivate() {
    debugPrint('временно удален из дерева при навигации или скролле');
    super.deactivate();
  }

  @override
  void dispose() {
    debugPrint('виджет удаляется, чистим ресурсы');
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('перерисовываем виджет');
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(widget.label, style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 12),
            Text('Последнее значение: $_latestValue', style: const TextStyle(fontSize: 16)),
            Text('Всего обновлений: $_updates', style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
    );
  }
}
