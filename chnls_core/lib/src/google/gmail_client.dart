part of chnls_core;

class GmailClient {
  auth.AutoRefreshingAuthClient authClient;
  gmail.Profile profile;
  String linkedAccountId;
  gmail.GmailApi _api; 

  GmailClient.withAuthClient(auth.AutoRefreshingAuthClient this.authClient, String this.linkedAccountId) {
    _api = new gmail.GmailApi(authClient);    
  }
  
  Future<DeliverableMessage> sendEmail(DeliverableMessage message) {
    return _ensureProfile().then((gmail.Profile profile) => _gmailMessageFromMessage(message, profile)).then((gmail.Message gmailMessage) {
      print("About to send...");
      return _api.users.messages.send(gmailMessage, "me");
    }).catchError((e) {
      print(e);
    })
        .then((gmail.Message sentMessage) {
      print("About to fetch...");
      return _api.users.messages.get("me", sentMessage.id, format: "metadata", metadataHeaders: [EmailHeaders.MESSAGE_ID]);
    })
        .then((gmail.Message gmailMessage) {
      print("Processing fetched message...");
      gmailMessage.payload.headers.forEach((gmail.MessagePartHeader header) {
        if (header.name == EmailHeaders.MESSAGE_ID) {
          message.messageIdHeader = header.value;
        }
      });
      message.linkedAccountId = linkedAccountId;
      message.linkedAccountMessageId = gmailMessage.id;
      message.linkedAccountThreadId = gmailMessage.threadId;
      return message;
    });
  }

  Future<gmail.Profile> _ensureProfile() {
    if (profile == null) {
      return _api.users.getProfile("me").then((gmail.Profile p) {
        profile = p;
        return p;
      });
    } else {
      return new Future(() => profile);
    }
  }

  Future<gmail.Message> _gmailMessageFromMessage(Message message, gmail.Profile profile) {
    var mailBuild = new MailBuild("text/html");
    return _addHeaderFromContact(mailBuild, EmailHeaders.FROM, message.from)
        .then((_) => _addHeaderFromContacts(mailBuild, EmailHeaders.TO, message.to))
        .then((_) => _addHeaderFromContacts(mailBuild, EmailHeaders.CC, message.cc))
        .then((_) {
      mailBuild.addHeader(EmailHeaders.SUBJECT, message.subject);
      mailBuild.setContentString(message.htmlContent);
      gmail.Message result = new gmail.Message();
      result.threadId = message.linkedAccountThreadId;
      String mime = mailBuild.build();
      print(mime);
      result.raw = base64Encode(mime);
      return result;
    });
  }

  Future _addHeaderFromContacts(MailBuild builder, String headerName, Stream<Contact> stream) {
    if (stream == null) {
      return new Future(() {});
    } else {
      return stream.toList().then((List<Contact> contacts) {
        if (contacts.isNotEmpty) {
          builder.addHeader(headerName, _formatEmailAddressHeaderList(contacts));
        }
      });
    }
  }

  Future _addHeaderFromContact(MailBuild builder, String headerName, Future<Contact> future) {
    if (future == null) {
      return new Future(() {});
    } else {
      return future.then((Contact contact) {
        builder.addHeader(headerName, _formatEmailAddressHeader(contact));
      });
    }
  }

  String _formatEmailAddressHeader(Contact contact) {
    if (contact.name == null) {
      return '<' + contact.emailAddress + '>';
    } else {
      return '"' + contact.name.replaceAll('\"', '') + '" <' + contact.emailAddress + '>';
    }
  }

  String _formatEmailAddressHeaderList(Iterable<Contact> contacts) {
    StringBuffer buffer = new StringBuffer();
    bool first = true;
    contacts.forEach((Contact contact) {
      if (!first) {
        buffer.write(', ');
      }
      buffer.write(_formatEmailAddressHeader(contact));
      first = false;
    });
    return buffer.toString();
  }
}
