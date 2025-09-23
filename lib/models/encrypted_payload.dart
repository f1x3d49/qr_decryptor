class EncryptedPayload {
  final String encryptedText;
  final String key;
  final String iv;
  final String version;

  EncryptedPayload({
    required this.encryptedText,
    required this.key,
    required this.iv,
    required this.version,
  });

  factory EncryptedPayload.fromJson(Map<String, dynamic> json) {
    return EncryptedPayload(
      encryptedText: json['encryptedText'] as String,
      key: json['key'] as String,
      iv: json['iv'] as String,
      version: json['version'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'encryptedText': encryptedText,
      'key': key,
      'iv': iv,
      'version': version,
    };
  }
}