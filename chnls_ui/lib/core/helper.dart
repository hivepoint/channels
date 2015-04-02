part of core_ui;

final UiHelper uiHelper = new UiHelper();

class UiHelper {
    final StreamController<bool> _navController = new StreamController<bool>();
    Stream<bool> get onNavRequested => _navController.stream;
    
    set navOpen(bool value) {
        _navController.add(value);
    }
    
    final List<String> _allDarkColors = ["#B71C1C", "#AB47BC", "#5C6BC0", "#0277BD", "#00695C", "#33691E", "#8D6E63", "#78909C", 
                                "#AD1457", "#7E57C2", "#1565C0", "#0097A7", "#388E3C", "#BF360C", "#6A1B9A", "#283593",
                                "#5D4037", "#4527A0"];
    List<String> _pendingDarkColors = [];
    
    String getRandomDarkColor() {
        if (_pendingDarkColors.isEmpty) {
            var rand = new Random();
            int x = rand.nextInt(_allDarkColors.length);
            for (int i = 0; i < _allDarkColors.length; i++) {
                if (x >= _allDarkColors.length) {
                    x = 0;
                }
                _pendingDarkColors.add(_allDarkColors[x]);
                x++;
            }
        }
        return _pendingDarkColors.removeAt(0);
    }
}