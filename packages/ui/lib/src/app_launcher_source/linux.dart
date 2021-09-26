import 'dart:io';

import 'package:dbus/dbus.dart';
import 'package:desktop_entry/desktop_entry.dart' as desktop_entry;
import 'package:flutter/widgets.dart';
import 'package:gsettings/gsettings.dart';
import 'package:process/process.dart';

import 'repository.dart';

class LinuxAppLauncherSource extends AppLauncherSourceRepository<desktop_entry.DesktopEntry> {
  @override
  List<Application<desktop_entry.DesktopEntry>> getApplications() {
    final entries = desktop_entry.listEntries().where((final entry) => !entry.noDisplay() && !entry.hidden()).toList();
    final Map<String, List<desktop_entry.Icon>> icons = {};
    for (final icon in desktop_entry.getIcons()) {
      if (icons[icon.name] == null) {
        icons[icon.name] = [];
      }
      icons[icon.name]!.add(icon);
    }
    final List<Application<desktop_entry.DesktopEntry>> applications = [];
    for (final entry in entries) {
      applications.add(
        Application(
          entry.name(),
          () async {
            Widget? image;
            if (entry.icon() != null) {
              if (File(entry.icon()!).existsSync()) {
                // Not standard, but used by some apps
                image = Image.file(File(entry.icon()!));
              } else if (icons[entry.icon()] != null) {
                desktop_entry.Icon icon = _findBestIcon(icons[entry.icon()]!);
                if (icon.path.endsWith('.svg')) {
                  const size = 64;
                  icon = desktop_entry.Icon(
                    await _convertSVGtoPNG(icon.path, size),
                    icon.name,
                    icon.theme,
                    '${size}x$size',
                    icon.category,
                  );
                }
                image = Image.file(File(icon.path));
              }
            }
            return image ?? Container();
          },
          () async {
            await GSettings('sm.puri.phoc').set('auto-maximize', const DBusBoolean(true));
            await GSettings('sm.puri.phoc').set('scale-to-fit', const DBusBoolean(true));
            String exec = entry.exec()!;
            exec = exec.replaceAll('%f', '');
            exec = exec.replaceAll('%F', '');
            exec = exec.replaceAll('%u', '');
            exec = exec.replaceAll('%U', '');
            exec = exec.replaceAll('%i', '');
            exec = exec.replaceAll('%c', '');
            exec = exec.replaceAll('%k', '');
            // TODO: Implement parameters (https://specifications.freedesktop.org/desktop-entry-spec/desktop-entry-spec-latest.html Section "The Exec key")
            await const LocalProcessManager().start(
              exec.split(' ').where((final e) => e.isNotEmpty).toList(),
              mode: ProcessStartMode.detached,
              environment: {
                // https://wiki.archlinux.org/title/wayland#GUI_libraries
                'GDK_BACKEND': 'wayland',
                'QT_QPA_PLATFORM': 'wayland',
                'CLUTTER_BACKEND': 'wayland',
                'SDL_VIDEODRIVER': 'wayland',
              },
            );
          },
        ),
      );
    }
    return applications;
  }

  Future<String> _convertSVGtoPNG(final String path, final int size) async {
    final dir = '${Directory.systemTemp.path}/flutter-mobile-ui/icons';
    if (!Directory(dir).existsSync()) {
      Directory(dir).createSync(recursive: true);
    }
    final outputFile = '$dir/${path.split('/').last.replaceAll('.svg', '.png')}';
    if (File(outputFile).existsSync()) {
      return outputFile;
    }
    final result = await Process.run('convert', [
      '-background',
      'none',
      '-resize',
      '${size}x$size',
      path,
      outputFile,
    ]);
    if (result.exitCode != 0) {
      throw Exception(result.stderr);
    }
    return outputFile;
  }

  desktop_entry.Icon _findBestIcon(final List<desktop_entry.Icon> icons, {final String? theme}) {
    assert(icons.isNotEmpty, 'icons must be provided');
    List<desktop_entry.Icon> bestIcons = icons;

    if (theme != null) {
      final themeIcons = bestIcons.where((final icon) => icon.theme == theme).toList();
      if (themeIcons.isNotEmpty) {
        bestIcons = themeIcons;
      }
    }
    final themeIcons = bestIcons.where((final icon) => icon.theme == 'hicolor').toList();
    if (themeIcons.isNotEmpty) {
      bestIcons = themeIcons;
    }

    final svgIcons = bestIcons.where((final icon) => icon.path.endsWith('svg')).toList();
    if (svgIcons.isNotEmpty) {
      bestIcons = svgIcons;
    }

    final ge64Icons = bestIcons.where((final icon) => icon.pixelSize != null && icon.pixelSize! >= 64).toList();
    if (ge64Icons.isNotEmpty) {
      bestIcons = ge64Icons;
    }

    final gle128Icons = bestIcons.where((final icon) => icon.pixelSize != null && icon.pixelSize! <= 128).toList();
    if (gle128Icons.isNotEmpty) {
      bestIcons = gle128Icons;
    }

    return bestIcons.first;
  }
}
