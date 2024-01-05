import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:grit_test/widgets/history_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

import '../hive/entries.dart';
import '../utils.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final stt.SpeechToText _speech = stt.SpeechToText();

  bool isRecording = false;

  final ScrollController _scrollController = ScrollController();

  final FlutterTts flutterTts = FlutterTts();

  Future<void> speak() async {
    await flutterTts.speak(textCtrl.text);
  }

  Future<void> initSpeechToText() async {
    bool available = await _speech.initialize(
      onStatus: (status) {
        print('Speech recognition status: $status');
        if (status == "done") {
          setState(() {
            speechText += ' $recordingText';
            recordingText = '';
            isRecording = false;
            textCtrl.text = '$speechText $recordingText';
          });
        }
      },
      onError: (errorNotification) {
        print('Speech recognition error: $errorNotification');
        setState(() {
          isRecording = false;
          // speechText += recordingText;
          // recordingText = '';
        });
      },
    );

    if (available) {
      print('Speech recognition is available');
    } else {
      print('Speech recognition is not available');
    }
  }

  void startListening() {
    setState(() {
      isRecording = true;
    });
    _speech.listen(
      onResult: (result) {
        setState(() {
          recordingText = result.recognizedWords;
          textCtrl.text =
              isRecording ? '$speechText $recordingText' : speechText;
          scrollToBottom();
        });
      },
      listenFor: Duration(seconds: 30),
    );
  }

  void stopListening() {
    setState(() {
      isRecording = false;
      speechText += ' $recordingText';
      recordingText = '';
      textCtrl.text = '$speechText $recordingText';
      scrollToBottom();
    });
    _speech.stop();
  }

  void scrollToBottom() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  final textCtrl = TextEditingController();

  String speechText = "";

  String recordingText = "";

  final FocusNode _focusNode = FocusNode();
  final Box<Entry> _entryBox = Hive.box<Entry>('entries');

  void saveEntry() {
    final currentTime = DateTime.now();
    final entry = Entry(text: textCtrl.text, time: currentTime);
    _entryBox.add(entry);
    textCtrl.clear();
    speechText = '';
    recordingText = '';
    showToast('Entry saved successfully');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GritStone App'),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              height: MediaQuery.sizeOf(context).height * .25,
              width: MediaQuery.sizeOf(context).width,
              margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.black,
              child: SingleChildScrollView(
                controller: _scrollController,
                scrollDirection: Axis.vertical,
                child: TextField(
                  focusNode: _focusNode,
                  readOnly: isRecording,
                  controller: textCtrl,
                  onChanged: (txt) {
                    setState(() {});
                  },
                  style: TextStyle(color: Colors.white),
                  maxLines: null,
                  decoration: InputDecoration(border: InputBorder.none),
                  cursorColor: Colors.white,
                ),
              ),
            ),
            if (textCtrl.text.isNotEmpty)
              Container(
                  margin: EdgeInsets.symmetric(horizontal: 16),
                  alignment: Alignment.centerRight,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          onPrimary: Colors.white,
                          elevation: 5.0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: saveEntry,
                        child: Text('Save'),
                      ),
                      Spacer(),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red,
                          onPrimary: Colors.white,
                          elevation: 5.0,
                          padding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        onPressed: () => setState(() {
                          textCtrl.clear();
                          speechText = '';
                          recordingText = '';
                        }),
                        child: Text('Discard'),
                      ),
                      Spacer(),
                      IconButton(onPressed: speak, icon: Icon(Icons.volume_up)),
                    ],
                  )),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: isRecording ? Colors.red : null,
                onPrimary: isRecording ? Colors.white : null,
                elevation: 5.0,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onPressed: () async {
                if (!isRecording) {
                  await initSpeechToText();
                  startListening();
                } else {
                  stopListening();
                }
              },
              child: Text(isRecording ? 'Stop' : 'Start Voice Typing'),
            ),
            SizedBox(
              height: 50,
            ),
            Expanded(child: HistoryWidget())
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     Provider.of<DataProvider>(context, listen: false).updateData();
      //     speak();
      //   },
      //   child: Icon(Icons.refresh),
      // ),
    );
  }
}
