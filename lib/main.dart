import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() => runApp(const VoiceChangerApp());

class VoiceChangerApp extends StatelessWidget {
  const VoiceChangerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Realtime Voice',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF8B7CFF),
            brightness: Brightness.dark,
          ),
          scaffoldBackgroundColor: const Color(0xFF101018),
          useMaterial3: true,
        ),
        home: const VoiceChangerPage(),
      );
}

class VoiceEffect {
  const VoiceEffect(this.id, this.name, this.description, this.icon);
  final String id;
  final String name;
  final String description;
  final IconData icon;
}

const effects = <VoiceEffect>[
  VoiceEffect('baby', 'Bebek', 'Daha yüksek perde', Icons.child_care_rounded),
  VoiceEffect('robot', 'Robot', 'Metalik modülasyon', Icons.smart_toy_rounded),
  VoiceEffect('deep', 'Kalın', 'Daha düşük perde', Icons.graphic_eq_rounded),
  VoiceEffect('funny', 'Komik', 'Tiz ve eğlenceli', Icons.mood_rounded),
];

class VoiceChangerPage extends StatefulWidget {
  const VoiceChangerPage({super.key});

  @override
  State<VoiceChangerPage> createState() => _VoiceChangerPageState();
}

class _VoiceChangerPageState extends State<VoiceChangerPage> {
  static const _audio = MethodChannel('realtime_voice/audio');
  bool _isLive = false;
  bool _busy = false;
  String _selectedEffect = 'baby';
  String? _error;

  Future<void> _toggleLive() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      if (_isLive) {
        await _audio.invokeMethod<void>('stop');
        if (mounted) setState(() => _isLive = false);
      } else {
        final permission = await Permission.microphone.request();
        if (!permission.isGranted) {
          if (mounted) {
            setState(() => _error = permission.isPermanentlyDenied
                ? 'Mikrofon iznini Ayarlar’dan etkinleştirin.'
                : 'Canlı ses için mikrofon izni gerekli.');
          }
          return;
        }
        await _audio.invokeMethod<void>('start', {'effect': _selectedEffect});
        if (mounted) setState(() => _isLive = true);
      }
    } on PlatformException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'Ses başlatılamadı.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _selectEffect(String id) async {
    setState(() => _selectedEffect = id);
    if (!_isLive) return;
    try {
      await _audio.invokeMethod<void>('setEffect', {'effect': id});
    } on PlatformException catch (e) {
      if (mounted) setState(() => _error = e.message ?? 'Efekt değiştirilemedi.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final selected = effects.firstWhere((effect) => effect.id == _selectedEffect);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Realtime Voice', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
          children: [
            const Text('Sesini değiştir.',
                style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Bir efekt seç, ardından canlı modu başlat.',
                style: TextStyle(color: Colors.white.withValues(alpha: .65), fontSize: 15)),
            const SizedBox(height: 30),
            _LiveButton(isLive: _isLive, busy: _busy, onPressed: _toggleLive),
            const SizedBox(height: 14),
            Center(
              child: Text(
                _isLive ? 'CANLI · ${selected.name.toUpperCase()}' : 'BAŞLAMAK İÇİN HAZIR',
                style: TextStyle(
                  color: _isLive ? const Color(0xFF9DFFCE) : Colors.white54,
                  letterSpacing: 1.3,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (_isLive) ...[
              const SizedBox(height: 16),
              const _InfoBanner(
                icon: Icons.headphones_rounded,
                text: 'Canlı mikrofon dinlemesinde yankıyı önlemek için kulaklık kullanın.',
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 14),
              _InfoBanner(icon: Icons.warning_amber_rounded, text: _error!, isError: true),
            ],
            const SizedBox(height: 34),
            const Text('SES EFEKTLERİ',
                style: TextStyle(fontSize: 12, letterSpacing: 1.4, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            for (final effect in effects)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _EffectTile(
                  effect: effect,
                  selected: effect.id == _selectedEffect,
                  onTap: () => _selectEffect(effect.id),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              'Not: Efekt işleme cihaz üzerinde yapılır. Gecikme ve ses kalitesi cihaza göre değişebilir.',
              style: TextStyle(color: Colors.white.withValues(alpha: .48), fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _LiveButton extends StatelessWidget {
  const _LiveButton({required this.isLive, required this.busy, required this.onPressed});
  final bool isLive;
  final bool busy;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 190,
        child: Center(
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: busy ? null : onPressed,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 166,
              height: 166,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isLive ? const Color(0xFFCB526B) : const Color(0xFF7465EF),
                boxShadow: [
                  BoxShadow(
                    color: (isLive ? const Color(0xFFCB526B) : const Color(0xFF7465EF))
                        .withValues(alpha: .34),
                    blurRadius: 38,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (busy)
                    const SizedBox(width: 32, height: 32, child: CircularProgressIndicator())
                  else
                    Icon(isLive ? Icons.stop_rounded : Icons.mic_rounded, size: 38),
                  const SizedBox(height: 8),
                  Text(isLive ? 'DURDUR' : 'CANLIYA AL',
                      style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: .7)),
                ],
              ),
            ),
          ),
        ),
      );
}

class _EffectTile extends StatelessWidget {
  const _EffectTile({required this.effect, required this.selected, required this.onTap});
  final VoiceEffect effect;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: selected ? const Color(0xFF292541) : const Color(0xFF1A1A25),
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(effect.icon, color: selected ? const Color(0xFFB7AFFF) : Colors.white70),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(effect.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 3),
                    Text(effect.description,
                        style: TextStyle(color: Colors.white.withValues(alpha: .55), fontSize: 12)),
                  ]),
                ),
                if (selected) const Icon(Icons.check_circle_rounded, color: Color(0xFFB7AFFF)),
              ],
            ),
          ),
        ),
      );
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text, this.isError = false});
  final IconData icon;
  final String text;
  final bool isError;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(
          color: isError ? const Color(0xFF42262D) : const Color(0xFF222233),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Icon(icon, size: 19, color: isError ? const Color(0xFFFFA7A7) : const Color(0xFFB7AFFF)),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4))),
        ]),
      );
}
