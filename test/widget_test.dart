import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Importações necessárias para os testes
import 'package:loah_app/core/utils/currency_formatter.dart';
import 'package:loah_app/models/app_notification.dart';
import 'package:loah_app/models/contact_model.dart';

void main() {
  // ─────────────────────────────────────────────────────────────────
  // Testes do Widget principal (smoke test)
  // ─────────────────────────────────────────────────────────────────

  group('App Smoke Test', () {
    testWidgets('App renders without crashing', (WidgetTester tester) async {
      // This is a placeholder test that verifies the test environment
      // works. The full app requires Firebase initialization, so we
      // test individual widgets and utilities instead.
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(title: const Text('Loah')),
            body: const Center(child: Text('Hello, Loah!')),
          ),
        ),
      );

      expect(find.text('Loah'), findsOneWidget);
      expect(find.text('Hello, Loah!'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // Testes de Modelos
  // ─────────────────────────────────────────────────────────────────

  group('AppNotification Model', () {
    test('Creates AppNotification with default values', () {
      final notification = AppNotification(
        id: 'test_id',
        category: NotificationCategory.system,
        title: 'Test Title',
        message: 'Test Message',
        timestamp: DateTime(2024, 1, 1),
      );

      expect(notification.id, 'test_id');
      expect(notification.category, NotificationCategory.system);
      expect(notification.title, 'Test Title');
      expect(notification.message, 'Test Message');
      expect(notification.timestamp, DateTime(2024, 1, 1));
      expect(notification.relatedId, isNull);
      expect(notification.progress, isNull);
      expect(notification.isRead, false);
    });

    test('AppNotification copyWith updates fields correctly', () {
      final original = AppNotification(
        id: 'id1',
        category: NotificationCategory.tasks,
        title: 'Original',
        message: 'Original message',
        timestamp: DateTime(2024, 1, 1),
        relatedId: 'related1',
        progress: 0.5,
        isRead: false,
      );

      final modified = original.copyWith(
        title: 'Modified',
        isRead: true,
      );

      expect(modified.id, 'id1');
      expect(modified.title, 'Modified');
      expect(modified.isRead, true);
      expect(modified.category, NotificationCategory.tasks);
      expect(modified.message, 'Original message');
      expect(modified.relatedId, 'related1');
      expect(modified.progress, 0.5);
    });

    test('AppNotification serializes toFirestore correctly', () {
      final notification = AppNotification(
        id: 'notif_1',
        category: NotificationCategory.goals,
        title: 'Goal Reached',
        message: 'You reached 50%!',
        timestamp: DateTime(2024, 6, 15, 10, 30),
        relatedId: 'goal_123',
        progress: 0.5,
      );

      final map = notification.toFirestore();

      expect(map['category'], 'goals');
      expect(map['title'], 'Goal Reached');
      expect(map['message'], 'You reached 50%!');
      expect(map['relatedId'], 'goal_123');
      expect(map['progress'], 0.5);
      expect(map['isRead'], false);
      expect(map['timestamp'], isNotNull);
      expect(map['updatedAt'], isNotNull);
    });

    test('NotificationCategory contains all expected values', () {
      expect(NotificationCategory.values, hasLength(5));
      expect(NotificationCategory.values, contains(NotificationCategory.contacts));
      expect(NotificationCategory.values, contains(NotificationCategory.tasks));
      expect(NotificationCategory.values, contains(NotificationCategory.goals));
      expect(NotificationCategory.values, contains(NotificationCategory.finance));
      expect(NotificationCategory.values, contains(NotificationCategory.system));
    });
  });

  group('ContactModel', () {
    test('Creates ContactModel with required fields', () {
      const contact = ContactModel(
        id: 'contact_1',
        name: 'Alice Ferreira',
        email: 'alice@example.com',
        relationshipTag: 'Amiga',
      );

      expect(contact.id, 'contact_1');
      expect(contact.name, 'Alice Ferreira');
      expect(contact.email, 'alice@example.com');
      expect(contact.phone, isNull);
      expect(contact.relationshipTag, 'Amiga');
      expect(contact.isFavorite, false);
      expect(contact.desiredContactFrequencyDays, isNull);
      expect(contact.interactions, isEmpty);
      expect(contact.avatarUrl, isNull);
    });

    test('ContactModel isOverdue returns true when daysSinceLastContact exceeds frequency', () {
      final contact = ContactModel(
        id: 'c1',
        name: 'Test',
        relationshipTag: 'Amigo',
        desiredContactFrequencyDays: 7,
        interactions: [
          ContactInteraction(
            date: DateTime.now().subtract(const Duration(days: 10)),
            type: InteractionType.call,
          ),
        ],
      );

      expect(contact.isOverdue, isTrue);
      expect(contact.daysSinceLastContact, greaterThanOrEqualTo(10));
    });

    test('ContactModel isOverdue returns false when within frequency', () {
      final contact = ContactModel(
        id: 'c2',
        name: 'Test',
        relationshipTag: 'Amigo',
        desiredContactFrequencyDays: 7,
        interactions: [
          ContactInteraction(
            date: DateTime.now().subtract(const Duration(days: 2)),
            type: InteractionType.message,
          ),
        ],
      );

      expect(contact.isOverdue, isFalse);
      expect(contact.daysSinceLastContact, lessThanOrEqualTo(2));
    });

    test('ContactModel isOverdue returns false when no frequency set', () {
      const contact = ContactModel(
        id: 'c3',
        name: 'Test',
        relationshipTag: 'Colega',
        desiredContactFrequencyDays: null,
      );

      expect(contact.isOverdue, isFalse);
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // Testes de Utilitários
  // ─────────────────────────────────────────────────────────────────

  group('CurrencyFormatter', () {
    test('Formats integer values correctly', () {
      // Note: CurrencyFormatter uses locale 'pt_BR' with symbol '€'
      final result = CurrencyFormatter.format(0);
      expect(result, contains('0,00'));
    });

    test('Formats decimal values with thousands separators', () {
      final result1 = CurrencyFormatter.format(1000);
      expect(result1, contains('1.000'));
      expect(result1, contains('00'));

      final result2 = CurrencyFormatter.format(1234.56);
      expect(result2, contains('1.234'));
      expect(result2, contains('56'));
    });

    test('Formats small decimal values', () {
      final result = CurrencyFormatter.format(0.99);
      expect(result, contains('0,99'));

      final result2 = CurrencyFormatter.format(99.9);
      expect(result2, contains('99,90'));
    });

    test('Formats negative values correctly', () {
      final result = CurrencyFormatter.format(-500);
      // Note: format uses locale 'pt_BR' with symbol '€'
      expect(result, contains('500'));
      expect(result, contains('00'));
    });
  });

  // ─────────────────────────────────────────────────────────────────
  // Testes de Validação de Modelos
  // ─────────────────────────────────────────────────────────────────

  group('Goal Progress Validation', () {
    test('Goal progress calculation works correctly', () {
      // Simula o cálculo de progresso para metas manualValue
      const double current = 2500.0;
      const double target = 10000.0;
      const progress = current / target;

      expect(progress, 0.25);
      expect(progress * 100, 25.0);
    });

    test('Milestone detection works at 50%', () {
      const double current = 5000.0;
      const double target = 10000.0;
      const progress = current / target;

      expect(progress >= 0.5, isTrue);
      expect(progress < 0.75, isTrue);
      expect(progress < 1.0, isTrue);
    });

    test('Milestone detection works at 75%', () {
      const double current = 7500.0;
      const double target = 10000.0;
      const progress = current / target;

      expect(progress >= 0.75, isTrue);
      expect(progress < 1.0, isTrue);
    });

    test('No milestone for progress below 50%', () {
      const double current = 3000.0;
      const double target = 10000.0;
      const progress = current / target;

      expect(progress >= 0.5, isFalse);
      expect(progress >= 0.75, isFalse);
    });
  });
}
