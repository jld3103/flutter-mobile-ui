import 'package:flutter/material.dart';
import 'package:flutter_mobile_ui/src/app_launcher_source/linux.dart';
import 'package:flutter_mobile_ui/src/app_launcher_source/repository.dart';
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
        home: const HomePage(),
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
  final List<Application> applications = [];

  @override
  void initState() {
    super.initState();
    final List<AppLauncherSourceRepository> sources = [
      LinuxAppLauncherSource(),
    ];
    WidgetsBinding.instance!.addPostFrameCallback((final _) {
      setState(() {
        for (final source in sources) {
          applications.addAll(source.getCachedApplications());
        }
        applications.sort((final a, final b) => a.name.compareTo(b.name));
      });
    });
  }

  @override
  Widget build(final BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Flutter mobile UI'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Wrap(
              children: applications
                  .map<Widget>(
                    (final application) => Container(
                      margin: const EdgeInsets.all(5),
                      child: InkWell(
                        onTap: application.launch,
                        child: Container(
                          padding: const EdgeInsets.all(5),
                          child: Container(
                            constraints: const BoxConstraints(
                              minHeight: 66,
                              minWidth: 100,
                              maxWidth: 100,
                            ),
                            child: Column(
                              children: [
                                SizedBox(
                                  height: 50,
                                  width: 50,
                                  child: FutureBuilder<Widget>(
                                    future: application.getIcon(),
                                    builder: (final context, final snapshot) {
                                      if (snapshot.hasError) {
                                        return const Icon(Icons.error);
                                      }
                                      if (snapshot.hasData) {
                                        return snapshot.data ?? Container();
                                      }
                                      return const CircularProgressIndicator();
                                    },
                                  ),
                                ),
                                Text(
                                  application.name,
                                  overflow: TextOverflow.clip,
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
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
