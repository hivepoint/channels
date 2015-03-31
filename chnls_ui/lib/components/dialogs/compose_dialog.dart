import 'dart:html';
import 'package:polymer/polymer.dart';
import 'package:paper_elements/paper_autogrow_textarea.dart';
import 'package:paper_elements/paper_input_decorator.dart';

@CustomTag('compose-dialog')
class ComposeDialog extends PolymerElement {
    @published String heading = null;
    @published bool showing = false;
    
    PaperAutogrowTextarea _textContainer;
    TextAreaElement _text;
    PaperInputDecorator _decorator;
    
    ComposeDialog.created() : super.created();
    
    void attached() {
        _textContainer = shadowRoot.querySelector("#textContainer");
        _text = shadowRoot.querySelector("#text");
        _decorator = shadowRoot.querySelector("#composeDecorator");
    }
    
    void onSend(MouseEvent e) {
    }
    
    void onDialogOpen(var e) {
        if (e.detail) {
            _text.value = "";
            _textContainer.update();
            _decorator.updateLabelVisibility("");
        }
    }
}