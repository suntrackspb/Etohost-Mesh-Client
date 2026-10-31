import 'package:flutter/services.dart';

abstract final class MeshexWidgets {
  static const channel = MethodChannel('ru.meshex.app/widgets');
  static Future<void> publish(
    String json, {
    Uint8List? map,
    Uint8List? route,
  }) => channel.invokeMethod('publish', {
    'json': json,
    'map': map,
    'route': route,
  });
  static Future<List<String>> activeKinds() async =>
      await channel.invokeListMethod<String>('activeKinds') ?? [];
  static Future<String?> takeRoute() =>
      channel.invokeMethod<String>('takeRoute');
}
