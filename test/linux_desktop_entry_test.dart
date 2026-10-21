import 'package:etohost_mesh/core/desktop/linux_desktop_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('.desktop связывает окно с иконкой по app id', () {
    final t = linuxDesktopEntry(
      exe: '/opt/m/etohost_mesh',
      icon: '/opt/m/i.png',
    );
    expect(t, contains('Exec="/opt/m/etohost_mesh"'));
    expect(t, contains('Icon=/opt/m/i.png'));
    expect(t, contains('StartupWMClass=ru.etohost.mesh'));
  });
}
