part of chnls_core;

String generateUid() {
  Uuid uuid = new Uuid();
  return uuid.v4();
}

@export
abstract class WithGuid {
  @export String gid;

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
