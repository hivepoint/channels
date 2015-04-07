// Copyright (c) 2015, HivePoint, Inc. All rights reserved. 

library chnls_core;

import 'dart:async';
import 'dart:html';
import 'dart:indexed_db' as idb;
import 'dart:collection';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:exportable/exportable.dart';
import 'package:googleapis_auth/auth_browser.dart' as auth;
import 'package:googleapis/gmail/v1.dart' as gmail;
import 'package:uuid/uuid.dart';
import 'package:email/email.dart';

part 'src/chnls_core_msgs.dart';
part 'src/lifecycle.dart';

part 'src/groups/group_service.dart';
part 'src/groups/group.dart';

part 'src/contacts/contact_service.dart';
part 'src/contacts/contact.dart';

part 'src/conversations/conversation_service.dart';
part 'src/conversations/conversation.dart';

part 'src/messages/message_service.dart';
part 'src/messages/message.dart';
part 'src/messages/message_draft.dart';

part 'src/accounts/account_service.dart';
part 'src/accounts/linked_account.dart';

part 'src/db/database_service.dart';
part 'src/db/collection.dart';
part 'src/db/groups.dart';
part 'src/db/contacts.dart';
part 'src/db/conversations.dart';
part 'src/db/messages.dart';
part 'src/db/message_drafts.dart';
part 'src/db/linked_accounts.dart';

part 'src/google/google_auth.dart';
part 'src/google/gmail_client.dart';
part 'src/util/constants.dart';

part 'src/util/utils.dart';
