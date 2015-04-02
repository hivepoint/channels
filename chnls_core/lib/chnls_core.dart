// Copyright (c) 2015, HivePoint, Inc. All rights reserved. 

library chnls_core;

import 'dart:async';
import 'dart:html';
import 'dart:indexed_db' as idb;
import 'package:exportable/exportable.dart';
import 'package:googleapis_auth/auth_browser.dart';
import 'package:uuid/uuid.dart';

part 'src/chnls_core_msgs.dart';
part 'src/chnls_core_service.dart';

part 'src/groups/chnls_core_groups_service.dart';
part 'src/groups/chnls_core_group.dart';

part 'src/contacts/chnls_core_contact_service.dart';
part 'src/contacts/chnls_core_contact.dart';

part 'src/conversations/chnls_core_conversation.dart';
part 'src/conversations/chnls_core_message.dart';

part 'src/db/chnls_core_database_service.dart';
part 'src/db/chnls_core_database_collection.dart';
part 'src/db/chnls_core_database_groups.dart';

part 'src/google/chnls_core_google.dart';

part 'src/util/chnls_core_utils.dart';
