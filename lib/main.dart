import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;

void main() => runApp(const RatesApp());

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

String fmt(double v) {
  final s = v.toStringAsFixed(v == v.roundToDouble() ? 0 : 2);
  final p = s.split('.');
  final i = p[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
  return p.length > 1 ? '$i.${p[1]}' : i;
}

// ───────────────────────── التطبيق ─────────────────────────

class RatesApp extends StatelessWidget {
  const RatesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'أسعار العملات',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0F7A5A),
        scaffoldBackgroundColor: const Color(0xFFF6F7F4),
      ),
      builder: (c, child) =>
          Directionality(textDirection: TextDirection.rtl, child: child!),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Future<RatesData> _future = RatesService.fetch();
  RateType _type = RateType.parallel;
  int _tab = 0;

  void _reload() => setState(() => _future = RatesService.fetch());

  @override
  Widget build(BuildContext context) {
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
                  FilledButton(onPressed: _reload, child: const Text('إعادة المحاولة')),
                ]),
              );
            }
            final data = snap.data!;
            return _tab == 0
                ? RatesPage(
                    data: data,
                    type: _type,
                    onType: (t) => setState(() => _type = t),
                    onRefresh: () async {
                      _reload();
                      await _future;
                    },
                  )
                : ConverterPage(rates: data.rates, type: _type);
          },
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.show_chart), label: 'الأسعار'),
          NavigationDestination(icon: Icon(Icons.swap_vert), label: 'المحوّل'),
        ],
      ),
    );
  }
}

// ───────────────────────── شاشة الأسعار ─────────────────────────

class RatesPage extends StatelessWidget {
  final RatesData data;
  final RateType type;
  final ValueChanged<RateType> onType;
  final Future<void> Function() onRefresh;
  const RatesPage({
    super.key,
    required this.data,
    required this.type,
    required this.onType,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
        children: [
          const Text('الأسعار', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          Text(
            'مقابل الجنيه السوداني'
            '${data.updatedAgo != null ? ' · آخر تحديث منذ ${data.updatedAgo}' : ''}',
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 16),
          SegmentedButton<RateType>(
            segments: const [
              ButtonSegment(value: RateType.parallel, label: Text('موازي')),
              ButtonSegment(value: RateType.bank, label: Text('بنك')),
            ],
            selected: {type},
            onSelectionChanged: (s) => onType(s.first),
          ),
          const SizedBox(height: 8),
          for (final r in data.rates)
            Container(
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFE3E6E0))),
              ),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE4EEE9),
                  child: Text(r.code,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                ),
                title: Text(r.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                subtitle: Text(r.code),
                trailing: Text(
                  '${fmt(r.of(type))} ج.س',
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ───────────────────────── شاشة المحوّل ─────────────────────────

class ConverterPage extends StatefulWidget {
  final List<Rate> rates;
  final RateType type;
  const ConverterPage({super.key, required this.rates, required this.type});
  @override
  State<ConverterPage> createState() => _ConverterPageState();
}

class _ConverterPageState extends State<ConverterPage> {
  final _ctrl = TextEditingController(text: '100');
  String _from = 'USD', _to = 'SDG';

  late final Map<String, String> _names = {
    'SDG': 'الجنيه السوداني',
    for (final r in widget.rates) r.code: r.name,
  };

  double _rate(String c) => c == 'SDG'
      ? 1
      : widget.rates.firstWhere((r) => r.code == c).of(widget.type);

  Widget _picker(String value, ValueChanged<String> onChanged) => DropdownButton<String>(
        value: value,
        underline: const SizedBox.shrink(),
        items: [
          for (final e in _names.entries)
            DropdownMenuItem(value: e.key, child: Text('${e.value} (${e.key})')),
        ],
        onChanged: (v) => onChanged(v!),
      );

  Widget _card(String label, Widget picker, Widget value) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE3E6E0)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [Text(label, style: const TextStyle(color: Colors.black54)), picker]),
          value,
        ]),
      );

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_ctrl.text.replaceAll(',', '')) ?? 0;
    final result = amount * _rate(_from) / _rate(_to);
    final typeLabel = widget.type == RateType.parallel ? 'الموازي' : 'البنك';

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Text('المحوّل', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
        const SizedBox(height: 20),
        _card(
          'من',
          _picker(_from, (v) => setState(() => _from = v)),
          TextField(
            controller: _ctrl,
            textDirection: TextDirection.ltr,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
            decoration: const InputDecoration(border: InputBorder.none),
            onChanged: (_) => setState(() {}),
          ),
        ),
        Center(
          child: IconButton.filled(
            tooltip: 'تبديل العملتين',
            onPressed: () => setState(() {
              final t = _from;
              _from = _to;
              _to = t;
            }),
            icon: const Icon(Icons.swap_vert),
          ),
        ),
        _card(
          'إلى',
          _picker(_to, (v) => setState(() => _to = v)),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(fmt(result),
                textDirection: TextDirection.ltr,
                style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary)),
          ),
        ),
        const SizedBox(height: 12),
        Center(
          child: Text('السعر $typeLabel · المصدر: status.sd',
              style: const TextStyle(color: Colors.black54, fontSize: 13)),
        ),
      ],
    );
  }
}
