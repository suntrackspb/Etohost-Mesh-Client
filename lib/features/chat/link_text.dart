import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/links.dart';

/// Текст сообщения с кликабельными ссылками (открываются во внешнем браузере).
class LinkText extends StatefulWidget {
  const LinkText(this.text, {super.key});

  final String text;

  @override
  State<LinkText> createState() => _LinkTextState();
}

class _LinkTextState extends State<LinkText> {
  final _taps = <TapGestureRecognizer>[];

  void _clear() {
    for (final t in _taps) {
      t.dispose();
    }
    _taps.clear();
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _clear();
    final parts = splitLinks(widget.text);
    if (parts.every((p) => p.link == null)) return Text(widget.text);
    final color = Theme.of(context).colorScheme.primary;
    return Text.rich(
      TextSpan(
        children: [
          for (final p in parts)
            if (p.link case final uri?)
              TextSpan(
                text: p.text,
                style: TextStyle(
                  color: color,
                  decoration: TextDecoration.underline,
                  decorationColor: color,
                ),
                recognizer:
                    (TapGestureRecognizer()
                          ..onTap = () => launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          ))
                        .also(_taps.add),
              )
            else
              TextSpan(text: p.text),
        ],
      ),
    );
  }
}

extension<T> on T {
  T also(void Function(T) f) {
    f(this);
    return this;
  }
}
