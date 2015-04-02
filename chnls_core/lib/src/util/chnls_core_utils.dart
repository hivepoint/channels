part of chnls_core;

String generateUid() {
  Uuid uuid = new Uuid();
  return uuid.v5(Uuid.NAMESPACE_URL, "www.channels.cc");
}

@export
abstract class WithGuid {
  @export String gid;
}

