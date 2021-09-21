import 'package:flutter/widgets.dart';

abstract class AppLauncherSourceRepository<T> {
  List<Application<T>> getApplications();

  List<Application<T>>? _cache;

  List<Application<T>> getCachedApplications() => _cache ??= getApplications();
}

class Application<T> {
  Application(
    this.name,
    this.icon,
    this.data,
    this.launch,
  );

  final String name;
  final Widget? icon;
  final T data;
  final Function(T data) launch;
}
