import '../proto/mesh.dart';

/// Аппаратные идентификаторы своей ноды: MAC, device_id, прошивка, модель.
class HardwareIds {
  const HardwareIds({this.myInfo, this.user, this.metadata, this.transport});

  final MyNodeInfo? myInfo;
  final User? user;
  final DeviceMetadata? metadata;
  final String? transport;

  static String hex(List<int> b, {String sep = ''}) =>
      b.map((x) => x.toRadixString(16).padLeft(2, '0')).join(sep);

  /// Строки «название: значение»; отсутствующее поле — «нет».
  List<(String, String)> rows() {
    String or(String v) => v.isEmpty ? 'нет' : v;
    final num = myInfo?.myNodeNum;
    final mac = user?.macaddr ?? const <int>[];
    final macHex = hex(mac);
    final id = num == null ? '' : nodeIdString(num).substring(1);
    return [
      ('Подключение', or(transport ?? '')),
      ('Node id', num == null ? 'нет' : nodeIdString(num)),
      ('Прошивка', or(metadata?.firmwareVersion ?? '')),
      (
        'Модель (hw_model)',
        or(metadata?.hwModel.name ?? user?.hwModel.name ?? ''),
      ),
      ('pio_env', or(myInfo?.pioEnv ?? '')),
      ('MAC (User.macaddr)', or(hex(mac, sep: ':'))),
      (
        'Хвост MAC = node id',
        mac.length == 6 && id.isNotEmpty
            ? (macHex.substring(4) == id ? 'да' : 'нет')
            : '—',
      ),
      ('device_id (MyNodeInfo)', or(hex(myInfo?.deviceId ?? const <int>[]))),
      ('Длина device_id', '${myInfo?.deviceId.length ?? 0} байт'),
      ('Перезагрузок', '${myInfo?.rebootCount ?? '—'}'),
    ];
  }

  String asText() => [for (final (k, v) in rows()) '$k: $v'].join('\n');
}
