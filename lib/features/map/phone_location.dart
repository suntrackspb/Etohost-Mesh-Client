import 'package:meshex/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../app/position_service.dart';
import '../../data/position_sharer.dart';

/// Разовый запрос по нажатию, независимо от передачи позиции в эфир.
class PhoneLocationButton extends StatefulWidget {
  const PhoneLocationButton({
    super.key,
    required this.onLocated,
    this.locate = phoneFix,
  });

  final ValueChanged<LatLng> onLocated;
  final Future<Fix> Function() locate;

  @override
  State<PhoneLocationButton> createState() => _PhoneLocationButtonState();
}

class _PhoneLocationButtonState extends State<PhoneLocationButton> {
  bool _busy = false;

  Future<void> _locate() async {
    final strings = context.l10n;
    setState(() => _busy = true);
    try {
      final fix = await widget.locate();
      if (!mounted) return;
      widget.onLocated(LatLng(fix.lat, fix.lon));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            strings.couldNotDetermineLocation_e5f6db((e).toString()),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => FloatingActionButton.small(
    heroTag: 'phoneLocation',
    tooltip: context.l10n.myLocationRefresh_d26be2,
    onPressed: _busy ? null : _locate,
    child: _busy
        ? const SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : const Icon(Icons.person_pin_circle_outlined),
  );
}

/// Отдельный слой: позиция телефона не участвует в фильтрах и кластерах нод.
class PhoneLocationLayer extends StatelessWidget {
  const PhoneLocationLayer({super.key, required this.position});

  final LatLng position;

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: MarkerLayer(
      markers: [
        Marker(
          point: position,
          width: 32,
          height: 32,
          child: Semantics(
            label: context.l10n.myLocation_e77573,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue.withValues(alpha: 0.2),
              ),
              padding: const EdgeInsets.all(6),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.blue,
                  border: Border.all(color: Colors.white, width: 3),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
