import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/formatters/formatters.dart';

void main() {
  group('Formatters.capitalize', () {
    test('should capitalize first letter and lowercase rest', () {
      expect(Formatters.capitalize('hello'), 'Hello');
      expect(Formatters.capitalize('HELLO'), 'Hello');
      expect(Formatters.capitalize('hELLO'), 'Hello');
    });

    test('should return empty for empty string', () {
      expect(Formatters.capitalize(''), '');
    });
  });

  group('Formatters.capitalizeWords', () {
    test('should capitalize each word', () {
      expect(Formatters.capitalizeWords('john doe'), 'John Doe');
      expect(Formatters.capitalizeWords('JOHN DOE'), 'John Doe');
    });

    test('should return empty for empty string', () {
      expect(Formatters.capitalizeWords(''), '');
    });
  });

  group('Formatters.formatDate', () {
    test('should return empty for null date', () {
      expect(Formatters.formatDate(null), '');
    });

    test('should format date with default format', () {
      final date = DateTime(2024, 1, 15);
      expect(Formatters.formatDate(date), 'Jan 15, 2024');
    });

    test('should format date with custom format', () {
      final date = DateTime(2024, 1, 15, 14, 30);
      expect(
        Formatters.formatDate(date, format: 'MM/dd/yyyy HH:mm'),
        '01/15/2024 14:30',
      );
    });
  });

  group('Formatters.truncate', () {
    test('should return full text when within max length', () {
      expect(Formatters.truncate('Hello', 10), 'Hello');
    });

    test('should truncate and add suffix when exceeds max length', () {
      expect(Formatters.truncate('Hello World', 5), 'Hello...');
    });
  });

  group('Formatters.phone', () {
    test('should format 10-digit phone', () {
      expect(Formatters.phone('1234567890'), '(123) 456-7890');
    });

    test('should format 11-digit US phone', () {
      expect(Formatters.phone('12345678901'), '+1 (234) 567-8901');
    });

    test('should return empty for null', () {
      expect(Formatters.phone(null), '');
    });

    test('should return original for unknown format', () {
      expect(Formatters.phone('123'), '123');
    });
  });
}
