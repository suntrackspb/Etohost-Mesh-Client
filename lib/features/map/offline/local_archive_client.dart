import 'dart:io';

import 'package:http/http.dart' as http;

/// Адаптирует Range-запросы PMTiles к локальному файлу. Не открывает сеть.
class LocalArchiveClient extends http.BaseClient {
  LocalArchiveClient(this.file);
  final File file;
  bool _closed = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    if (_closed) throw StateError('Archive client closed');
    final range = request.headers.entries
        .where((e) => e.key.toLowerCase() == 'range')
        .firstOrNull
        ?.value;
    final match = RegExp(r'^bytes=(\d+)-(\d+)$').firstMatch(range ?? '');
    if (match == null) throw ArgumentError('A bounded byte range is required');
    final start = int.parse(match[1]!);
    final end = int.parse(match[2]!);
    final length = await file.length();
    if (start >= length || end < start) {
      return http.StreamedResponse(const Stream.empty(), 416);
    }
    final stop = (end + 1).clamp(0, length);
    // Each read owns its handle: simultaneous tile requests cannot move
    // another request's file position.
    final handle = await file.open();
    try {
      await handle.setPosition(start);
      final bytes = await handle.read(stop - start);
      return http.StreamedResponse(
        Stream.value(bytes),
        206,
        contentLength: bytes.length,
        headers: {'content-range': 'bytes $start-${stop - 1}/$length'},
      );
    } finally {
      await handle.close();
    }
  }

  @override
  void close() => _closed = true;
}
