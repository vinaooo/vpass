// ignore_for_file: avoid_print

import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:crypto/crypto.dart';
import 'package:convert/convert.dart';
import 'dart:convert';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

import 'ad_helper.dart';
import 'clipboard.dart';
import 'globals.dart';

class PasswordGenerator extends StatefulWidget {
  const PasswordGenerator({super.key});

  @override
  State<PasswordGenerator> createState() => _PasswordGeneratorState();
}

class _PasswordGeneratorState extends State<PasswordGenerator> {
  @override
  Widget build(BuildContext context) {
    Color selectedColor = Theme.of(context).primaryColor;
    ThemeData lightTheme = ThemeData(
      colorSchemeSeed: selectedColor,
      brightness: Brightness.light,
    );

    Widget schemeView(ThemeData theme) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: PasswordGeneratorPage(),
      );
    }

    return Expanded(
      child: Row(
        children: [
          Expanded(
            child: schemeView(lightTheme),
          ),
        ],
      ),
    );
  }
}

class PasswordGeneratorPage extends StatefulWidget {
  const PasswordGeneratorPage({super.key});

  @override
  State<PasswordGeneratorPage> createState() => _PasswordGeneratorPageState();
}

class _PasswordGeneratorPageState extends State<PasswordGeneratorPage> {
  final TextEditingController aliasController = TextEditingController();
  final TextEditingController secretController = TextEditingController();

  String aliasText = "";
  String secretText = "";

  bool internDebug = false; //put true for debug messages in console
  bool speCharSwitch = true;

  bool numberSwitch = true;
  bool lettersSwitch = true;
  bool capLettersSwitch = true;

  bool aliasValidator = false;
  bool secretValidator = false;

  int currentSliderValue = 32;

  String pwValue(String aliasStr, String secretStr) {
    String password = "";

    String vsha512(String entrada) {
      var bytes = utf8.encode(entrada);
      var digest = sha512.convert(bytes);
      var hexString = hex.encode(digest.bytes);
      String bigHexString =
          hexString.toString() + hexString.toString().split('').reversed.join();
      bigHexString = bigHexString.split('').join() + bigHexString;
      bigHexString = bigHexString.split('').join() + bigHexString;
      bigHexString = bigHexString.split('').join() + bigHexString;
      bigHexString = bigHexString.split('').join() + bigHexString;
      return bigHexString;
    }

    String encodeHash(String hash) {
      var bytes = hex.decode(hash);
      var allowedChars = '''
ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyzz0123456789!@#\$%^&*()_+-=[]{};''';
      var encodedChars = bytes
          .map((byte) => allowedChars.codeUnitAt(byte % allowedChars.length));
      return String.fromCharCodes(encodedChars);
    }

    String removeDuplicateChars(String str) {
      StringBuffer sb = StringBuffer();
      for (int i = 0; i < str.length; i++) {
        if (i == 0 || str[i] != str[i - 1]) {
          sb.write(str[i]);
        }
      }
      return sb.toString();
    }

    StringBuffer sb = StringBuffer();

    var hash = vsha512('!$aliasText@$secretText#');
    var encodedHash = encodeHash(hash);

    var reversedHash = encodedHash.split('').reversed.join();

    int minLength = encodedHash.length < reversedHash.length
        ? encodedHash.length
        : reversedHash.length;
    for (int i = 0; i < minLength; i++) {
      sb.write(encodedHash[i]);
      sb.write(reversedHash[i]);
    }

    if (encodedHash.length > minLength) {
      sb.write(encodedHash.substring(minLength));
    } else if (reversedHash.length > minLength) {
      sb.write(reversedHash.substring(minLength));
    }

    password = removeDuplicateChars(sb.toString());

    String removeNumbers(String str) {
      return str.replaceAll(RegExp(r'[0-9]'), '');
    }

    String removeLetter(String str) {
      return str.replaceAll(RegExp(r'[a-zA-Z]'), '');
    }

    String removeSpecChar(String str) {
      return str.replaceAll(RegExp(r'[!@#\$%^&*()_+\-=\[\]{};]'), '');
    }

    if (lettersSwitch == false) password = removeLetter(password);
    if (numberSwitch == false) password = removeNumbers(password);
    if (speCharSwitch == false) password = removeSpecChar(password);
    if (capLettersSwitch == false) password = password.toLowerCase();

    //print(password.substring(0, currentSliderValue));

    return password.substring(
        0, currentSliderValue); //mensagem do sem senha, ou sei la
  }

  int securityLevel(int secPwValue) {
    int internSecurityLevel = 0;

    if (speCharSwitch == true) {
      internSecurityLevel = internSecurityLevel + 1;
    }
    if (numberSwitch == true) {
      internSecurityLevel = internSecurityLevel + 1;
    }
    if (lettersSwitch == true) {
      internSecurityLevel = internSecurityLevel + 1;
    }
    if (capLettersSwitch == true) {
      internSecurityLevel = internSecurityLevel + 1;
    }
    if (secPwValue > 10) {
      internSecurityLevel = internSecurityLevel + 1;
    }
    if (secPwValue > 16) {
      internSecurityLevel = internSecurityLevel + 1;
    }
    if (secPwValue > 32) {
      internSecurityLevel = internSecurityLevel + 1;
    }
    if (secPwValue > 64) {
      internSecurityLevel = internSecurityLevel + 1;
    }
    if (secPwValue > 100) {
      internSecurityLevel = internSecurityLevel + 1;
    }

    return internSecurityLevel;
  }

  String textNoPass() {
    if (aliasText != "" || secretText != "") {
      return pwValue(aliasText, secretText);
    }
    return " Please type Alias or Secret!\n";
  }

  int securityNoPass() {
    if (aliasText != "" || secretText != "") {
      return securityLevel(pwValue(aliasText, secretText).toString().length);
    } else {
      return 0;
    }
  }

  double newTextSize(var value) {
    double textDynamicSize = 0;
    if (aliasValidator == false && secretValidator == false) {
      return 19;
    }

    if (value == null) {
      return 50;
    }
    if (value.toString().length > 120) {
      textDynamicSize = 16;
    }

    if (value.toString().length > 100 && value.toString().length <= 120) {
      textDynamicSize = 18;
    }
    if (value.toString().length > 66 && value.toString().length <= 100) {
      textDynamicSize = 20;
    }
    if (value.toString().length > 58 && value.toString().length <= 66) {
      textDynamicSize = 25;
    }
    if (value.toString().length > 52 && value.toString().length <= 58) {
      textDynamicSize = 28;
    }
    if (value.toString().length > 29 && value.toString().length <= 52) {
      textDynamicSize = 32;
    }
    if (value.toString().length > 26 && value.toString().length <= 29) {
      textDynamicSize = 36;
    }
    if (value.toString().length > 20 && value.toString().length <= 26) {
      textDynamicSize = 43;
    }
    if (value.toString().length > 9 && value.toString().length <= 20) {
      textDynamicSize = 50;
    }
    if (value.toString().length == 8 || value.toString().length == 9) {
      textDynamicSize = 68;
    }
    if (value.toString().length < 8) {
      textDynamicSize = 70;
    }

    return textDynamicSize;
  }

  //bool _loading = false;
void temporaryFunction() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text("Temporary Function"),
      content: Text("This is a temporary function. The copyToClipboard function should be called here instead."),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("OK"),
        ),
      ],
    ),
  );
}
  Future<void> copyToClipboard() async {
    print('aqui');
    //FocusManager.instance.primaryFocus?.unfocus();

    //setState(() => _loading = true);

    bool dataWasHiddenForAndroidAPI33;
    String text;
    String copyString = " ";

    copyString = textNoPass();

    try {
      dataWasHiddenForAndroidAPI33 = await SensitiveClipboard.copy(
        copyString,
        hideContent: true,
      );
      text = 'Successfully copied to Clipboard!';
    } on PlatformException {
      text = 'Ops! Something went wrong.';
      dataWasHiddenForAndroidAPI33 = false;
    }

    if (!mounted) return;

    if (!dataWasHiddenForAndroidAPI33) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(text),
        ),
      );
    }

    //setState(() => _loading = false);
  }

  BannerAd? bannerAd;
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid == true) {
      BannerAd(
        adUnitId: AdHelper.bannerAdUnitId,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            setState(() {
              bannerAd = ad as BannerAd;
            });
          },
          onAdFailedToLoad: (ad, error) {
            // Releases an ad resource when it fails to load
            ad.dispose();
            print(
                'Ad load failed (code=${error.code} message=${error.message})');
          },
        ),
      ).load();
    }
    aliasObscure = false;
  }

  bool aliasObscure = false;
  bool secretObscure = false;

  @override
  Widget build(BuildContext context) {
    final focusNode = FocusNode();

    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            // padding: const EdgeInsets.symmetric(vertical: smallSpacing),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints:
                      const BoxConstraints.tightFor(width: widthConstraint),
                  // Tapping within the a component card should request focus
                  // for that component's children.
                  child: Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 5, 0, 0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('Type user, services or whatever other word',
                                  style:
                                      Theme.of(context).textTheme.titleSmall),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5.0, vertical: 0.0),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(smallSpacing),
                                  child: TextField(
                                    obscureText: aliasObscure,
                                    style: const TextStyle(
                                      fontFamily: 'Ubuntu',
                                      decorationThickness: 0,
                                    ),
                                    onChanged: (String value) {
                                      if (value.isEmpty || value == "") {
                                        aliasValidator = false;
                                        setState(() => aliasText = value);
                                      } else {
                                        aliasValidator = true;
                                        setState(() => aliasText = value);
                                      }
                                    },
                                    enabled: speCharSwitch == false &&
                                            numberSwitch == false &&
                                            lettersSwitch == false
                                        ? false
                                        : true,
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          aliasObscure == true
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            aliasObscure = !aliasObscure;
                                          });
                                        },
                                      ),
                                      labelText: 'Alias *',
                                      hintText: "Enter an alias",
                                      filled: true,
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(12)),
                                          borderSide:
                                              BorderSide(color: Colors.red)),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 12),
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(smallSpacing),
                                  child: TextField(
                                    obscureText: true,
                                    style: const TextStyle(
                                      fontFamily: 'Ubuntu',
                                      decorationThickness: 0,
                                    ),
                                    onChanged: (String value) {
                                      if (value.isEmpty || value == "") {
                                        secretValidator = false;
                                        setState(() => secretText = value);
                                      } else {
                                        secretValidator = true;
                                        setState(() => secretText = value);
                                      }
                                    },
                                    enabled: speCharSwitch == false &&
                                            numberSwitch == false &&
                                            lettersSwitch == false
                                        ? false
                                        : true,
                                    decoration: InputDecoration(
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          secretObscure == true
                                              ? Icons.visibility
                                              : Icons.visibility_off,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            secretObscure = !secretObscure;
                                          });
                                        },
                                      ),
                                      labelText: 'Secret *',
                                      hintText: "Enter a secret",
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 12),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            // padding: const EdgeInsets.symmetric(vertical: smallSpacing),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Column(
              children: [
                ConstrainedBox(
                  constraints:
                      const BoxConstraints.tightFor(width: widthConstraint),
                  // Tapping within the a component card should request focus
                  // for that component's children.
                  child: Focus(
                    focusNode: focusNode,
                    canRequestFocus: true,
                    child: GestureDetector(
                      onTapDown: (_) {
                        focusNode.requestFocus();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            color: Theme.of(context).colorScheme.outlineVariant,
                          ),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 5, 0, 0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Text(
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleSmall,
                                      aliasValidator == false &&
                                              secretValidator == false
                                          ? "Password length: 0 characters"
                                          : "Password length: ${currentSliderValue.round().toString()} characters")
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0, vertical: 0.0),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Padding(
                                      padding:
                                          const EdgeInsets.fromLTRB(0, 0, 0, 6),
                                      child: Card(
                                        color: securityNoPass() == 0
                                            ? const Color(0xffBF2600)
                                            : securityNoPass() == 1
                                                ? Colors.red
                                                : securityNoPass() == 2
                                                    ? Colors
                                                        .deepOrangeAccent[400]
                                                    : securityNoPass() == 3
                                                        ? Colors
                                                            .orangeAccent[400]
                                                        : securityNoPass() == 4
                                                            ? Colors.amber[400]
                                                            : securityNoPass() ==
                                                                    5
                                                                ? const Color
                                                                        .fromARGB(
                                                                    255,
                                                                    255,
                                                                    222,
                                                                    3)
                                                                : securityNoPass() ==
                                                                        6
                                                                    ? Colors
                                                                        .yellow
                                                                    : securityNoPass() ==
                                                                            7
                                                                        ? const Color(
                                                                            0xffd0df00)
                                                                        : securityNoPass() ==
                                                                                8
                                                                            ? const Color.fromARGB(
                                                                                255,
                                                                                54,
                                                                                179,
                                                                                126)
                                                                            : securityNoPass() == 9
                                                                                ? const Color.fromARGB(255, 0, 102, 68)
                                                                                : null,
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: <Widget>[
                                            Container(
                                              width: Platform.isAndroid
                                                  ? bannerAd?.size.width
                                                      .toDouble()
                                                  : 200,
                                              height: 72.0,
                                              alignment: Alignment.center,
                                              child: bannerAd != null
                                                  ? AdWidget(ad: bannerAd!)
                                                  : Center(
                                                      child: Platform.isAndroid
                                                          ? LoadingAnimationWidget
                                                              .waveDots(
                                                              color:
                                                                  Colors.yellow,
                                                              size: 50,
                                                            )
                                                          : null,
                                                    ),
                                            ),
                                            SizedBox(
                                              height: 150,
                                              child: ListTile(
                                                title: const Text(
                                                  '',
                                                  style: TextStyle(
                                                    fontSize: 0,
                                                  ),
                                                ),
                                                subtitle: Text(textNoPass(),
                                                    textAlign:
                                                        aliasText == "" &&
                                                                secretText == ""
                                                            ? TextAlign.center
                                                            : TextAlign.justify,
                                                    softWrap: true,
                                                    style: TextStyle(
                                                      color: aliasText == "" &&
                                                              secretText == ""
                                                          ? Colors.yellow
                                                          : Colors.white,
                                                      fontSize: newTextSize(
                                                          pwValue(aliasText,
                                                              secretText)),
                                                      fontFamily:
                                                          'ShareTechMono',
                                                    )),
                                              ),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Align(
                                                alignment:
                                                    Alignment.bottomRight,
                                                heightFactor: 0,
                                                child: FloatingActionButton
                                                    .extended(
                                                  onPressed: (){ 
                                                    //copyToClipboard();
                                                    temporaryFunction();},
                                                  label: const Text('Cofgdfspy'),
                                                  icon: const Icon(
                                                    Icons.copy,
                                                  ),
                                                ),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            // padding: const EdgeInsets.symmetric(vertical: smallSpacing),
            padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
            child: Flex(
              direction: Axis.horizontal,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      ConstrainedBox(
                        constraints: const BoxConstraints.tightFor(
                            width: widthConstraint),
                        // Tapping within the a component card should request focus
                        // for that component's children.
                        child: Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                              color:
                                  Theme.of(context).colorScheme.outlineVariant,
                            ),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(12)),
                          ),
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 5, 0, 0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text('Password characters:',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                  vertical: 0.0,
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: <Widget>[
                                          Row(children: <Widget>[
                                            Expanded(
                                                flex: 2,
                                                child: Slider(
                                                    value: currentSliderValue
                                                        .round()
                                                        .toDouble(),
                                                    min: 6,
                                                    max: 128,
                                                    onChanged: speCharSwitch ==
                                                                false &&
                                                            numberSwitch ==
                                                                false &&
                                                            lettersSwitch ==
                                                                false
                                                        ? null
                                                        : aliasValidator ==
                                                                    false &&
                                                                secretValidator ==
                                                                    false
                                                            ? null
                                                            : (double value) =>
                                                                {
                                                                  setState(() =>
                                                                      currentSliderValue =
                                                                          value
                                                                              .toInt())
                                                                }))
                                          ]),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: SwitchListTile(
                                                  secondary: const Icon(
                                                    Icons.attach_money_outlined,
                                                    size: 35,
                                                  ),
                                                  title: const Text(
                                                    'Special Characters',
                                                  ),
                                                  subtitle: Text(
                                                      "$aliasValidator @#% characters into your password $secretValidator",
                                                      style: const TextStyle(
                                                          fontSize: 12)),
                                                  value: speCharSwitch,
                                                  onChanged:
                                                      aliasValidator == false &&
                                                              secretValidator ==
                                                                  false
                                                          ? null
                                                          : (bool value) {
                                                              setState(() {
                                                                speCharSwitch =
                                                                    value;
                                                              });
                                                            },
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: SwitchListTile(
                                                  secondary: const Icon(
                                                    Icons.onetwothree_outlined,
                                                    size: 35,
                                                  ),
                                                  title: const Text(
                                                    'Numbers',
                                                  ),
                                                  subtitle: const Text(
                                                      "Numbers into your password",
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                  value: numberSwitch,
                                                  onChanged:
                                                      aliasValidator == false &&
                                                              secretValidator ==
                                                                  false
                                                          ? null
                                                          : (bool value) {
                                                              setState(() {
                                                                numberSwitch =
                                                                    value;
                                                              });
                                                            },
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                flex: 2,
                                                child: SwitchListTile(
                                                  secondary: const Icon(
                                                    Icons.abc_outlined,
                                                    size: 35,
                                                  ),
                                                  title: const Text(
                                                    'Letters',
                                                  ),
                                                  subtitle: const Text(
                                                      "Letters into your password",
                                                      style: TextStyle(
                                                          fontSize: 12)),
                                                  value: lettersSwitch,
                                                  onChanged:
                                                      aliasValidator == false &&
                                                              secretValidator ==
                                                                  false
                                                          ? null
                                                          : (bool value) {
                                                              setState(() {
                                                                lettersSwitch =
                                                                    value;
                                                                capLettersSwitch =
                                                                    false;
                                                              });
                                                            },
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            children: <Widget>[
                                              Expanded(
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20, 0, 0, 0),
                                                  child: SwitchListTile(
                                                      secondary: const Icon(
                                                        Icons
                                                            .format_size_outlined,
                                                        size: 35,
                                                      ),
                                                      title: const Text(
                                                        'Capital letters',
                                                      ),
                                                      subtitle: const Text(
                                                          "Some capital letters into your password",
                                                          style: TextStyle(
                                                              fontSize: 12)),
                                                      value: capLettersSwitch,
                                                      onChanged: aliasValidator ==
                                                                  false &&
                                                              secretValidator ==
                                                                  false
                                                          ? null
                                                          : lettersSwitch ==
                                                                  false
                                                              ? null
                                                              : (bool value) {
                                                                  setState(() {
                                                                    capLettersSwitch =
                                                                        value;
                                                                  });
                                                                }),
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // ignore: todo
    // TODO: Dispose a BannerAd object
    bannerAd?.dispose();

    super.dispose();
  }
}
