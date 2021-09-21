import 'dart:io';

import 'package:desktop_entry/desktop_entry.dart' as desktop_entry;
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) => MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: GoogleFonts.robotoTextTheme(
            Theme.of(context).textTheme,
          ),
        ),
        home: HomePage(),
      );
}

class HomePage extends StatefulWidget {
  const HomePage({
    final Key? key,
  }) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<desktop_entry.DesktopEntry> entries;
  late Map<String, List<desktop_entry.Icon>> icons = {};

  desktop_entry.Icon findBestIcon(final List<desktop_entry.Icon> icons, {final String? theme}) {
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

  @override
  void initState() {
    super.initState();
    entries = desktop_entry.listEntries().where((final entry) => !entry.noDisplay() && !entry.hidden()).toList();
    final _icons = desktop_entry.getIcons();
    for (final icon in _icons) {
      if (icons[icon.name] == null) {
        icons[icon.name] = [];
      }
      icons[icon.name]!.add(icon);
    }
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Flutter mobile UI'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Wrap(
              children: entries
                  .map<Widget>(
                    (final entry) => Container(
                      padding: const EdgeInsets.all(10),
                      child: SizedBox(
                        height: 66,
                        width: 100,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 50,
                              width: 50,
                              child: Builder(
                                builder: (final context) {
                                  if (entry.icon() != null && icons[entry.icon()] != null) {
                                    final icon = findBestIcon(icons[entry.icon()]!, theme: 'breeze');
                                    if (icon.path.endsWith('.svg')) {
                                      return SvgPicture.file(File(icon.path));
                                    }
                                    return Image.file(File(icon.path));
                                  }
                                  return Container();
                                },
                              ),
                            ),
                            Text(
                              entry.name(),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
      );
}
