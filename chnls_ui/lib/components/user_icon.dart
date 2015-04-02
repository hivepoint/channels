library user_icon;

import 'package:polymer/polymer.dart';
import 'package:chnls_core/chnls_core.dart';

@CustomTag('user-icon')
class UserIcon extends PolymerElement {
    UserIcon.created() : super.created();
    
    @observable String imageUrl;
    @observable String userName = "";
    @observable String userEmail = "";
    
    Contact _contact;
    
    set contact(Contact value) {
        _contact = value;
        if (hasBeenAttached) {
            refresh();
        }
    }
    
    void attached() {
        refresh();
    }
    
    void refresh() {
        if (_contact == null) {
            imageUrl = null;
            userName = "";
            userEmail = "";
        } else {
            userName = _contact.name == null ? "" : _contact.name;
            userEmail = _contact.emailAddress == null ? "" : _contact.emailAddress.toLowerCase();
            setImageBasedOnName();
        }
    }
    
    void setImageBasedOnName() {
        String name = (_contact.name == null || _contact.name.isEmpty) ? "" : _contact.name.trim().toLowerCase();
        if (name.isEmpty) {
            name = _contact.emailAddress == null ? "" : _contact.emailAddress.toLowerCase().trim();
        }
        if (name.isEmpty) {
            imageUrl = "images/avatars/avatar_unknown.png";
        } else {
            imageUrl = "images/avatars/avatar_${name.substring(0, 1)}.png"; 
        }
    }
}