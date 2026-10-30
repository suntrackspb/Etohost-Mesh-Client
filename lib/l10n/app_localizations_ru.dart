// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get language => 'Язык';

  @override
  String get systemLanguage => 'Как в системе';

  @override
  String get russian => 'Русский';

  @override
  String get english => 'English';

  @override
  String get languageHelp => 'Язык интерфейса приложения';

  @override
  String get hourClock_55c2f5 => '12-часовой формат';

  @override
  String get h_d3db2b => '1Ч';

  @override
  String get buzzerGpio_fff3f4 => 'GPIO зуммер';

  @override
  String get buttonGpio_845326 => 'GPIO кнопки';

  @override
  String get gpsTransmitGpio_e4dc9e => 'GPIO передачи GPS';

  @override
  String get gpsReceiveGpio_402339 => 'GPIO приема GPS';

  @override
  String get batteryInaXxICAddress_3b2fa6 => 'I2C-адрес INA_2XX батареи';

  @override
  String get nodeId_021568 => 'ID ноды';

  @override
  String get ip_42788e => 'IP-адрес';

  @override
  String get mqttDownlinkEnabled_990d36 => 'MQTT Downlink включён';

  @override
  String get mqttUplinkEnabled_9d43a7 => 'MQTT Uplink включён';

  @override
  String get mqttClientProxy_aa711a => 'MQTT клиент-прокси';

  @override
  String get mqttConnectionRejectedCheckCredentials_5ddde1 =>
      'MQTT: соединение отклонено (проверьте учетные данные)';

  @override
  String get mqttConnectionLost_681220 => 'MQTT: соединение потеряно';

  @override
  String get tlsEnabled_df2997 => 'TLS включен';

  @override
  String get channelUrl_8b64fd => 'URL канала';

  @override
  String get auto_569533 => 'Авто';

  @override
  String get administration_d838aa => 'Администрирование';

  @override
  String get address_8db46e => 'Адрес';

  @override
  String get active_76ddd7 => 'Активно';

  @override
  String get uptime_d0d899 => 'Аптайм';

  @override
  String get battery_96a4c3 => 'Батарея';

  @override
  String get security_d4fab1 => 'Безопасность';

  @override
  String get baud_cd221c => 'Бод';

  @override
  String get yourNodeWillPeriodicallySendAn_b5be37 =>
      'Ваша нода будет периодически отправлять незашифрованный пакет местоположения на настроенный сервер MQTT, включающий идентификатор, короткое и длинное имя, приблизительное местоположение, модель оборудования, роль, версию встроенного ПО, регион LoRa, предустановку модема и название основного канала.';

  @override
  String get upDown_908205 => 'Вверх вниз 1';

  @override
  String get version_97c248 => 'Версия';

  @override
  String get firmwareEdition_29bed8 => 'Версия прошивки';

  @override
  String get weight_38348d => 'Вес';

  @override
  String get wind_43eea9 => 'Ветер';

  @override
  String get enablesTheDetectionSensorModuleIt_54016a =>
      'Включает модуль датчика обнаружения. Его необходимо включить как на ноде с датчиком, так и на всех нодах, на которых вы хотите получать текстовые сообщения датчика обнаружения или просматривать журнал и график датчика обнаружения.';

  @override
  String get enablesTheStoreAndForwardModule_539c8a =>
      'Включает модуль хранения и пересылки.';

  @override
  String get enabled_edde94 => 'Включен';

  @override
  String get enablingEthernetWillDisableTheBluetooth_7dd901 =>
      'Включение Ethernet отключит соединение Bluetooth с приложением.';

  @override
  String get enableBroadcastingDeviceMetricsToThe_7c0170 =>
      'Включить передачу метрик устройства в ячеистую сеть. При отключении метрики отправляются только подключенным клиентам.';

  @override
  String get enableBroadcastingPacketsViaUdpOver_60fa0e =>
      'Включить трансляцию пакетов через UDP по локальной сети.';

  @override
  String get enableFilterHere_f6dfd3 => 'Включить фильтрацию';

  @override
  String get enableThisDeviceAsAStore_4fbae6 =>
      'Включить это устройство как сервер хранения и пересылки. Требуется устройство ESP32 с PSRAM.';

  @override
  String get hum_b7b903 => 'Влажн';

  @override
  String get soilMoist_1e2f47 => 'Влажн почвы';

  @override
  String get humidity_3b6f05 => 'Влажность';

  @override
  String get externalNotification_22860a => 'Внешние уведомления';

  @override
  String get warningThisContactIsKnownImporting_555efb =>
      'Внимание: Данный контакт уже существует, импорт перезапишет ранее известную информацию о нём.';

  @override
  String get reconnecting_c0657e => 'Восстановление связи…';

  @override
  String get clockwiseRotaryEvent_fc48d3 => 'Вращение по часовой стрелке';

  @override
  String get counterClockwiseRotaryEvent_e87a94 =>
      'Вращение энкодера против часовой стрелки';

  @override
  String get historyReturnWindow_221c13 => 'Временное окно возврата истории';

  @override
  String get time_c80d7e => 'Время';

  @override
  String get lastHeardTime_c3cbbb => 'Время последнего вещания';

  @override
  String get all_fd08da => 'Все';

  @override
  String get willSleepEverythingAsMuchAs_b3e005 =>
      'Все устройства будут работать в режиме ожидания, насколько это возможно, в качестве трекера и датчика также будет использоваться радиоприемник lora. Не используйте эту настройку, если вы хотите использовать свое устройство с приложениями для телефона или устройство без пользовательской кнопки.';

  @override
  String get insertLink_ab6720 => 'Вставить ссылку';

  @override
  String get all_fc7905 => 'Всё';

  @override
  String get yesterday_51403c => 'Вчера';

  @override
  String get you_adb403 => 'Вы';

  @override
  String get areYouSureYouWantTo_7ff54f =>
      'Вы уверены, что хотите пересоздать свой приватный ключ?\n\nНоды, которые ранее обменивались ключами с этой нодой, должны будут удалить её и повторно обменяться ключами для того, чтобы возобновить защищённую связь.';

  @override
  String get areYouSure_b0069b => 'Вы уверены?';

  @override
  String get pickTheBackupToRestoreTo_92df2d =>
      'Выбери резервную копию для восстановления этой ноды. Сброс настроек или новый ключ меняет ID узла, поэтому старые резервные копии остаются под старым ID. Восстанавливай только резервную копию, взятую с этого же устройства: другой ключ дает обеим радиоустройствам одинаковый идентификатор.';

  @override
  String get pickTheEncryptedKeyBackupTo_5e150c =>
      'Выбери резервную копию зашифрованного ключа для удаления с этого устройства. Это не может быть отменено.';

  @override
  String get jsonOutputEnabled_946891 => 'Вывод JSON включен';

  @override
  String get outputLiveDebugLoggingOverSerial_db97f9 =>
      'Вывод отладочного журнала в реальном времени через последовательный порт, просмотр и экспорт журналов устройства со скрытыми позициями через Bluetooth.';

  @override
  String get boldTheHeadingTextOnThe_6d5498 =>
      'Выделять жирным шрифтом текст заголовка на экране.';

  @override
  String get shutdown_468972 => 'Выключение';

  @override
  String get shutdownNotSupportedOnThisDevice_04502f =>
      'Выключение не поддерживается на этом устройстве';

  @override
  String get altitude_b24a95 => 'Высота';

  @override
  String get quit_c42457 => 'Выход';

  @override
  String get outputPinGpio_341423 => 'Выходной контакт GPIO';

  @override
  String get outputPinVibraGpio_7e4cdf => 'Выходной контакт вибрации GPIO';

  @override
  String get done_398c7d => 'Готово';

  @override
  String get baro_21229d => 'Давл';

  @override
  String get pressure_aa017a => 'Давление';

  @override
  String get next_9c714c => 'Далее';

  @override
  String get detectionSensor_ef8fca => 'Датчик обнаружения';

  @override
  String get doubleTapAsButton_d2bc2c => 'Двойной тап как кнопка';

  @override
  String get actions_9978ac => 'Действия';

  @override
  String get display_fff385 => 'Дисплей';

  @override
  String get gpioOutputDuration_e159f4 => 'Длительность выхода GPIO';

  @override
  String get superDeepSleepDuration_c44e27 =>
      'Длительность супер-глубокого сна';

  @override
  String get acceptUnsignedTrafficForMaximumCompatibility_6a6fd7 =>
      'Для максимальной совместимости принимать трафик без цифровой подписи. Пакет все равно будет отброшен, если подпись неверна и ее возможно проверить.';

  @override
  String get noKeyBackupFoundForThis_ce5803 =>
      'Для этой ноды не найдено резервной копии ключа';

  @override
  String get add_559a87 => 'Добавить';

  @override
  String get addChannel_af2785 => 'Добавить канал';

  @override
  String get addsErrorCorrectionOnTopOf_512807 =>
      'Добавляет коррекцию ошибок поверх пресета. Более высокая скорость кодирования увеличивает длительность передачи каждого пакета и расходует больше рабочего цикла и ресурсов канала.';

  @override
  String get rainH_ee76fe => 'Дождь (1ч)';

  @override
  String get rainH_90ad74 => 'Дождь (24ч)';

  @override
  String get longitude_f22a3e => 'Долгота';

  @override
  String get availablePins_a9affa => 'Доступные контакты';

  @override
  String get availableModemPresetsDefaultIsLong_71dc05 =>
      'Доступные пресеты модема, по умолчанию - Long Fast.';

  @override
  String get displayUnits_4a7072 => 'Единицы измерения на экране';

  @override
  String get ifEnabledTheOutputPinWill_3d2627 =>
      'Если включено, контакт \'output\' будет активирован на высоком уровне, отключено означает активный низкий уровень.';

  @override
  String get ifSetAnyPacketsYouSend_4305f4 =>
      'Если установлено, все отправляемые вами пакеты будут отправлены эхом обратно на ваше устройство.';

  @override
  String get boldHeading_29e9c1 => 'Жирный заголовок';

  @override
  String get debugLogs_dea656 => 'Журнал отладки';

  @override
  String get logs_d821b9 => 'Журналы';

  @override
  String get close_4ae50d => 'Закрыть';

  @override
  String get replace_d772cc => 'Заменить';

  @override
  String get audio_3bcc51 => 'Звук';

  @override
  String get ignore_00e05b => 'Игнорировать';

  @override
  String get ignoreMqtt_be2d01 => 'Игнорировать MQTT';

  @override
  String get favorite_b880e6 => 'Избранное';

  @override
  String get importConfiguration_c776ef => 'Импорт настроек';

  @override
  String get import_55fd5f => 'Импортировать';

  @override
  String get importSharedContact_5e5c66 => 'Импортировать контакт?';

  @override
  String get name_aee78f => 'Имя';

  @override
  String get username_a79f8a => 'Имя пользователя';

  @override
  String get carouselInterval_fa458c => 'Интервал карусели';

  @override
  String get updateInterval_fe3feb => 'Интервал обновления';

  @override
  String get channelUtilization_b2e6eb => 'Использование канала';

  @override
  String get useISAsBuzzer_8b207f => 'Использовать I2S как зуммер';

  @override
  String get usePwmBuzzer_571ead => 'Использовать PWM зуммер';

  @override
  String get usePreset_f457c3 => 'Использовать пресет';

  @override
  String get usePhoneTimeZone_8a4f73 => 'Использовать часовой пояс телефона';

  @override
  String get usesPullupResistor_a75a60 => 'Использует подтягивающий резистор';

  @override
  String get utilizesTheNetworkConnectionOnYour_d40c1d =>
      'Использует сетевое подключение вашего телефона для подключения к MQTT.';

  @override
  String get useAPwmOutputLikeThe_6695f2 =>
      'Используйте выход PWM (например, RAK Buzzer) для мелодий вместо вывода вкл/выкл. Это будет игнорировать вывод, длительность вывода и активные настройки и использовать опцию GPIO зуммера в конфигурации устройства.';

  @override
  String get channels_88a8ec => 'Каналы';

  @override
  String get keysBackedUpSecurely_249b39 => 'Ключи надежно сохранены';

  @override
  String get numberOfRecords_107e13 => 'Количество записей';

  @override
  String get sats_096274 => 'Количество спутников';

  @override
  String get serialConsole_f80bee => 'Консоль последовательного порта';

  @override
  String get serialConsoleOverTheStreamApi_ee1f12 =>
      'Консоль последовательного порта через Stream API.';

  @override
  String get gpioPin_68149e => 'Контакт GPIO';

  @override
  String get gpioPinToMonitor_cef408 => 'Контакт GPIO для мониторинга';

  @override
  String get transmitDataTxdGpioPin_a33aed =>
      'Контакт GPIO передачи данных (txd)';

  @override
  String get receiveDataRxdGpioPin_05d193 => 'Контакт GPIO приема данных (rxd)';

  @override
  String get pressPin_e4f7eb => 'Контакт нажатия';

  @override
  String get copy_4a05d8 => 'Копировать';

  @override
  String get shortName_58073d => 'Короткое имя';

  @override
  String get spreadFactor_deb22e => 'Коэф. распространения';

  @override
  String get directMessages_6955f3 => 'Личные сообщения';

  @override
  String get localStats_f21f8a => 'Локальная статистика';

  @override
  String get maxHopsForDirectResponse_3ca022 =>
      'Макс кол-во хопов для прямых сообщений';

  @override
  String get maxPacketsInWindow_75eb31 => 'Макс пакетов в окне';

  @override
  String get historyReturnMax_cb0955 => 'Максимальное возвращение истории';

  @override
  String get position_82bd05 => 'Местоположение';

  @override
  String get airQualityMetrics_e4a5d4 => 'Метрики качества воздуха';

  @override
  String get environmentMetrics_f472fb => 'Метрики окружения';

  @override
  String get environmentMetricsEnabled_67632b => 'Метрики окружения включены';

  @override
  String get powerMetrics_f93c31 => 'Метрики питания';

  @override
  String get deviceMetrics_19b5ae => 'Метрики устройства';

  @override
  String get mesh_b9e236 => 'Меш';

  @override
  String get minPositionIntervalSecs_293ba3 =>
      'Мин. интервал позиционирования (сек)';

  @override
  String get minimumWakeTime_de36c3 => 'Минимальное время бодрствования';

  @override
  String get minimumDistance_404b16 => 'Минимальное расстояние';

  @override
  String get hardwareModel_feb4d1 => 'Модель оборудования';

  @override
  String get voltage_fb28eb => 'Напряжение';

  @override
  String get bluetoothConfig_aae27c => 'Настройка Bluetooth';

  @override
  String get mqttConfig_c20987 => 'Настройка MQTT';

  @override
  String get takConfiguration_cb4e17 => 'Настройка TAK';

  @override
  String get detectionSensorConfig_9fd77e => 'Настройка датчика обнаружения';

  @override
  String get audioConfig_7ca6bd => 'Настройка звука';

  @override
  String get remoteHardwareConfig_b75c78 => 'Настройка удаленного оборудования';

  @override
  String get trafficManagementConfiguration_3bcd5d =>
      'Настройка управления движением';

  @override
  String get configuration_7f17c7 => 'Настройки';

  @override
  String get moduleConfiguration_f1e43a => 'Настройки модуля';

  @override
  String get userConfig_28470f => 'Настройки пользователя';

  @override
  String get neighborInfoConfig_b6a0ae => 'Настройки соседей';

  @override
  String get deviceConfiguration_2030e8 => 'Настройки устройства';

  @override
  String get failedToRestoreKeysFromBackup_89248f =>
      'Не удалось восстановить ключи из резервной копии';

  @override
  String get inactive_0b3829 => 'Неактивно';

  @override
  String get whetherOrNotUseInputPullup_f96145 =>
      'Независимо от того, используется ли режим INPUT_PULLUP для вывода GPIO. Применимо только в том случае, если на выводе платы используются подтягивающие резисторы';

  @override
  String get noResultsFound_1e1b70 => 'Ничего не найдено';

  @override
  String get nodes_fea63e => 'Ноды';

  @override
  String get about_b9c9ff => 'О приложении';

  @override
  String get okToMqtt_81b6f7 => 'ОК для MQTT';

  @override
  String get exchangePosition_b039f2 => 'Обменяться местоположением';

  @override
  String get refresh_c2f668 => 'Обновить';

  @override
  String get hardware_2cf041 => 'Оборудование';

  @override
  String get rateLimited_eebeda => 'Ограничение скорости';

  @override
  String get rateLimitWindowSecs_5c4a08 => 'Окно ограничения скорости (сек.)';

  @override
  String get lux_0ca380 => 'Освещённость';

  @override
  String get rootTopic_994995 => 'Основная тема';

  @override
  String get dropUnknownPackets_ba44e0 => 'Отбрасывать неизвестные пакеты';

  @override
  String get reply_c6f466 => 'Ответить';

  @override
  String get disabled_cadea0 => 'Отключен';

  @override
  String get shutdownOnPowerLoss_753913 => 'Отключение при потере питания';

  @override
  String get disconnected_9d30b9 => 'Отключено';

  @override
  String get muteNotifications_6f777b => 'Отключить уведомления';

  @override
  String get disableFilterHere_24f1d5 => 'Отключить фильтрацию';

  @override
  String get openInBrowser_a1f2ae => 'Открыть в браузере';

  @override
  String get debug_8669d1 => 'Отладка';

  @override
  String get cancel_0ec753 => 'Отмена';

  @override
  String get cancelReply_d5465b => 'Отменить ответ';

  @override
  String get timestamp_9604ae => 'Отметка времени';

  @override
  String get displayFahrenheit_8c89d1 => 'Отображение по Фаренгейту';

  @override
  String get send_76dcf7 => 'Отправить';

  @override
  String get sendAHeartbeatToAdvertiseThe_80f353 =>
      'Отправить heartbeat для оповещения о присутствии сервера.';

  @override
  String get sendBell_9a7a42 => 'Отправить колокол';

  @override
  String get sendHeartbeat_733393 => 'Отправить сердцебиение';

  @override
  String get sendAsciiBellWithAlertMessage_fbcdc2 =>
      'Отправьте ASCII колокольчик с предупреждающим сообщением. Полезно для срабатывания внешнего уведомления на колокольчик.';

  @override
  String get filtered_a13eeb => 'Отфильтрованные';

  @override
  String get clear_98b207 => 'Очистить';

  @override
  String get positionPacket_02f1de => 'Пакет позиции';

  @override
  String get password_14f7c6 => 'Пароль';

  @override
  String get primary_781ece => 'Первичный';

  @override
  String get flipScreen_8fe129 => 'Перевернуть экран';

  @override
  String get flipScreenVertically_554b97 => 'Перевернуть экран вертикально';

  @override
  String get transmitEnabled_da32f9 => 'Передача включена';

  @override
  String get reboot_a40813 => 'Перезагрузка';

  @override
  String get adcOverride_577328 => 'Переопределение АЦП';

  @override
  String get frequencyOverride_80233f => 'Переопределение частоты';

  @override
  String get overrideConsoleSerialPort_6cee74 =>
      'Переопределить COM-порт консоли';

  @override
  String get reconnect_a8e2cf => 'Переподключение';

  @override
  String get power_cea0d9 => 'Питание';

  @override
  String get powerScreen_c81bdd => 'Питание экрана';

  @override
  String get default_469631 => 'По умолчанию';

  @override
  String get rotary_378549 => 'Поворотный 1';

  @override
  String get retry_9e506a => 'Повторить';

  @override
  String get locationSharing_26e070 => 'Поделиться местоположением';

  @override
  String get connecting_79e350 => 'Подключение';

  @override
  String get connecting_40b27e => 'Подключение…';

  @override
  String get connected_20bebc => 'Подключено';

  @override
  String get connect_124298 => 'Подключить';

  @override
  String get packetAuthenticity_43a0f6 => 'Подлинность пакета';

  @override
  String get enablesDevicesWithNativeIS_fb6aba =>
      'Позволяет устройствам с нативным аудиовыходом I2S использовать RTTTL через динамик как зуммер. Например, T-Watch S3 и T-Deck имеют эту возможность.';

  @override
  String get broadcastDeviceMetrics_48d605 =>
      'Показатели широковещательного устройства';

  @override
  String get show_7788a1 => 'Показать';

  @override
  String get showOnDeviceScreen_b36075 => 'Показать на экране устройства';

  @override
  String get onlyShowAndProcessCryptographicallyAuthenticated_4e43d0 =>
      'Показывать и обрабатывать только криптографически аутентифицированные mesh-пакеты. Старые ноды и слишком большие пакеты могут исчезнуть.';

  @override
  String get user_51aff1 => 'Пользователь';

  @override
  String get unknownPacketThreshold_db491f =>
      'Порог передач неизвестных пакетов';

  @override
  String get preview_5d092c => 'Предпросмотр';

  @override
  String get alertGpioVibraMotorWhenReceiving_fb8e2d =>
      'Предупреждающий вибромотор GPIO о получении звукового сигнала';

  @override
  String get alertGpioVibraMotorWhenReceiving_31bde3 =>
      'Предупреждающий вибромотор GPIO о получении сообщения';

  @override
  String get alertGpioBuzzerWhenReceivingA_5b83a2 =>
      'Предупреждающий зуммер GPIO при получении звукового сигнала';

  @override
  String get alertGpioBuzzerWhenReceivingA_8c8033 =>
      'Предупреждающий зуммер GPIO при получении сообщения';

  @override
  String get alertWhenReceivingABell_c28d01 =>
      'Предупреждение при получении звукового сигнала';

  @override
  String get alertWhenReceivingAMessage_a01361 =>
      'Предупреждение при получении сообщения';

  @override
  String get presets_c5eb0c => 'Пресеты';

  @override
  String get enablingWifiWillDisableTheBluetooth_29400e =>
      'При включении WiFi отключится bluetooth подключение к телефону';

  @override
  String get whenEnabledThePaxCounterModule_bf807f =>
      'При включении модуль прохожих подсчитывает количество людей, проходящих мимо, используя Wi-Fi и Bluetooth. Для работы счетчика количества человек как Wi-Fi, так и Bluetooth должны быть отключены.';

  @override
  String get app_f9886c => 'Приложение';

  @override
  String get rangeTest_6b237e => 'Проверка дальности';

  @override
  String get bandwidth_cb1c61 => 'Пропускная способность';

  @override
  String get firmware_df1881 => 'Прошивка';

  @override
  String get hopsAway_1337cd => 'Прыжков';

  @override
  String get nodeinfoDirectResponse_ee19b3 => 'Прямой ответ NodeInfo';

  @override
  String get aPublicStatusMessageThatIs_1e34f9 =>
      'Публичное сообщение о статусе, которое отправляется в сеть при изменении и каждые 12 часов.';

  @override
  String get publicKey_225a9f => 'Публичный ключ';

  @override
  String get publicKeyChanged_999a04 => 'Публичный ключ изменён';

  @override
  String get ledHeartbeat_351815 => 'Пульс LED';

  @override
  String get yourNodeSOperatingFrequencyIs_89edec =>
      'Рабочая частота вашей ноды рассчитывается на основе региона, настроек модема и этого поля. При значении 0 интервал автоматически рассчитывается на основе названия основного канала.';

  @override
  String get allowUndefinedPinAccess_323b2d =>
      'Разрешить неопределённый контакт';

  @override
  String get region_1089c8 => 'Регион';

  @override
  String get mode_ff0fbd => 'Режим';

  @override
  String get rebroadcastMode_96abc5 => 'Режим повторной передачи';

  @override
  String get pairingMode_053326 => 'Режим сопряжения';

  @override
  String get displayMode_953816 => 'Режим экрана';

  @override
  String get backupRestore_e10c3e => 'Резервная копия и восстановление';

  @override
  String get keyBackupDeleted_2ed312 => 'Резервная копия ключа удалена';

  @override
  String get ringtone_622e53 => 'Рингтон';

  @override
  String get role_ab51a3 => 'Роль';

  @override
  String get deviceRole_1118bf => 'Роль устройства';

  @override
  String get light_808001 => 'Светлая';

  @override
  String get today_5d5d2e => 'Сегодня';

  @override
  String get server_917e05 => 'Сервер';

  @override
  String get network_b3c4b1 => 'Сеть';

  @override
  String get signal_b26f0d => 'Сигнал';

  @override
  String get scanSharedChannelsQrCode_e4128b =>
      'Сканировать QR-код общих каналов';

  @override
  String get download_fe8f79 => 'Скачать';

  @override
  String get codingRate_4440db => 'Скорость кодирования';

  @override
  String get hide_107291 => 'Скрыть';

  @override
  String get serviceNotifications_f0c59c => 'Служебные уведомления';

  @override
  String get encoderPressEvent_c7ef35 => 'Событие нажатия энкодера';

  @override
  String get consentToShareUnencryptedNodeData_2a83b2 =>
      'Согласие на передачу незашифрованных данных ноды через MQTT';

  @override
  String get message_dc7234 => 'Сообщение';

  @override
  String get messages_019803 => 'Сообщения';

  @override
  String get messagesSentDirectlyToYou_9bb02c =>
      'Сообщения, отправленные тебе напрямую.';

  @override
  String get gasResistance_ccf913 => 'Сопротивление газа';

  @override
  String get status_81e4bb => 'Состояние';

  @override
  String get ledState_e13197 => 'Состояние LED';

  @override
  String get theStateOfTheLedOn_90485e => 'Состояние LED (вкл/выкл)';

  @override
  String get statusMessage_b6dd18 => 'Состояние сообщения';

  @override
  String get save_486405 => 'Сохранить';

  @override
  String get preserveFavorites_8bd086 => 'Сохранить избранное?';

  @override
  String get savesThePublicAndPrivateKeys_819ff7 =>
      'Сохранить публичные и приватные ключи в безопасном зашифрованном хранилище на этом устройстве.';

  @override
  String get savesACsvWithTheRange_d3ca60 =>
      'Сохраняет CSV с деталями сообщений тестирования дальности, в настоящее время доступно только на устройствах ESP32 с веб-сервером.';

  @override
  String get status_f7f293 => 'Статус';

  @override
  String get strictIgnoresEveryRemoteMeshPacket_c16f59 =>
      'Строгий игнорирует любые удалённые mesh-пакеты, которые не прошли криптографическую аутентификацию. Более старая прошивка, лицензированные устройства или ноды Ham без PKI-ключей и слишком большие пакеты могут перестать работать. Прямые сообщения с PKI-аутентификацией остаются доступными.';

  @override
  String get treatDoubleTapOnSupportedAccelerometers_28e78a =>
      'Считать двойное нажатие на поддерживаемых акселерометрах как нажатие пользовательской кнопки.';

  @override
  String get timeout_82605b => 'Таймаут';

  @override
  String get telemetry_c2d0b0 => 'Телеметрия';

  @override
  String get theme_553c45 => 'Тема';

  @override
  String get temp_e0d826 => 'Темп';

  @override
  String get soilTemp_014031 => 'Темп почвы';

  @override
  String get temperature_56f765 => 'Температура';

  @override
  String get oledType_6f928e => 'Тип OLED';

  @override
  String get triggertype_435565 => 'Тип триггера';

  @override
  String get current_47b6bf => 'Ток';

  @override
  String get encryptedOnly_5943ed => 'Только зашифрованные';

  @override
  String get favoritesOnly_f1d6dc => 'Только избранные';

  @override
  String get signedOnly_a90195 => 'Только подписанные';

  @override
  String get dewPoint_5fb1ca => 'Точка росы';

  @override
  String get traceRoute_c2e3ed => 'Трассировка маршрута';

  @override
  String get requiresThatThereBeAnAccelerometer_b88b6d =>
      'Требуется наличие акселерометра на вашем устройстве.';

  @override
  String get thisContactHasNoPublicKey_1b1efe =>
      'У этого контакта нет публичного ключа, поэтому его нельзя импортировать. Контакт без ключа стирает любой ключ, который твоя радиостанция уже хранит для этой ноды. Попроси отправителя снова поделиться им, когда его нода обменяется ключами.';

  @override
  String get notifications_ee3c35 => 'Уведомления';

  @override
  String get directMessageNotifications_35b81d =>
      'Уведомления о личных сообщениях';

  @override
  String get positionDeduplication_77bb08 => 'Удаление дубликатов позиций';

  @override
  String get remoteHardwareEnabled_2d4140 => 'Удаленное оборудование включено';

  @override
  String get remoteHardware_aa22db => 'Удаленное устройство';

  @override
  String get delete_86ea33 => 'Удалить';

  @override
  String get deleteKeyBackup_2b8633 => 'Удалить резервную копию ключа';

  @override
  String get smartPosition_71605c => 'Умное позиционирование';

  @override
  String get trafficManagement_c0dc15 => 'Управление движением';

  @override
  String get managedDevice_5802d0 => 'Управляемое устройство';

  @override
  String get controlsTheBlinkingLedOnThe_f98894 =>
      'Управляет мигающим светодиодом на устройстве. Для большинства устройств это будет управлять одним из максимум 4 светодиодов, светодиоды зарядки и GPS не управляются.';

  @override
  String get protectionLevel_b65cfe => 'Уровень защиты';

  @override
  String get rxBoostedGain_ccd314 => 'Усиление приема';

  @override
  String get setsTheScreenClockFormatTo_522029 =>
      'Устанавливает 12-часовой формат экранных часов.';

  @override
  String get device_bc791d => 'Устройство';

  @override
  String get deviceIsManagedByAMesh_c25d72 =>
      'Устройством управляет администратор сети, пользователь не может получить доступ ни к одной настройке устройства.';

  @override
  String get fixedPosition_375f92 => 'Фиксированная позиция';

  @override
  String get fixedPin_a02794 => 'Фиксированный PIN';

  @override
  String get noFilterWordsConfigured_f30bc1 => 'Фильтр слов не настроен';

  @override
  String get messageFilter_cf2a46 => 'Фильтр сообщений';

  @override
  String get filterAllConversations_0c4f61 => 'Фильтровать все диалоги';

  @override
  String get filterWords_42f560 => 'Фильтруемые слова';

  @override
  String get filters_67e16d => 'Фильтры';

  @override
  String get timeZone_47947a => 'Часовой пояс';

  @override
  String get timeZoneForDatesOnThe_ab5297 =>
      'Часовой пояс дат на экране и журнале устройства.';

  @override
  String get frequencySlot_8cb1e6 => 'Частотный слот';

  @override
  String get latitude_e4f731 => 'Широта';

  @override
  String get encryptionEnabled_a31349 => 'Шифрование включено';

  @override
  String get screenOnFor_c40d42 => 'Экран включен на';

  @override
  String get wakeScreenOnTapOrMotion_cbc6f1 =>
      'Экран пробуждения при нажатии или движении';

  @override
  String get exportConfiguration_af2d98 => 'Экспорт настроек';

  @override
  String get powerSaving_668a8d => 'Энергосбережение';

  @override
  String get thisBandwidthIsNotSupportedBy_629cec =>
      'Эта полоса пропускания не поддерживается подключённым радио в выбранном регионе. Выберите поддерживаемое значение перед сохранением.';

  @override
  String get thisConnectedDeviceDoesNotSupport_a098e6 =>
      'Это подключенное устройство не поддерживает верификацию подписи пакетов.';

  @override
  String get thisQrCodeContainsAComplete_8382f2 =>
      'Этот QR-код содержит полную конфигурацию. Это заменит ваши существующие каналы и настройки радио. Все существующие каналы будут удалены.';

  @override
  String get echo_1beee7 => 'Эхо';

  @override
  String get language_ed3f0e => 'Язык';

  @override
  String get thisWillShutdownTheNodePhysical_dda266 =>
      '⚠️ Эта нода будет ВЫКЛЮЧЕНА. Для её включения потребуется физическое взаимодействие.';

  @override
  String get byte_2b1af8 => '1 байт';

  @override
  String get bit_4d4041 => '128 бит';

  @override
  String get bit_4b629b => '256 бит';

  @override
  String get mqttUplinkEnabled_0922b5 => 'MQTT Включена восходящая связь';

  @override
  String get mqttDownlinkEnabled_07f56b => 'MQTT Нисходящая связь включена';

  @override
  String get udpBroadcast_cb95ce => 'UDP-трансляция';

  @override
  String get aTraceRouteWasSentNo_831209 =>
      'Был отправлен запрос трассировки маршрута, ответа получено не было.';

  @override
  String get include_66be7e => 'Включить';

  @override
  String get soilMoisture_09ca2d => 'Влажность почвы';

  @override
  String get thereIsAnIssueWithThis_da58d6 =>
      'Возникла проблема с открытым ключом этого контакта.';

  @override
  String get restore_29f3b2 => 'Восстановить';

  @override
  String get uptime_519192 => 'Время работы';

  @override
  String get second_a0f62f => 'Второй';

  @override
  String get secondaryAdminKey_a17eea => 'Второй ключ админа';

  @override
  String get inputs_4465f9 => 'Входы';

  @override
  String get selectANode_674ed0 => 'Выберите ноду';

  @override
  String get timingAndOverrides_7df059 => 'Выбор времени и переопределения';

  @override
  String get shutDownNode_6cff20 => 'Выключить ноду?';

  @override
  String get altitudeIsMeanSeaLevel_9128a7 => 'Высота над уровнем моря';

  @override
  String get outputPinBuzzerGpio_d0254b => 'Выходной контакт зуммера GPIO';

  @override
  String get longName_4a55b1 => 'Длинное имя';

  @override
  String get forAllMqttFunctionalityOtherThan_528328 =>
      'Для всей функциональности MQTT, кроме отчета карты, вы также должны настроить восходящую и нисходящую связь для каждого канала, который хотите мостить через MQTT.';

  @override
  String get toComplyWithPrivacyLawsLike_17f767 =>
      'Для соблюдения законов о конфиденциальности, таких как CCPA и GDPR, мы избегаем передачи точных данных о местоположении. Вместо этого мы используем анонимизированную или приблизительную (неточную) информацию о местоположении для защиты вашей конфиденциальности.';

  @override
  String get addChannels_236dd4 => 'Добавить каналы';

  @override
  String get addContact_155d11 => 'Добавить контакт';

  @override
  String get advanced_d7907f => 'Дополнительно';

  @override
  String get optionalGpio_967662 => 'Дополнительный GPIO';

  @override
  String get traceRouteLog_eaa487 => 'Журнал трассировки маршрута';

  @override
  String get replaceChannels_d0b4ac => 'Заменить каналы';

  @override
  String get encrypted_347a1a => 'Зашифровано';

  @override
  String get altitudeGeoidalSeparation_166950 => 'Значение коррекции высоты';

  @override
  String get ignored_4561a6 => 'Игнорируется';

  @override
  String get radiation_3bdf95 => 'Излучение';

  @override
  String get usedToIdentifyUnmonitoredOrInfrastructure_57ed87 =>
      'Используется для идентификации неотслеживаемых или инфраструктурных нод, чтобы обмен сообщениями был недоступен для нод, которые никогда не ответят.';

  @override
  String get howLongTheScreenRemainsOn_6187f3 =>
      'Как долго экран остается включенным после нажатия кнопки пользователя или получения сообщений.';

  @override
  String get key_cc6ec0 => 'Ключ';

  @override
  String get directMessageKey_db3f1a => 'Ключ личных переписок';

  @override
  String get adminKeys_59351d => 'Ключи админа';

  @override
  String get moduleConfiguration_4b812e => 'Конфигурация модуля';

  @override
  String get cannedMessagesConfig_458203 =>
      'Конфигурация сохраненных сообщений';

  @override
  String get deviceConfiguration_ccb937 => 'Конфигурация устройства';

  @override
  String get theRootTopicToUseFor_ee86b4 =>
      'Корневая тема для использования MQTT.';

  @override
  String get keyMapping_0f4f90 => 'Назначение клавиш';

  @override
  String get findANode_861918 => 'Найти ноду';

  @override
  String get vehicleHeading_7136f7 => 'Направление транспорта';

  @override
  String get loraConfig_980826 => 'Настройка LoRa';

  @override
  String get externalNotificationConfig_b8060c =>
      'Настройка внешних уведомлений';

  @override
  String get ambientLightingConfig_04051c => 'Настройка окружающего освещения';

  @override
  String get positionConfig_0ef894 => 'Настройка позиции';

  @override
  String get serialConfig_060db9 => 'Настройка последовательного порта';

  @override
  String get radioConfiguration_dbf9ae => 'Настройка радио';

  @override
  String get networkConfig_845e74 => 'Настройка сети';

  @override
  String get storeForwardConfig_27a553 => 'Настройка сохранения и пересылки';

  @override
  String get paxCounterConfig_5a4b67 => 'Настройка счетчика прохожих';

  @override
  String get rangeTestConfig_c02f93 => 'Настройка теста дальности';

  @override
  String get deviceConfig_1c4174 => 'Настройка устройства';

  @override
  String get securityConfig_2b6ab6 => 'Настройки безопасности';

  @override
  String get powerConfig_f44024 => 'Настройки питания';

  @override
  String get telemetryConfig_75dc08 => 'Настройки телеметрии';

  @override
  String get displayConfig_acaf70 => 'Настройки экрана';

  @override
  String get unset_7faabd => 'Не задан';

  @override
  String get unmessagable_42f44c => 'Невозможно отправить сообщение';

  @override
  String get unmonitored_0eff12 => 'Неконтролируемый';

  @override
  String get publicKeyMismatch_a6a194 => 'Несоответствие открытого ключа';

  @override
  String get node_2409cc => 'Нода';

  @override
  String get oneMinute_6d5cba => 'Одна минута';

  @override
  String get ambientLighting_d3a18a => 'Окружающее освещение';

  @override
  String get online_76e9fb => 'Онлайн';

  @override
  String get mapReport_64f9f0 => 'Отчет карты';

  @override
  String get clearStaleNodes_968b4f => 'Очистить устаревшие ноды';

  @override
  String get options_6744ad => 'Параметры';

  @override
  String get ethernetOptions_d9cb39 => 'Параметры Ethernet';

  @override
  String get wifiOptions_612b23 => 'Параметры WiFi';

  @override
  String get sensorOptions_abc34e => 'Параметры датчика';

  @override
  String get environmentSensorOptions_850067 => 'Параметры датчика окружения';

  @override
  String get powerSensorOptions_9aba2f => 'Параметры питания сенсоров';

  @override
  String get serverOption_1dc679 => 'Параметры сервера';

  @override
  String get deviceOptions_4d2301 => 'Параметры устройства';

  @override
  String get primaryGpio_b6ae3c => 'Первичный GPIO';

  @override
  String get primaryAdminKey_e8e5be => 'Первичный ключ администратора';

  @override
  String get firstHeard_fb9dde => 'Первое обнаружение';

  @override
  String get navigateToNode_3ebc01 => 'Перейти к ноде';

  @override
  String get overrideAutomaticOledScreenDetection_3e664c =>
      'Переопределить автоматическое обнаружение OLED-экрана.';

  @override
  String get overrideDefaultScreenLayout_abfc85 =>
      'Переопределить макет экрана по умолчанию';

  @override
  String get shareContactQr_3fcfa5 => 'Поделиться QR контакта';

  @override
  String get shareQrCode_6584cb => 'Поделиться QR-кодом';

  @override
  String get connectToMqttViaProxy_385c9e => 'Подключение к MQTT через прокси';

  @override
  String get details_abaf4c => 'Подробности...';

  @override
  String get confirm_846aff => 'Подтверждение';

  @override
  String get positionsEnabled_05a345 => 'Позиции включены';

  @override
  String get position_c139a7 => 'Позиция';

  @override
  String get search_6433b5 => 'Поиск';

  @override
  String get sequenceNumber_12b28a => 'Порядковый номер';

  @override
  String get afterConfigValuesSaveTheNode_675d86 =>
      'После сохранения значений нода перезагрузится.';

  @override
  String get theLastOfTheDeviceMac_aa05c8 =>
      'Последние 4 символа MAC-адреса устройства будут добавлены к короткому имени для установки имени BLE устройства. Короткое имя может быть длиной до 4 байт.';

  @override
  String get serial_427dc5 => 'Последовательный порт';

  @override
  String get configurationPresets_057e0a => 'Преднастройки конфигурации';

  @override
  String get approximateLocation_5a3d58 => 'Приблизительное местоположение';

  @override
  String get verifyWhoYouAreMessagingWith_690825 =>
      'Проверьте, с кем вы общаетесь, сравнив открытые ключи при личной встрече или по телефону. Самый последний открытый ключ для этой ноды не совпадает с ранее записанным ключом. Вы можете удалить ноду и позволить ей снова обменяться ключами, если смена ключа произошла из-за сброса настроек или другого преднамеренного действия, но это также может указывать на более серьезную проблему безопасности.';

  @override
  String get empty_2138fa => 'Пустой';

  @override
  String get fiveMinutes_960eec => 'Пять минут';

  @override
  String get keySize_b9f9ea => 'Размер ключа';

  @override
  String get allowPositionRequests_11c111 => 'Разрешить запрос позиции';

  @override
  String get advancedDeviceGps_afe61f => 'Расширенное устройство GPS';

  @override
  String get theRegionWhereYouWillBe_5a735c =>
      'Регион, в котором вы будете использовать ваше устройство';

  @override
  String get backup_72f931 => 'Резервная копия';

  @override
  String get keyBackup_30f9f7 => 'Резервная копия ключа';

  @override
  String get roles_265068 => 'Роли';

  @override
  String get channelRole_d02621 => 'Роль канала';

  @override
  String get resetNodedb_58a887 => 'Сброс NodeDB';

  @override
  String get factoryResetWillDeleteDeviceAnd_cd2c63 =>
      'Сброс к заводским настройкам удалит данные устройства и приложения.';

  @override
  String get factoryReset_5dbd37 => 'Сброс настроек';

  @override
  String get channelDetails_1240d4 => 'Сведения о канале';

  @override
  String get userDetails_4f06a9 => 'Сведения о пользователе';

  @override
  String get storeAndForwardServersRequireAn_adeadb =>
      'Серверы сохранения и пересылки требуют устройство ESP32 с PSRAM или Linux Native.';

  @override
  String get vehicleSpeed_32ceef => 'Скорость транспорта';

  @override
  String get regeneratePrivateKey_4eb698 => 'Создать заново закрытый ключ';

  @override
  String get generateANewPrivateKeyTo_cb7634 =>
      'Создать новый закрытый ключ для замены текущего. Открытый ключ будет автоматически создан из вашего закрытого ключа.';

  @override
  String get backupYourPrivateKeyToYour_eef405 =>
      'Создать резервную копию приватного ключа в связку ключей iCloud.';

  @override
  String get messagesSeparateWith_efc965 => 'Сообщения разделяются |';

  @override
  String get cannedMessages_f068fb => 'Сохраненные сообщения';

  @override
  String get storeForward_05111b => 'Сохранить и переслать';

  @override
  String get paxCounter_34f998 => 'Счетчик прохожих';

  @override
  String get soilTemp_e10385 => 'Температура почвы';

  @override
  String get rangeTest_c0e745 => 'Тест дальности';

  @override
  String get controlType_b68319 => 'Тип управления';

  @override
  String get preciseLocation_bdfcca => 'Точное местоположение';

  @override
  String get traffic_6990f2 => 'Трафик';

  @override
  String get tertiaryAdminKey_bc13d6 => 'Третичный ключ администратора';

  @override
  String get deleteAllConfigKeysAndBle_cca1f1 =>
      'Удалить все настройки, ключи и BLE-соединения?';

  @override
  String get deleteAllConfig_8a83a4 => 'Удалить все настройки?';

  @override
  String get deleteNode_d5a0b2 => 'Удалить ноду?';

  @override
  String get batteryLevel_9ffc19 => 'Уровень заряда';

  @override
  String get deviceGps_a724ae => 'Устройство GPS';

  @override
  String get positionFlags_813b55 => 'Флаги позиции';

  @override
  String get color_84b22e => 'Цвет';

  @override
  String get display_0cca12 => 'Экран';

  @override
  String get deviceScreen_566ed6 => 'Экран устройства';

  @override
  String get thisWillDisableFixedPositionAnd_d42ce0 =>
      'Это отключит фиксированную позицию и удалит текущую установленную позицию.';

  @override
  String get thisWillSendACurrentPosition_45fe3d =>
      'Это отправит текущую позицию с вашего телефона и включит фиксированную позицию.';

  @override
  String get airtime_060fe3 => 'Эфирное время';

  @override
  String get ringtoneTransferLanguageRtttlRingtoneString_7d5b14 =>
      'Язык передачи рингтона (RTTTL) - строка рингтона, используемая поддерживаемыми зуммерами во внешних уведомлениях.';

  @override
  String get triggerEventType_8a7f87 => 'Тип события-триггера';

  @override
  String get ledOutputDriveCurrent_1fa019 =>
      'Ток управления для выхода светодиода.';

  @override
  String get mirrorOnly_543934 => 'Только из зеркала';

  @override
  String get nodeLogOnly_3a7130 => 'Только лог ноды';

  @override
  String get positionPrecision_01dd31 => 'Точность позиций';

  @override
  String get prioritizesBroadcastingGpsPositionPackets_090b6f =>
      'Транслирует пакеты местоположения GPS в приоритетном порядке.';

  @override
  String get prioritizesBroadcastingTelemetryPackets_650606 =>
      'Транслирует пакеты телеметрии в приоритетном порядке.';

  @override
  String get tracerouteNotFound_b165bf => 'Трассировка не найдена';

  @override
  String get tracerouteSentWaitingForAResponse_9a18a6 =>
      'Трассировка отправлена — ждём ответ';

  @override
  String get traceroutes_84a6df => 'Трассировки';

  @override
  String get noTraceroutes_921f96 => 'Трассировок нет';

  @override
  String get dark_bd16b2 => 'Тёмная';

  @override
  String get eachNodeHasItsOwnDatabase_534196 =>
      'У каждой ноды своя база: ноды, каналы, сообщения и копия зеркала. Сверх заданного числа самая давно не использованная база удаляется вместе с перепиской; 0 — хранить все. Открытую базу удалить нельзя.';

  @override
  String get thisNodeHasNeitherWiFi_ee205d =>
      'У этой ноды нет ни Wi-Fi, ни Ethernet.';

  @override
  String get removedFromFavorites_f3503a => 'Убрано из избранного';

  @override
  String get reactionNotifications_cb9243 => 'Уведомления о реакциях';

  @override
  String get remoteHardware_9cd039 => 'Удаленное оборудование';

  @override
  String get deleteDatabase_97a78b => 'Удалить базу?';

  @override
  String get deleteImage_8faab6 => 'Удалить картинку?';

  @override
  String get deleteMap_077c0a => 'Удалить карту';

  @override
  String get deleteExtraDatabases_ff4d99 => 'Удалить лишние базы?';

  @override
  String get specifiesHowToRotateOrInvert_c2e76b =>
      'Указывает, как повернуть или инвертировать вывод компаса для точного отображения.';

  @override
  String get ukraineMhz_71f385 => 'Украина 433 Мгц';

  @override
  String get smartInterval_e82120 => 'Умный интервал';

  @override
  String get mentionsOfMyNode_dfdc0f => 'Упоминания моей ноды';

  @override
  String get greenChannelLevelOfTheBacklight_82039b =>
      'Уровень зелёного канала светодиода подсветки.';

  @override
  String get redChannelLevelOfTheBacklight_eecf26 =>
      'Уровень красного канала светодиода подсветки.';

  @override
  String get blueChannelLevelOfTheBacklight_54c801 =>
      'Уровень синего светодиода фоновой подсветки.';

  @override
  String get setManually_8f0d8a => 'Установить вручную';

  @override
  String get usePhonePosition_026914 => 'Установить с телефона';

  @override
  String get youHaveTheLatestVersion_6ae127 => 'Установлена последняя версия';

  @override
  String get deprecatedInfrastructureRoleThatBreaksThe_9d25ee =>
      'Устаревшая инфраструктурная роль, создающая разрывы в цепочке ретрансляции mesh-сети. Переключите эту ноду на роль на основе Router (Router или Router Late).';

  @override
  String get legacyDevice_9f4169 => 'Устаревшее устройство';

  @override
  String get thisDeviceIsNoLongerSupported_1eacd7 =>
      'Устройство больше не поддерживается и не получает обновлений прошивки.';

  @override
  String get communityDevice_ee5a2a => 'Устройство сообщества';

  @override
  String get deviceThatDoesNotForwardPackets_56dca1 =>
      'Устройство, которое не пересылает пакеты с других устройств.';

  @override
  String get deviceThatTransmitsOnlyWhenNecessary_cbb9fa =>
      'Устройство, которое передает сигнал только при необходимости для скрытности или экономии энергии.';

  @override
  String get aCfgFileAsUsedBy_8cf2f0 =>
      'Файл .cfg, как в официальных приложениях';

  @override
  String get theFileDoesNotAppearTo_bd6b67 => 'Файл не похож на картинку';

  @override
  String get theFileDoesNotAppearTo_788b13 =>
      'Файл не похож на резервную копию ключа';

  @override
  String get theFileIsEmpty_e16485 => 'Файл пустой';

  @override
  String get theFileIsTooLargeFor_f5e529 =>
      'Файл слишком большой для конфигурации';

  @override
  String get theFileWasSavedByA_ca52a5 =>
      'Файл сохранён более новой версией приложения';

  @override
  String get fixedPinForBluetoothPairingUsed_5e7b2a =>
      'Фиксированный PIN-код для подключения к Bluetooth. Используется при соединении с фиксированным PIN-кодом';

  @override
  String get philippinesMhz_447f09 => 'Филиппины 433 МГц';

  @override
  String get philippinesMhz_c66f5b => 'Филиппины 868 МГц';

  @override
  String get philippinesMhz_6c76eb => 'Филиппины 915 МГц';

  @override
  String get filtersAndSorting_7551fe => 'Фильтры и сортировка';

  @override
  String get purple_13c197 => 'Фиолетовый';

  @override
  String get hops_859d39 => 'Хопов';

  @override
  String get maximumHops_a86743 => 'Хопов не больше';

  @override
  String get storeAndForward_61adb3 => 'Хранение и пересылка';

  @override
  String get storageAndDeletion_a10344 => 'Хранение и удаление';

  @override
  String get accentColor_ff9b5d => 'Цвет акцента';

  @override
  String get colorOfMessagesMentioningOrReplying_a39b9c =>
      'Цвет сообщений с упоминанием или ответом на ваше';

  @override
  String get colorOfMentionsAndRepliesTo_cbd753 =>
      'Цвет упоминаний и ответов на ваше';

  @override
  String get center_05b1c1 => 'Центр';

  @override
  String get areaCenter_63f063 => 'Центр области';

  @override
  String get particles_e6d802 => 'Частицы';

  @override
  String get codecSampleRate_535520 => 'Частота дискретизации CODEC2';

  @override
  String get chat_8c77e4 => 'Чат';

  @override
  String get whatIsNotSent_7dd3f5 => 'Что НЕ отправляется';

  @override
  String get whatWillBeSent_e8db1a => 'Что будет отправлено';

  @override
  String get whatYouDidWhatYouExpected_81e7ad =>
      'Что делали, что ожидали, что получилось';

  @override
  String get whatIsWrongOptional_5f4ae1 => 'Что не так (необязательно)';

  @override
  String get whatHappened_81dc9f => 'Что случилось';

  @override
  String get black_0d6b1a => 'Чёрная';

  @override
  String get encryption_72622e => 'Шифрование';

  @override
  String get gateway_715fc6 => 'Шлюз';

  @override
  String get exportToFile_5ba2da => 'Экспорт в файл';

  @override
  String get exportPrivateKey_8cfcb4 => 'Экспорт приватного ключа';

  @override
  String get thisDatabaseBelongsToTheCurrently_45a34e =>
      'Это база открытой сейчас ноды — её заменить нельзя';

  @override
  String get thisIsNotAMeshexDatabase_4c1a04 => 'Это не база Meshex';

  @override
  String get thisIsNotAContactLink_e1159c => 'Это не ссылка контакта';

  @override
  String get thisIsNotAMeshtasticChannel_036b26 =>
      'Это не ссылка на каналы Meshtastic';

  @override
  String get thisIsNotASqliteDatabase_c247f9 => 'Это не файл базы SQLite';

  @override
  String get thisIsNotAMeshtasticConfiguration_21780c =>
      'Это не файл конфигурации Meshtastic';

  @override
  String get thisDatabaseIsOpen_86610c => 'Это открытая база';

  @override
  String get thisQrCodeContainsAFull_84c455 =>
      'Этот QR-код содержит полную конфигурацию. Это заменит ваши существующие каналы и настройки радио.';

  @override
  String get s_b759c4 => 'Ю';

  @override
  String get se_e26c37 => 'ЮВ';

  @override
  String get sw_58a11c => 'ЮЗ';

  @override
  String get japan_44a609 => 'Япония';

  @override
  String get aug_098b49 => 'авг.';

  @override
  String get apr_0ab944 => 'апр.';

  @override
  String get possiblySpoofedPositionInterferenceZone_80184e =>
      'вероятно, подменённая точка (зона глушилки)';

  @override
  String get all_ef8ff2 => 'все';

  @override
  String get off_147380 => 'выкл.';

  @override
  String get hpa_d96200 => 'гПа';

  @override
  String get locationServicesAreDisabledOnThe_c9a206 =>
      'геолокация на телефоне выключена';

  @override
  String get dec_e8b13c => 'дек.';

  @override
  String get waitingForResponse_ea1f81 => 'ждём ответ';

  @override
  String get lastHours_154ae5 => 'за 2 ч';

  @override
  String get lastDays_3f4fcc => 'за 7 дней';

  @override
  String get allTime_9790a7 => 'за всё время';

  @override
  String get lastHours_fee233 => 'за сутки';

  @override
  String get lastHour_5702d4 => 'за час';

  @override
  String get loadingNodes_1c32b3 => 'загрузка нод';

  @override
  String get mirror_53fbab => 'зеркало';

  @override
  String get july_8510c0 => 'июля';

  @override
  String get june_1e3af2 => 'июня';

  @override
  String get kg_59ddef => 'кг';

  @override
  String get km_3ced3a => 'км';

  @override
  String get lx_cfc6c7 => 'лк';

  @override
  String get any_3290bc => 'любое';

  @override
  String get mS_73183b => 'м/с';

  @override
  String get ma_6562f3 => 'мА';

  @override
  String get march_cd806e => 'марта';

  @override
  String get may_7bbf85 => 'мая';

  @override
  String get min_d6035d => 'мин';

  @override
  String get rH_34dc16 => 'мкР/ч';

  @override
  String get gM_67c6f5 => 'мкг/м³';

  @override
  String get mm_b8d125 => 'мм';

  @override
  String get marginal_e208a1 => 'на грани';

  @override
  String get connected_abb335 => 'на связи';

  @override
  String get direct_95dc0c => 'напрямую';

  @override
  String get notSetTheFilterIsInactive_8aa65f =>
      'не задан — фильтр не работает';

  @override
  String get unsupportedByTheFirmware_936c06 => 'не поддерживается прошивкой';

  @override
  String get disconnected_0cf65d => 'не подключена';

  @override
  String get disconnected_e29749 => 'не подключено';

  @override
  String get locationAccessDenied_606358 => 'нет доступа к геолокации';

  @override
  String get noKey_edc637 => 'нет ключа';

  @override
  String get noResponse_967d69 => 'нет ответа';

  @override
  String get noNodePublicKey_e13456 => 'нет публичного ключа ноды';

  @override
  String get noNodePublicKeyWaitFor_78601d =>
      'нет публичного ключа ноды — дождитесь её NodeInfo';

  @override
  String get noConnection_75a42a => 'нет связи';

  @override
  String get noNodeConnection_114c0d => 'нет соединения с нодой';

  @override
  String get theNodeDoesNotAcceptDirect_63d6ab =>
      'нода не принимает личные сообщения';

  @override
  String get nov_0adb0f => 'нояб.';

  @override
  String get requiresFirmware_a63ae1 => 'нужна прошивка 2.7.20+';

  @override
  String get requiresFirmware_e37f17 => 'нужна прошивка 2.8+';

  @override
  String get waitingToReconnect_b168a0 => 'ожидание переподключения';

  @override
  String get oct_22e90b => 'окт.';

  @override
  String get primary_8a174a => 'основной';

  @override
  String get externalPower_963740 => 'от сети';

  @override
  String get thePrimaryChannelCannotBeDeleted_1b4706 =>
      'первичный канал не удаляется';

  @override
  String get ping_1b6f5d => 'пинг';

  @override
  String get poor_324298 => 'плохой';

  @override
  String get bySnr_f87a18 => 'по SNR';

  @override
  String get byTime_5bad62 => 'по времени';

  @override
  String get byName_21b8bf => 'по имени';

  @override
  String get default_0d558f => 'по умолчанию';

  @override
  String get byHops_90b84d => 'по хопам';

  @override
  String get connected_f006c9 => 'подключена';

  @override
  String get connecting_794e89 => 'подключение';

  @override
  String get receivingConfiguration_8a745a => 'получение конфигурации';

  @override
  String get onConnectionLoss_24be13 => 'при обрыве связи';

  @override
  String get radio_c9a417 => 'радио';

  @override
  String get s_b40bbc => 'с';

  @override
  String get ownNodeNotLoadedYet_b8cd83 => 'своя нода ещё не загружена';

  @override
  String get sep_309c10 => 'сент.';

  @override
  String get theServerDidNotReturnA_df447b => 'сервер не вернул номер отчёта';

  @override
  String get network_2f481e => 'сеть';

  @override
  String get correctedUsingNeighbors_e10fad => 'скорректировано по соседям';

  @override
  String get tooManyReportsTryAgainLater_6816c9 =>
      'слишком много отчётов, попробуйте позже';

  @override
  String get theNodeConnectionChanged_1d3493 => 'соединение с нодой изменилось';

  @override
  String get fair_f2d6a6 => 'средний';

  @override
  String get test_0ebb88 => 'тест';

  @override
  String get mirrorOnly_cb09e9 => 'только из зеркала';

  @override
  String get justNow_c47cbe => 'только что';

  @override
  String get theContactHasNoPublicKey_3c0ca0 =>
      'у контакта нет публичного ключа';

  @override
  String get yourNodeHasNoCoordinates_1602cf => 'у своей ноды нет координат';

  @override
  String get feb_4d7ceb => 'февр.';

  @override
  String get hop_bbae58 => 'хоп';

  @override
  String get hops_070a7f => 'хопа';

  @override
  String get hops_c54799 => 'хопов';

  @override
  String get good_d5f5ec => 'хороший';

  @override
  String get jan_28e060 => 'янв.';

  @override
  String get defaultKhz_0f9e1a => 'По умолчанию (250 кГц)';

  @override
  String get defaultKhz_696623 => 'По умолчанию (812.5 кГц)';

  @override
  String get rotatesWithThePhone_3acc7b => 'Поворачивается вслед за телефоном';

  @override
  String get rotateWithTwoFingersWhenDisabled_194ca1 =>
      'Поворот двумя пальцами. Выключено — север всегда сверху.';

  @override
  String get noNodesWithCoordinatesMatchThe_70925b =>
      'Под фильтр не подходит ни одна нода с координатами.';

  @override
  String get nothingMatchesTheFilter_42d5b4 => 'Под фильтр ничего не подходит';

  @override
  String get supportedDevice_7bbcea => 'Поддерживаемое устройство';

  @override
  String get supportedWithFirmwareUpdatesSpecializedForm_a06e6b =>
      'Поддерживается, прошивка обновляется; специализированный форм-фактор.';

  @override
  String get support_6ae569 => 'Поддержка';

  @override
  String get connectToTheLastNodeOn_98c221 =>
      'Подключаться к последней ноде при запуске';

  @override
  String get connectingToAMirrorIsOptional_975b0b =>
      'Подключение к зеркалу необязательно: адрес выбираете вы. При проверке адреса и подключении сервер видит IP-адрес соединения, время и параметры запросов, версию приложения и платформу. Сервер может предложить дополнительные сервисы изображений и отчётов на других адресах. Содержимым, журналами и сроками хранения управляет оператор соответствующего сервиса; клиент не управляет этим сервером. Условия обработки и удаления серверных данных уточняйте у его оператора.';

  @override
  String get connectingToACommunityServer_a8bcbd =>
      'Подключение к серверу сообщества';

  @override
  String get connectedSince_c5387f => 'Подключено с';

  @override
  String get connectTheNodeUsingAUsb_c6b502 => 'Подключите ноду кабелем USB';

  @override
  String get connectToANode_6caeff => 'Подключитесь к ноде';

  @override
  String get connectToANodeToImport_c0f2ca =>
      'Подключитесь к ноде, чтобы импортировать';

  @override
  String get connectToANodeToSend_67b4d9 => 'Подключитесь к ноде, чтобы писать';

  @override
  String get connectToYourOwnNode_d2f276 => 'Подключитесь к своей ноде';

  @override
  String get connectToYourOwnNode_cefdf1 => 'Подключитесь к своей ноде.';

  @override
  String get waitBeforeRepeatingTheCommand_4113a0 =>
      'Подождите перед повторной командой';

  @override
  String get pleaseWaitThisActionIsTemporarily_4a28f0 =>
      'Подождите, действие временно недоступно';

  @override
  String get signPacketsFirmware_c59ca8 => 'Подписывают пакеты (прошивка 2.8)';

  @override
  String get signature_a5dcf3 => 'Подпись';

  @override
  String get signatureRejectedHasTheNodeKey_2b76db =>
      'Подпись не принята — ключ ноды изменился? Попробуйте позже';

  @override
  String get senderSignatureVerified_96ee0d => 'Подпись отправителя проверена';

  @override
  String get details_7e4277 => 'Подробнее';

  @override
  String get subnet_05d5fa => 'Подсеть';

  @override
  String get acknowledgmentVerificationFailedPossibleForgery_c5e853 =>
      'Подтверждение не прошло проверку — возможна подделка';

  @override
  String get report_5405a3 => 'Пожаловаться';

  @override
  String get reportThisImage_07a666 => 'Пожаловаться на картинку?';

  @override
  String get pleaseSelectARegion_a28cc4 => 'Пожалуйста, выберите регион';

  @override
  String get positionNotSetYetChooseIts_607bea =>
      'Позиция ещё не задана — выберите, откуда её взять';

  @override
  String get positionBroadcast_9b9f9c => 'Позиция отправлена в сеть';

  @override
  String get positionSentWaitingForAResponse_640d17 =>
      'Позиция отправлена — ждём ответную';

  @override
  String get phonePosition_68a6a2 => 'Позиция телефона';

  @override
  String get searchFromTheNodeList_a208a5 => 'Поиск из списка нод';

  @override
  String get searchSettings_69a03f => 'Поиск по настройкам';

  @override
  String get searchMessages_b03790 => 'Поиск по сообщениям';

  @override
  String get searchingForPorts_eea068 => 'Поиск портов…';

  @override
  String get nothingHereYet_ea91cf => 'Пока пусто';

  @override
  String get showAll_9d04f0 => 'Показать все';

  @override
  String get showAllNodes_174d10 => 'Показать все ноды';

  @override
  String get showMore_b53ec8 => 'Показать ещё';

  @override
  String get showIgnoredNodes_48f862 => 'Показывать игнорируемые';

  @override
  String get showImages_436fda => 'Показывать картинки';

  @override
  String get showHiddenMessages_4e0ac3 => 'Показывать скрытые сообщения';

  @override
  String get privacyPolicy_4041aa => 'Политика конфиденциальности';

  @override
  String get retrievingKeyFromMirror_8c97ce => 'Получение ключа из зеркала…';

  @override
  String get retrievingPublicKeyFromMirror_c82d52 =>
      'Получение публичного ключа из зеркала…';

  @override
  String get attempts_002dd4 => 'Попыток';

  @override
  String get noPortsFound_cc35ea => 'Портов не найдено';

  @override
  String get theNodeWillRestartAfterWriting_a91c98 =>
      'После записи нода перезагрузится и подключение прервётся.';

  @override
  String get timeSinceTheLastPacketFrom_b027b2 =>
      'Последний пакет от ноды — столько назад';

  @override
  String get showPreviewsOfImageServiceLinks_92d5b2 =>
      'Превью ссылок сервиса картинок подключённого сервера прямо в ленте';

  @override
  String get preset_a6549e => 'Пресет';

  @override
  String get uploadingAnImageSendsTheFile_5e9db2 =>
      'При загрузке изображения выбранному сервису передаются файл и ID ноды с подписью запроса. Получатели ссылки могут просматривать изображение. При жалобе передаются ID ноды, ID изображения и указанная причина. Удаление своей картинки доступно, если его поддерживает сервис и в приложении сохранён токен удаления. Оно не удаляет копии, которые могли сохранить другие пользователи.';

  @override
  String get loadingMapsSendsYourIpAddress_c7eb25 =>
      'При загрузке карты сервер тайлов получает IP-адрес и запросы участков карты. В зависимости от подложки используются OpenStreetMap, OpenTopoMap или CARTO либо настроенный прокси. Офлайн-карта скачивается с сайта Meshex. В сборках с собственной проверкой обновлений приложение обращается к API GitHub; автоматическую проверку можно выключить в разделе «О приложении».';

  @override
  String get whenCheckingAnAddressOrConnecting_ac269f =>
      'При проверке адреса и подключении сервер получает:\n• IP-адрес вашего соединения и время запросов;\n• версию приложения и платформу;\n• запрашиваемые данные — например, ID просматриваемой ноды или диапазон истории сообщений.\nОператор может сохранять эти сведения в журнале сервера.';

  @override
  String get theFirmwareAlwaysPreservesFavoritesIn_0ef245 =>
      'При этой роли прошивка всегда сохраняет избранное.';

  @override
  String get zoomIn_0c937d => 'Приблизить';

  @override
  String get appConnectedOrStandaloneMessagingDevice_4df636 =>
      'Приложение подключено или автономное устройство обмена сообщениями.';

  @override
  String get theApplicationWillKeepRunningIn_035e16 =>
      'Приложение продолжит работать в фоне: принимать сообщения и держать связь с нодой. Вернуть окно — значок в трее, выйти — «Выход» в его меню. Изменить это можно в настройках приложения.';

  @override
  String get deliveredWhileTheApplicationIsRunning_ef1ca3 =>
      'Приходят, пока приложение запущено (в том числе в фоне). Звук и баннеры — в системных настройках уведомлений.';

  @override
  String get tracerouteResponseReceived_2f2fbf => 'Пришёл ответ на трассировку';

  @override
  String get checkAndEnable_38d621 => 'Проверить и включить';

  @override
  String get checkAndApply_5b616e => 'Проверить и применить';

  @override
  String get checkForUpdates_fa7bfc => 'Проверить обновления';

  @override
  String get rangeTestEnabled_eed1b9 => 'Проверка дальности включена';

  @override
  String get checkLatitudeLongitudeAndAltitude_3d4bed =>
      'Проверьте широту, долготу и высоту';

  @override
  String get checkOnStartup_6a3174 => 'Проверять при запуске';

  @override
  String get viewedMapTilesOfflineClearCache_5c907e =>
      'Просмотренные тайлы без сети, очистка';

  @override
  String get firmwareIsStillUpdatedButSome_3ef828 =>
      'Прошивка ещё обновляется, но часть функций может быть недоступна.';

  @override
  String get mapReporting_161284 => 'Публикация на карте';

  @override
  String get worksOfflineTheOnlineMapLayer_6371a8 =>
      'Работает без сети. Онлайн-подложка отключена.';

  @override
  String get radio_e36f9c => 'Радио';

  @override
  String get radioMirror_971a23 => 'Радио + Зеркало';

  @override
  String get radius_3dfacb => 'Радиус';

  @override
  String get mapSizeMismatch_1787b9 => 'Размер карты не совпал';

  @override
  String get permissionsAndPhoneLocation_73702c =>
      'Разрешения и позиция телефона';

  @override
  String get allowTransmissionOverLoraRadioDisable_103bcc =>
      'Разрешить передачу по LoRa-радио. Отключай при горячей замене антенн или стендовых испытаниях.';

  @override
  String get disconnects_775091 => 'Разрывов';

  @override
  String get connectionDrops_1da695 => 'Разрывов соединения';

  @override
  String get reactionsToMyMessages_3250d9 => 'Реакции на мои сообщения';

  @override
  String get reactionsToYourMessages_2a4302 => 'Реакции на твои сообщения.';

  @override
  String get ituRegionAmateurM_99c943 => 'Регион МСЭ 3 / Любительский 2 м';

  @override
  String get ituRegionAmateurCm_7aef8d => 'Регион МСЭ 3 / Любительский 70 см';

  @override
  String get periodicallySendsTheLocationAsA_ea2b0e =>
      'Регулярно отправляет местоположение в виде сообщения в основной канал, чтобы помочь с восстановлением устройства.';

  @override
  String get gpsModePhysicalHardware_11df68 =>
      'Режим GPS (физическое оборудование)';

  @override
  String get ipvMode_ed8756 => 'Режим IPv4';

  @override
  String get terrain_35f3e9 => 'Рельеф';

  @override
  String get retransmissions_4ec216 => 'Ретрансляции';

  @override
  String get ringtoneAndCannedMessages_9b84af =>
      'Рингтон и сохраненные сообщения';

  @override
  String get pink_6e9cd3 => 'Розовый';

  @override
  String get russia_3d9a48 => 'Россия';

  @override
  String get n_67bbe9 => 'С';

  @override
  String get fromGithub_c134e1 => 'С GitHub';

  @override
  String get fromWebsite_225fd2 => 'С сайта';

  @override
  String get ne_29cd51 => 'СВ';

  @override
  String get nw_9ecc3e => 'СЗ';

  @override
  String get build_930d47 => 'Сборка';

  @override
  String get resetFilters_03ead0 => 'Сбросить фильтры';

  @override
  String get details_99bf04 => 'Сведения';

  @override
  String get minimizeToTray_a1d8e8 => 'Свернуть в трей';

  @override
  String get minimizeToTray_2b2ecc => 'Свернуть в трей?';

  @override
  String get light_726f3e => 'Свет';

  @override
  String get minimizeToTrayOnClose_720ae8 => 'Сворачивать в трей при закрытии';

  @override
  String get ownNode_237648 => 'Своя нода';

  @override
  String get ownNodeIdModelFirmwareRole_2fdfaf =>
      'Своя нода: ID, модель, прошивка, роль, регион, пресет, число нод и каналов';

  @override
  String get contactTheDeveloper_ca5284 => 'Связаться с разработчиком';

  @override
  String get connection_cbc0f9 => 'Связь';

  @override
  String get theNodeConnectionAndNotificationsKeep_155e05 =>
      'Связь с нодой и уведомления продолжают работать. Выключено — крестик закрывает приложение.';

  @override
  String get theNodeDisconnectedItAppearsTo_25e160 =>
      'Связь с нодой пропала — похоже, она перезагружается и применяет настройки. После переподключения проверьте значения.';

  @override
  String get northUp_be8de1 => 'Север сверху';

  @override
  String get rsyslogServer_49feb1 => 'Сервер rsyslog';

  @override
  String get theServerMayAlsoOfferImage_a319bd =>
      'Сервер также может предлагать сервисы изображений и отчётов на других адресах. При обращении к ним их операторы тоже видят IP-адрес и запросы. При загрузке изображения передаются файл и ID ноды; при жалобе — ID ноды, ID изображения и причина жалобы. Состав диагностического отчёта показан отдельно перед отправкой.';

  @override
  String get communityServers_917685 => 'Серверы сообществ';

  @override
  String get serviceTemporarilyUnavailable_3bd3fd =>
      'Сервис временно недоступен';

  @override
  String get theImageServiceIsNotResponding_3a7b0d =>
      'Сервис картинок не отвечает — проверьте интернет';

  @override
  String get theServiceDidNotRespondIn_cfe928 => 'Сервис не ответил вовремя';

  @override
  String get theServiceDoesNotKnowYour_ca4501 =>
      'Сервис пока не знает вашу ноду: она должна появиться на карте зеркала';

  @override
  String get serialPort_7f0e67 => 'Серийный порт';

  @override
  String get singaporeMhz_2b2999 => 'Сингапур 923 МГц';

  @override
  String get blue_04954c => 'Синий';

  @override
  String get system_3ac98f => 'Система';

  @override
  String get systemLightDarkOrBlackOled_edaf2a =>
      'Система, светлая, тёмная или чёрная (OLED)';

  @override
  String get scanQr_ba92dd => 'Сканировать QR';

  @override
  String get scanContact_be9772 => 'Сканировать контакт';

  @override
  String get downloadMap_df5ad3 => 'Скачать карту';

  @override
  String get numberOfDatabasesToKeep_dd8856 => 'Сколько баз хранить';

  @override
  String get copied_892254 => 'Скопировано';

  @override
  String get copy_ed4950 => 'Скопировать';

  @override
  String get copyNumber_82ae50 => 'Скопировать номер';

  @override
  String get copyLink_a44800 => 'Скопировать ссылку';

  @override
  String get serialBaudRate_bbbfb6 => 'Скорость COM-порта';

  @override
  String get hideNodesBeyondTheRadius_93e947 => 'Скрывать ноды дальше радиуса';

  @override
  String get hideMessagesMatchingFiltersInEvery_5d3016 =>
      'Скрывать сообщения, содержащие фильтры, в каждом канале и ЛС. Выключить для одного разговора — в его меню.';

  @override
  String get hideNodesViaMqtt_a06257 => 'Скрыть ноды через MQTT';

  @override
  String get monitor_a0b8fc => 'Следить';

  @override
  String get tooManyRequestsTryAgainLater_f13749 =>
      'Слишком часто, попробуйте позже';

  @override
  String get wordOrRegexPattern_d88d91 => 'Слово или regex:шаблон';

  @override
  String get layers_16876c => 'Слои';

  @override
  String get domainNameSystemDns_6275c5 => 'Служба доменных имен (DNS)';

  @override
  String get lastHeard_07e526 => 'Слышали';

  @override
  String get heardOverTheAir_d31ee9 => 'Слышно в эфире';

  @override
  String get noLongerSupported_e39ef3 => 'Снято с поддержки';

  @override
  String get connectionEventsPacketsAndNodeLog_745e44 =>
      'События соединения, пакеты и лог ноды';

  @override
  String get connection_0427c0 => 'Соединение';

  @override
  String get connectionDuration_c69bbf => 'Соединение держится';

  @override
  String get unitedStatesOfAmerica_7fc1f6 => 'Соединенные Штаты Америки';

  @override
  String get messageFromAnIgnoredNodeTap_0685fd =>
      'Сообщение от игнорируемой ноды — показать';

  @override
  String get noMessagesYet_165664 => 'Сообщений пока нет';

  @override
  String get messagesFromIgnoredNodesAreCollapsed_379dd7 =>
      'Сообщения игнорируемых нод — свёрнутыми, раскрываются нажатием. Выключено — их не видно совсем';

  @override
  String get messagesFromHiddenChannelsAreNot_ae5ae7 =>
      'Сообщения скрытых каналов не загружаются из зеркала. Вернёте канал — его лента подгрузится снова.';

  @override
  String get messagesContainingTheseWordsWillBe_3bfbda =>
      'Сообщения, содержащие эти слова, будут скрыты. Слово ищется целиком, без учёта регистра; regex:шаблон — регулярное выражение.';

  @override
  String get giveThisNumberToTheDeveloper_53370d =>
      'Сообщите этот номер разработчику — по нему он найдёт ваш отчёт.';

  @override
  String get bluetoothPairingOnLinux_5f59c4 => 'Сопряжение Bluetooth в Linux';

  @override
  String get sort_ed0301 => 'Сортировка';

  @override
  String get connectionStatusTransportBleNameOr_ccaddd =>
      'Состояние соединения: способ подключения (имя BLE или адрес ноды), попытки и разрывы';

  @override
  String get savingToNode_283e94 => 'Сохранение на ноде';

  @override
  String get saved_f0dff5 => 'Сохранено';

  @override
  String get saveTheSettingsTheProxyWill_d1d086 =>
      'Сохраните настройки: прокси подключится, когда клиент-прокси будет включён в ноде.';

  @override
  String get saveToFile_cdda1c => 'Сохранить в файл';

  @override
  String get saveChannel_cc1444 => 'Сохранить канал?';

  @override
  String get saveUserConfigurationToS_8e9bf5 =>
      'Сохранить конфигурацию пользователя в %s?';

  @override
  String get saveBluetoothSettings_0dcf49 => 'Сохранить настройки Bluetooth?';

  @override
  String get saveMqttSettings_fd988d => 'Сохранить настройки MQTT?';

  @override
  String get saveStoreForwardSettings_bb7b6d =>
      'Сохранить настройки Store & Forward?';

  @override
  String get saveTakSettings_a0c983 => 'Сохранить настройки TAK?';

  @override
  String get saveSecuritySettings_a7801d => 'Сохранить настройки безопасности?';

  @override
  String get saveExternalNotificationSettings_96386a =>
      'Сохранить настройки внешних уведомлений?';

  @override
  String get saveDetectionSensorSettings_b580f0 =>
      'Сохранить настройки датчика обнаружения?';

  @override
  String get saveAudioSettings_8ccb7e => 'Сохранить настройки звука?';

  @override
  String get saveNeighborInformationSettings_c94aec =>
      'Сохранить настройки информации о соседях?';

  @override
  String get saveAmbientLightingSettings_c54691 =>
      'Сохранить настройки окружающего освещения?';

  @override
  String get savePowerSettings_0a3030 => 'Сохранить настройки питания?';

  @override
  String get savePositionSettings_876ad7 => 'Сохранить настройки позиции?';

  @override
  String get saveSerialSettings_9fde53 =>
      'Сохранить настройки последовательного порта?';

  @override
  String get saveNetworkSettings_5ed6f6 => 'Сохранить настройки сети?';

  @override
  String get saveCannedMessageSettings_2594d4 =>
      'Сохранить настройки сохраненных сообщений?';

  @override
  String get savePaxCounterSettings_2cf0b9 =>
      'Сохранить настройки счетчика прохожих?';

  @override
  String get saveTelemetrySettings_35193a => 'Сохранить настройки телеметрии?';

  @override
  String get saveRangeTestSettings_284561 =>
      'Сохранить настройки теста дальности?';

  @override
  String get saveRemoteHardwareSettings_bee1fe =>
      'Сохранить настройки удаленного оборудования?';

  @override
  String get saveTrafficManagementSettings_22a20b =>
      'Сохранить настройки управления движением?';

  @override
  String get saveDeviceSettings_be53bb => 'Сохранить настройки устройства?';

  @override
  String get saveDisplaySettings_d04519 => 'Сохранить настройки экрана?';

  @override
  String get saveFile_d10137 => 'Сохранить файл';

  @override
  String get linksInSentMessagesWillStop_a4253e =>
      'Ссылка в отправленных сообщениях перестанет открываться.';

  @override
  String get contactLink_3b3d44 => 'Ссылка контакта';

  @override
  String get theLinkIsEmpty_800d53 => 'Ссылка пуста';

  @override
  String get linkCopied_49261e => 'Ссылка скопирована';

  @override
  String get theLinkIsTooLong_75ef62 => 'Ссылка слишком длинная';

  @override
  String get stop_6d714e => 'Стоп';

  @override
  String get bluetoothConnectionStrategy_56baed =>
      'Стратегия подключения Bluetooth';

  @override
  String get posixTimeZoneDefinition_87d573 =>
      'Строка определения часового пояса POSIX';

  @override
  String get dewPoint_2b7056 => 'Т. росы';

  @override
  String get thailand_03ddbe => 'Таиланд';

  @override
  String get taiwan_2cc337 => 'Тайвань';

  @override
  String get messageTextTheLogContainsOnly_d95f22 =>
      'Текст сообщений (в журнале — только размер)';

  @override
  String get currentApplicationSettingsAndRecentConnections_ae2892 =>
      'Текущие настройки приложения и недавние подключения будут заменены данными из файла. Базы нод не изменятся.';

  @override
  String get mirror_14fdf3 => '(зеркало)';

  @override
  String get khz_872eb4 => '125 кГц';

  @override
  String get khz_501421 => '203.125 кГц';

  @override
  String get h_4c8c75 => '24Ч';

  @override
  String get khz_1ebb85 => '31 кГц';

  @override
  String get khz_d95d4a => '406.25 кГц';

  @override
  String get khz_ac5e55 => '500 кГц';

  @override
  String get khz_91b5e4 => '62 кГц';

  @override
  String get d_3ecbe0 => '7Д';

  @override
  String get khz_56b83b => '812.5 кГц';

  @override
  String get nodeMac_49269c => '<MAC ноды>';

  @override
  String get bluetoothEnabled_3469b5 => 'Bluetooth включен';

  @override
  String get bluetoothAndTheLocalNetworkConnect_2e6ed6 =>
      'Bluetooth и локальная сеть используются для подключения к нодам, камера — для сканирования QR-кодов. Уведомления сообщают о событиях приложения. Геопозиция используется при выборе позиции телефона и при включённой передаче позиции своей ноде. Передача выключена по умолчанию. Прошивка ноды может дальше распространять координаты по своим настройкам. Разрешения можно изменить в настройках операционной системы.';

  @override
  String get codecEnabled_8e6ef2 => 'CODEC 2 включен';

  @override
  String get serialPortEnabled_c878e2 => 'COM-порт включен';

  @override
  String get ethernetEnabled_7440bf => 'Ethernet включен';

  @override
  String get gpioPinForThePwmBuzzer_ac885c => 'GPIO-вывод для ШИМ-зуммера';

  @override
  String get gpioPinForTheUserButton_a5b887 =>
      'GPIO-вывод для пользовательской кнопки; можно переназначить на платах с несколькими кнопками';

  @override
  String get mirrorId_9b8cbe => 'ID в зеркале';

  @override
  String get packetId_869cfb => 'ID пакета';

  @override
  String get packetIdHex_7d2120 => 'ID пакета (hex)';

  @override
  String get theIdMatchesTheNodeMac_ca22a6 =>
      'ID совпадает с MAC-адресом ноды — исправлять нечего.';

  @override
  String get nodeIpOrHostname_4e0881 => 'IP или хост ноды';

  @override
  String get theJsonFileContainsTheUnencrypted_470e15 =>
      'JSON-файл содержит незашифрованный приватный ключ ноды. Любой, у кого есть этот файл, сможет использовать ключ вашей ноды. Храните файл в защищённом месте и не передавайте посторонним.';

  @override
  String get communitySupportedLinuxDevice_372e0a =>
      'Linux-устройство, поддерживается сообществом.';

  @override
  String get macAndDeviceIdOfThe_018be2 => 'MAC и device_id подключённой ноды';

  @override
  String get thisMacBelongsToADifferent_c8f6b3 => 'MAC не от этой ноды';

  @override
  String get yourNodeMacIsUnknown_80e80c => 'MAC своей ноды неизвестен';

  @override
  String get mqttEnabled_47dd00 => 'MQTT включен';

  @override
  String get meshexIsAClientForMeshtastic_b9497b =>
      'Meshex — клиент для радионод Meshtastic. Приложение хранит на устройстве сообщения, сведения о нодах и их позициях, настройки, конфигурацию подключённых нод и диагностический журнал. Очистка данных в настройках приложения действует на локальные данные, а не на радиоэфир и сторонние серверы.';

  @override
  String get ntpServer_0f61dc => 'NTP-сервер';

  @override
  String get nodeinfoSent_16d722 => 'NodeInfo отправлена';

  @override
  String get nodeinfoBroadcast_f42668 => 'NodeInfo отправлена в сеть';

  @override
  String get paFanDisabled_a9c1ad => 'PA вентилятор выключен';

  @override
  String get storeForwardEnabled_a01444 => 'Store & Forward включена';

  @override
  String get telegramOrEmailIfYouWould_8f673d =>
      'Telegram, почта — если нужен ответ';

  @override
  String get wiFiEnabled_c884a7 => 'Wi-Fi включен';

  @override
  String get fromNumMustPrecedeToNum_be1e5b =>
      'from_num должен идти раньше to_num';

  @override
  String get possiblySpoofedPosition_5ca05b => '· вероятно, подменённая точка';

  @override
  String get corrected_a0b938 => '· скорректировано';

  @override
  String get automaticPortraitLandscapeReversedOrientations_3e0120 =>
      'Авто, книжная, альбомная, перевёрнутые';

  @override
  String get automaticallyCyclesThroughDisplayPagesAt_13281c =>
      'Автоматически переключает на следующую страницу на экране как карусель, основываясь на заданном интервале.';

  @override
  String get adminAccessAndFlagsNodeKeys_502b16 =>
      'Админ-доступ и флаги (ключи ноды сохранятся)';

  @override
  String get mqttServerAddress_615ec8 => 'Адрес MQTT-сервера';

  @override
  String get mirrorAddressAndData_e46280 => 'Адрес и данные зеркала';

  @override
  String get mirrorServerAddressChatMessagesAnd_64453e =>
      'Адрес сервера зеркала: с него приходят чат и ноды из MQTT. Пока зеркало выключено, приложение не подключается к нему. Проверка адреса тоже отправляет запрос на указанный сервер.';

  @override
  String get landscape_53bf5f => 'Альбомная';

  @override
  String get landscapeReversed_089eb6 => 'Альбомная перевёрнутая';

  @override
  String get nodeHardwareIds_a78041 => 'Аппаратные id ноды';

  @override
  String get applicationDatabase_4d6431 => 'База приложения';

  @override
  String get databaseSaved_190541 => 'База сохранена';

  @override
  String get nodeDatabases_1e2d9d => 'Базы нод';

  @override
  String get noNodeMirrorOnly_7434e1 => 'Без ноды (только зеркало)';

  @override
  String get noHighlight_14736b => 'Без подсветки';

  @override
  String get unencrypted_74bae3 => 'Без шифрования';

  @override
  String get securityChangesNodeKeysAndAdmin_a52c58 =>
      'Безопасность меняет ключи и админ-доступ ноды — включайте, только если это копия этой же ноды.';

  @override
  String get teal_9161f9 => 'Бирюзовый';

  @override
  String get v_b25cd7 => 'В';

  @override
  String get theFollowingChannelsWereFoundIn_c3f485 =>
      'В QR-коде были найдены следующие каналы. Существующие каналы будут сохранены.';

  @override
  String get appliesToTheNodeListAnd_f9af88 =>
      'В списке и на карте. Ноды без координат и своя нода не скрываются.';

  @override
  String get theLinkContainsMoreThanChannels_158006 =>
      'В ссылке больше 8 каналов';

  @override
  String get theLinkHasNoChannelData_a0a60d => 'В ссылке нет данных каналов';

  @override
  String get theLinkContainsNoChannels_a613c7 => 'В ссылке нет каналов';

  @override
  String get theLinkHasNoLoraSettings_2b6cd1 =>
      'В ссылке нет настроек LoRa — каналы можно только добавить';

  @override
  String get theFileWillContainYourNode_2c8772 =>
      'В файле будут адреса ваших нод и зеркала. Храните его у себя и никому не передавайте.';

  @override
  String get theFileWillContainNodeKeys_7a17b9 =>
      'В файле будут ключи ноды, ключи каналов и пароли Wi-Fi/MQTT. Не передавайте его посторонним.';

  @override
  String get theFileContainsNoNodeData_fba6b0 => 'В файле нет данных ноды';

  @override
  String get theFileContainsNoKeys_274a37 => 'В файле нет ключей';

  @override
  String get theFileContainsNoSettings_6865dd => 'В файле нет настроек';

  @override
  String get theFileContainsNoApplicationSettings_276e18 =>
      'В файле нет настроек приложения';

  @override
  String get yourCommentAndContactDetailsIf_7eb17d =>
      'Ваш комментарий и контакт, если укажете';

  @override
  String get enterAtLeastCharacters_ffcd3a => 'Введите хотя бы 2 символа';

  @override
  String get restore_c7aaa9 => 'Вернуть';

  @override
  String get osVersion_8aba4a => 'Версия ОС';

  @override
  String get yourApplicationVersionIsOutdatedPlease_d5ccc4 =>
      'Версия приложения устарела — обновите его';

  @override
  String get applicationVersionPhoneModelOsVersion_3c056a =>
      'Версия приложения, модель телефона, версия ОС, язык и часовой пояс';

  @override
  String get vibrateOnNotification_d0009e => 'Вибрация при уведомлении';

  @override
  String get nodeRowLayout_12026b => 'Вид строки ноды';

  @override
  String get visibleOnlyToYou_e71a47 => 'Видна только вам';

  @override
  String get enablesAutomaticTakPliBroadcastsAnd_e4e185 =>
      'Включает автоматические трансляции TAK PLI и сокращает рутинные трансляции.';

  @override
  String get byEnablingThisFeatureYouAcknowledge_de04ee =>
      'Включив эту функцию, вы подтверждаете и даете явное согласие на передачу данных о географическом местоположении вашего устройства в режиме реального времени по протоколу MQTT без шифрования. Эти данные о местоположении могут использоваться для таких целей, как создание отчетов по карте в режиме реального времени, отслеживание устройства и связанные с этим функции телеметрии.\n\nИмейте в виду, что поскольку отчет карты не зашифрован, ваши данные могут быть постоянно сохранены и отображены третьими сторонами. Meshtastic не несет ответственности за такое хранение, отображение или раскрытие этих данных.\n\nЯ прочитал и понимаю вышеизложенное. Я добровольно даю согласие на незашифрованную передачу данных моей ноды через MQTT.';

  @override
  String get enableBluetoothOnThisDevice_392fce =>
      'Включить Bluetooth на устройстве';

  @override
  String get enableMqttGateway_540669 => 'Включить MQTT-шлюз';

  @override
  String get enableCodecAudioEncodingDecodingFor_7f4387 =>
      'Включить кодирование/декодирование звука Codec2 для голосовой связи по mesh-сети.';

  @override
  String get owner_926e3b => 'Владелец';

  @override
  String get externalPower_684553 => 'Внешнее питание';

  @override
  String get externalNotificationsEnabled_06341b =>
      'Внешние уведомления включены';

  @override
  String get scrollDownAllMessagesRead_292955 => 'Вниз, всё прочитано';

  @override
  String get questionsBugReportsAndPrivacyRequests_5ebcd5 =>
      'Вопросы, сообщения об ошибках и обращения о конфиденциальности можно оставить в Issues проекта Meshex. Для создания обращения нужен аккаунт GitHub. Обращения могут быть публичными: не публикуйте приватные ключи, пароли, точные координаты и другие личные сведения. По вопросам содержимого и удаления данных на сервере сообщества обращайтесь к его оператору.';

  @override
  String get mapRotation_8a6270 => 'Вращение карты';

  @override
  String get allMessagesInThisChatWill_6baa0a =>
      'Все сообщения этого чата удалятся с этого устройства. У собеседника они останутся.';

  @override
  String get allFeaturesUnderActiveDevelopment_ce30a3 =>
      'Все функции, активная разработка.';

  @override
  String get alwaysOn_43ba2d => 'Всегда включен';

  @override
  String get sendAnyway_c6bcaa => 'Всё равно отправить';

  @override
  String get youChooseTheServerItsOperator_f140c4 =>
      'Вы сами выбираете сервер. Его оператор управляет содержимым, доступностью и хранением данных; клиент не управляет этим сервером. Подключайтесь к операторам, которым доверяете.';

  @override
  String get chooseAKeyToRestore_9fa859 => 'Выбери ключ для восстановления';

  @override
  String get selectAChannelOrConversation_3b7ddb => 'Выберите канал или диалог';

  @override
  String get chooseFile_2e31da => 'Выбрать файл';

  @override
  String get quit_026abb => 'Выйти';

  @override
  String get disabled_d934ae => 'Выключено';

  @override
  String get altitudeM_4e463b => 'Высота, м';

  @override
  String get gas_5d1111 => 'Газ';

  @override
  String get locationServicesAreDisabled_34928e =>
      'Геолокация выключена в системе';

  @override
  String get clusterNodes_d1274e => 'Группировать ноды';

  @override
  String get distantNodes_c51034 => 'Дальние ноды';

  @override
  String get data_d8e5fd => 'Данные';

  @override
  String get dataOnThisDevice_2ff795 => 'Данные на устройстве';

  @override
  String get detectionSensorEnabled_1b4f0e => 'Датчик определения включен';

  @override
  String get diagnosticReports_1eec79 => 'Диагностические отчёты';

  @override
  String get theBlePinMustContainDigits_d88065 =>
      'Длина пин-кода BLE должна быть 6 цифр.';

  @override
  String get bluetoothWaitTime_de4a08 => 'Длительность ожидания Bluetooth';

  @override
  String get forNodesWithoutGpsPhoneCoordinates_e96e7e =>
      'Для нод без GPS: координаты телефона уходят только своей ноде, в сеть их рассылает прошивка по своим настройкам. Работает, пока приложение открыто и подключено.';

  @override
  String get setBothTheTimeWindowAnd_7dff47 =>
      'Для ограничения скорости задайте и окно, и число пакетов.';

  @override
  String get useDataToClearTheLocal_2715b2 =>
      'Для очистки локальной базы используйте раздел «Данные», для удаления сохранённой копии ключа — раздел «Безопасность». Отдельно управляйте файлами экспорта и резервными копиями операционной системы. Удаление локальных данных не отзывает радиопакеты и не удаляет данные у других участников сети. Вопросы о работе приложения и обработке данных можно направить через контакт ниже.';

  @override
  String get addNote_57d0f4 => 'Добавить заметку';

  @override
  String get addedToFavorites_d0d718 => 'Добавлено в избранное';

  @override
  String get rain_aad03f => 'Дождь';

  @override
  String get rainH_770fb0 => 'Дождь 1ч';

  @override
  String get rainH_b2fa03 => 'Дождь 24ч';

  @override
  String get delivered_9b68fb => 'Доставлено';

  @override
  String get deliveredVerifiedByTheRecipient_0d8f81 =>
      'Доставлено, подтверждено получателем';

  @override
  String get moreEmoji_2bfd6b => 'Другие эмодзи';

  @override
  String get itsMirrorMessagesWillBeDeleted_d9e39c =>
      'Его сообщения из зеркала удалятся и больше не будут загружаться. Вернуть канал можно в настройках зеркала.';

  @override
  String get measurementUnitsShownOnTheDevice_573c1c =>
      'Единицы измерения, отображаемые на экране устройства.';

  @override
  String get ifYourPhoneCannotConnectAfter_9fa7f4 =>
      'Если после перезагрузки телефон не подключается к ноде, перезагрузите её ещё раз.';

  @override
  String get hasCoordinates_4d4419 => 'Есть координаты';

  @override
  String get hasPublicKey_dd027c => 'Есть публичный ключ';

  @override
  String get hasPublicKeyPki_b08915 => 'Есть публичный ключ (PKI)';

  @override
  String get reportSent_050a2d => 'Жалоба отправлена';

  @override
  String get theReportWillBeSentTo_5e4e2b => 'Жалоба уйдёт оператору сервера';

  @override
  String get waitingForCoordinates_8cafb9 => 'Ждём координаты';

  @override
  String get waitingForANodeConnection_617dba => 'Ждём подключения к ноде';

  @override
  String get journal_67ade7 => 'Журнал';

  @override
  String get reportLog_c75086 => 'Журнал для отчёта';

  @override
  String get applicationAndNodeLogsAndDetails_395cd3 =>
      'Журнал и сведения о приложении и ноде';

  @override
  String get applicationLogFromRecentLaunchesConnection_a484f1 =>
      'Журнал приложения за последние запуски: события соединения, служебные пакеты, лог прошивки ноды, ошибки. В журнале есть ID и имена нод из эфира';

  @override
  String get journalCopied_1ee14a => 'Журнал скопирован';

  @override
  String get w_a9d7eb => 'З';

  @override
  String get outsideTheDownloadedSaintPetersburgMap_24a118 =>
      'За пределами скачанной карты Петербурга';

  @override
  String get forget_90bc7d => 'Забыть';

  @override
  String get loadMore_010963 => 'Загрузить ещё';

  @override
  String get loadFromFile_e47fd3 => 'Загрузить из файла';

  @override
  String get imageUploadsAreBlockedForYour_4267f6 =>
      'Загрузка картинок для вас заблокирована';

  @override
  String get downloadCanceled_13f622 => 'Загрузка отменена';

  @override
  String get radioTrafficUpload_cd86b2 => 'Загрузка эфира';

  @override
  String get maximumHopCountByDefaultHigher_c79f9b =>
      'Задает максимальное количество прыжков, по умолчанию - 3. Увеличение количества также увеличивает перегрузку и должно использоваться с осторожностью. Сообщения с 0 прыжков не будут получать подтверждения.';

  @override
  String get privateKey_378280 => 'Закрытый ключ';

  @override
  String get replaceDatabase_1a5ae6 => 'Заменить базу?';

  @override
  String get noRadioMeasurementsYet_45e333 => 'Замеров по радио пока нет';

  @override
  String get note_917b58 => 'Заметка';

  @override
  String get write_4be730 => 'Записать';

  @override
  String get writeConfigurationFromAFileTo_5b4b13 =>
      'Записать конфигурацию из файла в ноду';

  @override
  String get requestSentWaitingForAResponse_8172e2 =>
      'Запрос отправлен — ждём ответ';

  @override
  String get request_ebdfd9 => 'Запросить';

  @override
  String get requestTelemetry_c5374e => 'Запросить телеметрию';

  @override
  String get charge_b1ad91 => 'Заряд';

  @override
  String get encrypted_9cdd75 => 'Зашифрован';

  @override
  String get nodesYouHaveConnectedToWill_436ad0 =>
      'Здесь появятся ноды, к которым вы подключались';

  @override
  String get green_6989f8 => 'Зеленый';

  @override
  String get green_a0f667 => 'Зелёный';

  @override
  String get mirror_66ace6 => 'Зеркало';

  @override
  String get mirrorInterferenceZonesCouldNotBe_7b5b5d =>
      'Зеркало: зоны глушилок не загружены';

  @override
  String get mirrorNodesCouldNotBeLoaded_41ed72 => 'Зеркало: ноды не загружены';

  @override
  String get identifier_754cba => 'Идентификатор';

  @override
  String get searchingTheNetwork_bdab2d => 'Идёт поиск в сети…';

  @override
  String get searchingForNodes_ba19cf => 'Идёт поиск нод…';

  @override
  String get fromMirror_f5296f => 'Из зеркала';

  @override
  String get favoriteAndIgnoredNodesAreAlways_f2c698 =>
      'Избранные и игнорируемые ноды всегда сохраняются. Другие ноды удаляются из базы данных приложения через заданное число дней. (Ноды с ключами PKC всегда сохраняются не менее 7 дней.) Удаляются только ноды, которых нет в базе нод устройства; своя нода и ноды с заметкой тоже сохраняются.';

  @override
  String get imagesAndReports_a79f68 => 'Изображения и жалобы';

  @override
  String get theLinkContainsDuplicateChannelNames_3b33c1 =>
      'Имена каналов в ссылке повторяются';

  @override
  String get importDatabaseFromFile_81e7f3 => 'Импорт базы из файла';

  @override
  String get importNodeDatabaseFromFile_7ff7a5 => 'Импорт базы ноды из файла';

  @override
  String get importFromFile_f190b3 => 'Импорт из файла';

  @override
  String get sensorNameForMeshMessages_40e05a =>
      'Имя датчика для сообщений mesh-сети';

  @override
  String get nameOrId_ffe28b => 'Имя или !id';

  @override
  String get nodeNameOrId_ee4d66 => 'Имя или id ноды';

  @override
  String get indigo_03aba6 => 'Индиго';

  @override
  String get nodeInformationBroadcastInterval_0a98b2 =>
      'Интервал вещания передачи информации об узле';

  @override
  String get airQualityUpdateInterval_008585 =>
      'Интервал обновления данных качества воздуха';

  @override
  String get environmentMetricsUpdateInterval_5d18f2 =>
      'Интервал обновления метрик среды';

  @override
  String get deviceMetricsUpdateInterval_d890da =>
      'Интервал обновления метрик устройства';

  @override
  String get powerMetricsUpdateInterval_d4bac6 =>
      'Интервал обновления метрик электропитания';

  @override
  String get stateBroadcastInterval_bec9d7 => 'Интервал передачи состояния';

  @override
  String get repeatInterval_51be08 => 'Интервал повтора';

  @override
  String get mapReportInterval_bee95f => 'Интервал публикации на карте';

  @override
  String get neighborInformation_2b7dad => 'Информация о соседях';

  @override
  String get neighborInformationEnabled_c25a9a =>
      'Информация о соседях включена';

  @override
  String get infrastructureNodeThatAlwaysRetransmitsPackets_704f22 =>
      'Инфраструктурная нода, которая всегда ретранслирует пакеты один раз, но только после всех остальных режимов. Отображается в списке нод. Не лучший выбор для нод на крышах.';

  @override
  String get search_58212e => 'Искать';

  @override
  String get useTheModemPresetInsteadOf_941abf =>
      'Использовать настройки пресета модема вместо ручного указания полосы пропускания, коэффициента расширения и скорости кодирования';

  @override
  String get useDownloadedMap_9e8629 => 'Использовать скачанную карту';

  @override
  String get codecBitrateTheSampleRateIs_1a0df2 =>
      'Используемая скорость передачи Codec2. Частота дискретизации всегда 8 кГц. Более низкие скорости используют меньше полосы пропускания, но снижают качество звука.';

  @override
  String get repair_9b1c9a => 'Исправить';

  @override
  String get repairNodeId_47d759 => 'Исправить ID ноды';

  @override
  String get repairNodeId_16de55 => 'Исправить ID ноды?';

  @override
  String get repairAndRestart_0ef1ee => 'Исправить и перезагрузить';

  @override
  String get repairedTheNodeMacWasSent_4c3760 =>
      'Исправлено: ноде отправлен её MAC';

  @override
  String get source_8290a3 => 'Источник';

  @override
  String get kazakhstanMhz_c0f5fd => 'Казахстан 433 МГц';

  @override
  String get kazakhstanMhz_26f59e => 'Казахстан 863 МГц';

  @override
  String get howOftenToRequestGpsCoordinates_8f0f04 =>
      'Как часто запрашивать координаты GPS (<10 секунд держит GPS включенным постоянно).';

  @override
  String get theChannelWillBeDisabledOn_3cb75d =>
      'Канал будет отключен на ноде.';

  @override
  String get thisChannelExistsOnlyInThe_30433a =>
      'Канал есть только в зеркале — писать в него нельзя.';

  @override
  String get channels_5488bf => 'Каналов';

  @override
  String get channelsWillBeAddedToThe_32e8d4 =>
      'Каналы будут добавлены на ноду.';

  @override
  String get channelsWillBeAddedExistingChannels_dfb994 =>
      'Каналы будут добавлены; существующие каналы и настройки LoRa сохранятся.';

  @override
  String get channelsAndLora_147acf => 'Каналы и LoRa';

  @override
  String get channelsAndLoraSettingsOnThe_31a15a =>
      'Каналы и настройки LoRa на ноде будут заменены.';

  @override
  String get channelsWillAppearAfterConnectingTo_e7a062 =>
      'Каналы появятся после подключения к ноде.';

  @override
  String get channelsSaved_dbb2d3 => 'Каналы сохранены';

  @override
  String get map_5736d0 => 'Карта';

  @override
  String get image_690092 => 'Картинка';

  @override
  String get imageUploadedStoredForDays_144c69 =>
      'Картинка загружена, хранится 3 дня';

  @override
  String get imageUnavailableDeletedOrExpired_82b7c1 =>
      'Картинка недоступна\n(удалена или истёк срок)';

  @override
  String get theImageIsTooLarge_94ad38 => 'Картинка слишком большая';

  @override
  String get imageDeleted_e4b164 => 'Картинка удалена';

  @override
  String get theImageIsAlreadyGone_910faf => 'Картинки уже нет';

  @override
  String get mapsAndUpdateChecks_f48d47 => 'Карты и проверка обновлений';

  @override
  String get keyRestoredSaveTheSettings_92bb30 =>
      'Ключ восстановлен — сохраните настройки';

  @override
  String get theKeyDoesNotMatchThe_4c6326 =>
      'Ключ не соответствует выбранному размеру';

  @override
  String get keyCopied_c184c1 => 'Ключ скопирован';

  @override
  String get theKeyMustBeBytesEncoded_04f2cd => 'Ключ — 32 байта в base64';

  @override
  String get keysAndBackups_9b106e => 'Ключи и резервные копии';

  @override
  String get nodeKeysAndAdminAccess_7b222d => 'Ключи ноды и админ-доступ';

  @override
  String get keysSavedToAFileKeep_32f5b4 =>
      'Ключи сохранены в файл. Храните его в надёжном месте';

  @override
  String get encryptionKeysPsksAndChannelNames_cfa888 =>
      'Ключи шифрования, PSK и названия каналов';

  @override
  String get portrait_79fe4f => 'Книжная';

  @override
  String get portraitReversed_674692 => 'Книжная перевёрнутая';

  @override
  String get hopCount_6d7f43 => 'Количество прыжков';

  @override
  String get chirpsPerSymbolRaisedToThis_f60898 =>
      'Количество чирпов на символ — 2 в степени этого значения.';

  @override
  String get commandSent_d331b9 => 'Команда отправлена';

  @override
  String get contactOptional_309ca4 => 'Контакт (необязательно)';

  @override
  String get pttPin_3c56da => 'Контакт PTT';

  @override
  String get contactImported_0f4d2f => 'Контакт импортирован';

  @override
  String get projectContact_9535fa => 'Контакт проекта';

  @override
  String get mapChecksumMismatch_da850d => 'Контрольная сумма карты не совпала';

  @override
  String get nodeConfigurationsMayContainPrivateKeys_b72311 =>
      'Конфигурация ноды может содержать приватные ключи и пароли. Отдельные резервные копии ключей сохраняются в системном защищённом хранилище; на iOS используется синхронизируемая связка ключей iCloud. Экспортированный JSON содержит незашифрованный приватный ключ. Файл настроек также может содержать ключи и пароли. Выбранное вами место сохранения может быть облачным. Удаляйте экспортированные файлы и резервные копии отдельно, когда они больше не нужны.';

  @override
  String get coordinatesCopied_082ae9 => 'Координаты скопированы';

  @override
  String get coordinatesOfEitherThePhoneOr_6668dd =>
      'Координаты — ни телефона, ни нод';

  @override
  String get copyText_667f44 => 'Копировать текст';

  @override
  String get korea_522d28 => 'Корея';

  @override
  String get yourNodeShortNameInChannel_7ab080 =>
      'Короткое имя своей ноды в тексте канала';

  @override
  String get positionCorrection_e7d3bd => 'Корректировка позиций';

  @override
  String get red_1686b6 => 'Красный';

  @override
  String get mapCache_fc6703 => 'Кэш карты';

  @override
  String get licenses_488dd1 => 'Лицензии';

  @override
  String get directMessages_96a4a7 => 'Личные';

  @override
  String get mhz_b6fe8f => 'МГц';

  @override
  String get m_1ac436 => 'МОм';

  @override
  String get maximumTimeBetweenNodePositionBroadcasts_118530 =>
      'Максимальное время между передачами позиции нодой.';

  @override
  String get malaysiaMhz_8949b1 => 'Малайзия 433 МГц';

  @override
  String get malaysiaMhz_2a5dd6 => 'Малайзия 919 МГц';

  @override
  String get route_b765f3 => 'Маршрут';

  @override
  String get returnRoute_9e78e2 => 'Маршрут обратно';

  @override
  String get minimumTimeBetweenDetectionBroadcasts_e6291c =>
      'Минимальное время между передачами обнаружения';

  @override
  String get minimumTimeBetweenDetectionBroadcasts_ef8eba =>
      'Минимальное время между передачами обнаружения.';

  @override
  String get minimumDistanceForSmartPositionBroadcasting_c4fdb9 =>
      'Минимальное расстояние для умной рассылки координаты.';

  @override
  String get model_f1f1ee => 'Модель';

  @override
  String get deviceModel_6b816f => 'Модель устройства';

  @override
  String get airQualityModuleEnabled_341f24 =>
      'Модуль измерения качества воздуха включен';

  @override
  String get powerMetricsModuleEnabled_74b93b =>
      'Модуль метрик питания включен';

  @override
  String get transmitPower_a90731 => 'Мощность передатчика';

  @override
  String get radioTransmitPowerLeaveZeroTo_bdb039 =>
      'Мощность передачи радио. Оставь ноль, чтобы использовать максимально допустимый уровень для региона — именно так следует поступать большинству радиоустройств.';

  @override
  String get myNode_933f3d => 'Моя нода';

  @override
  String get myLocation_e77573 => 'Моё местоположение';

  @override
  String get myLocationRefresh_d26be2 => 'Моё местоположение (обновить)';

  @override
  String get notSupportedOnIphonesWithFace_7d312d =>
      'На iPhone с Face ID не поддерживается';

  @override
  String get connected_1578f2 => 'На связи';

  @override
  String get name_3de498 => 'Название';

  @override
  String get findNodesOnTheLocalNetwork_9f4117 => 'Найти ноды в локальной сети';

  @override
  String get findNearbyNodes_37deaa => 'Найти ноды поблизости';

  @override
  String get message_bda589 => 'Написать';

  @override
  String get voltage_5b3602 => 'Напр.';

  @override
  String get compassHeading_c9f066 => 'Направление компаса';

  @override
  String get settingsWrittenTheNodeWillRestart_ce3279 =>
      'Настройки записаны, нода перезагрузится';

  @override
  String get applicationSettingsAndRecentConnectionsFor_cab177 =>
      'Настройки приложения и недавние подключения — например, чтобы вернуть их после переустановки. В файле адреса ваших нод и зеркала: никому его не передавайте.';

  @override
  String get settingsSaved_0c3942 => 'Настройки сохранены';

  @override
  String get trafficManagementSettingsInThisApplication_691b03 =>
      'Настройки управления движением в этом приложении — по схеме прошивки 2.8. Обновите прошивку ноды.';

  @override
  String get beginEditing_cfa550 => 'Начало редактирования';

  @override
  String get notEncrypted_c40021 => 'Не зашифровано';

  @override
  String get notFoundAmongNodesOnThe_ec3654 => 'Не найдено среди нод на карте';

  @override
  String get doNotRemindMe_7319fc => 'Не напоминать';

  @override
  String get notSent_304893 => 'Не отправлено';

  @override
  String get couldNotOpenTheDownloadedMap_be745e =>
      'Не удалось открыть скачанную карту.';

  @override
  String get couldNotOpenTheSupportPage_eb8159 =>
      'Не удалось открыть страницу поддержки';

  @override
  String get couldNotRetrieveTheKeyFrom_693021 =>
      'Не удалось получить ключ из зеркала';

  @override
  String get couldNotVerifyTheOfflineMap_f0dd0f =>
      'Не удалось проверить офлайн-карту';

  @override
  String get couldNotReadChannelData_1a56bc =>
      'Не удалось прочитать данные каналов';

  @override
  String get couldNotReadMapSettings_9d3bfa =>
      'Не удалось прочитать настройки карты';

  @override
  String get couldNotDownloadTheMapCheck_07b3ae =>
      'Не удалось скачать карту. Проверьте сеть и повторите.';

  @override
  String get noMoreOftenThanEvery_3389cd => 'Не чаще чем раз в';

  @override
  String get incorrectDeviceTime_bcddb3 => 'Неверное время на устройстве';

  @override
  String get invalidRegularExpression_d0b364 => 'Неверное регулярное выражение';

  @override
  String get invalidChannelDataInTheLink_d0da40 =>
      'Неверные данные каналов в ссылке';

  @override
  String get invalidAddress_e5fb1c => 'Неверный адрес';

  @override
  String get invalidIpvAddress_c9875b => 'Неверный адрес IPv4';

  @override
  String get recent_1328d8 => 'Недавние';

  @override
  String get nepalMhz_73462a => 'Непал 865 МГц';

  @override
  String get locationAccessDeniedAllowItIn_fa90c3 =>
      'Нет доступа к геолокации — разрешите в настройках системы';

  @override
  String get noMeasurementsForThisPeriod_c02810 => 'Нет замеров за этот период';

  @override
  String get noNodeKeyConnectToYour_7e5d9a =>
      'Нет ключа ноды — подключитесь к своей ноде';

  @override
  String get noKeyNotEncrypted_1c5fa9 => 'Нет ключа — не зашифровано';

  @override
  String get noNodesWithCoordinatesThisIs_34558f =>
      'Нет нод с координатами.\nЭто нормально: начиная с прошивки 2.8 отправка позиции по умолчанию выключена.';

  @override
  String get noAcknowledgment_f9cd9b => 'Нет подтверждения';

  @override
  String get noPublicKey_fc72da => 'Нет публичного ключа';

  @override
  String get noNodePublicKeyWaitFor_f9fbc4 =>
      'Нет публичного ключа ноды — дождитесь NodeInfo или повторите загрузку из зеркала в карточке ноды.';

  @override
  String get noNodeConnection_8ce75b => 'Нет соединения с нодой';

  @override
  String get noDatabaseFile_c7a185 => 'Нет файла базы';

  @override
  String get noneOfTheNodesOnThis_79590a =>
      'Ни у одной ноды маршрута нет координат';

  @override
  String get never_f5bf59 => 'Никогда';

  @override
  String get specializedDevice_be7b26 => 'Нишевое устройство';

  @override
  String get newZealandMhz_66ff01 => 'Новая Зеландия 865 МГц';

  @override
  String get newMessages_f8bbc3 => 'Новые сообщения';

  @override
  String get nodesInDatabase_b7f028 => 'Нод в базе';

  @override
  String get nodesOnRadio_f76516 => 'Нод в эфире';

  @override
  String get noNodesYetConnectToYour_c2e63b =>
      'Нод пока нет.\nПодключитесь к своей ноде.';

  @override
  String get nodeNoLongerIgnored_c2b973 => 'Нода больше не игнорируется';

  @override
  String get theNodeWillBeRemovedFrom_e0fd0d =>
      'Нода будет удалена из базы своей ноды. Она снова появится, когда её услышат.';

  @override
  String get theNodeWillBeRemovedFrom_0c5eb5 =>
      'Нода будет удалена из приложения. Она снова появится, когда её услышат.';

  @override
  String get theNodeHasNotBroadcastIts_198664 =>
      'Нода ещё не передала свои данные в сеть — подождите и попробуйте позже';

  @override
  String get theNodeHasNotSentIts_58663f =>
      'Нода ещё не прислала свои данные — подождите окончания загрузки.';

  @override
  String get theNodeHasNotSentThese_0e8dcb =>
      'Нода ещё не прислала эти настройки';

  @override
  String get nodeIgnored_cdfc8a => 'Нода игнорируется';

  @override
  String get theNodeUsesARegionUnsupported_213978 =>
      'Нода использует регион, который приложение не поддерживает. Выберите поддерживаемый регион перед сохранением.';

  @override
  String get nodeNotFound_9951e4 => 'Нода не найдена';

  @override
  String get notAcknowledgedByTheNode_90929d => 'Нода не подтвердила';

  @override
  String get theNodeDidNotAcknowledgeImporting_65bf83 =>
      'Нода не подтвердила импорт ключа получателя';

  @override
  String get theNodeDidNotAcknowledgeThe_e56f57 =>
      'Нода не подтвердила команду';

  @override
  String get theNodeDidNotAcknowledgeSaving_e14f06 =>
      'Нода не подтвердила сохранение';

  @override
  String get thisNodeDoesNotAcceptDirect_338e6e =>
      'Нода не принимает личные сообщения.';

  @override
  String get theNodeWillRespondWithIts_ab01ac =>
      'Нода ответит текущими значениями';

  @override
  String get theNodeIsRestartingItsName_f432c3 =>
      'Нода перезагружается. После подключения имя вернётся само.';

  @override
  String get theNodeWillClearItsSaved_7eed33 =>
      'Нода сбросит сохранённое состояние и перезагрузится. Ключ шифрования и настройки останутся.';

  @override
  String get theNodeSavedAZeroMac_630708 =>
      'Нода сохранила у себя нулевой MAC-адрес — из-за ошибки кнопки «Отправить NodeInfo» в Meshex 0.1.7–0.1.10. ID на этой прошивке считается из ключа и не сменится, но MAC стоит вернуть.\n\nИсправление отправит ноде её настоящий MAC. Перезагрузка не нужна, ничего не потеряется.';

  @override
  String get nodeDeleted_bd0760 => 'Нода удалена';

  @override
  String get number_1bb3d1 => 'Номер';

  @override
  String get reportNumber_a2f60b => 'Номер отчёта';

  @override
  String get numberCopied_875e81 => 'Номер скопирован';

  @override
  String get twoNodeDatabasesAreRequired_0e6b9d => 'Нужны базы двух нод';

  @override
  String get exchangeNodeinfo_e2f5f6 => 'Обменяться NodeInfo';

  @override
  String get colorPreview_dfa12d => 'Образец цвета';

  @override
  String get mentionsAndReplies_209ee7 => 'Обращения ко мне';

  @override
  String get maintenance_3c5bdd => 'Обслуживание';

  @override
  String get waiting_5813a9 => 'Ожидание';

  @override
  String get window_f5988f => 'Окно';

  @override
  String get optimizedForAtakCommunicationReducesRoutine_27d642 =>
      'Оптимизировано для связи с системой ATAK, сокращает текущие передачи.';

  @override
  String get orange_6494ce => 'Оранжевый';

  @override
  String get screenOrientation_87b383 => 'Ориентация экрана';

  @override
  String get fromMyNode_336438 => 'От своей ноды';

  @override
  String get replyToMessage_4e6ac3 => 'Ответ на сообщение';

  @override
  String get repliesAndMentions_f0aae9 => 'Ответы и упоминания';

  @override
  String get repliesToMyMessages_2fca62 => 'Ответы на мои сообщения';

  @override
  String get responsesToOutgoingTraceroutes_dea22a =>
      'Ответы на отправленные трассировки.';

  @override
  String get repliesToYourMessagesAndMentions_953527 =>
      'Ответы на твои сообщения и упоминания в каналах.';

  @override
  String get zoomOut_fea897 => 'Отдалить';

  @override
  String get disablesTheUserButtonTripleClick_9664f8 =>
      'Отключает горячую клавишу тройного нажатия пользовательской кнопки.';

  @override
  String get disconnect_94d07a => 'Отключить';

  @override
  String get disableTripleClickShortcut_0ac4dd =>
      'Отключить тройное нажатие кнопки';

  @override
  String get cannotDeleteTheCurrentlyOpenDatabase_023546 =>
      'Открытую базу удалить нельзя';

  @override
  String get open_125957 => 'Открыть';

  @override
  String get openInMaps_6bb0f2 => 'Открыть в Картах';

  @override
  String get openGithubSupport_603c75 => 'Открыть поддержку на GitHub';

  @override
  String get cancelDownload_136bdc => 'Отменить загрузку';

  @override
  String get sender_522b04 => 'Отправитель';

  @override
  String get sendNodeinfo_79376f => 'Отправить Nodeinfo';

  @override
  String get sendToServices_7ae0e3 => 'Отправить в Services';

  @override
  String get sendAgain_625609 => 'Отправить ещё раз';

  @override
  String get sendReport_63b6fb => 'Отправить отчёт';

  @override
  String get sendReportToTheDeveloper_d46fe6 => 'Отправить отчёт разработчику';

  @override
  String get sendAPingToServices_afe5a4 => 'Отправить пинг в Services?';

  @override
  String get sendPosition_1a3631 => 'Отправить позицию';

  @override
  String get sentOverTheAir_740ec0 => 'Отправлено в эфир';

  @override
  String get sending_5f0935 => 'Отправляется';

  @override
  String get forwardEncryptedPacketsToMqtt_53e004 =>
      'Отправлять зашифрованные пакеты в MQTT';

  @override
  String get scanInMeshtasticToAddThis_e46939 =>
      'Отсканируйте в Meshtastic, чтобы добавить контакт';

  @override
  String get reportSent_4eb02c => 'Отчёт отправлен';

  @override
  String get reportsAreSentAtYourRequest_7fcca2 =>
      'Отчёт отправляется по вашему действию сервису, объявленному подключённым зеркалом. Перед отправкой можно посмотреть состав отчёта и журнал. Отчёт включает сведения о приложении, системе, ноде и соединении, а также ваш комментарий и контакт, если вы их указали. Не включайте секреты и личные сведения в комментарий. Для удаления отправленного отчёта обратитесь к оператору сервиса и укажите номер отчёта.';

  @override
  String get reportsAreSentThroughTheConnected_ceda96 =>
      'Отчёты отправляются через подключённый сервер, а он их не принимает или не подключён.';

  @override
  String get offlineOpenstreetmapContributors_76e794 =>
      'Офлайн · © OpenStreetMap contributors';

  @override
  String get offlineMap_c6b2c6 => 'Офлайн-карта';

  @override
  String get offlineMapAboutKmMbData_433acc =>
      'Офлайн-карта · около 100 км · 194 МБ\nДанные от 29.10.2026';

  @override
  String get offlineMapEnabled_4908b7 => 'Офлайн-карта включена';

  @override
  String get offlineMap_7c2718 => 'Офлайн-карта…';

  @override
  String get appearance_d206f1 => 'Оформление';

  @override
  String get packetsReceived_83d955 => 'Пакетов получено';

  @override
  String get sharePositionWithMyNode_acf46e => 'Передавать позицию своей ноде';

  @override
  String get broadcastOverLora_d52575 => 'Передать через LoRa';

  @override
  String get restarts_05fe86 => 'Перезагрузок';

  @override
  String get transfer_081b1d => 'Перенести';

  @override
  String get transferToTheOpenDatabase_8042a9 => 'Перенести в открытую базу';

  @override
  String get transferMessages_f1f159 => 'Перенести сообщения?';

  @override
  String get overrideDutyCycle_e5b06b => 'Переопределить рабочий цикл';

  @override
  String get reconnect_91c240 => 'Переподключить';

  @override
  String get regenerate_9bf881 => 'Пересоздать';

  @override
  String get dragTheMarkerOrEnterCoordinates_1127fb =>
      'Перетащите метку или введите координаты';

  @override
  String get broadcastInterval_5acd28 => 'Период рассылки';

  @override
  String get saintPetersburgAndSurroundings_6bc6a9 => 'Петербург и окрестности';

  @override
  String get platform_89009f => 'Платформа';

  @override
  String get followApplicationTheme_6d6cea => 'По теме приложения';

  @override
  String m_a6990d(String arg0) {
    return '$arg0 м';
  }

  @override
  String km_f1c739(String arg0) {
    return '$arg0 км';
  }

  @override
  String trayUnavailable_046650(String arg0) {
    return 'Трей недоступен: $arg0';
  }

  @override
  String tray_2a443c(String arg0) {
    return 'Трей: $arg0';
  }

  @override
  String imageExceedsMb_0b3767(String arg0) {
    return 'Картинка больше $arg0 МБ';
  }

  @override
  String mirror_871d44(String arg0) {
    return 'Зеркало: $arg0';
  }

  @override
  String nodeDatabases_f031cb(String arg0) {
    return 'Базы нод: $arg0';
  }

  @override
  String nodeDatabase_bed412(String arg0) {
    return 'База ноды $arg0';
  }

  @override
  String deletingDatabase_41e9b6(String arg0, String arg1) {
    return 'Удаление базы $arg0: $arg1';
  }

  @override
  String autoConnect_4cc7c7(String arg0) {
    return 'Автоподключение: $arg0';
  }

  @override
  String notification_7dcfc3(String arg0) {
    return 'Уведомление: $arg0';
  }

  @override
  String notificationsNotStarted_e0104d(String arg0) {
    return 'Уведомления не запущены: $arg0';
  }

  @override
  String couldNotCollectReport_f860a7(String arg0) {
    return 'не удалось собрать отчёт: $arg0';
  }

  @override
  String inChannelMessages_74052f(String arg0) {
    return '«$arg0» в тексте канала';
  }

  @override
  String min_c284de(String arg0) {
    return '$arg0 мин';
  }

  @override
  String sent_c9f056(String arg0) {
    return 'Передано $arg0';
  }

  @override
  String error_8f7267(String arg0) {
    return 'Ошибка: $arg0';
  }

  @override
  String viewedTilesAreAvailableOfflineUsing_f4b74a(String arg0, String arg1) {
    return 'Просмотренные тайлы, работают без сети. Занято $arg0 из $arg1.';
  }

  @override
  String couldNotReadOwnNode_d29415(String arg0) {
    return 'Ошибка чтения своей ноды: $arg0';
  }

  @override
  String couldNotReadFirmwareDetails_b21e3e(String arg0) {
    return 'Ошибка чтения данных прошивки: $arg0';
  }

  @override
  String ownNodeHasNotLoadedYet_0d7292(String arg0) {
    return 'Своя нода $arg0 ещё не загружена';
  }

  @override
  String deleteChannel_8f1495(String arg0) {
    return 'Удалить канал «$arg0»?';
  }

  @override
  String channel_024ea4(String arg0) {
    return 'Канал $arg0';
  }

  @override
  String couldNotSave_6886a1(String arg0) {
    return 'Не удалось сохранить: $arg0';
  }

  @override
  String backup_5f3ad8(String arg0, String arg1) {
    return '$arg0, резервное копирование $arg1';
  }

  @override
  String couldNotReadFile_425230(String arg0) {
    return 'Не удалось прочитать файл: $arg0';
  }

  @override
  String keySelectedSaveTheSettingsOnly_f2a281(String arg0) {
    return 'Ключ $arg0 подставлен — сохраните настройки. Ставьте ключ только на ту ноду, с которой он снят';
  }

  @override
  String couldNotReadConfiguration_7e6b38(String arg0) {
    return 'Ошибка чтения конфигурации: $arg0';
  }

  @override
  String theNodeSavedAZeroMac_88c735(String arg0, String arg1) {
    return 'Нода сохранила у себя нулевой MAC-адрес — из-за ошибки кнопки «Отправить NodeInfo» в Meshex 0.1.7–0.1.10. Пока нода не перезагружалась, её ID прежний ($arg0). При следующей перезагрузке ID сменится на случайный: другие увидят её как новую ноду, переписка и избранное у них разделятся.\n\n$arg1';
  }

  @override
  String theNodeIdChangedFromTo_ca53f7(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'ID ноды сменился с $arg0 на $arg1 — из-за ошибки кнопки «Отправить NodeInfo» в Meshex 0.1.7–0.1.10.\n\nИсправление вернёт $arg2, ключ шифрования сохранится. Нода перезагрузится, имя приложение вернёт само. Список нод, избранное и игнор останутся. У других пользователей $arg3 какое-то время будет видна отдельной нодой.';
  }

  @override
  String nodeId_12da33(String arg0, String arg1) {
    return 'ID ноды: $arg0.\n\n$arg1';
  }

  @override
  String failed_317897(String arg0) {
    return 'Не удалось: $arg0';
  }

  @override
  String toBrokerToNodeDropped_856a68(String arg0, String arg1, String arg2) {
    return 'В брокер: $arg0 · в ноду: $arg1 · отброшено: $arg2';
  }

  @override
  String couldNotOpenFile_7fa8ac(String arg0) {
    return 'Не удалось открыть файл: $arg0';
  }

  @override
  String mainSettingsWrittenNotWrittenNode_5d2582(String arg0) {
    return 'Основное записано. Не записано (нода перезагрузилась): $arg0 — задайте вручную';
  }

  @override
  String stoppedAt_546fe2(String arg0, String arg1) {
    return 'Остановлено на «$arg0»$arg1';
  }

  @override
  String writtenLastTheNodeWillThen_35a22d(String arg0) {
    return 'Последними записываются: $arg0. После них нода перезагрузится, связь ненадолго прервётся.';
  }

  @override
  String skipped_29ab80(String arg0) {
    return 'Пропущено: $arg0';
  }

  @override
  String open_0cdbe8(String arg0) {
    return 'Открыта · $arg0';
  }

  @override
  String couldNotRead_35e132(String arg0) {
    return 'Не удалось прочитать: $arg0';
  }

  @override
  String kb_c723dd(String arg0) {
    return '$arg0 КБ';
  }

  @override
  String mb_d67a20(String arg0) {
    return '$arg0 МБ';
  }

  @override
  String messagesFromDatabaseWillBeAdded_47ae75(String arg0, String arg1) {
    return 'Сообщения из базы $arg0 будут добавлены в открытую базу, старый номер своей ноды заменится текущим. Старая база останется — её можно удалить потом.$arg1';
  }

  @override
  String messagesTransferred_4a0c59(String arg0) {
    return 'Перенесено сообщений: $arg0';
  }

  @override
  String couldNotTransfer_613ff4(String arg0) {
    return 'Не удалось перенести: $arg0';
  }

  @override
  String settingsLoaded_66f8ee(String arg0) {
    return 'Настройки загружены ($arg0)';
  }

  @override
  String couldNotLoad_9d91fc(String arg0) {
    return 'Не удалось загрузить: $arg0';
  }

  @override
  String thisNodeDatabaseChannelsAndMessages_6599da(String arg0) {
    return '$arg0: ноды, каналы и сообщения этой ноды будут удалены с устройства. Сама нода не изменится.';
  }

  @override
  String couldNotDelete_bacd63(String arg0) {
    return 'Не удалось удалить: $arg0';
  }

  @override
  String databaseForNodeAlreadyExistsReplace_d59789(String arg0) {
    return 'База ноды $arg0 уже есть. Заменить её данными из файла?';
  }

  @override
  String databaseForNodeLoadedItWill_8f5c23(String arg0) {
    return 'База ноды $arg0 загружена — откроется при подключении к этой ноде';
  }

  @override
  String afterDays_00b005(String arg0) {
    return 'Через $arg0 дн.';
  }

  @override
  String currentDatabasesTheLeastRecentlyUsed_0fb1b8(String arg0, String arg1) {
    return 'Сейчас баз: $arg0. Самые давно не использованные ($arg1) удалятся вместе с перепиской.';
  }

  @override
  String application_7574f7(String arg0) {
    return 'Приложение › $arg0';
  }

  @override
  String radius_02211c(String arg0, String arg1) {
    return '$arg0 · радиус $arg1';
  }

  @override
  String mirrorRespondingNodes_d2a09d(String arg0) {
    return 'Зеркало отвечает, нод: $arg0';
  }

  @override
  String willUse_0a9e87(String arg0) {
    return 'Будет использован: $arg0';
  }

  @override
  String disconnectedRetryingInS_c55f01(String arg0) {
    return 'Нет связи, повтор через $arg0 с';
  }

  @override
  String versionReleased_3afe40(String arg0) {
    return 'Вышла версия $arg0';
  }

  @override
  String version_450a87(String arg0) {
    return 'Версия $arg0';
  }

  @override
  String versionAvailableTapToDownload_af3a75(String arg0) {
    return 'Доступна версия $arg0 — нажмите, чтобы скачать';
  }

  @override
  String couldNotCheck_d7d26b(String arg0) {
    return 'Не удалось проверить: $arg0';
  }

  @override
  String historyNotLoaded_652fe3(String arg0) {
    return 'История не загружена: $arg0';
  }

  @override
  String pingsAreUsuallySentToThe_159914(String arg0) {
    return 'Пинги принято отправлять в сервисный канал, там отвечают боты.$arg0';
  }

  @override
  String notSent_04b25a(String arg0) {
    return 'Не отправлено: $arg0';
  }

  @override
  String hops_3baa0e(String arg0) {
    return 'Хопов: $arg0';
  }

  @override
  String hideFilteredMessages_3a8226(String arg0) {
    return 'Скрыть $arg0 отфильтрованных';
  }

  @override
  String showFilteredMessages_0be3c1(String arg0) {
    return 'Показать $arg0 отфильтрованных';
  }

  @override
  String gatewaysShowOnMap_6e8104(String arg0) {
    return 'Шлюзы: $arg0. Показать на карте';
  }

  @override
  String sentOf_167cc7(String arg0, String arg1) {
    return 'Отправлено $arg0 из $arg1';
  }

  @override
  String tooLongMoreThanMessages_f438b3(String arg0) {
    return 'Слишком длинно: больше $arg0 сообщений';
  }

  @override
  String bytesWillSendAsMessages_e34c7b(String arg0, String arg1) {
    return '$arg0 байт · уйдёт $arg1 сообщениями';
  }

  @override
  String channel_6a801e(String arg0) {
    return 'канал $arg0';
  }

  @override
  String hideChannel_3f4e20(String arg0) {
    return 'Скрыть канал «$arg0»?';
  }

  @override
  String deleteConversationWith_7b6ba5(String arg0) {
    return 'Удалить переписку с «$arg0»?';
  }

  @override
  String showWhoReacted_154369(String arg0, String arg1) {
    return '$arg0: $arg1. Показать, кто поставил';
  }

  @override
  String theReportWillBeSentTo_360707(String arg0) {
    return 'Жалоба уйдёт оператору сервера ($arg0)';
  }

  @override
  String scan_603ff2(String arg0) {
    return 'Сканирование: $arg0';
  }

  @override
  String networkSearch_a3c1c6(String arg0) {
    return 'Поиск в сети: $arg0';
  }

  @override
  String ports_1b477b(String arg0) {
    return 'Порты: $arg0';
  }

  @override
  String ports_50f8c3(String arg0) {
    return 'Портов: $arg0';
  }

  @override
  String log_b9a4c8(String arg0) {
    return 'Журнал · $arg0';
  }

  @override
  String db_112739(String arg0) {
    return '$arg0 дБ';
  }

  @override
  String skipped_5dec4c(String arg0) {
    return 'пропущено $arg0';
  }

  @override
  String nodes_3af8d3(String arg0) {
    return 'Ноды$arg0';
  }

  @override
  String minAgo_d8d327(String arg0) {
    return '$arg0 мин назад';
  }

  @override
  String hAgo_9ef360(String arg0) {
    return '$arg0 ч назад';
  }

  @override
  String dAgo_1ab28d(String arg0) {
    return '$arg0 д назад';
  }

  @override
  String cameraUnavailable_6012f0(String arg0) {
    return 'Камера недоступна: $arg0';
  }

  @override
  String hops_d23d4f(String arg0) {
    return 'хопов: $arg0';
  }

  @override
  String db_660739(String arg0, String arg1) {
    return '$arg0 дБ, $arg1';
  }

  @override
  String dbm_aadd53(String arg0) {
    return '$arg0 дБм';
  }

  @override
  String v_7e1412(String arg0) {
    return '$arg0 В';
  }

  @override
  String altitudeM_dd3a3e(String arg0) {
    return 'высота $arg0 м';
  }

  @override
  String nodesAtThisLocation_39f71d(String arg0) {
    return 'Ноды в этом месте: $arg0';
  }

  @override
  String map_d56e1b(String arg0) {
    return 'Карта$arg0';
  }

  @override
  String search_b34b80(String arg0) {
    return 'Поиск: $arg0';
  }

  @override
  String couldNotDetermineLocation_e5f6db(String arg0) {
    return 'Не удалось определить местоположение: $arg0';
  }

  @override
  String downloadedOfMb_945586(String arg0) {
    return 'Скачано $arg0 из 194 МБ';
  }

  @override
  String linesKb_94885c(String arg0, String arg1) {
    return '$arg0 строк, $arg1 КБ';
  }

  @override
  String databasesMoved_c705c3(String arg0) {
    return 'Базы перенесены: $arg0';
  }

  @override
  String movingDatabases_08b6c6(String arg0) {
    return 'Перенос баз: $arg0';
  }

  @override
  String linuxShortcut_e8cde8(String arg0) {
    return 'Ярлык Linux: $arg0';
  }

  @override
  String restoringAttempt_111048(String arg0, String arg1) {
    return 'Восстановление (попытка $arg0) — $arg1';
  }

  @override
  String disabled_7e8add(String arg0) {
    return 'Отключено — $arg0';
  }

  @override
  String mqttProxyConnectingTo_76c8be(String arg0, String arg1) {
    return 'MQTT-прокси: подключение к $arg0 (#$arg1)';
  }

  @override
  String mqttProxyConnectedTopics_155375(String arg0) {
    return 'MQTT-прокси: подключено, темы: $arg0';
  }

  @override
  String mqttProxy_ae0acc(String arg0) {
    return 'MQTT-прокси: $arg0';
  }

  @override
  String mqttProxyFailure_e15119(String arg0) {
    return 'Сбой MQTT-прокси: $arg0';
  }

  @override
  String mqttProxyNotSentToNode_d164ca(String arg0) {
    return 'MQTT-прокси: в ноду не ушло: $arg0';
  }

  @override
  String defaultPreset_3eeaf1(String arg0) {
    return 'Пресет по умолчанию (4/$arg0)';
  }

  @override
  String unknown_bf9aae(String arg0) {
    return 'Неизвестный ($arg0)';
  }

  @override
  String unsupportedKhz_f4a35a(String arg0) {
    return 'Неподдерживаемый ($arg0 кГц)';
  }

  @override
  String noLongerThan_85eae1(String arg0, String arg1) {
    return 'Не длиннее $arg0 $arg1';
  }

  @override
  String ms_f929ee(String arg0) {
    return '$arg0 мс';
  }

  @override
  String optionalFieldsInPositionMessagesMore_544075(String arg0) {
    return 'Необязательные поля в сообщении о местоположении. Чем больше полей включено, тем больше сообщение, а значит больше время передачи и риск потери пакетов.\n$arg0';
  }

  @override
  String owner_a19d69(String arg0) {
    return 'Владелец: $arg0';
  }

  @override
  String channelsAndLora_f47f79(String arg0) {
    return 'Каналы ($arg0) и LoRa';
  }

  @override
  String yourRegionHasADutyCycle_8bba9b(String arg0) {
    return 'В вашем регионе действует режим работы $arg0%. Не рекомендуется использовать MQTT, если у вас ограничен режим работы, так как дополнительный трафик быстро перегрузит вашу сеть LoRa.';
  }

  @override
  String withinKm_810838(String arg0) {
    return 'В пределах $arg0 км';
  }

  @override
  String withinM_4c9617(String arg0) {
    return 'В пределах $arg0 м';
  }

  @override
  String aChannelNamedAlreadyExistsOn_f690d9(String arg0) {
    return 'На ноде уже есть канал «$arg0»';
  }

  @override
  String notEnoughFreeSlotsNeedAvailable_ebb9b1(String arg0, String arg1) {
    return 'Не хватает свободных слотов: нужно $arg0, свободно $arg1';
  }

  @override
  String s_b1049d(String arg0) {
    return '$arg0 с';
  }

  @override
  String nodeError_1c86cd(String arg0) {
    return 'Ошибка ноды: $arg0';
  }

  @override
  String bits_1c3c42(String arg0) {
    return '$arg0 бит';
  }

  @override
  String bytes_b92ed8(String arg0) {
    return '$arg0 байт';
  }

  @override
  String to_525c23(String arg0, String arg1) {
    return '$arg0 к «$arg1»';
  }

  @override
  String reply_9b21d8(String arg0) {
    return '$arg0 · ответ';
  }

  @override
  String traceroute_bf254b(String arg0) {
    return 'Трассировка маршрута: $arg0';
  }

  @override
  String outbound_0eb5b8(String arg0) {
    return 'туда $arg0';
  }

  @override
  String return_c58db8(String arg0) {
    return 'обратно $arg0';
  }

  @override
  String serverResponded_01d198(String arg0) {
    return 'сервер ответил $arg0';
  }

  @override
  String lastPositionOutsideTheInterferenceZone_f954f0(String arg0) {
    return 'последняя точка вне зоны глушилки, $arg0';
  }

  @override
  String precisionKm_52aa61(String arg0) {
    return 'точность ~$arg0 км';
  }

  @override
  String precisionM_0e4845(String arg0) {
    return 'точность ~$arg0 м';
  }

  @override
  String theMacAddressIsCorrectFirmware_79bf7b(String arg0) {
    return 'MAC-адрес в порядке. Прошивка $arg0 считает ID из ключа шифрования — исправлять нечего.';
  }

  @override
  String dH_0efa0f(String arg0, String arg1) {
    return '$arg0 д $arg1 ч';
  }

  @override
  String hMin_ace139(String arg0, String arg1) {
    return '$arg0 ч $arg1 мин';
  }

  @override
  String longerThanBytes_0b6b95(String arg0) {
    return 'длиннее $arg0 байт';
  }

  @override
  String topMostTalkativeOverDays_f8e44b(String arg0, String arg1) {
    return 'Топ-$arg0 болтливых за $arg1 дн.';
  }

  @override
  String serverDidNotRespondWithinS_d4984e(String arg0) {
    return 'сервер не ответил за $arg0 с';
  }

  @override
  String noConnectionToServer_c97c08(String arg0) {
    return 'нет связи с сервером: $arg0';
  }

  @override
  String serverRespondedTo_546208(String arg0, String arg1) {
    return 'сервер ответил $arg0 на /$arg1';
  }

  @override
  String mirrorErrorProcessing_150c37(String arg0, String arg1) {
    return 'Зеркало: ошибка обработки $arg0: $arg1';
  }

  @override
  String mirrorConnectionClosed_fb5059(String arg0) {
    return 'Зеркало: соединение закрыто$arg0';
  }

  @override
  String get compassTitle => 'Компас';

  @override
  String get compassNoSensor =>
      'Это устройство не оснащено датчиком компаса. Курс недоступен.';

  @override
  String get compassNoPermission =>
      'Для отображения расстояния и азимута требуется разрешение на определение местоположения.';

  @override
  String get compassLocationOff =>
      'Геолокация выключена. Включите службы определения местоположения.';

  @override
  String get compassWaitingGps =>
      'Ждём сигнала GPS, чтобы рассчитать расстояние и азимут.';

  @override
  String get compassWaitingHeading =>
      'Ждём истинный курс компаса. Держите телефон горизонтально.';

  @override
  String get compassCalibration =>
      'Компас неточен. Отойдите от магнитов и поверните телефон восьмёркой.';

  @override
  String get compassSensorError => 'Не удалось получить данные компаса.';

  @override
  String get compassLocationError => 'Не удалось получить координаты телефона.';

  @override
  String get compassNoTarget => 'У ноды нет координат.';

  @override
  String get compassTargetMissing => 'Нода не найдена.';

  @override
  String compassDistance(String value) {
    return 'Расстояние: $value';
  }

  @override
  String compassBearing(String value) {
    return 'Азимут: $value';
  }

  @override
  String compassAccuracy(String value) {
    return 'Точность позиции: ±$value';
  }

  @override
  String get compassAccuracyUnknown => 'Точность позиции ноды неизвестна';

  @override
  String compassUpdated(String value) {
    return 'Последнее обновление позиции: $value';
  }

  @override
  String get compassUnknownTime => 'Время позиции неизвестно';

  @override
  String get compassOpenSettings => 'Открыть настройки';

  @override
  String get compassAllowLocation => 'Разрешить геолокацию';

  @override
  String get compassRetry => 'Повторить';

  @override
  String compassPhoneAccuracy(String value) {
    return 'Точность GPS телефона: ±$value';
  }

  @override
  String get compassTargetCorrected =>
      'Координаты ноды скорректированы зеркалом';

  @override
  String get compassTargetSpoofed => 'Координаты ноды могут быть подменены';

  @override
  String get compassTrueNorth => 'Направление относительно истинного севера';

  @override
  String compassArrowLabel(String value) {
    return 'Направление к ноде: $value';
  }

  @override
  String compassPositionAge(String value) {
    return ' $value назад';
  }

  @override
  String get compassCoincident => 'Вы в пределах точности позиции ноды';

  @override
  String get compassExchangePosition => 'Обменяться позицией';

  @override
  String get youPrefix => 'Вы: ';

  @override
  String notificationReplyTitle(String value) {
    return '$value · ответ';
  }

  @override
  String notificationReactionBody(String reaction, String target) {
    return '$reaction к «$target»';
  }

  @override
  String notificationTraceTitle(String value) {
    return 'Трассировка маршрута: $value';
  }

  @override
  String get cardinalNorth => 'С';

  @override
  String get cardinalNorthEast => 'СВ';

  @override
  String get cardinalEast => 'В';

  @override
  String get cardinalSouthEast => 'ЮВ';

  @override
  String get cardinalSouth => 'Ю';

  @override
  String get cardinalSouthWest => 'ЮЗ';

  @override
  String get cardinalWest => 'З';

  @override
  String get cardinalNorthWest => 'СЗ';

  @override
  String get trayShow => 'Показать';

  @override
  String get trayQuit => 'Выход';

  @override
  String get systemDefaultRussianOrEnglish_f182fd =>
      'Как в системе, русский или английский';

  @override
  String get mainSettingsSaved_00e02d => ' (основное сохранено)';

  @override
  String get warningTheOwnNodeKeysDiffer_aed068 =>
      '\n\nВнимание: ключ своей ноды в этих базах разный — похоже, это другая нода.';

  @override
  String get theOwnNodeKeyIsUnknown_ccc9d8 =>
      '\n\nКлюч своей ноды неизвестен — проверить, что это та же нода, нельзя.';

  @override
  String get theNodeHasNoServicesChannel_ab2d98 =>
      '\n\nКанала Services на ноде нет — добавьте его в настройках каналов.';

  @override
  String get bytes_e0d1c3 => 'байт';

  @override
  String get characters_7fbc31 => 'символов';

  @override
  String get hour_1e0e6a => 'час';

  @override
  String get hours_4e4e58 => 'часа';

  @override
  String get hours_217fae => 'часов';

  @override
  String get minute_28716b => 'минута';

  @override
  String get minutes_caa635 => 'минуты';

  @override
  String get minutes_333ed1 => 'минут';

  @override
  String get second_5dbcff => 'секунда';

  @override
  String get seconds_86ee6d => 'секунды';

  @override
  String get seconds_2c2499 => 'секунд';

  @override
  String get theRepairSendsTheCorrectMac_7391e0 =>
      'Исправление отправит ноде её настоящий MAC. Перезагрузка не нужна, ничего не потеряется.';

  @override
  String get neitherTheApplicationNorTheMirror_04717d =>
      'Настоящий MAC этой ноды неизвестен ни приложению, ни зеркалу. Перезагрузите ноду: если ID сменится, вернитесь сюда — исправление вернёт прежний ID, ничего не потеряется.';

  @override
  String bluetoothDidNotCompleteTheOperation_65145b(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'Bluetooth не завершил операцию. Если на ноде включён PIN, возможно, нужно завершить сопряжение в Linux. Отключите автоподключение и нажмите «Отключить», затем выполните в терминале:\n\nbluetoothctl\nremove $arg0\nagent KeyboardOnly\ndefault-agent\npair $arg1\ntrust $arg2\ndisconnect $arg3\nquit\n\nПри запросе введите PIN ноды. Команда remove удаляет прежнее сопряжение. После успешного pair подключитесь снова в приложении. Если сопряжение уже выполнено, проверьте питание и доступность ноды.';
  }

  @override
  String of_b319e7(String arg0, String arg1) {
    return ' ($arg0 из $arg1)';
  }
}
