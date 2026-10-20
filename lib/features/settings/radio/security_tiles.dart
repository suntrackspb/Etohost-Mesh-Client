import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/settings/security_section.dart';
import '../../../data/settings/settings_form.dart';
import '../../../ui/kit/kit.dart';

/// Публичный ключ (выводится из закрытого в форме) с кнопкой «Копировать»
/// и пересоздание закрытого ключа.
class SecurityKeyTiles extends StatelessWidget {
  const SecurityKeyTiles({super.key, required this.form});

  final SettingsForm form;

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: form,
    builder: (context, _) {
      final priv = SecurityKey.decode(form.value<String>('privateKey'));
      return SectionCard(
        children: [
          FutureBuilder(
            future: priv == null
                ? Future.value(null)
                : SecurityKey.publicFor(priv),
            builder: (context, snap) =>
                _PublicKey(SecurityKey.encode(snap.data ?? const [])),
          ),
          MeshTile(
            title: SecuritySection.regenerateLabel,
            subtitle: SecuritySection.regenerateHelp,
            leading: const Icon(Icons.autorenew),
            onTap: form.saving ? null : () => _regenerate(context),
          ),
        ],
      );
    },
  );

  Future<void> _regenerate(BuildContext context) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Вы уверены?'),
        content: const Text(SecuritySection.regenerateConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Отмена'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Пересоздать'),
          ),
        ],
      ),
    );
    if (yes == true) {
      form.set('privateKey', SecurityKey.encode(SecurityKey.generatePrivate()));
    }
  }
}

class _PublicKey extends StatelessWidget {
  const _PublicKey(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: Tokens.s16,
        vertical: Tokens.s8,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.key, size: 18),
              const SizedBox(width: Tokens.s8),
              const Expanded(child: Text(SecuritySection.publicKeyLabel)),
              TextButton.icon(
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Копировать'),
                onPressed: text.isEmpty
                    ? null
                    : () => Clipboard.setData(ClipboardData(text: text)),
              ),
            ],
          ),
          SelectableText(
            text.isEmpty ? '—' : text,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              fontFamilyFallback: const ['Menlo', 'Courier'],
            ),
          ),
          const SizedBox(height: Tokens.s4),
          Text(
            SecuritySection.publicKeyHelp,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.outline,
            ),
          ),
        ],
      ),
    );
  }
}

/// Предупреждение под формой (оранжевое, как в iOS).
class SecurityNote extends StatelessWidget {
  const SecurityNote(this.text, {super.key});

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
