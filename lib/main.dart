import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'splash_page.dart';

Future<void> main() async {

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



enum RateType { parallel, bank }

class Rate {
  final String code, name;
  final double parallel, bank;
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


  static const _currencies = <String, List<String>>{
    '\u0627\u0644\u062F\u0648\u0644\u0627\u0631 \u0627\u0644\u0627\u0645\u0631\u064A\u0643\u064A': ['USD', '\u0627\u0644\u062F\u0648\u0644\u0627\u0631 \u0627\u0644\u0623\u0645\u0631\u064A\u0643\u064A'],
    '\u0627\u0644\u064A\u0648\u0631\u0648': ['EUR', '\u0627\u0644\u064A\u0648\u0631\u0648'],
    '\u0627\u0644\u062F\u0631\u0647\u0645 \u0627\u0644\u0627\u0645\u0627\u0631\u0627\u062A\u064A': ['AED', '\u0627\u0644\u062F\u0631\u0647\u0645 \u0627\u0644\u0625\u0645\u0627\u0631\u0627\u062A\u064A'],
    '\u0627\u0644\u0631\u064A\u0627\u0644 \u0627\u0644\u0633\u0639\u0648\u062F\u064A': ['SAR', '\u0627\u0644\u0631\u064A\u0627\u0644 \u0627\u0644\u0633\u0639\u0648\u062F\u064A'],
    '\u0627\u0644\u0631\u064A\u0627\u0644 \u0627\u0644\u0642\u0637\u0631\u064A': ['QAR', '\u0627\u0644\u0631\u064A\u0627\u0644 \u0627\u0644\u0642\u0637\u0631\u064A'],
    '\u0627\u0644\u062C\u0646\u064A\u0647 \u0627\u0644\u0645\u0635\u0631\u064A': ['EGP', '\u0627\u0644\u062C\u0646\u064A\u0647 \u0627\u0644\u0645\u0635\u0631\u064A'],
  };

  static double _num(String s) => double.parse(s.replaceAll(',', ''));

  static Future<RatesData> fetch() async {
    final res = await http
        .get(Uri.parse(_url))
        .timeout(const Duration(seconds: 15));
    if (res.statusCode != 200) throw Exception('\u062E\u0637\u0623 ${res.statusCode}');

    final doc = html_parser.parse(utf8.decode(res.bodyBytes));
    final text = (doc.body?.text ?? '').replaceAll(RegExp(r'\s+'), ' ');

    final rates = <Rate>[];
    _currencies.forEach((siteName, info) {
      final m = RegExp(
        '${RegExp.escape(siteName)}[^\\d]*?\u0645\u0648\u0627\u0632\u064A[^\\d]*([\\d,.]+)[^\\d]*?\u0628\u0646\u0643[^\\d]*([\\d,.]+)',
      ).firstMatch(text);
      if (m != null) {
        rates.add(Rate(info[0], info[1], _num(m.group(1)!), _num(m.group(2)!)));
      }
    });
    if (rates.isEmpty) {
      throw Exception('\u062A\u0639\u0630\u0651\u0631 \u0642\u0631\u0627\u0621\u0629 \u0627\u0644\u0623\u0633\u0639\u0627\u0631\u060C \u0631\u0628\u0645\u0627 \u062A\u063A\u064A\u0651\u0631 \u0634\u0643\u0644 \u0627\u0644\u0635\u0641\u062D\u0629');
    }

    final ago = RegExp(r'\u0622\u062E\u0631 \u062A\u062D\u062F\u064A\u062B \u0645\u0646\u0630\s*(\d+\s*\S+)').firstMatch(text)?.group(1);
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
      title: '\u0623\u0633\u0639\u0627\u0631 \u0627\u0644\u0639\u0645\u0644\u0627\u062A',
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
      tooltip: '\u062A\u0628\u062F\u064A\u0644 \u0627\u0644\u0648\u0636\u0639 \u0627\u0644\u062F\u0627\u0643\u0646 \u0648\u0627\u0644\u0641\u0627\u062A\u062D',
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
                      onPressed: _reload, child: const Text('\u0625\u0639\u0627\u062F\u0629 \u0627\u0644\u0645\u062D\u0627\u0648\u0644\u0629')),
                ]),
              );
            }
            final data = snap.data!;
            return _tab == 0
                ? RatesPage(
                    data: data,
                    type: _type,
                    onType: (t) => setState(() => _type = t),
                    action: themeButton,

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
              for (final e in const [(0, '\u0627\u0644\u0623\u0633\u0639\u0627\u0631'), (1, '\u0627\u0644\u0645\u062D\u0648\u0651\u0644')])
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
    required Color fg,
    double width = 80,
    double fontSize = 14}) {
  return Container(
    width: width,
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
    child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 12, color: fg),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11, color: fg, height: 1.2)),
          ]),
          const SizedBox(height: 2),

          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerRight,
            child: Text(value,
                textDirection: TextDirection.ltr,
                softWrap: false,
                style: TextStyle(
                    fontSize: fontSize, fontWeight: FontWeight.w700, height: 1.15)),
          ),
        ]),
  );
}



class RatesPage extends StatelessWidget {
  final RatesData data;
  final RateType type;
  final ValueChanged<RateType> onType;
  final Widget action;
  final ValueChanged<String> onPick;
  final Future<void> Function() onRefresh;
  const RatesPage({
    super.key,
    required this.data,
    required this.type,
    required this.onType,
    required this.action,
    required this.onPick,
    required this.onRefresh,
  });

  static const _flags = {
    'USD': '\u{1F1FA}\u{1F1F8}',
    'EUR': '\u{1F1EA}\u{1F1FA}',
    'AED': '\u{1F1E6}\u{1F1EA}',
    'SAR': '\u{1F1F8}\u{1F1E6}',
    'QAR': '\u{1F1F6}\u{1F1E6}',
    'EGP': '\u{1F1EA}\u{1F1EC}',
  };
  static const _order = ['AED', 'EGP', 'EUR', 'SAR', 'QAR'];

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final par = type == RateType.parallel;

    Widget priceTile(Rate r) => par
        ? rateTile(context,
            label: '\u0645\u0648\u0627\u0632\u064A',
            value: fmt(r.parallel),
            icon: Icons.storefront_outlined,
            bg: p.cream,
            fg: p.amber,
            width: 120,
            fontSize: 20)
        : rateTile(context,
            label: '\u0628\u0646\u0643',
            value: fmt(r.bank),
            icon: Icons.account_balance_outlined,
            bg: p.mint,
            fg: p.mintText,
            width: 120,
            fontSize: 20);
    final usd = data.rates.firstWhere((r) => r.code == 'USD',
        orElse: () => data.rates.first);
    final list = [
      for (final c in _order) ...data.rates.where((r) => r.code == c),
    ];
    final subText = data.updatedAgo != null
        ? '\u0622\u062E\u0631 \u062A\u062D\u062F\u064A\u062B \u0645\u0646\u0630 ' + data.updatedAgo!
        : '\u0645\u0642\u0627\u0628\u0644 \u0627\u0644\u062C\u0646\u064A\u0647 \u0627\u0644\u0633\u0648\u062F\u0627\u0646\u064A';

    return LayoutBuilder(builder: (context, box) {

      final h = box.maxHeight < 600 ? 600.0 : box.maxHeight;

      Widget currencyCard(Rate r) => Material(
            color: p.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
              side: BorderSide(color: p.line),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () => onPick(r.code),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(children: [
                  Container(
                    width: 40,
                    height: 40,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                        color: p.mint, borderRadius: BorderRadius.circular(12)),
                    child: Text(_flags[r.code] ?? '',
                        style: const TextStyle(fontSize: 22)),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(r.name,
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2)),
                          Text(r.code,
                              textDirection: TextDirection.ltr,
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                  color: p.muted)),
                        ]),
                  ),
                  const SizedBox(width: 6),
                  priceTile(r),
                ]),
              ),
            ),
          );

      return RefreshIndicator(
        onRefresh: onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: h,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Column(
                children: [
                  screenHeader(
                    context,
                    '\u0623\u0633\u0639\u0627\u0631 \u0627\u0644\u0639\u0645\u0644\u0627\u062A',
                    Text(subText, style: TextStyle(fontSize: 12, color: p.muted)),
                    action,
                  ),
                  const SizedBox(height: 10),
                  SegmentedButton<RateType>(
                    expandedInsets: EdgeInsets.zero,
                    showSelectedIcon: true,
                    segments: const [
                      ButtonSegment(value: RateType.parallel, label: Text('\u0645\u0648\u0627\u0632\u064A')),
                      ButtonSegment(value: RateType.bank, label: Text('\u0628\u0646\u0643')),
                    ],
                    selected: {type},
                    onSelectionChanged: (s) => onType(s.first),
                    style: SegmentedButton.styleFrom(
                      backgroundColor: p.card,
                      foregroundColor: p.muted,
                      selectedBackgroundColor: p.mint,
                      selectedForegroundColor: p.mintText,
                      side: BorderSide(color: p.line),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(children: [
                    Container(
                        width: 8,
                        height: 8,
                        decoration:
                            BoxDecoration(color: p.accent, shape: BoxShape.circle)),
                    const SizedBox(width: 8),
                    const Text('\u0623\u0633\u0639\u0627\u0631 \u0627\u0644\u064A\u0648\u0645',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(width: 8),
                    Expanded(child: Container(height: 1, color: p.line)),
                  ]),
                  const SizedBox(height: 6),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: heroGradient,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: DefaultTextStyle(
                      style: const TextStyle(color: Colors.white),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(usd.name + (par ? ' \u2013 \u0627\u0644\u0633\u0648\u0642 \u0627\u0644\u0645\u0648\u0627\u0632\u064A' : ' \u2013 \u0633\u0639\u0631 \u0627\u0644\u0628\u0646\u0643'),
                                style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    height: 1.3)),
                            const SizedBox(height: 2),
                            Text.rich(
                              TextSpan(children: [
                                TextSpan(
                                    text: fmt(usd.of(type)),
                                    style: const TextStyle(
                                        fontSize: 40,
                                        fontWeight: FontWeight.w700,
                                        height: 1.1)),
                                const TextSpan(
                                    text: ' \u062C.\u0633', style: TextStyle(fontSize: 12)),
                              ]),
                              textDirection: TextDirection.ltr,
                            ),
                          ]),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Expanded(
                    child: Column(
                      children: [
                        for (final r in list)
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: currencyCard(r),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}



String applyKey(String a, String k) {
  if (k == '\u232B') return a.isEmpty ? a : a.substring(0, a.length - 1);
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
        'SDG': '\u0627\u0644\u062C\u0646\u064A\u0647 \u0627\u0644\u0633\u0648\u062F\u0627\u0646\u064A',
        for (final r in rates) r.code: r.name,
      };

  Widget _picker(BuildContext context, String value, ValueChanged<String> cb,
      {required Color bg, required Color fg}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(14)),
      child: DropdownButton<String>(
        isDense: true,
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
    final typeLabel = type == RateType.parallel ? '\u0633\u0639\u0631 \u0645\u0648\u0627\u0632\u064A' : '\u0633\u0639\u0631 \u0628\u0646\u0643';

    return LayoutBuilder(builder: (context, box) {

      final keyH = ((box.maxHeight - 450) / 4 - 6).clamp(40.0, 60.0).toDouble();
      final cellW = (box.maxWidth - 40 - 16) / 3;
      final ratio = cellW / keyH;

      return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        screenHeader(
          context,
          '\u0627\u0644\u0645\u062D\u0648\u0651\u0644',
          TextButton(
            onPressed: onToggleType,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              alignment: Alignment.centerRight,
            ),
            child: Text(typeLabel + ' \u00B7 \u0627\u0636\u063A\u0637 \u0644\u0644\u062A\u0628\u062F\u064A\u0644',
                style: TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600, color: p.mintText)),
          ),
          action,
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: p.card,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: p.line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('\u0645\u0646', style: TextStyle(fontSize: 13, color: p.muted)),
              _picker(context, from, onFrom, bg: p.chip, fg: p.text),
            ]),
            Container(
              alignment: Alignment.centerLeft,
              constraints: const BoxConstraints(minHeight: 50),
              child: Text(amount.isEmpty ? '0' : amount,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700)),
            ),
          ]),
        ),
        Center(
          child: IconButton.filled(
            tooltip: '\u062A\u0628\u062F\u064A\u0644 \u0627\u0644\u0639\u0645\u0644\u062A\u064A\u0646',
            onPressed: onSwap,
            style: IconButton.styleFrom(minimumSize: const Size(40, 40)),
            icon: const Icon(Icons.swap_vert),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: heroGradient,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('\u0625\u0644\u0649', style: TextStyle(fontSize: 13, color: Colors.white)),
              _picker(context, to, onTo,
                  bg: const Color(0x33FFFFFF), fg: Colors.white),
            ]),
            Container(
              alignment: Alignment.centerLeft,
              constraints: const BoxConstraints(minHeight: 50),
              child: Text(fmt(amt * unit),
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(
                      fontSize: 38, fontWeight: FontWeight.w700, color: Colors.white)),
            ),
          ]),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text('1 $from = ${fmt(unit, 4)} $to',
              textDirection: TextDirection.ltr,
              style: TextStyle(color: p.muted, fontSize: 12)),
        ),
        const SizedBox(height: 8),
        Directionality(
          textDirection: TextDirection.ltr,
          child: GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: ratio,
            children: [
              for (final k in const ['1','2','3','4','5','6','7','8','9','.','0','\u232B'])
                TextButton(
                  onPressed: () => onAmount(applyKey(amount, k)),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
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
    });
  }
}
