import 'dart:io';

import 'package:desktop_entry/desktop_entry.dart' as desktop_entry;
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
      Widget? image;
      if (entry.icon() != null && icons[entry.icon()] != null) {
        final icon = _findBestIcon(icons[entry.icon()]!, theme: 'breeze');
        if (icon.path.endsWith('.svg')) {
          image = SvgPicture.file(File(icon.path));
        } else {
          image = Image.file(File(icon.path));
        }
      }
      applications.add(
        Application(
          entry.name(),
          image,
          entry,
          (final entry) {
            print('launching ${entry.name()}');
          },
        ),
      );
    }
    return applications;
  }

  desktop_entry.Icon _findBestIcon(final List<desktop_entry.Icon> icons, {final String? theme}) {
    assert(icons.isNotEmpty, 'icons must be provided');
    List<desktop_entry.Icon> bestIcons = icons;

    /*
    Often selects SVG icons that don't render correctly or even not at all
    TODO: Check if SVGs can be test rendered and removed if they throw an error
    if (theme != null) {
      final themeIcons = bestIcons.where((final icon) => icon.theme == theme).toList();
      if (themeIcons.isNotEmpty) {
        bestIcons = themeIcons;
      } else {
    */
    final themeIcons = bestIcons.where((final icon) => icon.theme == 'hicolor').toList();
    if (themeIcons.isNotEmpty) {
      bestIcons = themeIcons;
    }
    /*
      }
    }
    */

    final nonSvgIcons = bestIcons.where((final icon) => !icon.path.endsWith('.svg')).toList();
    if (nonSvgIcons.isNotEmpty) {
      bestIcons = nonSvgIcons;
    }

    final nonScalableIcons = bestIcons.where((final icon) => icon.size != 'scalable').toList();
    if (nonScalableIcons.isNotEmpty) {
      bestIcons = nonScalableIcons;
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
