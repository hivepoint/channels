part of chnls_core;

String generateUid() {
  Uuid uuid = new Uuid();
  return uuid.v4();
}

@export
abstract class WithGuid {
  @export String gid;
}

