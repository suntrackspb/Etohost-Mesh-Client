import 'dart:io';

import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

/// Windows и Linux: крестик прячет окно в трей (если включено), иконка
/// в трее возвращает его, «Выход» в её меню закрывает приложение.
class DesktopTray with WindowListener, TrayListener {
  DesktopTray({this.onError, this.onFirstClose});

  static bool get supported => Platform.isWindows || Platform.isLinux;

  final void Function(Object e)? onError;

  /// Спросить при закрытии окна, что делать: true — в трей, false — выйти,
  /// null — передумали. Сам решает, спрашивать ли (только первый раз).
  final Future<bool?> Function()? onFirstClose;

  bool _ready = false;
  bool _wanted = false;
  bool _shown = false;

  Future<void> init() async {
    await windowManager.ensureInitialized();
    windowManager.addListener(this);
    trayManager.addListener(this);
    _ready = true;
    await _apply();
  }

  /// Сворачивать в трей при закрытии окна.
  Future<void> setCloseToTray(bool on) async {
    _wanted = on;
    if (_ready) await _apply();
  }

  Future<void> _apply() async {
    if (_wanted && !_shown) {
      try {
        await trayManager.setIcon(
          Platform.isWindows ? 'assets/tray/icon.ico' : 'assets/tray/icon.png',
        );
        // На Linux (AppIndicator) подсказки нет — вызов бросает исключение.
        if (Platform.isWindows) await trayManager.setToolTip('Meshex');
        await trayManager.setContextMenu(
          Menu(
            items: [
              MenuItem(key: 'show', label: 'Показать'),
              MenuItem.separator(),
              MenuItem(key: 'exit', label: 'Выход'),
            ],
          ),
        );
        _shown = true;
      } catch (e) {
        // Нет трея (например, GNOME без AppIndicator) — закрываем как обычно.
        onError?.call(e);
      }
    } else if (!_wanted && _shown) {
      await trayManager.destroy();
      _shown = false;
    }
    await windowManager.setPreventClose(_shown);
  }

  /// Вывести окно на передний план: из трея, из свёрнутого, из-под других.
  Future<void> bringToFront() async {
    if (!_ready) return;
    if (await windowManager.isMinimized()) await windowManager.restore();
    await windowManager.show();
    await windowManager.focus();
  }

  Future<void> _exit() async {
    await windowManager.setPreventClose(false);
    if (_shown) await trayManager.destroy();
    await windowManager.destroy();
  }

  @override
  Future<void> onWindowClose() async {
    if (!_shown) return;
    final ask = onFirstClose;
    final toTray = ask == null ? true : await ask();
    if (toTray == null) return;
    if (!toTray) return _exit();
    await windowManager.hide();
  }

  // На Linux щелчки по значку не приходят: AppIndicator сам показывает меню.
  @override
  void onTrayIconMouseDown() => bringToFront();

  @override
  void onTrayIconRightMouseDown() => trayManager.popUpContextMenu();

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show':
        bringToFront();
      case 'exit':
        _exit();
    }
  }

  void dispose() {
    windowManager.removeListener(this);
    trayManager.removeListener(this);
  }
}
