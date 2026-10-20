import 'dart:ffi';
import 'dart:io';

/// Модель устройства без плагинов: iOS/macOS — sysctl `hw.machine`
/// («iPhone15,4»), Android — `getprop`. null, если не получилось.
Future<String?> deviceModel() async {
  try {
    if (Platform.isIOS) return _sysctl('hw.machine');
    if (Platform.isMacOS) return _sysctl('hw.model');
    if (Platform.isAndroid) {
      Future<String> prop(String k) async =>
          ((await Process.run('getprop', [k])).stdout as String).trim();
      final m =
          '${await prop('ro.product.manufacturer')} '
          '${await prop('ro.product.model')}';
      return m.trim().isEmpty ? null : m.trim();
    }
  } catch (_) {}
  return null;
}

typedef _SysctlC =
    Int32 Function(
      Pointer<Uint8>,
      Pointer<Uint8>,
      Pointer<IntPtr>,
      Pointer<Void>,
      IntPtr,
    );
typedef _SysctlDart =
    int Function(
      Pointer<Uint8>,
      Pointer<Uint8>,
      Pointer<IntPtr>,
      Pointer<Void>,
      int,
    );

@Native<Pointer<Void> Function(IntPtr)>(symbol: 'malloc')
external Pointer<Void> _malloc(int size);

@Native<Void Function(Pointer<Void>)>(symbol: 'free')
external void _free(Pointer<Void> p);

String? _sysctl(String name) {
  final fn = DynamicLibrary.process().lookupFunction<_SysctlC, _SysctlDart>(
    'sysctlbyname',
  );
  const cap = 256;
  final key = _malloc(name.length + 1).cast<Uint8>();
  final buf = _malloc(cap).cast<Uint8>();
  final len = _malloc(sizeOf<IntPtr>()).cast<IntPtr>();
  try {
    for (var i = 0; i < name.length; i++) {
      key[i] = name.codeUnitAt(i);
    }
    key[name.length] = 0;
    len.value = cap;
    if (fn(key, buf, len, nullptr, 0) != 0) return null;
    final bytes = <int>[];
    for (var i = 0; i < len.value && buf[i] != 0; i++) {
      bytes.add(buf[i]);
    }
    return String.fromCharCodes(bytes);
  } finally {
    _free(key.cast());
    _free(buf.cast());
    _free(len.cast());
  }
}
