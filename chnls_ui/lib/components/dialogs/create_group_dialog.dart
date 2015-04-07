library create_group_dialog;

import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_input.dart';
import 'package:core_elements/core_input.dart';
import 'package:paper_elements/paper_input_decorator.dart';
import 'package:chnls_core/chnls_core.dart';

@CustomTag("create-group-dialog")
class CreateGroupDialog extends PolymerElement {
    CreateGroupDialog.created() : super.created();
    
    @published bool showing = false;
    CoreInput _name;
    PaperInput _description;
    PaperInputDecorator _decorator;
    
    final StreamController<Group> _controller = new StreamController<Group>();
    Stream<Group> get onGroupCreated => _controller.stream;
    
    void attached() {
        super.attached();
        _name = shadowRoot.querySelector("#name");
        _description = shadowRoot.querySelector("#description");
        _decorator = shadowRoot.querySelector("#nameDecorator");
    }
    
    void onDialogOpen(var e) {
        if (e.detail) {
            _name.value = "";
            _description.value = "";
            _decorator.updateLabelVisibility("");
            _decorator.isInvalid = false;
        }
    }
    
    void onInputChanged(var e) {
        _decorator.isInvalid = false;
    }
    
    void onCreate(var event) {
        String name = _name.value.trim();
        if (name.isEmpty) {
            _decorator.isInvalid = true;
        } else {
            _decorator.isInvalid = false;
            showing = false;
            GroupService service = new GroupService();
            service.addGroup(name, new ContactService().contacts(), "#777").then((Group g) {
                _controller.add(g);
            });
        }
    }
}