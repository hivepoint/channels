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
  group('Start-from-empty tests', () {
    setUp(() {
      return cleanGroups().then((_) {
        return cleanContacts();
      });
    });

    tearDown(() {});

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

  group('Single group tests', () {
    setUp(() {
      return cleanGroups().then((_) {
        return cleanContacts().then((_) {
          Set<Contact> contacts = new Set<Contact>();
          return contactsService
              .addContact("joe@test.com", "Joe", null)
              .then((Contact contact) {
            contacts.add(contact);
            return groupsService.addGroup("group1", contacts, "#0f0");
          });
        });
      });
    });

    tearDown(() {});

    test('Modify group', () {
      return groupsService.groups().listen((Group group) {
        DateTime previouslyUpdated = group.lastUpdated;
        return group.setTileColor("#00f").then((Group updated) {
          expect(updated.tileColor, equals("#00f"));
          expect(updated.lastUpdated, greaterThan(previouslyUpdated));
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
