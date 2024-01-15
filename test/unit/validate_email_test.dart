import 'package:flutter_test/flutter_test.dart';
import 'package:vehicle_rental/utils/helper.dart';

void main() {
  group('Email Validation Tests', () {
    test('Valid Email Test', () {
      expect(validateEmail('test@example.com'), true);
      expect(validateEmail('user@domain.co'), true);
      expect(validateEmail('john.doe@company.org'), true);
    });

    test('Invalid Email Test', () {
      expect(validateEmail('invalidemail'), false);
      expect(validateEmail('user@.com'), false);
      expect(validateEmail('user@domain.'), false);
    });

    test('Edge Case Tests', () {
      expect(validateEmail(''), false);
      expect(validateEmail('test @example.com'), false);
      expect(validateEmail('  test@example.com  '), false);
      expect(validateEmail('user@@domain.com'), false);
    });
  });
}