import 'dart:async';

import "package:flutter/material.dart";
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart' as srr;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';

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

  final stt.SpeechToText _speechToText = stt.SpeechToText();

  late StreamSubscription<bool> keyboardSubscription;

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

  // _check () {
  //   if (MediaQuery.of(context).viewInsets.bottom  < 0)
  // }

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
    await flutterTts.setIosAudioCategory(
      IosTextToSpeechAudioCategory.playback,
      [
        IosTextToSpeechAudioCategoryOptions.allowBluetooth,
        IosTextToSpeechAudioCategoryOptions.allowBluetoothA2DP,
        IosTextToSpeechAudioCategoryOptions.allowAirPlay,
        IosTextToSpeechAudioCategoryOptions.duckOthers,
        IosTextToSpeechAudioCategoryOptions.defaultToSpeaker
      ],
      IosTextToSpeechAudioMode.voicePrompt,
    );
  }

  Future _speak(say) async {
    await flutterTts.setLanguage("en-US");
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
    await _speechToText.listen(onResult: _onSpeechResult);
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
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black,
                ),
                child: Center(
                  child: SizedBox(
                    width: 60.0,
                    height: 60.0,
                    child: Text(
                      "Settings",
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.translate),
                title: const Text('Change language'),
                onTap: () {
                  // change app state...
                  Navigator.pop(context); // close the drawer
                },
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
                                style: TextStyle(
                                  fontSize: !_keyboardUp ? 40 : 32,
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                  fontWeight: FontWeight.w900,
                                  fontFamily: "Source Sans Pro",
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
                      child: NotificationListener(
                        onNotification:
                            (SizeChangedLayoutNotification notification) {
                          if (_keyboardUp == true) {
                            if (_realTap == false) {
                              FocusScope.of(context).unfocus();
                            } else {
                              // after animation,
                              // set _realTap to false
                              // wait for animation to finish
                              Future.delayed(const Duration(milliseconds: 600),
                                  () {
                                _realTap = false;
                              });
                            }
                          }
                          return true;
                        },
                        child: SizeChangedLayoutNotifier(
                          child: Ink(
                            child: Stack(
                              children: [
                                Ink(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    color: Colors.purple.shade100,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 10,
                                        offset: const Offset(0, 5),
                                      ),
                                    ],
                                  ),
                                  child: InkWell(
                                    onTap: () => {},
                                    child: Center(
                                      child: SingleChildScrollView(
                                        controller: _controller,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: RichText(
                                              text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: prevText.join("\n") == ""
                                                    ? ""
                                                    : "${prevText.join("\n")}\n\n",
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.blue,
                                                ),
                                              ),
                                              TextSpan(
                                                text: otext,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w300,
                                                ),
                                              ),
                                              TextSpan(
                                                text: ctext,
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ],
                                          )),
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
                                      color: Colors.deepPurple,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 10,
                                          offset: const Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: GestureDetector(
                                      onTap: () => {
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
                                      child: micState
                                          ? const Icon(
                                              Icons.mic,
                                              color: Colors.white,
                                            )
                                          : const Icon(
                                              Icons.mic_off_rounded,
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
                                color: Colors.purple.shade800,
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 10,
                                      offset: const Offset(0, 5))
                                ],
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
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                      ),
                                      maxLines: 100,
                                      keyboardType: TextInputType.multiline,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        hintText: "Type your message here",
                                        hintStyle: TextStyle(
                                          color: Color.fromARGB(
                                              255, 202, 176, 176),
                                          fontSize: 20,
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
