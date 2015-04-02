part of chnls_core;

class GoogleAuth {
  static const String CLIENT_ID = "227332334996-vkncjc14bc3k0lsgfcl3hbfsf6ejjhb7.apps.googleusercontent.com";
  static const String CLIENT_SECRET = "xTThiyFWAZ-kBOqlGEFlayB3";
  static final GoogleAuth _singleton = new GoogleAuth._internal();
  factory GoogleAuth() => _singleton;  
  GoogleAuth._internal() {
  }
  
  Future<String> authorize() {
    var id = new ClientId(CLIENT_ID, CLIENT_SECRET);
    var scopes = ["https://www.googleapis.com/auth/gmail.readonly"];
    var completer = new Completer<String>();
     createImplicitBrowserFlow(id, scopes)
        .then((BrowserOAuth2Flow flow) {
          flow.obtainAccessCredentialsViaUserConsent()
            .then((AccessCredentials credentials) {
              flow.close();
              completer.complete(credentials.accessToken.data);
          });
    });  
     return completer.future;
  }
}

