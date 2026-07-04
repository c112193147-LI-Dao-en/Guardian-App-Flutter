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
  final ScrollController _scrollController = ScrollController(); 
  
  List<Map<String, dynamic>> _messages = [];
  bool _isTyping = false; 

  final String _apiKey = '你的_OPENAI_API_KEY'; 

  @override
  void initState() {
    super.initState();
    _loadHistory(); 
  }

  Future<String> _generateTimestamp() async {
    final db = await DatabaseHelper.instance.database;
    final records = await db.query(DatabaseHelper.table, orderBy: "id DESC", limit: 1);

    String targetDate = DateTime.now().toIso8601String().split('T')[0]; 

    if (records.isNotEmpty) {
      // 這裡已經加上 .toString()，紅線不會再出現了！
      String latestDateStr = records.first['date'].toString().split(' ')[0]; 
      targetDate = latestDateStr.replaceAll('/', '-'); 
    }
    
    String currentTime = DateTime.now().toIso8601String().split('T')[1];
    return "${targetDate}T$currentTime";
  }

  void _loadHistory() async {
    final chats = await DatabaseHelper.instance.readAllChats();
    setState(() {
      final normalChats = chats.where((c) => c['isBot'] != 2).toList();
      
      if (normalChats.isEmpty) {
        _messages = [{'isBot': true, 'text': '你好！我是你的專屬心理守護助手。今天感覺如何？'}];
      } else {
        _messages = normalChats.map((c) => {
          'isBot': c['isBot'] == 1,
          'text': c['text']
        }).toList();
      }
    });
    _scrollToBottom();
  }

  void _handleSend() async {
    String text = _controller.text.trim();
    if (text.isEmpty) return;

    _controller.clear();

    setState(() {
      _messages.add({'isBot': false, 'text': text});
      _isTyping = true; 
    });
    
    String userTimestamp = await _generateTimestamp();
    await DatabaseHelper.instance.insertChat({
      'isBot': 0, 'text': text, 'timestamp': userTimestamp
    });
    _scrollToBottom();

    String botReply = "";

    if (_apiKey == '你的_OPENAI_API_KEY') {
      await Future.delayed(const Duration(seconds: 2));
      botReply = "我了解你的感受。這段時間辛苦了，無論發生什麼事，我都會在這裡陪伴你。如果願意的話，可以跟我多分享一點喔！";
    } else {
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

    if (mounted) {
      setState(() {
        _isTyping = false; 
        _messages.add({'isBot': true, 'text': botReply});
      });
      
      String botTimestamp = await _generateTimestamp();
      await DatabaseHelper.instance.insertChat({
        'isBot': 1, 'text': botReply, 'timestamp': botTimestamp
      });
      _scrollToBottom();
    }
  }

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
        actions: [
          TextButton(
            onPressed: () async {
              final userMessages = _messages.where((m) => m['isBot'] == false).toList();
              String summary = "單純陪伴，無特別紀錄";
              if (userMessages.isNotEmpty) {
                summary = userMessages.map((m) => m['text']).join(' / ');
              }
              
              String summaryTimestamp = await _generateTimestamp();
              await DatabaseHelper.instance.saveSummaryAndClearChats(summary, summaryTimestamp);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('對話已轉為日誌並清除紀錄！'), backgroundColor: Colors.indigo));
                Navigator.pop(context);
              }
            },
            child: const Text('結束並存檔', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
        ],
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