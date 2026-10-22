import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'splash_page.dart';


const appVersion = 'v2.4';

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
  final Color bg, surface, line, chip, text, muted, track, thumb, hero, accent,
      onAccent, navBg, navText;
  const Palette({
    required this.bg,
    required this.surface,
    required this.line,
    required this.chip,
    required this.text,
    required this.muted,
    required this.track,
    required this.thumb,
    required this.hero,
    required this.accent,
    required this.onAccent,
    required this.navBg,
    required this.navText,
  });

  static const light = Palette(
    bg: Color(0xFFF1EFEA),
    surface: Color(0xFFFFFFFF),
    line: Color(0xFFE6E3DC),
    chip: Color(0xFFF1EFEA),
    text: Color(0xFF0F1115),
    muted: Color(0xFF6B6F76),
    track: Color(0xFFE6E3DC),
    thumb: Color(0xFFFFFFFF),
    hero: Color(0xFF0F1115),
    accent: Color(0xFF2F5BFF),
    onAccent: Color(0xFFFFFFFF),
    navBg: Color(0xFF0F1115),
    navText: Color(0xA6FFFFFF),
  );

  static const dark = Palette(
    bg: Color(0xFF0B0C0F),
    surface: Color(0xFF15171C),
    line: Color(0xFF24272F),
    chip: Color(0xFF1E2128),
    text: Color(0xFFF2F3F5),
    muted: Color(0xFF9AA0AA),
    track: Color(0xFF1E2128),
    thumb: Color(0xFF2B303B),
    hero: Color(0xFF1B2350),
    accent: Color(0xFF7D96FF),
    onAccent: Color(0xFF0B1030),
    navBg: Color(0xFF1E222B),
    navText: Color(0x99FFFFFF),
  );

  static Palette of(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dark : light;
}


const softWhite = Color(0x24FFFFFF);

ThemeData buildTheme(Brightness b) {
  final p = b == Brightness.dark ? Palette.dark : Palette.light;
  return ThemeData(
    useMaterial3: true,
    brightness: b,
    scaffoldBackgroundColor: p.bg,
    cardColor: p.surface,
    popupMenuTheme: PopupMenuThemeData(color: p.surface),
    colorScheme: ColorScheme.fromSeed(seedColor: p.accent, brightness: b).copyWith(
      primary: p.accent,
      onPrimary: p.onAccent,
      surface: p.bg,
      onSurface: p.text,
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
        backgroundColor: p.surface,
        foregroundColor: p.text,
        minimumSize: const Size(42, 42),
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
                    onConvert: () => setState(() => _tab = 1),
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
          padding: const EdgeInsets.fromLTRB(48, 8, 48, 16),
          child: Container(
            height: 54,
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: p.navBg,
              borderRadius: BorderRadius.circular(30),
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
                      foregroundColor: _tab == e.$1 ? p.onAccent : p.navText,
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



Widget screenHeader(Widget title, Widget sub, Widget action) {
  return Row(children: [
    Expanded(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        title,
        sub,
      ]),
    ),
    action,
  ]);
}

Widget screenTitle(String text) =>
    Text(text, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.2));



class RatesPage extends StatelessWidget {
  final RatesData data;
  final RateType type;
  final ValueChanged<RateType> onType;
  final Widget action;
  final ValueChanged<String> onPick;
  final VoidCallback onConvert;
  final Future<void> Function() onRefresh;
  const RatesPage({
    super.key,
    required this.data,
    required this.type,
    required this.onType,
    required this.action,
    required this.onPick,
    required this.onConvert,
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
    final usd = data.rates.firstWhere((r) => r.code == 'USD',
        orElse: () => data.rates.first);
    final list = [
      for (final c in _order) ...data.rates.where((r) => r.code == c),
    ];
    final subText = (data.updatedAgo != null
            ? '\u0645\u062D\u062F\u0651\u062B \u0645\u0646\u0630 ' + data.updatedAgo!
            : '\u0645\u0642\u0627\u0628\u0644 \u0627\u0644\u062C\u0646\u064A\u0647 \u0627\u0644\u0633\u0648\u062F\u0627\u0646\u064A') +
        ' \u00B7 ' +
        appVersion;


    final double spread = par
        ? (usd.bank == 0 ? 0.0 : (usd.parallel / usd.bank - 1) * 100)
        : (usd.parallel == 0 ? 0.0 : (usd.bank / usd.parallel - 1) * 100);
    final spreadText = (spread >= 0 ? '+' : '') + spread.toStringAsFixed(1) + '%';
    final spreadLabel = par ? ' \u0639\u0646 \u0627\u0644\u0628\u0646\u0643' : ' \u0639\u0646 \u0627\u0644\u0645\u0648\u0627\u0632\u064A';

    Widget segmented() => Container(
          height: 40,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: p.track,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Row(children: [
            for (final e in const [
              (RateType.parallel, '\u0645\u0648\u0627\u0632\u064A'),
              (RateType.bank, '\u0628\u0646\u0643'),
            ])
              Expanded(
                child: Semantics(
                  button: true,
                  selected: type == e.$1,
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => onType(e.$1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: type == e.$1 ? p.thumb : Colors.transparent,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: type == e.$1
                            ? const [
                                BoxShadow(
                                    color: Color(0x24000000),
                                    blurRadius: 4,
                                    offset: Offset(0, 1))
                              ]
                            : null,
                      ),
                      child: Text(e.$2,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight:
                                  type == e.$1 ? FontWeight.w700 : FontWeight.w500,
                              color: type == e.$1 ? p.text : p.muted)),
                    ),
                  ),
                ),
              ),
          ]),
        );

    Widget hero() => Container(
          height: 136,
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: p.hero,
            borderRadius: BorderRadius.circular(32),
          ),
          child: DefaultTextStyle(
            style: const TextStyle(color: Colors.white),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [
                      Text(_flags['USD'] ?? '',
                          style: const TextStyle(fontSize: 24, height: 1.1)),
                      const SizedBox(width: 10),
                      Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(usd.name,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700)),
                            Text(par ? '\u0627\u0644\u0633\u0648\u0642 \u0627\u0644\u0645\u0648\u0627\u0632\u064A' : '\u0633\u0639\u0631 \u0627\u0644\u0628\u0646\u0643',
                                style: const TextStyle(
                                    fontSize: 12, color: Colors.white70)),
                          ]),
                    ]),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: softWhite,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Text('USD',
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text: fmt(usd.of(type)),
                                style: const TextStyle(
                                    fontSize: 42,
                                    fontWeight: FontWeight.w700,
                                    height: 1.0)),
                            const TextSpan(
                                text: ' \u062C.\u0633', style: TextStyle(fontSize: 12)),
                          ]),
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: softWhite,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(spreadText,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(fontSize: 11)),
                        Text(spreadLabel, style: const TextStyle(fontSize: 11)),
                      ]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );

    Widget tile(Rate r) {
      final price = par ? r.parallel : r.bank;
      return Material(
        color: p.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: BorderSide(color: p.line),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () => onPick(r.code),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_flags[r.code] ?? '',
                        style: const TextStyle(fontSize: 22, height: 1.1)),
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: p.chip,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(r.code,
                          textDirection: TextDirection.ltr,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: p.muted)),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12, color: p.muted, height: 1.2)),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerRight,
                      child: Text(fmt(price),
                          textDirection: TextDirection.ltr,
                          softWrap: false,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              height: 1.15)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }

    Widget actionTile() => Material(
          color: p.accent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          child: InkWell(
            borderRadius: BorderRadius.circular(28),
            onTap: onConvert,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.calculate_outlined, size: 22, color: p.onAccent),
                      Icon(Icons.arrow_forward, size: 20, color: p.onAccent),
                    ],
                  ),
                  Text('\u062D\u0648\u0651\u0644 \u0628\u064A\u0646 \u0627\u0644\u0639\u0645\u0644\u0627\u062A',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          height: 1.3,
                          color: p.onAccent)),
                ],
              ),
            ),
          ),
        );

    final cells = <Widget>[for (final r in list) tile(r), actionTile()];
    final gridRows = <Widget>[
      for (var i = 0; i < cells.length; i += 2)
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: i + 2 < cells.length ? 10 : 0),
            child: Row(children: [
              Expanded(child: cells[i]),
              const SizedBox(width: 10),
              Expanded(
                  child: i + 1 < cells.length ? cells[i + 1] : const SizedBox()),
            ]),
          ),
        ),
    ];

    return LayoutBuilder(builder: (context, box) {

      final h = box.maxHeight < 600 ? 600.0 : box.maxHeight;
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
                    screenTitle('\u0627\u0644\u0623\u0633\u0639\u0627\u0631'),
                    Row(children: [
                      Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                              color: Color(0xFF22C55E), shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      Text(subText,
                          style: TextStyle(fontSize: 12, color: p.muted)),
                    ]),
                    action,
                  ),
                  const SizedBox(height: 12),
                  segmented(),
                  const SizedBox(height: 12),
                  hero(),
                  const SizedBox(height: 10),
                  Expanded(child: Column(children: gridRows)),
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

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final amt = double.tryParse(amount) ?? 0;
    final unit = _rate(from) / _rate(to);
    final typeLabel = type == RateType.parallel ? '\u0633\u0639\u0631 \u0645\u0648\u0627\u0632\u064A' : '\u0633\u0639\u0631 \u0628\u0646\u0643';
    final codes = _names.keys.toList();

    return LayoutBuilder(builder: (context, box) {

      final keyH = ((box.maxHeight - 400) / 4 - 6).clamp(40.0, 50.0).toDouble();
      final cellW = (box.maxWidth - 40 - 16) / 3;
      final ratio = cellW / keyH;

      return ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        children: [
          screenHeader(
            screenTitle('\u0627\u0644\u0645\u062D\u0648\u0651\u0644'),
            TextButton(
              onPressed: onToggleType,
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: const Size(0, 28),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerRight,
              ),
              child: Text(typeLabel + ' \u00B7 \u0627\u0636\u063A\u0637 \u0644\u0644\u062A\u0628\u062F\u064A\u0644',
                  style: TextStyle(
                      fontSize: 12, fontWeight: FontWeight.w600, color: p.accent)),
            ),
            action,
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 32,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: [
                for (final c in codes)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () => onFrom(c),
                      child: Container(
                        height: 32,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: c == from ? p.text : p.surface,
                          borderRadius: BorderRadius.circular(19),
                          border: Border.all(
                              color: c == from ? p.text : p.line),
                        ),
                        child: Text(c,
                            textDirection: TextDirection.ltr,
                            style: TextStyle(
                                fontSize: 13,
                                fontWeight:
                                    c == from ? FontWeight.w700 : FontWeight.w500,
                                color: c == from ? p.bg : p.muted)),
                      ),
                    ),
                  ),
              ]),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: p.surface,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: p.line),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('\u0627\u0644\u0645\u0628\u0644\u063A', style: TextStyle(fontSize: 12, color: p.muted)),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(amount.isEmpty ? '0' : amount,
                            style: const TextStyle(
                                fontSize: 40,
                                fontWeight: FontWeight.w700,
                                height: 1.2)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(from,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: p.muted)),
                  ],
                ),
              ),
            ]),
          ),
          SizedBox(
            height: 36,
            child: Center(
              child: IconButton.filled(
                tooltip: '\u062A\u0628\u062F\u064A\u0644 \u0627\u0644\u0639\u0645\u0644\u062A\u064A\u0646',
                onPressed: onSwap,
                style: IconButton.styleFrom(
                  backgroundColor: p.accent,
                  foregroundColor: p.onAccent,
                  minimumSize: const Size(36, 36),
                  padding: EdgeInsets.zero,
                ),
                icon: const Icon(Icons.swap_vert, size: 20),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: p.hero,
              borderRadius: BorderRadius.circular(28),
            ),
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  const Text('\u0627\u0644\u0646\u062A\u064A\u062C\u0629',
                      style: TextStyle(fontSize: 12, color: Colors.white70)),
                  PopupMenuButton<String>(
                    tooltip: '\u0627\u062E\u062A\u064A\u0627\u0631 \u0627\u0644\u0639\u0645\u0644\u0629',
                    onSelected: onTo,
                    itemBuilder: (c) => [
                      for (final e in _names.entries)
                        PopupMenuItem<String>(
                          value: e.key,
                          child: Text(e.value + ' (' + e.key + ')'),
                        ),
                    ],
                    child: Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: softWhite,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(to,
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 4),
                        const Icon(Icons.expand_more, size: 18, color: Colors.white),
                      ]),
                    ),
                  ),
                ]),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(fmt(amt * unit),
                          style: const TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w700,
                              height: 1.2)),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text('1 $from = ${fmt(unit, 4)} $to',
                        style: const TextStyle(
                            fontSize: 12, color: Colors.white70)),
                  ),
                ),
              ]),
            ),
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
              childAspectRatio: ratio,
              children: [
                for (final k in const ['1','2','3','4','5','6','7','8','9','.','0','\u232B'])
                  TextButton(
                    onPressed: () => onAmount(applyKey(amount, k)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      backgroundColor: p.surface,
                      foregroundColor: p.text,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: p.line),
                      ),
                      textStyle:
                          const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
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
