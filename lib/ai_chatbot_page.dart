import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'database_helper.dart';

class AIChatbotPage extends StatefulWidget {
  const AIChatbotPage({Key? key}) : super(key: key);

  @override
  State<AIChatbotPage> createState() => _AIChatbotPageState();
}

class _AIChatbotPageState extends State<AIChatbotPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController(); // 控制畫面自動捲動
  
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false; // 👉 控制「正在輸入中」的動畫狀態

  // 🔑 OpenAI API 金鑰 (請換成你自己的)
  final String _apiKey = '你的_OPENAI_API_KEY'; 

  @override
  void initState() {
    super.initState();
    _loadHistory(); // 啟動時先去資料庫撈紀錄
  }

  // 👉 1. 從資料庫讀取對話紀錄
  void _loadHistory() async {
    final chats = await DatabaseHelper.instance.readAllChats();
    setState(() {
      if (chats.isEmpty) {
        // 如果是第一次使用，塞入第一句話
        _messages = [{'isBot': true, 'text': '你好！我是你的專屬心理守護助手。今天感覺如何？'}];
      } else {
        // 從資料庫把 0 和 1 轉換回 true 和 false
        _messages = chats.map((c) => {
          'isBot': c['isBot'] == 1,
          'text': c['text']
        }).toList();
      }
    });
    _scrollToBottom();
  }

  // 👉 2. 發送訊息與呼叫 API
  void _handleSend() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    // 先把使用者的話顯示出來，並存入資料庫
    setState(() {
      _messages.add({'isBot': false, 'text': text});
      _isTyping = true; // 開啟正在輸入動畫
    });
    await DatabaseHelper.instance.insertChat({
      'isBot': 0, 'text': text, 'timestamp': DateTime.now().toIso8601String()
    });
    _scrollToBottom();

    String botReply = "";

    // 👉 3. 智慧回覆機制 (防呆：如果沒放 API Key 就用模擬的)
    if (_apiKey == '你的_OPENAI_API_KEY') {
      await Future.delayed(const Duration(seconds: 2));
      botReply = "我已經收到你的訊息了！(此為模擬回覆，若要啟用真實 AI 對話，請至程式碼中填入 OpenAI API Key)";
    } else {
      // 呼叫真實 OpenAI API
      try {
        final response = await http.post(
          Uri.parse('https://api.openai.com/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey'
          },
          body: jsonEncode({
            'model': 'gpt-3.5-turbo',
            'messages': [
              {'role': 'system', 'content': '你是一個溫暖的心理諮商師，名叫「守護者」。請用繁體中文以簡短、同理、溫柔的語氣回覆使用者，每次回覆不要超過 50 字。'},
              {'role': 'user', 'content': text}
            ]
          })
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          botReply = data['choices'][0]['message']['content'];
        } else {
          print('❌ API 錯誤原因：${response.body}');
          botReply = "抱歉，我的大腦(API)目前有點連線異常，請稍後再試。";
        }
      } catch (e) {
        botReply = "抱歉，網路似乎斷線了，我無法思考。";
      }
    }

    // 將機器人的回覆顯示出來，並存入資料庫
    if (mounted) {
      setState(() {
        _isTyping = false; // 關閉動畫
        _messages.add({'isBot': true, 'text': botReply});
      });
      await DatabaseHelper.instance.insertChat({
        'isBot': 1, 'text': botReply, 'timestamp': DateTime.now().toIso8601String()
      });
      _scrollToBottom();
    }
  }

  // 畫面自動捲到最下方
  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      appBar: AppBar(
        title: const Text('AI 心理陪伴', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        backgroundColor: const Color(0xFF673AB7),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return _buildChatBubble(msg['text'], msg['isBot']);
              },
            ),
          ),
          
          // 👉 4. 「機器人正在輸入中...」小動畫
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16, height: 16, 
                    child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF673AB7))
                  ),
                  const SizedBox(width: 12),
                  Text('守護者正在思考中...', style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                ],
              ),
            ),
            
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isBot) {
    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        decoration: BoxDecoration(
          color: isBot ? Colors.white : const Color(0xFF673AB7),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(isBot ? 4 : 20),
            bottomRight: Radius.circular(isBot ? 20 : 4),
          ),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5, offset: const Offset(0, 2))],
        ),
        child: Text(
          text,
          style: TextStyle(color: isBot ? Colors.black87 : Colors.white, fontSize: 15, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5))],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: '想說些什麼嗎...',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onSubmitted: (_) => _handleSend(),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: const BoxDecoration(color: Color(0xFF673AB7), shape: BoxShape.circle),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                onPressed: _handleSend,
              ),
            ),
          ],
        ),
      ),
    );
  }
}