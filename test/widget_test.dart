// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:interactiveapp/main.dart';

void main() {
  // Ukuran layar setara ponsel agar seluruh kartu terlihat di test.
  void useMobileScreen(WidgetTester tester) {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Aplikasi menampilkan kartu pertama dan panduan',
      (WidgetTester tester) async {
    useMobileScreen(tester);
    await tester.pumpWidget(const EcoEnergyApp());

    expect(find.text('EcoEnergy'), findsOneWidget);
    expect(find.text('SUMBER ENERGI 1'), findsOneWidget);
    expect(find.text('Energi Surya'), findsOneWidget);
    expect(find.text('Energi Angin'), findsNothing);

    // Bagian "Cara Menggunakan".
    await tester.scrollUntilVisible(
      find.text('Swipe Horizontal'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Cara Menggunakan'), findsOneWidget);
    expect(find.text('Double Tap'), findsOneWidget);
    expect(find.text('Scale / Pinch'), findsOneWidget);
  });

  testWidgets('Tombol panah memindahkan kartu',
      (WidgetTester tester) async {
    useMobileScreen(tester);
    await tester.pumpWidget(const EcoEnergyApp());

    // Berikutnya: Surya -> Angin
    await tester.tap(find.byIcon(Icons.chevron_right_rounded));
    await tester.pumpAndSettle();
    expect(find.text('SUMBER ENERGI 2'), findsOneWidget);
    expect(find.text('Energi Angin'), findsOneWidget);

    // Sebelumnya: Angin -> Surya
    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pumpAndSettle();
    expect(find.text('SUMBER ENERGI 1'), findsOneWidget);
    expect(find.text('Energi Surya'), findsOneWidget);
  });

  testWidgets('Swipe horizontal memindahkan kartu',
      (WidgetTester tester) async {
    useMobileScreen(tester);
    await tester.pumpWidget(const EcoEnergyApp());

    // Swipe ke kiri -> kartu berikutnya.
    await tester.fling(
      find.byIcon(Icons.wb_sunny_rounded),
      const Offset(-300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('Energi Angin'), findsOneWidget);

    // Swipe ke kanan -> kartu sebelumnya.
    await tester.fling(
      find.byIcon(Icons.air_rounded),
      const Offset(300, 0),
      1000,
    );
    await tester.pumpAndSettle();
    expect(find.text('Energi Surya'), findsOneWidget);
  });

  testWidgets('Double tap pada ikon memperbesar objek',
      (WidgetTester tester) async {
    useMobileScreen(tester);
    await tester.pumpWidget(const EcoEnergyApp());

    final icon = find.byIcon(Icons.wb_sunny_rounded);

    await tester.tap(icon);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(icon);
    await tester.pumpAndSettle();

    expect(find.text('Double Tap: objek diperbesar'), findsOneWidget);
  });
}
