import 'dart:async';
import 'package:build/build.dart';
import 'package:ipr2025q1/router_objects.dart';

import 'package:source_gen/source_gen.dart';
import 'package:analyzer/dart/element/element.dart';

class RouteParamsGenerator extends GeneratorForAnnotation<ScreenRoute> {
  @override
  FutureOr<String?> generateForAnnotatedElement(Element element, ConstantReader annotation, BuildStep buildStep) {
    final className = element.displayName;
    final paramsClassName = '${className}Params';
    final routeClassName = '${className}Route';

    if (element is! ClassElement) return null;
    final classElement = element as ClassElement;
    final constructor = classElement.unnamedConstructor;
    if (constructor == null) return null;

    /// чекаем параметры
    final isModal = annotation.read('isModal').boolValue;
    final routeSuper = isModal ? 'GeneratedModalRoute' : 'GeneratedDefaultRoute';

    final buffer = StringBuffer();

    /// забираем свойства из помеченного класса и генерируем 
    /// класс параметров маршрута
    buffer.writeln('class $paramsClassName {');
    for (final param in constructor.parameters) {
      final type = param.type.getDisplayString();
      final name = param.name;
      buffer.writeln('  final $type $name;');
    }
    buffer.write('  const $paramsClassName({');
    for (final param in constructor.parameters) {
      final isRequired = param.isRequiredNamed ? 'required ' : '';
      final name = param.name;
      final defaultValue = param.defaultValueCode != null ? ' = ${param.defaultValueCode}' : '';
      buffer.write('$isRequired this.$name$defaultValue, ');
    }
    buffer.writeln('});');
    buffer.writeln('}');

    /// собираем роут
    buffer.writeln('class $routeClassName extends $routeSuper {');
    buffer.write('  $routeClassName($paramsClassName params)');
    buffer.write(' : super(widget: $className(');
    /// подставляем параметры
    for (final param in constructor.parameters) {
      final name = param.name;
      buffer.write('$name: params.$name, ');
    }

    buffer.writeln('));');
    buffer.writeln('}');
    
    /// пишем в файлик
    return buffer.toString();
  }
}
/// гененруем файл и подсовываем туда part of
Builder routeParamsBuilder(BuilderOptions options) => PartBuilder([RouteParamsGenerator()], '.router.dart');
