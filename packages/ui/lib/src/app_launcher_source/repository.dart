import 'package:flutter/widgets.dart';

abstract class AppLauncherSourceRepository<T> {
  List<Application<T>> getApplications();

  List<Application<T>>? _cache;

  List<Application<T>> getCachedApplications() => _cache ??= getApplications();
}

class Application<T> {
  Application(
    this.name,
    this.getIcon,
    this.launch,
  );

  final String name;
  final Future<Widget> Function() getIcon;
  final Function() launch;
}
