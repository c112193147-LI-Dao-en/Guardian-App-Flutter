import 'package:flutter/material.dart';
// 👉 1. 補上這兩行，讓它認識新房間
import 'ai_chatbot_page.dart';
import 'mood_analysis_page.dart';

class AdvancedGuardianScreen extends StatelessWidget {
  const AdvancedGuardianScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8FC), 
      body: Column(
        children: [
          // ==========================================
          // 上半部：紫色漸層 Header 區域
          // ==========================================
          Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFF6B48FF),
                  Color(0xFF3D5AFE),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(left: 24.0, right: 24.0, top: 40.0, bottom: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Icon(
                      Icons.local_florist,
                      color: Colors.white,
                      size: 32,
                    ),
                    SizedBox(height: 16),
                    Text(
                      '進階心理守護',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '更多專業諮商與評測功能',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ==========================================
          // 下半部：功能列表區域
          // ==========================================
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(top: 16.0),
              children: [
                _buildFeatureItem(
                  icon: Icons.assignment_outlined,
                  title: '柯氏憂鬱量表',
                  subtitle: '定期心理狀態評測',
                ),
                _buildFeatureItem(
                  icon: Icons.calendar_today_outlined,
                  title: '諮商預約',
                  subtitle: '與心理師對話',
                ),
                // 👉 2. 補上聊天機器人的跳轉指令
                _buildFeatureItem(
                  icon: Icons.smart_toy_outlined,
                  title: '聊天機器人',
                  subtitle: '24小時AI心理陪伴',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const AIChatbotPage()));
                  },
                ),
                // 👉 3. 你的心情數據分析跳轉指令
                _buildFeatureItem(
                  icon: Icons.analytics_outlined,
                  title: '心情數據分析',
                  subtitle: '發掘情緒變化趨勢',
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const MoodAnalysisPage()));
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // 共用 UI 模組升級版！
  // ==========================================
  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap, // 👉 4. 讓它學會接收 onTap 參數
  }) {
    // 👉 5. 用 GestureDetector 包起來，讓整列都可以點擊
    return GestureDetector(
      onTap: onTap, 
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF3D5AFE).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: const Color(0xFF3D5AFE),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D2D2D),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                // 如果有 onTap 就變成深藍色，沒有就是淺藍色
                color: onTap != null ? const Color(0xFF3D5AFE) : const Color(0xFF7C8DCC), 
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                onTap != null ? '進入' : '即將推出', // 👉 6. 聰明的文字切換
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}