import "package:flutter/material.dart";
import 'package:indriyeahapp/widgets/custom_app_bar.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart' as srr;
import 'package:flutter_tts/flutter_tts.dart';

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

  final stt.SpeechToText _speechToText = stt.SpeechToText();

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

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _initTts();
  }

  _initTts() {
    flutterTts = FlutterTts();
    _setAwaitOptions();
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
    print("SPEAKING?@?@?E??");
    print(flutterTts);
    await flutterTts.setLanguage("en-US");
    await flutterTts.setVolume(1.0);
    await flutterTts.setSpeechRate(0.420);
    await flutterTts.setPitch(1.0);
    print("everything was set...");
    await flutterTts.speak(say);
    print("i spoke?!?");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      body: SafeArea(
        child: Center(
          child: IntrinsicHeight(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Flexible(
                  flex: MediaQuery.of(context).viewInsets.bottom == 0 ? 1 : 1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Text(
                        "Indri.yeah",
                        // textAlign: MediaQuery.of(context).viewInsets.bottom == 0
                        //     ? TextAlign.left
                        //     : TextAlign.center,
                        style: TextStyle(
                          fontSize:
                              MediaQuery.of(context).viewInsets.bottom == 0
                                  ? 30
                                  : 18,
                          color: Colors.pink.shade900,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: MediaQuery.of(context).viewInsets.bottom == 0 ? 8 : 6,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
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
                Flexible(
                  flex: MediaQuery.of(context).viewInsets.bottom == 0 ? 2 : 4,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Ink(
                      // height: MediaQuery.of(context).viewInsets.bottom == 0
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
                                    controller: _textController,
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
                                        color:
                                            Color.fromARGB(255, 202, 176, 176),
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
    );
  }
}
