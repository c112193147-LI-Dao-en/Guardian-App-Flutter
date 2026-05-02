import 'package:flutter/material.dart';
import 'database_helper.dart';

class HistoryListPage extends StatefulWidget {
  const HistoryListPage({super.key});

  @override
  State<HistoryListPage> createState() => _HistoryListPageState();
}

class _HistoryListPageState extends State<HistoryListPage> {
  List<Map<String, dynamic>> _allRecords = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  // 負責將平鋪的資料分群：年份 -> 月份 -> 紀錄列表
  Map<String, Map<String, List<Map<String, dynamic>>>> _groupDataByYearAndMonth() {
    Map<String, Map<String, List<Map<String, dynamic>>>> grouped = {};

    for (var record in _allRecords) {
      String dbDate = record['date']; // 例如 "2026/04/24 13:30"
      String dateOnly = dbDate.split(' ')[0]; // "2026/04/24"
      List<String> parts = dateOnly.split('/');
      
      String year = "${parts[0]}年"; // "2026年"
      String month = "${int.parse(parts[1])}月"; // "4月" (int.parse 可以自動把 04 變 4)

      // 如果還沒有這個年份，就建立
      if (!grouped.containsKey(year)) {
        grouped[year] = {};
      }
      // 如果該年份下還沒有這個月份，就建立
      if (!grouped[year]!.containsKey(month)) {
        grouped[year]![month] = [];
      }
      
      // 把資料塞進對應的年月裡
      grouped[year]![month]!.add(record);
    }
    return grouped;
  }

  // 1. 從資料庫讀取所有紀錄
  Future<void> _loadAllData() async {
    final data = await DatabaseHelper.instance.readAllRecords();
    setState(() {
      // 將資料反轉，讓最新的紀錄顯示在最上面
      _allRecords = data.reversed.toList();
      _isLoading = false;
    });
  }

  // 2. 執行刪除動作並重新整理畫面
  void _deleteData() async {
    await DatabaseHelper.instance.deleteAllRecords();
    // 確保刪除動作完成後再重新抓取
    await Future.delayed(const Duration(milliseconds: 100));
    _loadAllData(); 
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🗑️ 所有歷史數據已完全清空'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  // 3. 刪除前的確認對話框
  void _showDeleteConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('清空所有紀錄？'),
        content: const Text('這將會刪除資料庫中所有的歷史紀錄，此操作無法復原。'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteData();
            },
            child: const Text('確定刪除', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  // 4. 格式化日期顯示
  String _formatDate(String isoString) {
    DateTime dt = DateTime.parse(isoString);
    return "${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')} ${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        title: const Text('歷史數據明細', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // 垃圾桶按鈕：如果沒資料就禁用 (null)
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.redAccent, size: 28),
            onPressed: _allRecords.isEmpty ? null : _showDeleteConfirmDialog,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _allRecords.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.inbox, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('目前尚無歷史紀錄', style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _allRecords.length,
                  itemBuilder: (context, index) {
                    final record = _allRecords[index];

                    // 數據單位轉換與格式化
                    double screenHours = (record['screen_time'] as num) / 60;
                    double sleepHours = (record['sleep_time'] as num).toDouble();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5, offset: const Offset(0, 2))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                              const SizedBox(width: 8),
                              Text(
                                _formatDate(record['date']), 
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey, fontSize: 14)
                              ),
                            ],
                          ),
                          const Divider(height: 24, thickness: 0.5),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildTableItem("步數", "${record['steps']}", Colors.deepOrange),
                              _buildTableItem("螢幕", "${screenHours.toStringAsFixed(1)}Hr", Colors.indigoAccent),
                              _buildTableItem("睡眠", "${sleepHours.toStringAsFixed(1)}h", Colors.deepPurpleAccent),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }

  // 輔助組件：建立數據單元格
  Widget _buildTableItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 6),
        Text(
          value, 
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)
        ),
      ],
    );
  }
}