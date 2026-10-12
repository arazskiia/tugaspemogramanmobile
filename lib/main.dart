import 'package:flutter/material.dart';

void main() {
  runApp(const EcoEnergyApp());
}

class EcoEnergyApp extends StatelessWidget {
  const EcoEnergyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'EcoEnergy',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF3F7F2),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF248653),
        ),
      ),
      home: const EnergyDashboard(),
    );
  }
}

class EnergyDashboard extends StatefulWidget {
  const EnergyDashboard({super.key});

  @override
  State<EnergyDashboard> createState() =>
      _EnergyDashboardState();
}

class _EnergyDashboardState extends State<EnergyDashboard> {
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

  int currentIndex = 0;
  double objectScale = 1.0;
  bool doubleTapZoom = false;
  String gestureStatus = 'Pilih kartu dan coba gesturenya!';

  void changeCard(int direction) {
    setState(() {
      currentIndex =
          (currentIndex + direction + energies.length) %
              energies.length;
      objectScale = 1.0;
      doubleTapZoom = false;
      gestureStatus = direction > 0
          ? 'Swipe kanan: kartu berikutnya'
          : 'Swipe kiri: kartu sebelumnya';
    });
  }

  @override
  Widget build(BuildContext context) {
    final energy = energies[currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F7F2),
        title: const Text(
          'EcoEnergy',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF17663D),
          ),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 18),
            child: Icon(
              Icons.eco_rounded,
              color: Color(0xFF248653),
              size: 30,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Energi Bersih,\nMasa Depan Lebih Baik!',
                style: TextStyle(
                  fontSize: 27,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF174D32),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kenali berbagai sumber energi terbarukan '
                'melalui pengalaman interaktif.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 24),

              // Kartu dapat digeser secara horizontal.
              GestureDetector(
                onHorizontalDragEnd: (details) {
                  final velocity =
                      details.primaryVelocity ?? 0;

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
                        color: Colors.green.withOpacity(0.08),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'SUMBER ENERGI ${currentIndex + 1}',
                          style: const TextStyle(
                            fontSize: 11,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF248653),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Double tap dan pinch diterapkan
                      // pada objek ikon energi.
                      GestureDetector(
                        onDoubleTap: () {
                          setState(() {
                            doubleTapZoom = !doubleTapZoom;
                            objectScale =
                                doubleTapZoom ? 1.5 : 1.0;
                            gestureStatus = doubleTapZoom
                                ? 'Double Tap: objek diperbesar'
                                : 'Double Tap: ukuran kembali normal';
                          });
                        },
                        onScaleStart: (_) {},
                        onScaleUpdate: (details) {
                          if (details.pointerCount >= 2) {
                            setState(() {
                              objectScale =
                                  (details.scale).clamp(0.7, 2.0);
                              gestureStatus =
                                  'Pinch: ukuran objek berubah';
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 200),
                          height: 190,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: energy['color']
                                .withOpacity(0.12),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Transform.scale(
                              scale: objectScale,
                              child: Icon(
                                energy['icon'],
                                size: 100,
                                color: energy['color'],
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      Text(
                        energy['title'],
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF174D32),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        energy['subtitle'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        energy['description'],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          height: 1.5,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          energies.length,
                          (index) => AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 4,
                            ),
                            height: 8,
                            width: currentIndex == index ? 24 : 8,
                            decoration: BoxDecoration(
                              color: currentIndex == index
                                  ? const Color(0xFF248653)
                                  : Colors.grey.shade300,
                              borderRadius:
                                  BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                    ],
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
                    const Icon(
                      Icons.touch_app_rounded,
                      color: Color(0xFF248653),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        gestureStatus,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF17663D),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Cara Menggunakan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              instruction(
                Icons.touch_app,
                'Double Tap',
                'Ketuk ikon dua kali untuk memperbesar '
                    'atau mengembalikan ukurannya.',
              ),
              instruction(
                Icons.pinch,
                'Scale / Pinch',
                'Gunakan dua jari pada ikon untuk '
                    'mengubah ukuran objek.',
              ),
              instruction(
                Icons.swipe,
                'Swipe Horizontal',
                'Geser area kartu ke kiri atau kanan '
                    'untuk berpindah sumber energi.',
              ),

              const SizedBox(height: 16),
              const Center(
                child: Text(
                  'SDG 7 • Affordable and Clean Energy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF248653),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget instruction(
    IconData icon,
    String title,
    String description,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF248653)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.black54,
                    height: 1.4,
                    fontSize: 13,
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