// FlixGo — Flutter UI.
// Files: lib/main.dart (this file), lib/logo_data.dart (embedded logo), lib/player.dart (built-in player).
// Dependencies: google_fonts, video_player (see pubspec.yaml). No assets folder needed.
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'logo_data.dart';
import 'player.dart';

void main() => runApp(const FlixGoApp());

class Pal {
  final Color bg, bg2, card, ink, mute, line, pink, aqua, aquaBg, amber, vio;
  const Pal(this.bg, this.bg2, this.card, this.ink, this.mute, this.line,
      this.pink, this.aqua, this.aquaBg, this.amber, this.vio);
}

const darkPal = Pal(Color(0xFF130E2B), Color(0xFF1D1542), Color(0xFF241B52),
    Color(0xFFF4F0FF), Color(0xFFB3ABDB), Color(0xFF3A2F78), Color(0xFFFF6B9A),
    Color(0xFF2DD4BF), Color(0x292DD4BF), Color(0xFFFFB84D), Color(0xFFC4B8FF));
const lightPal = Pal(Color(0xFFF6F3FF), Color(0xFFEBE6FF), Color(0xFFFFFFFF),
    Color(0xFF1D1640), Color(0xFF5F5785), Color(0xFFDDD6F7), Color(0xFFC0266F),
    Color(0xFF0E8F80), Color(0xFFE1F6F3), Color(0xFFF59E0B), Color(0xFF5B3BDB));

const brandViolet = Color(0xFF6D4AFF);
const brandMagenta = Color(0xFFC0266F);

class Plat {
  final String ar, en;
  final RegExp re;
  final Color c;
  Plat(this.ar, this.en, this.re, this.c);
}

final platforms = [
  Plat('يوتيوب', 'YouTube', RegExp(r'youtu\.?be', caseSensitive: false),
      const Color(0xFFE02D2D)),
  Plat('إنستغرام', 'Instagram', RegExp(r'instagram\.com', caseSensitive: false),
      const Color(0xFFD946EF)),
  Plat('تيك توك', 'TikTok', RegExp(r'tiktok\.com', caseSensitive: false),
      const Color(0xFF06B6D4)),
  Plat('منصة X', 'X', RegExp(r'(twitter|x)\.com', caseSensitive: false),
      const Color(0xFF6D4AFF)),
  Plat('فيسبوك', 'Facebook',
      RegExp(r'(facebook|fb)\.com|fb\.watch', caseSensitive: false),
      const Color(0xFF3B82F6)),
];

const qv = [
  ['360p', 'صغير', 'Small'],
  ['720p', 'HD', 'HD'],
  ['1080p', 'Full HD', 'Full HD'],
  ['4K', 'فائقة', 'Ultra'],
];
const qa = [
  ['128', 'kbps', 'kbps'],
  ['192', 'kbps', 'kbps'],
  ['320', 'kbps', 'kbps'],
];
const sizes = {'360p': '18', '720p': '46', '1080p': '112', '4K': '380'};

const tr = {
  'ar': {
    'tag': 'حمّل الفيديو والصوت\nمن منصاتك المفضلة',
    'start': 'ابدأ الآن', 'other': 'English',
    'h1': 'حمّل ما يعجبك\nبضغطة واحدة',
    'sub': 'الصق رابط الفيديو وسنجهّزه لك بالجودة التي تريدها.',
    'ph': 'الصق الرابط هنا', 'paste': 'لصق', 'video': 'فيديو',
    'audio': 'صوت فقط', 'go': 'ابدأ التحميل', 'dl': 'التحميلات',
    'newDl': 'تحميل جديد', 'none': 'لم يُكتشف رابط بعد',
    'found': 'تم اكتشاف: ', 'bad': 'الرابط غير مدعوم', 'ql': 'الجودة',
    'qa': 'جودة الصوت (MP3)', 'est': 'الحجم المتوقع',
    'need': 'الصق رابطاً صالحاً أولاً', 'started': 'بدأ التحميل ✓',
    'done': 'اكتمل: ', 'vT': 'فيديو', 'aT': 'مقطع صوتي', 'from': ' من ',
    'vK': 'فيديو', 'aK': 'صوت', 'mb': ' ميغابايت', 'ok': 'تم',
    'empty': 'لا توجد تحميلات هنا.\nالصق رابطاً وابدأ.',
    'l0': 'ملفاتك تظهر هنا.', 'fAll': 'الكل', 'fAct': 'قيد التحميل',
    'fDone': 'مكتمل', 'settings': 'الإعدادات', 'setSub': 'خصّص التطبيق كما تريد.',
    'secLook': 'المظهر واللغة', 'theme': 'المظهر', 'light': 'فاتح',
    'dark': 'داكن', 'lang': 'اللغة', 'secDl': 'التحميل',
    'defVideo': 'جودة الفيديو الافتراضية',
    'defAudio': 'جودة الصوت الافتراضية', 'wifi': 'التحميل عبر Wi‑Fi فقط',
    'wifiSub': 'يوفّر باقة الإنترنت', 'autoPlay': 'تشغيل تلقائي بعد التحميل',
    'autoSub': 'يفتح المشغل عند اكتمال الملف', 'folder': 'مكان الحفظ',
    'secData': 'البيانات', 'clear': 'مسح قائمة التحميلات',
    'cleared': 'تم مسح القائمة', 'secAbout': 'حول التطبيق',
    'version': 'الإصدار', 'player': 'المشغل',
    'playErr': 'تعذّر تشغيل الملف. تحقق من الاتصال بالإنترنت.',
    'demo': 'معاينة تجريبية بملف نموذجي', 'play': 'تشغيل',
  },
  'en': {
    'tag': 'Download video and audio\nfrom your favorite platforms',
    'start': 'Get started', 'other': 'العربية',
    'h1': 'Download what you love\nin one tap',
    'sub': "Paste a video link and we'll prepare it in the quality you want.",
    'ph': 'Paste the link here', 'paste': 'Paste', 'video': 'Video',
    'audio': 'Audio only', 'go': 'Start download', 'dl': 'Downloads',
    'newDl': 'New download', 'none': 'No link detected yet',
    'found': 'Detected: ', 'bad': 'Unsupported link', 'ql': 'Quality',
    'qa': 'Audio quality (MP3)', 'est': 'Estimated size',
    'need': 'Paste a valid link first', 'started': 'Download started ✓',
    'done': 'Finished: ', 'vT': 'Video', 'aT': 'Audio clip', 'from': ' from ',
    'vK': 'Video', 'aK': 'Audio', 'mb': ' MB', 'ok': 'Done',
    'empty': 'No downloads here.\nPaste a link to start.',
    'l0': 'Your files show up here.', 'fAll': 'All', 'fAct': 'Downloading',
    'fDone': 'Done', 'settings': 'Settings', 'setSub': 'Customize the app.',
    'secLook': 'Appearance & language', 'theme': 'Theme', 'light': 'Light',
    'dark': 'Dark', 'lang': 'Language', 'secDl': 'Downloads',
    'defVideo': 'Default video quality',
    'defAudio': 'Default audio quality', 'wifi': 'Download on Wi‑Fi only',
    'wifiSub': 'Saves mobile data', 'autoPlay': 'Play after download',
    'autoSub': 'Opens the player when a file finishes', 'folder': 'Save location',
    'secData': 'Data', 'clear': 'Clear downloads list',
    'cleared': 'List cleared', 'secAbout': 'About',
    'version': 'Version', 'player': 'Player',
    'playErr': 'Could not play this file. Check your internet connection.',
    'demo': 'Demo preview using a sample file', 'play': 'Play',
  },
};

class Item {
  final Plat p;
  final bool audio;
  final String q;
  double pr = 0;
  Item(this.p, this.audio, this.q);
  bool get done => pr >= 100;
}

class FlixGoApp extends StatelessWidget {
  const FlixGoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'FlixGo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(textTheme: GoogleFonts.tajawalTextTheme()),
        home: const Home(),
      );
}

class Home extends StatefulWidget {
  const Home({super.key});
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool ar = true, dark = true, audio = false, err = false, started = false;
  bool wifiOnly = true, autoPlay = false;
  int tab = 0, vq = 1, aq = 1, filter = 0;
  final url = TextEditingController();
  final items = <Item>[];

  Pal get c => dark ? darkPal : lightPal;
  String t(String k) => tr[ar ? 'ar' : 'en']![k]!;
  String pn(Plat p) => ar ? p.ar : p.en;
  Plat? get plat {
    for (final p in platforms) {
      if (p.re.hasMatch(url.text)) return p;
    }
    return null;
  }

  String title(Item i) => '${t(i.audio ? 'aT' : 'vT')}${t('from')}${pn(i.p)}';
  String size(Item i) =>
      i.audio ? '4.2${t('mb')}' : '${sizes[i.q]}${t('mb')}';
  String est() =>
      audio ? '≈ 4.2${t('mb')}' : '≈ ${sizes[qv[vq][0]]}${t('mb')}';

  @override
  void dispose() {
    url.dispose();
    super.dispose();
  }

  void toast(String m) {
    final s = ScaffoldMessenger.of(context);
    s.hideCurrentSnackBar();
    s.showSnackBar(SnackBar(
      content:
          Text(m, style: TextStyle(color: c.bg, fontWeight: FontWeight.w700)),
      backgroundColor: c.ink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      duration: const Duration(seconds: 2),
    ));
  }

  Future<void> paste() async {
    final d = await Clipboard.getData('text/plain');
    final txt = d?.text ?? '';
    url.text = txt.isNotEmpty ? txt : 'https://youtu.be/AbCd1234';
    setState(() {});
  }

  void start() {
    final p = plat;
    if (p == null) {
      setState(() => err = true);
      Future.delayed(const Duration(milliseconds: 700), () {
        if (mounted) setState(() => err = false);
      });
      toast(t('need'));
      return;
    }
    final qq = audio ? qa[aq] : qv[vq];
    final it = Item(p, audio, audio ? '${qq[0]} kbps' : qq[0]);
    setState(() {
      items.insert(0, it);
      url.clear();
    });
    toast(t('started'));
    // Simulated progress. Replace with your real download service.
    Timer.periodic(const Duration(milliseconds: 350), (tm) {
      if (!mounted) {
        tm.cancel();
        return;
      }
      setState(() => it.pr = min(100, it.pr + Random().nextDouble() * 14 + 4));
      if (it.done) {
        tm.cancel();
        toast('${t('done')}${title(it)}');
        if (autoPlay) openPlayer(it);
      }
    });
  }

  void openPlayer(Item i) {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => PlayerPage(
        title: title(i),
        subtitle: '${t(i.audio ? 'aK' : 'vK')} · ${i.q} · ${size(i)}',
        source: i.audio ? kDemoAudio : kDemoVideo,
        pageTitle: t('player'),
        errorText: t('playErr'),
        demoText: t('demo'),
        audio: i.audio,
        rtl: ar,
        accent: i.p.c,
      ),
    ));
  }

  // ---------- Splash ----------
  Widget circle(double d, Color col) => Container(
      width: d,
      height: d,
      decoration: BoxDecoration(shape: BoxShape.circle, color: col));

  Widget splash() => Material(
        color: Colors.white,
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Stack(alignment: Alignment.topCenter, children: [
                Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(child: circle(560, const Color(0xFFF4F1FF)))),
                Positioned(
                    top: 110,
                    left: 0,
                    right: 0,
                    child: Center(child: circle(380, const Color(0xFFE9E3FF)))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(28, 0, 28, 28),
                  child: Column(children: [
                    const SizedBox(height: 190),
                    Image.memory(kLogoBytes,
                        width: 230, fit: BoxFit.contain, gaplessPlayback: true),
                    const SizedBox(height: 96),
                    Text(t('tag'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            color: Color(0xFF4A4270),
                            fontSize: 19,
                            height: 1.5,
                            fontWeight: FontWeight.w500)),
                    const SizedBox(height: 22),
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      for (final col in const [
                        Color(0xFFE02D2D),
                        Color(0xFFD946EF),
                        Color(0xFF06B6D4),
                        Color(0xFF6D4AFF),
                        Color(0xFF3B82F6)
                      ])
                        Container(
                            width: 10,
                            height: 10,
                            margin: const EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle, color: col)),
                    ]),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => started = true),
                      child: Container(
                        height: 58,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: const LinearGradient(
                                colors: [Color(0xFF0B5CFF), Color(0xFFA000E6)]),
                            boxShadow: const [
                              BoxShadow(
                                  color: Color(0x59783CFF),
                                  blurRadius: 26,
                                  offset: Offset(0, 10))
                            ]),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(t('start'),
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800)),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_rounded,
                                  color: Colors.white),
                            ]),
                      ),
                    ),
                    TextButton(
                      onPressed: () => setState(() => ar = !ar),
                      style: TextButton.styleFrom(
                          minimumSize: const Size(88, 44)),
                      child: Text(t('other'),
                          style: const TextStyle(
                              color: Color(0xFF4A4270),
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      );

  // ---------- Main app ----------
  Widget sq(Widget ch, VoidCallback f, String label) => Semantics(
        button: true,
        label: label,
        child: GestureDetector(
          onTap: f,
          child: Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.line, width: 1.5)),
            child: ch,
          ),
        ),
      );

  Widget header() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
        child: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(kMarkBytes,
                width: 42, height: 42, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Text('FlixGo',
              style: TextStyle(
                  color: c.ink, fontSize: 22, fontWeight: FontWeight.w800)),
          const Spacer(),
          sq(Icon(Icons.language_rounded, color: c.ink, size: 20),
              () => setState(() => ar = !ar), t('other')),
          const SizedBox(width: 8),
          sq(
              Icon(dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  color: c.ink, size: 20),
              () => setState(() => dark = !dark),
              'theme'),
        ]),
      );

  Widget seg(String k, bool a, IconData ic) => Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => audio = a),
          child: Center(
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(ic, size: 20, color: audio == a ? Colors.white : c.mute),
              const SizedBox(width: 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: audio == a ? Colors.white : c.mute),
                child: Text(t(k)),
              ),
            ]),
          ),
        ),
      );

  Widget chipBox(String label, String sub, bool on, VoidCallback f) =>
      GestureDetector(
        onTap: f,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
              color: on ? c.aquaBg : c.card,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: on ? c.aqua : c.line, width: 1.5)),
          child: Center(
              widthFactor: 1,
              child: Text.rich(TextSpan(
              text: label,
              style: TextStyle(
                  color: c.ink,
                  fontWeight: on ? FontWeight.w700 : FontWeight.w500),
              children: sub.isEmpty
                  ? null
                  : [
                      TextSpan(
                          text: '  $sub',
                          style: TextStyle(
                              color: c.mute,
                              fontSize: 12,
                              fontWeight: FontWeight.w400))
                    ]))),
        ),
      );

  Widget downloadPage() {
    final p = plat;
    final qs = audio ? qa : qv;
    final sel = audio ? aq : vq;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        Text(t('h1'),
            style: TextStyle(
                color: c.ink,
                fontSize: 30,
                fontWeight: FontWeight.w800,
                height: 1.25)),
        const SizedBox(height: 6),
        Text(t('sub'),
            style: TextStyle(color: c.mute, fontSize: 14, height: 1.5)),
        const SizedBox(height: 18),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                  color: err ? c.pink : c.line, width: 1.5)),
          child: Column(children: [
            Row(children: [
              Icon(Icons.link_rounded, color: c.mute, size: 22),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: url,
                  onChanged: (_) => setState(() {}),
                  keyboardType: TextInputType.url,
                  textDirection: url.text.isEmpty ? null : TextDirection.ltr,
                  style: TextStyle(color: c.ink, fontSize: 15),
                  decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      hintText: t('ph'),
                      hintStyle: TextStyle(color: c.mute)),
                ),
              ),
              GestureDetector(
                onTap: paste,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: c.bg2, borderRadius: BorderRadius.circular(12)),
                  child: Text(t('paste'),
                      style: TextStyle(
                          color: c.vio, fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 10,
                height: 10,
                decoration:
                    BoxDecoration(shape: BoxShape.circle, color: p?.c ?? c.line),
              ),
              const SizedBox(width: 8),
              Text(
                  p != null
                      ? '${t('found')}${pn(p)}'
                      : url.text.isEmpty
                          ? t('none')
                          : t('bad'),
                  style: TextStyle(color: c.mute, fontSize: 13)),
            ]),
          ]),
        ),
        const SizedBox(height: 18),
        Container(
          height: 54,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: c.bg2, borderRadius: BorderRadius.circular(18)),
          child: Stack(children: [
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              alignment: AlignmentDirectional(audio ? 1 : -1, 0),
              child: FractionallySizedBox(
                widthFactor: .5,
                heightFactor: 1,
                child: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                          colors: [brandViolet, Color(0xFFB8247D)])),
                ),
              ),
            ),
            Row(children: [
              seg('video', false, Icons.videocam_outlined),
              seg('audio', true, Icons.headphones_rounded),
            ]),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 20, bottom: 10),
          child: Text(audio ? t('qa') : t('ql'),
              style: TextStyle(
                  color: c.ink, fontSize: 15, fontWeight: FontWeight.w700)),
        ),
        Wrap(spacing: 9, runSpacing: 9, children: [
          for (var i = 0; i < qs.length; i++)
            chipBox(qs[i][0], qs[i][ar ? 1 : 2], sel == i, () {
              setState(() {
                if (audio) {
                  aq = i;
                } else {
                  vq = i;
                }
              });
            }),
        ]),
        const SizedBox(height: 14),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(t('est'), style: TextStyle(color: c.mute, fontSize: 13)),
          Text(est(),
              style: TextStyle(
                  color: c.ink, fontSize: 13, fontWeight: FontWeight.w700)),
        ]),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: start,
          child: Container(
            height: 58,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient:
                    const LinearGradient(colors: [brandViolet, brandMagenta]),
                boxShadow: const [
                  BoxShadow(
                      color: Color(0x596D4AFF),
                      blurRadius: 26,
                      offset: Offset(0, 10))
                ]),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Icon(Icons.download_rounded, color: Colors.white),
              const SizedBox(width: 10),
              Text(t('go'),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w800)),
            ]),
          ),
        ),
      ],
    );
  }

  Widget card(Item i) {
    final done = i.done;
    return GestureDetector(
      onTap: done ? () => openPlayer(i) : null,
      child: Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.line, width: 1.5)),
      child: Row(children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(colors: [i.p.c, brandViolet])),
          child: Icon(
              i.audio ? Icons.music_note_rounded : Icons.play_arrow_rounded,
              color: Colors.white,
              size: 26),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title(i),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: c.ink, fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 2),
            Text('${t(i.audio ? 'aK' : 'vK')} · ${i.q} · ${size(i)}',
                style: TextStyle(color: c.mute, fontSize: 12.5)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: LinearProgressIndicator(
                  value: i.pr / 100,
                  minHeight: 7,
                  backgroundColor: c.bg2,
                  color: c.aqua),
            ),
          ]),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 44,
          child: done
              ? Semantics(
                  button: true,
                  label: t('play'),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                            colors: [brandViolet, brandMagenta])),
                    child: const Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 26),
                  ),
                )
              : Text('${i.pr.floor()}%',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: c.ink, fontSize: 13, fontWeight: FontWeight.w700)),
        ),
      ]),
    ));
  }

  Widget listPage() {
    final n = items.length;
    final shown = items
        .where((i) => filter == 0 || (filter == 1 ? !i.done : i.done))
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
      children: [
        Text(t('dl'),
            style: TextStyle(
                color: c.ink, fontSize: 30, fontWeight: FontWeight.w800)),
        const SizedBox(height: 6),
        Text(
            n == 0
                ? t('l0')
                : ar
                    ? '$n ملف في هذه الجلسة'
                    : '$n file${n == 1 ? '' : 's'} this session',
            style: TextStyle(color: c.mute, fontSize: 14)),
        const SizedBox(height: 16),
        Wrap(spacing: 8, runSpacing: 8, children: [
          chipBox(t('fAll'), '', filter == 0, () => setState(() => filter = 0)),
          chipBox(
              t('fAct'), '', filter == 1, () => setState(() => filter = 1)),
          chipBox(
              t('fDone'), '', filter == 2, () => setState(() => filter = 2)),
        ]),
        if (shown.isEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 60),
            child: Column(children: [
              Icon(Icons.inbox_outlined, size: 54, color: c.mute),
              const SizedBox(height: 10),
              Text(t('empty'),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.mute, height: 1.6)),
            ]),
          ),
        for (final i in shown) card(i),
      ],
    );
  }

  // ---------- Settings ----------
  Widget secTitle(String k) => Padding(
        padding: const EdgeInsets.only(top: 22, bottom: 10),
        child: Text(t(k),
            style: TextStyle(
                color: c.ink, fontSize: 15, fontWeight: FontWeight.w700)),
      );

  Widget group(List<Widget> rows) {
    final kids = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      if (i > 0) kids.add(Divider(height: 1, thickness: 1, color: c.line));
      kids.add(rows[i]);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: c.line, width: 1.5)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: kids),
    );
  }

  Widget optionRow(String labelKey, Widget child) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(t(labelKey),
              style: TextStyle(
                  color: c.ink, fontSize: 14, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          child,
        ]),
      );

  Widget segControl(List<String> labels, int sel, void Function(int) onSel) =>
      Container(
        height: 48,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
            color: c.bg2, borderRadius: BorderRadius.circular(14)),
        child: Row(children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onSel(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(11),
                      gradient: sel == i
                          ? const LinearGradient(
                              colors: [brandViolet, Color(0xFFB8247D)])
                          : null),
                  child: Text(labels[i],
                      style: TextStyle(
                          color: sel == i ? Colors.white : c.mute,
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                ),
              ),
            ),
        ]),
      );

  Widget toggle(bool on, void Function(bool) f, String label) => Semantics(
        label: label,
        toggled: on,
        child: GestureDetector(
          onTap: () => f(!on),
          child: SizedBox(
            width: 52,
            height: 44,
            child: Center(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 52,
                height: 30,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: on ? brandViolet : c.line),
                child: AnimatedAlign(
                  duration: const Duration(milliseconds: 200),
                  alignment: on
                      ? AlignmentDirectional.centerEnd
                      : AlignmentDirectional.centerStart,
                  child: Padding(
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: Color(0x40000000),
                                blurRadius: 4,
                                offset: Offset(0, 2))
                          ]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

  Widget switchRow(
          String titleKey, String subKey, bool on, void Function(bool) f) =>
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(t(titleKey),
                  style: TextStyle(
                      color: c.ink, fontSize: 14, fontWeight: FontWeight.w700)),
              const SizedBox(height: 2),
              Text(t(subKey),
                  style: TextStyle(color: c.mute, fontSize: 12.5)),
            ]),
          ),
          const SizedBox(width: 12),
          toggle(on, f, t(titleKey)),
        ]),
      );

  Widget settingsPage() => ListView(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 110),
        children: [
          Text(t('settings'),
              style: TextStyle(
                  color: c.ink, fontSize: 30, fontWeight: FontWeight.w800)),
          const SizedBox(height: 6),
          Text(t('setSub'), style: TextStyle(color: c.mute, fontSize: 14)),
          secTitle('secLook'),
          group([
            optionRow(
                'theme',
                segControl([t('light'), t('dark')], dark ? 1 : 0,
                    (i) => setState(() => dark = i == 1))),
            optionRow(
                'lang',
                segControl(['العربية', 'English'], ar ? 0 : 1,
                    (i) => setState(() => ar = i == 0))),
          ]),
          secTitle('secDl'),
          group([
            optionRow(
                'defVideo',
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (var i = 0; i < qv.length; i++)
                    chipBox(qv[i][0], '', vq == i, () => setState(() => vq = i)),
                ])),
            optionRow(
                'defAudio',
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (var i = 0; i < qa.length; i++)
                    chipBox('${qa[i][0]} kbps', '', aq == i,
                        () => setState(() => aq = i)),
                ])),
            switchRow('wifi', 'wifiSub', wifiOnly,
                (v) => setState(() => wifiOnly = v)),
            switchRow('autoPlay', 'autoSub', autoPlay,
                (v) => setState(() => autoPlay = v)),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(children: [
                Icon(Icons.folder_outlined, color: c.mute, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t('folder'),
                            style: TextStyle(
                                color: c.ink,
                                fontSize: 14,
                                fontWeight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text('Downloads/FlixGo',
                            textDirection: TextDirection.ltr,
                            style: TextStyle(color: c.mute, fontSize: 12.5)),
                      ]),
                ),
              ]),
            ),
          ]),
          secTitle('secData'),
          group([
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                setState(() => items.clear());
                toast(t('cleared'));
              },
              child: Container(
                constraints: const BoxConstraints(minHeight: 56),
                alignment: AlignmentDirectional.centerStart,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.delete_outline_rounded,
                      color: dark ? c.pink : const Color(0xFFB3205F), size: 22),
                  const SizedBox(width: 12),
                  Text(t('clear'),
                      style: TextStyle(
                          color: dark ? c.pink : const Color(0xFFB3205F),
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
          secTitle('secAbout'),
          group([
            Container(
              constraints: const BoxConstraints(minHeight: 56),
              alignment: Alignment.center,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(t('version'),
                        style: TextStyle(
                            color: c.ink,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                    Text('1.0.0',
                        style: TextStyle(color: c.mute, fontSize: 14)),
                  ]),
            ),
          ]),
        ],
      );

  Widget navBtn(int i, String label, IconData ic, int badge) => Expanded(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => tab = i),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
                color: tab == i ? c.bg2 : Colors.transparent,
                borderRadius: BorderRadius.circular(18)),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Stack(clipBehavior: Clip.none, children: [
                Icon(ic, size: 22, color: tab == i ? c.vio : c.mute),
                if (badge > 0)
                  PositionedDirectional(
                    top: -6,
                    end: -14,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      decoration: BoxDecoration(
                          color: c.pink,
                          borderRadius: BorderRadius.circular(9)),
                      child: Text('$badge',
                          style: TextStyle(
                              color: dark ? c.bg : Colors.white,
                              fontSize: 11)),
                    ),
                  ),
              ]),
              const SizedBox(height: 2),
              Text(label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: tab == i ? c.vio : c.mute,
                      fontWeight: FontWeight.w700,
                      fontSize: 12)),
            ]),
          ),
        ),
      );

  Widget nav() => Positioned(
        left: 20,
        right: 20,
        bottom: 20,
        child: Container(
          height: 64,
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: c.line, width: 1.5),
              boxShadow: const [
                BoxShadow(
                    color: Color(0x40140A3C),
                    blurRadius: 30,
                    offset: Offset(0, 12))
              ]),
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            navBtn(0, t('newDl'), Icons.add_rounded, 0),
            navBtn(1, t('dl'), Icons.inbox_outlined, items.length),
            navBtn(2, t('settings'), Icons.tune_rounded, 0),
          ]),
        ),
      );

  Widget app() => Scaffold(
        backgroundColor: c.bg,
        body: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Stack(children: [
                Column(children: [
                  header(),
                  Expanded(
                      child: tab == 0
                          ? downloadPage()
                          : tab == 1
                              ? listPage()
                              : settingsPage()),
                ]),
                nav(),
              ]),
            ),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) => Directionality(
        textDirection: ar ? TextDirection.rtl : TextDirection.ltr,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: started
              ? KeyedSubtree(key: const ValueKey('app'), child: app())
              : KeyedSubtree(key: const ValueKey('splash'), child: splash()),
        ),
      );
}
