import 'dart:convert';
import 'dart:typed_data';
import 'package:pointycastle/export.dart';
import '../models/encrypted_payload.dart';

class DecryptionService {
  static String decryptText(EncryptedPayload payload) {
    try {
      // Decode the base64 encoded key and IV
      final keyBytes = base64.decode(payload.key);
      final ivBytes = base64.decode(payload.iv);

      // The encrypted text from CryptoJS is in a specific format
      // We need to extract the actual ciphertext
      final cipherText = _extractCipherText(payload.encryptedText);

      // Perform AES-256-CBC decryption
      final decryptedBytes = _aesDecrypt(cipherText, keyBytes, ivBytes);

      // Remove PKCS7 padding and convert back to string
      final unpaddedBytes = _removePkcs7Padding(decryptedBytes);
      return utf8.decode(unpaddedBytes);
    } catch (e) {
      throw Exception('Decryption failed: $e');
    }
  }

  static Uint8List _extractCipherText(String cryptoJsString) {
    // CryptoJS outputs in a format like "U2FsdGVkX1..." which is base64
    // but contains salt info. For our case, we assume it's just the ciphertext
    return base64.decode(cryptoJsString);
  }

  static Uint8List _aesDecrypt(Uint8List encrypted, Uint8List key, Uint8List iv) {
    // Initialize AES cipher in CBC mode
    final cipher = CBCBlockCipher(AESEngine());
    final params = ParametersWithIV(KeyParameter(key), iv);

    cipher.init(false, params); // false for decryption

    final decrypted = Uint8List(encrypted.length);
    var offset = 0;

    while (offset < encrypted.length) {
      offset += cipher.processBlock(encrypted, offset, decrypted, offset);
    }

    return decrypted;
  }

  static Uint8List _removePkcs7Padding(Uint8List data) {
    if (data.isEmpty) return data;

    final paddingLength = data.last;
    if (paddingLength == 0 || paddingLength > 16) {
      throw Exception('Invalid PKCS7 padding');
    }

    // Verify padding is correct
    for (int i = data.length - paddingLength; i < data.length; i++) {
      if (data[i] != paddingLength) {
        throw Exception('Invalid PKCS7 padding');
      }
    }

    return data.sublist(0, data.length - paddingLength);
  }

  static EncryptedPayload parseQrCode(String qrData) {
    try {
      final jsonData = json.decode(qrData) as Map<String, dynamic>;
      return EncryptedPayload.fromJson(jsonData);
    } catch (e) {
      throw Exception('Invalid QR code format: $e');
    }
  }
}