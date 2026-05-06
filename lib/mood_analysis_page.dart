import 'package:flutter/material.dart';

class MoodAnalysisPage extends StatelessWidget {
  const MoodAnalysisPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('心情數據分析')),
      body: const Center(child: Text('這裡之後會放情緒統計圖表')),
    );
  }
}