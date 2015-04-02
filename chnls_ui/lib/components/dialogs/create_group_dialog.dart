library create_group_dialog;

import 'dart:async';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_input.dart';
import 'package:core_elements/core_input.dart';
import 'package:paper_elements/paper_input_decorator.dart';
import "../../core/core_ui.dart";

@CustomTag("create-group-dialog")
class CreateGroupDialog extends PolymerElement {
    CreateGroupDialog.created() : super.created();
    
    @published bool showing = false;
    CoreInput _name;
    PaperInput _description;
    PaperInputDecorator _decorator;
    
    final StreamController<Collection> _controller = new StreamController<Collection>();
    Stream<Collection> get onGroupCreated => _controller.stream;
    
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
            String desc = _description.value.trim();
            showing = false;
            _controller.add(new Collection(name, desc, uiHelper.getRandomDarkColor()));
        }
    }
}