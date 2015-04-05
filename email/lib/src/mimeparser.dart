part of email;

class NameValue {
  String name;
  String value;
}

abstract class MimeHandler {
  void onHeaders(Map<String, dynamic> headers);
  void onBodyAsString(String value);
  void onBodyAsBinary(Uint8List contents);
  void onEnd();
}

class MimeParser {
  MimeHandler handler;
  JsObject _o;

  MimeParser(MimeHandler this.handler) {
    _o = new JsObject(context['MimeParser'], []);
    
    _o['onheader'] = (node) {
      JsMap map = new JsMap.fromJsObject(node['headers']);
      handler.onHeaders(map);
    };
    _o['onbody'] = (parser, content) {
      if (content is String) {
        handler.onBodyAsString(content.toString());
      } else {
        handler.onBodyAsBinary(content);
      }
    };
    _o['onend'] = () {
      handler.onEnd();
    };
  }

  MimeParser._fromJs(var o) {
    this._o = o;
  }

  bool write(String chunk) => _o.callMethod('write', [chunk]);
  
  bool writeBytes(Uint8List chunk) => _o.callMethod('write', [chunk]);

  void end() => _o.callMethod('end', []);
}

class JsMap implements Map<String, dynamic> {
  final JsObject _jsObject;
  JsMap.fromJsObject(this._jsObject);

  operator [](String key) => _jsObject[key];
  void operator []=(String key, value) {
    _jsObject[key] = value;
  }
  remove(String key) {
    final value = this[key];
    _jsObject.deleteProperty(key);
    return value;
  }
  Iterable<String> get keys => context['Object'].callMethod('keys', [_jsObject]);

  // use Maps to implement functions
  bool containsValue(value) => Maps.containsValue(this, value);
  bool containsKey(String key) => keys.contains(key);
  putIfAbsent(String key, ifAbsent()) => Maps.putIfAbsent(this, key, ifAbsent);
  void addAll(Map<String, dynamic> other) {
    if (other != null) {
      other.forEach((k, v) => this[k] = v);
    }
  }
  void clear() => Maps.clear(this);
  void forEach(void f(String key, value)) => Maps.forEach(this, f);
  Iterable get values => Maps.getValues(this);
  int get length => Maps.length(this);
  bool get isEmpty => Maps.isEmpty(this);
  bool get isNotEmpty => Maps.isNotEmpty(this);
}
