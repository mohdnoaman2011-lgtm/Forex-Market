import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'splash_page.dart';

Future<void> main() async {
  // أي خطأ في البناء يظهر نصه على الشاشة بدل الشاشة السوداء
  ErrorWidget.builder = (details) => Material(
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Text(
              details.exceptionAsString(),
              textDirection: TextDirection.ltr,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        ),
      );
  try {
    WidgetsFlutterBinding.ensureInitialized();
    runApp(const RatesApp());
  } catch (e, st) {
    runApp(
      MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SingleChildScrollView(
                child: Text(
                  '$e\n$st',
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── النماذج والخدمة ─────────────────────────

enum RateType { parallel, bank }

class Rate {
  final String code, name;
  final double parallel, bank; // السعر بالجنيه السوداني
  const Rate(this.code, this.name, this.parallel, this.bank);
  double of(RateType t) => t == RateType.parallel ? parallel : bank;
}

class RatesData {
  final List<Rate> rates;
  final String? updatedAgo;
  RatesData(this.rates, this.updatedAgo);
}

class RatesService {
  static const _url = 'https://status.sd/';

  // الاسم كما يظهر في الموقع → (الرمز، الاسم المعروض)
  static const _currencies = <String, List<String>>{
    'الدولار الامريكي': ['USD', 'الدولار الأمريكي'],
    'اليورو': ['EUR', 'اليورو'],
    'الدرهم الاماراتي': ['AED', 'الدرهم الإماراتي'],
    'الريال السعودي': ['SAR', 'الريال السعودي'],
    'الريال القطري': ['QAR', 'الريال القطري'],
    'الجنيه المصري': ['EGP', 'الجنيه المصري'],
  };

  static double _num(String s) => double.parse(s.replaceAll(',', ''));

  static Future<RatesData> fetch() async {
    final res = await http
        .get(Uri.parse(_url))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('خطأ ${res.statusCode}');

    final doc = html_parser.parse(utf8.decode(res.bodyBytes));
    final text = (doc.body?.text ?? '').replaceAll(RegExp(r'\s+'), ' ');

    final rates = <Rate>[];
    _currencies.forEach((siteName, info) {
      final m = RegExp(
        '${RegExp.escape(siteName)}[^\\d]*?موازي[^\\d]*([\\d,.]+)[^\\d]*?بنك[^\\d]*([\\d,.]+)',
      ).firstMatch(text); // أول تطابق فقط (القائمة مكررة في الصفحة)
      if (m != null) {
        rates.add(Rate(info[0], info[1], _num(m.group(1)!), _num(m.group(2)!)));
      }
    });
    if (rates.isEmpty) {
      throw Exception('تعذّر قراءة الأسعار، ربما تغيّر شكل الصفحة');
    }

    final ago = RegExp(r'آخر تحديث منذ\s*(\d+\s*\S+)').firstMatch(text)?.group(1);
    return RatesData(rates, ago);
  }
}

String fmt(double v, [int d = 2]) {
  var s = v.toStringAsFixed(d);
  if (s.contains('.')) {
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  final p = s.split('.');
  final i = p[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return p.length > 1 ? '$i.${p[1]}' : i;
}

// ───────────────────────── الألوان والثيم ─────────────────────────

class Palette {
  final Color bg, card, line, chip, text, muted, mint, mintText, cream, amber,
      accent, onAccent;
  const Palette({
    required this.bg,
    required this.card,
    required this.line,
    required this.chip,
    required this.text,
    required this.muted,
    required this.mint,
    required this.mintText,
    required this.cream,
    required this.amber,
    required this.accent,
    required this.onAccent,
  });

  static const dark = Palette(
    bg: Color(0xFF0A101C),
    card: Color(0xFF121B2B),
    line: Color(0xFF223148),
    chip: Color(0xFF223148),
    text: Color(0xFFE8EEF8),
    muted: Color(0xFF8E9DB8),
    mint: Color(0xFF182A4A),
    mintText: Color(0xFF7AA5FF),
    cream: Color(0xFF2B2514),
    amber: Color(0xFFF2B544),
    accent: Color(0xFF7AA5FF),
    onAccent: Color(0xFF06122B),
  );

  static const light = Palette(
    bg: Color(0xFFF4F6FA),
    card: Color(0xFFFFFFFF),
    line: Color(0xFFE1E6EF),
    chip: Color(0xFFDFE6F2),
    text: Color(0xFF121C2E),
    muted: Color(0xFF56627A),
    mint: Color(0xFFE8EFFC),
    mintText: Color(0xFF1D4ED8),
    cream: Color(0xFFFDF4E6),
    amber: Color(0xFF9A5B00),
    accent: Color(0xFF1D4ED8),
    onAccent: Color(0xFFFFFFFF),
  );

  static Palette of(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dark : light;
}

const heroGradient = LinearGradient(
  begin: Alignment.topRight,
  end: Alignment.bottomLeft,
  colors: [Color(0xFF2563EB), Color(0xFF1E3A8A)],
);

ThemeData buildTheme(Brightness b) {
  final p = b == Brightness.dark ? Palette.dark : Palette.light;
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    scaffoldBackgroundColor: p.bg,
    cardColor: p.card,
    colorScheme: ColorScheme.fromSeed(seedColor: p.accent, brightness: b).copyWith(
      primary: p.accent,
      onPrimary: p.onAccent,
      surface: p.bg,
      onSurface: p.text,
      primaryContainer: p.chip,
      onPrimaryContainer: p.text,
      onSurfaceVariant: p.muted,
      outlineVariant: p.line,
    ),
    textTheme: GoogleFonts.ibmPlexSansArabicTextTheme(ThemeData(brightness: b).textTheme)
        .apply(bodyColor: p.text, displayColor: p.text),
  );
}

// ───────────────────────── التطبيق ─────────────────────────

/// حفظ اختيار الوضع (فاتح/داكن) في ملف صغير، بدون أي إضافة خارجية.
class ThemeStore {
  static File get _file => File(Directory.systemTemp.path + '/theme_mode.txt');

  static String? read() {
    try {
      return _file.existsSync() ? _file.readAsStringSync().trim() : null;
    } catch (_) {
      return null;
    }
  }

  static void write(String v) {
    try {
      _file.writeAsStringSync(v);
    } catch (_) {}
  }
}

class RatesApp extends StatefulWidget {
  const RatesApp({super.key});
  @override
  State<RatesApp> createState() => _RatesAppState();
}

class _RatesAppState extends State<RatesApp> {
  late ThemeMode _mode = switch (ThemeStore.read()) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  void _toggle(bool isDarkNow) {
    final next = isDarkNow ? ThemeMode.light : ThemeMode.dark;
    setState(() => _mode = next);
    ThemeStore.write(next == ThemeMode.dark ? 'dark' : 'light');
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أسعار العملات',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(Brightness.light),
      darkTheme: buildTheme(Brightness.dark),