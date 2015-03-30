part of core_ui;

class Place {
  String _key;
  final Map _properties = {};

  Place({String placeKey}) {
    _key = placeKey;
  }

  Place.fromToken(String token) {
    _key = "";
    if (token != null && token.isNotEmpty) {
      if (token.startsWith("#")) {
        token = token.substring(1);
      }
    }
    int colonAt = token.indexOf(":");
    String initial;
    String rest;
    if (colonAt >= 0) {
      initial = token.substring(0, colonAt);
      rest = token.substring(colonAt + 1);
    } else {
      initial = token;
      rest = "";
    }
    if (initial != null && initial.isNotEmpty) {
      _key = initial;
      if (rest != null && rest.length > 0) {
        List<String> split = rest.split("&");
        for (String s in split) {
          if (s != null && s.length > 0) {
            int x = s.indexOf("=");
            if (x > 0) {
              String name = s.substring(0, x);
              String value = s.substring(x + 1);
              if (value == null) {
                value = "";
              }
              value = Uri.decodeQueryComponent(value);
              setProperty(name, value);
            }
          }
        }
      }
    }
  }

  String get key => _key == null ? "" : _key;
  Iterable<String> get propertyNames => _properties.keys;

  void setProperty(String name, String value) {
    _properties[name] = value;
  }

  String getProperty(String name) {
    return _properties[name];
  }

  bool operator ==(Place other) {
    if (other == null) {
      return false;
    }

    if ((_key != other.key) ||
        (_properties.length != other._properties.length)) {
      return false;
    }

    for (String key in _properties.keys) {
      if (other._properties.containsKey(key)) {
        if (getProperty(key) != other.getProperty(key)) {
          return false;
        }
      } else {
        return false;
      }
    }

    return true;
  }
}
