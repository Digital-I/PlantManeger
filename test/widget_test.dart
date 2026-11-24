import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:plantmanager/features/common/empty_state.dart';

void main() {
  testWidgets('empty state displays its title and message', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: EmptyState(
            title: 'Растений пока нет',
            message: 'Добавьте первое растение.',
          ),
        ),
      ),
    );

    expect(find.text('Растений пока нет'), findsOneWidget);
    expect(find.text('Добавьте первое растение.'), findsOneWidget);
  });
}
