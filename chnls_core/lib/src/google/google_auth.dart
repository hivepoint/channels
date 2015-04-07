part of chnls_core;

class GoogleAuth {
  static const String CLIENT_ID =
      "227332334996-vkncjc14bc3k0lsgfcl3hbfsf6ejjhb7.apps.googleusercontent.com";
  static const String CLIENT_SECRET = "xTThiyFWAZ-kBOqlGEFlayB3";
  static final GoogleAuth _singleton = new GoogleAuth._internal();
  factory GoogleAuth() => _singleton;
  GoogleAuth._internal() {}

  auth.AccessCredentials _credentials;

  Future<auth.AccessCredentials> get credentials {
    var completer = new Completer<auth.AccessCredentials>();
    if (_credentials == null ||
        _credentials.accessToken.expiry.millisecondsSinceEpoch <
            new DateTime.now().millisecondsSinceEpoch) {
      var id = new auth.ClientId(CLIENT_ID, CLIENT_SECRET);
      var scopes = ["https://www.googleapis.com/auth/gmail.readonly", "email"];
      auth.BrowserOAuth2Flow authFlow;
      auth.createImplicitBrowserFlow(id, scopes)
          .then((auth.BrowserOAuth2Flow flow) {
        authFlow = flow;
        flow.obtainAccessCredentialsViaUserConsent().then(
            (auth.AccessCredentials credentials) => completer.complete(credentials));
      }).whenComplete(() => authFlow.close());
    } else {
      completer.complete(_credentials);
    }
    return completer.future;
  }
  
  Future<auth.AutoRefreshingAuthClient> authorizedClient() {
    var id = new auth.ClientId(CLIENT_ID, CLIENT_SECRET);
    var scopes = ["https://www.googleapis.com/auth/gmail.readonly", "email"];
    return auth.createImplicitBrowserFlow(id, scopes)
        .then((auth.BrowserOAuth2Flow flow) {
      return flow.clientViaUserConsent(immediate: true).catchError((_) {
        return flow.clientViaUserConsent(immediate: false);
      }, test: (error) => error is auth.UserConsentException);
    });
  }

}
