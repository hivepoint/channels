library chnls_core.test;

import 'package:unittest/unittest.dart';
import 'package:chnls_core/chnls_core.dart';
import 'package:unittest/html_config.dart';
import 'dart:core';
import 'dart:async';
import 'package:googleapis_auth/auth_browser.dart';
import 'package:googleapis/gmail/v1.dart' as gmail;

AccountService accountService = new AccountService();
GroupService groupService = new GroupService();
ContactService contactService = new ContactService();
ConversationService conversationService = new ConversationService();
MessageService messageService = new MessageService();

main() {
  useHtmlConfiguration();
//    group('Google', () {
//      test('Google oauth', () {
//        return new GoogleAuth().credentials.then((AccessCredentials creds) {
//          print(creds.accessToken.data);
//        });
//      });
//    });

//    group('Gmail', () {
//      test('profile', () {
//        return new GoogleAuth().authorizedClient().then((AutoRefreshingAuthClient client){
//          gmail.GmailApi api = new gmail.GmailApi(client);
//          var request = new gmail.Draft();
//
//          api.users.drafts.create(request, "me")
//            .then((Draft draft) {
//
//          });
//          api.users.getProfile("me")
//          .then((gmail.Profile profile) {
//            print(profile);
//          });
//        });
//      });
//    });

  
  group('Gmail send', () {
    setUp(() {
      return new DatabaseService().deleteDatabase();
    });
    
    test('send', () {
      return accountService
          .addLinkedAccount("kduffie@hivepoint.com", "Kingston at HivePoint", LinkedAccountType.GMAIL)
          .then((_) => contactService.addContact(true, "kduffie@hivepoint.com", "Kingston at Hivepoint", null))
          .then((_) => contactService.addContact(false, "kingston.duffie@gmail.com", "Kingston at Gmail", null))
          .then((_) => groupService.addGroup("group1", contactService.contacts(), '#f0f'))
          .then((Group group) => group.createConversation("subject1"))
          .then((Conversation conversation) => conversation.createDraftMessage())
          .then((MessageDraft draft) => draft.updateContent('<p>This is an <b>important</b> conversation!</p>'))
          .then((MessageDraft draft) => draft.send())
          .then((Message message) => print(message));
    });
  });

  //  group('Start-from-empty tests', () {
//    setUp(() {
//      return cleanGroups().then((_) {
//        return cleanContacts();
//      });
//    });
//
//    tearDown(() {});
//
//    test('Group:  add/check', () {
//      return groupsService.addGroup("group1", null, "#f00").then((Group group) {
//        expect(group.gid.isEmpty, isFalse);
//        expect(group.tileColor, "#f00");
//      });
//    });
//
//    test('Full group', () {
//      Set<Contact> contacts = new Set<Contact>();
//      return contactsService
//          .addContact("joe@test.com", "Joe", null)
//          .then((Contact joe) {
//        contacts.add(joe);
//        return contactsService
//            .addContact("bob@test.com", "Bob", null)
//            .then((Contact bob) {
//          contacts.add(bob);
//          return groupsService
//              .addGroup("group1", contacts, "#f00")
//              .then((Group group1) {
//            return groupsService.groups().listen((Group group) {
//              expect(group.tileColor, equals("#f00"));
//            });
//          });
//        });
//      });
//    });
//  });

  group('Single group tests', () {
    setUp(() {
      return cleanGroups().then((_) => cleanContacts()).then((_) => cleanConversations()).then((_) => cleanMessages()).then((_) => cleanMessageDrafts());
    });
  });

  tearDown(() {});

//    test('Modify group', () {
//      return groupsService.groups().listen((Group group) {
//        DateTime previouslyUpdated = group.lastUpdated;
//        return group.setTileColor("#00f").then((Group updated) {
//          expect(updated.tileColor, equals("#00f"));
//          expect(updated.lastUpdated, greaterThan(previouslyUpdated));
//        });
//      });
//    });

//    test('Conversation', () {
//      return groupsService.groups().listen((Group group) {
//        return group
//            .createConversation("subject1")
//            .then((Conversation conversation) {
//          expect(conversation.gid, equals(group.gid));
//          return group.conversations
//              .toList()
//              .then((List<Conversation> conversations) {
//            expect(conversations.length, equals(1));
//            expect(conversations.first.subject, equals("subject1"));
//          });
//        });
//      });
//    });

//  test('Message lifecycle', () {
//    var verifyMessage = expectAsync((Message message) {
//      expect(message.htmlContent, equals("hello world!"));
//    });
//    groupService
//        .addGroup("group1", new List<Contact>(), "#f00")
//        .then((Group group) => group.createConversation("subject1"))
//        .then((Conversation conversation) => conversation.createDraftMessage())
//        .then((MessageDraft draft) => draft.updateContent("hello world!"))
//        .then((MessageDraft draft) => draft.send())
//        .then((Message message) => verifyMessage(message));
//  });
}

Future cleanGroups() {
  return groupService.deleteAll();
}

Future cleanContacts() {
  return contactService.deleteAll();
}

Future cleanConversations() {
  return conversationService.deleteAll();
}

Future cleanMessages() {
  return messageService.deleteAll();
}

Future cleanMessageDrafts() {
  return messageService.deleteAllDrafts();
}
