import 'package:flutter_test/flutter_test.dart';
import 'package:ipr2025q1/src/stream.dart';

void main() {
  late MyCoolStreamObject streamObject;

  setUp(() {
    /// выполняется перед каждым тестом
    /// инициализация
    streamObject = MyCoolStreamObject();
  });

  tearDown(() {
    /// выполняется после тестов
    streamObject.disposeStream();
  });

  group('Stream test', () {
    test('basic test', () async {
      streamObject.initNewStream(from: 1, to: 3, valueDelay: Duration(milliseconds: 1));
      final values = <int>[];
      final stream = streamObject.stream.value!;
      await for (var value in stream) {
        values.add(value);
      }
      expect(values, [1, 2, 3]);
    });

    test('dispose test', () {
      streamObject.initNewStream(from: 1, to: 2);
      expect(streamObject.stream.value, isNotNull);

      streamObject.disposeStream();
      expect(streamObject.stream.value, isNull);
    });

    test('transformer test', () async {
      streamObject.initNewStream(from: 1, to: 4, valueDelay: Duration(milliseconds: 1), transformer: UglyTransformer());
      final result = <int>[];
      final stream = streamObject.stream.value!;
      await for (var value in stream) {
        result.add(value);
      }
      expect(result, [1, 4, 3, 8]);
    });

    test('stream completes', () async {
      streamObject.initNewStream(from: 1, to: 1);
      final stream = streamObject.stream.value!;
      await stream.drain();

      expect(true, isTrue);
    });

    test('stream pause and resume', () async {
      streamObject.initNewStream(from: 1, to: 2, valueDelay: Duration(milliseconds: 10));
      final stream = streamObject.stream.value!;
      final sub = stream.listen((_) {});
      sub.pause();
      await Future.delayed(Duration(milliseconds: 30));
      expect(sub.isPaused, isTrue);
      sub.resume();
      await sub.asFuture();
    });

    group('group setUp/tearDown', () {
      setUpAll(() {
        // вызовется один раз перед тестом
      });
      tearDownAll(() {
        // вызовется один раз после всей группы
      });

      test('stream emits correct count', () async {
        streamObject.initNewStream(from: 5, to: 7, valueDelay: Duration(milliseconds: 1));
        final count = await streamObject.stream.value!.length;
        expect(count, 3);
      });
    });
  });
}
