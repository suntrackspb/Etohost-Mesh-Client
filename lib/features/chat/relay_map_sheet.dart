import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Встроенный браузер есть на iOS, macOS и Android; на прочих — внешний.
bool get _hasWebView =>
    !kIsWeb && (Platform.isIOS || Platform.isMacOS || Platform.isAndroid);

/// Карта ретрансляций сообщения: шторка снизу со встроенным браузером.
Future<void> showRelayMap(BuildContext context, Uri url) async {
  if (!_hasWebView) {
    await launchUrl(url, mode: LaunchMode.externalApplication);
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    enableDrag: false,
    showDragHandle: true,
    builder: (_) =>
        FractionallySizedBox(heightFactor: 0.92, child: _RelayMap(url: url)),
  );
}

class _RelayMap extends StatefulWidget {
  const _RelayMap({required this.url});

  final Uri url;

  @override
  State<_RelayMap> createState() => _RelayMapState();
}

class _RelayMapState extends State<_RelayMap> {
  late final WebViewController _c;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _c = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) {
            if (mounted) setState(() => _loading = false);
          },
        ),
      )
      ..loadRequest(widget.url);
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          IconButton(
            tooltip: 'Открыть в браузере',
            icon: const Icon(Icons.open_in_browser),
            onPressed: () =>
                launchUrl(widget.url, mode: LaunchMode.externalApplication),
          ),
          Expanded(
            child: Text(
              'Ретрансляции',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Готово'),
          ),
        ],
      ),
      if (_loading) const LinearProgressIndicator(),
      Expanded(
        child: WebViewWidget(
          controller: _c,
          // Карта сама обрабатывает жесты (сдвиг, масштаб).
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(EagerGestureRecognizer.new),
          },
        ),
      ),
    ],
  );
}
