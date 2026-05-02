import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'database_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const GuardianApp());
}

// ==========================================
// 🌟 全域設定變數
// ==========================================
class GlobalSettings {
  static double stepGoal = 4000;
  static double screenLimit = 7.0; 
  static double sleepMin = 6.0;
  static double sleepMax = 9.0;
}

class GuardianApp extends StatelessWidget {
  const GuardianApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '不吵人的守護者',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFF4F6F9),
        dividerColor: Colors.transparent, 
      ),
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ==========================================
// 🌟 專屬排版元件：解決字體忽大忽小的問題
// ==========================================
class FormattedValueRow extends StatelessWidget {
  final String val1;
  final String unit1;
  final String? val2;
  final String? unit2;

  const FormattedValueRow({
    super.key,
    required this.val1,
    required this.unit1,
    this.val2,
    this.unit2,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(val1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.black87)),
        if (unit1.isNotEmpty) const SizedBox(width: 4),
        if (unit1.isNotEmpty) Text(unit1, style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
        if (val2 != null && val2!.isNotEmpty) ...[
          const SizedBox(width: 8),
          Text(val2!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 32, color: Colors.black87)),
          if (unit2 != null && unit2!.isNotEmpty) const SizedBox(width: 4),
          if (unit2 != null && unit2!.isNotEmpty) Text(unit2!, style: const TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
        ]
      ],
    );
  }
}

// ==========================================
// 🌟 側邊抽屜選單 (Drawer)
// ==========================================
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF673AB7), Colors.indigo],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: const [
                Icon(Icons.spa_rounded, color: Colors.white, size: 40),
                SizedBox(height: 10),
                Text('進階心理守護', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                Text('更多專業諮商與評測功能', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.assignment_rounded, color: Colors.indigo),
            title: const Text('柯氏憂鬱量表', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('定期心理狀態評測'),
            trailing: Chip(
              label: const Text('即將推出', style: TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: Colors.indigo.shade300,
              padding: EdgeInsets.zero,
            ),
            onTap: () {
              Navigator.pop(context); 
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('柯氏憂鬱量表功能開發中...'), behavior: SnackBarBehavior.floating));
            },
          ),
          ListTile(
            leading: const Icon(Icons.event_available_rounded, color: Colors.indigo),
            title: const Text('諮商預約', style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('與心理師對話'),
            trailing: Chip(
              label: const Text('即將推出', style: TextStyle(fontSize: 10, color: Colors.white)),
              backgroundColor: Colors.indigo.shade300,
              padding: EdgeInsets.zero,
            ),
            onTap: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('諮商預約功能開發中...'), behavior: SnackBarBehavior.floating));
            },
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🌟 主導航控制中樞
// ==========================================
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  Widget _getCurrentPage() {
    switch (_currentIndex) {
      case 0: return const HomePage();
      case 1: return const AnalysisPage();
      case 2: return const HistoryListPage();
      case 3: return const SettingsPage();
      case 4: return const AboutPage();
      default: return const HomePage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _getCurrentPage(), 
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -5)),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF673AB7),
          unselectedItemColor: Colors.grey.shade400,
          type: BottomNavigationBarType.fixed, 
          selectedFontSize: 11,
          unselectedFontSize: 11,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.home_rounded, size: 24)), label: '首頁'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.bar_chart_rounded, size: 24)), label: '圖表'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.list_alt_rounded, size: 24)), label: '紀錄'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.settings_rounded, size: 24)), label: '設定'),
            BottomNavigationBarItem(icon: Padding(padding: EdgeInsets.only(bottom: 4), child: Icon(Icons.info_outline_rounded, size: 24)), label: '關於'),
          ],
        ),
      ),
    );
  }
}

// ==========================================
// 🌟 1. 今日摘要首頁
// ==========================================
class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int steps = 0;
  int screenTimeMinutes = 0;
  double sleepHours = 0.0;
  DateTime simulationDate = DateTime.now();
  final Random _random = Random();

  final List<String> _quotes = [
    "無論世界多吵雜，這裡永遠有你的安靜角落。",
    "休息不是浪費時間，是為了走更長遠的路。",
    "聽聽自己的呼吸聲，感受當下的平靜。",
    "今天的你，已經做得很棒了。",
    "試著放下手機 10 分鐘，去看看窗外的天空吧。"
  ];

  @override
  void initState() {
    super.initState();
    _loadRecentData();
  }

  void _loadRecentData() async {
    final data = await DatabaseHelper.instance.readAllRecords();
    if (data.isNotEmpty) {
      final latest = data.last; 
      if (mounted) {
        setState(() {
          steps = latest['steps'];
          screenTimeMinutes = latest['screen_time'];
          sleepHours = latest['sleep_time'];
          List<String> dateParts = latest['date'].split(' ')[0].split('/');
          simulationDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2])).subtract(const Duration(days: 1));
        });
      }
    } else {
      setState(() {
        steps = GlobalSettings.stepGoal.toInt();
        screenTimeMinutes = (GlobalSettings.screenLimit * 60 * 0.8).toInt();
        sleepHours = (GlobalSettings.sleepMin + GlobalSettings.sleepMax) / 2;
      });
    }
  }

  String _getInsight() {
    List<String> insights = [];
    if (steps < GlobalSettings.stepGoal) {
      insights.add("🚶‍♂️ 步數未達標，找個時間活動一下喔！");
    }
    if (screenTimeMinutes >= (GlobalSettings.screenLimit * 60)) {
      insights.add("📱 螢幕時間偏高，讓眼睛休息一下。");
    }
    if (sleepHours < GlobalSettings.sleepMin) {
      insights.add("🛏️ 昨晚睡得較少，今晚早點休息吧。");
    }
    return insights.isEmpty ? "✨ 狀態非常理想，請繼續保持！" : insights.join("\n\n");
  }

  void _showTopNotification(BuildContext context, String message) {
    OverlayState? overlayState = Overlay.of(context);
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0, left: 16.0, right: 16.0,
        child: Material(
          color: Colors.transparent,
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeOutCubic,
            tween: Tween<Offset>(begin: const Offset(0, -1), end: const Offset(0, 0)),
            builder: (context, Offset offset, child) => FractionalTranslation(translation: offset, child: child),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.96), borderRadius: BorderRadius.circular(20), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 15, offset: Offset(0, 5))]),
              child: Row(
                children: [
                  const Icon(Icons.spa_rounded, color: Colors.indigo, size: 24),
                  const SizedBox(width: 16),
                  Expanded(child: Text(message, style: const TextStyle(fontSize: 14, height: 1.4, color: Colors.black87, fontWeight: FontWeight.w500))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    overlayState.insert(overlayEntry);
    Future.delayed(const Duration(seconds: 5), () => overlayEntry.remove());
  }

  void _simulateAndSave() async {
    bool forceAnomaly = _random.nextDouble() < 0.35; 
    int newSteps; int newScreenMinutes; double newSleep;
    if (forceAnomaly) {
      newSteps = (GlobalSettings.stepGoal * 0.4).toInt() + _random.nextInt(1000); 
      newScreenMinutes = (GlobalSettings.screenLimit * 60).toInt() + 60; 
      newSleep = GlobalSettings.sleepMin - 1.5;
    } else {
      newSteps = GlobalSettings.stepGoal.toInt() + 1000;       
      newScreenMinutes = (GlobalSettings.screenLimit * 60 * 0.6).toInt(); 
      newSleep = (GlobalSettings.sleepMin + GlobalSettings.sleepMax) / 2;
    }
    await DatabaseHelper.instance.insertRecord({
      'date': "${simulationDate.year}/${simulationDate.month.toString().padLeft(2, '0')}/${simulationDate.day.toString().padLeft(2, '0')} 10:00",
      'steps': newSteps, 'screen_time': newScreenMinutes, 'sleep_time': double.parse(newSleep.toStringAsFixed(1)),
    });
    setState(() {
      simulationDate = simulationDate.subtract(const Duration(days: 1));
      steps = newSteps; screenTimeMinutes = newScreenMinutes; sleepHours = double.parse(newSleep.toStringAsFixed(1));
    });
    if (forceAnomaly) _showTopNotification(context, _getInsight().replaceAll("\n\n", " "));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(title: const Text('不吵人的守護者', style: TextStyle(color: Color(0xFF673AB7), fontWeight: FontWeight.bold, fontSize: 24)), backgroundColor: Colors.transparent, elevation: 0, iconTheme: const IconThemeData(color: Color(0xFF673AB7))),
      body: SingleChildScrollView( 
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("哈囉，晚安", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
                  const SizedBox(height: 5),
                  Text(_quotes[_random.nextInt(_quotes.length)], style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            
            // 🌟 使用新的 FormattedValueRow 解決字體忽大忽小的問題
            _buildSummaryCard(
              title: '步行',
              valueWidget: FormattedValueRow(val1: '$steps', unit1: '步'), 
              icon: Icons.local_fire_department, color: Colors.orange, liveValue: steps, goalValue: GlobalSettings.stepGoal, goalText: '${GlobalSettings.stepGoal.toInt()}'
            ),
            _buildSummaryCard(
              title: '螢幕使用時間',
              valueWidget: FormattedValueRow(val1: '${screenTimeMinutes ~/ 60}', unit1: '時', val2: '${screenTimeMinutes % 60}', unit2: '分'), 
              icon: Icons.smartphone, color: Colors.blue, liveValue: screenTimeMinutes, goalValue: GlobalSettings.screenLimit * 60, goalText: '${GlobalSettings.screenLimit.toInt()}時'
            ), 
            _buildSummaryCard(
              title: '睡眠時間', 
              valueWidget: FormattedValueRow(val1: sleepHours.toStringAsFixed(1), unit1: '時'), 
              icon: Icons.bed, color: Colors.indigo, liveValue: sleepHours, goalValue: GlobalSettings.sleepMin, goalText: '${GlobalSettings.sleepMin.toInt()}時'
            ), 
            
            const SizedBox(height: 10),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: LinearGradient(colors: [Colors.indigo.shade400, Colors.indigo.shade700]), borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.indigo.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))]),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(children: [Icon(Icons.auto_awesome, color: Colors.white, size: 20), SizedBox(width: 8), Text("守護者洞察", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]),
                  const SizedBox(height: 16), 
                  Text(_getInsight(), style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.5)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('心情日誌功能開發中...'), behavior: SnackBarBehavior.floating)),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white24)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [Icon(Icons.edit_note_rounded, color: Colors.white70, size: 18), SizedBox(width: 8), Text("記錄今天的心情...", style: TextStyle(color: Colors.white70, fontSize: 12))],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 35),
            ElevatedButton(
              onPressed: _simulateAndSave,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF673AB7), minimumSize: const Size(double.infinity, 60), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 2),
              child: const Text('模擬狀態並儲存', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(height: 12),
            const Text('🧬 專題測試：將依照您目前的設定生成數據', style: TextStyle(color: Colors.grey, fontSize: 12)),
            const SizedBox(height: 40), 
          ],
        ),
      ),
    );
  }

  Widget _buildCircularProgress(Color color, num liveValue, num goalValue, String goalText) {
    double progress = (liveValue / goalValue).clamp(0.0, 1.0);
    return Column(
      children: [
        SizedBox(width: 72, height: 72, child: Stack(fit: StackFit.expand, children: [CircularProgressIndicator(value: 1.0, strokeWidth: 8, valueColor: AlwaysStoppedAnimation<Color>(color.withOpacity(0.15))), CircularProgressIndicator(value: progress, strokeWidth: 8, backgroundColor: Colors.transparent, valueColor: AlwaysStoppedAnimation<Color>(color), strokeCap: StrokeCap.round)])),
        const SizedBox(height: 10), 
        Text('目標: $goalText', style: const TextStyle(fontSize: 14, color: Colors.blueGrey, fontWeight: FontWeight.bold)), 
      ],
    );
  }

  Widget _buildSummaryCard({required String title, required Widget valueWidget, required IconData icon, required Color color, required num liveValue, required num goalValue, required String goalText}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Text(title, style: TextStyle(color: Colors.grey.shade800, fontWeight: FontWeight.bold, fontSize: 15))]),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.center, 
            children: [
              valueWidget, // 替換為我們寫好的精美排版 Widget
              _buildCircularProgress(color, liveValue, goalValue, goalText)
            ]
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🌟 2. 詳細數據分析頁 (同步修復圖表頁的字體問題)
// ==========================================
class AnalysisPage extends StatefulWidget {
  const AnalysisPage({super.key});
  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  List<Map<String, dynamic>> _recentRecords = [];
  int _selectedIndex = -1; 
  @override
  void initState() { super.initState(); _loadRecentData(); }
  void _loadRecentData() async {
    final data = await DatabaseHelper.instance.readAllRecords();
    Map<String, Map<String, dynamic>> uniqueDays = {};
    for (var r in data) { String dateOnly = r['date'].split(' ')[0]; if (!uniqueDays.containsKey(dateOnly)) uniqueDays[dateOnly] = r; }
    List<String> sortedDates = uniqueDays.keys.toList()..sort();
    List<String> last7Dates = sortedDates.reversed.take(7).toList().reversed.toList();
    setState(() { _recentRecords = last7Dates.map((date) => uniqueDays[date]!).toList(); });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), 
      appBar: AppBar(title: const Text('詳細數據分析', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: _recentRecords.isEmpty 
        ? const Center(child: Text('尚無數據分析，請先在首頁模擬資料', style: TextStyle(color: Colors.grey)))
        : GestureDetector(
            onTap: () => setState(() => _selectedIndex = -1),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildAnalysisChart('步行', '步', Colors.orange, 'steps'), const SizedBox(height: 20),
                  _buildAnalysisChart('螢幕使用時間', '小時', Colors.blue, 'screen_time'), const SizedBox(height: 20),
                  _buildAnalysisChart('睡眠時間', '小時', Colors.indigo, 'sleep_time'), const SizedBox(height: 40),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildAnalysisChart(String title, String defaultUnit, Color color, String key) {
    num displayValue = 0; String displayDate = "最近 7 日"; String labelText = "平均";
    if (_selectedIndex != -1 && _selectedIndex < _recentRecords.length) {
      displayValue = _recentRecords[_selectedIndex][key]; displayDate = _recentRecords[_selectedIndex]['date'].split(' ')[0].substring(5).replaceAll('-', '/'); labelText = "單日紀錄"; 
    } else {
      double sum = _recentRecords.fold(0.0, (prev, element) => prev + element[key]); displayValue = sum / _recentRecords.length;
    }
    
    // 🌟 圖表區也同步套用新的 FormattedValueRow 排版
    Widget valueWidget;
    if (key == 'sleep_time') { 
      valueWidget = FormattedValueRow(val1: displayValue.toStringAsFixed(1), unit1: defaultUnit); 
    } else if (key == 'screen_time') { 
      int mins = displayValue.round(); 
      valueWidget = FormattedValueRow(val1: '${mins ~/ 60}', unit1: '時', val2: '${mins % 60}', unit2: '分'); 
    } else { 
      valueWidget = FormattedValueRow(val1: displayValue.round().toString(), unit1: defaultUnit); 
    }

    return Container(
      padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)), Text(displayDate, style: const TextStyle(color: Colors.grey, fontSize: 12))]),
          const SizedBox(height: 4), Text(labelText, style: const TextStyle(color: Colors.blueGrey, fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 2),
          valueWidget, // 使用精美排版
          const SizedBox(height: 20),
          SizedBox(
            height: 140, 
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(_recentRecords.length, (index) {
                double val = _recentRecords[index][key].toDouble(); double maxVal = _recentRecords.map((e) => e[key]).reduce((a, b) => a > b ? a : b).toDouble(); double heightFactor = maxVal == 0 ? 0.1 : (val / maxVal).clamp(0.1, 1.0);
                return GestureDetector(
                  onTap: () => setState(() => _selectedIndex = index),
                  child: Container(color: Colors.transparent, child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [Container(width: 25, height: 90 * heightFactor, decoration: BoxDecoration(color: _selectedIndex == index ? color : color.withOpacity(0.4), borderRadius: BorderRadius.circular(6))), const SizedBox(height: 8), Text(_recentRecords[index]['date'].split(' ')[0].substring(5).replaceAll('-', '/'), style: const TextStyle(fontSize: 11, color: Colors.blueGrey, fontWeight: FontWeight.bold))])),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================
// 🌟 3. 歷史紀錄盒子
// ==========================================
class HistoryListPage extends StatefulWidget {
  const HistoryListPage({super.key});
  @override
  State<HistoryListPage> createState() => _HistoryListPageState();
}

class _HistoryListPageState extends State<HistoryListPage> {
  List<Map<String, dynamic>> _allRecords = [];
  @override
  void initState() { super.initState(); _loadData(); }
  void _loadData() async { final data = await DatabaseHelper.instance.readAllRecords(); setState(() { _allRecords = data; }); }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var r in _allRecords) { String key = "${r['date'].split('/')[0]}|${int.parse(r['date'].split('/')[1])}"; if (!grouped.containsKey(key)) grouped[key] = []; grouped[key]!.add(r); }
    final keys = grouped.keys.toList();
    return Scaffold(
      drawer: const AppDrawer(), 
      appBar: AppBar(title: const Text('歷史紀錄盒子', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black), actions: [IconButton(icon: const Icon(Icons.delete_sweep, color: Colors.redAccent), onPressed: () async { await DatabaseHelper.instance.deleteAllRecords(); _loadData(); })]),
      body: GridView.builder(
        padding: const EdgeInsets.all(16), gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 16, mainAxisSpacing: 16), itemCount: keys.length,
        itemBuilder: (context, index) {
          String year = keys[index].split('|')[0], month = keys[index].split('|')[1];
          return InkWell(
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => MonthDetailPage(year: year, month: month, records: grouped[keys[index]]!))),
            child: Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [const Icon(Icons.folder_rounded, color: Colors.indigo, size: 40), Text('$year年'), Text('$month月', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold))])),
          );
        },
      ),
    );
  }
}

class MonthDetailPage extends StatelessWidget {
  final String year, month; final List<Map<String, dynamic>> records;
  const MonthDetailPage({super.key, required this.year, required this.month, required this.records});

  void _showDailyChart(BuildContext context, Map<String, dynamic> record) {
    int steps = record['steps']; int screenMins = record['screen_time']; double sleepHours = record['sleep_time']; String date = record['date'].split(' ')[0].replaceAll('/', '-');
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(30))), padding: const EdgeInsets.only(top: 12, left: 24, right: 24, bottom: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(10))), const SizedBox(height: 24), Text('$date 數據快覽', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.blueGrey)), const SizedBox(height: 30),
              _buildHorizontalBar('步行', '$steps 步', steps / 10000, Colors.orange, Icons.local_fire_department), _buildHorizontalBar('螢幕', '${screenMins~/60}時${screenMins%60}分', screenMins / 480, Colors.blue, Icons.smartphone), _buildHorizontalBar('睡眠', '${sleepHours}時', sleepHours / 10, Colors.indigo, Icons.bed), 
            ],
          ),
        );
      }
    );
  }

  Widget _buildHorizontalBar(String title, String val, double ratio, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, size: 20, color: color), const SizedBox(width: 10), Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade700, fontSize: 16)), const Spacer(), Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18))]),
          const SizedBox(height: 10), ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: ratio.clamp(0.05, 1.0), minHeight: 14, backgroundColor: color.withOpacity(0.15), valueColor: AlwaysStoppedAnimation<Color>(color))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$year年 $month月 明細'), backgroundColor: Colors.white, iconTheme: const IconThemeData(color: Colors.black)),
      body: ListView.builder(
        padding: const EdgeInsets.all(16), itemCount: records.length,
        itemBuilder: (context, index) {
          final r = records[index]; int screenMins = r['screen_time']; String formattedScreen = '${screenMins ~/ 60}h${screenMins % 60}m';
          return Card(
            margin: const EdgeInsets.only(bottom: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: InkWell( 
              borderRadius: BorderRadius.circular(20), onTap: () => _showDailyChart(context, r),
              child: Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0xFFF0F4FF), child: Icon(Icons.calendar_month, color: Colors.indigo)), title: Text(r['date'].split(' ')[0], style: const TextStyle(fontWeight: FontWeight.bold)), subtitle: Padding(padding: const EdgeInsets.only(top: 6.0), child: Text('步數: ${r['steps']} | 螢幕: $formattedScreen | 睡眠: ${r['sleep_time']}h', style: const TextStyle(fontSize: 12))), trailing: const Icon(Icons.chevron_right, color: Colors.grey))),
            ),
          );
        },
      ),
    );
  }
}

// ==========================================
// 🌟 4. 個人化設定分頁
// ==========================================
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ 個人化黃金三角設定已更新！', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo,
        behavior: SnackBarBehavior.floating,
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), 
      appBar: AppBar(
        title: const Text('個人化設定', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('黃金三角閥值設定', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
          const SizedBox(height: 8),
          const Text('因為每個人的生理時鐘與生活型態不同，您可以自由調整觸發關心提醒的標準。首頁的數據指標與異常生成邏輯將同步連動。', style: TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 20),

          _buildSettingCard(
            title: '最低步行目標', icon: Icons.local_fire_department, color: Colors.orange, valueText: '${GlobalSettings.stepGoal.toInt()} 步',
            child: SliderTheme(data: SliderTheme.of(context).copyWith(activeTrackColor: Colors.orange, thumbColor: Colors.orange), child: Slider(value: GlobalSettings.stepGoal, min: 1000, max: 10000, divisions: 18, onChanged: (val) { setState(() { GlobalSettings.stepGoal = val; }); })),
          ),
          
          _buildSettingCard(
            title: '螢幕時間警示上限', icon: Icons.smartphone, color: Colors.blue, valueText: '${GlobalSettings.screenLimit.toInt()} 小時',
            child: SliderTheme(data: SliderTheme.of(context).copyWith(activeTrackColor: Colors.blue, thumbColor: Colors.blue), child: Slider(value: GlobalSettings.screenLimit, min: 2, max: 12, divisions: 10, onChanged: (val) { setState(() { GlobalSettings.screenLimit = val; }); })),
          ),

          _buildSettingCard(
            title: '理想睡眠區間', icon: Icons.bed, color: Colors.indigo, valueText: '${GlobalSettings.sleepMin.toInt()} ~ ${GlobalSettings.sleepMax.toInt()} 小時',
            child: SliderTheme(data: SliderTheme.of(context).copyWith(activeTrackColor: Colors.indigo, thumbColor: Colors.indigo), child: RangeSlider(values: RangeValues(GlobalSettings.sleepMin, GlobalSettings.sleepMax), min: 3, max: 12, divisions: 9, onChanged: (val) { setState(() { GlobalSettings.sleepMin = val.start; GlobalSettings.sleepMax = val.end; }); })),
          ),

          const SizedBox(height: 30),
          
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF673AB7), minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 2),
            child: const Text('儲存並套用設定', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSettingCard({required String title, required IconData icon, required Color color, required String valueText, required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 4))]),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 22), const SizedBox(width: 8), Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87)), const Spacer(), Text(valueText, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: color))]),
          const SizedBox(height: 10), child, 
        ],
      ),
    );
  }
}

// ==========================================
// 🌟 5. 關於頁面
// ==========================================
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(), 
      appBar: AppBar(title: const Text('關於守護者', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), backgroundColor: Colors.white, elevation: 0, iconTheme: const IconThemeData(color: Colors.black)),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Center(child: CircleAvatar(radius: 50, backgroundColor: Color(0xFFF0F4FF), child: Icon(Icons.spa_rounded, size: 60, color: Color(0xFF673AB7)))), const SizedBox(height: 20),
          const Center(child: Text('不吵人的守護者', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87))), const Center(child: Text('Version 1.0.0', style: TextStyle(color: Colors.grey))), const SizedBox(height: 40),
          const Text('設計理念', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(height: 12),
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]), child: const Text('在數位時代，我們每天產生大量的數據，但這些數據往往只是冷冰冰的數字。\n\n「不吵人的守護者」致力於無感收集您的日常健康數據，我們不會頻繁打擾您，只會在您的生活規律出現較大波動、真正需要關懷時，適時給予溫暖的提醒與陪伴。', style: TextStyle(fontSize: 15, height: 1.8, color: Colors.blueGrey))), const SizedBox(height: 30),
          const Text('專題團隊', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)), const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5))]),
            child: Column(children: [_buildTeamMemberRow(Icons.computer_rounded, '前端開發與 UI 規劃', '專案組員 A'), const Divider(height: 30), _buildTeamMemberRow(Icons.storage_rounded, '資料庫與演算法實作', '專案組員 B'), const Divider(height: 30), _buildTeamMemberRow(Icons.analytics_rounded, '商業邏輯與企劃', '專案組員 C')]),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildTeamMemberRow(IconData icon, String role, String name) {
    return Row(children: [Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFF0F4FF), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.indigo, size: 20)), const SizedBox(width: 16), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(role, style: const TextStyle(fontSize: 12, color: Colors.grey)), const SizedBox(height: 4), Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87))]))]);
  }
}