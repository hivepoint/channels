// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library email.unittest;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'package:email/email.dart';

main() {
  useHtmlConfiguration();
  group('A group of tests', () {
    test('First Test', () {
      MailBuild build = new MailBuild("multipart/alternative");
      build.addHeader("header1", "value1");
      MailBuild part1 = build.createChild("text/plain");
      part1.setContentString("This is a test");
      MailBuild part2 = build.createChild("text/html");
      part2.setContentString("<p>This is a test</p>");
      String mime = build.build();
      print(mime);
    });
  });
}
