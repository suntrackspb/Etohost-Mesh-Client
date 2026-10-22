import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/toasts.dart';
import '../../app/images_providers.dart';
import '../../app/providers.dart';
import '../../core/links.dart';
import '../../data/images/image_uploader.dart';
import '../../ui/kit/kit.dart';

/// Превью картинок из ссылок сообщения (только свои сервисы, см.
/// [imagePreview]). Размер фиксированный — лента не прыгает при загрузке.
class MessageImages extends ConsumerWidget {
  const MessageImages(this.text, {super.key});

  final String text;

  static const _w = 240.0;
  static const _h = 180.0;

  /// Превью декодируется в эту ширину (×3 под плотные экраны).
  static const cacheWidth = 720;

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
          cacheWidth: MessageImages.cacheWidth,
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

/// Картинка на весь экран: масштаб пальцами, свайп вниз — закрыть
/// (когда не увеличена), открыть в браузере.
class _FullImage extends ConsumerStatefulWidget {
  const _FullImage(this.url);

  final Uri url;

  @override
  ConsumerState<_FullImage> createState() => _FullImageState();
}

class _FullImageState extends ConsumerState<_FullImage> {
  final _zoom = TransformationController();
  var _zoomed = false;
  var _dy = 0.0;

  /// Сколько протянуть вниз, чтобы закрыть.
  static const _closeAt = 120.0;

  /// Своя картинка i.jab.su (есть токен удаления); null — чужая или не знаем.
  UploadedImage? _own;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final id = jabImageId(widget.url);
    final images = ref.read(imageUploadsProvider);
    if (id != null && images != null) {
      images.own(id).then((v) {
        if (mounted) setState(() => _own = v);
      });
    }
  }

  Future<void> _run(Future<void> Function() action, String done) async {
    setState(() => _busy = true);
    try {
      await action();
      toasts.show(done);
    } catch (e) {
      toasts.error('$e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _delete(ImageUploads images, UploadedImage img) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Удалить картинку?'),
        content: const Text(
          'Ссылка в отправленных сообщениях перестанет открываться.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final nav = Navigator.of(context);
    await _run(() async {
      await images.delete(img);
      // Превью в ленте взято из кэша — убрать, чтобы показалось «недоступна».
      final u = widget.url.toString();
      NetworkImage(u).evict();
      ResizeImage(NetworkImage(u), width: MessageImages.cacheWidth).evict();
      nav.pop();
    }, 'Картинка удалена');
  }

  Future<void> _report(ImageUploads images, String id) async {
    final reason = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Пожаловаться на картинку?'),
        content: TextField(
          controller: reason,
          maxLength: 200,
          decoration: const InputDecoration(
            hintText: 'Что не так (необязательно)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Пожаловаться'),
          ),
        ],
      ),
    );
    final text = reason.text.trim();
    reason.dispose();
    if (ok != true || !mounted) return;
    await _run(() => images.report(id, text), 'Жалоба отправлена');
  }

  List<Widget> _actions() {
    final images = ref.watch(imageUploadsProvider);
    final id = jabImageId(widget.url);
    if (images == null || id == null) return const [];
    if (_busy) {
      return const [
        Padding(
          padding: EdgeInsets.all(14),
          child: SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ];
    }
    final own = _own;
    return [
      if (own != null)
        IconButton(
          tooltip: 'Удалить',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _delete(images, own),
        )
      else
        IconButton(
          tooltip: 'Пожаловаться',
          icon: const Icon(Icons.flag_outlined),
          onPressed: () => _report(images, id),
        ),
    ];
  }

  @override
  void dispose() {
    _zoom.dispose();
    super.dispose();
  }

  void _onZoomEnd(ScaleEndDetails _) {
    final z = _zoom.value.getMaxScaleOnAxis() > 1.01;
    if (z != _zoomed) setState(() => _zoomed = z);
  }

  void _onDragEnd(DragEndDetails d) {
    if (_dy > _closeAt || (d.primaryVelocity ?? 0) > 800) {
      Navigator.of(context).pop();
    } else {
      setState(() => _dy = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final fade = (1 - _dy / 400).clamp(0.3, 1.0);
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: fade),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        actions: [
          ..._actions(),
          IconButton(
            tooltip: 'Открыть в браузере',
            icon: const Icon(Icons.open_in_browser),
            onPressed: () =>
                launchUrl(widget.url, mode: LaunchMode.externalApplication),
          ),
        ],
      ),
      body: GestureDetector(
        // Увеличенную картинку палец двигает, а не закрывает.
        onVerticalDragUpdate: _zoomed
            ? null
            : (d) => setState(() => _dy = (_dy + d.delta.dy).clamp(0, 1e4)),
        onVerticalDragEnd: _zoomed ? null : _onDragEnd,
        child: Transform.translate(
          offset: Offset(0, _dy),
          child: InteractiveViewer(
            transformationController: _zoom,
            maxScale: 6,
            panEnabled: _zoomed,
            onInteractionEnd: _onZoomEnd,
            child: Center(child: Image.network(widget.url.toString())),
          ),
        ),
      ),
    );
  }
}
