import 'package:flutter/material.dart';

class MoodAnalysisPage extends StatelessWidget {
  const MoodAnalysisPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      appBar: AppBar(
        backgroundColor: const Color(0xFFF8F9FA),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        // 👇 這裡改掉了
        title: const Text(
          '14 日足跡紀錄',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '近 14 日趨勢分析',
              style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            // 👇 這裡幫你把 7 天改成了 14 天對齊邏輯
            const Text(
              '基於您最近 14 天的活動紀錄', 
              style: TextStyle(fontSize: 14.0, color: Colors.grey),
            ),
            const SizedBox(height: 24.0),

            // --- 異常偵測卡片 ---
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                      SizedBox(width: 8.0),
                      Text(
                        '異常偵測 (點擊查看明細)',
                        style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAlertCircle('2次', '步數異常'),
                      _buildAlertCircle('2次', '螢幕異常'),
                      _buildAlertCircle('2次', '睡眠異常'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32.0),

            // --- 黃金三角平均值 ---
            const Text(
              '黃金三角平均值',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0),
            _buildInfoCard(
              icon: Icons.local_fire_department,
              iconBgColor: const Color(0xFFFFF0E0),
              iconColor: Colors.orange,
              title: '平均步行',
              value: '4099 步',
            ),
            const SizedBox(height: 12.0),
            _buildInfoCard(
              icon: Icons.smartphone,
              iconBgColor: const Color(0xFFE0F0FF),
              iconColor: Colors.blueAccent,
              title: '平均螢幕時間',
              value: '5時34分',
            ),
            const SizedBox(height: 12.0),
            _buildInfoCard(
              icon: Icons.bed,
              iconBgColor: const Color(0xFFEAE0FF),
              iconColor: Colors.deepPurpleAccent,
              title: '平均睡眠時間',
              value: '6.6 小時',
            ),
            const SizedBox(height: 32.0),
            
            const Divider(color: Color(0xFFE0E0E0), thickness: 1),
            const SizedBox(height: 24.0),

            // --- 近期紀錄回顧 ---
            Row(
              children: const [
                Icon(Icons.history, color: Colors.deepPurple, size: 24), // 換成了普通的歷史 icon
                SizedBox(width: 8.0),
                // 👇 這裡改掉了
                Text(
                  '近期活動回顧', 
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16.0),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              decoration: BoxDecoration(
                color: const Color(0xFFEBEBFC), 
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                children: const [
                  Text('05/20', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A6C7A))),
                  SizedBox(width: 16.0),
                  Text('test1', style: TextStyle(color: Colors.deepPurpleAccent, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
            const SizedBox(height: 40.0),
          ],
        ),
      ),
    );
  }

  // 輔助組件不用管
  Widget _buildAlertCircle(String count, String label) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: Color(0xFFFFEBEB), 
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            count,
            style: const TextStyle(color: Colors.redAccent, fontSize: 16.0, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 8.0),
        Text(label, style: const TextStyle(fontSize: 12.0, color: Colors.grey)),
      ],
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: const Color(0xFFEAF1F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8.0),
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 16.0),
          Text(title, style: const TextStyle(fontSize: 16.0, color: Color(0xFF4A4A4A))),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}