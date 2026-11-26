import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart' as intl;

void main() {
  runApp(const AlnoorAlfatimiApp());
}

class AlnoorAlfatimiApp extends StatefulWidget {
  const AlnoorAlfatimiApp({super.key});

  @override
  State<AlnoorAlfatimiApp> createState() => _AlnoorAlfatimiAppState();
}

class _AlnoorAlfatimiAppState extends State<AlnoorAlfatimiApp> {
  int themeIndex = 0;
  double fontSize = 20.0;
  double speechRate = 0.48;
  String selectedCity = 'صنعاء';

  final List themePalettes = [
    {
      'name': 'الأخضر الزمرّدي الملكي',
      'bg': const Color(0xFF071E18),
      'card': const Color(0xFF0E3329),
      'accent': const Color(0xFFD4AF37),
      'text': Colors.white,
      'isDark': true,
    },
    {
      'name': 'الكحلي الفاطمي الليلي',
      'bg': const Color(0xFF0A1428),
      'card': const Color(0xFF132445),
      'accent': const Color(0xFFE5C158),
      'text': Colors.white,
      'isDark': true,
    },
    {
      'name': 'الأسود الفاخر والذهبي',
      'bg': const Color(0xFF101012),
      'card': const Color(0xFF1D1D22),
      'accent': const Color(0xFFD4AF37),
      'text': Colors.white,
      'isDark': true,
    },
    {
      'name': 'النهاري العاجي الهادئ',
      'bg': const Color(0xFFF6F4EE),
      'card': Colors.white,
      'accent': const Color(0xFF0F4C3A),
      'text': const Color(0xFF1A1A1A),
      'isDark': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      themeIndex = prefs.getInt('themeIndex') ?? 0;
      fontSize = prefs.getDouble('fontSize') ?? 20.0;
      speechRate = prefs.getDouble('speechRate') ?? 0.48;
      selectedCity = prefs.getString('selectedCity') ?? 'صنعاء';
    });
  }

  Future<void> _updateSettings({int? t, double? f, double? s, String? c}) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (t != null) {
        themeIndex = t;
        prefs.setInt('themeIndex', t);
      }
      if (f != null) {
        fontSize = f;
        prefs.setDouble('fontSize', f);
      }
      if (s != null) {
        speechRate = s;
        prefs.setDouble('speechRate', s);
      }
      if (c != null) {
        selectedCity = c;
        prefs.setString('selectedCity', c);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final palette = themePalettes[themeIndex];
    return MaterialApp(
      title: 'النور الفاطمي',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: palette['isDark'] ? Brightness.dark : Brightness.light,
        scaffoldBackgroundColor: palette['bg'],
        colorSchemeSeed: palette['accent'],
      ),
      home: Directionality(
        textDirection: TextDirection.rtl,
        child: MainDashboard(
          palette: palette,
          themePalettes: themePalettes,
          themeIndex: themeIndex,
          fontSize: fontSize,
          speechRate: speechRate,
          selectedCity: selectedCity,
          onUpdateSettings: _updateSettings,
        ),
      ),
    );
  }
}

class MainDashboard extends StatefulWidget {
  final Map palette;
  final List themePalettes;
  final int themeIndex;
  final double fontSize;
  final double speechRate;
  final String selectedCity;
  final Function({int? t, double? f, double? s, String? c}) onUpdateSettings;

  const MainDashboard({
    super.key,
    required this.palette,
    required this.themePalettes,
    required this.themeIndex,
    required this.fontSize,
    required this.speechRate,
    required this.selectedCity,
    required this.onUpdateSettings,
  });

  @override
  State<MainDashboard> createState() => _MainDashboardState();
}

class _MainDashboardState extends State<MainDashboard> {
  final FlutterTts tts = FlutterTts();
  late Timer _timer;
  DateTime _now = DateTime.now();

  final Map cityCoords = {
    'صنعاء': {'lat': 15.3694, 'lng': 44.1910, 'tz': 3.0},
    'إب': {'lat': 13.9667, 'lng': 44.1833, 'tz': 3.0},
    'حراز': {'lat': 15.0833, 'lng': 43.7333, 'tz': 3.0},
    'عدن': {'lat': 12.7855, 'lng': 45.0187, 'tz': 3.0},
    'تعز': {'lat': 13.5795, 'lng': 44.0209, 'tz': 3.0},
    'نجران': {'lat': 17.4933, 'lng': 44.1277, 'tz': 3.0},
    'مكة المكرمة': {'lat': 21.3891, 'lng': 39.8579, 'tz': 3.0},
  };

  @override
  void initState() {
    super.initState();
    _initTts();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() => _now = DateTime.now());
    });
  }

  Future<void> _initTts() async {
    await tts.setLanguage('ar');
    await tts.setSpeechRate(widget.speechRate);
    await tts.setPitch(1.0);
  }

  Future<void> _speak(String text) async {
    await tts.stop();
    await tts.setLanguage('ar');
    await tts.setSpeechRate(widget.speechRate);
    await tts.speak(text);
  }

  @override
  void dispose() {
    _timer.cancel();
    tts.stop();
    super.dispose();
  }

  String _getFatimidDate(DateTime date) {
    int y = date.year;
    int m = date.month;
    int d = date.day;
    if (m < 3) {
      y -= 1;
      m += 12;
    }
    int a = (y / 100).floor();
    int b = 2 - a + (a / 4).floor();
    int jd = (365.25 * (y + 4716)).floor() + (30.6001 * (m + 1)).floor() + d + b - 1524;

    int l = jd - 1948440 + 10632;
    int n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    int j = (((10985 - l) / 5316).floor()) * (((50 * l) / 17719).floor()) +
        ((l / 5670).floor()) * (((43 * l) / 15238).floor());
    l = l - (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
        ((j / 16).floor()) * (((15238 * j) / 43).floor()) + 29;
    int hMonth = ((24 * l) / 709).floor();
    int hDay = l - ((709 * hMonth) / 24).floor();
    int hYear = 30 * n + j - 30;

    const months = [
      '', 'محرم الحرام', 'صفر الخير', 'ربيع الأول', 'ربيع الآخر',
      'جمادى الأولى', 'جمادى الآخرة', 'رجب الأصب', 'شعبان المعظم',
      'شهر رمضان', 'شوال المكرم', 'ذو القعدة', 'ذو الحجة'
    ];
    return '$hDay ${months[hMonth]} $hYear هـ (التقويم الفاطمي)';
  }

  Map _calculatePrayerTimes(DateTime date, String city) {
    final c = cityCoords[city] ?? cityCoords['صنعاء']!;
    double lat = c['lat'];
    double lng = c['lng'];
    double tz = c['tz'];

    int dayOfYear = date.difference(DateTime(date.year, 1, 1)).inDays + 1;
    double decl = 23.44 * sin((2 * pi / 365.0) * (dayOfYear - 81)) * pi / 180.0;
    double latRad = lat * pi / 180.0;

    double eqTime = 9.87 * sin(2 * (2 * pi / 365.0) * (dayOfYear - 81)) -
        7.53 * cos((2 * pi / 365.0) * (dayOfYear - 81)) -
        1.5 * sin((2 * pi / 365.0) * (dayOfYear - 81));

    double solarNoon = 12.0 + tz - (lng / 15.0) - (eqTime / 60.0);

    double hourAngle(double angleDeg) {
      double angleRad = angleDeg * pi / 180.0;
      double cosH = (sin(angleRad) - sin(latRad) * sin(decl)) / (cos(latRad) * cos(decl));
      cosH = cosH.clamp(-1.0, 1.0);
      return (acos(cosH) * 180.0 / pi) / 15.0;
    }

    double fajr = solarNoon - hourAngle(-18.0);
    double dhuhr = solarNoon + 0.05;
    double asrShadow = 1.0 + tan((latRad - decl).abs());
    double asrAngle = atan(1.0 / asrShadow) * 180.0 / pi;
    double asr = solarNoon + hourAngle(asrAngle);
    double maghrib = solarNoon + hourAngle(-0.833) + 0.05;
    double isha = solarNoon + hourAngle(-17.5);

    String fmt(double h) {
      int hrs = h.floor() % 24;
      int mins = ((h - h.floor()) * 60).round() % 60;
      String period = hrs >= 12 ? 'م' : 'ص';
      int h12 = hrs % 12 == 0 ? 12 : hrs % 12;
      return '${h12.toString().padLeft(2, '0')}:${mins.toString().padLeft(2, '0')} $period';
    }

    return {
      'الفجر': fmt(fajr),
      'الظهر': fmt(dhuhr),
      'العصر': fmt(asr),
      'المغرب': fmt(maghrib),
      'العشاء': fmt(isha),
    };
  }

  void _showDonationDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: widget.palette['card'],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: BorderSide(color: widget.palette['accent'], width: 1.5),
          ),
          title: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 30),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'دعم ونشر النور الفاطمي',
                  style: TextStyle(color: widget.palette['accent'], fontWeight: FontWeight.bold, fontSize: 19),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تبرّع وساعد لنشر تطبيق (النور الفاطمي) لينتشر بين أيدي أصحاب الدعوة الإسماعيلية في كل مكان، ويكون لك صدقة جارية وأجراً متصلاً بإذن الله.',
                style: TextStyle(color: widget.palette['text'], fontSize: 16, height: 1.6),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: widget.palette['accent'].withOpacity(0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: widget.palette['accent']),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'طرق التبرع:',
                      style: TextStyle(color: widget.palette['accent'], fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'تواصل مع المطور لإتمام عملية التبرع
(أ. م. محمد عبدالواحد الهمداني)',
                      style: TextStyle(color: widget.palette['text'], fontSize: 15, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.palette['accent'],
                foregroundColor: Colors.black,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('جزاك الله خيراً', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _playAdhanDialog() {
    const adhanText = 'الله أكبر، الله أكبر، الله أكبر، الله أكبر. أشهد أن لا إله إلا الله، أشهد أن لا إله إلا الله. أشهد أن محمداً رسول الله، أشهد أن محمداً رسول الله. أشهد أن علياً ولي الله، أشهد أن علياً ولي الله. حي على الصلاة، حي على الصلاة. حي على الفلاح، حي على الفلاح. حي على خير العمل، حي على خير العمل. الله أكبر، الله أكبر. لا إله إلا الله.';
    _speak(adhanText);
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: widget.palette['card'],
          title: Text('الأذان المبارك', style: TextStyle(color: widget.palette['accent'], fontWeight: FontWeight.bold)),
          content: Text(adhanText, style: TextStyle(color: widget.palette['text'], fontSize: 17, height: 1.7)),
          actions: [
            TextButton(
              onPressed: () {
                tts.stop();
                Navigator.pop(ctx);
              },
              child: const Text('إيقاف وإغلاق', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    final prayers = _calculatePrayerTimes(_now, widget.selectedCity);
    final timeStr = intl.DateFormat('hh:mm:ss a').format(_now);
    final gregStr = intl.DateFormat('yyyy / MM / dd').format(_now);
    final fatimidStr = _getFatimidDate(_now);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    tooltip: 'دعم ونشر التطبيق',
                    onPressed: _showDonationDialog,
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.redAccent.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.redAccent, width: 1.5),
                      ),
                      child: const Icon(Icons.favorite_rounded, color: Colors.redAccent, size: 26),
                    ),
                  ),
                  Column(
                    children: [
                      Text(
                        'النور الفاطمي',
                        style: TextStyle(color: p['accent'], fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'إعداد: أ. م. محمد عبدالواحد الهمداني',
                        style: TextStyle(color: p['text'].withOpacity(0.85), fontSize: 13),
                      ),
                    ],
                  ),
                  IconButton(
                    tooltip: 'الإعدادات',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => Directionality(
                            textDirection: TextDirection.rtl,
                            child: SettingsScreen(
                              palette: p,
                              themePalettes: widget.themePalettes,
                              themeIndex: widget.themeIndex,
                              fontSize: widget.fontSize,
                              speechRate: widget.speechRate,
                              selectedCity: widget.selectedCity,
                              cities: cityCoords.keys.toList(),
                              onUpdate: widget.onUpdateSettings,
                            ),
                          ),
                        ),
                      );
                    },
                    icon: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: p['accent'].withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: p['accent'], width: 1.5),
                      ),
                      child: Icon(Icons.settings_rounded, color: p['accent'], size: 26),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [p['card'], p['accent'].withOpacity(0.22), p['card']],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p['accent'], width: 1.6),
                ),
                child: Column(
                  children: [
                    Text(
                      'أصحاب الكساء الخمسة عليهم السلام',
                      style: TextStyle(color: p['accent'], fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'مُحَمَّد  •  عَلِيّ  •  فَاطِمَة  •  الْحَسَن  •  الْحُسَيْن',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: p['text'],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: p['card'],
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: p['accent'].withOpacity(0.5)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.location_on_rounded, color: p['accent'], size: 20),
                            const SizedBox(width: 4),
                            Text(widget.selectedCity, style: TextStyle(color: p['accent'], fontWeight: FontWeight.bold, fontSize: 16)),
                          ],
                        ),
                        Text(timeStr, style: TextStyle(color: p['text'], fontSize: 19, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const Divider(height: 18),
                    Text(
                      fatimidStr,
                      style: TextStyle(color: p['accent'], fontSize: 17, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'الميلادي: $gregStr م',
                      style: TextStyle(color: p['text'].withOpacity(0.75), fontSize: 13),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: prayers.entries.map((e) {
                        return Column(
                          children: [
                            Text(e.key, style: TextStyle(color: p['accent'], fontSize: 13, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(e.value, style: TextStyle(color: p['text'], fontSize: 12, fontWeight: FontWeight.w600)),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: p['accent'],
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: _playAdhanDialog,
                        icon: const Icon(Icons.volume_up_rounded),
                        label: const Text('استماع للأذان (حي على خير العمل)', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.08,
                children: [
                  _modernTile(
                    icon: Icons.menu_book_rounded,
                    title: 'القرآن الكريم',
                    sub: '114 سورة + مساعد الحفظ',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: QuranIndexScreen(palette: p, fontSize: widget.fontSize, onSpeak: _speak),
                        ),
                      ),
                    ),
                  ),
                  _modernTile(
                    icon: Icons.volunteer_activism_rounded,
                    title: 'أدعية الإمام علي',
                    sub: 'نهج البلاغة والمأثورات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: ImamAliDuasScreen(palette: p, fontSize: widget.fontSize, onSpeak: _speak),
                        ),
                      ),
                    ),
                  ),
                  _modernTile(
                    icon: Icons.auto_awesome_rounded,
                    title: 'ثقّف نفسك',
                    sub: 'حب آل البيت وولاية علي',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: EducateYourselfScreen(palette: p, fontSize: widget.fontSize, onSpeak: _speak),
                        ),
                      ),
                    ),
                  ),
                  _modernTile(
                    icon: Icons.fingerprint_rounded,
                    title: 'السبحة والأذكار',
                    sub: 'تسبيحة الزهراء والتنبيهات',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: TasbihAndAdhkarScreen(palette: p, fontSize: widget.fontSize, onSpeak: _speak),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modernTile({required IconData icon, required String title, required String sub, required VoidCallback onTap}) {
    final p = widget.palette;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: p['card'],
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: p['accent'].withOpacity(0.65), width: 1.4),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.25), blurRadius: 8, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: p['accent'].withOpacity(0.18),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: p['accent'], size: 34),
            ),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(color: p['text'], fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(sub, textAlign: TextAlign.center, style: TextStyle(color: p['accent'], fontSize: 12)),
          ],
        ),
      ),
    );
  }
}

class QuranIndexScreen extends StatefulWidget {
  final Map palette;
  final double fontSize;
  final Function(String) onSpeak;

  const QuranIndexScreen({super.key, required this.palette, required this.fontSize, required this.onSpeak});

  @override
  State<QuranIndexScreen> createState() => _QuranIndexScreenState();
}

class _QuranIndexScreenState extends State<QuranIndexScreen> {
  List surahs = [];
  List filtered = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadQuran();
  }

  Future<void> _loadQuran() async {
    final raw = await rootBundle.loadString('assets/quran.json');
    final data = List.from(jsonDecode(raw));
    setState(() {
      surahs = data;
      filtered = data;
      loading = false;
    });
  }

  void _search(String q) {
    setState(() {
      filtered = surahs.where((s) => s['name'].toString().contains(q) || s['id'].toString() == q).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: p['card'],
        title: Text('القرآن الكريم (114 سورة)', style: TextStyle(color: p['accent'], fontWeight: FontWeight.bold)),
      ),
      body: loading
          ? Center(child: CircularProgressIndicator(color: p['accent']))
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    onChanged: _search,
                    decoration: InputDecoration(
                      hintText: 'ابحث باسم السورة أو رقمها...',
                      prefixIcon: Icon(Icons.search, color: p['accent']),
                      filled: true,
                      fillColor: p['card'],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (ctx, i) {
                      final s = filtered[i];
                      return Card(
                        color: p['card'],
                        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: p['accent'],
                            child: Text('${s['id']}', style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                          ),
                          title: Text('سورة ${s['name']}', style: TextStyle(color: p['text'], fontSize: 18, fontWeight: FontWeight.bold)),
                          subtitle: Text('عدد الآيات: ${s['total_verses']} • ${s['type'] == 'meccan' ? 'مكية' : 'مدنية'}',
                              style: TextStyle(color: p['accent'], fontSize: 13)),
                          trailing: Icon(Icons.arrow_forward_ios_rounded, color: p['accent'], size: 18),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => Directionality(
                                textDirection: TextDirection.rtl,
                                child: SurahReaderScreen(
                                  surah: s,
                                  palette: p,
                                  fontSize: widget.fontSize,
                                  onSpeak: widget.onSpeak,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class SurahReaderScreen extends StatefulWidget {
  final Map surah;
  final Map palette;
  final double fontSize;
  final Function(String) onSpeak;

  const SurahReaderScreen({super.key, required this.surah, required this.palette, required this.fontSize, required this.onSpeak});

  @override
  State<SurahReaderScreen> createState() => _SurahReaderScreenState();
}

class _SurahReaderScreenState extends State<SurahReaderScreen> {
  bool memorizationMode = false;
  Set revealedVerses = {};

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    List verses = widget.surah['verses'] ?? [];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: p['card'],
        title: Text('سورة ${widget.surah['name']}', style: TextStyle(color: p['accent'], fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            tooltip: 'مساعد الحفظ (إخفاء/إظهار الآيات)',
            icon: Icon(memorizationMode ? Icons.visibility_off_rounded : Icons.psychology_rounded, color: p['accent']),
            onPressed: () {
              setState(() {
                memorizationMode = !memorizationMode;
                revealedVerses.clear();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (memorizationMode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              color: p['accent'].withOpacity(0.2),
              child: Text(
                'وضع مساعد الحفظ مفعّل: سمّع الآية ثم المسها للتحقق من حفظك!',
                textAlign: TextAlign.center,
                style: TextStyle(color: p['accent'], fontWeight: FontWeight.bold),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(14),
              itemCount: verses.length,
              itemBuilder: (ctx, idx) {
                final v = verses[idx];
                int vId = v['id'];
                bool isHidden = memorizationMode && !revealedVerses.contains(vId);

                return InkWell(
                  onTap: () {
                    if (memorizationMode) {
                      setState(() {
                        if (revealedVerses.contains(vId)) {
                          revealedVerses.remove(vId);
                        } else {
                          revealedVerses.add(vId);
                        }
                      });
                    }
                  },
                  child: Card(
                    color: p['card'],
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            isHidden ? '﴿ الآية رقم $vId — المس هنا لإظهار النص والتحقق ﴾' : '${v['text']} ﴿$vId﴾',
                            style: TextStyle(
                              color: isHidden ? p['accent'] : p['text'],
                              fontSize: widget.fontSize + 2,
                              height: 1.8,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              icon: Icon(Icons.volume_up_rounded, color: p['accent']),
                              onPressed: () => widget.onSpeak(v['text']),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class ImamAliDuasScreen extends StatelessWidget {
  final Map palette;
  final double fontSize;
  final Function(String) onSpeak;

  const ImamAliDuasScreen({super.key, required this.palette, required this.fontSize, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final List duas = [
      {
        'title': 'دعاء التمجيد والتوحيد (من نهج البلاغة)',
        'text': 'الْحَمْدُ لِلَّهِ الَّذِي لَا يَبْلُغُ مِدْحَتَهُ الْقَائِلُونَ، وَلَا يُحْصِي نَعْمَاءَهُ الْعَادُّونَ، وَلَا يُؤَدِّي حَقَّهُ الْمُجْتَهِدُونَ، الَّذِي لَا يُدْرِكُهُ بُعْدُ الْهِمَمِ، وَلَا يَنَالُهُ غَوْصُ الْفِطَنِ.',
      },
      {
        'title': 'دعاء الصباح لأمير المؤمنين (عليه السلام)',
        'text': 'اللَّهُمَّ يَا مَنْ دَلَعَ لِسَانَ الصَّبَاحِ بِنُطْقِ تَبَلُّجِهِ، وَسَرَّحَ قِطَعَ اللَّيْلِ الْمُظْلِمِ بِغَيَاهِبِ تَلَجْلُجِهِ، وَأَتْقَنَ صُنْعَ الْفَلَكِ الدَّوَّارِ فِي مَقَادِيرِ تَبَرُّجِهِ، صَلِّ عَلَى مُحَمَّدٍ وَآلِ مُحَمَّدٍ وَافْتَحْ لَنَا أَبْوَابَ رَحْمَتِكَ.',
      },
      {
        'title': 'دعاء الاستغفار الجامع (من نهج البلاغة)',
        'text': 'اللَّهُمَّ إِنِّي أَسْتَغْفِرُكَ لِكُلِّ ذَنْبٍ تُبْتُ إِلَيْكَ مِنْهُ ثُمَّ عُدْتُ فِيهِ، وَأَسْتَغْفِرُكَ لِكُلِّ مَا وَعَدْتُكَ بِهِ مِنْ نَفْسِي ثُمَّ لَمْ أُوفِ لَكَ بِهِ، وَأَسْتَغْفِرُكَ لِكُلِّ نِعْمَةٍ أَنْعَمْتَ بِهَا عَلَيَّ فَقَوِيتُ بِهَا عَلَى مَعْصِيَتِكَ.',
      },
      {
        'title': 'دعاء قضاء الحوائج وتفريج الكروب',
        'text': 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَآلِ مُحَمَّدٍ، يَا كَافِيَ الْفَرْدِ الضَّعِيفِ، وَوَاقِيَ الْأَمْرِ الْمَخُوفِ، أَفْرِدْنِي لِطَاعَتِكَ، وَاجْعَلْ لِي مِنْ كُلِّ هَمٍّ وَغَمٍّ فَرَجاً وَمَخْرَجاً بِرَحْمَتِكَ يَا أَرْحَمَ الرَّاحِمِينَ.',
      },
      {
        'title': 'دعاء طلب العلم والحكمة (نهج البلاغة)',
        'text': 'اللَّهُمَّ اجْعَلْ نَفْسِي أَوَّلَ كَرِيمَةٍ تَنْتَزِعُهَا مِنْ كَرَائِمِي، وَأَوَّلَ وَدِيعَةٍ تَرْتَجِعُهَا مِنْ وَدَائِعِ نِعَمِكَ عِنْدِي، وَارْزُقْنِي عَقْلاً كَامِلاً وَلُبّاً رَاجِحاً وَقَلْباً زَكِيّاً وَعِلْماً نَافِعاً.',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: p['card'],
        title: Text('أدعية الإمام علي (عليه السلام)', style: TextStyle(color: p['accent'], fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: duas.length,
        itemBuilder: (ctx, i) {
          final d = duas[i];
          return Card(
            color: p['card'],
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: p['accent'].withOpacity(0.5)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(d['title'], style: TextStyle(color: p['accent'], fontSize: 17, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Text(d['text'], style: TextStyle(color: p['text'], fontSize: fontSize, height: 1.8)),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: p['accent'], foregroundColor: Colors.black),
                    onPressed: () => onSpeak(d['text']),
                    icon: const Icon(Icons.volume_up_rounded),
                    label: const Text('استماع للدعاء', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class EducateYourselfScreen extends StatelessWidget {
  final Map palette;
  final double fontSize;
  final Function(String) onSpeak;

  const EducateYourselfScreen({super.key, required this.palette, required this.fontSize, required this.onSpeak});

  @override
  Widget build(BuildContext context) {
    final p = palette;
    final List wisdoms = [
      {
        'source': 'قول رسول الله ﷺ في ولاية علي',
        'body': '«مَنْ كُنْتُ مَوْلَاهُ فَعَلِيٌّ مَوْلَاهُ، اللَّهُمَّ وَالِ مَنْ وَالَاهُ، وَعَادِ مَنْ عَادَاهُ، وَانْصُرْ مَنْ نَصَرَهُ، وَاخْذُلْ مَنْ خَذَلَهُ».',
      },
      {
        'source': 'حديث الثقلين الشريف',
        'body': '«إِنِّي تَارِكٌ فِيكُمُ الثَّقَلَيْنِ: كِتَابَ اللَّهِ وَعِتْرَتِي أَهْلَ بَيْتِي، مَا إِنْ تَمَسَّكْتُمْ بِهِمَا لَنْ تَضِلُّوا بَعْدِي أَبَداً».',
      },
      {
        'source': 'من كلام أمير المؤمنين علي (عليه السلام) - نهج البلاغة',
        'body': '«نَحْنُ الشِّعَارُ وَالْأَصْحَابُ، وَالْخَزَنَةُ وَالْأَبْوَابُ، وَلَا تُؤْتَى الْبُيُوتُ إِلَّا مِنْ أَبْوَابِهَا، فَمَنْ أَتَاهَا مِنْ غَيْرِ أَبْوَابِهَا سُمِّيَ سَارِقاً».',
      },
      {
        'source': 'الاقتداء بولاية علي الطاهرة',
        'body': '«أَلَا وَإِنَّ لِكُلِّ مَأْمُومٍ إِمَاماً يَقْتَدِي بِهِ وَيَسْتَضِيءُ بِنُورِ عِلْمِهِ، أَلَا وَإِنَّ إِمَامَكُمْ قَدِ اكْتَفَى مِنْ دُنْيَاهُ بِطِمْرَيْهِ وَمِنْ طُعْمِهِ بِقُرْصَيْهِ».',
      },
      {
        'source': 'حب آل البيت عليهم السلام',
        'body': 'قال رسول الله ﷺ: «مَثَلُ أَهْلِ بَيْتِي فِيكُمْ كَمَثَلِ سَفِينَةِ نُوحٍ، مَنْ رَكِبَهَا نَجَا، وَمَنْ تَخَلَّفَ عَنْهَا غَرِقَ وَهَوَى».',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: p['card'],
        title: Text('ثقّف نفسك — أنوار الولاية', style: TextStyle(color: p['accent'], fontWeight: FontWeight.bold)),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: wisdoms.length,
        itemBuilder: (ctx, i) {
          final w = wisdoms[i];
          return Card(
            color: p['card'],
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
              side: BorderSide(color: p['accent'], width: 1.2),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: p['accent'], size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(w['source'], style: TextStyle(color: p['accent'], fontSize: 15, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(w['body'], style: TextStyle(color: p['text'], fontSize: fontSize, height: 1.8)),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: Icon(Icons.volume_up_rounded, color: p['accent']),
                      onPressed: () => onSpeak(w['body']),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class TasbihAndAdhkarScreen extends StatefulWidget {
  final Map palette;
  final double fontSize;
  final Function(String) onSpeak;

  const TasbihAndAdhkarScreen({super.key, required this.palette, required this.fontSize, required this.onSpeak});

  @override
  State<TasbihAndAdhkarScreen> createState() => _TasbihAndAdhkarScreenState();
}

class _TasbihAndAdhkarScreenState extends State<TasbihAndAdhkarScreen> {
  int count = 0;
  String currentDhikr = 'الله أكبر (تسبيحة الزهراء عليها السلام - 34)';

  final List adhkarList = [
    'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ لَا شَرِيكَ لَهُ، اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَآلِ مُحَمَّدٍ.',
    'يَا حَيُّ يَا قَيُّومُ بِرَحْمَتِكَ أَسْتَغِيثُ، أَصْلِحْ لِي شَأْنِي كُلَّهُ وَلَا تَكِلْنِي إِلَى نَفْسِي طَرْفَةَ عَيْنٍ.',
    'لَا إِلَهَ إِلَّا اللَّهُ الْمَلِكُ الْحَقُّ الْمُبِينُ، مُحَمَّدٌ رَسُولُ اللَّهِ الصَّادِقُ الْوَعْدِ الْأَمِينُ، عَلِيٌّ وَلِيُّ اللَّهِ.',
    'أَسْتَغْفِرُ اللَّهَ الَّذِي لَا إِلَهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ وَأَتُوبُ إِلَيْهِ.',
  ];

  void _increment() {
    setState(() {
      count++;
      if (count <= 34) {
        currentDhikr = 'الله أكبر ($count / 34)';
      } else if (count <= 67) {
        currentDhikr = 'الحمد لله (${count - 34} / 33)';
      } else if (count <= 100) {
        currentDhikr = 'سبحان الله (${count - 67} / 33)';
      } else {
        currentDhikr = 'اكتملت تسبيحة الزهراء (100) — واصل الذكر';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: p['card'],
        title: Text('السبحة والأذكار اليومية', style: TextStyle(color: p['accent'], fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: p['card'],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: p['accent'], width: 1.5),
              ),
              child: Column(
                children: [
                  Text(currentDhikr, style: TextStyle(color: p['accent'], fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: _increment,
                    child: Container(
                      width: 150,
                      height: 150,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(colors: [p['accent'], p['accent'].withOpacity(0.5)]),
                        boxShadow: [BoxShadow(color: p['accent'].withOpacity(0.4), blurRadius: 16)],
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: const TextStyle(color: Colors.black, fontSize: 44, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton.icon(
                    onPressed: () => setState(() {
                      count = 0;
                      currentDhikr = 'الله أكبر (تسبيحة الزهراء عليها السلام - 34)';
                    }),
                    icon: const Icon(Icons.refresh, color: Colors.redAccent),
                    label: const Text('تصفير العداد', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Text('أذكار الصباح والمساء اليومية:', style: TextStyle(color: p['accent'], fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 10),
            ...adhkarList.map((dhikr) => Card(
                  color: p['card'],
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(dhikr, style: TextStyle(color: p['text'], fontSize: widget.fontSize - 1, height: 1.6)),
                    trailing: IconButton(
                      icon: Icon(Icons.volume_up_rounded, color: p['accent']),
                      onPressed: () => widget.onSpeak(dhikr),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class SettingsScreen extends StatefulWidget {
  final Map palette;
  final List themePalettes;
  final int themeIndex;
  final double fontSize;
  final double speechRate;
  final String selectedCity;
  final List cities;
  final Function({int? t, double? f, double? s, String? c}) onUpdate;

  const SettingsScreen({
    super.key,
    required this.palette,
    required this.themePalettes,
    required this.themeIndex,
    required this.fontSize,
    required this.speechRate,
    required this.selectedCity,
    required this.cities,
    required this.onUpdate,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late int tIdx;
  late double fSize;
  late double sRate;
  late String city;

  @override
  void initState() {
    super.initState();
    tIdx = widget.themeIndex;
    fSize = widget.fontSize;
    sRate = widget.speechRate;
    city = widget.selectedCity;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.themePalettes[tIdx];
    return Scaffold(
      backgroundColor: p['bg'],
      appBar: AppBar(
        backgroundColor: p['card'],
        title: Text('إعدادات النور الفاطمي', style: TextStyle(color: p['accent'], fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('لون خلفية التطبيق والمظهر:', style: TextStyle(color: p['accent'], fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          ...List.generate(widget.themePalettes.length, (i) {
            final item = widget.themePalettes[i];
            return Card(
              color: p['card'],
              child: RadioListTile(
                value: i,
                groupValue: tIdx,
                activeColor: p['accent'],
                title: Text(item['name'], style: TextStyle(color: p['text'], fontWeight: FontWeight.bold)),
                secondary: CircleAvatar(backgroundColor: item['bg'], child: Icon(Icons.palette, color: item['accent'])),
                onChanged: (val) {
                  setState(() => tIdx = val as int);
                  widget.onUpdate(t: tIdx);
                },
              ),
            );
          }),
          const SizedBox(height: 18),
          Text('المدينة (لضبط الوقت ومواقيت الصلاة):', style: TextStyle(color: p['accent'], fontSize: 17, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Card(
            color: p['card'],
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              child: DropdownButtonFormField(
                value: city,
                dropdownColor: p['card'],
                decoration: const InputDecoration(border: InputBorder.none),
                items: widget.cities.map((c) => DropdownMenuItem(value: c, child: Text(c, style: TextStyle(color: p['text'])))).toList(),
                onChanged: (val) {
                  setState(() => city = val.toString());
                  widget.onUpdate(c: city);
                },
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text('حجم خط النصوص والآيات: ${fSize.toInt()}', style: TextStyle(color: p['accent'], fontSize: 17, fontWeight: FontWeight.bold)),
          Slider(
            min: 16,
            max: 30,
            value: fSize,
            activeColor: p['accent'],
            onChanged: (v) {
              setState(() => fSize = v);
              widget.onUpdate(f: fSize);
            },
          ),
          const SizedBox(height: 12),
          Text('سرعة القراءة الصوتية: ${sRate.toStringAsFixed(2)}', style: TextStyle(color: p['accent'], fontSize: 17, fontWeight: FontWeight.bold)),
          Slider(
            min: 0.3,
            max: 0.8,
            value: sRate,
            activeColor: p['accent'],
            onChanged: (v) {
              setState(() => sRate = v);
              widget.onUpdate(s: sRate);
            },
          ),
        ],
      ),
    );
  }
}
