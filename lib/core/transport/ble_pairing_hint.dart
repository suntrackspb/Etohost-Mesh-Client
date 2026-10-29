import 'dart:async';

/// Таймаут не доказывает проблему сопряжения: предлагаем проверить её.
String? blePairingHint(Object error, String deviceId, {required bool linux}) {
  if (!linux) return null;
  final text = error.toString().toLowerCase();
  if (error is! TimeoutException &&
      !text.contains('timeout') &&
      !text.contains('timed out') &&
      !text.contains('inprogress')) {
    return null;
  }
  // В команды подставляем только MAC, а не произвольный идентификатор.
  final mac = RegExp(r'^[0-9a-fA-F]{2}(:[0-9a-fA-F]{2}){5}$').hasMatch(deviceId)
      ? deviceId
      : '<MAC ноды>';
  return 'Bluetooth не завершил операцию. Если на ноде включён PIN, '
      'возможно, нужно завершить сопряжение в Linux. '
      'Отключите автоподключение и нажмите «Отключить», затем '
      'выполните в терминале:\n\n'
      'bluetoothctl\n'
      'remove $mac\n'
      'agent KeyboardOnly\n'
      'default-agent\n'
      'pair $mac\n'
      'trust $mac\n'
      'disconnect $mac\n'
      'quit\n\n'
      'При запросе введите PIN ноды. Команда remove удаляет прежнее '
      'сопряжение. После успешного pair подключитесь снова в приложении. '
      'Если сопряжение уже выполнено, проверьте питание и доступность ноды.';
}
