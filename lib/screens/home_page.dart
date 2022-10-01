import "package:flutter/material.dart";
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart' as srr;
import 'package:text_to_speech/text_to_speech.dart';

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
  final TextToSpeech tts = TextToSpeech();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink.shade100,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          "indri.yeah",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      body: Center(
        child: IntrinsicHeight(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
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
                        height: MediaQuery.of(context).size.height / 3,
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
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    TextSpan(
                                      text: otext,
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Colors.black,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ctext,
                                      style: TextStyle(
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
                          margin: EdgeInsets.all(5),
                          padding: EdgeInsets.all(5),
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
                                ? Icon(
                                    Icons.mic,
                                    color: Colors.white,
                                  )
                                : Icon(
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
              Expanded(
                child: Container(
                  color: Colors.blue,
                  height: MediaQuery.of(context).size.height / 3,
                  child: Center(
                    child: Text("indri.yeah text"),
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Colors.blueGrey,
                  height: MediaQuery.of(context).size.height / 3,
                  child: Center(
                    child: Text("indri.yeah keyboard goes here if active"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
