import 'dart:io';

import 'package:xdg_directories/xdg_directories.dart';

/// Icon
class Icon {
  // ignore: public_member_api_docs
  Icon(this.path, this.name, this.theme, this.size, this.category);

  /// Path of the icon file
  final String path;

  /// Name of the icon
  ///
  /// Is the file name stripped from the file extension
  final String name;

  /// Name of the icon theme
  final String? theme;

  /// Size of the icon
  ///
  /// If in pixels it has the format 64x64
  final String? size;

  /// Category of the icon
  final String? category;

  /// Get the size in pixels
  /// Returns null if the size is not in pixels
  int? get pixelSize {
    if (size == null) {
      return null;
    }
    if (size!.contains('@')) {
      return int.parse(size!.split('@')[0]);
    }
    if (size!.contains('x')) {
      return int.parse(size!.split('x')[0]);
    }
    return int.tryParse(size!);
  }
}

/// Get all [Icon]'s available
///
/// [withoutLocal] disables search in `$HOME/.local/share/icons`
List<Icon> getIcons({
  final bool withoutLocal = false,
}) {
  final List<Icon> icons = [];
  final dirs = [
    ...[
      if (!withoutLocal) dataHome,
      ...dataDirs,
    ].map((final d) => Directory('${d.path}/icons')),
    // https://specifications.freedesktop.org/icon-theme-spec/icon-theme-spec-latest.html (Section "Directory Layout")
    Directory(
      '/usr/share/pixmaps',
    ),
  ];
  for (final dir in dirs) {
    if (dir.existsSync()) {
      final files = dir.listSync(recursive: true);
      for (final file in files.whereType<File>()) {
        final parts = file.path.replaceAll(dir.path, '').split('/').where((final e) => e.isNotEmpty).toList();
        if (parts.length == 1) {
          final nameParts = parts.last.split('.');
          final name = nameParts.sublist(0, nameParts.length - 1).join('.');
          icons.add(
            Icon(
              file.path,
              name,
              null,
              null,
              null,
            ),
          );
        } else if (parts.length == 4) {
          final nameParts = parts.last.split('.');
          final name = nameParts.sublist(0, nameParts.length - 1).join('.');
          final theme = parts[0];
          String size;
          String category;
          if (theme == 'hicolor') {
            size = parts[1];
            category = parts[2];
          } else {
            size = parts[2];
            category = parts[1];
          }
          icons.add(
            Icon(
              file.path,
              name,
              theme,
              size,
              category,
            ),
          );
        }
      }
    }
  }
  return icons;
}
