import 'package:flutter_test/flutter_test.dart';
import 'package:oremusapp/app/commons/email_validator.dart';

void main() {
  group('EmailValidator.validate', () {
    group('emails valides', () {
      const valid = [
        'user@example.com',
        'first.last@example.com',
        'user+tag@example.com',
        'user_name@example.co.uk',
        'a@example.com',
        'user@sub.example.com',
        'amourssou11@gmail.com',
        "info@oremus.ci",
        'utilisateur@exemple.fr',
        'user-name@example-site.com',
        'user@example.museum',
      ];

      for (final email in valid) {
        test('$email → valide', () {
          expect(EmailValidator.validate(email), isTrue);
        });
      }
    });

    group('emails invalides', () {
      const invalid = [
        '',
        'plainaddress',
        '@no-local.com',
        'no-at.com',
        'user@',
        'user@.com',
        'user@@example.com',
        'user@-example.com',
        'user @example.com',
        'user@exa mple.com',
        'user.@example.com',
        '.user@example.com',
        'user..name@example.com',
      ];

      for (final email in invalid) {
        test('"$email" → invalide', () {
          expect(EmailValidator.validate(email), isFalse);
        });
      }
    });

    test('email > 254 caractères → invalide', () {
      final tooLong = '${'a' * 250}@b.co';
      expect(EmailValidator.validate(tooLong), isFalse);
    });

    test('caractères atom autorisés dans la partie locale', () {
      // !#$%&'*+-/=?^_`{|}~ sont valides en partie locale (RFC 5322).
      expect(EmailValidator.validate("user!name@example.com"), isTrue);
      expect(EmailValidator.validate("user+tag@example.com"), isTrue);
      expect(EmailValidator.validate("user_name@example.com"), isTrue);
    });

    test('TLD numérique pur → invalide (pas de support punycode)', () {
      expect(EmailValidator.validate('user@example.123'), isFalse);
    });

    test('international (allowInternational=true par défaut)', () {
      // L'accentué dans le domain doit passer puisque allowInternational=true.
      expect(EmailValidator.validate('user@éxample.fr'), isTrue);
    });
  });
}
