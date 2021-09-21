library desktop_entry;

import 'dart:io';

import 'package:xdg_directories/xdg_directories.dart';

export 'icon.dart';

// ignore: public_member_api_docs
const groupDesktopEntry = 'Desktop Entry';

// ignore: public_member_api_docs
const typeApplication = 'Application';

/// Desktop Entry
///
/// See https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html
class DesktopEntry {
  // ignore: public_member_api_docs
  DesktopEntry(this.data);

  /// Parse a Desktop Entry file from a given [path]
  factory DesktopEntry.parseFile(final String path) {
    final lines = File(path).readAsLinesSync().where((final line) => line.isNotEmpty && !line.startsWith('#'));
    final data = <String, Map<String, String>>{};
    late String group;
    for (final line in lines) {
      if (line.startsWith('[') && line.endsWith(']')) {
        group = line.substring(1, line.length - 1);
        data[group] = <String, String>{};
      } else {
        final parts = line.split('=');
        // Remove spaces around =
        final key = parts[0].trimRight();
        final value = parts[1].trimLeft();
        data[group]![key] = value;
      }
    }
    return DesktopEntry(data);
  }

  /// Data of the Desktop Entry
  ///
  /// First map is group and second map is key=value
  final Map<String, Map<String, String>> data;

  /// Get a value using a key
  /// [group] defaults to `Desktop Entry`
  String getValue(
    final String key, {
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(key, group: group)!;

  /// Get a nullable/optional value using a key
  /// [group] defaults to `Desktop Entry`
  String? getNullableValue(
    final String key, {
    final String group = groupDesktopEntry,
  }) =>
      data[group]![key];

  /// `Type` value
  String type({
    final String group = groupDesktopEntry,
  }) =>
      getValue(
        'Type',
        group: group,
      );

  /// `Version` value
  String? version({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'Version',
        group: group,
      );

  /// `Name` value
  String name({
    final String group = groupDesktopEntry,
  }) =>
      getValue(
        'Name',
        group: group,
      );

  /// `GenericName` value
  String? genericName({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'GenericName',
        group: group,
      );

  /// `NoDisplay` value
  bool noDisplay({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'NoDisplay',
        group: group,
      ) ==
      'true';

  /// `Comment` value
  String? comment({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'Comment',
        group: group,
      );

  /// `Icon` value
  String? icon({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'Icon',
        group: group,
      );

  /// `Hidden` value
  bool hidden({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'Hidden',
        group: group,
      ) ==
      'true';

  /// `OnlyShowIn` value
  List<String>? onlyShowIn({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'OnlyShowIn',
        group: group,
      )?.split(';');

  /// `NotShowIn` value
  List<String>? notShowIn({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'NotShowIn',
        group: group,
      )?.split(';');

  /// `DBusActivatable` value
  bool dBusActivatable({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'DBusActivatable',
        group: group,
      ) ==
      'true';

  /// `TryExec` value
  String? tryExec({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'TryExec',
        group: group,
      );

  /// `Exec` value
  String? exec({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'Exec',
        group: group,
      );

  /// `Path` value
  String? path({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'Path',
        group: group,
      );

  /// `Terminal` value
  bool terminal({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'Terminal',
        group: group,
      ) ==
      'true';

  /// `Actions` value
  List<String>? actions({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'Actions',
        group: group,
      )?.split(';');

  /// `MimeType` value
  List<String>? mimeType({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'MimeType',
        group: group,
      )?.split(';');

  /// `Categories` value
  List<String>? categories({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'Categories',
        group: group,
      )?.split(';');

  /// `Implements` value
  List<String>? implements_({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'Implements',
        group: group,
      )?.split(';');

  /// `Keywords` value
  List<String>? keywords({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'Keywords',
        group: group,
      )?.split(';');

  /// `StartupNotify` value
  bool startupNotify({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'StartupNotify',
        group: group,
      ) ==
      'true';

  /// `StartupWMClass` value
  String? startupWMClass({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'StartupWMClass',
        group: group,
      );

  /// `URL` value
  String? url({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'URL',
        group: group,
      );

  /// `PrefersNonDefaultGPU` value
  bool prefersNonDefaultGPU({
    final String group = groupDesktopEntry,
  }) =>
      getNullableValue(
        'PrefersNonDefaultGPU',
        group: group,
      ) ==
      'true';
}

/// List all Desktop Entries
///
/// [withoutLocal] disables search in `$HOME/.local/share/applications`
List<DesktopEntry> listEntries({
  final bool withoutLocal = false,
}) {
  final entries = <String, DesktopEntry>{};
  final dirs = [
    if (!withoutLocal) dataHome,
    ...dataDirs,
  ].map((final d) => Directory('${d.path}/applications'));
  for (final dir in dirs) {
    if (dir.existsSync()) {
      final files = dir.listSync(recursive: true);
      for (final file in files) {
        if (file.path.endsWith('.desktop')) {
          final id = getDesktopFileID(dir.path, file.path);
          if (entries[id] == null) {
            entries[id] = DesktopEntry.parseFile(file.path);
          }
        }
      }
    }
  }
  return entries.values.toList();
}

/// Get the `Desktop File ID` for a given file inside it's `$XDG_DATA_DIRS` component
///
/// See https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html (Section "Desktop File ID")
String getDesktopFileID(final String dir, String path) {
  assert(path.startsWith(dir), 'path has to start with dir');
  path = path.replaceAll(dir, '');
  if (path.startsWith('/')) {
    path = path.substring(1);
  }
  return path.replaceAll('/', '-');
}
