library chnls_core.test;

import 'package:unittest/unittest.dart';
import 'package:chnls_core/chnls_core.dart';
import 'package:unittest/html_config.dart';
import 'dart:core';
import 'dart:async';

GroupsService groupsService = new GroupsService();
ContactsService contactsService = new ContactsService();

main() {
  useHtmlConfiguration();
  group('All tests', () {

//    test ('Auth test', () {
//      GoogleAuth auth = new GoogleAuth();
//      var callback1 = expectAsync((String token) {
//          print(token);
//          expect(token.isEmpty, isFalse);
//      });
//       auth.authorize().then(callback1);
//    });

//    test('Message test:  add/check', () {
//      MessageService msgs = new MessageService();
//      msgs.clearAllMessages();
//      msgs.addMessage("joe@test.com", "hello world 1");
//      msgs.addMessage("joe@test.com", "hello world 2");
//      msgs.addMessage("joe@test.com", "hello world 3");
//      var callback = expectAsync((msgs) {
//        print(msgs.toString());
//        expect(msgs.length, 3);
//      });
//      msgs.getMessages().toList().then(callback);
//      print("done!");
//    });

//    test('Group test:  add/check', () {
//      var callback = expectAsync((List<Group> groups) {
//        expect(groups.length, equals(2));
//      });
//      GroupsService sut = new GroupsService();
//      var contacts = new List<Contact>();
//      sut.deleteAll().then((_) {
//        sut.addGroup("group1", contacts, "#fff").then((_) {
//          sut.addGroup("group2", contacts, "#777").then((_) {
//            sut.groups().toList().then(callback);
//          });
//        });
//      });
//    });

    setUp(() {
      return cleanGroups().then((_) {
        return cleanContacts();
      });
    });

    tearDown(() {
    });

    test('Group:  add/check', () {
      return groupsService.addGroup("group1", null, "#f00").then((Group group) {
        expect(group.gid.isEmpty, isFalse);
        expect(group.tileColor, "#f00");
      });
    });

    test('Full group', () {
      Set<Contact> contacts = new Set<Contact>();
      return contactsService
          .addContact("joe@test.com", "Joe", null)
          .then((Contact joe) {
        contacts.add(joe);
        return contactsService
            .addContact("bob@test.com", "Bob", null)
            .then((Contact bob) {
          contacts.add(bob);
          return groupsService
              .addGroup("group1", contacts, "#f00")
              .then((Group group1) {
            return groupsService.groups().listen((Group group) {
              expect(group.tileColor, equals("#f00"));
            });
          });
        });
      });
    });
  });
}

Future cleanGroups() {
  return groupsService.deleteAll();
}
Future cleanContacts() {
  return contactsService.deleteAll();
}
