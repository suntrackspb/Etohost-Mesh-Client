import 'package:meshex/core/desktop/linux_desktop_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('.desktop связывает окно с иконкой по app id', () {
    final t = linuxDesktopEntry(exe: '/opt/m/meshex', icon: '/opt/m/i.png');
    expect(t, contains('Exec="/opt/m/meshex"'));
    expect(t, contains('Icon=/opt/m/i.png'));
    expect(t, contains('StartupWMClass=ru.meshex.app'));
  });
}
