import 'package:polymer/polymer.dart';
import "core/core_ui.dart";
import 'package:core_elements/core_drawer_panel.dart';

@CustomTag('main-app2')
class MainApp2 extends PolymerElement {
    MainApp2.created() : super.created();
    
    @observable String toolbarTitle = "All channels";
    @observable int pageIndex = 0;
    
    CoreDrawerPanel _drawer;
    List _subs = [];
    
    void attached() {
        _drawer = shadowRoot.querySelector("#drawerPanel");
        _subs.add(uiHelper.onNavRequested.listen((bool value) {
            if (value) {
                _drawer.openDrawer();
            } else {
                _drawer.closeDrawer();
            }
        }));
    }
    
    void detached() {
        for (var s in _subs) {
            s.cancel();
        }
        _subs.clear;
    }
}