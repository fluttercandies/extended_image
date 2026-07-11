import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('lays out a custom child with the provided size and fit', (
    WidgetTester tester,
  ) async {
    const Key viewportKey = ValueKey<String>('viewport');
    const Key childKey = ValueKey<String>('custom-child');

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            key: viewportKey,
            width: 300,
            height: 200,
            child: ExtendedImageGestureWidget(
              childSize: const Size(100, 50),
              fit: BoxFit.contain,
              child: const ColoredBox(key: childKey, color: Colors.red),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(childKey)), const Size(300, 150));
    expect(
      tester.getTopLeft(find.byKey(childKey)) -
          tester.getTopLeft(find.byKey(viewportKey)),
      const Offset(0, 25),
    );
  });

  testWidgets('zooms a custom child through ExtendedImageGestureState', (
    WidgetTester tester,
  ) async {
    final GlobalKey<ExtendedImageGestureState> gestureKey =
        GlobalKey<ExtendedImageGestureState>();
    const Key viewportKey = ValueKey<String>('viewport');
    const Key childKey = ValueKey<String>('custom-child');

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            key: viewportKey,
            width: 300,
            height: 200,
            child: ExtendedImageGestureWidget(
              extendedImageGestureKey: gestureKey,
              childSize: const Size(100, 50),
              fit: BoxFit.contain,
              child: const ColoredBox(key: childKey, color: Colors.blue),
            ),
          ),
        ),
      ),
    );

    gestureKey.currentState!.handleDoubleTap(
      scale: 2,
      doubleTapPosition: tester.getCenter(find.byKey(viewportKey)),
    );
    await tester.pump();

    expect(gestureKey.currentState!.gestureDetails!.totalScale, 2);
    expect(tester.getSize(find.byKey(childKey)), const Size(600, 300));
  });
}
