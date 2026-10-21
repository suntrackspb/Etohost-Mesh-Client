import '../core/proto/mesh.dart';
import 'database.dart';

/// Оценка сигнала, как в Android-клиенте (LoraSignalIndicator).
enum SignalQuality { good, fair, bad, none }

/// Роль ноды по имени из прошивки: CLIENT_MUTE → ClientMute.
String roleName(int role) {
  final r = Config_DeviceConfig_Role.valueOf(role);
  if (r == null) return '$role';
  return r.name
      .toLowerCase()
      .split('_')
      .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
      .join();
}

/// Пресет ноды: из зеркала, а для слышимых в эфире — наш собственный.
String? nodePreset(Node n, String? ownPreset) =>
    n.modemPreset ?? (n.onRadio ? ownPreset : null);

/// Порог демодуляции SNR для пресета (по spreading factor).
double presetSnrLimit(String? preset) => switch (preset) {
  'ShortTurbo' || 'ShortFast' => -7.5,
  'ShortSlow' => -10,
  'MediumFast' || 'MediumTurbo' => -12.5,
  'MediumSlow' => -15,
  'LongSlow' || 'VLongSlow' || 'VeryLongSlow' => -20,
  _ => -17.5,
};

/// SNR относительно порога пресета: запас > 0 — хорошо, до −5.5 — средне,
/// до −7.5 — плохо.
SignalQuality snrQuality(double snr, String? preset) {
  final margin = snr - presetSnrLimit(preset);
  if (margin > 0) return SignalQuality.good;
  if (margin > -5.5) return SignalQuality.fair;
  if (margin >= -7.5) return SignalQuality.bad;
  return SignalQuality.none;
}

/// RSSI по фиксированным порогам Android.
SignalQuality rssiQuality(int rssi) {
  if (rssi > -115) return SignalQuality.good;
  if (rssi > -120) return SignalQuality.fair;
  if (rssi > -126) return SignalQuality.bad;
  return SignalQuality.none;
}

/// Слышали недавно (подсвечивается в списке).
bool heardRecently(DateTime? t, [DateTime? now]) =>
    t != null && (now ?? DateTime.now()).difference(t).inHours < 2;

/// Нода из зеркала на другом пресете нам по эфиру недоступна — в списке и
/// на карте её не показываем. Слышимые в эфире и без пресета — всегда.
bool onOwnPreset(Node n, String? ownPreset) =>
    n.onRadio ||
    n.modemPreset == null ||
    ownPreset == null ||
    n.modemPreset == ownPreset;
