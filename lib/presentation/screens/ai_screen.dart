import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:gpt_markdown/gpt_markdown.dart';

class AIScreen extends StatefulWidget {
  @override
  _AIScreenState createState() => _AIScreenState();
}

class _AIScreenState extends State<AIScreen> {
  final String apiKey =
      "AIzaSyC_vUuwBetE9Wfr6sHS7X54ko_JJA1Tkjg"; // Replace with your actual API key
  late final GenerativeModel _model;
  String _responseText = "Loading...";
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(model: 'gemini-2.5-flash-preview-05-20', apiKey: apiKey);
    // _generateContent("Tell me a fun fact about Flutter."); // Initial prompt
  }

  Future<void> _generateContent(String prompt) async {
    setState(() {
      _responseText = "Generating...";
    });
    try {
      final content = [Content.text(prompt)];
      final response = await _model.generateContent(content);
      setState(() {
        _responseText = response.text ?? "No response text.";
      });
    } catch (e) {
      setState(() {
        _responseText = "Error: ${e.toString()}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('Gemini API Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Enter your prompt here...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (String value) {
                  if (value.isNotEmpty) {
                    _generateContent(value);
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    _generateContent(_controller.text);
                  }
                },
                child: Text('Send Prompt'),
              ),
              SizedBox(height: 20),
              Text('Gemini Response:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Expanded(
                child: ListView(
                  children: [
                    GptMarkdown(
                      _responseText,
                      onLinkTab: (url, url1) {
                        print(url);
                        print(url1);
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
