import 'package:flutter_test/flutter_test.dart';
import 'package:qr_decrypt_app/services/decryption_service.dart';

void main() {
  group('DecryptionService Tests', () {
    test('should parse QR code JSON correctly', () {
      const qrData = '''
      {
        "encryptedText": "U2FsdGVkX1+abc123",
        "key": "SGVsbG8gV29ybGQ=",
        "iv": "MTIzNDU2Nzg5MA==",
        "version": "1.0"
      }
      ''';

      final payload = DecryptionService.parseQrCode(qrData);

      expect(payload.encryptedText, 'U2FsdGVkX1+abc123');
      expect(payload.key, 'SGVsbG8gV29ybGQ=');
      expect(payload.iv, 'MTIzNDU2Nzg5MA==');
      expect(payload.version, '1.0');
    });

    test('should throw exception for invalid JSON', () {
      const invalidQrData = 'not valid json';

      expect(
        () => DecryptionService.parseQrCode(invalidQrData),
        throwsA(isA<Exception>()),
      );
    });
  });
}