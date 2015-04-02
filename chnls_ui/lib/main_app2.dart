import 'package:polymer/polymer.dart';
import "core/core_ui.dart";
import 'package:core_elements/core_drawer_panel.dart';
import "components/feed_view.dart";

@CustomTag('main-app2')
class MainApp2 extends PolymerElement {
    MainApp2.created() : super.created();
    
    @observable String toolbarTitle = "All channels";
    @observable int pageIndex = 0;
    
    CoreDrawerPanel _drawer;
    FeedView _feedView;
    List _subs = [];
    
    void attached() {
        super.attached();
        _drawer = shadowRoot.querySelector("#drawerPanel");
        _feedView = shadowRoot.querySelector("#feedView");
        
        _subs.add(uiHelper.onNavRequested.listen((bool value) {
            if (value) {
                _drawer.openDrawer();
            } else {
                _drawer.closeDrawer();
            }
        }));
        
        _subs.add(router.onOpenCollectionPage.listen((_) {
            pageIndex = 0;
        }));
        
        _subs.add(router.onOpenGroup.listen((Collection c) {
            _feedView.collection = c;
            pageIndex = 1;
        }));
    }
    
    void detached() {
        for (var s in _subs) {
            s.cancel();
        }
        _subs.clear;
        super.detached();
    }
}