part of chnls_core;

String generateUid() {
  Uuid uuid = new Uuid();
  return uuid.v4();
}

abstract class WithGuid {
  String get gid;

  int get hashCode {
    return gid.hashCode;
  }

  bool operator ==(other) {
    if (other is WithGuid) {
      return gid == other.gid;
    } else {
      return false;
    }
  }
}

class DuplicateException implements Exception {
  final String message;
  DuplicateException(this.message);
  String toString() => message;
}

String base64Encode(String value) {
  var bytes = UTF8.encode(value);
  return CryptoUtils.bytesToBase64(bytes, urlSafe: true);
}
