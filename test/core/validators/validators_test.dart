import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/core/validators/validators.dart';

void main() {
  group('Validators.email', () {
    test('should return error for null value', () {
      expect(Validators.email(null), isNotNull);
    });

    test('should return error for empty string', () {
      expect(Validators.email(''), isNotNull);
    });

    test('should return error for invalid email', () {
      expect(Validators.email('notanemail'), isNotNull);
      expect(Validators.email('@domain.com'), isNotNull);
      expect(Validators.email('user@'), isNotNull);
    });

    test('should return null for valid email', () {
      expect(Validators.email('test@test.com'), isNull);
      expect(Validators.email('user.name@domain.co.uk'), isNull);
    });
  });

  group('Validators.password', () {
    test('should return error for null value', () {
      expect(Validators.password(null), isNotNull);
    });

    test('should return error for empty string', () {
      expect(Validators.password(''), isNotNull);
    });

    test('should return error for short password', () {
      expect(Validators.password('Ab1'), isNotNull);
    });

    test('should return error when missing uppercase', () {
      expect(Validators.password('abcdefgh1'), isNotNull);
    });

    test('should return error when missing number', () {
      expect(Validators.password('Abcdefgh'), isNotNull);
    });

    test('should return null for valid password', () {
      expect(Validators.password('Password1'), isNull);
      expect(Validators.password('MyPass123'), isNull);
    });
  });

  group('Validators.name', () {
    test('should return error for null value', () {
      expect(Validators.name(null), isNotNull);
    });

    test('should return error for empty string', () {
      expect(Validators.name(''), isNotNull);
    });

    test('should return error for single character', () {
      expect(Validators.name('A'), isNotNull);
    });

    test('should return null for valid name', () {
      expect(Validators.name('John'), isNull);
    });

    test('should use custom field name in error', () {
      final result = Validators.name('', fieldName: 'First Name');
      expect(result, contains('First Name'));
    });
  });

  group('Validators.phone', () {
    test('should return null for null value', () {
      expect(Validators.phone(null), isNull);
    });

    test('should return null for empty string', () {
      expect(Validators.phone(''), isNull);
    });

    test('should return null for valid phone', () {
      expect(Validators.phone('+1234567890'), isNull);
    });

    test('should return error for invalid phone', () {
      expect(Validators.phone('abc'), isNotNull);
    });
  });

  group('Validators.nonEmpty', () {
    test('should return error for null', () {
      expect(Validators.nonEmpty(null), isNotNull);
    });

    test('should return error for empty string', () {
      expect(Validators.nonEmpty(''), isNotNull);
    });

    test('should return null for non-empty', () {
      expect(Validators.nonEmpty('hello'), isNull);
    });
  });
}
