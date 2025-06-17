// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'some_page.dart';

// **************************************************************************
// RouteParamsGenerator
// **************************************************************************

class SomePageParams {
  final Key? key;
  final int someIntParam;
  final String someStringParam;
  const SomePageParams({
    this.key,
    required this.someIntParam,
    required this.someStringParam,
  });
}

class SomePageRoute extends GeneratedModalRoute {
  SomePageRoute(SomePageParams params)
    : super(
        widget: SomePage(
          key: params.key,
          someIntParam: params.someIntParam,
          someStringParam: params.someStringParam,
        ),
      );
}
