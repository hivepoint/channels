part of chnls_core;

abstract class Contact {
  String gid;
  String emailAddress;
  String name;
}

class SimpleContact extends Contact with WithGuid{
  SimpleContact(String gid, String emailAddress, String name) {
    this.gid = gid;
    this.emailAddress = emailAddress;
    this.name = name;
  }
}