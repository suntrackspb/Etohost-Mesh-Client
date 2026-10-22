import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

/// Полный выбор эмодзи для реакции. Возвращает эмодзи или null (закрыли).
/// Недавние ведём сами (быстрая панель), поэтому вкладки «недавние» нет.
Future<String?> pickEmoji(BuildContext context) {
  final scheme = Theme.of(context).colorScheme;
  final bg = scheme.surfaceContainerLow;
  return showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    backgroundColor: bg,
    builder: (ctx) => SafeArea(
      child: EmojiPicker(
        onEmojiSelected: (_, e) => Navigator.pop(ctx, e.emoji),
        config: Config(
          height: 320,
          locale: const Locale('ru'),
          emojiViewConfig: EmojiViewConfig(
            backgroundColor: bg,
            columns: 8,
            emojiSizeMax: 30,
          ),
          categoryViewConfig: CategoryViewConfig(
            backgroundColor: bg,
            initCategory: Category.SMILEYS,
            recentTabBehavior: RecentTabBehavior.NONE,
            indicatorColor: scheme.primary,
            iconColor: scheme.onSurfaceVariant,
            iconColorSelected: scheme.primary,
          ),
          bottomActionBarConfig: BottomActionBarConfig(
            showBackspaceButton: false,
            backgroundColor: bg,
            buttonColor: bg,
            buttonIconColor: scheme.onSurfaceVariant,
          ),
          searchViewConfig: SearchViewConfig(
            backgroundColor: bg,
            buttonIconColor: scheme.onSurfaceVariant,
            hintText: 'Поиск',
          ),
        ),
      ),
    ),
  );
}
