import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../data/position_sharer.dart';
import '../../../ui/kit/kit.dart';
import '../../map/map_tiles.dart';

/// «Установить вручную»: метку двигают пальцем, координаты и высоту
/// можно поправить в полях. Возвращает [Fix] или null (отмена).
class FixedPositionPicker extends StatefulWidget {
  const FixedPositionPicker({super.key, this.initial, this.altitude});

  final LatLng? initial;
  final int? altitude;

  @override
  State<FixedPositionPicker> createState() => _FixedPositionPickerState();
}

class _FixedPositionPickerState extends State<FixedPositionPicker> {
  final _map = MapController();
  late LatLng _point = widget.initial ?? defaultMapCenter;
  late final _lat = TextEditingController(text: _fmt(_point.latitude));
  late final _lon = TextEditingController(text: _fmt(_point.longitude));
  late final _alt = TextEditingController(
    text: widget.altitude?.toString() ?? '',
  );
  String? _error;

  static String _fmt(double v) => v.toStringAsFixed(6);

  @override
  void dispose() {
    _lat.dispose();
    _lon.dispose();
    _alt.dispose();
    super.dispose();
  }

  static const _pin = 56.0;
  bool _dragging = false;

  /// Палец на значке метки (значок стоит над точкой, остриём вниз).
  bool _onPin(Offset local) {
    final tip = _map.camera.latLngToScreenOffset(_point);
    return Rect.fromLTRB(
      tip.dx - _pin / 2 - 8,
      tip.dy - _pin - 8,
      tip.dx + _pin / 2 + 8,
      tip.dy + 8,
    ).contains(local);
  }

  /// Метку двигают на смещение пальца — точка под иглой не прыгает
  /// туда, где палец коснулся значка.
  void _drag(Offset delta) {
    final c = _map.camera;
    final p = c.screenOffsetToLatLng(c.latLngToScreenOffset(_point) + delta);
    setState(() {
      _point = p;
      _lat.text = _fmt(p.latitude);
      _lon.text = _fmt(p.longitude);
      _error = null;
    });
  }

  /// Ввели координаты руками — метка переезжает туда.
  void _typed() {
    final f = manualFix(_lat.text, _lon.text, '', DateTime.now());
    if (f == null) return;
    setState(() => _point = LatLng(f.lat, f.lon));
    _map.move(_point, _map.camera.zoom);
  }

  void _zoomBy(double delta) {
    final cam = _map.camera;
    _map.move(cam.center, (cam.zoom + delta).clamp(2, 19));
  }

  void _save() {
    final f = manualFix(_lat.text, _lon.text, _alt.text, DateTime.now());
    if (f == null) {
      setState(() => _error = 'Проверьте широту, долготу и высоту');
      return;
    }
    Navigator.pop(context, f);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Установить вручную'),
        actions: [TextButton(onPressed: _save, child: const Text('Сохранить'))],
      ),
      body: Column(
        children: [
          Expanded(
            // Перетаскивание ловим Listener'ом поверх карты: жесты внутри
            // маркера карта перехватывает сама. Пока тащим метку, карта
            // не двигается.
            child: Stack(
              children: [
                Positioned.fill(
                  child: Listener(
                    onPointerDown: (e) {
                      if (_onPin(e.localPosition)) {
                        setState(() => _dragging = true);
                      }
                    },
                    onPointerMove: (e) {
                      if (_dragging) _drag(e.localDelta);
                    },
                    onPointerUp: (_) => setState(() => _dragging = false),
                    onPointerCancel: (_) => setState(() => _dragging = false),
                    child: FlutterMap(
                      mapController: _map,
                      options: MapOptions(
                        initialCenter: _point,
                        initialZoom: widget.initial == null ? 9 : 15,
                        interactionOptions: InteractionOptions(
                          flags: _dragging
                              ? InteractiveFlag.none
                              : InteractiveFlag.all & ~InteractiveFlag.rotate,
                        ),
                      ),
                      children: [
                        const OsmTiles(),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _point,
                              width: _pin,
                              height: _pin,
                              alignment: Alignment.topCenter,
                              child: Icon(
                                Icons.location_pin,
                                size: _pin,
                                color: Colors.red,
                                shadows: const [
                                  Shadow(color: Colors.black54, blurRadius: 4),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Запасной способ масштаба: с мыши и трекпада на десктопе.
                Positioned(
                  right: Tokens.s16,
                  bottom: Tokens.s16,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'pickerZoomIn',
                        tooltip: 'Приблизить',
                        onPressed: () => _zoomBy(1),
                        child: const Icon(Icons.add),
                      ),
                      const SizedBox(height: Tokens.s8),
                      FloatingActionButton.small(
                        heroTag: 'pickerZoomOut',
                        tooltip: 'Отдалить',
                        onPressed: () => _zoomBy(-1),
                        child: const Icon(Icons.remove),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(Tokens.s16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Перетащите метку или введите координаты',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: Tokens.s8),
                  Row(
                    children: [
                      Expanded(child: _field(_lat, 'Широта', _typed)),
                      const SizedBox(width: Tokens.s8),
                      Expanded(child: _field(_lon, 'Долгота', _typed)),
                      const SizedBox(width: Tokens.s8),
                      SizedBox(
                        width: 96,
                        child: _field(_alt, 'Высота, м', null),
                      ),
                    ],
                  ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: Tokens.s8),
                      child: Text(
                        _error!,
                        style: TextStyle(color: scheme.error),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, VoidCallback? onDone) =>
      TextField(
        controller: c,
        decoration: InputDecoration(labelText: label, isDense: true),
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        onSubmitted: (_) => onDone?.call(),
        onEditingComplete: onDone,
      );
}
