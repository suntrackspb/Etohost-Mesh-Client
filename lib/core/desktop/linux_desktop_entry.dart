import 'dart:io';

/// Совпадает с APPLICATION_ID в linux/CMakeLists.txt (tool/patch_platforms.py).
const linuxAppId = 'ru.meshex.app';

/// Текст .desktop-файла: по нему панель (особенно на Wayland) находит
/// иконку окна — gtk_window_set_icon там не работает.
String linuxDesktopEntry({required String exe, required String icon}) =>
    '''
[Desktop Entry]
Type=Application
Name=Meshex
Comment=Meshtastic client
Exec="$exe"
Icon=$icon
Terminal=false
Categories=Network;
StartupWMClass=$linuxAppId
''';

/// Linux: кладёт .desktop в ~/.local/share/applications, чтобы у окна в
/// панели была наша иконка. Сборка — архив без установщика, поэтому при
/// каждом запуске обновляем путь (архив могли перенести).
Future<void> installLinuxDesktopEntry() async {
  if (!Platform.isLinux) return;
  final home = Platform.environment['HOME'];
  if (home == null) return;
  final exe = File(Platform.resolvedExecutable);
  final icon = '${exe.parent.path}/data/flutter_assets/assets/icon/window.png';
  if (!File(icon).existsSync()) return;
  final dir = Directory(
    '${Platform.environment['XDG_DATA_HOME'] ?? '$home/.local/share'}/applications',
  );
  final file = File('${dir.path}/$linuxAppId.desktop');
  final text = linuxDesktopEntry(exe: exe.path, icon: icon);
  if (file.existsSync() && file.readAsStringSync() == text) return;
  await dir.create(recursive: true);
  await file.writeAsString(text);
}
