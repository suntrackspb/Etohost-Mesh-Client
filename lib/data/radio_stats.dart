import 'database.dart';

/// Сводка по своей ноде для вкладки «Подключение».
class RadioStats {
  const RadioStats({
    required this.onRadio,
    required this.online,
    required this.channels,
    this.battery,
    this.channelUtil,
    this.airUtilTx,
  });

  /// Нод, услышанных в эфире (без зеркала).
  final int onRadio;

  /// Из них слышны за последние [onlineWindow].
  final int online;

  /// Активных каналов (основной и дополнительные).
  final int channels;

  /// 0–100, больше 100 — питание от сети; null — неизвестно.
  final int? battery;
  final double? channelUtil;
  final double? airUtilTx;

  static const onlineWindow = Duration(hours: 2);

  bool get onPower => (battery ?? 0) > 100;

  factory RadioStats.of(
    List<Node> nodes,
    List<MeshChannel> channels, {
    int? me,
    DateTime? now,
  }) {
    final t = now ?? DateTime.now();
    final radio = nodes.where((n) => n.onRadio && n.num != me);
    Node? own;
    for (final n in nodes) {
      if (n.num == me) own = n;
    }
    return RadioStats(
      onRadio: radio.length,
      online: radio
          .where(
            (n) =>
                n.lastHeard != null &&
                t.difference(n.lastHeard!) <= onlineWindow,
          )
          .length,
      // role: 0 — DISABLED.
      channels: channels.where((c) => c.role != 0).length,
      battery: own?.batteryLevel,
      channelUtil: own?.channelUtilization,
      airUtilTx: own?.airUtilTx,
    );
  }
}
