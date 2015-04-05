// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library email.unittest;

import 'package:unittest/unittest.dart';
import 'package:unittest/html_config.dart';
import 'package:email/email.dart';
import 'dart:typed_data';
import 'dart:js';

main() {
  useHtmlConfiguration();
  group('emailjs tests', () {
//    test('mailbuild', () {
//      MailBuild build = new MailBuild("multipart/alternative");
//      build.addHeader("header1", "value1");
//      MailBuild part1 = build.createChild("text/plain");
//      part1.setContentString("This is a test");
//      MailBuild part2 = build.createChild("text/html");
//      part2.setContentString("<p>This is a test</p>");
//      String mime = build.build();
//      expect(mime, contains("This is a test"));
//    });

    test('mimeparse', () {
      TestMimeHandler handler = new TestMimeHandler();
      MimeParser parser = new MimeParser(handler);
      parser.write(sample1);
      parser.end();
    });
  });
}

class TestMimeHandler extends MimeHandler {
  void onHeaders(Map<String, dynamic> headers) {
    headers.keys.forEach((String key) {
      List<JsObject> values = headers[key] as List<JsObject>;
      values.forEach((var value) {
        print("header: " + key + ": " + value['value'].toString());
      });
    });
  }
  void onBodyAsString(String value) {
    print(value);
  }
  void onBodyAsBinary(Uint8List contents) {
    print(contents);
  }
  void onEnd() {
    print("--> end!");
  }
}

String get sample1 {
  return '''
MIME-Version: 1.0
Received: by 10.96.117.161 with HTTP; Sat, 4 Apr 2015 13:51:21 -0700 (PDT)
Date: Sat, 4 Apr 2015 13:51:21 -0700
Delivered-To: kingston.duffie@gmail.com
Message-ID: <CANP4uOkrwULoqz4eOjtWK82aS=eSspSsACGdbPgGMhRet9SJMw@mail.gmail.com>
Subject: Next Saturday?
From: Kingston Duffie <kingston.duffie@gmail.com>
To: Tyler Sosin <tysosin@gmail.com>
Content-Type: multipart/alternative; boundary=001a113a91e631ca390512ec3ad7

--001a113a91e631ca390512ec3ad7
Content-Type: text/plain; charset=UTF-8

Tyler,

Martin Brown, Al Sykes, and I have a tee time at 8AM next Saturday at
Stanford.  Would you like to join us?  (Mike has a foursome playing at
8:10.)

Kingston

--001a113a91e631ca390512ec3ad7
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Tyler,<div><br></div><div>Martin Brown, Al Sykes, and I ha=
ve a tee time at 8AM next Saturday at Stanford.=C2=A0 Would you like to joi=
n us? =C2=A0(Mike has a foursome playing at 8:10.)</div><div><br></div><div=
>Kingston</div></div>

--001a113a91e631ca390512ec3ad7--
''';
}
