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
      themeMode: _mode,
      builder: (c, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: SplashPage(next: HomePage(onToggleTheme: _toggle)),
    );
  }
}

// ───────────────────────── الصفحة الرئيسية ─────────────────────────

class HomePage extends StatefulWidget {
  final ValueChanged<bool> onToggleTheme;
  const HomePage({super.key, required this.onToggleTheme});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<RatesData> _future = RatesService.fetch();
  RateType _type = RateType.parallel;
  int _tab = 0;
  String _from = 'USD', _to = 'SDG', _amount = '100';

  void _reload() => setState(() => _future = RatesService.fetch());

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeButton = IconButton(
      tooltip: 'تبديل الوضع الداكن والفاتح',
      onPressed: () => widget.onToggleTheme(isDark),
      style: IconButton.styleFrom(
        backgroundColor: p.card,
        foregroundColor: p.text,
        minimumSize: const Size(44, 44),
        side: BorderSide(color: p.line),
      ),
      icon: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined),
    );

    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<RatesData>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return Center(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${snap.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton(
                      onPressed: _reload, child: const Text('إعادة المحاولة')),
                ]),
              );
            }
            final data = snap.data!;
            return _tab == 0
                ? RatesPage(
                    data: data,
                    action: themeButton,
                    // الضغط على بطاقة عملة ينقلك للمحوّل ومعها تلك العملة
                    onPick: (c) => setState(() {
                      _from = c;
                      _to = 'SDG';
                      _tab = 1;
                    }),
                    onRefresh: () async {
                      _reload();
                      await _future;
                    },
                  )
                : ConverterPage(
                    rates: data.rates,
                    type: _type,
                    action: themeButton,
                    from: _from,
                    to: _to,
                    amount: _amount,
                    onToggleType: () => setState(() => _type =
                        _type == RateType.parallel
                            ? RateType.bank
                            : RateType.parallel),
                    onFrom: (v) => setState(() => _from = v),
                    onTo: (v) => setState(() => _to = v),
                    onSwap: () => setState(() {
                      final t = _from;
                      _from = _to;
                      _to = t;
                    }),
                    onAmount: (v) => setState(() => _amount = v),
                  );
          },
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(40, 8, 40, 16),
          child: Container(
            height: 64,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: p.card,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: p.line),
            ),
            child: Row(children: [
              for (final e in const [(0, 'الأسعار'), (1, 'المحوّل')])
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _tab = e.$1),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          _tab == e.$1 ? p.accent : Colors.transparent,
                      foregroundColor: _tab == e.$1 ? p.onAccent : p.muted,
                      shape: const StadiumBorder(),
                      textStyle: TextStyle(
                          fontWeight:
                              _tab == e.$1 ? FontWeight.w700 : FontWeight.w500),
                    ),
                    child: Text(e.$2),
                  ),
                ),
            ]),
          ),
        ),
      ),
    );
  }
}

// ───────────────────────── عناصر مشتركة ─────────────────────────

Widget screenHeader(BuildContext context, String title, Widget sub, Widget action) {
  return Row(children: [
    Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        sub,
      ]),
    ),
    action,
  ]);
}

Widget rateTile(BuildContext context,
    {required String label,
    required String value,
    required IconData icon,
    required Color bg,
    required Color fg}) {
  return Container(
    width: 76,
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon, size: 12, color: fg),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 11, color: fg)),
      ]),
      const SizedBox(height: 2),
      Text(value,
          textDirection: TextDirection.ltr,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
    ]),
  );
}

// ───────────────────────── شاشة الأسعار ─────────────────────────

class RatesPage extends StatelessWidget {
  final RatesData data;
  final Widget action;
  final ValueChanged<String> onPick;
  final Future<void> Function() onRefresh;
  const RatesPage({
    super.key,
    required this.data,
    required this.action,
    required this.onPick,
    required this.onRefresh,
  });

  static const _flags = {
    'USD': '🇺🇸',
    'EUR': '🇪🇺',
    'AED': '🇦🇪',
    'SAR': '🇸🇦',
    'QAR': '🇶🇦',
    'EGP': '🇪🇬',
  };
  static const _order = ['AED', 'EGP', 'EUR', 'SAR', 'QAR'];

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final usd = data.rates.firstWhere((r) => r.code == 'USD',
        orElse: () => data.rates.first);
    final list = [
      for (final c in _order) ...data.rates.where((r) => r.code == c),
    ];
    final subText = data.updatedAgo != null
        ? 'آخر تحديث منذ ' + data.updatedAgo!
        : 'مقابل الجنيه السوداني';

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          screenHeader(
            context,
            'أسعار العملات',
            Text(subText, style: TextStyle(fontSize: 13, color: p.muted)),
            action,
          ),
          const SizedBox(height: 14),
          Row(children: [
            Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: p.accent, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            const Text('أسعار اليوم',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(width: 8),
            Expanded(child: Container(height: 1, color: p.line)),
          ]),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              gradient: heroGradient,
              borderRadius: BorderRadius.circular(24),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(usd.name + ' – السوق الموازي',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text.rich(
                    TextSpan(children: [
                      TextSpan(
                          text: fmt(usd.parallel),
                          style: const TextStyle(
                              fontSize: 40, fontWeight: FontWeight.w700, height: 1.1)),
                      const TextSpan(text: ' ج.س', style: TextStyle(fontSize: 13)),
                    ]),
                    textDirection: TextDirection.ltr,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0x2EFFFFFF),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Row(children: [
                        Icon(Icons.account_balance_outlined, size: 12, color: Colors.white),
                        SizedBox(width: 6),
                        Text('بنك', style: TextStyle(fontSize: 12)),
                      ]),
                      Text(fmt(usd.bank),
                          textDirection: TextDirection.ltr,
                          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                ]),
              ]),
            ),
          ),
          const SizedBox(height: 14),
          for (final r in list)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Material(
                color: p.card,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                  side: BorderSide(color: p.line),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => onPick(r.code),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(children: [
                      Container(
                        width: 40,
                        height: 40,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            color: p.mint, borderRadius: BorderRadius.circular(12)),
                        child: Text(_flags[r.code] ?? '', style: const TextStyle(fontSize: 22)),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(r.name,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700, height: 1.25)),
                          Text(r.code,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w700, color: p.muted)),
                        ]),
                      ),
                      rateTile(context,
                          label: 'موازي',
                          value: fmt(r.parallel),
                          icon: Icons.storefront_outlined,
                          bg: p.cream,
                          fg: p.amber),
                      const SizedBox(width: 6),
                      rateTile(context,
                          label: 'بنك',
                          value: fmt(r.bank),
                          icon: Icons.account_balance_outlined,
                          bg: p.mint,
                          fg: p.mintText),
                    ]),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── شاشة المحوّل ─────────────────────────

String applyKey(String a, String k) {
  if (k == '⌫') return a.isEmpty ? a : a.substring(0, a.length - 1);
  if (k == '.') return a.contains('.') ? a : (a.isEmpty ? '0' : a) + '.';
  if (a.length >= 12) return a;
  return (a == '0' ? '' : a) + k;
}

class ConverterPage extends StatelessWidget {
  final List<Rate> rates;
  final RateType type;
  final Widget action;
  final String from, to, amount;
  final VoidCallback onToggleType, onSwap;
  final ValueChanged<String> onFrom, onTo, onAmount;
  const ConverterPage({
    super.key,
    required this.rates,
    required this.type,
    required this.action,
    required this.from,
    required this.to,
    required this.amount,
    required this.onToggleType,
    required this.onFrom,
    required this.onTo,
    required this.onSwap,
    required this.onAmount,
  });

  double _rate(String c) =>
      c == 'SDG' ? 1 : rates.firstWhere((r) => r.code == c).of(type);

  Map<String, String> get _names => {
        'SDG': 'الجنيه السوداني',
        for (final r in rates) r.code: r.name,
      };

  Widget _picker(BuildContext context, String value, ValueChanged<String> cb,
      {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        iconEnabledColor: fg,
        selectedItemBuilder: (c) => [
          for (final e in _names.entries)
            Align(
              alignment: Alignment.center,
              child: Text(e.key,
                  textDirection: TextDirection.ltr,
                  style: TextStyle(color: fg, fontWeight: FontWeight.w600)),
            ),
        ],
        items: [
          for (final e in _names.entries)
            DropdownMenuItem(value: e.key, child: Text(e.value + ' (' + e.key + ')')),
        ],
        onChanged: (v) => cb(v!),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final amt = double.tryParse(amount) ?? 0;
    final unit = _rate(from) / _rate(to);
    final typeLabel = type == RateType.parallel ? 'سعر موازي' : 'سعر بنك';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        screenHeader(
          context,
          'المحوّل',
          TextButton(
            onPressed: onToggleType,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 44),
              alignment: Alignment.centerRight,
            ),
            child: Text(typeLabel + ' · اضغط للتبديل',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: p.mintText)),
          ),
          action,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: p.line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('من', style: TextStyle(fontSize: 13, color: p.muted)),
              _picker(context, from, onFrom, bg: p.chip, fg: p.text),
            ]),
            Container(
              alignment: Alignment.centerLeft,
              constraints: const BoxConstraints(minHeight: 62),
              child: Text(amount.isEmpty ? '0' : amount,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        Center(
          child: IconButton.filled(
            tooltip: 'تبديل العملتين',
            onPressed: onSwap,
            icon: const Icon(Icons.swap_vert),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            gradient: heroGradient,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('إلى', style: TextStyle(fontSize: 13, color: Colors.white)),
              _picker(context, to, onTo,
                  bg: const Color(0x33FFFFFF), fg: Colors.white),
            ]),
            Container(
              alignment: Alignment.centerLeft,
              constraints: const BoxConstraints(minHeight: 62),
              child: Text(fmt(amt * unit),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                      fontSize: 44, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text('1 $from = ${fmt(unit, 4)} $to',
              textDirection: TextDirection.ltr,
              style: TextStyle(color: p.muted, fontSize: 12)),
        ),
        const SizedBox(height: 12),
        Directionality(
          textDirection: TextDirection.ltr,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.3,
            children: [
              for (final k in const ['1','2','3','4','5','6','7','8','9','.','0','⌫'])
                TextButton(
                  onPressed: () => onAmount(applyKey(amount, k)),
                  style: TextButton.styleFrom(
                    backgroundColor: p.card,
                    foregroundColor: p.text,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                      side: BorderSide(color: p.line),
                    ),
                    textStyle: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                  child: Text(k),
                ),
            ],
          ),
        ),
      ],
    );
  }
}