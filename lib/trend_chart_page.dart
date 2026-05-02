import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'database_helper.dart';

class TrendChartPage extends StatefulWidget {
  const TrendChartPage({super.key});

  @override
  State<TrendChartPage> createState() => _TrendChartPageState();
}

class _TrendChartPageState extends State<TrendChartPage> {
  List<Map<String, dynamic>> _historyData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await DatabaseHelper.instance.readAllRecords();
    setState(() {
      _historyData = data.take(7).toList().reversed.toList();
      _isLoading = false;
    });
  }

  String getWeekdayString(int weekday) {
    const weekdays = ['週一', '週二', '週三', '週四', '週五', '週六', '週日'];
    return weekdays[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7), 
      appBar: AppBar(
        title: const Text('詳細數據分析', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _historyData.isEmpty
              ? const Center(child: Text('目前尚無數據，請先回首頁模擬存檔'))
              : ListView(
                  padding: const EdgeInsets.all(16.0),
                  children: [
                    _buildIosBarChartCard('步行', Colors.deepOrange, 'steps', '步'),
                    const SizedBox(height: 20),
                    _buildIosBarChartCard('螢幕使用時間', Colors.indigoAccent, 'screen_time', '分鐘'),
                    const SizedBox(height: 20),
                    _buildIosBarChartCard('睡眠總量', Colors.deepPurpleAccent, 'sleep_time', '小時'),
                  ],
                ),
    );
  }

  Widget _buildIosBarChartCard(String title, Color barColor, String dataKey, String unit) {
    double total = 0;
    for (var row in _historyData) {
      total += (row[dataKey] as num).toDouble();
    }
    double average = _historyData.isNotEmpty ? total / _historyData.length : 0;
    
    String dateRangeStr = "近 7 次紀錄";
    if (_historyData.isNotEmpty) {
      DateTime endDate = DateTime.now();
      DateTime startDate = endDate.subtract(Duration(days: _historyData.length - 1));
      dateRangeStr = "${startDate.year}年${startDate.month}月${startDate.day}日至${endDate.day}日";
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 15),
          const Text("平均", style: TextStyle(color: Colors.grey, fontSize: 14)),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                dataKey == 'steps' ? average.toInt().toString() : average.toStringAsFixed(1), 
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black)
              ),
              const SizedBox(width: 4),
              Padding(
                padding: const EdgeInsets.only(bottom: 6.0),
                child: Text(unit, style: const TextStyle(color: Colors.grey, fontSize: 14)),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(dateRangeStr, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 30),
          
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: dataKey == 'steps' ? 12000 : (dataKey == 'screen_time' ? 650 : 16), // 稍微拉高天花板，留空間給氣泡
                
                // 🌟 魔法在這裡：開啟觸控互動功能 🌟
                barTouchData: BarTouchData(
                  enabled: true, // 開啟觸控
                  touchTooltipData: BarTouchTooltipData(
                    getTooltipColor: (group) => Colors.black87, // 氣泡背景改為有質感的深黑色
                    getTooltipItem: (group, groupIndex, rod, rodIndex) {
                      // 取得原始數值
                      double value = rod.toY;
                      // 判斷是否需要小數點 (步數不用，螢幕/睡眠需要 1 位)
                      String displayValue = dataKey == 'steps' ? value.toInt().toString() : value.toStringAsFixed(1);
                      
                      return BarTooltipItem(
                        displayValue, // 大大的數字
                        const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                        children: <TextSpan>[
                          TextSpan(
                            text: ' $unit', // 數字後面接上單位
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.normal),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                
                titlesData: FlTitlesData(
                  show: true,
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (double value, TitleMeta meta) {
                        int index = value.toInt();
                        if (index >= 0 && index < _historyData.length) {
                           int daysAgo = (_historyData.length - 1) - index;
                           DateTime targetDate = DateTime.now().subtract(Duration(days: daysAgo));
                           return Padding(
                             padding: const EdgeInsets.only(top: 8.0),
                             child: Text(getWeekdayString(targetDate.weekday), style: const TextStyle(color: Colors.grey, fontSize: 12)),
                           );
                        }
                        return const Text('');
                      },
                      reservedSize: 30,
                    ),
                  ),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: dataKey == 'steps' ? 5000 : (dataKey == 'screen_time' ? 300 : 5),
                  getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.withOpacity(0.2), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                
                barGroups: List.generate(_historyData.length, (index) {
                  return BarChartGroupData(
                    x: index,
                    barRods: [
                      BarChartRodData(
                        toY: (_historyData[index][dataKey] as num).toDouble(),
                        color: barColor,
                        width: 25,
                        borderRadius: const BorderRadius.only(topLeft: Radius.circular(4), topRight: Radius.circular(4)),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}