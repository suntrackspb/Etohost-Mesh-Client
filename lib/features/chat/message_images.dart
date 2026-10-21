import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/providers.dart';
import '../../core/links.dart';
import '../../ui/kit/kit.dart';

/// Превью картинок из ссылок сообщения (только свои сервисы, см.
/// [imagePreview]). Размер фиксированный — лента не прыгает при загрузке.
class MessageImages extends ConsumerWidget {
  const MessageImages(this.text, {super.key});

  final String text;

  static const _w = 240.0;
  static const _h = 180.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!(ref.watch(showImagesProvider).value ?? true)) {
      return const SizedBox.shrink();
    }
    final urls = imagePreviews(text);
    if (urls.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: Tokens.s4),
      child: Wrap(
        spacing: Tokens.s4,
        runSpacing: Tokens.s4,
        children: [for (final u in urls) _Thumb(u)],
      ),
    );
  }
}

class _Thumb extends StatelessWidget {
  const _Thumb(this.url);

  final Uri url;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget box(Widget child) => Container(
      width: MessageImages._w,
      height: MessageImages._h,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: child,
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(Tokens.radiusM),
      child: GestureDetector(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            fullscreenDialog: true,
            builder: (_) => _FullImage(url),
          ),
        ),
        child: Image.network(
          url.toString(),
          width: MessageImages._w,
          height: MessageImages._h,
          fit: BoxFit.cover,
          // Декодируем в размер превью, а не в полный (до 2048 px).
          cacheWidth: (MessageImages._w * 3).round(),
          loadingBuilder: (_, child, p) => p == null
              ? child
              : box(
                  const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
          errorBuilder: (_, _, _) => box(
            Text(
              'Картинка недоступна\n(удалена или истёк срок)',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
        ),
      ),
    );
  }
}

/// Картинка на весь экран: масштаб пальцами, открыть в браузере.
class _FullImage extends StatelessWidget {
  const _FullImage(this.url);

  final Uri url;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Colors.black,
    appBar: AppBar(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      actions: [
        IconButton(
          tooltip: 'Открыть в браузере',
          icon: const Icon(Icons.open_in_browser),
          onPressed: () => launchUrl(url, mode: LaunchMode.externalApplication),
        ),
      ],
    ),
    body: InteractiveViewer(
      maxScale: 6,
      child: Center(child: Image.network(url.toString())),
    ),
  );
}
