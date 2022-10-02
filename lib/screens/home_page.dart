import 'dart:async';

import "package:flutter/material.dart";
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart' as srr;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

import 'package:google_fonts/google_fonts.dart';

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
  late FlutterTts flutterTts;
  String _textToSay = "";
  bool _keyboardUp = false;
  List<stt.LocaleName> _locales = [];
  List<dynamic> _TTSlanguages = [];
  List<String> _TTSGood = [];

  final stt.SpeechToText _speechToText = stt.SpeechToText();

  late StreamSubscription<bool> keyboardSubscription;

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

  bool _realTap = false;

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
    _TTSlanguages = await flutterTts.getLanguages;
    // convert _TTSlanguages to a list of strings

    _TTSGood = _TTSlanguages.map((e) => e.toString()).toList();

    if (Platform.isAndroid) {
      var map = await flutterTts.areLanguagesInstalled(_TTSGood);

      // edit TTS Languages to remove unsupported languages
      _TTSGood.removeWhere((element) => !map[element]!);
    }
    print(_TTSGood);

    await flutterTts.awaitSpeakCompletion(true);
  }

  Future _speak(say) async {
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.420);
    await flutterTts.setPitch(1.0);
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        if (_keyboardUp == true)
          {
            FocusScope.of(context).unfocus(),
            _realTap = true,
          }
      },
      child: Scaffold(
        endDrawer: Drawer(
          child: ListView(
            physics: const NeverScrollableScrollPhysics(),
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                ),
                child: const SizedBox(
                  width: double.infinity,
                  height: 40.0,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 48,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('Change STT Language'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              height: 300,
                              width: 200,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _locales.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_locales[index].name),
                                    onTap: () {
                                      setState(
                                        () {
                                          _selectedLocale =
                                              _locales[index].localeId;
                                        },
                                      );
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Change TTS Language'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              height: 300,
                              width: 200,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: _TTSGood.length,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    title: Text(_TTSGood[index]),
                                    onTap: () {
                                      setState(
                                        () {
                                          flutterTts.setLanguage(
                                            _TTSGood[index],
                                          );
                                        },
                                      );
                                      Navigator.pop(context);
                                    },
                                  );
                                },
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.mic_none_outlined),
                title: const Text('Change Voice'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.speed_outlined),
                title: const Text('Change Speed'),
                onTap: () {},
              ),
              ListTile(
                leading: const Icon(Icons.dark_mode_outlined),
                title: const Text('Dark Mode'),
                onTap: () {},
              )
            ],
          ),
        ),
        key: _scaffoldKey,
        backgroundColor: Theme.of(context).colorScheme.background,
        body: SafeArea(
          child: Center(
            child: IntrinsicHeight(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Flexible(
                    flex: !_keyboardUp ? 1 : 1,
                    child: Padding(
                      padding: !_keyboardUp
                          ? const EdgeInsets.fromLTRB(20, 0, 10, 0)
                          : const EdgeInsets.fromLTRB(20, 0, 10, 0),
                      child: Row(
                        children: [
                          Expanded(
                            child: AnimatedAlign(
                              alignment: !_keyboardUp
                                  ? Alignment.centerLeft
                                  : const Alignment(0.1, 0),
                              duration: const Duration(milliseconds: 300),
                              child: AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 300),
                                style: GoogleFonts.sourceSansPro(
                                  textStyle: TextStyle(
                                    fontSize: !_keyboardUp ? 40 : 32,
                                    color:
                                        Theme.of(context).colorScheme.onPrimary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                child: const Text(
                                  "Indri.yeah",
                                ),
                              ),
                            ),
                          ),
                          AnimatedAlign(
                            alignment: Alignment.center,
                            duration: const Duration(milliseconds: 300),
                            child: IconButton(
                                onPressed: () => {
                                      _scaffoldKey.currentState!
                                          .openEndDrawer(),
                                    },
                                icon: Icon(
                                  Icons.menu,
                                  color: Colors.pink.shade900,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: !_keyboardUp ? 8 : 6,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                      child: Ink(
                        // TODO: make text come from bottom
                        child: Stack(
                          children: [
                            Positioned.fill(
                              top: 0,
                              left: 0,
                              child: Ink(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  color: Theme.of(context).colorScheme.primary,
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //     color: Colors.black.withOpacity(0.2),
                                  //     blurRadius: 10,
                                  //     offset: const Offset(0, 5),
                                  //   ),
                                  // ],
                                ),
                                child: InkWell(
                                  onTap: () => {
                                    prevText =
                                        prevText.isEmpty ? [""] : prevText,
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
                                    child: LayoutBuilder(
                                      builder: (context, constraints) {
                                        return SingleChildScrollView(
                                          controller: _controller,
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: micState &&
                                                    prevText.isNotEmpty
                                                ? RichText(
                                                    textAlign: TextAlign.left,
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: prevText.join(
                                                                      "\n") ==
                                                                  ""
                                                              ? ""
                                                              : "${prevText.join("\n")}\n",
                                                          style: GoogleFonts
                                                              .robotoSlab(
                                                            textStyle:
                                                                const TextStyle(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      90,
                                                                      90,
                                                                      90),
                                                            ),
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: otext,
                                                          style: GoogleFonts
                                                              .robotoSlab(
                                                            textStyle:
                                                                const TextStyle(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: Color
                                                                  .fromARGB(
                                                                      255,
                                                                      120,
                                                                      120,
                                                                      120),
                                                            ),
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: ctext,
                                                          style: GoogleFonts
                                                              .robotoSlab(
                                                            textStyle:
                                                                const TextStyle(
                                                              fontSize: 24,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color:
                                                                  Colors.black,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  )
                                                : prevText.isEmpty
                                                    ? ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                            minHeight:
                                                                constraints
                                                                    .maxHeight),
                                                        child: Center(
                                                          child: Text(
                                                            "Tap to speak",
                                                            style: GoogleFonts
                                                                .robotoSlab(
                                                              textStyle:
                                                                  const TextStyle(
                                                                fontSize: 24,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w400,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      )
                                                    : RichText(
                                                        textAlign:
                                                            TextAlign.left,
                                                        text: TextSpan(
                                                          children: [
                                                            TextSpan(
                                                              text: prevText.join(
                                                                          "\n") ==
                                                                      ""
                                                                  ? ""
                                                                  : "${prevText.join("\n")}\n",
                                                              style: GoogleFonts
                                                                  .robotoSlab(
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontSize: 24,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          90,
                                                                          90,
                                                                          90),
                                                                ),
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: otext,
                                                              style: GoogleFonts
                                                                  .robotoSlab(
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontSize: 24,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Color
                                                                      .fromARGB(
                                                                          255,
                                                                          120,
                                                                          120,
                                                                          120),
                                                                ),
                                                              ),
                                                            ),
                                                            TextSpan(
                                                              text: ctext,
                                                              style: GoogleFonts
                                                                  .robotoSlab(
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontSize: 24,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: Colors
                                                                      .black,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.fromLTRB(8, 2, 8, 2),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color:
                                      Theme.of(context).colorScheme.secondary,
                                ),
                                child: GestureDetector(
                                  child: micState
                                      ? const Icon(
                                          Icons.mic_none_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        )
                                      : const Icon(
                                          Icons.mic_off_outlined,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                ),
                              ),
                            ),
                            prevText.isNotEmpty && !micState
                                ? Positioned(
                                    bottom: 0,
                                    left: 0,
                                    child: Container(
                                      margin: const EdgeInsets.all(5),
                                      child: Text(
                                        "Tap to start speaking again",
                                        style: GoogleFonts.robotoSlab(
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : Positioned(
                                    bottom: 0, left: 0, child: Container()),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    flex: !_keyboardUp ? 2 : 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Ink(
                        // height: _keyboardUp
                        //     ? (1 * MediaQuery.of(context).size.height) / 8
                        //     : (2 * MediaQuery.of(context).size.height) / 5,
                        child: Stack(
                          children: [
                            Ink(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondaryContainer,
                                // boxShadow: [
                                //   BoxShadow(
                                //     color: Colors.black.withOpacity(0.2),
                                //     blurRadius: 10,
                                //     offset: const Offset(0, 5),
                                //   )
                                // ],
                              ),
                              child: InkWell(
                                onTap: () => {},
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: TextField(
                                      focusNode: _focus,
                                      controller: _textController,
                                      onTap: () => {
                                        setState(() {
                                          _realTap = true;
                                        })
                                      },
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
                                      style: GoogleFonts.robotoSlab(
                                        textStyle: const TextStyle(
                                          fontSize: 24,
                                          color: Colors.white,
                                        ),
                                      ),
                                      maxLines: 100,
                                      keyboardType: TextInputType.multiline,
                                      decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Type your message here",
                                        hintStyle: GoogleFonts.robotoSlab(
                                          textStyle: const TextStyle(
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
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                margin: const EdgeInsets.all(5),
                                padding: const EdgeInsets.all(5),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.green,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: GestureDetector(
                                  onTap: () => {},
                                  child: const Icon(
                                    Icons.autorenew,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
