// ignore_for_file: prefer_const_constructors, sized_box_for_whitespace, prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart' as srr;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'dart:math';

import 'dart:io' show Platform;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<String> prevText = [];
  String otext = "";
  String ctext = "Tap to speak";
  bool micState = false;
  bool speechInit = false;
  final ScrollController _controller = ScrollController();
  final ScrollController _scrollController = ScrollController();
  late FlutterTts flutterTts;
  String _textToSay = "";
  bool _keyboardUp = false;
  List<stt.LocaleName> _locales = [];
  // ignore: non_constant_identifier_names
  List<dynamic> _TTSlanguages = [];
  // ignore: non_constant_identifier_names
  List<String> _TTSGood = [];

  final stt.SpeechToText _speechToText = stt.SpeechToText();

  late StreamSubscription<bool> keyboardSubscription;

  String _setTTSlocale = "";
  String _selectedLocale = "";

  void _initSpeech() async {
    speechInit = await _speechToText.initialize(
      onStatus: (val) => {
        if (val == "notListening")
          {
            setState(() {
              micState = false;
              otext = otext + ctext;
              ctext = "";
            })
          }
        else if (val == "done")
          {
            setState(() {
              otext = otext + ctext;
              prevText.add(otext);
              otext = "";
              ctext = "";
            })
          },
      },
    );
    _locales = await _speechToText.locales();
    var sysLocale = await _speechToText.systemLocale();
    _selectedLocale = sysLocale!.localeId;
    setState(() {});
  }

  final FocusNode _focus = FocusNode();

  // ignore: non_constant_identifier_names
  late List<dynamic> _TTSVoices;
  // ignore: non_constant_identifier_names
  late List<Map<String, String>> _TTSVoicesGood;
  // ignore: non_constant_identifier_names
  late List<Map<String, String>> _TTSVoicesGoodGood = [];

  double _speechRate = 0.5;

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();

    var keyboardVisibilityController = KeyboardVisibilityController();

    keyboardSubscription =
        keyboardVisibilityController.onChange.listen((bool visible) {
      // I WANT TO KNOW IF KEYBOARD WAS DISMISSED BRUH
      // FocusScope.of(context).unfocus();
    });
  }

  _initTts() {
    flutterTts = FlutterTts();
    _setAwaitOptions();
    _focus.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    if (_focus.hasFocus) {
      if (!_keyboardUp) {
        setState(() {
          _keyboardUp = true;
        });
      }
    } else {
      if (_keyboardUp) {
        setState(() {
          _keyboardUp = false;
        });
      }
    }
  }

  Future _setAwaitOptions() async {
    // await flutterTts.setIosAudioCategory(
    //   IosTextToSpeechAudioCategory.playback,
    //   [
    //     IosTextToSpeechAudioCategoryOptions.allowBluetooth,
    //     IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
    //     IosTextToSpeechAudioCategoryOptions.allowAirPlay,
    //     IosTextToSpeechAudioCategoryOptions.duckOthers
    //   ],
    //   IosTextToSpeechAudioMode.voicePrompt,
    // );
    _TTSVoices = await flutterTts.getVoices;
    // convert _TTSVoices to String String map
    _TTSVoicesGood = _TTSVoices.map(
      (e) => {
        "name": e["name"].toString(),
        "locale": e["locale"].toString(),
      },
    ).toList();

    // populate TTSVOICEGOODGOOD with only the names which are current locale...

    _TTSlanguages = await flutterTts.getLanguages;
    // convert _TTSlanguages to a list of strings

    _TTSGood = _TTSlanguages.map((e) => e.toString()).toList();

    if (Platform.isAndroid) {
      var map = await flutterTts.areLanguagesInstalled(_TTSGood);

      // edit TTS Languages to remove unsupported languages
      _TTSGood.removeWhere((element) => !map[element]!);
    }

    // _lang = await flutterTts.getDefaultVoice;
    var map = {};
    if (Platform.isAndroid) {
      map = await flutterTts.getDefaultVoice;
    } else {
      map = {"locale": "en-US"};
    }
    _setTTSlocale = map["locale"];
    _oopaoopa();
    await flutterTts.awaitSpeakCompletion(true);
  }

  void _oopaoopa() {
    _TTSVoicesGoodGood = [];
    for (Map<String, String> val in _TTSVoicesGood) {
      if (val["locale"] == _setTTSlocale) {
        _TTSVoicesGoodGood.add(val);
      }
    }
  }

  Future _speak(say) async {
    await flutterTts.setVolume(1.5);
    await flutterTts.setSpeechRate(_speechRate);
    await flutterTts.speak(say);
  }

  @override
  void dispose() {
    super.dispose();
    flutterTts.stop();
  }

  void _startListening() async {
    await _speechToText.listen(
        onResult: _onSpeechResult, localeId: _selectedLocale);
    setState(() {
      ctext = "";
      otext = "";
    });
  }

  void _onSpeechResult(srr.SpeechRecognitionResult result) {
    setState(() {
      String itext = result.recognizedWords;
      if (itext.split(" ").length > 4) {
        List<String> words = itext.split(" ");
        otext = words.sublist(0, words.length - 4).join(" ");
        ctext = " ${words.sublist(words.length - 4).join(" ")}";
      } else {
        ctext = itext;
      }
      _scrollDown();
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _scrollDown() {
    _controller.jumpTo(_controller.position.maxScrollExtent);
  }

  final TextEditingController _textController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  bool _transform = false;

  void _showDialog(Widget child) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 216,
        padding: const EdgeInsets.only(top: 6.0),
        // The Bottom margin is provided to align the popup above the system navigation bar.
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        // Provide a background color for the popup.
        color: CupertinoColors.systemBackground.resolveFrom(context),
        // Use a SafeArea widget to avoid system overlaps.
        child: SafeArea(
          top: false,
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        if (_keyboardUp == true)
          {
            FocusScope.of(context).unfocus(),
          }
      },
      child: CupertinoPageScaffold(
        // endDrawer: Drawer(
        //   child: ListView(
        //     physics: const NeverScrollableScrollPhysics(),
        //     children: <Widget>[
        //       DrawerHeader(
        //         decoration: BoxDecoration(
        //           color: Theme.of(context).colorScheme.secondary,
        //         ),
        //         child: const SizedBox(
        //           width: double.infinity,
        //           height: 40.0,
        //           child: Align(
        //             alignment: Alignment.centerLeft,
        //             child: Text(
        //               "Settings",
        //               style: TextStyle(
        //                 color: Colors.white,
        //                 fontSize: 48,
        //               ),
        //             ),
        //           ),
        //         ),
        //       ),
        // ListTile(
        //   leading: const Icon(Icons.translate),
        //   title: const Text('Change STT Language'),
        //   onTap: () {

        //     );
        //   },
        // ),
        //       ListTile(
        //         leading: const Icon(Icons.language),
        //         title: const Text('Change TTS Language'),
        //         onTap: () {
        //           showDialog(
        //             context: context,
        //             builder: (context) {
        //               return AlertDialog(
        //                 content: Column(
        //                   mainAxisSize: MainAxisSize.min,
        //                   children: [
        //                     Container(
        //                       padding: const EdgeInsets.all(10),
        //                       height: 300,
        //                       width: 200,
        //                       child: ListView.builder(
        //                         shrinkWrap: true,
        //                         itemCount: _TTSGood.length,
        //                         itemBuilder: (context, index) {
        //                           return ListTile(
        //                             title: Text(_TTSGood[index]),
        //                             onTap: () {
        //                               setState(
        //                                 () {
        //                                   flutterTts.setLanguage(
        //                                     _TTSGood[index],
        //                                   );
        //                                   _setTTSlocale = _TTSGood[index];
        //                                   _oopaoopa();
        //                                 },
        //                               );
        //                               Navigator.pop(context);
        //                             },
        //                           );
        //                         },
        //                       ),
        //                     )
        //                   ],
        //                 ),
        //               );
        //             },
        //           );
        //         },
        //       ),
        //       ListTile(
        //         leading: const Icon(Icons.mic_none_outlined),
        //         title: const Text('Change Voice'),
        //         onTap: () {
        //           showDialog(
        //             context: context,
        //             builder: (context) {
        //               return AlertDialog(
        //                 content: Column(
        //                   mainAxisSize: MainAxisSize.min,
        //                   children: [
        //                     Container(
        //                       padding: const EdgeInsets.all(10),
        //                       height: 300,
        //                       width: 200,
        //                       child: ListView.builder(
        //                         shrinkWrap: true,
        //                         itemCount: _TTSVoicesGoodGood.length,
        //                         itemBuilder: (context, index) {
        //                           return ListTile(
        //                             title: Text("${_TTSVoicesGoodGood[index]}"),
        //                             onTap: () {
        //                               setState(
        //                                 () {
        //                                   flutterTts.setVoice(
        //                                     _TTSVoicesGoodGood[index],
        //                                   );
        //                                 },
        //                               );
        //                               Navigator.pop(context);
        //                             },
        //                           );
        //                         },
        //                       ),
        //                     )
        //                   ],
        //                 ),
        //               );
        //             },
        //           );
        //         },
        //       ),
        //       ListTile(
        //         leading: const Icon(Icons.speed_outlined),
        //         title: const Text('Change Speed'),
        //         onTap: () {
        //           showDialog(
        //             context: context,
        //             builder: (context) {
        //               return AlertDialog(
        //                 content: Column(
        //                   mainAxisSize: MainAxisSize.min,
        //                   children: [
        //                     Container(
        //                       padding: const EdgeInsets.all(10),
        //                       height: 300,
        //                       width: 200,
        //                       child: Slider(
        //                         value: _speechRate,
        //                         min: 0.0,
        //                         max: 1.0,
        //                         divisions: 10,
        //                         label: _speechRate.toString(),
        //                         onChanged: (value) {
        //                           setState(
        //                             () {
        //                               _speechRate = value;
        //                             },
        //                           );
        //                         },
        //                         onChangeEnd: (val) {
        //                           Navigator.pop(context);
        //                         },
        //                       ),
        //                     )
        //                   ],
        //                 ),
        //               );
        //             },
        //           );
        //         },
        //       )
        //     ],
        //   ),
        // ),
        // key: _scaffoldKey,
        backgroundColor: const CupertinoDynamicColor.withBrightness(
          color: Color.fromARGB(255, 229, 229, 234),
          darkColor: Colors.black54,
        ),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: _controller,
          slivers: [
            const CupertinoSliverNavigationBar(
              backgroundColor: CupertinoDynamicColor.withBrightness(
                color: Color.fromARGB(255, 229, 229, 234),
                darkColor: Colors.black54,
              ),
              largeTitle: Text(
                'Indri.Yeah',
                style: TextStyle(
                  color: CupertinoDynamicColor.withBrightness(
                      color: Color.fromARGB(255, 28, 28, 38),
                      darkColor: Colors.white),
                ),
              ),
              trailing: Icon(
                CupertinoIcons.book_fill,
                color: CupertinoDynamicColor.withBrightness(
                    color: Color.fromARGB(255, 175, 82, 222),
                    darkColor: Colors.white),
              ),
            ),
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    flex: 8,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.bottomLeft,
                          child: CupertinoButton(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(CupertinoIcons.globe),
                                const SizedBox(width: 5),
                                Text(_selectedLocale), // TODO: change if time
                              ],
                            ),
                            onPressed: () => {
                              _showDialog(
                                CupertinoPicker(
                                  itemExtent: 32,
                                  onSelectedItemChanged: (int value) {
                                    setState(() {
                                      _selectedLocale =
                                          _locales[value].localeId;
                                    });
                                  },
                                  children: List<Widget>.generate(
                                    _locales.length,
                                    (int index) {
                                      return Center(
                                        child: Text(
                                          _locales[index].localeId,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: Container(
                            height: 6 * MediaQuery.of(context).size.height / 14,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const CupertinoDynamicColor.withBrightness(
                                color: Color(0xFFF2F2F7),
                                darkColor: Colors.black54,
                              ),
                            ),
                            child: GestureDetector(
                              onTap: () => {
                                prevText = prevText.isEmpty ? [""] : prevText,
                                if (speechInit && !micState)
                                  {
                                    // Speech is initialized,
                                    micState = !micState,
                                    _startListening()
                                  }
                                else if (speechInit && micState)
                                  {
                                    // Speech is initialized,
                                    micState = !micState,
                                    _stopListening()
                                  }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: SingleChildScrollView(
                                  controller: _scrollController,
                                  child: micState && prevText.isNotEmpty
                                      ? RichText(
                                          textAlign: TextAlign.left,
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: prevText.join("\n") == ""
                                                    ? ""
                                                    : "${prevText.join("\n")}\n",
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w300,
                                                  color: CupertinoDynamicColor
                                                      .withBrightness(
                                                    color: Colors.black,
                                                    darkColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              TextSpan(
                                                text: otext,
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w500,
                                                  color: CupertinoDynamicColor
                                                      .withBrightness(
                                                    color: Colors.black,
                                                    darkColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              TextSpan(
                                                text: ctext,
                                                style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w700,
                                                  color: CupertinoDynamicColor
                                                      .withBrightness(
                                                    color: Colors.black,
                                                    darkColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : prevText.isEmpty
                                          ? Container(
                                              height: 6 *
                                                  MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  14,
                                              child: Center(
                                                child: Icon(
                                                  CupertinoIcons.mic_fill,
                                                  size: 64,
                                                  color: CupertinoDynamicColor
                                                      .withBrightness(
                                                    color: Color(0xC01C1C1E),
                                                    darkColor: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : Stack(
                                              children: [
                                                RichText(
                                                  textAlign: TextAlign.left,
                                                  text: TextSpan(
                                                    children: [
                                                      TextSpan(
                                                        text: prevText.join(
                                                                    "\n") ==
                                                                ""
                                                            ? ""
                                                            : "${prevText.join("\n")}\n",
                                                        style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                          color:
                                                              CupertinoDynamicColor
                                                                  .withBrightness(
                                                            color: Colors.black,
                                                            darkColor:
                                                                Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: otext,
                                                        style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color:
                                                              CupertinoDynamicColor
                                                                  .withBrightness(
                                                            color: Colors.black,
                                                            darkColor:
                                                                Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      TextSpan(
                                                        text: ctext,
                                                        style: TextStyle(
                                                          fontSize: 25,
                                                          fontWeight:
                                                              FontWeight.w700,
                                                          color:
                                                              CupertinoDynamicColor
                                                                  .withBrightness(
                                                            color: Colors.black,
                                                            darkColor:
                                                                Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  bottom: 0,
                                                  right: 0,
                                                  child: Text(
                                                    "Press to speak again ",
                                                  ),
                                                ),
                                              ],
                                            ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 6,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Align(
                              alignment: Alignment.bottomLeft,
                              child: CupertinoButton(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(CupertinoIcons.globe),
                                    const SizedBox(width: 5),
                                    Text(_setTTSlocale), // TODO: change if time
                                  ],
                                ),
                                onPressed: () => {
                                  _showDialog(
                                    CupertinoPicker(
                                      itemExtent: 32,
                                      onSelectedItemChanged: (int value) {
                                        setState(() {
                                          _setTTSlocale = _TTSGood[value];
                                          flutterTts.setLanguage(_setTTSlocale);
                                        });
                                      },
                                      children: List<Widget>.generate(
                                        _TTSGood.length,
                                        (int index) {
                                          return Center(
                                            child: Text(
                                              _TTSGood[index].toString(),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                },
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomRight,
                              child: CupertinoButton(
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                        CupertinoIcons.arrow_2_circlepath),
                                    const SizedBox(width: 5),
                                  ],
                                ),
                                onPressed: () => {
                                  setState(
                                    () {
                                      // toggle transform
                                      _transform = !_transform;
                                    },
                                  ),
                                },
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                          child: Container(
                            height: 3 * MediaQuery.of(context).size.height / 14,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const CupertinoDynamicColor.withBrightness(
                                color: Color(0xFFAF52DE),
                                darkColor: Colors.black54,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 0,
                                  offset: const Offset(0, 5),
                                )
                              ],
                            ),
                            child: GestureDetector(
                              onTap: () => {},
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: RotatedBox(
                                    quarterTurns: _transform ? 2 : 0,
                                    child: CupertinoTextField(
                                      focusNode: _focus,
                                      controller: _textController,
                                      onTap: () => {},
                                      onChanged: (val) => {
                                        if (val.lastIndexOf("\n") == -1)
                                          {
                                            // line continues
                                            _textToSay = val,
                                          }
                                        else
                                          {
                                            // line has ended somewhere
                                            if (val.lastIndexOf("\n") ==
                                                val.length - 1)
                                              {
                                                // line just ended, speak it
                                                _speak(_textToSay),
                                                _textToSay = "",
                                              }
                                            else
                                              {
                                                // line
                                                _textToSay = val.substring(
                                                    val.lastIndexOf("\n") + 1),
                                              }
                                          },
                                      },
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                      ),
                                      maxLines: 100,
                                      keyboardType: TextInputType.multiline,
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: Colors.transparent,
                                        ),
                                      ),
                                      // prefix: Icon(CupertinoIcons.keyboard),
                                      placeholder: "Type here...",
                                      placeholderStyle: TextStyle(
                                        fontSize: 24,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
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
      ),
    );
  }
}
