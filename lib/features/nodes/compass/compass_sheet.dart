import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/providers.dart';
import '../../../core/geo/geo.dart';
import '../../../data/node_position.dart';
import '../../../l10n/l10n.dart';
import '../node_provider.dart';
import '../nodes_page.dart';
import 'compass_controller.dart';

Future<void> showNodeCompass(BuildContext context, int num) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => NodeCompassSheet(num: num),
    );

class NodeCompassSheet extends ConsumerStatefulWidget {
  const NodeCompassSheet({super.key, required this.num, this.inputs});

  final int num;
  final CompassInputs? inputs;

  @override
  ConsumerState<NodeCompassSheet> createState() => _NodeCompassSheetState();
}

class _NodeCompassSheetState extends ConsumerState<NodeCompassSheet> {
  late final NodeCompassController _controller;
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    _controller = NodeCompassController(widget.inputs ?? DeviceCompassInputs());
    _lifecycle = AppLifecycleListener(
      onResume: () => unawaited(_controller.start()),
      onPause: () => unawaited(_controller.stop()),
      onHide: () => unawaited(_controller.stop()),
    );
    unawaited(_controller.start(requestPermission: true));
  }

  @override
  void dispose() {
    _lifecycle.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final node = ref.watch(nodeProvider(widget.num));
    final n = node.value;
    final target = n == null
        ? null
        : nodePositionBy(n, ref.watch(positionRulesProvider));
    final s = context.l10n;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.85,
        ),
        child: ListenableBuilder(
          listenable: _controller,
          builder: (context, _) {
            final c = _controller;
            final fix = c.hasFreshFix ? c.fix : null;
            final destination = target == null
                ? null
                : (lat: target.lat, lon: target.lon);
            final distance = fix == null || destination == null
                ? null
                : distanceKm(fix.position, destination) * 1000;
            final radius = precisionRadiusMeters(target?.precisionBits);
            final withinPrecision =
                distance != null &&
                distance <= math.max(radius ?? 0, fix!.accuracy);
            final bearing =
                fix == null || destination == null || withinPrecision
                ? null
                : bearingDeg(fix.position, destination);
            final heading = c.trueHeading;
            final at =
                target?.at ??
                (target?.corrected == true || target?.spoofed == true
                    ? null
                    : target?.mirror == true
                    ? n?.mirrorPositionAt
                    : n?.radioGoodAt);
            final access = c.access;
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    s.compassTitle,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    n?.longName.isNotEmpty == true
                        ? n!.longName
                        : n?.shortName ?? '',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  if (node.isLoading) const LinearProgressIndicator(),
                  if (n == null && !node.isLoading)
                    Text(s.compassTargetMissing),
                  if (n != null && target == null) Text(s.compassNoTarget),
                  const SizedBox(height: 16),
                  CompassDial(
                    heading: heading,
                    bearing: bearing,
                    angularError: distance == null
                        ? null
                        : compassAngularError(radius, distance),
                    semanticLabel: bearing == null
                        ? s.compassWaitingHeading
                        : s.compassArrowLabel('${bearing.round()}°'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    s.compassDistance(
                      distance == null
                          ? '—'
                          : context.builtIn(distanceText(distance / 1000)),
                    ),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(
                    s.compassBearing(
                      bearing == null ? '—' : '${bearing.round() % 360}°',
                    ),
                  ),
                  if (withinPrecision)
                    Text(s.compassCoincident, textAlign: TextAlign.center),
                  const SizedBox(height: 8),
                  Text(
                    radius == null
                        ? s.compassAccuracyUnknown
                        : s.compassAccuracy(
                            context.builtIn(distanceText(radius / 1000)),
                          ),
                  ),
                  if (fix != null && fix.accuracy.isFinite && fix.accuracy >= 0)
                    Text(
                      s.compassPhoneAccuracy(
                        context.builtIn(distanceText(fix.accuracy / 1000)),
                      ),
                    ),
                  Text(
                    at == null
                        ? s.compassUnknownTime
                        : s.compassUpdated(context.builtIn(lastHeardText(at))),
                  ),
                  if (target?.corrected == true)
                    _warning(s.compassTargetCorrected),
                  if (target?.spoofed == true) _warning(s.compassTargetSpoofed),
                  if (access == CompassLocationAccess.disabled) ...[
                    _warning(s.compassLocationOff),
                    TextButton(
                      onPressed: () => c.inputs.openSettings(permission: false),
                      child: Text(s.compassOpenSettings),
                    ),
                  ] else if (access == CompassLocationAccess.denied ||
                      access == CompassLocationAccess.deniedForever) ...[
                    _warning(s.compassNoPermission),
                    TextButton(
                      onPressed: () =>
                          access == CompassLocationAccess.deniedForever
                          ? c.inputs.openSettings(permission: true)
                          : c.start(requestPermission: true),
                      child: Text(
                        access == CompassLocationAccess.deniedForever
                            ? s.compassOpenSettings
                            : s.compassAllowLocation,
                      ),
                    ),
                  ] else if (access == CompassLocationAccess.allowed &&
                      fix == null)
                    _warning(
                      c.locationError
                          ? s.compassLocationError
                          : s.compassWaitingGps,
                    ),
                  if (c.headingError)
                    _warning(s.compassSensorError)
                  else if (c.heading?.available == false)
                    _warning(s.compassNoSensor)
                  else if (fix != null && heading == null)
                    _warning(s.compassWaitingHeading),
                  if (c.heading?.calibrate == true)
                    _warning(s.compassCalibration),
                  if (c.locationError ||
                      c.headingError ||
                      (fix != null &&
                          c.heading?.available == true &&
                          heading == null))
                    TextButton(
                      onPressed: () => c.start(),
                      child: Text(s.compassRetry),
                    ),
                  const SizedBox(height: 8),
                  Text(
                    s.compassTrueNorth,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _warning(String text) => Padding(
    padding: const EdgeInsets.only(top: 12),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
    ),
  );
}

/// Dial rotates around geographic north; the arrow disappears without a heading.
class CompassDial extends StatelessWidget {
  const CompassDial({
    super.key,
    required this.heading,
    required this.bearing,
    required this.angularError,
    required this.semanticLabel,
  });
  final double? heading;
  final double? bearing;
  final double? angularError;
  final String semanticLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    label: semanticLabel,
    child: ExcludeSemantics(
      child: SizedBox.square(
        dimension: 240,
        child: CustomPaint(
          painter: _CompassPainter(
            heading: heading,
            bearing: bearing,
            angularError: angularError,
            scheme: Theme.of(context).colorScheme,
          ),
        ),
      ),
    ),
  );
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({
    required this.heading,
    required this.bearing,
    required this.angularError,
    required this.scheme,
  });
  final double? heading, bearing, angularError;
  final ColorScheme scheme;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 8;
    final paint = Paint()
      ..color = scheme.outline
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(center, radius, paint);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-(heading ?? 0) * math.pi / 180);
    for (var d = 0; d < 360; d += 10) {
      final major = d % 90 == 0;
      canvas.save();
      canvas.rotate(d * math.pi / 180);
      paint
        ..color = d == 0 ? scheme.error : scheme.outline
        ..strokeWidth = major ? 3 : 1;
      canvas.drawLine(
        Offset(0, -radius),
        Offset(0, -radius + (major ? 14 : 7)),
        paint,
      );
      canvas.restore();
    }
    for (final (label, degrees) in [
      ('N', 0),
      ('E', 90),
      ('S', 180),
      ('W', 270),
    ]) {
      final angle = degrees * math.pi / 180;
      final offset = Offset(math.sin(angle), -math.cos(angle)) * (radius - 30);
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.rotate((heading ?? 0) * math.pi / 180);
      final text = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: degrees == 0 ? scheme.error : scheme.onSurface,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      text.paint(canvas, Offset(-text.width / 2, -text.height / 2));
      canvas.restore();
    }
    if (heading != null && bearing != null) {
      canvas.rotate(bearing! * math.pi / 180);
      final error = angularError;
      if (error != null && error > 0) {
        paint
          ..style = PaintingStyle.fill
          ..color = scheme.primary.withValues(alpha: 0.12);
        canvas.drawArc(
          Rect.fromCircle(center: Offset.zero, radius: radius - 5),
          (-90 - error) * math.pi / 180,
          error * 2 * math.pi / 180,
          true,
          paint,
        );
      }
      paint
        ..style = PaintingStyle.fill
        ..color = scheme.primary;
      final arrow = Path()
        ..moveTo(0, -radius * 0.65)
        ..lineTo(17, -radius * 0.32)
        ..lineTo(5, -radius * 0.37)
        ..lineTo(5, radius * 0.35)
        ..lineTo(-5, radius * 0.35)
        ..lineTo(-5, -radius * 0.37)
        ..lineTo(-17, -radius * 0.32)
        ..close();
      canvas.drawPath(arrow, paint);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassPainter old) =>
      old.heading != heading ||
      old.bearing != bearing ||
      old.angularError != angularError ||
      old.scheme != scheme;
}
