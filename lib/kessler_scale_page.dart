import 'package:flutter/material.dart';

class KesslerScalePage extends StatefulWidget {
  const KesslerScalePage({super.key});

  @override
  State<KesslerScalePage> createState() => _KesslerScalePageState();
}

class _KesslerScalePageState extends State<KesslerScalePage> {
  final List<String> _questions = [
    "1. 您覺得疲倦，沒有活力嗎？",
    "2. 您覺得心情低落，做什麼都提不起勁嗎？",
    "3. 您覺得焦慮不安，難以放鬆嗎？",
    "4. 您覺得對未來感到沒有希望嗎？",
    "5. 您覺得自己比不上別人嗎？",
  ];

  final List<String> _options = ["從不", "偶爾", "有時", "經常", "總是"];
  late List<int> _answers;

  @override
  void initState() {
    super.initState();
    _answers = List.filled(_questions.length, -1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('柯氏憂鬱量表'), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black)),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_questions[index], style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          children: List.generate(_options.length, (optIdx) {
                            return ChoiceChip(
                              label: Text(_options[optIdx]),
                              selected: _answers[index] == optIdx,
                              onSelected: (s) => setState(() => _answers[index] = optIdx),
                            );
                          }),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50), backgroundColor: const Color(0xFF673AB7)),
              child: const Text('完成評測', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
    );
  }
}