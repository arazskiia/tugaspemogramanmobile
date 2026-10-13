import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const EcoEnergyApp());
}

const Color kGreen = Color(0xFF248653);
const Color kDarkGreen = Color(0xFF17663D);
const Color kTitleGreen = Color(0xFF174D32);
const Color kBg = Color(0xFFF3F7F2);

class EcoEnergyApp extends StatelessWidget {
  const EcoEnergyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoEnergy',
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
          PointerDeviceKind.trackpad,
          PointerDeviceKind.stylus,
        },
      ),
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: kBg,
        colorScheme: ColorScheme.fromSeed(seedColor: kGreen),
      ),
      home: const MainShell(),
    );
  }
}

/// Data sumber energi (dipakai bersama oleh semua halaman).
final List<Map<String, dynamic>> energies = [
  {
    'title': 'Energi Surya',
    'subtitle': 'Memanfaatkan cahaya matahari',
    'icon': Icons.wb_sunny_rounded,
    'color': const Color(0xFFFFB547),
    'description':
        'Panel surya mengubah sinar matahari menjadi listrik '
        'yang dapat digunakan untuk kebutuhan sehari-hari.',
  },
  {
    'title': 'Energi Angin',
    'subtitle': 'Memanfaatkan kekuatan angin',
    'icon': Icons.air_rounded,
    'color': const Color(0xFF56A7E8),
    'description':
        'Turbin angin mengubah energi gerak angin menjadi '
        'energi listrik tanpa pembakaran bahan bakar.',
  },
  {
    'title': 'Energi Air',
    'subtitle': 'Memanfaatkan aliran air',
    'icon': Icons.water_drop_rounded,
    'color': const Color(0xFF4C9FE3),
    'description':
        'Pembangkit listrik tenaga air menggunakan aliran '
        'air untuk menggerakkan turbin pembangkit listrik.',
  },
];

/// Halaman utama (tanpa menu navigasi bawah).
class MainShell extends StatelessWidget {
  const MainShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kBg,
        scrolledUnderElevation: 0,
        title: const Text(
          'EcoEnergy',
          style: TextStyle(fontWeight: FontWeight.bold, color: kDarkGreen),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(Icons.eco_rounded, color: kGreen, size: 30),
          ),
        ],
      ),
      body: const SafeArea(child: EnergyDashboard()),
    );
  }
}

/// ---------------------------------------------------------------
/// Bagian "Cara Menggunakan"
/// ---------------------------------------------------------------
class UsageGuide extends StatelessWidget {
  const UsageGuide({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Cara Menggunakan',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: kDarkGreen,
          ),
        ),
        SizedBox(height: 18),
        InstructionItem(
          icon: Icons.touch_app,
          title: 'Double Tap',
          description:
              'Ketuk ikon dua kali untuk memperbesar atau mengembalikan ukurannya.',
        ),
        InstructionItem(
          icon: Icons.pinch,
          title: 'Scale / Pinch',
          description:
              'Cubit dengan dua jari pada ikon untuk mengubah ukuran objek. '
              'Di laptop: pinch trackpad, atau Ctrl + scroll, atau tombol + / −.',
        ),
        InstructionItem(
          icon: Icons.swipe,
          title: 'Swipe Horizontal',
          description:
              'Geser kartu ke kiri atau kanan untuk berpindah sumber energi.',
        ),
      ],
    );
  }
}

class InstructionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const InstructionItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 32,
            child: Icon(icon, color: kGreen, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------
/// Halaman Beranda
/// ---------------------------------------------------------------
class EnergyDashboard extends StatefulWidget {
  final int initialIndex;
  final ValueChanged<int>? onIndexChanged;

  const EnergyDashboard({
    super.key,
    this.initialIndex = 0,
    this.onIndexChanged,
  });

  @override
  State<EnergyDashboard> createState() => _EnergyDashboardState();
}

class _EnergyDashboardState extends State<EnergyDashboard> {
  late int currentIndex = widget.initialIndex;
  double objectScale = 1.0;
  double baseScale = 1.0;
  bool isPinching = false;
  bool doubleTapZoom = false;
  String gestureStatus = 'Pilih kartu dan coba gesturenya!';
  DateTime _lastWheel = DateTime.fromMillisecondsSinceEpoch(0);

  // Ubah ukuran ikon dengan faktor tertentu (dipakai trackpad, Ctrl+scroll, tombol).
  void _zoomBy(double factor) {
    setState(() {
      objectScale = (objectScale * factor).clamp(0.7, 2.0);
      doubleTapZoom = objectScale > 1.0;
      gestureStatus = 'Pinch: ukuran objek berubah';
    });
  }

  // Pinch trackpad & Ctrl + scroll pada area ikon.
  void _onIconPointerSignal(PointerSignalEvent event) {
    if (event is PointerScaleEvent) {
      _zoomBy(event.scale);
    } else if (event is PointerScrollEvent &&
        HardwareKeyboard.instance.isControlPressed) {
      _zoomBy(event.scrollDelta.dy < 0 ? 1.1 : 0.9);
    }
  }

  // Scroll horizontal mouse / trackpad (atau Shift + scroll wheel) untuk ganti kartu.
  void _onPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    if (HardwareKeyboard.instance.isControlPressed) return; // itu untuk zoom

    final dx = event.scrollDelta.dx;
    final dy = event.scrollDelta.dy;
    final shift = HardwareKeyboard.instance.isShiftPressed;

    final delta = dx.abs() > dy.abs() ? dx : (shift ? dy : 0.0);
    if (delta.abs() < 10) return;

    final now = DateTime.now();
    if (now.difference(_lastWheel).inMilliseconds < 450) return;
    _lastWheel = now;

    changeCard(delta > 0 ? 1 : -1);
    setState(() => gestureStatus = 'Scroll mouse: kartu berpindah');
  }

  // Tombol panah keyboard kiri / kanan.
  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
      changeCard(1);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
      changeCard(-1);
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void changeCard(int direction) {
    setState(() {
      currentIndex =
          (currentIndex + direction + energies.length) % energies.length;
      objectScale = 1.0;
      doubleTapZoom = false;
      gestureStatus = direction > 0
          ? 'Swipe kiri: kartu berikutnya'
          : 'Swipe kanan: kartu sebelumnya';
    });
    widget.onIndexChanged?.call(currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final energy = energies[currentIndex];
    final Color color = energy['color'] as Color;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Energi Bersih,\nMasa Depan Lebih Baik!',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: kTitleGreen,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kenali berbagai sumber energi terbarukan '
            'melalui pengalaman interaktif.',
            style: TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 24),

          // Kartu dapat digeser secara horizontal.
          Focus(
            autofocus: true,
            onKeyEvent: _onKey,
            child: Listener(
              onPointerSignal: _onPointerSignal,
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  final velocity = details.primaryVelocity ?? 0;
                  if (velocity < -100) {
                    changeCard(1);
                  } else if (velocity > 100) {
                    changeCard(-1);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'SUMBER ENERGI ${currentIndex + 1}',
                              style: const TextStyle(
                                fontSize: 11,
                                letterSpacing: 1.5,
                                fontWeight: FontWeight.bold,
                                color: kGreen,
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: 'Sebelumnya',
                            visualDensity: VisualDensity.compact,
                            color: kGreen,
                            icon: const Icon(Icons.chevron_left_rounded),
                            onPressed: () => changeCard(-1),
                          ),
                          IconButton(
                            tooltip: 'Berikutnya',
                            visualDensity: VisualDensity.compact,
                            color: kGreen,
                            icon: const Icon(Icons.chevron_right_rounded),
                            onPressed: () => changeCard(1),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Double tap & pinch pada objek ikon energi.
                      Listener(
                        onPointerSignal: _onIconPointerSignal,
                        child: GestureDetector(
                          onDoubleTap: () {
                            setState(() {
                              doubleTapZoom = !doubleTapZoom;
                              objectScale = doubleTapZoom ? 1.5 : 1.0;
                              gestureStatus = doubleTapZoom
                                  ? 'Double Tap: objek diperbesar'
                                  : 'Double Tap: ukuran kembali normal';
                            });
                          },
                          onScaleStart: (_) {
                            baseScale = objectScale;
                            isPinching = false;
                          },
                          onScaleUpdate: (details) {
                            // Layar sentuh (2 jari) ATAU scale berubah (trackpad).
                            if (details.pointerCount >= 2 ||
                                details.scale != 1.0) {
                              isPinching = true;
                              setState(() {
                                objectScale = (baseScale * details.scale)
                                    .clamp(0.7, 2.0);
                                doubleTapZoom = objectScale > 1.0;
                                gestureStatus = 'Pinch: ukuran objek berubah';
                              });
                            }
                          },
                          // Swipe satu jari di area ikon ditangani di sini,
                          // karena recognizer scale mengalahkan drag horizontal.
                          onScaleEnd: (details) {
                            if (isPinching) return;
                            final vx = details.velocity.pixelsPerSecond.dx;
                            if (vx < -300) {
                              changeCard(1);
                            } else if (vx > 300) {
                              changeCard(-1);
                            }
                          },
                          child: Stack(
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                height: 190,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: AnimatedScale(
                                    scale: objectScale,
                                    duration: const Duration(milliseconds: 60),
                                    child: Icon(
                                      energy['icon'] as IconData,
                                      size: 100,
                                      color: color,
                                    ),
                                  ),
                                ),
                              ),
                              // Tombol cadangan untuk mouse biasa.
                              Positioned(
                                right: 8,
                                bottom: 8,
                                child: Row(
                                  children: [
                                    IconButton.filledTonal(
                                      tooltip: 'Perkecil',
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.remove),
                                      onPressed: () => _zoomBy(0.85),
                                    ),
                                    IconButton.filledTonal(
                                      tooltip: 'Perbesar',
                                      visualDensity: VisualDensity.compact,
                                      icon: const Icon(Icons.add),
                                      onPressed: () => _zoomBy(1.15),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text(
                        energy['title'] as String,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: kTitleGreen,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        energy['subtitle'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        energy['description'] as String,
                        textAlign: TextAlign.center,
                        style: const TextStyle(height: 1.5, fontSize: 13),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          energies.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 8,
                            width: currentIndex == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: currentIndex == index
                                  ? kGreen
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Indikator perubahan visual gesture.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFE1F3E6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                const Icon(Icons.touch_app_rounded, color: kGreen),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    gestureStatus,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: kDarkGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 28),
          const UsageGuide(),

          const SizedBox(height: 8),
          const Center(
            child: Text(
              'SDG 7 • Affordable and Clean Energy',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: kGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
