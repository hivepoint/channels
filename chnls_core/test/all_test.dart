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

    test('Message test:  add/check', () {
      MessageService msgs = new MessageService();
      msgs.clearAllMessages();
      msgs.addMessage("hello world 1");
      msgs.addMessage("hello world 2");
      msgs.addMessage("hello world 3");
      var callback = expectAsync((msgs) {
        print(msgs.toString());
        expect(msgs.length, 3);
      });
      msgs.getMessages().toList().then(callback);
      print("done!");
    });
  });
}
