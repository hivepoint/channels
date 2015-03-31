library chnls_core.test;

import 'package:unittest/unittest.dart';
import 'package:chnls_core/chnls_core.dart';
import 'package:unittest/html_config.dart';
import 'dart:core';

main() {
  useHtmlConfiguration();
  group('All tests', () {
    setUp(() {
    });

//    test ('Auth test', () {
//      GoogleAuth auth = new GoogleAuth();
//      var callback1 = expectAsync((String token) {
//          print(token);
//          expect(token.isEmpty, isFalse);          
//      });
//       auth.authorize().then(callback1);
//    });
    
    test('Message test:  add/check', () {
      MessageService msgs = new MessageService();
      msgs.clearAllMessages();
      msgs.addMessage("joe@test.com", "hello world 1");
      msgs.addMessage("joe@test.com", "hello world 2");
      msgs.addMessage("joe@test.com", "hello world 3");
      var callback = expectAsync((msgs) {
        print(msgs.toString());
        expect(msgs.length, 3);
      });
      msgs.getMessages().toList().then(callback);
      print("done!");
    });
  });
}
