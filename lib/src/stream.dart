import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyCoolStreamObject {
  final ValueNotifier<Stream<int>?> _stream = ValueNotifier(null);

  ValueListenable<Stream<int>?> get stream => _stream;

  /// Инициализируем новый стрим
  void initNewStream({
    required int from,
    required int to,
    /// задержка между событиями
    Duration? valueDelay,
    /// можем применять трансформеры к стримам
    StreamTransformerBase<int, int>? transformer,
  }) {
    disposeStream();
    if (transformer != null) {
      _stream.value = transformer.bind(_streamBuilder(from, to, valueDelay));
    } else {
      _stream.value = _streamBuilder(from, to, valueDelay);
    }
  }

  /// Создаем стрим из заданных параметров
  Stream<int> _streamBuilder(int from, int to, Duration? valueDelay) async* {
    for (var i = from; i <= to; i++) {
      yield i;
      await Future.delayed(valueDelay ?? const Duration(seconds: 1));
    }
  }

  void disposeStream() {
    _stream.value = null;
  }
}

/// Дурацкий трансформер который возвращает не четные числа
/// а четные возводит в квадрат
class UglyTransformer extends StreamTransformerBase<int, int> {
  @override
  Stream<int> bind(Stream<int> stream) async* {
    await for (final value in stream) {
      if (value.isOdd) {
        yield value;
      } else {
        yield value * 2;
      }
    }
  }
}

/// Расширение для мержа стримов
extension StreamExt<T> on List<Stream<T>> {
  /// Поочередно слушаем все стримы
  Stream<T> syncMerge() async* {
    for (final stream in this) {
      await for (final value in stream) {
        yield value;
      }
    }
  }

  /// Кастомный аналог StreamGroup.merge
  Stream<T> asyncMerge() {
    final controller = StreamController<T>();
    var completed = 0;

    for (final stream in this) {
      stream.listen(
        (event) => controller.add(event),
        onError: controller.addError,
        onDone: () {
          completed++;
          if (completed == length) {
            controller.close();
          }
        },
        cancelOnError: false,
      );
    }

    return controller.stream;
  }
}

class StreamScreen extends StatelessWidget {
  final _stream = MyCoolStreamObject();
  final ValueNotifier<Stream<int>?> _anotherStream = ValueNotifier(null);

  StreamScreen({super.key});

  void _postFrameCallback(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      callback.call();
    });
  }

  List<Stream<int>> _createStreams() {
    final customStream = MyCoolStreamObject()..initNewStream(from: 30, to: 40, valueDelay: Duration(milliseconds: 300));

    final streamFromController = Stream<int>.periodic(Duration(milliseconds: 200), (x) => x).take(10);

    final generatorStream = (() async* {
      yield 99;
      await Future.delayed(Duration(milliseconds: 120));
      yield 66;
    })();

    final singleValueStream = Stream<int>.value(999);

    return [
      if (customStream.stream.value case Stream<int> stream) stream,
      streamFromController,
      generatorStream,
      singleValueStream,
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: _stream.stream,
            builder: (context, stream, _) {
              if (stream != null) {
                return StreamBuilder<int>(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      _postFrameCallback(_stream.disposeStream);
                    }
                    return Text('value: ${snapshot.data}');
                  },
                );
              }
              return Text("Stream is null");
            },
          ),

          ElevatedButton(
            onPressed: () {
              _postFrameCallback(() {
                _stream.initNewStream(from: 0, to: 10);
              });
            },
            child: const Text('simple stream'),
          ),
          ElevatedButton(
            onPressed: () {
              _postFrameCallback(() {
                _stream.initNewStream(from: 0, to: 10, transformer: UglyTransformer());
              });
            },
            child: const Text('simple with transformer'),
          ),
          ElevatedButton(
            onPressed: () {
              _postFrameCallback(() {
                _anotherStream.value = _createStreams().syncMerge();
              });
            },
            child: const Text('sync merged streams'),
          ),
          ElevatedButton(
            onPressed: () {
              _postFrameCallback(() {
                _anotherStream.value = _createStreams().asyncMerge();
              });
            },
            child: const Text('async merged streams'),
          ),
          ValueListenableBuilder(
            valueListenable: _anotherStream,
            builder: (context, stream, _) {
              if (stream != null) {
                return StreamBuilder<int>(
                  stream: stream,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      _postFrameCallback((){
                        _anotherStream.value = null;
                      });
                    }

                    return Text('Merged stream value: ${snapshot.data}');
                  },
                );
              }

              return SizedBox();
            },
          ),
        ],
      ),
    );
  }
}
