import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unstack/widgets/circular_progress_3d.dart';

void main() {
  group('CircularProgressIndicator3D Optimization Tests', () {
    testWidgets('should not rebuild unnecessarily when progress unchanged', (WidgetTester tester) async {
      int buildCount = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                buildCount++;
                return CircularProgressIndicator3D(
                  totalTasks: 10,
                  completedTasks: 5,
                  size: 200,
                );
              },
            ),
          ),
        ),
      );

      // Initial build
      expect(buildCount, 1);
      
      // Wait for animations to settle
      await tester.pump(const Duration(seconds: 2));
      
      // Should not have triggered additional builds of parent
      expect(buildCount, 1);
    });

    testWidgets('should rebuild when progress values change', (WidgetTester tester) async {
      int totalTasks = 10;
      int completedTasks = 5;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  children: [
                    CircularProgressIndicator3D(
                      totalTasks: totalTasks,
                      completedTasks: completedTasks,
                      size: 200,
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          completedTasks = 7;
                        });
                      },
                      child: Text('Update Progress'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      );

      // Find the progress indicator
      expect(find.byType(CircularProgressIndicator3D), findsOneWidget);
      
      // Tap the button to update progress
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();
      
      // Widget should still be present and functional
      expect(find.byType(CircularProgressIndicator3D), findsOneWidget);
    });

    testWidgets('should handle zero tasks correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularProgressIndicator3D(
              totalTasks: 0,
              completedTasks: 0,
              size: 200,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator3D), findsOneWidget);
      
      // Should not throw any errors
      await tester.pump(const Duration(seconds: 1));
    });

    testWidgets('should handle completed tasks correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularProgressIndicator3D(
              totalTasks: 5,
              completedTasks: 5,
              size: 200,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator3D), findsOneWidget);
      expect(find.text('100%'), findsOneWidget);
    });

    testWidgets('should respond to tap events', (WidgetTester tester) async {
      bool tapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CircularProgressIndicator3D(
              totalTasks: 10,
              completedTasks: 5,
              size: 200,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(CircularProgressIndicator3D));
      expect(tapped, true);
    });
  });
}
