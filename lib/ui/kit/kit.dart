/// Дизайн-кит: экраны собираются только из этих компонентов и токенов.
library;

import 'package:flutter/material.dart';

import '../tokens.dart';

export '../tokens.dart';

/// Карточка-секция с необязательным заголовком (как группы в настройках iOS).
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    this.footer,
    required this.children,
  });

  final String? title;

  /// Пояснение под секцией (как footer в iOS Form).
  final String? footer;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Tokens.s16,
              Tokens.s16,
              Tokens.s16,
              Tokens.s8,
            ),
            child: Text(
              title!.toUpperCase(),
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0) const Divider(height: 1, indent: Tokens.s16),
                children[i],
              ],
            ],
          ),
        ),
        if (footer != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
              Tokens.s16,
              Tokens.s4,
              Tokens.s16,
              Tokens.s8,
            ),
            child: Text(
              footer!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
      ],
    );
  }
}

/// Строка списка. Единая точка для наведения/контекстного меню на десктопе.
class MeshTile extends StatelessWidget {
  const MeshTile({
    super.key,
    required this.title,
    this.subtitle,
    this.titleExtra,
    this.subtitleWidget,
    this.leading,
    this.trailing,
    this.onTap,
    this.onLongPress,
    this.selected = false,
  });

  final String title;
  final String? subtitle;

  /// Значки сразу после заголовка.
  final Widget? titleExtra;

  /// Подзаголовок-виджет вместо [subtitle].
  final Widget? subtitleWidget;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final bool selected;

  @override
  Widget build(BuildContext context) => ListTile(
    title: titleExtra == null
        ? Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)
        : Row(
            children: [
              Flexible(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 4),
              titleExtra!,
            ],
          ),
    subtitle:
        subtitleWidget ??
        (subtitle == null
            ? null
            : Text(subtitle!, maxLines: 2, overflow: TextOverflow.ellipsis)),
    leading: leading,
    trailing:
        trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
    onTap: onTap,
    onLongPress: onLongPress,
    selected: selected,
  );
}

/// Пустое состояние экрана.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.text,
    this.action,
  });

  final IconData icon;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(Tokens.s24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: cs.onSurfaceVariant),
            const SizedBox(height: Tokens.s12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(color: cs.onSurfaceVariant),
            ),
            if (action != null) ...[
              const SizedBox(height: Tokens.s16),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}

/// Точка статуса с подписью.
class StatusDot extends StatelessWidget {
  const StatusDot({super.key, required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(Icons.circle, size: 10, color: color),
      const SizedBox(width: Tokens.s8),
      Text(label),
    ],
  );
}

/// Две колонки на широком экране, одна — на узком.
/// На узком экране [detail] открывается отдельным маршрутом, здесь показывается только [list].
class SplitView extends StatelessWidget {
  const SplitView({
    super.key,
    required this.list,
    this.detail,
    this.placeholder,
  });

  final Widget list;
  final Widget? detail;
  final Widget? placeholder;

  static bool isWide(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= Tokens.wideBreakpoint;

  @override
  Widget build(BuildContext context) {
    if (!isWide(context)) return list;
    return Row(
      children: [
        SizedBox(width: Tokens.listPaneWidth, child: list),
        const VerticalDivider(width: 1),
        Expanded(child: detail ?? placeholder ?? const SizedBox()),
      ],
    );
  }
}

/// Цвет ноды: младшие 24 бита node_id (как в iOS-клиенте Etohost).
Color nodeColor(int nodeNum) => Color(0xFF000000 | (nodeNum & 0xFFFFFF));

/// Читаемый цвет текста поверх [bg]: чёрный на светлом, белый на тёмном
/// (яркость 0.299R + 0.587G + 0.114B > 0.6, как contrastingText в iOS).
Color contrastingText(Color bg) =>
    0.299 * bg.r + 0.587 * bg.g + 0.114 * bg.b > 0.6
    ? Colors.black
    : Colors.white;

/// Круглая аватарка ноды: цвет по node_id, короткое имя внутри.
class NodeAvatar extends StatelessWidget {
  const NodeAvatar({
    super.key,
    required this.nodeNum,
    this.shortName,
    this.size = 40,
  });

  final int nodeNum;
  final String? shortName;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bg = nodeColor(nodeNum);
    final name = shortName?.trim() ?? '';
    return ExcludeSemantics(
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        padding: EdgeInsets.all(size * 0.12),
        decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            name.isEmpty ? '?' : name,
            maxLines: 1,
            style: TextStyle(
              color: contrastingText(bg),
              fontSize: size * 0.32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

/// Предупреждение под формой (оранжевое, как в iOS).
class WarningNote extends StatelessWidget {
  const WarningNote(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(
      horizontal: Tokens.s16,
      vertical: Tokens.s4,
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.warning_amber, size: 16, color: Colors.orange),
        const SizedBox(width: Tokens.s8),
        Expanded(
          child: Text(
            text,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.orange),
          ),
        ),
      ],
    ),
  );
}
