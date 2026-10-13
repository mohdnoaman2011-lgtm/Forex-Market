import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  runApp(RatesApp(prefs: prefs));
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
  final Color bg, card, line, chip, text, muted, accent, onAccent;
  const Palette(this.bg, this.card, this.line, this.chip, this.text, this.muted,
      this.accent, this.onAccent);

  static const dark = Palette(Color(0xFF0A1411), Color(0xFF12201A),
      Color(0xFF22362D), Color(0xFF192A23), Color(0xFFEAF3EE),
      Color(0xFF8FA79B), Color(0xFF4ADE9A), Color(0xFF05150E));
  static const light = Palette(Color(0xFFF6F7F4), Color(0xFFFFFFFF),
      Color(0xFFE3E6E0), Color(0xFFE4EEE9), Color(0xFF14201B),
      Color(0xFF5B6660), Color(0xFF0F7A5A), Color(0xFFFFFFFF));

  static Palette of(BuildContext c) =>
      Theme.of(c).brightness == Brightness.dark ? dark : light;
}

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

class RatesApp extends StatefulWidget {
  final SharedPreferences prefs;
  const RatesApp({super.key, required this.prefs});
  @override
  State<RatesApp> createState() => _RatesAppState();
}

class _RatesAppState extends State<RatesApp> {
  static const _key = 'theme_mode';
  late ThemeMode _mode = switch (widget.prefs.getString(_key)) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };

  void _toggle(bool isDarkNow) {
    final next = isDarkNow ? ThemeMode.light : ThemeMode.dark;
    setState(() => _mode = next);
    widget.prefs.setString(_key, next == ThemeMode.dark ? 'dark' : 'light');
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
      home: HomePage(onToggleTheme: _toggle),
    );
  }
}

// ───────────────────────── مكوّنات مشتركة ─────────────────────────

class Seg extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final double height, radius;
  const Seg(this.label, this.selected, this.onTap,
      {super.key, this.height = 44, this.radius = 12});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Expanded(
      child: Material(
        color: selected ? p.accent : Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(radius),
          onTap: onTap,
          child: SizedBox(
            height: height,
            child: Center(
              child: Text(label,
                  style: TextStyle(
                    fontSize: 14,
                    color: selected ? p.onAccent : p.muted,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  )),
            ),
          ),
        ),
      ),
    );
  }
}

class Boxed extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final double radius;
  const Boxed(this.child,
      {super.key, this.padding = const EdgeInsets.all(20), this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: p.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: p.line),
      ),
      child: child,
    );
  }
}

class Tag extends StatelessWidget {
  final String text;
  final Color? color;
  const Tag(this.text, {super.key, this.color});
  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
          BoxDecoration(color: p.chip, borderRadius: BorderRadius.circular(10)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Text(text, style: TextStyle(fontSize: 12, color: color ?? p.text)),
      ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final themeButton = IconButton.filledTonal(
      tooltip: 'تبديل الوضع الداكن والفاتح',
      onPressed: () => widget.onToggleTheme(isDark),
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
                    type: _type,
                    action: themeButton,
                    onType: (t) => setState(() => _type = t),
                    // الضغط على عملة ينقلك للمحوّل ومعها تلك العملة
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
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(32),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(children: [
              for (final e in const [(0, 'الأسعار'), (1, 'المحوّل')])
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _tab = e.$1),
                    style: TextButton.styleFrom(
                      backgroundColor:
                          _tab == e.$1 ? cs.primary : Colors.transparent,
                      foregroundColor:
                          _tab == e.$1 ? cs.onPrimary : cs.onSurfaceVariant,
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

BoxDecoration cardDecoration(BuildContext context, {double radius = 24}) {
  final cs = Theme.of(context).colorScheme;
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(radius),
    border: Border.all(color: cs.outlineVariant),
  );
}

Widget infoChip(BuildContext context, String text, {Color? color}) {
  final cs = Theme.of(context).colorScheme;
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: cs.primaryContainer,
      borderRadius: BorderRadius.circular(10),
    ),
    child: Text(text,
        textDirection: TextDirection.ltr,
        style: TextStyle(fontSize: 12, color: color ?? cs.onPrimaryContainer)),
  );
}

// ───────────────────────── شاشة الأسعار ─────────────────────────

class RatesPage extends StatelessWidget {
  final RatesData data;
  final RateType type;
  final Widget action;
  final ValueChanged<RateType> onType;
  final ValueChanged<String> onPick;
  final Future<void> Function() onRefresh;
  const RatesPage({
    super.key,
    required this.data,
    required this.type,
    required this.action,
    required this.onType,
    required this.onPick,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final par = type == RateType.parallel;
    final usd = data.rates.firstWhere((r) => r.code == 'USD',
        orElse: () => data.rates.first);
    final spread =
        usd.bank == 0 ? null : (usd.parallel / usd.bank - 1) * 100;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        children: [
          Row(children: [
            const Expanded(
              child: Text('الأسعار',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
            ),
            if (data.updatedAgo != null)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: cardDecoration(context, radius: 20),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                          color: cs.primary, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Text('منذ ${data.updatedAgo}',
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                ]),
              ),
            const SizedBox(width: 8),
            action,
          ]),
          const SizedBox(height: 16),
          SegmentedButton<RateType>(
            segments: const [
              ButtonSegment(value: RateType.parallel, label: Text('موازي')),
              ButtonSegment(value: RateType.bank, label: Text('بنك')),
            ],
            selected: {type},
            onSelectionChanged: (s) => onType(s.first),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: cardDecoration(context),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('${usd.name} · ${par ? 'موازي' : 'بنك'}',
                  style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
              const SizedBox(height: 6),
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: fmt(usd.of(type)),
                      style: const TextStyle(
                          fontSize: 40, fontWeight: FontWeight.w700)),
                  TextSpan(
                      text: ' SDG',
                      style: TextStyle(fontSize: 14, color: cs.onSurfaceVariant)),
                ]),
                textDirection: TextDirection.ltr,
              ),
              const SizedBox(height: 12),
              Wrap(spacing: 8, children: [
                infoChip(context,
                    '${par ? 'بنك' : 'موازي'} ${fmt(usd.of(par ? RateType.bank : RateType.parallel))}'),
                if (spread != null)
                  infoChip(context, 'الفرق +${spread.toStringAsFixed(1)}%',
                      color: cs.primary),
              ]),
            ]),
          ),
          const SizedBox(height: 8),
          for (final r in data.rates)
            Container(
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: cs.outlineVariant)),
              ),
              child: ListTile(
                onTap: () => onPick(r.code),
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 44,
                  height: 44,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: cs.primaryContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(r.code,
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: cs.primary)),
                ),
                title: Text(r.name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                subtitle: Text(r.code,
                    style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text.rich(
                      TextSpan(children: [
                        TextSpan(
                            text: fmt(r.of(type)),
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 18)),
                        TextSpan(
                            text: ' SDG',
                            style: TextStyle(
                                fontSize: 11, color: cs.onSurfaceVariant)),
                      ]),
                      textDirection: TextDirection.ltr,
                    ),
                    Text(
                      '${par ? 'بنك' : 'موازي'} ${fmt(r.of(par ? RateType.bank : RateType.parallel))}',
                      textDirection: TextDirection.ltr,
                      style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
                    ),
                  ],
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
  if (k == '.') return a.contains('.') ? a : '${a.isEmpty ? '0' : a}.';
  if (a.length >= 12) return a;
  return (a == '0' ? '' : a) + k;
}

class ConverterPage extends StatelessWidget {
  final List<Rate> rates;
  final RateType type;
  final Widget action;
  final String from, to, amount;
  final ValueChanged<String> onFrom, onTo, onAmount;
  final VoidCallback onSwap;
  const ConverterPage({
    super.key,
    required this.rates,
    required this.type,
    required this.action,
    required this.from,
    required this.to,
    required this.amount,
    required this.onFrom,
    required this.onTo,
    required this.onAmount,
    required this.onSwap,
  });

  double _rate(String c) =>
      c == 'SDG' ? 1 : rates.firstWhere((r) => r.code == c).of(type);

  Map<String, String> get _names => {
        'SDG': 'الجنيه السوداني',
        for (final r in rates) r.code: r.name,
      };

  Widget _picker(BuildContext context, String value, ValueChanged<String> cb) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        items: [
          for (final e in _names.entries)
            DropdownMenuItem(value: e.key, child: Text('${e.value} (${e.key})')),
        ],
        onChanged: (v) => cb(v!),
      ),
    );
  }

  Widget _card(BuildContext context, String label, Widget picker, Widget value) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: cardDecoration(context),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(label, style: TextStyle(fontSize: 13, color: cs.onSurfaceVariant)),
          picker,
        ]),
        value,
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final amt = double.tryParse(amount) ?? 0;
    final unit = _rate(from) / _rate(to);
    final typeLabel = type == RateType.parallel ? 'سعر موازي' : 'سعر بنك';

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      children: [
        Row(children: [
          const Expanded(
            child: Text('المحوّل',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: cardDecoration(context, radius: 20),
            child: Text(typeLabel,
                style: TextStyle(fontSize: 12, color: cs.primary)),
          ),
          const SizedBox(width: 8),
          action,
        ]),
        const SizedBox(height: 16),
        _card(
          context,
          'من',
          _picker(context, from, onFrom),
          Container(
            alignment: Alignment.centerLeft,
            constraints: const BoxConstraints(minHeight: 62),
            child: Text(amount.isEmpty ? '0' : amount,
                textDirection: TextDirection.ltr,
                style: const TextStyle(fontSize: 42, fontWeight: FontWeight.w700)),
          ),
        ),
        Center(
          child: IconButton.filled(
            tooltip: 'تبديل العملتين',
            onPressed: onSwap,
            icon: const Icon(Icons.swap_vert),
          ),
        ),
        _card(
          context,
          'إلى',
          _picker(context, to, onTo),
          Container(
            alignment: Alignment.centerLeft,
            constraints: const BoxConstraints(minHeight: 62),
            child: Text(fmt(amt * unit),
                textDirection: TextDirection.ltr,
                style: TextStyle(
                    fontSize: 42, fontWeight: FontWeight.w700, color: cs.primary)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text('1 $from = ${fmt(unit, 4)} $to · المصدر: status.sd',
              textDirection: TextDirection.ltr,
              style: TextStyle(color: cs.onSurfaceVariant, fontSize: 12)),
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
                    backgroundColor: Theme.of(context).cardColor,
                    foregroundColor: cs.onSurface,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    textStyle: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.w500),
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
