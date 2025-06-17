class ScreenRoute {
  final bool isModal;
  const ScreenRoute({this.isModal = false});
}

class BaseRouteParams {}

abstract interface class IRoute<BaseRouteParams> {
  Object build();
}

abstract class GeneratedModalRoute {
  final Object widget;
  const GeneratedModalRoute({required this.widget});
}

abstract class GeneratedDefaultRoute {
  final Object widget;
  const GeneratedDefaultRoute({required this.widget});
}