import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home.dart';

class ThemeSection extends StatefulWidget {
  const ThemeSection({
    super.key,
    required this.handleBrightnessChange,
    required this.handleColorSelect,
  });

  final void Function(bool useLightMode) handleBrightnessChange;
  final void Function(int value) handleColorSelect;
  @override
  State<ThemeSection> createState() => _ThemeSectionState();
}

class _ThemeSectionState extends State<ThemeSection> {
  bool isNonModalBottomSheetOpen = false;

  var themeData = ThemeData();

  int saveThemeBrightness = 2;
  int bsThemeBrightness = 2;
  int saveAccentColor = 1;
  int bsAccentColor = 1;

  Future<void> saveConfigs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('themeBrightness', saveThemeBrightness);
    prefs.setInt('accentColor', saveAccentColor);
    setState(() {
      bsThemeBrightness = saveThemeBrightness;
      bsAccentColor = saveAccentColor;
    });
  }

  @override
  Widget build(BuildContext context) {
    //final isBright = Theme.of(context).brightness == Brightness.light;
    List<Widget> themeButtonList = <Widget>[
      IconButton(
          icon: const Icon(Icons.light_mode_outlined),
          onPressed: () {
            widget.handleBrightnessChange(true);
            saveThemeBrightness = 1;
            saveConfigs();
          }),
      IconButton(
        icon: const Icon(Icons.dark_mode),
        onPressed: () {
          widget.handleBrightnessChange(false);
          saveThemeBrightness = 0;
          saveConfigs();
        },
      ),
      IconButton(
          onPressed: () {
            widget.handleBrightnessChange(SchedulerBinding
                    .instance.platformDispatcher.platformBrightness ==
                Brightness.light);
            saveThemeBrightness = 2;
            saveConfigs();
          },
          icon: const Icon(Icons.brightness_4_outlined)),
    ];
    List<Widget> accentButtonList = <Widget>[
      IconButton(
          onPressed: () {
            widget.handleColorSelect(0);
            saveAccentColor = 0;
            saveConfigs();
          },
          icon: const Icon(
            Icons.circle,
            color: Color(0xff6750a4),
          )),
      IconButton(
          onPressed: () {
            widget.handleColorSelect(1);
            saveAccentColor = 1;
            saveConfigs();
          },
          icon: const Icon(Icons.circle, color: Colors.indigo)),
      IconButton(
          onPressed: () {
            widget.handleColorSelect(2);
            saveAccentColor = 2;
            saveConfigs();
          },
          icon: const Icon(Icons.circle, color: Colors.blue)),
      IconButton(
          onPressed: () {
            widget.handleColorSelect(3);
            saveAccentColor = 3;
            saveConfigs();
          },
          icon: const Icon(Icons.circle, color: Colors.teal)),
      IconButton(
          onPressed: () {
            widget.handleColorSelect(4);
            saveAccentColor = 4;
            saveConfigs();
          },
          icon: const Icon(Icons.circle, color: Colors.green)),
      IconButton(
          onPressed: () {
            widget.handleColorSelect(5);
            saveAccentColor = 5;
            saveConfigs();
          },
          icon: const Icon(Icons.circle, color: Colors.yellow)),
      IconButton(
          onPressed: () {
            widget.handleColorSelect(6);
            saveAccentColor = 6;
            saveConfigs();
          },
          icon: const Icon(Icons.circle, color: Colors.orange)),
      IconButton(
          onPressed: () {
            widget.handleColorSelect(7);
            saveAccentColor = 7;
            saveConfigs();
          },
          icon: const Icon(Icons.circle, color: Colors.deepOrange)),
      IconButton(
          onPressed: () {
            widget.handleColorSelect(8);
            saveAccentColor = 8;
            saveConfigs();
          },
          icon: const Icon(Icons.circle, color: Colors.pink)),
    ];
    List<Text> themeLabelList = const <Text>[
      Text('Light'),
      Text('Dark'),
      Text('System'),
    ];
    List<Text> accentLabelList = const <Text>[
      Text('Material'),
      Text('Indigo'),
      Text('Blue'),
      Text('Teal'),
      Text('Green'),
      Text('Yellow'),
      Text('Orange'),
      Text('Deep \nOrange', textAlign: TextAlign.center),
      Text('Pink'),
    ];

    themeButtonList = List.generate(
        themeButtonList.length,
        (index) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                themeButtonList[index],
                themeLabelList[index],
              ],
            ));

    accentButtonList = List.generate(
        accentButtonList.length,
        (index) => Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                accentButtonList[index],
                accentLabelList[index],
              ],
            ));
    return CardCreator(
      title: 'Appearence',
      child: Wrap(
        alignment: WrapAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, top: 8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    SizedBox(
                      width: 140,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'App theme',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            constraints: const BoxConstraints(
                              maxWidth: 640,
                              minWidth: 300,
                              maxHeight: 200,
                            ),
                            builder: (context) {
                              return FractionallySizedBox(
                                widthFactor: 0.7,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Row(
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(30, 10, 0, 0),
                                          child: Text(
                                            'Pick a theme:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    GridView.count(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 0),
                                      shrinkWrap: true,
                                      crossAxisCount: 3,
                                      children: themeButtonList,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    SizedBox(
                      width: 140,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Accent color',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          showModalBottomSheet<void>(
                            context: context,
                            constraints: const BoxConstraints(
                              maxWidth: 640,
                              minWidth: 300,
                              maxHeight: 500,
                            ),
                            builder: (context) {
                              return FractionallySizedBox(
                                widthFactor: 0.7,
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    const Row(
                                      children: [
                                        Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(30, 10, 0, 0),
                                          child: Text(
                                            'Pick an accent color:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 16),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 0),
                                      child: FilledButton(
                                        onPressed: () {
                                          widget.handleColorSelect(10);
                                          saveAccentColor = 10;
                                          saveConfigs();
                                        },
                                        child: const Text('System Color'),
                                      ),
                                    ),
                                    GridView.count(
                                      padding: const EdgeInsets.fromLTRB(
                                          10, 0, 10, 0),
                                      shrinkWrap: true,
                                      crossAxisCount: 3,
                                      children: accentButtonList,
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
