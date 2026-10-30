import 'dart:io';

import 'package:flutter/material.dart';
import '../l10n/l10n.dart';
import 'package:toastification/toastification.dart';

enum ToastKind { info, success, error }

/// Сколько держать уведомление: длинный текст — дольше, но не больше 8 с.
Duration toastDuration(String text) =>
    Duration(milliseconds: (3000 + text.length * 40).clamp(3000, 8000));

/// Всплывающие уведомления сверху (вместо снэкбаров, которые закрывают
/// строку ввода). Вызываются без `BuildContext` — из логики тоже; нужен
/// `ToastificationWrapper` над приложением. Пакет спрятан за этим
/// интерфейсом, чтобы его можно было заменить без правок вызовов.
class Toasts {
  const Toasts();

  static bool get _desktop =>
      Platform.isMacOS || Platform.isWindows || Platform.isLinux;

  /// [onTap] — действие по нажатию (например, «Скачать»); подсказку о нём
  /// пишите в [text].
  void show(
    String text, {
    ToastKind kind = ToastKind.info,
    VoidCallback? onTap,
  }) {
    toastification.show(
      type: switch (kind) {
        ToastKind.info => ToastificationType.info,
        ToastKind.success => ToastificationType.success,
        ToastKind.error => ToastificationType.error,
      },
      style: ToastificationStyle.flatColored,
      title: Builder(
        builder: (context) => Text(context.builtIn(text), maxLines: 4),
      ),
      alignment: _desktop ? Alignment.topRight : Alignment.topCenter,
      autoCloseDuration: toastDuration(text),
      showProgressBar: false,
      closeOnClick: onTap == null,
      dragToClose: true,
      pauseOnHover: true,
      sizeConstraints: const BoxConstraints(maxWidth: 420),
      callbacks: ToastificationCallbacks(
        onTap: onTap == null
            ? null
            : (item) {
                toastification.dismiss(item);
                onTap();
              },
      ),
    );
  }

  void success(String text) => show(text, kind: ToastKind.success);
  void error(String text) => show(text, kind: ToastKind.error);
}

const toasts = Toasts();

/// Обёртка над приложением; стопка — до 3 уведомлений.
Widget toastsHost(Widget child) => ToastificationWrapper(
  config: const ToastificationConfig(maxToastLimit: 3),
  child: child,
);
