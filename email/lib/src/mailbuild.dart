part of email;

class MailBuild {
  JsObject _o;

  MailBuild(String contentType, {String filename: null}) {
    _o = new JsObject(context['mailbuild'], [contentType, new JsObject.jsify({"filename": filename})]);
  }

  MailBuild._fromJs(var o) {
    this._o = o;
  }

  MailBuild createChild(String contentType, {String filename: null}) => new MailBuild._fromJs(_o.callMethod('createChild', [contentType, new JsObject.jsify({"filename": filename})]));

  MailBuild appendChild(MailBuild child) => new MailBuild._fromJs(_o.callMethod('appendChild', [child._o]));

  MailBuild replace(String contentType, {String filename: null}) => new MailBuild._fromJs(_o.callMethod('replace', [contentType, new JsObject.jsify({"filename": filename})]));

  MailBuild remove() => new MailBuild._fromJs(_o.callMethod('remove', []));

  MailBuild setHeader(String key, String value) => new MailBuild._fromJs(_o.callMethod('setHeader', [key, value]));

  MailBuild addHeader(String key, String value) => new MailBuild._fromJs(_o.callMethod('addHeader', [key, value]));

  String getHeader(String key) => _o.callMethod('getHeader', [key]);

  MailBuild setContentString(String content) => new MailBuild._fromJs(_o.callMethod('setContent', [content]));

  MailBuild setContentBinary(Uint8List content) => new MailBuild._fromJs(_o.callMethod('setContent', [content]));

  String build() => _o.callMethod('build', []); 
}
