import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // Thay thế bằng API Key của bạn (KHÔNG BAO GIỜ NHÚNG TRỰC TIẾP TRONG ỨNG DỤNG THỰC TẾ)
  // static const _apiKey = String.fromEnvironment("AIzaSyC_vUuwBetE9Wfr6sHS7X54ko_JJA1Tkjg"); // Nên lấy từ biến môi trường
  static const _apiKey = "AIzaSyC_vUuwBetE9Wfr6sHS7X54ko_JJA1Tkjg"; // Chỉ dùng cho demo

  late final GenerativeModel _model;
  late final ChatSession _chat;

  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false; // Trạng thái tải

  @override
  void initState() {
    super.initState();
    if (_apiKey.isEmpty) {
      throw Exception('API Key is not set. Please set the API_KEY environment variable.');
    }
    _model = GenerativeModel(model: 'gemini-2.5-flash-preview-05-20', apiKey: _apiKey);
    _chat = _model.startChat(); // Bắt đầu một phiên chat mới
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Hàm gửi tin nhắn
  Future<void> _sendMessage() async {
    // setState(() {
    //   _isLoading = true; // Bắt đầu tải
    // });
    // try {
    //   final message = _textController.text;
    //   if (message.isEmpty) return;
    //
    //   // Gửi tin nhắn và chờ phản hồi
    //   // Lịch sử chat tự động được duy trì trong _chat
    //   final response = await _chat.sendMessage(Content.text(message));
    //
    //   // Xóa input sau khi gửi
    //   _textController.clear();
    //
    //   // Cuộn xuống cuối để hiển thị tin nhắn mới
    //   _scrollToEnd();
    // } catch (e) {
    //   print('Error sending message: $e');
    //   ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    // } finally {
    //   setState(() {
    //     _isLoading = false; // Kết thúc tải
    //   });
    // }

    print(_chat.history);
  }

  // Hàm cuộn xuống cuối danh sách tin nhắn
  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gemini Chat')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _chat.history.length, // Lấy lịch sử chat
                itemBuilder: (context, index) {
                  final content = _chat.history.toList()[index];
                  final isUser = content.role == 'user'; // Kiểm tra vai trò của tin nhắn

                  return Align(
                    alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                      padding: const EdgeInsets.all(12.0),
                      decoration: BoxDecoration(
                        color: isUser ? Colors.blue[100] : Colors.grey[200],
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        content.parts
                            .whereType<TextPart>()
                            .map((e) => e.text)
                            .join('\n'), // Hiển thị nội dung tin nhắn
                        style: TextStyle(color: isUser ? Colors.blue[900] : Colors.black87),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _textController,
                      decoration: InputDecoration(
                        hintText: 'Nhập tin nhắn của bạn...',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20.0)),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 10.0,
                        ),
                      ),
                      onSubmitted: (value) => _sendMessage(), // Gửi khi nhấn Enter
                      enabled: !_isLoading, // Vô hiệu hóa khi đang tải
                    ),
                  ),
                  const SizedBox(width: 8.0),
                  _isLoading
                      ? const CircularProgressIndicator() // Hiển thị vòng xoay tải
                      : FloatingActionButton(
                          onPressed: _sendMessage,
                          child: const Icon(Icons.send),
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
