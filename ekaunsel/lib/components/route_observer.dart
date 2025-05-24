import 'package:flutter/widgets.dart';

/// Holds the current route name globally
String currentRoute = '';

/// Global route observer
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

/// Custom RouteAware implementation that updates `currentRoute`
class RouteTracker extends RouteAware {
  final void Function(String route)? onChanged;

  RouteTracker({this.onChanged});

  @override
  void didPush() {
    if (onChanged != null) onChanged!(currentRoute);
  }

  @override
  void didPushNext() {}

  @override
  void didPop() {}

  @override
  void didPopNext() {}

  void didChangeDependencies() {}
}
