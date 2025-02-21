import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/calendar/v3.dart' as cal;
import 'package:googleapis_auth/googleapis_auth.dart' as auth;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'task_history.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SpeechToTextScreen(),
    );
  }
}

class SpeechToTextScreen extends StatefulWidget {
  @override
  _SpeechToTextScreenState createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  String _transcription = "Press the button and start speaking...";
  Map<String, dynamic>? extractedActions;
  bool _isProcessing = false;
  bool _showAboutUsButtons = false; // Flag to show License and GitHub buttons

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [cal.CalendarApi.calendarScope],
  );

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    bool available = await _speech.initialize();
    if (!available) {
      print("Speech recognition is not available.");
    }
  }

  void _startListening() async {
    if (!_isListening) {
      setState(() {
        _isListening = true;
        _transcription = "Listening...";
      });
    }

    await _speech.listen(
      onResult: (result) {
        setState(() {
          _transcription = result.recognizedWords;
        });
      },
      listenMode: stt.ListenMode.dictation,
      partialResults: true,
      listenFor: Duration(minutes: 5),
    );
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
    _sendToGemini();
  }

  Future<void> _sendToGemini() async {
    if (_transcription.isEmpty || _transcription == "Listening...") {
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    String apiUrl = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=AIzaSyCYYZQDiDAhq8tvZZyhlHA3KDiZ7gbFrH8";

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "contents": [
          {
            "role": "user",
            "parts": [
              {"text": "Extract action items, tasks, meeting points, and date/time from this transcript: $_transcription"}
            ]
          }
        ]
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      if (jsonResponse["candidates"] != null && jsonResponse["candidates"].isNotEmpty) {
        setState(() {
          extractedActions = {
            "Meeting_Agenda": _transcription,
            "Summary": jsonResponse["candidates"][0]["content"]["parts"][0]["text"],
            "Date": DateTime.now().toIso8601String(),
          };
        });

        _saveTaskHistory(extractedActions!);
      }
    } else {
      print("Gemini API Error: ${response.body}");
    }

    setState(() {
      _isProcessing = false;
    });
  }



  Future<void> _addToGoogleCalendar() async {
    if (extractedActions == null || !extractedActions!.containsKey("Date")) return;

    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    if (googleUser == null) {
      print("User canceled Google sign-in");
      return;
    }

    // Convert extracted date string to DateTime object
    DateTime eventStartDate = DateTime.parse(extractedActions!["Date"]);

    final event = cal.Event()
      ..summary = extractedActions!["Summary"]
      ..start = cal.EventDateTime(dateTime: eventStartDate, timeZone: "UTC")
      ..end = cal.EventDateTime(dateTime: eventStartDate.add(Duration(hours: 1)), timeZone: "UTC");

    print("Event sent to Google Calendar: ${event.summary}, ${event.start?.dateTime}");
  }

  Future<void> _saveTaskHistory(Map<String, dynamic> newTask) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> history = prefs.getStringList('taskHistory') ?? [];
    history.add(jsonEncode(newTask));
    await prefs.setStringList('taskHistory', history);
  }
  void _launchGitHub() async {
    const url = 'https://github.com/adityakr1108'; // Replace with your GitHub URL
    final Uri uri = Uri.parse(url);

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback to a browser if no suitable app is found
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Error launching URL: $e');
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Smart Voice Assistant"), centerTitle: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Mic Button with some spacing
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: GestureDetector(
              onTap: _isListening ? _stopListening : _startListening,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 300),
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isListening ? Colors.redAccent : Colors.blueAccent,
                ),
                child: Icon(_isListening ? Icons.stop : Icons.mic, size: 36, color: Colors.white),
              ),
            ),
          ),

          // Transcription text
          SizedBox(height: 30),
          _buildInfoBox("Transcription", _transcription),

          // Extracted Actions editable
          SizedBox(height: 20),
          if (extractedActions != null)
            Expanded(
              child: _buildEditableInfoBox("Extracted Actions", extractedActions),
            ),

          // Processing status
          if (_isProcessing)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircularProgressIndicator(),
            ),

          // Horizontal Buttons at the Bottom
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _addToGoogleCalendar,
                  child: Text("Save Data"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => TaskHistoryScreen()));
                  },
                  child: Text("Task History"),
                ),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAboutUsButtons = !_showAboutUsButtons; // Toggle About Us section
                    });
                  },
                  child: Text("About Us"),
                ),
              ],
            ),
          ),

          // Show License and GitHub buttons only when "About Us" is clicked
          if (_showAboutUsButtons)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Column(
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      showLicensePage(context: context);
                    },
                    icon: Icon(Icons.policy),
                    label: Text("License"),
                  ),
                  ElevatedButton.icon(
                    onPressed: _launchGitHub,
                    icon: Icon(Icons.link),
                    label: Text("GitHub Profile"),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoBox(String title, String content) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 2, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent)),
          SizedBox(height: 8),
          SingleChildScrollView(child: Text(content, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500))),
        ],
      ),
    );
  }

  Widget _buildEditableInfoBox(String title, Map<String, dynamic>? data) {
    if (data == null) return Container();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), spreadRadius: 2, blurRadius: 4)],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          _buildEditableField("Meeting Agenda", data["Meeting_Agenda"] ?? ""),
          _buildEditableField("Summary", data["Summary"] ?? ""),
          _buildEditableField("Date", data["Date"] ?? ""),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, String initialValue) {
    TextEditingController controller = TextEditingController(text: initialValue);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        onChanged: (newValue) {
          setState(() {
            if (label == "Meeting Agenda") {
              extractedActions?["Meeting_Agenda"] = newValue;
            } else if (label == "Summary") {
              extractedActions?["Summary"] = newValue;
            } else if (label == "Date") {
              extractedActions?["Date"] = newValue;
            }
          });
        },
      ),
    );
  }
}
