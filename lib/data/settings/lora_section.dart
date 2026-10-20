import '../../core/proto/mesh.dart';
import '../database.dart';
import 'admin_settings.dart';
import 'fields.dart';
import 'user_section.dart';

/// Раздел «LoRa»: LoRaConfig.swift + LoraConfigEnums.swift (iOS),
/// LoRaConfigItemList.kt (Android). Подписи — ru iOS, иначе ru Android,
/// иначе английский. Не редактируются (как и в iOS/Android): ignore_incoming,
/// frequency_offset, fem_lna_mode, serial_hal_only — сохраняются как есть.
abstract final class LoraSection {
  static const title = 'Настройка LoRa';
  static const groupOptions = 'Параметры';
  static const groupAdvanced = 'Дополнительно';
  static const saveConfirm = 'Your device may reboot after saving.';

  /// Регионы iOS (RegionCodes) в его порядке: значение, подпись.
  static const regions = <Choice>[
    (value: 0, label: 'Пожалуйста, выберите регион'),
    (value: 1, label: 'Соединенные Штаты Америки'),
    (value: 2, label: 'European Union 433MHz'),
    (value: 3, label: 'European Union 868MHz'),
    (value: 4, label: 'China'),
    (value: 5, label: 'Япония'),
    (value: 6, label: 'Australia / New Zealand'),
    (value: 22, label: 'Australia / New Zealand 433MHz'),
    (value: 7, label: 'Корея'),
    (value: 8, label: 'Тайвань'),
    (value: 9, label: 'Россия'),
    (value: 10, label: 'India'),
    (value: 11, label: 'Новая Зеландия 865 МГц'),
    (value: 12, label: 'Таиланд'),
    (value: 14, label: 'Украина 433 Мгц'),
    (value: 16, label: 'Малайзия 433 МГц'),
    (value: 17, label: 'Малайзия 919 МГц'),
    (value: 18, label: 'Сингапур 923 МГц'),
    (value: 19, label: 'Филиппины 433 МГц'),
    (value: 20, label: 'Филиппины 868 МГц'),
    (value: 21, label: 'Филиппины 915 МГц'),
    (value: 23, label: 'Казахстан 433 МГц'),
    (value: 24, label: 'Казахстан 863 МГц'),
    (value: 25, label: 'Непал 865 МГц'),
    (value: 26, label: 'Brazil 902MHz'),
    (value: 27, label: 'ITU Region 1 / Amateur 2m'),
    (value: 28, label: 'ITU Region 2 / Amateur 2m'),
    (value: 29, label: 'European Union 866MHz'),
    (value: 30, label: 'European Union 874MHz'),
    (value: 31, label: 'European Union 917MHz'),
    (value: 32, label: 'European Union 868MHz (Narrow)'),
    (value: 13, label: '2.4 GHz'),
    (value: 33, label: 'Регион МСЭ 3 / Любительский 2 м'),
    (value: 34, label: 'ITU Region 1 / Amateur 70cm'),
    (value: 35, label: 'ITU Region 2 / Amateur 70cm'),
    (value: 36, label: 'Регион МСЭ 3 / Любительский 70 см'),
    (value: 37, label: 'ITU Region 2 / Amateur 1.25m'),
  ];

  static const lora24 = 13;
  static const _regions28 = {29, 32, 27, 28, 33, 34, 35, 36, 37};
  static const _hiddenRegions = {30, 31};

  /// Любительские диапазоны: только для лицензированных операторов.
  /// Ham-режим не перенесён — показываем, только если нода уже на них.
  static const _hamRegions = {27, 28, 33, 34, 35, 36, 37};
  static const _euRegions = {2, 3, 29, 30, 31, 32};
  static const _bandLimitedRegions = {3, 29, 32, 27, 28, 33, 34, 35, 36, 37};

  /// Регионы с ограничением рабочего цикла (dutyCycle 10% в iOS).
  static const _dutyCycleRegions = {2, 3, 14, 29, 30, 31, 32};

  static const presets = <Choice>[
    (value: 0, label: 'Большая дальность - Быстрый'),
    (value: 1, label: 'Long Range - Slow'),
    (value: 7, label: 'Большая дальность - Умеренно'),
    (value: 9, label: 'Большая дальность - Турбо'),
    (value: 3, label: 'Medium Range - Slow'),
    (value: 4, label: 'Medium Range - Fast'),
    (value: 5, label: 'Short Range - Slow'),
    (value: 6, label: 'Short Range - Fast'),
    (value: 8, label: 'Short Range - Turbo'),
    (value: 10, label: 'Легкий - Быстро'),
    (value: 11, label: 'Легкий - Медленно'),
    (value: 12, label: 'Узкий - Быстро'),
    (value: 13, label: 'Узкий - Медленно'),
    (value: 14, label: 'Tiny - Fast'),
    (value: 15, label: 'Tiny - Slow'),
    (value: 16, label: 'Medium Range - Turbo'),
  ];

  static const _deprecatedPresets = {1};
  static const _presets28 = {10, 11, 12, 13, 14, 15, 16};
  static const _turboPresets = {8, 9, 16};
  static const _bandLimitedPresets = {10, 11, 12, 13, 14, 15};

  /// Платы с вентилятором усилителя (RF95_FAN_EN), как paFanHardware в iOS.
  static final _paFanHardware = {
    HardwareModel.BETAFPV_2400_TX.value,
    HardwareModel.RADIOMASTER_900_BANDIT_NANO.value,
    HardwareModel.RADIOMASTER_900_BANDIT.value,
    HardwareModel.TBEAM_1_WATT.value,
  };

  /// Скорость кодирования пресета (знаменатель 4/n).
  static int presetCodingRate(int preset) => switch (preset) {
    9 || 7 || 1 => 8,
    12 || 13 => 6,
    _ => 5,
  };

  /// Регионы для выбора: без скрытых, без 2.8-регионов на старой прошивке,
  /// без любительских.
  static List<Choice> regionChoices(bool fw28) => [
    for (final r in regions)
      if (!_hiddenRegions.contains(r.value) &&
          (fw28 || !_regions28.contains(r.value)) &&
          !_hamRegions.contains(r.value))
        r,
  ];

  static bool knownRegion(int r) => regions.any((c) => c.value == r);

  /// Пресеты, допустимые в регионе.
  static List<Choice> presetChoices(int region, bool fw28) => [
    for (final p in presets)
      if (!_deprecatedPresets.contains(p.value) &&
          (fw28 || !_presets28.contains(p.value)) &&
          !(_euRegions.contains(region) && _turboPresets.contains(p.value)) &&
          (_bandLimitedRegions.contains(region) ||
              !_bandLimitedPresets.contains(p.value)))
        p,
  ];

  /// Полосы пропускания; 0 — значение региона по умолчанию.
  static List<Choice> bandwidthChoices(int region) => region == lora24
      ? const [
          (value: 0, label: 'По умолчанию (812.5 кГц)'),
          (value: 200, label: '203.125 кГц'),
          (value: 400, label: '406.25 кГц'),
          (value: 800, label: '812.5 кГц'),
        ]
      : const [
          (value: 0, label: 'По умолчанию (250 кГц)'),
          (value: 31, label: '31 кГц'),
          (value: 62, label: '62 кГц'),
          (value: 125, label: '125 кГц'),
          (value: 500, label: '500 кГц'),
        ];

  /// С пресетом: 0 (пресет) и только выше его — если прошивка это умеет
  /// (2.7.18+); вручную: 4/5–4/8.
  static List<Choice> codingRateChoices(
    bool usePreset,
    int preset,
    bool canOverride,
  ) {
    if (!usePreset) {
      return [for (var n = 5; n <= 8; n++) (value: n, label: '4/$n')];
    }
    final def = presetCodingRate(preset);
    return [
      (value: 0, label: 'Пресет по умолчанию (4/$def)'),
      if (canOverride)
        for (var n = def + 1; n <= 8; n++) (value: n, label: '4/$n'),
    ];
  }

  static bool _custom(Map<String, Object?> v) => v['usePreset'] == false;

  static List<FieldSpec<Object?>> fields({
    required String firmware,
    required int hwModel,
  }) {
    final fw28 = firmwareAtLeast(firmware, 2, 8);
    final canOverride = _codingOverride(firmware);
    return [
      ChoiceFieldSpec(
        'region',
        'Регион',
        const [],
        group: groupOptions,
        help: 'Регион, в котором вы будете использовать ваше устройство',
        optionsFor: (_) => regionChoices(fw28),
        unknownLabel: (r) =>
            regions.where((c) => c.value == r).firstOrNull?.label ??
            'Неизвестный ($r)',
      ),
      const BoolFieldSpec(
        'usePreset',
        'Использовать пресет',
        group: groupOptions,
        help:
            'Использовать настройки пресета модема вместо ручного указания '
            'полосы пропускания, коэффициента расширения и скорости кодирования',
      ),
      ChoiceFieldSpec(
        'modemPreset',
        'Пресеты',
        const [],
        group: groupOptions,
        help: 'Доступные пресеты модема, по умолчанию - Long Fast.',
        visibleWhen: (v) => v['usePreset'] == true,
        optionsFor: (v) => presetChoices(v['region']! as int, fw28),
        unknownLabel: (p) =>
            presets.where((c) => c.value == p).firstOrNull?.label ?? '$p',
      ),
      const BoolFieldSpec(
        'ignoreMqtt',
        'Игнорировать MQTT',
        group: groupAdvanced,
        help:
            'Ignore packets received over LoRa that travelled via MQTT '
            'anywhere on their path.',
      ),
      const BoolFieldSpec('okToMqtt', 'ОК для MQTT', group: groupAdvanced),
      const BoolFieldSpec(
        'txEnabled',
        'Передача включена',
        group: groupAdvanced,
        help:
            'Разрешить передачу по LoRa-радио. Отключай при горячей замене '
            'антенн или стендовых испытаниях.',
      ),
      ChoiceFieldSpec(
        'bandwidth',
        'Пропускная способность',
        const [],
        group: groupAdvanced,
        visibleWhen: _custom,
        optionsFor: (v) => bandwidthChoices(v['region']! as int),
        unknownLabel: (b) => 'Неподдерживаемый ($b кГц)',
      ),
      ChoiceFieldSpec(
        'spreadFactor',
        'Коэф. распространения',
        [for (var n = 7; n <= 12; n++) (value: n == 12 ? 0 : n, label: '$n')],
        group: groupAdvanced,
        help: 'Количество чирпов на символ — 2 в степени этого значения.',
        visibleWhen: _custom,
      ),
      ChoiceFieldSpec(
        'codingRate',
        'Скорость кодирования',
        const [],
        group: groupAdvanced,
        help:
            'Добавляет коррекцию ошибок поверх пресета. Более высокая скорость '
            'кодирования увеличивает длительность передачи каждого пакета и '
            'расходует больше рабочего цикла и ресурсов канала.',
        optionsFor: (v) => codingRateChoices(
          v['usePreset']! as bool,
          v['modemPreset']! as int,
          canOverride,
        ),
      ),
      ChoiceFieldSpec(
        'hopLimit',
        'Количество прыжков',
        [for (var n = 1; n <= 7; n++) (value: n, label: '$n')],
        group: groupAdvanced,
        help:
            'Задает максимальное количество прыжков, по умолчанию - 3. '
            'Увеличение количества также увеличивает перегрузку и должно '
            'использоваться с осторожностью. Сообщения с 0 прыжков не будут '
            'получать подтверждения.',
      ),
      IntFieldSpec(
        'channelNum',
        'Частотный слот',
        group: groupAdvanced,
        min: 0,
        max: 1000,
        help:
            'Рабочая частота вашей ноды рассчитывается на основе региона, '
            'настроек модема и этого поля. При значении 0 интервал '
            'автоматически рассчитывается на основе названия основного канала.',
        enabledWhen: (v) => v['overrideFrequency'] == 0.0,
      ),
      const BoolFieldSpec(
        'rxBoostedGain',
        'Усиление приема',
        group: groupAdvanced,
        help: 'Enable RX boosted gain mode on SX126X based radios',
      ),
      BoolFieldSpec(
        'overrideDutyCycle',
        'Переопределить рабочий цикл',
        group: groupAdvanced,
        visibleWhen: (v) => _dutyCycleRegions.contains(v['region']),
      ),
      if (_paFanHardware.contains(hwModel))
        const BoolFieldSpec(
          'paFanDisabled',
          'PA вентилятор выключен',
          group: groupAdvanced,
        ),
      const DoubleFieldSpec(
        'overrideFrequency',
        'Переопределение частоты',
        group: groupAdvanced,
        min: 0,
        max: 3000,
        unit: 'МГц',
      ),
      const IntFieldSpec(
        'txPower',
        'Мощность передатчика',
        group: groupAdvanced,
        min: 0,
        max: 30,
        unit: 'dBm',
        help:
            'Мощность передачи радио. Оставь ноль, чтобы использовать '
            'максимально допустимый уровень для региона — именно так следует '
            'поступать большинству радиоустройств.',
      ),
    ];
  }

  /// Скорость кодирования поверх пресета прошивка учитывает с 2.7.18.
  static bool _codingOverride(String fw) {
    if (firmwareAtLeast(fw, 2, 8)) return true;
    final p = fw.split('.');
    final patch = int.tryParse(p.length > 2 ? p[2] : '') ?? 0;
    return firmwareAtLeast(fw, 2, 7) && patch >= 18;
  }

  static Map<String, Object?> read(Config_LoRaConfig c) => {
    'region': c.region.value,
    'usePreset': c.usePreset,
    'modemPreset': c.modemPreset.value,
    'ignoreMqtt': c.ignoreMqtt,
    'okToMqtt': c.configOkToMqtt,
    'txEnabled': c.txEnabled,
    'bandwidth': c.bandwidth,
    'spreadFactor': c.spreadFactor,
    'codingRate': c.codingRate,
    'hopLimit': c.hopLimit,
    'channelNum': c.channelNum,
    'rxBoostedGain': c.sx126xRxBoostedGain,
    'overrideDutyCycle': c.overrideDutyCycle,
    'paFanDisabled': c.paFanDisabled,
    'overrideFrequency': c.overrideFrequency,
    'txPower': c.txPower,
  };

  /// Согласовать скорость кодирования с пресетом/ручным режимом (как
  /// CodingRates.normalized в iOS).
  static void adjust(Map<String, Object?> v) {
    final usePreset = v['usePreset']! as bool;
    final cr = v['codingRate']! as int;
    final ok = codingRateChoices(
      usePreset,
      v['modemPreset']! as int,
      true,
    ).any((c) => c.value == cr);
    if (!ok) v['codingRate'] = usePreset ? 0 : 5;
  }

  /// Ошибка сочетания значений: неизвестный регион или полоса.
  static String? check(Map<String, Object?> v) {
    if (!knownRegion(v['region']! as int)) {
      return 'Нода использует регион, который приложение не поддерживает. '
          'Выберите поддерживаемый регион перед сохранением.';
    }
    if (v['usePreset'] == false &&
        !bandwidthChoices(
          v['region']! as int,
        ).any((c) => c.value == v['bandwidth'])) {
      return 'Эта полоса пропускания не поддерживается подключённым радио в '
          'выбранном регионе. Выберите поддерживаемое значение перед '
          'сохранением.';
    }
    return null;
  }

  /// Новый LoRaConfig: исходный с правками формы (нередактируемые поля —
  /// как были).
  static Config_LoRaConfig apply(
    Config_LoRaConfig base,
    Map<String, Object?> v,
  ) => base.deepCopy()
    ..region = Config_LoRaConfig_RegionCode.valueOf(v['region']! as int)!
    ..usePreset = v['usePreset']! as bool
    ..modemPreset = Config_LoRaConfig_ModemPreset.valueOf(
      v['modemPreset']! as int,
    )!
    ..ignoreMqtt = v['ignoreMqtt']! as bool
    ..configOkToMqtt = v['okToMqtt']! as bool
    ..txEnabled = v['txEnabled']! as bool
    ..bandwidth = v['bandwidth']! as int
    ..spreadFactor = v['spreadFactor']! as int
    ..codingRate = v['codingRate']! as int
    ..hopLimit = v['hopLimit']! as int
    ..channelNum = v['channelNum']! as int
    ..sx126xRxBoostedGain = v['rxBoostedGain']! as bool
    ..overrideDutyCycle = v['overrideDutyCycle']! as bool
    ..paFanDisabled = v['paFanDisabled']! as bool
    ..overrideFrequency = v['overrideFrequency']! as double
    ..txPower = v['txPower']! as int;

  /// set_config своей ноде; при подтверждении — сохранить конфиг в БД.
  static Future<bool> save(
    AdminSettings admin,
    AppDatabase db,
    Config_LoRaConfig base,
    Map<String, Object?> v,
  ) async {
    final cfg = Config(lora: apply(base, v));
    final ok = await admin.send(AdminMessage(setConfig: cfg));
    if (ok) {
      await db
          .into(db.configBlobs)
          .insertOnConflictUpdate(
            ConfigBlobsCompanion.insert(
              key: 'config.lora',
              data: cfg.writeToBuffer(),
              updated: DateTime.now(),
            ),
          );
    }
    return ok;
  }
}
