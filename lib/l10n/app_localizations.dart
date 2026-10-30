import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ru'),
    Locale('en'),
  ];

  /// No description provided for @language.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language;

  /// No description provided for @systemLanguage.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе'**
  String get systemLanguage;

  /// No description provided for @russian.
  ///
  /// In ru, this message translates to:
  /// **'Русский'**
  String get russian;

  /// No description provided for @english.
  ///
  /// In ru, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @languageHelp.
  ///
  /// In ru, this message translates to:
  /// **'Язык интерфейса приложения'**
  String get languageHelp;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'12-часовой формат'**
  String get hourClock_55c2f5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'1Ч'**
  String get h_d3db2b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'GPIO зуммер'**
  String get buzzerGpio_fff3f4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'GPIO кнопки'**
  String get buttonGpio_845326;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'GPIO передачи GPS'**
  String get gpsTransmitGpio_e4dc9e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'GPIO приема GPS'**
  String get gpsReceiveGpio_402339;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'I2C-адрес INA_2XX батареи'**
  String get batteryInaXxICAddress_3b2fa6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'ID ноды'**
  String get nodeId_021568;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'IP-адрес'**
  String get ip_42788e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MQTT Downlink включён'**
  String get mqttDownlinkEnabled_990d36;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MQTT Uplink включён'**
  String get mqttUplinkEnabled_9d43a7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MQTT клиент-прокси'**
  String get mqttClientProxy_aa711a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MQTT: соединение отклонено (проверьте учетные данные)'**
  String get mqttConnectionRejectedCheckCredentials_5ddde1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MQTT: соединение потеряно'**
  String get mqttConnectionLost_681220;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'TLS включен'**
  String get tlsEnabled_df2997;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'URL канала'**
  String get channelUrl_8b64fd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Авто'**
  String get auto_569533;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Администрирование'**
  String get administration_d838aa;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Адрес'**
  String get address_8db46e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Активно'**
  String get active_76ddd7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Аптайм'**
  String get uptime_d0d899;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Батарея'**
  String get battery_96a4c3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Безопасность'**
  String get security_d4fab1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Бод'**
  String get baud_cd221c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ваша нода будет периодически отправлять незашифрованный пакет местоположения на настроенный сервер MQTT, включающий идентификатор, короткое и длинное имя, приблизительное местоположение, модель оборудования, роль, версию встроенного ПО, регион LoRa, предустановку модема и название основного канала.'**
  String get yourNodeWillPeriodicallySendAn_b5be37;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вверх вниз 1'**
  String get upDown_908205;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Версия'**
  String get version_97c248;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Версия прошивки'**
  String get firmwareEdition_29bed8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вес'**
  String get weight_38348d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ветер'**
  String get wind_43eea9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включает модуль датчика обнаружения. Его необходимо включить как на ноде с датчиком, так и на всех нодах, на которых вы хотите получать текстовые сообщения датчика обнаружения или просматривать журнал и график датчика обнаружения.'**
  String get enablesTheDetectionSensorModuleIt_54016a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включает модуль хранения и пересылки.'**
  String get enablesTheStoreAndForwardModule_539c8a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включен'**
  String get enabled_edde94;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включение Ethernet отключит соединение Bluetooth с приложением.'**
  String get enablingEthernetWillDisableTheBluetooth_7dd901;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включить передачу метрик устройства в ячеистую сеть. При отключении метрики отправляются только подключенным клиентам.'**
  String get enableBroadcastingDeviceMetricsToThe_7c0170;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включить трансляцию пакетов через UDP по локальной сети.'**
  String get enableBroadcastingPacketsViaUdpOver_60fa0e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включить фильтрацию'**
  String get enableFilterHere_f6dfd3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включить это устройство как сервер хранения и пересылки. Требуется устройство ESP32 с PSRAM.'**
  String get enableThisDeviceAsAStore_4fbae6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Влажн'**
  String get hum_b7b903;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Влажн почвы'**
  String get soilMoist_1e2f47;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Влажность'**
  String get humidity_3b6f05;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Внешние уведомления'**
  String get externalNotification_22860a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Внимание: Данный контакт уже существует, импорт перезапишет ранее известную информацию о нём.'**
  String get warningThisContactIsKnownImporting_555efb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Восстановление связи…'**
  String get reconnecting_c0657e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вращение по часовой стрелке'**
  String get clockwiseRotaryEvent_fc48d3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вращение энкодера против часовой стрелки'**
  String get counterClockwiseRotaryEvent_e87a94;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Временное окно возврата истории'**
  String get historyReturnWindow_221c13;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Время'**
  String get time_c80d7e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Время последнего вещания'**
  String get lastHeardTime_c3cbbb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Все'**
  String get all_fd08da;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Все устройства будут работать в режиме ожидания, насколько это возможно, в качестве трекера и датчика также будет использоваться радиоприемник lora. Не используйте эту настройку, если вы хотите использовать свое устройство с приложениями для телефона или устройство без пользовательской кнопки.'**
  String get willSleepEverythingAsMuchAs_b3e005;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вставить ссылку'**
  String get insertLink_ab6720;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Всё'**
  String get all_fc7905;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вчера'**
  String get yesterday_51403c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вы'**
  String get you_adb403;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены, что хотите пересоздать свой приватный ключ?\n\nНоды, которые ранее обменивались ключами с этой нодой, должны будут удалить её и повторно обменяться ключами для того, чтобы возобновить защищённую связь.'**
  String get areYouSureYouWantTo_7ff54f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вы уверены?'**
  String get areYouSure_b0069b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выбери резервную копию для восстановления этой ноды. Сброс настроек или новый ключ меняет ID узла, поэтому старые резервные копии остаются под старым ID. Восстанавливай только резервную копию, взятую с этого же устройства: другой ключ дает обеим радиоустройствам одинаковый идентификатор.'**
  String get pickTheBackupToRestoreTo_92df2d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выбери резервную копию зашифрованного ключа для удаления с этого устройства. Это не может быть отменено.'**
  String get pickTheEncryptedKeyBackupTo_5e150c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вывод JSON включен'**
  String get jsonOutputEnabled_946891;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вывод отладочного журнала в реальном времени через последовательный порт, просмотр и экспорт журналов устройства со скрытыми позициями через Bluetooth.'**
  String get outputLiveDebugLoggingOverSerial_db97f9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выделять жирным шрифтом текст заголовка на экране.'**
  String get boldTheHeadingTextOnThe_6d5498;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выключение'**
  String get shutdown_468972;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выключение не поддерживается на этом устройстве'**
  String get shutdownNotSupportedOnThisDevice_04502f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Высота'**
  String get altitude_b24a95;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выход'**
  String get quit_c42457;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выходной контакт GPIO'**
  String get outputPinGpio_341423;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выходной контакт вибрации GPIO'**
  String get outputPinVibraGpio_7e4cdf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Готово'**
  String get done_398c7d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Давл'**
  String get baro_21229d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Давление'**
  String get pressure_aa017a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Далее'**
  String get next_9c714c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Датчик обнаружения'**
  String get detectionSensor_ef8fca;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Двойной тап как кнопка'**
  String get doubleTapAsButton_d2bc2c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Действия'**
  String get actions_9978ac;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Дисплей'**
  String get display_fff385;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Длительность выхода GPIO'**
  String get gpioOutputDuration_e159f4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Длительность супер-глубокого сна'**
  String get superDeepSleepDuration_c44e27;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Для максимальной совместимости принимать трафик без цифровой подписи. Пакет все равно будет отброшен, если подпись неверна и ее возможно проверить.'**
  String get acceptUnsignedTrafficForMaximumCompatibility_6a6fd7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Для этой ноды не найдено резервной копии ключа'**
  String get noKeyBackupFoundForThis_ce5803;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Добавить'**
  String get add_559a87;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Добавить канал'**
  String get addChannel_af2785;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Добавляет коррекцию ошибок поверх пресета. Более высокая скорость кодирования увеличивает длительность передачи каждого пакета и расходует больше рабочего цикла и ресурсов канала.'**
  String get addsErrorCorrectionOnTopOf_512807;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Дождь (1ч)'**
  String get rainH_ee76fe;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Дождь (24ч)'**
  String get rainH_90ad74;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Долгота'**
  String get longitude_f22a3e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Доступные контакты'**
  String get availablePins_a9affa;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Доступные пресеты модема, по умолчанию - Long Fast.'**
  String get availableModemPresetsDefaultIsLong_71dc05;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Единицы измерения на экране'**
  String get displayUnits_4a7072;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Если включено, контакт \'\'output\'\' будет активирован на высоком уровне, отключено означает активный низкий уровень.'**
  String get ifEnabledTheOutputPinWill_3d2627;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Если установлено, все отправляемые вами пакеты будут отправлены эхом обратно на ваше устройство.'**
  String get ifSetAnyPacketsYouSend_4305f4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Жирный заголовок'**
  String get boldHeading_29e9c1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Журнал отладки'**
  String get debugLogs_dea656;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Журналы'**
  String get logs_d821b9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Закрыть'**
  String get close_4ae50d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Заменить'**
  String get replace_d772cc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Звук'**
  String get audio_3bcc51;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Игнорировать'**
  String get ignore_00e05b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Игнорировать MQTT'**
  String get ignoreMqtt_be2d01;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Избранное'**
  String get favorite_b880e6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Импорт настроек'**
  String get importConfiguration_c776ef;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать'**
  String get import_55fd5f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Импортировать контакт?'**
  String get importSharedContact_5e5c66;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Имя'**
  String get name_aee78f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Имя пользователя'**
  String get username_a79f8a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Интервал карусели'**
  String get carouselInterval_fa458c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Интервал обновления'**
  String get updateInterval_fe3feb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Использование канала'**
  String get channelUtilization_b2e6eb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Использовать I2S как зуммер'**
  String get useISAsBuzzer_8b207f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Использовать PWM зуммер'**
  String get usePwmBuzzer_571ead;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Использовать пресет'**
  String get usePreset_f457c3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Использовать часовой пояс телефона'**
  String get usePhoneTimeZone_8a4f73;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Использует подтягивающий резистор'**
  String get usesPullupResistor_a75a60;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Использует сетевое подключение вашего телефона для подключения к MQTT.'**
  String get utilizesTheNetworkConnectionOnYour_d40c1d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Используйте выход PWM (например, RAK Buzzer) для мелодий вместо вывода вкл/выкл. Это будет игнорировать вывод, длительность вывода и активные настройки и использовать опцию GPIO зуммера в конфигурации устройства.'**
  String get useAPwmOutputLikeThe_6695f2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Каналы'**
  String get channels_88a8ec;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ключи надежно сохранены'**
  String get keysBackedUpSecurely_249b39;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Количество записей'**
  String get numberOfRecords_107e13;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Количество спутников'**
  String get sats_096274;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Консоль последовательного порта'**
  String get serialConsole_f80bee;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Консоль последовательного порта через Stream API.'**
  String get serialConsoleOverTheStreamApi_ee1f12;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Контакт GPIO'**
  String get gpioPin_68149e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Контакт GPIO для мониторинга'**
  String get gpioPinToMonitor_cef408;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Контакт GPIO передачи данных (txd)'**
  String get transmitDataTxdGpioPin_a33aed;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Контакт GPIO приема данных (rxd)'**
  String get receiveDataRxdGpioPin_05d193;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Контакт нажатия'**
  String get pressPin_e4f7eb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Копировать'**
  String get copy_4a05d8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Короткое имя'**
  String get shortName_58073d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Коэф. распространения'**
  String get spreadFactor_deb22e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Личные сообщения'**
  String get directMessages_6955f3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Локальная статистика'**
  String get localStats_f21f8a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Макс кол-во хопов для прямых сообщений'**
  String get maxHopsForDirectResponse_3ca022;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Макс пакетов в окне'**
  String get maxPacketsInWindow_75eb31;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Максимальное возвращение истории'**
  String get historyReturnMax_cb0955;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Местоположение'**
  String get position_82bd05;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Метрики качества воздуха'**
  String get airQualityMetrics_e4a5d4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Метрики окружения'**
  String get environmentMetrics_f472fb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Метрики окружения включены'**
  String get environmentMetricsEnabled_67632b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Метрики питания'**
  String get powerMetrics_f93c31;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Метрики устройства'**
  String get deviceMetrics_19b5ae;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Меш'**
  String get mesh_b9e236;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Мин. интервал позиционирования (сек)'**
  String get minPositionIntervalSecs_293ba3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Минимальное время бодрствования'**
  String get minimumWakeTime_de36c3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Минимальное расстояние'**
  String get minimumDistance_404b16;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Модель оборудования'**
  String get hardwareModel_feb4d1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Напряжение'**
  String get voltage_fb28eb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка Bluetooth'**
  String get bluetoothConfig_aae27c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка MQTT'**
  String get mqttConfig_c20987;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка TAK'**
  String get takConfiguration_cb4e17;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка датчика обнаружения'**
  String get detectionSensorConfig_9fd77e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка звука'**
  String get audioConfig_7ca6bd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка удаленного оборудования'**
  String get remoteHardwareConfig_b75c78;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка управления движением'**
  String get trafficManagementConfiguration_3bcd5d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки'**
  String get configuration_7f17c7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки модуля'**
  String get moduleConfiguration_f1e43a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки пользователя'**
  String get userConfig_28470f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки соседей'**
  String get neighborInfoConfig_b6a0ae;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки устройства'**
  String get deviceConfiguration_2030e8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось восстановить ключи из резервной копии'**
  String get failedToRestoreKeysFromBackup_89248f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Неактивно'**
  String get inactive_0b3829;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Независимо от того, используется ли режим INPUT_PULLUP для вывода GPIO. Применимо только в том случае, если на выводе платы используются подтягивающие резисторы'**
  String get whetherOrNotUseInputPullup_f96145;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ничего не найдено'**
  String get noResultsFound_1e1b70;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ноды'**
  String get nodes_fea63e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'О приложении'**
  String get about_b9c9ff;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'ОК для MQTT'**
  String get okToMqtt_81b6f7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Обменяться местоположением'**
  String get exchangePosition_b039f2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Обновить'**
  String get refresh_c2f668;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Оборудование'**
  String get hardware_2cf041;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ограничение скорости'**
  String get rateLimited_eebeda;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Окно ограничения скорости (сек.)'**
  String get rateLimitWindowSecs_5c4a08;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Освещённость'**
  String get lux_0ca380;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Основная тема'**
  String get rootTopic_994995;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отбрасывать неизвестные пакеты'**
  String get dropUnknownPackets_ba44e0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ответить'**
  String get reply_c6f466;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отключен'**
  String get disabled_cadea0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отключение при потере питания'**
  String get shutdownOnPowerLoss_753913;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отключено'**
  String get disconnected_9d30b9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отключить уведомления'**
  String get muteNotifications_6f777b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отключить фильтрацию'**
  String get disableFilterHere_24f1d5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Открыть в браузере'**
  String get openInBrowser_a1f2ae;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отладка'**
  String get debug_8669d1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отмена'**
  String get cancel_0ec753;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отменить ответ'**
  String get cancelReply_d5465b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отметка времени'**
  String get timestamp_9604ae;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отображение по Фаренгейту'**
  String get displayFahrenheit_8c89d1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправить'**
  String get send_76dcf7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправить heartbeat для оповещения о присутствии сервера.'**
  String get sendAHeartbeatToAdvertiseThe_80f353;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправить колокол'**
  String get sendBell_9a7a42;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправить сердцебиение'**
  String get sendHeartbeat_733393;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправьте ASCII колокольчик с предупреждающим сообщением. Полезно для срабатывания внешнего уведомления на колокольчик.'**
  String get sendAsciiBellWithAlertMessage_fbcdc2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отфильтрованные'**
  String get filtered_a13eeb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Очистить'**
  String get clear_98b207;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пакет позиции'**
  String get positionPacket_02f1de;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пароль'**
  String get password_14f7c6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Первичный'**
  String get primary_781ece;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Перевернуть экран'**
  String get flipScreen_8fe129;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Перевернуть экран вертикально'**
  String get flipScreenVertically_554b97;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Передача включена'**
  String get transmitEnabled_da32f9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Перезагрузка'**
  String get reboot_a40813;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Переопределение АЦП'**
  String get adcOverride_577328;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Переопределение частоты'**
  String get frequencyOverride_80233f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Переопределить COM-порт консоли'**
  String get overrideConsoleSerialPort_6cee74;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Переподключение'**
  String get reconnect_a8e2cf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Питание'**
  String get power_cea0d9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Питание экрана'**
  String get powerScreen_c81bdd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию'**
  String get default_469631;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поворотный 1'**
  String get rotary_378549;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get retry_9e506a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться местоположением'**
  String get locationSharing_26e070;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключение'**
  String get connecting_79e350;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключение…'**
  String get connecting_40b27e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключено'**
  String get connected_20bebc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключить'**
  String get connect_124298;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подлинность пакета'**
  String get packetAuthenticity_43a0f6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Позволяет устройствам с нативным аудиовыходом I2S использовать RTTTL через динамик как зуммер. Например, T-Watch S3 и T-Deck имеют эту возможность.'**
  String get enablesDevicesWithNativeIS_fb6aba;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Показатели широковещательного устройства'**
  String get broadcastDeviceMetrics_48d605;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Показать'**
  String get show_7788a1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Показать на экране устройства'**
  String get showOnDeviceScreen_b36075;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Показывать и обрабатывать только криптографически аутентифицированные mesh-пакеты. Старые ноды и слишком большие пакеты могут исчезнуть.'**
  String get onlyShowAndProcessCryptographicallyAuthenticated_4e43d0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пользователь'**
  String get user_51aff1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Порог передач неизвестных пакетов'**
  String get unknownPacketThreshold_db491f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Предпросмотр'**
  String get preview_5d092c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждающий вибромотор GPIO о получении звукового сигнала'**
  String get alertGpioVibraMotorWhenReceiving_fb8e2d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждающий вибромотор GPIO о получении сообщения'**
  String get alertGpioVibraMotorWhenReceiving_31bde3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждающий зуммер GPIO при получении звукового сигнала'**
  String get alertGpioBuzzerWhenReceivingA_5b83a2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждающий зуммер GPIO при получении сообщения'**
  String get alertGpioBuzzerWhenReceivingA_8c8033;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждение при получении звукового сигнала'**
  String get alertWhenReceivingABell_c28d01;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Предупреждение при получении сообщения'**
  String get alertWhenReceivingAMessage_a01361;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пресеты'**
  String get presets_c5eb0c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'При включении WiFi отключится bluetooth подключение к телефону'**
  String get enablingWifiWillDisableTheBluetooth_29400e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'При включении модуль прохожих подсчитывает количество людей, проходящих мимо, используя Wi-Fi и Bluetooth. Для работы счетчика количества человек как Wi-Fi, так и Bluetooth должны быть отключены.'**
  String get whenEnabledThePaxCounterModule_bf807f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Приложение'**
  String get app_f9886c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Проверка дальности'**
  String get rangeTest_6b237e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пропускная способность'**
  String get bandwidth_cb1c61;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Прошивка'**
  String get firmware_df1881;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Прыжков'**
  String get hopsAway_1337cd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Прямой ответ NodeInfo'**
  String get nodeinfoDirectResponse_ee19b3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Публичное сообщение о статусе, которое отправляется в сеть при изменении и каждые 12 часов.'**
  String get aPublicStatusMessageThatIs_1e34f9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Публичный ключ'**
  String get publicKey_225a9f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Публичный ключ изменён'**
  String get publicKeyChanged_999a04;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пульс LED'**
  String get ledHeartbeat_351815;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Рабочая частота вашей ноды рассчитывается на основе региона, настроек модема и этого поля. При значении 0 интервал автоматически рассчитывается на основе названия основного канала.'**
  String get yourNodeSOperatingFrequencyIs_89edec;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить неопределённый контакт'**
  String get allowUndefinedPinAccess_323b2d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Регион'**
  String get region_1089c8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Режим'**
  String get mode_ff0fbd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Режим повторной передачи'**
  String get rebroadcastMode_96abc5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Режим сопряжения'**
  String get pairingMode_053326;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Режим экрана'**
  String get displayMode_953816;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Резервная копия и восстановление'**
  String get backupRestore_e10c3e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Резервная копия ключа удалена'**
  String get keyBackupDeleted_2ed312;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Рингтон'**
  String get ringtone_622e53;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Роль'**
  String get role_ab51a3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Роль устройства'**
  String get deviceRole_1118bf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Светлая'**
  String get light_808001;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сегодня'**
  String get today_5d5d2e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сервер'**
  String get server_917e05;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сеть'**
  String get network_b3c4b1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сигнал'**
  String get signal_b26f0d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать QR-код общих каналов'**
  String get scanSharedChannelsQrCode_e4128b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скачать'**
  String get download_fe8f79;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скорость кодирования'**
  String get codingRate_4440db;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть'**
  String get hide_107291;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Служебные уведомления'**
  String get serviceNotifications_f0c59c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Событие нажатия энкодера'**
  String get encoderPressEvent_c7ef35;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Согласие на передачу незашифрованных данных ноды через MQTT'**
  String get consentToShareUnencryptedNodeData_2a83b2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сообщение'**
  String get message_dc7234;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения'**
  String get messages_019803;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения, отправленные тебе напрямую.'**
  String get messagesSentDirectlyToYou_9bb02c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сопротивление газа'**
  String get gasResistance_ccf913;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Состояние'**
  String get status_81e4bb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Состояние LED'**
  String get ledState_e13197;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Состояние LED (вкл/выкл)'**
  String get theStateOfTheLedOn_90485e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Состояние сообщения'**
  String get statusMessage_b6dd18;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить'**
  String get save_486405;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить избранное?'**
  String get preserveFavorites_8bd086;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить публичные и приватные ключи в безопасном зашифрованном хранилище на этом устройстве.'**
  String get savesThePublicAndPrivateKeys_819ff7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохраняет CSV с деталями сообщений тестирования дальности, в настоящее время доступно только на устройствах ESP32 с веб-сервером.'**
  String get savesACsvWithTheRange_d3ca60;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Статус'**
  String get status_f7f293;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Строгий игнорирует любые удалённые mesh-пакеты, которые не прошли криптографическую аутентификацию. Более старая прошивка, лицензированные устройства или ноды Ham без PKI-ключей и слишком большие пакеты могут перестать работать. Прямые сообщения с PKI-аутентификацией остаются доступными.'**
  String get strictIgnoresEveryRemoteMeshPacket_c16f59;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Считать двойное нажатие на поддерживаемых акселерометрах как нажатие пользовательской кнопки.'**
  String get treatDoubleTapOnSupportedAccelerometers_28e78a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Таймаут'**
  String get timeout_82605b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Телеметрия'**
  String get telemetry_c2d0b0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Тема'**
  String get theme_553c45;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Темп'**
  String get temp_e0d826;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Темп почвы'**
  String get soilTemp_014031;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Температура'**
  String get temperature_56f765;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Тип OLED'**
  String get oledType_6f928e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Тип триггера'**
  String get triggertype_435565;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ток'**
  String get current_47b6bf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Только зашифрованные'**
  String get encryptedOnly_5943ed;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Только избранные'**
  String get favoritesOnly_f1d6dc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Только подписанные'**
  String get signedOnly_a90195;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Точка росы'**
  String get dewPoint_5fb1ca;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Трассировка маршрута'**
  String get traceRoute_c2e3ed;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Требуется наличие акселерометра на вашем устройстве.'**
  String get requiresThatThereBeAnAccelerometer_b88b6d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'У этого контакта нет публичного ключа, поэтому его нельзя импортировать. Контакт без ключа стирает любой ключ, который твоя радиостанция уже хранит для этой ноды. Попроси отправителя снова поделиться им, когда его нода обменяется ключами.'**
  String get thisContactHasNoPublicKey_1b1efe;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления'**
  String get notifications_ee3c35;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления о личных сообщениях'**
  String get directMessageNotifications_35b81d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удаление дубликатов позиций'**
  String get positionDeduplication_77bb08;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удаленное оборудование включено'**
  String get remoteHardwareEnabled_2d4140;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удаленное устройство'**
  String get remoteHardware_aa22db;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удалить'**
  String get delete_86ea33;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удалить резервную копию ключа'**
  String get deleteKeyBackup_2b8633;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Умное позиционирование'**
  String get smartPosition_71605c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Управление движением'**
  String get trafficManagement_c0dc15;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Управляемое устройство'**
  String get managedDevice_5802d0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Управляет мигающим светодиодом на устройстве. Для большинства устройств это будет управлять одним из максимум 4 светодиодов, светодиоды зарядки и GPS не управляются.'**
  String get controlsTheBlinkingLedOnThe_f98894;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Уровень защиты'**
  String get protectionLevel_b65cfe;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Усиление приема'**
  String get rxBoostedGain_ccd314;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Устанавливает 12-часовой формат экранных часов.'**
  String get setsTheScreenClockFormatTo_522029;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Устройство'**
  String get device_bc791d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Устройством управляет администратор сети, пользователь не может получить доступ ни к одной настройке устройства.'**
  String get deviceIsManagedByAMesh_c25d72;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Фиксированная позиция'**
  String get fixedPosition_375f92;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Фиксированный PIN'**
  String get fixedPin_a02794;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр слов не настроен'**
  String get noFilterWordsConfigured_f30bc1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Фильтр сообщений'**
  String get messageFilter_cf2a46;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Фильтровать все диалоги'**
  String get filterAllConversations_0c4f61;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Фильтруемые слова'**
  String get filterWords_42f560;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры'**
  String get filters_67e16d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Часовой пояс'**
  String get timeZone_47947a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Часовой пояс дат на экране и журнале устройства.'**
  String get timeZoneForDatesOnThe_ab5297;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Частотный слот'**
  String get frequencySlot_8cb1e6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Широта'**
  String get latitude_e4f731;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Шифрование включено'**
  String get encryptionEnabled_a31349;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Экран включен на'**
  String get screenOnFor_c40d42;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Экран пробуждения при нажатии или движении'**
  String get wakeScreenOnTapOrMotion_cbc6f1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт настроек'**
  String get exportConfiguration_af2d98;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Энергосбережение'**
  String get powerSaving_668a8d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Эта полоса пропускания не поддерживается подключённым радио в выбранном регионе. Выберите поддерживаемое значение перед сохранением.'**
  String get thisBandwidthIsNotSupportedBy_629cec;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Это подключенное устройство не поддерживает верификацию подписи пакетов.'**
  String get thisConnectedDeviceDoesNotSupport_a098e6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Этот QR-код содержит полную конфигурацию. Это заменит ваши существующие каналы и настройки радио. Все существующие каналы будут удалены.'**
  String get thisQrCodeContainsAComplete_8382f2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Эхо'**
  String get echo_1beee7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Язык'**
  String get language_ed3f0e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'⚠️ Эта нода будет ВЫКЛЮЧЕНА. Для её включения потребуется физическое взаимодействие.'**
  String get thisWillShutdownTheNodePhysical_dda266;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'1 байт'**
  String get byte_2b1af8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'128 бит'**
  String get bit_4d4041;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'256 бит'**
  String get bit_4b629b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MQTT Включена восходящая связь'**
  String get mqttUplinkEnabled_0922b5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MQTT Нисходящая связь включена'**
  String get mqttDownlinkEnabled_07f56b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'UDP-трансляция'**
  String get udpBroadcast_cb95ce;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Был отправлен запрос трассировки маршрута, ответа получено не было.'**
  String get aTraceRouteWasSentNo_831209;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включить'**
  String get include_66be7e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Влажность почвы'**
  String get soilMoisture_09ca2d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Возникла проблема с открытым ключом этого контакта.'**
  String get thereIsAnIssueWithThis_da58d6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Восстановить'**
  String get restore_29f3b2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Время работы'**
  String get uptime_519192;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Второй'**
  String get second_a0f62f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Второй ключ админа'**
  String get secondaryAdminKey_a17eea;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Входы'**
  String get inputs_4465f9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выберите ноду'**
  String get selectANode_674ed0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выбор времени и переопределения'**
  String get timingAndOverrides_7df059;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выключить ноду?'**
  String get shutDownNode_6cff20;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Высота над уровнем моря'**
  String get altitudeIsMeanSeaLevel_9128a7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выходной контакт зуммера GPIO'**
  String get outputPinBuzzerGpio_d0254b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Длинное имя'**
  String get longName_4a55b1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Для всей функциональности MQTT, кроме отчета карты, вы также должны настроить восходящую и нисходящую связь для каждого канала, который хотите мостить через MQTT.'**
  String get forAllMqttFunctionalityOtherThan_528328;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Для соблюдения законов о конфиденциальности, таких как CCPA и GDPR, мы избегаем передачи точных данных о местоположении. Вместо этого мы используем анонимизированную или приблизительную (неточную) информацию о местоположении для защиты вашей конфиденциальности.'**
  String get toComplyWithPrivacyLawsLike_17f767;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Добавить каналы'**
  String get addChannels_236dd4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Добавить контакт'**
  String get addContact_155d11;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Дополнительно'**
  String get advanced_d7907f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Дополнительный GPIO'**
  String get optionalGpio_967662;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Журнал трассировки маршрута'**
  String get traceRouteLog_eaa487;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Заменить каналы'**
  String get replaceChannels_d0b4ac;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Зашифровано'**
  String get encrypted_347a1a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Значение коррекции высоты'**
  String get altitudeGeoidalSeparation_166950;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Игнорируется'**
  String get ignored_4561a6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Излучение'**
  String get radiation_3bdf95;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Используется для идентификации неотслеживаемых или инфраструктурных нод, чтобы обмен сообщениями был недоступен для нод, которые никогда не ответят.'**
  String get usedToIdentifyUnmonitoredOrInfrastructure_57ed87;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Как долго экран остается включенным после нажатия кнопки пользователя или получения сообщений.'**
  String get howLongTheScreenRemainsOn_6187f3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ключ'**
  String get key_cc6ec0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ключ личных переписок'**
  String get directMessageKey_db3f1a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ключи админа'**
  String get adminKeys_59351d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Конфигурация модуля'**
  String get moduleConfiguration_4b812e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Конфигурация сохраненных сообщений'**
  String get cannedMessagesConfig_458203;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Конфигурация устройства'**
  String get deviceConfiguration_ccb937;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Корневая тема для использования MQTT.'**
  String get theRootTopicToUseFor_ee86b4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Назначение клавиш'**
  String get keyMapping_0f4f90;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Найти ноду'**
  String get findANode_861918;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Направление транспорта'**
  String get vehicleHeading_7136f7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка LoRa'**
  String get loraConfig_980826;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка внешних уведомлений'**
  String get externalNotificationConfig_b8060c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка окружающего освещения'**
  String get ambientLightingConfig_04051c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка позиции'**
  String get positionConfig_0ef894;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка последовательного порта'**
  String get serialConfig_060db9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка радио'**
  String get radioConfiguration_dbf9ae;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка сети'**
  String get networkConfig_845e74;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка сохранения и пересылки'**
  String get storeForwardConfig_27a553;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка счетчика прохожих'**
  String get paxCounterConfig_5a4b67;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка теста дальности'**
  String get rangeTestConfig_c02f93;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройка устройства'**
  String get deviceConfig_1c4174;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки безопасности'**
  String get securityConfig_2b6ab6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки питания'**
  String get powerConfig_f44024;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки телеметрии'**
  String get telemetryConfig_75dc08;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки экрана'**
  String get displayConfig_acaf70;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не задан'**
  String get unset_7faabd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Невозможно отправить сообщение'**
  String get unmessagable_42f44c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Неконтролируемый'**
  String get unmonitored_0eff12;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Несоответствие открытого ключа'**
  String get publicKeyMismatch_a6a194;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода'**
  String get node_2409cc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Одна минута'**
  String get oneMinute_6d5cba;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Окружающее освещение'**
  String get ambientLighting_d3a18a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Онлайн'**
  String get online_76e9fb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отчет карты'**
  String get mapReport_64f9f0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Очистить устаревшие ноды'**
  String get clearStaleNodes_968b4f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Параметры'**
  String get options_6744ad;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Параметры Ethernet'**
  String get ethernetOptions_d9cb39;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Параметры WiFi'**
  String get wifiOptions_612b23;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Параметры датчика'**
  String get sensorOptions_abc34e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Параметры датчика окружения'**
  String get environmentSensorOptions_850067;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Параметры питания сенсоров'**
  String get powerSensorOptions_9aba2f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Параметры сервера'**
  String get serverOption_1dc679;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Параметры устройства'**
  String get deviceOptions_4d2301;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Первичный GPIO'**
  String get primaryGpio_b6ae3c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Первичный ключ администратора'**
  String get primaryAdminKey_e8e5be;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Первое обнаружение'**
  String get firstHeard_fb9dde;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Перейти к ноде'**
  String get navigateToNode_3ebc01;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Переопределить автоматическое обнаружение OLED-экрана.'**
  String get overrideAutomaticOledScreenDetection_3e664c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Переопределить макет экрана по умолчанию'**
  String get overrideDefaultScreenLayout_abfc85;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться QR контакта'**
  String get shareContactQr_3fcfa5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поделиться QR-кодом'**
  String get shareQrCode_6584cb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключение к MQTT через прокси'**
  String get connectToMqttViaProxy_385c9e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подробности...'**
  String get details_abaf4c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение'**
  String get confirm_846aff;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Позиции включены'**
  String get positionsEnabled_05a345;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Позиция'**
  String get position_c139a7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поиск'**
  String get search_6433b5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Порядковый номер'**
  String get sequenceNumber_12b28a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'После сохранения значений нода перезагрузится.'**
  String get afterConfigValuesSaveTheNode_675d86;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Последние 4 символа MAC-адреса устройства будут добавлены к короткому имени для установки имени BLE устройства. Короткое имя может быть длиной до 4 байт.'**
  String get theLastOfTheDeviceMac_aa05c8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Последовательный порт'**
  String get serial_427dc5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Преднастройки конфигурации'**
  String get configurationPresets_057e0a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Приблизительное местоположение'**
  String get approximateLocation_5a3d58;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте, с кем вы общаетесь, сравнив открытые ключи при личной встрече или по телефону. Самый последний открытый ключ для этой ноды не совпадает с ранее записанным ключом. Вы можете удалить ноду и позволить ей снова обменяться ключами, если смена ключа произошла из-за сброса настроек или другого преднамеренного действия, но это также может указывать на более серьезную проблему безопасности.'**
  String get verifyWhoYouAreMessagingWith_690825;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пустой'**
  String get empty_2138fa;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пять минут'**
  String get fiveMinutes_960eec;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Размер ключа'**
  String get keySize_b9f9ea;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить запрос позиции'**
  String get allowPositionRequests_11c111;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Расширенное устройство GPS'**
  String get advancedDeviceGps_afe61f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Регион, в котором вы будете использовать ваше устройство'**
  String get theRegionWhereYouWillBe_5a735c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Резервная копия'**
  String get backup_72f931;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Резервная копия ключа'**
  String get keyBackup_30f9f7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Роли'**
  String get roles_265068;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Роль канала'**
  String get channelRole_d02621;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сброс NodeDB'**
  String get resetNodedb_58a887;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сброс к заводским настройкам удалит данные устройства и приложения.'**
  String get factoryResetWillDeleteDeviceAnd_cd2c63;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сброс настроек'**
  String get factoryReset_5dbd37;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сведения о канале'**
  String get channelDetails_1240d4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сведения о пользователе'**
  String get userDetails_4f06a9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Серверы сохранения и пересылки требуют устройство ESP32 с PSRAM или Linux Native.'**
  String get storeAndForwardServersRequireAn_adeadb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скорость транспорта'**
  String get vehicleSpeed_32ceef;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Создать заново закрытый ключ'**
  String get regeneratePrivateKey_4eb698;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Создать новый закрытый ключ для замены текущего. Открытый ключ будет автоматически создан из вашего закрытого ключа.'**
  String get generateANewPrivateKeyTo_cb7634;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Создать резервную копию приватного ключа в связку ключей iCloud.'**
  String get backupYourPrivateKeyToYour_eef405;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения разделяются |'**
  String get messagesSeparateWith_efc965;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохраненные сообщения'**
  String get cannedMessages_f068fb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить и переслать'**
  String get storeForward_05111b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Счетчик прохожих'**
  String get paxCounter_34f998;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Температура почвы'**
  String get soilTemp_e10385;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Тест дальности'**
  String get rangeTest_c0e745;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Тип управления'**
  String get controlType_b68319;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Точное местоположение'**
  String get preciseLocation_bdfcca;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Трафик'**
  String get traffic_6990f2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Третичный ключ администратора'**
  String get tertiaryAdminKey_bc13d6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все настройки, ключи и BLE-соединения?'**
  String get deleteAllConfigKeysAndBle_cca1f1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удалить все настройки?'**
  String get deleteAllConfig_8a83a4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удалить ноду?'**
  String get deleteNode_d5a0b2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Уровень заряда'**
  String get batteryLevel_9ffc19;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Устройство GPS'**
  String get deviceGps_a724ae;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Флаги позиции'**
  String get positionFlags_813b55;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Цвет'**
  String get color_84b22e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Экран'**
  String get display_0cca12;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Экран устройства'**
  String get deviceScreen_566ed6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Это отключит фиксированную позицию и удалит текущую установленную позицию.'**
  String get thisWillDisableFixedPositionAnd_d42ce0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Это отправит текущую позицию с вашего телефона и включит фиксированную позицию.'**
  String get thisWillSendACurrentPosition_45fe3d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Эфирное время'**
  String get airtime_060fe3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Язык передачи рингтона (RTTTL) - строка рингтона, используемая поддерживаемыми зуммерами во внешних уведомлениях.'**
  String get ringtoneTransferLanguageRtttlRingtoneString_7d5b14;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Тип события-триггера'**
  String get triggerEventType_8a7f87;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ток управления для выхода светодиода.'**
  String get ledOutputDriveCurrent_1fa019;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Только из зеркала'**
  String get mirrorOnly_543934;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Только лог ноды'**
  String get nodeLogOnly_3a7130;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Точность позиций'**
  String get positionPrecision_01dd31;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Транслирует пакеты местоположения GPS в приоритетном порядке.'**
  String get prioritizesBroadcastingGpsPositionPackets_090b6f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Транслирует пакеты телеметрии в приоритетном порядке.'**
  String get prioritizesBroadcastingTelemetryPackets_650606;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Трассировка не найдена'**
  String get tracerouteNotFound_b165bf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Трассировка отправлена — ждём ответ'**
  String get tracerouteSentWaitingForAResponse_9a18a6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Трассировки'**
  String get traceroutes_84a6df;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Трассировок нет'**
  String get noTraceroutes_921f96;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Тёмная'**
  String get dark_bd16b2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'У каждой ноды своя база: ноды, каналы, сообщения и копия зеркала. Сверх заданного числа самая давно не использованная база удаляется вместе с перепиской; 0 — хранить все. Открытую базу удалить нельзя.'**
  String get eachNodeHasItsOwnDatabase_534196;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'У этой ноды нет ни Wi-Fi, ни Ethernet.'**
  String get thisNodeHasNeitherWiFi_ee205d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Убрано из избранного'**
  String get removedFromFavorites_f3503a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления о реакциях'**
  String get reactionNotifications_cb9243;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удаленное оборудование'**
  String get remoteHardware_9cd039;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удалить базу?'**
  String get deleteDatabase_97a78b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удалить картинку?'**
  String get deleteImage_8faab6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удалить карту'**
  String get deleteMap_077c0a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удалить лишние базы?'**
  String get deleteExtraDatabases_ff4d99;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Указывает, как повернуть или инвертировать вывод компаса для точного отображения.'**
  String get specifiesHowToRotateOrInvert_c2e76b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Украина 433 Мгц'**
  String get ukraineMhz_71f385;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Умный интервал'**
  String get smartInterval_e82120;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Упоминания моей ноды'**
  String get mentionsOfMyNode_dfdc0f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Уровень зелёного канала светодиода подсветки.'**
  String get greenChannelLevelOfTheBacklight_82039b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Уровень красного канала светодиода подсветки.'**
  String get redChannelLevelOfTheBacklight_eecf26;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Уровень синего светодиода фоновой подсветки.'**
  String get blueChannelLevelOfTheBacklight_54c801;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Установить вручную'**
  String get setManually_8f0d8a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Установить с телефона'**
  String get usePhonePosition_026914;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Установлена последняя версия'**
  String get youHaveTheLatestVersion_6ae127;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Устаревшая инфраструктурная роль, создающая разрывы в цепочке ретрансляции mesh-сети. Переключите эту ноду на роль на основе Router (Router или Router Late).'**
  String get deprecatedInfrastructureRoleThatBreaksThe_9d25ee;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Устаревшее устройство'**
  String get legacyDevice_9f4169;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Устройство больше не поддерживается и не получает обновлений прошивки.'**
  String get thisDeviceIsNoLongerSupported_1eacd7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Устройство сообщества'**
  String get communityDevice_ee5a2a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Устройство, которое не пересылает пакеты с других устройств.'**
  String get deviceThatDoesNotForwardPackets_56dca1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Устройство, которое передает сигнал только при необходимости для скрытности или экономии энергии.'**
  String get deviceThatTransmitsOnlyWhenNecessary_cbb9fa;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Файл .cfg, как в официальных приложениях'**
  String get aCfgFileAsUsedBy_8cf2f0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Файл не похож на картинку'**
  String get theFileDoesNotAppearTo_bd6b67;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Файл не похож на резервную копию ключа'**
  String get theFileDoesNotAppearTo_788b13;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Файл пустой'**
  String get theFileIsEmpty_e16485;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Файл слишком большой для конфигурации'**
  String get theFileIsTooLargeFor_f5e529;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Файл сохранён более новой версией приложения'**
  String get theFileWasSavedByA_ca52a5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Фиксированный PIN-код для подключения к Bluetooth. Используется при соединении с фиксированным PIN-кодом'**
  String get fixedPinForBluetoothPairingUsed_5e7b2a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Филиппины 433 МГц'**
  String get philippinesMhz_447f09;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Филиппины 868 МГц'**
  String get philippinesMhz_c66f5b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Филиппины 915 МГц'**
  String get philippinesMhz_6c76eb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Фильтры и сортировка'**
  String get filtersAndSorting_7551fe;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Фиолетовый'**
  String get purple_13c197;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Хопов'**
  String get hops_859d39;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Хопов не больше'**
  String get maximumHops_a86743;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Хранение и пересылка'**
  String get storeAndForward_61adb3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Хранение и удаление'**
  String get storageAndDeletion_a10344;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Цвет акцента'**
  String get accentColor_ff9b5d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Цвет сообщений с упоминанием или ответом на ваше'**
  String get colorOfMessagesMentioningOrReplying_a39b9c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Цвет упоминаний и ответов на ваше'**
  String get colorOfMentionsAndRepliesTo_cbd753;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Центр'**
  String get center_05b1c1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Центр области'**
  String get areaCenter_63f063;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Частицы'**
  String get particles_e6d802;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Частота дискретизации CODEC2'**
  String get codecSampleRate_535520;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Чат'**
  String get chat_8c77e4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Что НЕ отправляется'**
  String get whatIsNotSent_7dd3f5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Что будет отправлено'**
  String get whatWillBeSent_e8db1a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Что делали, что ожидали, что получилось'**
  String get whatYouDidWhatYouExpected_81e7ad;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Что не так (необязательно)'**
  String get whatIsWrongOptional_5f4ae1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Что случилось'**
  String get whatHappened_81dc9f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Чёрная'**
  String get black_0d6b1a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Шифрование'**
  String get encryption_72622e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Шлюз'**
  String get gateway_715fc6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт в файл'**
  String get exportToFile_5ba2da;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Экспорт приватного ключа'**
  String get exportPrivateKey_8cfcb4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Это база открытой сейчас ноды — её заменить нельзя'**
  String get thisDatabaseBelongsToTheCurrently_45a34e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Это не база Meshex'**
  String get thisIsNotAMeshexDatabase_4c1a04;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Это не ссылка контакта'**
  String get thisIsNotAContactLink_e1159c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Это не ссылка на каналы Meshtastic'**
  String get thisIsNotAMeshtasticChannel_036b26;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Это не файл базы SQLite'**
  String get thisIsNotASqliteDatabase_c247f9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Это не файл конфигурации Meshtastic'**
  String get thisIsNotAMeshtasticConfiguration_21780c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Это открытая база'**
  String get thisDatabaseIsOpen_86610c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Этот QR-код содержит полную конфигурацию. Это заменит ваши существующие каналы и настройки радио.'**
  String get thisQrCodeContainsAFull_84c455;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ю'**
  String get s_b759c4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'ЮВ'**
  String get se_e26c37;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'ЮЗ'**
  String get sw_58a11c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Япония'**
  String get japan_44a609;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'авг.'**
  String get aug_098b49;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'апр.'**
  String get apr_0ab944;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'вероятно, подменённая точка (зона глушилки)'**
  String get possiblySpoofedPositionInterferenceZone_80184e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'все'**
  String get all_ef8ff2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'выкл.'**
  String get off_147380;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'гПа'**
  String get hpa_d96200;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'геолокация на телефоне выключена'**
  String get locationServicesAreDisabledOnThe_c9a206;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'дек.'**
  String get dec_e8b13c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'ждём ответ'**
  String get waitingForResponse_ea1f81;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'за 2 ч'**
  String get lastHours_154ae5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'за 7 дней'**
  String get lastDays_3f4fcc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'за всё время'**
  String get allTime_9790a7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'за сутки'**
  String get lastHours_fee233;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'за час'**
  String get lastHour_5702d4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'загрузка нод'**
  String get loadingNodes_1c32b3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'зеркало'**
  String get mirror_53fbab;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'июля'**
  String get july_8510c0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'июня'**
  String get june_1e3af2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'кг'**
  String get kg_59ddef;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'км'**
  String get km_3ced3a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'лк'**
  String get lx_cfc6c7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'любое'**
  String get any_3290bc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'м/с'**
  String get mS_73183b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'мА'**
  String get ma_6562f3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'марта'**
  String get march_cd806e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'мая'**
  String get may_7bbf85;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'мин'**
  String get min_d6035d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'мкР/ч'**
  String get rH_34dc16;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'мкг/м³'**
  String get gM_67c6f5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'мм'**
  String get mm_b8d125;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'на грани'**
  String get marginal_e208a1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'на связи'**
  String get connected_abb335;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'напрямую'**
  String get direct_95dc0c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'не задан — фильтр не работает'**
  String get notSetTheFilterIsInactive_8aa65f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'не поддерживается прошивкой'**
  String get unsupportedByTheFirmware_936c06;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'не подключена'**
  String get disconnected_0cf65d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'не подключено'**
  String get disconnected_e29749;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'нет доступа к геолокации'**
  String get locationAccessDenied_606358;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'нет ключа'**
  String get noKey_edc637;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'нет ответа'**
  String get noResponse_967d69;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'нет публичного ключа ноды'**
  String get noNodePublicKey_e13456;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'нет публичного ключа ноды — дождитесь её NodeInfo'**
  String get noNodePublicKeyWaitFor_78601d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'нет связи'**
  String get noConnection_75a42a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'нет соединения с нодой'**
  String get noNodeConnection_114c0d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'нода не принимает личные сообщения'**
  String get theNodeDoesNotAcceptDirect_63d6ab;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'нояб.'**
  String get nov_0adb0f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'нужна прошивка 2.7.20+'**
  String get requiresFirmware_a63ae1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'нужна прошивка 2.8+'**
  String get requiresFirmware_e37f17;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'ожидание переподключения'**
  String get waitingToReconnect_b168a0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'окт.'**
  String get oct_22e90b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'основной'**
  String get primary_8a174a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'от сети'**
  String get externalPower_963740;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'первичный канал не удаляется'**
  String get thePrimaryChannelCannotBeDeleted_1b4706;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'пинг'**
  String get ping_1b6f5d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'плохой'**
  String get poor_324298;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'по SNR'**
  String get bySnr_f87a18;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'по времени'**
  String get byTime_5bad62;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'по имени'**
  String get byName_21b8bf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'по умолчанию'**
  String get default_0d558f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'по хопам'**
  String get byHops_90b84d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'подключена'**
  String get connected_f006c9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'подключение'**
  String get connecting_794e89;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'получение конфигурации'**
  String get receivingConfiguration_8a745a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'при обрыве связи'**
  String get onConnectionLoss_24be13;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'радио'**
  String get radio_c9a417;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'с'**
  String get s_b40bbc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'своя нода ещё не загружена'**
  String get ownNodeNotLoadedYet_b8cd83;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'сент.'**
  String get sep_309c10;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'сервер не вернул номер отчёта'**
  String get theServerDidNotReturnA_df447b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'сеть'**
  String get network_2f481e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'скорректировано по соседям'**
  String get correctedUsingNeighbors_e10fad;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'слишком много отчётов, попробуйте позже'**
  String get tooManyReportsTryAgainLater_6816c9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'соединение с нодой изменилось'**
  String get theNodeConnectionChanged_1d3493;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'средний'**
  String get fair_f2d6a6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'тест'**
  String get test_0ebb88;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'только из зеркала'**
  String get mirrorOnly_cb09e9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'только что'**
  String get justNow_c47cbe;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'у контакта нет публичного ключа'**
  String get theContactHasNoPublicKey_3c0ca0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'у своей ноды нет координат'**
  String get yourNodeHasNoCoordinates_1602cf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'февр.'**
  String get feb_4d7ceb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'хоп'**
  String get hop_bbae58;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'хопа'**
  String get hops_070a7f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'хопов'**
  String get hops_c54799;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'хороший'**
  String get good_d5f5ec;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'янв.'**
  String get jan_28e060;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию (250 кГц)'**
  String get defaultKhz_0f9e1a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'По умолчанию (812.5 кГц)'**
  String get defaultKhz_696623;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поворачивается вслед за телефоном'**
  String get rotatesWithThePhone_3acc7b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поворот двумя пальцами. Выключено — север всегда сверху.'**
  String get rotateWithTwoFingersWhenDisabled_194ca1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Под фильтр не подходит ни одна нода с координатами.'**
  String get noNodesWithCoordinatesMatchThe_70925b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Под фильтр ничего не подходит'**
  String get nothingMatchesTheFilter_42d5b4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поддерживаемое устройство'**
  String get supportedDevice_7bbcea;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поддерживается, прошивка обновляется; специализированный форм-фактор.'**
  String get supportedWithFirmwareUpdatesSpecializedForm_a06e6b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поддержка'**
  String get support_6ae569;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключаться к последней ноде при запуске'**
  String get connectToTheLastNodeOn_98c221;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключение к зеркалу необязательно: адрес выбираете вы. При проверке адреса и подключении сервер видит IP-адрес соединения, время и параметры запросов, версию приложения и платформу. Сервер может предложить дополнительные сервисы изображений и отчётов на других адресах. Содержимым, журналами и сроками хранения управляет оператор соответствующего сервиса; клиент не управляет этим сервером. Условия обработки и удаления серверных данных уточняйте у его оператора.'**
  String get connectingToAMirrorIsOptional_975b0b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключение к серверу сообщества'**
  String get connectingToACommunityServer_a8bcbd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключено с'**
  String get connectedSince_c5387f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключите ноду кабелем USB'**
  String get connectTheNodeUsingAUsb_c6b502;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключитесь к ноде'**
  String get connectToANode_6caeff;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключитесь к ноде, чтобы импортировать'**
  String get connectToANodeToImport_c0f2ca;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключитесь к ноде, чтобы писать'**
  String get connectToANodeToSend_67b4d9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключитесь к своей ноде'**
  String get connectToYourOwnNode_d2f276;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подключитесь к своей ноде.'**
  String get connectToYourOwnNode_cefdf1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подождите перед повторной командой'**
  String get waitBeforeRepeatingTheCommand_4113a0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подождите, действие временно недоступно'**
  String get pleaseWaitThisActionIsTemporarily_4a28f0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подписывают пакеты (прошивка 2.8)'**
  String get signPacketsFirmware_c59ca8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подпись'**
  String get signature_a5dcf3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подпись не принята — ключ ноды изменился? Попробуйте позже'**
  String get signatureRejectedHasTheNodeKey_2b76db;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подпись отправителя проверена'**
  String get senderSignatureVerified_96ee0d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подробнее'**
  String get details_7e4277;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подсеть'**
  String get subnet_05d5fa;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Подтверждение не прошло проверку — возможна подделка'**
  String get acknowledgmentVerificationFailedPossibleForgery_c5e853;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пожаловаться'**
  String get report_5405a3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пожаловаться на картинку?'**
  String get reportThisImage_07a666;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пожалуйста, выберите регион'**
  String get pleaseSelectARegion_a28cc4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Позиция ещё не задана — выберите, откуда её взять'**
  String get positionNotSetYetChooseIts_607bea;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Позиция отправлена в сеть'**
  String get positionBroadcast_9b9f9c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Позиция отправлена — ждём ответную'**
  String get positionSentWaitingForAResponse_640d17;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Позиция телефона'**
  String get phonePosition_68a6a2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поиск из списка нод'**
  String get searchFromTheNodeList_a208a5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по настройкам'**
  String get searchSettings_69a03f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поиск по сообщениям'**
  String get searchMessages_b03790;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поиск портов…'**
  String get searchingForPorts_eea068;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пока пусто'**
  String get nothingHereYet_ea91cf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Показать все'**
  String get showAll_9d04f0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Показать все ноды'**
  String get showAllNodes_174d10;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Показать ещё'**
  String get showMore_b53ec8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Показывать игнорируемые'**
  String get showIgnoredNodes_48f862;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Показывать картинки'**
  String get showImages_436fda;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Показывать скрытые сообщения'**
  String get showHiddenMessages_4e0ac3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Политика конфиденциальности'**
  String get privacyPolicy_4041aa;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Получение ключа из зеркала…'**
  String get retrievingKeyFromMirror_8c97ce;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Получение публичного ключа из зеркала…'**
  String get retrievingPublicKeyFromMirror_c82d52;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Попыток'**
  String get attempts_002dd4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Портов не найдено'**
  String get noPortsFound_cc35ea;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'После записи нода перезагрузится и подключение прервётся.'**
  String get theNodeWillRestartAfterWriting_a91c98;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Последний пакет от ноды — столько назад'**
  String get timeSinceTheLastPacketFrom_b027b2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Превью ссылок сервиса картинок подключённого сервера прямо в ленте'**
  String get showPreviewsOfImageServiceLinks_92d5b2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пресет'**
  String get preset_a6549e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'При загрузке изображения выбранному сервису передаются файл и ID ноды с подписью запроса. Получатели ссылки могут просматривать изображение. При жалобе передаются ID ноды, ID изображения и указанная причина. Удаление своей картинки доступно, если его поддерживает сервис и в приложении сохранён токен удаления. Оно не удаляет копии, которые могли сохранить другие пользователи.'**
  String get uploadingAnImageSendsTheFile_5e9db2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'При загрузке карты сервер тайлов получает IP-адрес и запросы участков карты. В зависимости от подложки используются OpenStreetMap, OpenTopoMap или CARTO либо настроенный прокси. Офлайн-карта скачивается с сайта Meshex. В сборках с собственной проверкой обновлений приложение обращается к API GitHub; автоматическую проверку можно выключить в разделе «О приложении».'**
  String get loadingMapsSendsYourIpAddress_c7eb25;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'При проверке адреса и подключении сервер получает:\n• IP-адрес вашего соединения и время запросов;\n• версию приложения и платформу;\n• запрашиваемые данные — например, ID просматриваемой ноды или диапазон истории сообщений.\nОператор может сохранять эти сведения в журнале сервера.'**
  String get whenCheckingAnAddressOrConnecting_ac269f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'При этой роли прошивка всегда сохраняет избранное.'**
  String get theFirmwareAlwaysPreservesFavoritesIn_0ef245;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Приблизить'**
  String get zoomIn_0c937d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Приложение подключено или автономное устройство обмена сообщениями.'**
  String get appConnectedOrStandaloneMessagingDevice_4df636;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Приложение продолжит работать в фоне: принимать сообщения и держать связь с нодой. Вернуть окно — значок в трее, выйти — «Выход» в его меню. Изменить это можно в настройках приложения.'**
  String get theApplicationWillKeepRunningIn_035e16;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Приходят, пока приложение запущено (в том числе в фоне). Звук и баннеры — в системных настройках уведомлений.'**
  String get deliveredWhileTheApplicationIsRunning_ef1ca3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пришёл ответ на трассировку'**
  String get tracerouteResponseReceived_2f2fbf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Проверить и включить'**
  String get checkAndEnable_38d621;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Проверить и применить'**
  String get checkAndApply_5b616e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Проверить обновления'**
  String get checkForUpdates_fa7bfc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Проверка дальности включена'**
  String get rangeTestEnabled_eed1b9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Проверьте широту, долготу и высоту'**
  String get checkLatitudeLongitudeAndAltitude_3d4bed;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Проверять при запуске'**
  String get checkOnStartup_6a3174;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Просмотренные тайлы без сети, очистка'**
  String get viewedMapTilesOfflineClearCache_5c907e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Прошивка ещё обновляется, но часть функций может быть недоступна.'**
  String get firmwareIsStillUpdatedButSome_3ef828;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Публикация на карте'**
  String get mapReporting_161284;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Работает без сети. Онлайн-подложка отключена.'**
  String get worksOfflineTheOnlineMapLayer_6371a8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Радио'**
  String get radio_e36f9c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Радио + Зеркало'**
  String get radioMirror_971a23;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Радиус'**
  String get radius_3dfacb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Размер карты не совпал'**
  String get mapSizeMismatch_1787b9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Разрешения и позиция телефона'**
  String get permissionsAndPhoneLocation_73702c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить передачу по LoRa-радио. Отключай при горячей замене антенн или стендовых испытаниях.'**
  String get allowTransmissionOverLoraRadioDisable_103bcc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Разрывов'**
  String get disconnects_775091;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Разрывов соединения'**
  String get connectionDrops_1da695;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Реакции на мои сообщения'**
  String get reactionsToMyMessages_3250d9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Реакции на твои сообщения.'**
  String get reactionsToYourMessages_2a4302;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Регион МСЭ 3 / Любительский 2 м'**
  String get ituRegionAmateurM_99c943;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Регион МСЭ 3 / Любительский 70 см'**
  String get ituRegionAmateurCm_7aef8d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Регулярно отправляет местоположение в виде сообщения в основной канал, чтобы помочь с восстановлением устройства.'**
  String get periodicallySendsTheLocationAsA_ea2b0e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Режим GPS (физическое оборудование)'**
  String get gpsModePhysicalHardware_11df68;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Режим IPv4'**
  String get ipvMode_ed8756;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Рельеф'**
  String get terrain_35f3e9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ретрансляции'**
  String get retransmissions_4ec216;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Рингтон и сохраненные сообщения'**
  String get ringtoneAndCannedMessages_9b84af;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Розовый'**
  String get pink_6e9cd3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Россия'**
  String get russia_3d9a48;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'С'**
  String get n_67bbe9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'С GitHub'**
  String get fromGithub_c134e1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'С сайта'**
  String get fromWebsite_225fd2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'СВ'**
  String get ne_29cd51;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'СЗ'**
  String get nw_9ecc3e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сборка'**
  String get build_930d47;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сбросить фильтры'**
  String get resetFilters_03ead0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сведения'**
  String get details_99bf04;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Свернуть в трей'**
  String get minimizeToTray_a1d8e8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Свернуть в трей?'**
  String get minimizeToTray_2b2ecc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Свет'**
  String get light_726f3e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сворачивать в трей при закрытии'**
  String get minimizeToTrayOnClose_720ae8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Своя нода'**
  String get ownNode_237648;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Своя нода: ID, модель, прошивка, роль, регион, пресет, число нод и каналов'**
  String get ownNodeIdModelFirmwareRole_2fdfaf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Связаться с разработчиком'**
  String get contactTheDeveloper_ca5284;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Связь'**
  String get connection_cbc0f9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Связь с нодой и уведомления продолжают работать. Выключено — крестик закрывает приложение.'**
  String get theNodeConnectionAndNotificationsKeep_155e05;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Связь с нодой пропала — похоже, она перезагружается и применяет настройки. После переподключения проверьте значения.'**
  String get theNodeDisconnectedItAppearsTo_25e160;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Север сверху'**
  String get northUp_be8de1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сервер rsyslog'**
  String get rsyslogServer_49feb1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сервер также может предлагать сервисы изображений и отчётов на других адресах. При обращении к ним их операторы тоже видят IP-адрес и запросы. При загрузке изображения передаются файл и ID ноды; при жалобе — ID ноды, ID изображения и причина жалобы. Состав диагностического отчёта показан отдельно перед отправкой.'**
  String get theServerMayAlsoOfferImage_a319bd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Серверы сообществ'**
  String get communityServers_917685;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сервис временно недоступен'**
  String get serviceTemporarilyUnavailable_3bd3fd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сервис картинок не отвечает — проверьте интернет'**
  String get theImageServiceIsNotResponding_3a7b0d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сервис не ответил вовремя'**
  String get theServiceDidNotRespondIn_cfe928;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сервис пока не знает вашу ноду: она должна появиться на карте зеркала'**
  String get theServiceDoesNotKnowYour_ca4501;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Серийный порт'**
  String get serialPort_7f0e67;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сингапур 923 МГц'**
  String get singaporeMhz_2b2999;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Синий'**
  String get blue_04954c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Система'**
  String get system_3ac98f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Система, светлая, тёмная или чёрная (OLED)'**
  String get systemLightDarkOrBlackOled_edaf2a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать QR'**
  String get scanQr_ba92dd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сканировать контакт'**
  String get scanContact_be9772;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скачать карту'**
  String get downloadMap_df5ad3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сколько баз хранить'**
  String get numberOfDatabasesToKeep_dd8856;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скопировано'**
  String get copied_892254;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать'**
  String get copy_ed4950;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать номер'**
  String get copyNumber_82ae50;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скопировать ссылку'**
  String get copyLink_a44800;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скорость COM-порта'**
  String get serialBaudRate_bbbfb6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скрывать ноды дальше радиуса'**
  String get hideNodesBeyondTheRadius_93e947;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скрывать сообщения, содержащие фильтры, в каждом канале и ЛС. Выключить для одного разговора — в его меню.'**
  String get hideMessagesMatchingFiltersInEvery_5d3016;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть ноды через MQTT'**
  String get hideNodesViaMqtt_a06257;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Следить'**
  String get monitor_a0b8fc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Слишком часто, попробуйте позже'**
  String get tooManyRequestsTryAgainLater_f13749;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Слово или regex:шаблон'**
  String get wordOrRegexPattern_d88d91;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Слои'**
  String get layers_16876c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Служба доменных имен (DNS)'**
  String get domainNameSystemDns_6275c5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Слышали'**
  String get lastHeard_07e526;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Слышно в эфире'**
  String get heardOverTheAir_d31ee9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Снято с поддержки'**
  String get noLongerSupported_e39ef3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'События соединения, пакеты и лог ноды'**
  String get connectionEventsPacketsAndNodeLog_745e44;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Соединение'**
  String get connection_0427c0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Соединение держится'**
  String get connectionDuration_c69bbf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Соединенные Штаты Америки'**
  String get unitedStatesOfAmerica_7fc1f6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сообщение от игнорируемой ноды — показать'**
  String get messageFromAnIgnoredNodeTap_0685fd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сообщений пока нет'**
  String get noMessagesYet_165664;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения игнорируемых нод — свёрнутыми, раскрываются нажатием. Выключено — их не видно совсем'**
  String get messagesFromIgnoredNodesAreCollapsed_379dd7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения скрытых каналов не загружаются из зеркала. Вернёте канал — его лента подгрузится снова.'**
  String get messagesFromHiddenChannelsAreNot_ae5ae7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения, содержащие эти слова, будут скрыты. Слово ищется целиком, без учёта регистра; regex:шаблон — регулярное выражение.'**
  String get messagesContainingTheseWordsWillBe_3bfbda;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сообщите этот номер разработчику — по нему он найдёт ваш отчёт.'**
  String get giveThisNumberToTheDeveloper_53370d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сопряжение Bluetooth в Linux'**
  String get bluetoothPairingOnLinux_5f59c4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сортировка'**
  String get sort_ed0301;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Состояние соединения: способ подключения (имя BLE или адрес ноды), попытки и разрывы'**
  String get connectionStatusTransportBleNameOr_ccaddd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранение на ноде'**
  String get savingToNode_283e94;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранено'**
  String get saved_f0dff5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохраните настройки: прокси подключится, когда клиент-прокси будет включён в ноде.'**
  String get saveTheSettingsTheProxyWill_d1d086;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить в файл'**
  String get saveToFile_cdda1c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить канал?'**
  String get saveChannel_cc1444;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить конфигурацию пользователя в %s?'**
  String get saveUserConfigurationToS_8e9bf5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки Bluetooth?'**
  String get saveBluetoothSettings_0dcf49;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки MQTT?'**
  String get saveMqttSettings_fd988d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки Store & Forward?'**
  String get saveStoreForwardSettings_bb7b6d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки TAK?'**
  String get saveTakSettings_a0c983;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки безопасности?'**
  String get saveSecuritySettings_a7801d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки внешних уведомлений?'**
  String get saveExternalNotificationSettings_96386a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки датчика обнаружения?'**
  String get saveDetectionSensorSettings_b580f0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки звука?'**
  String get saveAudioSettings_8ccb7e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки информации о соседях?'**
  String get saveNeighborInformationSettings_c94aec;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки окружающего освещения?'**
  String get saveAmbientLightingSettings_c54691;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки питания?'**
  String get savePowerSettings_0a3030;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки позиции?'**
  String get savePositionSettings_876ad7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки последовательного порта?'**
  String get saveSerialSettings_9fde53;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки сети?'**
  String get saveNetworkSettings_5ed6f6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки сохраненных сообщений?'**
  String get saveCannedMessageSettings_2594d4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки счетчика прохожих?'**
  String get savePaxCounterSettings_2cf0b9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки телеметрии?'**
  String get saveTelemetrySettings_35193a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки теста дальности?'**
  String get saveRangeTestSettings_284561;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки удаленного оборудования?'**
  String get saveRemoteHardwareSettings_bee1fe;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки управления движением?'**
  String get saveTrafficManagementSettings_22a20b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки устройства?'**
  String get saveDeviceSettings_be53bb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить настройки экрана?'**
  String get saveDisplaySettings_d04519;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сохранить файл'**
  String get saveFile_d10137;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка в отправленных сообщениях перестанет открываться.'**
  String get linksInSentMessagesWillStop_a4253e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка контакта'**
  String get contactLink_3b3d44;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка пуста'**
  String get theLinkIsEmpty_800d53;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка скопирована'**
  String get linkCopied_49261e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ссылка слишком длинная'**
  String get theLinkIsTooLong_75ef62;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Стоп'**
  String get stop_6d714e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Стратегия подключения Bluetooth'**
  String get bluetoothConnectionStrategy_56baed;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Строка определения часового пояса POSIX'**
  String get posixTimeZoneDefinition_87d573;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Т. росы'**
  String get dewPoint_2b7056;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Таиланд'**
  String get thailand_03ddbe;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Тайвань'**
  String get taiwan_2cc337;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Текст сообщений (в журнале — только размер)'**
  String get messageTextTheLogContainsOnly_d95f22;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Текущие настройки приложения и недавние подключения будут заменены данными из файла. Базы нод не изменятся.'**
  String get currentApplicationSettingsAndRecentConnections_ae2892;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'(зеркало)'**
  String get mirror_14fdf3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'125 кГц'**
  String get khz_872eb4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'203.125 кГц'**
  String get khz_501421;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'24Ч'**
  String get h_4c8c75;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'31 кГц'**
  String get khz_1ebb85;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'406.25 кГц'**
  String get khz_d95d4a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'500 кГц'**
  String get khz_ac5e55;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'62 кГц'**
  String get khz_91b5e4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'7Д'**
  String get d_3ecbe0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'812.5 кГц'**
  String get khz_56b83b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'<MAC ноды>'**
  String get nodeMac_49269c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Bluetooth включен'**
  String get bluetoothEnabled_3469b5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Bluetooth и локальная сеть используются для подключения к нодам, камера — для сканирования QR-кодов. Уведомления сообщают о событиях приложения. Геопозиция используется при выборе позиции телефона и при включённой передаче позиции своей ноде. Передача выключена по умолчанию. Прошивка ноды может дальше распространять координаты по своим настройкам. Разрешения можно изменить в настройках операционной системы.'**
  String get bluetoothAndTheLocalNetworkConnect_2e6ed6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'CODEC 2 включен'**
  String get codecEnabled_8e6ef2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'COM-порт включен'**
  String get serialPortEnabled_c878e2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ethernet включен'**
  String get ethernetEnabled_7440bf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'GPIO-вывод для ШИМ-зуммера'**
  String get gpioPinForThePwmBuzzer_ac885c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'GPIO-вывод для пользовательской кнопки; можно переназначить на платах с несколькими кнопками'**
  String get gpioPinForTheUserButton_a5b887;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'ID в зеркале'**
  String get mirrorId_9b8cbe;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'ID пакета'**
  String get packetId_869cfb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'ID пакета (hex)'**
  String get packetIdHex_7d2120;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'ID совпадает с MAC-адресом ноды — исправлять нечего.'**
  String get theIdMatchesTheNodeMac_ca22a6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'IP или хост ноды'**
  String get nodeIpOrHostname_4e0881;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'JSON-файл содержит незашифрованный приватный ключ ноды. Любой, у кого есть этот файл, сможет использовать ключ вашей ноды. Храните файл в защищённом месте и не передавайте посторонним.'**
  String get theJsonFileContainsTheUnencrypted_470e15;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Linux-устройство, поддерживается сообществом.'**
  String get communitySupportedLinuxDevice_372e0a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MAC и device_id подключённой ноды'**
  String get macAndDeviceIdOfThe_018be2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MAC не от этой ноды'**
  String get thisMacBelongsToADifferent_c8f6b3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MAC своей ноды неизвестен'**
  String get yourNodeMacIsUnknown_80e80c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MQTT включен'**
  String get mqttEnabled_47dd00;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Meshex — клиент для радионод Meshtastic. Приложение хранит на устройстве сообщения, сведения о нодах и их позициях, настройки, конфигурацию подключённых нод и диагностический журнал. Очистка данных в настройках приложения действует на локальные данные, а не на радиоэфир и сторонние серверы.'**
  String get meshexIsAClientForMeshtastic_b9497b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'NTP-сервер'**
  String get ntpServer_0f61dc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'NodeInfo отправлена'**
  String get nodeinfoSent_16d722;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'NodeInfo отправлена в сеть'**
  String get nodeinfoBroadcast_f42668;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'PA вентилятор выключен'**
  String get paFanDisabled_a9c1ad;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Store & Forward включена'**
  String get storeForwardEnabled_a01444;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Telegram, почта — если нужен ответ'**
  String get telegramOrEmailIfYouWould_8f673d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Wi-Fi включен'**
  String get wiFiEnabled_c884a7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'from_num должен идти раньше to_num'**
  String get fromNumMustPrecedeToNum_be1e5b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'· вероятно, подменённая точка'**
  String get possiblySpoofedPosition_5ca05b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'· скорректировано'**
  String get corrected_a0b938;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Авто, книжная, альбомная, перевёрнутые'**
  String get automaticPortraitLandscapeReversedOrientations_3e0120;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Автоматически переключает на следующую страницу на экране как карусель, основываясь на заданном интервале.'**
  String get automaticallyCyclesThroughDisplayPagesAt_13281c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Админ-доступ и флаги (ключи ноды сохранятся)'**
  String get adminAccessAndFlagsNodeKeys_502b16;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Адрес MQTT-сервера'**
  String get mqttServerAddress_615ec8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Адрес и данные зеркала'**
  String get mirrorAddressAndData_e46280;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Адрес сервера зеркала: с него приходят чат и ноды из MQTT. Пока зеркало выключено, приложение не подключается к нему. Проверка адреса тоже отправляет запрос на указанный сервер.'**
  String get mirrorServerAddressChatMessagesAnd_64453e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Альбомная'**
  String get landscape_53bf5f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Альбомная перевёрнутая'**
  String get landscapeReversed_089eb6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Аппаратные id ноды'**
  String get nodeHardwareIds_a78041;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'База приложения'**
  String get applicationDatabase_4d6431;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'База сохранена'**
  String get databaseSaved_190541;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Базы нод'**
  String get nodeDatabases_1e2d9d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Без ноды (только зеркало)'**
  String get noNodeMirrorOnly_7434e1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Без подсветки'**
  String get noHighlight_14736b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Без шифрования'**
  String get unencrypted_74bae3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Безопасность меняет ключи и админ-доступ ноды — включайте, только если это копия этой же ноды.'**
  String get securityChangesNodeKeysAndAdmin_a52c58;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Бирюзовый'**
  String get teal_9161f9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В'**
  String get v_b25cd7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В QR-коде были найдены следующие каналы. Существующие каналы будут сохранены.'**
  String get theFollowingChannelsWereFoundIn_c3f485;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В списке и на карте. Ноды без координат и своя нода не скрываются.'**
  String get appliesToTheNodeListAnd_f9af88;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В ссылке больше 8 каналов'**
  String get theLinkContainsMoreThanChannels_158006;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В ссылке нет данных каналов'**
  String get theLinkHasNoChannelData_a0a60d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В ссылке нет каналов'**
  String get theLinkContainsNoChannels_a613c7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В ссылке нет настроек LoRa — каналы можно только добавить'**
  String get theLinkHasNoLoraSettings_2b6cd1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В файле будут адреса ваших нод и зеркала. Храните его у себя и никому не передавайте.'**
  String get theFileWillContainYourNode_2c8772;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В файле будут ключи ноды, ключи каналов и пароли Wi-Fi/MQTT. Не передавайте его посторонним.'**
  String get theFileWillContainNodeKeys_7a17b9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В файле нет данных ноды'**
  String get theFileContainsNoNodeData_fba6b0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В файле нет ключей'**
  String get theFileContainsNoKeys_274a37;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В файле нет настроек'**
  String get theFileContainsNoSettings_6865dd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В файле нет настроек приложения'**
  String get theFileContainsNoApplicationSettings_276e18;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ваш комментарий и контакт, если укажете'**
  String get yourCommentAndContactDetailsIf_7eb17d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Введите хотя бы 2 символа'**
  String get enterAtLeastCharacters_ffcd3a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вернуть'**
  String get restore_c7aaa9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Версия ОС'**
  String get osVersion_8aba4a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Версия приложения устарела — обновите его'**
  String get yourApplicationVersionIsOutdatedPlease_d5ccc4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Версия приложения, модель телефона, версия ОС, язык и часовой пояс'**
  String get applicationVersionPhoneModelOsVersion_3c056a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вибрация при уведомлении'**
  String get vibrateOnNotification_d0009e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вид строки ноды'**
  String get nodeRowLayout_12026b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Видна только вам'**
  String get visibleOnlyToYou_e71a47;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включает автоматические трансляции TAK PLI и сокращает рутинные трансляции.'**
  String get enablesAutomaticTakPliBroadcastsAnd_e4e185;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включив эту функцию, вы подтверждаете и даете явное согласие на передачу данных о географическом местоположении вашего устройства в режиме реального времени по протоколу MQTT без шифрования. Эти данные о местоположении могут использоваться для таких целей, как создание отчетов по карте в режиме реального времени, отслеживание устройства и связанные с этим функции телеметрии.\n\nИмейте в виду, что поскольку отчет карты не зашифрован, ваши данные могут быть постоянно сохранены и отображены третьими сторонами. Meshtastic не несет ответственности за такое хранение, отображение или раскрытие этих данных.\n\nЯ прочитал и понимаю вышеизложенное. Я добровольно даю согласие на незашифрованную передачу данных моей ноды через MQTT.'**
  String get byEnablingThisFeatureYouAcknowledge_de04ee;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включить Bluetooth на устройстве'**
  String get enableBluetoothOnThisDevice_392fce;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включить MQTT-шлюз'**
  String get enableMqttGateway_540669;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Включить кодирование/декодирование звука Codec2 для голосовой связи по mesh-сети.'**
  String get enableCodecAudioEncodingDecodingFor_7f4387;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Владелец'**
  String get owner_926e3b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Внешнее питание'**
  String get externalPower_684553;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Внешние уведомления включены'**
  String get externalNotificationsEnabled_06341b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вниз, всё прочитано'**
  String get scrollDownAllMessagesRead_292955;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вопросы, сообщения об ошибках и обращения о конфиденциальности можно оставить в Issues проекта Meshex. Для создания обращения нужен аккаунт GitHub. Обращения могут быть публичными: не публикуйте приватные ключи, пароли, точные координаты и другие личные сведения. По вопросам содержимого и удаления данных на сервере сообщества обращайтесь к его оператору.'**
  String get questionsBugReportsAndPrivacyRequests_5ebcd5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вращение карты'**
  String get mapRotation_8a6270;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Все сообщения этого чата удалятся с этого устройства. У собеседника они останутся.'**
  String get allMessagesInThisChatWill_6baa0a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Все функции, активная разработка.'**
  String get allFeaturesUnderActiveDevelopment_ce30a3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Всегда включен'**
  String get alwaysOn_43ba2d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Всё равно отправить'**
  String get sendAnyway_c6bcaa;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вы сами выбираете сервер. Его оператор управляет содержимым, доступностью и хранением данных; клиент не управляет этим сервером. Подключайтесь к операторам, которым доверяете.'**
  String get youChooseTheServerItsOperator_f140c4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выбери ключ для восстановления'**
  String get chooseAKeyToRestore_9fa859;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выберите канал или диалог'**
  String get selectAChannelOrConversation_3b7ddb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выбрать файл'**
  String get chooseFile_2e31da;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выйти'**
  String get quit_026abb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Выключено'**
  String get disabled_d934ae;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Высота, м'**
  String get altitudeM_4e463b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Газ'**
  String get gas_5d1111;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Геолокация выключена в системе'**
  String get locationServicesAreDisabled_34928e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Группировать ноды'**
  String get clusterNodes_d1274e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Дальние ноды'**
  String get distantNodes_c51034;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Данные'**
  String get data_d8e5fd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Данные на устройстве'**
  String get dataOnThisDevice_2ff795;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Датчик определения включен'**
  String get detectionSensorEnabled_1b4f0e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Диагностические отчёты'**
  String get diagnosticReports_1eec79;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Длина пин-кода BLE должна быть 6 цифр.'**
  String get theBlePinMustContainDigits_d88065;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Длительность ожидания Bluetooth'**
  String get bluetoothWaitTime_de4a08;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Для нод без GPS: координаты телефона уходят только своей ноде, в сеть их рассылает прошивка по своим настройкам. Работает, пока приложение открыто и подключено.'**
  String get forNodesWithoutGpsPhoneCoordinates_e96e7e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Для ограничения скорости задайте и окно, и число пакетов.'**
  String get setBothTheTimeWindowAnd_7dff47;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Для очистки локальной базы используйте раздел «Данные», для удаления сохранённой копии ключа — раздел «Безопасность». Отдельно управляйте файлами экспорта и резервными копиями операционной системы. Удаление локальных данных не отзывает радиопакеты и не удаляет данные у других участников сети. Вопросы о работе приложения и обработке данных можно направить через контакт ниже.'**
  String get useDataToClearTheLocal_2715b2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Добавить заметку'**
  String get addNote_57d0f4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Добавлено в избранное'**
  String get addedToFavorites_d0d718;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Дождь'**
  String get rain_aad03f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Дождь 1ч'**
  String get rainH_770fb0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Дождь 24ч'**
  String get rainH_b2fa03;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Доставлено'**
  String get delivered_9b68fb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Доставлено, подтверждено получателем'**
  String get deliveredVerifiedByTheRecipient_0d8f81;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Другие эмодзи'**
  String get moreEmoji_2bfd6b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Его сообщения из зеркала удалятся и больше не будут загружаться. Вернуть канал можно в настройках зеркала.'**
  String get itsMirrorMessagesWillBeDeleted_d9e39c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Единицы измерения, отображаемые на экране устройства.'**
  String get measurementUnitsShownOnTheDevice_573c1c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Если после перезагрузки телефон не подключается к ноде, перезагрузите её ещё раз.'**
  String get ifYourPhoneCannotConnectAfter_9fa7f4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Есть координаты'**
  String get hasCoordinates_4d4419;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Есть публичный ключ'**
  String get hasPublicKey_dd027c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Есть публичный ключ (PKI)'**
  String get hasPublicKeyPki_b08915;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба отправлена'**
  String get reportSent_050a2d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба уйдёт оператору сервера'**
  String get theReportWillBeSentTo_5e4e2b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ждём координаты'**
  String get waitingForCoordinates_8cafb9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ждём подключения к ноде'**
  String get waitingForANodeConnection_617dba;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Журнал'**
  String get journal_67ade7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Журнал для отчёта'**
  String get reportLog_c75086;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Журнал и сведения о приложении и ноде'**
  String get applicationAndNodeLogsAndDetails_395cd3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Журнал приложения за последние запуски: события соединения, служебные пакеты, лог прошивки ноды, ошибки. В журнале есть ID и имена нод из эфира'**
  String get applicationLogFromRecentLaunchesConnection_a484f1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Журнал скопирован'**
  String get journalCopied_1ee14a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'З'**
  String get w_a9d7eb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'За пределами скачанной карты Петербурга'**
  String get outsideTheDownloadedSaintPetersburgMap_24a118;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Забыть'**
  String get forget_90bc7d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить ещё'**
  String get loadMore_010963;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Загрузить из файла'**
  String get loadFromFile_e47fd3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка картинок для вас заблокирована'**
  String get imageUploadsAreBlockedForYour_4267f6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка отменена'**
  String get downloadCanceled_13f622;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Загрузка эфира'**
  String get radioTrafficUpload_cd86b2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Задает максимальное количество прыжков, по умолчанию - 3. Увеличение количества также увеличивает перегрузку и должно использоваться с осторожностью. Сообщения с 0 прыжков не будут получать подтверждения.'**
  String get maximumHopCountByDefaultHigher_c79f9b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Закрытый ключ'**
  String get privateKey_378280;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Заменить базу?'**
  String get replaceDatabase_1a5ae6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Замеров по радио пока нет'**
  String get noRadioMeasurementsYet_45e333;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Заметка'**
  String get note_917b58;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Записать'**
  String get write_4be730;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Записать конфигурацию из файла в ноду'**
  String get writeConfigurationFromAFileTo_5b4b13;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Запрос отправлен — ждём ответ'**
  String get requestSentWaitingForAResponse_8172e2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Запросить'**
  String get request_ebdfd9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Запросить телеметрию'**
  String get requestTelemetry_c5374e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Заряд'**
  String get charge_b1ad91;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Зашифрован'**
  String get encrypted_9cdd75;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Здесь появятся ноды, к которым вы подключались'**
  String get nodesYouHaveConnectedToWill_436ad0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Зеленый'**
  String get green_6989f8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Зелёный'**
  String get green_a0f667;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Зеркало'**
  String get mirror_66ace6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Зеркало: зоны глушилок не загружены'**
  String get mirrorInterferenceZonesCouldNotBe_7b5b5d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Зеркало: ноды не загружены'**
  String get mirrorNodesCouldNotBeLoaded_41ed72;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Идентификатор'**
  String get identifier_754cba;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Идёт поиск в сети…'**
  String get searchingTheNetwork_bdab2d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Идёт поиск нод…'**
  String get searchingForNodes_ba19cf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Из зеркала'**
  String get fromMirror_f5296f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Избранные и игнорируемые ноды всегда сохраняются. Другие ноды удаляются из базы данных приложения через заданное число дней. (Ноды с ключами PKC всегда сохраняются не менее 7 дней.) Удаляются только ноды, которых нет в базе нод устройства; своя нода и ноды с заметкой тоже сохраняются.'**
  String get favoriteAndIgnoredNodesAreAlways_f2c698;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Изображения и жалобы'**
  String get imagesAndReports_a79f68;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Имена каналов в ссылке повторяются'**
  String get theLinkContainsDuplicateChannelNames_3b33c1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Импорт базы из файла'**
  String get importDatabaseFromFile_81e7f3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Импорт базы ноды из файла'**
  String get importNodeDatabaseFromFile_7ff7a5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Импорт из файла'**
  String get importFromFile_f190b3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Имя датчика для сообщений mesh-сети'**
  String get sensorNameForMeshMessages_40e05a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Имя или !id'**
  String get nameOrId_ffe28b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Имя или id ноды'**
  String get nodeNameOrId_ee4d66;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Индиго'**
  String get indigo_03aba6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Интервал вещания передачи информации об узле'**
  String get nodeInformationBroadcastInterval_0a98b2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Интервал обновления данных качества воздуха'**
  String get airQualityUpdateInterval_008585;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Интервал обновления метрик среды'**
  String get environmentMetricsUpdateInterval_5d18f2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Интервал обновления метрик устройства'**
  String get deviceMetricsUpdateInterval_d890da;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Интервал обновления метрик электропитания'**
  String get powerMetricsUpdateInterval_d4bac6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Интервал передачи состояния'**
  String get stateBroadcastInterval_bec9d7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Интервал повтора'**
  String get repeatInterval_51be08;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Интервал публикации на карте'**
  String get mapReportInterval_bee95f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Информация о соседях'**
  String get neighborInformation_2b7dad;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Информация о соседях включена'**
  String get neighborInformationEnabled_c25a9a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Инфраструктурная нода, которая всегда ретранслирует пакеты один раз, но только после всех остальных режимов. Отображается в списке нод. Не лучший выбор для нод на крышах.'**
  String get infrastructureNodeThatAlwaysRetransmitsPackets_704f22;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Искать'**
  String get search_58212e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Использовать настройки пресета модема вместо ручного указания полосы пропускания, коэффициента расширения и скорости кодирования'**
  String get useTheModemPresetInsteadOf_941abf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Использовать скачанную карту'**
  String get useDownloadedMap_9e8629;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Используемая скорость передачи Codec2. Частота дискретизации всегда 8 кГц. Более низкие скорости используют меньше полосы пропускания, но снижают качество звука.'**
  String get codecBitrateTheSampleRateIs_1a0df2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Исправить'**
  String get repair_9b1c9a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Исправить ID ноды'**
  String get repairNodeId_47d759;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Исправить ID ноды?'**
  String get repairNodeId_16de55;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Исправить и перезагрузить'**
  String get repairAndRestart_0ef1ee;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Исправлено: ноде отправлен её MAC'**
  String get repairedTheNodeMacWasSent_4c3760;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Источник'**
  String get source_8290a3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Казахстан 433 МГц'**
  String get kazakhstanMhz_c0f5fd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Казахстан 863 МГц'**
  String get kazakhstanMhz_26f59e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Как часто запрашивать координаты GPS (<10 секунд держит GPS включенным постоянно).'**
  String get howOftenToRequestGpsCoordinates_8f0f04;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Канал будет отключен на ноде.'**
  String get theChannelWillBeDisabledOn_3cb75d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Канал есть только в зеркале — писать в него нельзя.'**
  String get thisChannelExistsOnlyInThe_30433a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Каналов'**
  String get channels_5488bf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Каналы будут добавлены на ноду.'**
  String get channelsWillBeAddedToThe_32e8d4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Каналы будут добавлены; существующие каналы и настройки LoRa сохранятся.'**
  String get channelsWillBeAddedExistingChannels_dfb994;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Каналы и LoRa'**
  String get channelsAndLora_147acf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Каналы и настройки LoRa на ноде будут заменены.'**
  String get channelsAndLoraSettingsOnThe_31a15a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Каналы появятся после подключения к ноде.'**
  String get channelsWillAppearAfterConnectingTo_e7a062;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Каналы сохранены'**
  String get channelsSaved_dbb2d3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Карта'**
  String get map_5736d0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Картинка'**
  String get image_690092;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Картинка загружена, хранится 3 дня'**
  String get imageUploadedStoredForDays_144c69;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Картинка недоступна\n(удалена или истёк срок)'**
  String get imageUnavailableDeletedOrExpired_82b7c1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Картинка слишком большая'**
  String get theImageIsTooLarge_94ad38;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Картинка удалена'**
  String get imageDeleted_e4b164;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Картинки уже нет'**
  String get theImageIsAlreadyGone_910faf;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Карты и проверка обновлений'**
  String get mapsAndUpdateChecks_f48d47;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ключ восстановлен — сохраните настройки'**
  String get keyRestoredSaveTheSettings_92bb30;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ключ не соответствует выбранному размеру'**
  String get theKeyDoesNotMatchThe_4c6326;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ключ скопирован'**
  String get keyCopied_c184c1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ключ — 32 байта в base64'**
  String get theKeyMustBeBytesEncoded_04f2cd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ключи и резервные копии'**
  String get keysAndBackups_9b106e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ключи ноды и админ-доступ'**
  String get nodeKeysAndAdminAccess_7b222d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ключи сохранены в файл. Храните его в надёжном месте'**
  String get keysSavedToAFileKeep_32f5b4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ключи шифрования, PSK и названия каналов'**
  String get encryptionKeysPsksAndChannelNames_cfa888;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Книжная'**
  String get portrait_79fe4f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Книжная перевёрнутая'**
  String get portraitReversed_674692;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Количество прыжков'**
  String get hopCount_6d7f43;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Количество чирпов на символ — 2 в степени этого значения.'**
  String get chirpsPerSymbolRaisedToThis_f60898;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Команда отправлена'**
  String get commandSent_d331b9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Контакт (необязательно)'**
  String get contactOptional_309ca4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Контакт PTT'**
  String get pttPin_3c56da;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Контакт импортирован'**
  String get contactImported_0f4d2f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Контакт проекта'**
  String get projectContact_9535fa;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Контрольная сумма карты не совпала'**
  String get mapChecksumMismatch_da850d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Конфигурация ноды может содержать приватные ключи и пароли. Отдельные резервные копии ключей сохраняются в системном защищённом хранилище; на iOS используется синхронизируемая связка ключей iCloud. Экспортированный JSON содержит незашифрованный приватный ключ. Файл настроек также может содержать ключи и пароли. Выбранное вами место сохранения может быть облачным. Удаляйте экспортированные файлы и резервные копии отдельно, когда они больше не нужны.'**
  String get nodeConfigurationsMayContainPrivateKeys_b72311;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Координаты скопированы'**
  String get coordinatesCopied_082ae9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Координаты — ни телефона, ни нод'**
  String get coordinatesOfEitherThePhoneOr_6668dd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Копировать текст'**
  String get copyText_667f44;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Корея'**
  String get korea_522d28;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Короткое имя своей ноды в тексте канала'**
  String get yourNodeShortNameInChannel_7ab080;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Корректировка позиций'**
  String get positionCorrection_e7d3bd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Красный'**
  String get red_1686b6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Кэш карты'**
  String get mapCache_fc6703;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Лицензии'**
  String get licenses_488dd1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Личные'**
  String get directMessages_96a4a7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'МГц'**
  String get mhz_b6fe8f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'МОм'**
  String get m_1ac436;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Максимальное время между передачами позиции нодой.'**
  String get maximumTimeBetweenNodePositionBroadcasts_118530;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Малайзия 433 МГц'**
  String get malaysiaMhz_8949b1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Малайзия 919 МГц'**
  String get malaysiaMhz_2a5dd6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Маршрут'**
  String get route_b765f3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Маршрут обратно'**
  String get returnRoute_9e78e2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Минимальное время между передачами обнаружения'**
  String get minimumTimeBetweenDetectionBroadcasts_e6291c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Минимальное время между передачами обнаружения.'**
  String get minimumTimeBetweenDetectionBroadcasts_ef8eba;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Минимальное расстояние для умной рассылки координаты.'**
  String get minimumDistanceForSmartPositionBroadcasting_c4fdb9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Модель'**
  String get model_f1f1ee;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Модель устройства'**
  String get deviceModel_6b816f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Модуль измерения качества воздуха включен'**
  String get airQualityModuleEnabled_341f24;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Модуль метрик питания включен'**
  String get powerMetricsModuleEnabled_74b93b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Мощность передатчика'**
  String get transmitPower_a90731;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Мощность передачи радио. Оставь ноль, чтобы использовать максимально допустимый уровень для региона — именно так следует поступать большинству радиоустройств.'**
  String get radioTransmitPowerLeaveZeroTo_bdb039;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Моя нода'**
  String get myNode_933f3d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Моё местоположение'**
  String get myLocation_e77573;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Моё местоположение (обновить)'**
  String get myLocationRefresh_d26be2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'На iPhone с Face ID не поддерживается'**
  String get notSupportedOnIphonesWithFace_7d312d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'На связи'**
  String get connected_1578f2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Название'**
  String get name_3de498;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Найти ноды в локальной сети'**
  String get findNodesOnTheLocalNetwork_9f4117;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Найти ноды поблизости'**
  String get findNearbyNodes_37deaa;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Написать'**
  String get message_bda589;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Напр.'**
  String get voltage_5b3602;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Направление компаса'**
  String get compassHeading_c9f066;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки записаны, нода перезагрузится'**
  String get settingsWrittenTheNodeWillRestart_ce3279;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки приложения и недавние подключения — например, чтобы вернуть их после переустановки. В файле адреса ваших нод и зеркала: никому его не передавайте.'**
  String get applicationSettingsAndRecentConnectionsFor_cab177;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки сохранены'**
  String get settingsSaved_0c3942;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки управления движением в этом приложении — по схеме прошивки 2.8. Обновите прошивку ноды.'**
  String get trafficManagementSettingsInThisApplication_691b03;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Начало редактирования'**
  String get beginEditing_cfa550;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не зашифровано'**
  String get notEncrypted_c40021;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не найдено среди нод на карте'**
  String get notFoundAmongNodesOnThe_ec3654;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не напоминать'**
  String get doNotRemindMe_7319fc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не отправлено'**
  String get notSent_304893;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть скачанную карту.'**
  String get couldNotOpenTheDownloadedMap_be745e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть страницу поддержки'**
  String get couldNotOpenTheSupportPage_eb8159;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить ключ из зеркала'**
  String get couldNotRetrieveTheKeyFrom_693021;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось проверить офлайн-карту'**
  String get couldNotVerifyTheOfflineMap_f0dd0f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось прочитать данные каналов'**
  String get couldNotReadChannelData_1a56bc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось прочитать настройки карты'**
  String get couldNotReadMapSettings_9d3bfa;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось скачать карту. Проверьте сеть и повторите.'**
  String get couldNotDownloadTheMapCheck_07b3ae;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не чаще чем раз в'**
  String get noMoreOftenThanEvery_3389cd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Неверное время на устройстве'**
  String get incorrectDeviceTime_bcddb3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Неверное регулярное выражение'**
  String get invalidRegularExpression_d0b364;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Неверные данные каналов в ссылке'**
  String get invalidChannelDataInTheLink_d0da40;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Неверный адрес'**
  String get invalidAddress_e5fb1c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Неверный адрес IPv4'**
  String get invalidIpvAddress_c9875b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Недавние'**
  String get recent_1328d8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Непал 865 МГц'**
  String get nepalMhz_73462a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нет доступа к геолокации — разрешите в настройках системы'**
  String get locationAccessDeniedAllowItIn_fa90c3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нет замеров за этот период'**
  String get noMeasurementsForThisPeriod_c02810;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нет ключа ноды — подключитесь к своей ноде'**
  String get noNodeKeyConnectToYour_7e5d9a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нет ключа — не зашифровано'**
  String get noKeyNotEncrypted_1c5fa9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нет нод с координатами.\nЭто нормально: начиная с прошивки 2.8 отправка позиции по умолчанию выключена.'**
  String get noNodesWithCoordinatesThisIs_34558f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нет подтверждения'**
  String get noAcknowledgment_f9cd9b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нет публичного ключа'**
  String get noPublicKey_fc72da;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нет публичного ключа ноды — дождитесь NodeInfo или повторите загрузку из зеркала в карточке ноды.'**
  String get noNodePublicKeyWaitFor_f9fbc4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нет соединения с нодой'**
  String get noNodeConnection_8ce75b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нет файла базы'**
  String get noDatabaseFile_c7a185;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ни у одной ноды маршрута нет координат'**
  String get noneOfTheNodesOnThis_79590a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Никогда'**
  String get never_f5bf59;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нишевое устройство'**
  String get specializedDevice_be7b26;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Новая Зеландия 865 МГц'**
  String get newZealandMhz_66ff01;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Новые сообщения'**
  String get newMessages_f8bbc3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нод в базе'**
  String get nodesInDatabase_b7f028;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нод в эфире'**
  String get nodesOnRadio_f76516;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нод пока нет.\nПодключитесь к своей ноде.'**
  String get noNodesYetConnectToYour_c2e63b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода больше не игнорируется'**
  String get nodeNoLongerIgnored_c2b973;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода будет удалена из базы своей ноды. Она снова появится, когда её услышат.'**
  String get theNodeWillBeRemovedFrom_e0fd0d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода будет удалена из приложения. Она снова появится, когда её услышат.'**
  String get theNodeWillBeRemovedFrom_0c5eb5;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода ещё не передала свои данные в сеть — подождите и попробуйте позже'**
  String get theNodeHasNotBroadcastIts_198664;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода ещё не прислала свои данные — подождите окончания загрузки.'**
  String get theNodeHasNotSentIts_58663f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода ещё не прислала эти настройки'**
  String get theNodeHasNotSentThese_0e8dcb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода игнорируется'**
  String get nodeIgnored_cdfc8a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода использует регион, который приложение не поддерживает. Выберите поддерживаемый регион перед сохранением.'**
  String get theNodeUsesARegionUnsupported_213978;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода не найдена'**
  String get nodeNotFound_9951e4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода не подтвердила'**
  String get notAcknowledgedByTheNode_90929d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода не подтвердила импорт ключа получателя'**
  String get theNodeDidNotAcknowledgeImporting_65bf83;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода не подтвердила команду'**
  String get theNodeDidNotAcknowledgeThe_e56f57;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода не подтвердила сохранение'**
  String get theNodeDidNotAcknowledgeSaving_e14f06;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода не принимает личные сообщения.'**
  String get thisNodeDoesNotAcceptDirect_338e6e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода ответит текущими значениями'**
  String get theNodeWillRespondWithIts_ab01ac;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода перезагружается. После подключения имя вернётся само.'**
  String get theNodeIsRestartingItsName_f432c3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода сбросит сохранённое состояние и перезагрузится. Ключ шифрования и настройки останутся.'**
  String get theNodeWillClearItsSaved_7eed33;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода сохранила у себя нулевой MAC-адрес — из-за ошибки кнопки «Отправить NodeInfo» в Meshex 0.1.7–0.1.10. ID на этой прошивке считается из ключа и не сменится, но MAC стоит вернуть.\n\nИсправление отправит ноде её настоящий MAC. Перезагрузка не нужна, ничего не потеряется.'**
  String get theNodeSavedAZeroMac_630708;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода удалена'**
  String get nodeDeleted_bd0760;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Номер'**
  String get number_1bb3d1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Номер отчёта'**
  String get reportNumber_a2f60b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Номер скопирован'**
  String get numberCopied_875e81;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нужны базы двух нод'**
  String get twoNodeDatabasesAreRequired_0e6b9d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Обменяться NodeInfo'**
  String get exchangeNodeinfo_e2f5f6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Образец цвета'**
  String get colorPreview_dfa12d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Обращения ко мне'**
  String get mentionsAndReplies_209ee7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Обслуживание'**
  String get maintenance_3c5bdd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ожидание'**
  String get waiting_5813a9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Окно'**
  String get window_f5988f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Оптимизировано для связи с системой ATAK, сокращает текущие передачи.'**
  String get optimizedForAtakCommunicationReducesRoutine_27d642;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Оранжевый'**
  String get orange_6494ce;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ориентация экрана'**
  String get screenOrientation_87b383;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'От своей ноды'**
  String get fromMyNode_336438;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ответ на сообщение'**
  String get replyToMessage_4e6ac3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ответы и упоминания'**
  String get repliesAndMentions_f0aae9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ответы на мои сообщения'**
  String get repliesToMyMessages_2fca62;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ответы на отправленные трассировки.'**
  String get responsesToOutgoingTraceroutes_dea22a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ответы на твои сообщения и упоминания в каналах.'**
  String get repliesToYourMessagesAndMentions_953527;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отдалить'**
  String get zoomOut_fea897;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отключает горячую клавишу тройного нажатия пользовательской кнопки.'**
  String get disablesTheUserButtonTripleClick_9664f8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отключить'**
  String get disconnect_94d07a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отключить тройное нажатие кнопки'**
  String get disableTripleClickShortcut_0ac4dd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Открытую базу удалить нельзя'**
  String get cannotDeleteTheCurrentlyOpenDatabase_023546;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Открыть'**
  String get open_125957;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Открыть в Картах'**
  String get openInMaps_6bb0f2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Открыть поддержку на GitHub'**
  String get openGithubSupport_603c75;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отменить загрузку'**
  String get cancelDownload_136bdc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправитель'**
  String get sender_522b04;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправить Nodeinfo'**
  String get sendNodeinfo_79376f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправить в Services'**
  String get sendToServices_7ae0e3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправить ещё раз'**
  String get sendAgain_625609;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправить отчёт'**
  String get sendReport_63b6fb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправить отчёт разработчику'**
  String get sendReportToTheDeveloper_d46fe6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправить пинг в Services?'**
  String get sendAPingToServices_afe5a4;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправить позицию'**
  String get sendPosition_1a3631;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправлено в эфир'**
  String get sentOverTheAir_740ec0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправляется'**
  String get sending_5f0935;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправлять зашифрованные пакеты в MQTT'**
  String get forwardEncryptedPacketsToMqtt_53e004;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отсканируйте в Meshtastic, чтобы добавить контакт'**
  String get scanInMeshtasticToAddThis_e46939;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отчёт отправлен'**
  String get reportSent_4eb02c;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отчёт отправляется по вашему действию сервису, объявленному подключённым зеркалом. Перед отправкой можно посмотреть состав отчёта и журнал. Отчёт включает сведения о приложении, системе, ноде и соединении, а также ваш комментарий и контакт, если вы их указали. Не включайте секреты и личные сведения в комментарий. Для удаления отправленного отчёта обратитесь к оператору сервиса и укажите номер отчёта.'**
  String get reportsAreSentAtYourRequest_7fcca2;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отчёты отправляются через подключённый сервер, а он их не принимает или не подключён.'**
  String get reportsAreSentThroughTheConnected_ceda96;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн · © OpenStreetMap contributors'**
  String get offlineOpenstreetmapContributors_76e794;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн-карта'**
  String get offlineMap_c6b2c6;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн-карта · около 100 км · 194 МБ\nДанные от 29.10.2026'**
  String get offlineMapAboutKmMbData_433acc;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн-карта включена'**
  String get offlineMapEnabled_4908b7;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Офлайн-карта…'**
  String get offlineMap_7c2718;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Оформление'**
  String get appearance_d206f1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пакетов получено'**
  String get packetsReceived_83d955;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Передавать позицию своей ноде'**
  String get sharePositionWithMyNode_acf46e;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Передать через LoRa'**
  String get broadcastOverLora_d52575;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Перезагрузок'**
  String get restarts_05fe86;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Перенести'**
  String get transfer_081b1d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Перенести в открытую базу'**
  String get transferToTheOpenDatabase_8042a9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Перенести сообщения?'**
  String get transferMessages_f1f159;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Переопределить рабочий цикл'**
  String get overrideDutyCycle_e5b06b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Переподключить'**
  String get reconnect_91c240;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пересоздать'**
  String get regenerate_9bf881;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Перетащите метку или введите координаты'**
  String get dragTheMarkerOrEnterCoordinates_1127fb;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Период рассылки'**
  String get broadcastInterval_5acd28;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Петербург и окрестности'**
  String get saintPetersburgAndSurroundings_6bc6a9;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Платформа'**
  String get platform_89009f;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'По теме приложения'**
  String get followApplicationTheme_6d6cea;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} м'**
  String m_a6990d(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} км'**
  String km_f1c739(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Трей недоступен: {arg0}'**
  String trayUnavailable_046650(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Трей: {arg0}'**
  String tray_2a443c(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Картинка больше {arg0} МБ'**
  String imageExceedsMb_0b3767(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Зеркало: {arg0}'**
  String mirror_871d44(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Базы нод: {arg0}'**
  String nodeDatabases_f031cb(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'База ноды {arg0}'**
  String nodeDatabase_bed412(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удаление базы {arg0}: {arg1}'**
  String deletingDatabase_41e9b6(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Автоподключение: {arg0}'**
  String autoConnect_4cc7c7(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Уведомление: {arg0}'**
  String notification_7dcfc3(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Уведомления не запущены: {arg0}'**
  String notificationsNotStarted_e0104d(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'не удалось собрать отчёт: {arg0}'**
  String couldNotCollectReport_f860a7(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'«{arg0}» в тексте канала'**
  String inChannelMessages_74052f(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} мин'**
  String min_c284de(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Передано {arg0}'**
  String sent_c9f056(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка: {arg0}'**
  String error_8f7267(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Просмотренные тайлы, работают без сети. Занято {arg0} из {arg1}.'**
  String viewedTilesAreAvailableOfflineUsing_f4b74a(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка чтения своей ноды: {arg0}'**
  String couldNotReadOwnNode_d29415(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка чтения данных прошивки: {arg0}'**
  String couldNotReadFirmwareDetails_b21e3e(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Своя нода {arg0} ещё не загружена'**
  String ownNodeHasNotLoadedYet_0d7292(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удалить канал «{arg0}»?'**
  String deleteChannel_8f1495(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Канал {arg0}'**
  String channel_024ea4(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось сохранить: {arg0}'**
  String couldNotSave_6886a1(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0}, резервное копирование {arg1}'**
  String backup_5f3ad8(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось прочитать файл: {arg0}'**
  String couldNotReadFile_425230(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ключ {arg0} подставлен — сохраните настройки. Ставьте ключ только на ту ноду, с которой он снят'**
  String keySelectedSaveTheSettingsOnly_f2a281(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка чтения конфигурации: {arg0}'**
  String couldNotReadConfiguration_7e6b38(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нода сохранила у себя нулевой MAC-адрес — из-за ошибки кнопки «Отправить NodeInfo» в Meshex 0.1.7–0.1.10. Пока нода не перезагружалась, её ID прежний ({arg0}). При следующей перезагрузке ID сменится на случайный: другие увидят её как новую ноду, переписка и избранное у них разделятся.\n\n{arg1}'**
  String theNodeSavedAZeroMac_88c735(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'ID ноды сменился с {arg0} на {arg1} — из-за ошибки кнопки «Отправить NodeInfo» в Meshex 0.1.7–0.1.10.\n\nИсправление вернёт {arg2}, ключ шифрования сохранится. Нода перезагрузится, имя приложение вернёт само. Список нод, избранное и игнор останутся. У других пользователей {arg3} какое-то время будет видна отдельной нодой.'**
  String theNodeIdChangedFromTo_ca53f7(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  );

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'ID ноды: {arg0}.\n\n{arg1}'**
  String nodeId_12da33(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось: {arg0}'**
  String failed_317897(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В брокер: {arg0} · в ноду: {arg1} · отброшено: {arg2}'**
  String toBrokerToNodeDropped_856a68(String arg0, String arg1, String arg2);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось открыть файл: {arg0}'**
  String couldNotOpenFile_7fa8ac(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Основное записано. Не записано (нода перезагрузилась): {arg0} — задайте вручную'**
  String mainSettingsWrittenNotWrittenNode_5d2582(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Остановлено на «{arg0}»{arg1}'**
  String stoppedAt_546fe2(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Последними записываются: {arg0}. После них нода перезагрузится, связь ненадолго прервётся.'**
  String writtenLastTheNodeWillThen_35a22d(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пропущено: {arg0}'**
  String skipped_29ab80(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Открыта · {arg0}'**
  String open_0cdbe8(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось прочитать: {arg0}'**
  String couldNotRead_35e132(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} КБ'**
  String kb_c723dd(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} МБ'**
  String mb_d67a20(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сообщения из базы {arg0} будут добавлены в открытую базу, старый номер своей ноды заменится текущим. Старая база останется — её можно удалить потом.{arg1}'**
  String messagesFromDatabaseWillBeAdded_47ae75(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Перенесено сообщений: {arg0}'**
  String messagesTransferred_4a0c59(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось перенести: {arg0}'**
  String couldNotTransfer_613ff4(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настройки загружены ({arg0})'**
  String settingsLoaded_66f8ee(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось загрузить: {arg0}'**
  String couldNotLoad_9d91fc(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0}: ноды, каналы и сообщения этой ноды будут удалены с устройства. Сама нода не изменится.'**
  String thisNodeDatabaseChannelsAndMessages_6599da(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось удалить: {arg0}'**
  String couldNotDelete_bacd63(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'База ноды {arg0} уже есть. Заменить её данными из файла?'**
  String databaseForNodeAlreadyExistsReplace_d59789(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'База ноды {arg0} загружена — откроется при подключении к этой ноде'**
  String databaseForNodeLoadedItWill_8f5c23(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Через {arg0} дн.'**
  String afterDays_00b005(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сейчас баз: {arg0}. Самые давно не использованные ({arg1}) удалятся вместе с перепиской.'**
  String currentDatabasesTheLeastRecentlyUsed_0fb1b8(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Приложение › {arg0}'**
  String application_7574f7(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} · радиус {arg1}'**
  String radius_02211c(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Зеркало отвечает, нод: {arg0}'**
  String mirrorRespondingNodes_d2a09d(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Будет использован: {arg0}'**
  String willUse_0a9e87(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Нет связи, повтор через {arg0} с'**
  String disconnectedRetryingInS_c55f01(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Вышла версия {arg0}'**
  String versionReleased_3afe40(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Версия {arg0}'**
  String version_450a87(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Доступна версия {arg0} — нажмите, чтобы скачать'**
  String versionAvailableTapToDownload_af3a75(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось проверить: {arg0}'**
  String couldNotCheck_d7d26b(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'История не загружена: {arg0}'**
  String historyNotLoaded_652fe3(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пинги принято отправлять в сервисный канал, там отвечают боты.{arg0}'**
  String pingsAreUsuallySentToThe_159914(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не отправлено: {arg0}'**
  String notSent_04b25a(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Хопов: {arg0}'**
  String hops_3baa0e(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть {arg0} отфильтрованных'**
  String hideFilteredMessages_3a8226(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Показать {arg0} отфильтрованных'**
  String showFilteredMessages_0be3c1(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Шлюзы: {arg0}. Показать на карте'**
  String gatewaysShowOnMap_6e8104(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отправлено {arg0} из {arg1}'**
  String sentOf_167cc7(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Слишком длинно: больше {arg0} сообщений'**
  String tooLongMoreThanMessages_f438b3(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} байт · уйдёт {arg1} сообщениями'**
  String bytesWillSendAsMessages_e34c7b(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'канал {arg0}'**
  String channel_6a801e(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скрыть канал «{arg0}»?'**
  String hideChannel_3f4e20(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Удалить переписку с «{arg0}»?'**
  String deleteConversationWith_7b6ba5(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0}: {arg1}. Показать, кто поставил'**
  String showWhoReacted_154369(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Жалоба уйдёт оператору сервера ({arg0})'**
  String theReportWillBeSentTo_360707(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сканирование: {arg0}'**
  String scan_603ff2(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поиск в сети: {arg0}'**
  String networkSearch_a3c1c6(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Порты: {arg0}'**
  String ports_1b477b(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Портов: {arg0}'**
  String ports_50f8c3(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Журнал · {arg0}'**
  String log_b9a4c8(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} дБ'**
  String db_112739(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'пропущено {arg0}'**
  String skipped_5dec4c(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ноды{arg0}'**
  String nodes_3af8d3(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} мин назад'**
  String minAgo_d8d327(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} ч назад'**
  String hAgo_9ef360(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} д назад'**
  String dAgo_1ab28d(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Камера недоступна: {arg0}'**
  String cameraUnavailable_6012f0(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'хопов: {arg0}'**
  String hops_d23d4f(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} дБ, {arg1}'**
  String db_660739(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} дБм'**
  String dbm_aadd53(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} В'**
  String v_7e1412(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'высота {arg0} м'**
  String altitudeM_dd3a3e(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ноды в этом месте: {arg0}'**
  String nodesAtThisLocation_39f71d(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Карта{arg0}'**
  String map_d56e1b(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Поиск: {arg0}'**
  String search_b34b80(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось определить местоположение: {arg0}'**
  String couldNotDetermineLocation_e5f6db(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Скачано {arg0} из 194 МБ'**
  String downloadedOfMb_945586(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} строк, {arg1} КБ'**
  String linesKb_94885c(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Базы перенесены: {arg0}'**
  String databasesMoved_c705c3(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Перенос баз: {arg0}'**
  String movingDatabases_08b6c6(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ярлык Linux: {arg0}'**
  String linuxShortcut_e8cde8(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Восстановление (попытка {arg0}) — {arg1}'**
  String restoringAttempt_111048(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Отключено — {arg0}'**
  String disabled_7e8add(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MQTT-прокси: подключение к {arg0} (#{arg1})'**
  String mqttProxyConnectingTo_76c8be(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MQTT-прокси: подключено, темы: {arg0}'**
  String mqttProxyConnectedTopics_155375(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MQTT-прокси: {arg0}'**
  String mqttProxy_ae0acc(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Сбой MQTT-прокси: {arg0}'**
  String mqttProxyFailure_e15119(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MQTT-прокси: в ноду не ушло: {arg0}'**
  String mqttProxyNotSentToNode_d164ca(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Пресет по умолчанию (4/{arg0})'**
  String defaultPreset_3eeaf1(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Неизвестный ({arg0})'**
  String unknown_bf9aae(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Неподдерживаемый ({arg0} кГц)'**
  String unsupportedKhz_f4a35a(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не длиннее {arg0} {arg1}'**
  String noLongerThan_85eae1(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} мс'**
  String ms_f929ee(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Необязательные поля в сообщении о местоположении. Чем больше полей включено, тем больше сообщение, а значит больше время передачи и риск потери пакетов.\n{arg0}'**
  String optionalFieldsInPositionMessagesMore_544075(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Владелец: {arg0}'**
  String owner_a19d69(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Каналы ({arg0}) и LoRa'**
  String channelsAndLora_f47f79(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В вашем регионе действует режим работы {arg0}%. Не рекомендуется использовать MQTT, если у вас ограничен режим работы, так как дополнительный трафик быстро перегрузит вашу сеть LoRa.'**
  String yourRegionHasADutyCycle_8bba9b(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В пределах {arg0} км'**
  String withinKm_810838(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'В пределах {arg0} м'**
  String withinM_4c9617(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'На ноде уже есть канал «{arg0}»'**
  String aChannelNamedAlreadyExistsOn_f690d9(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Не хватает свободных слотов: нужно {arg0}, свободно {arg1}'**
  String notEnoughFreeSlotsNeedAvailable_ebb9b1(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} с'**
  String s_b1049d(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Ошибка ноды: {arg0}'**
  String nodeError_1c86cd(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} бит'**
  String bits_1c3c42(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} байт'**
  String bytes_b92ed8(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} к «{arg1}»'**
  String to_525c23(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} · ответ'**
  String reply_9b21d8(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Трассировка маршрута: {arg0}'**
  String traceroute_bf254b(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'туда {arg0}'**
  String outbound_0eb5b8(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'обратно {arg0}'**
  String return_c58db8(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'сервер ответил {arg0}'**
  String serverResponded_01d198(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'последняя точка вне зоны глушилки, {arg0}'**
  String lastPositionOutsideTheInterferenceZone_f954f0(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'точность ~{arg0} км'**
  String precisionKm_52aa61(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'точность ~{arg0} м'**
  String precisionM_0e4845(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'MAC-адрес в порядке. Прошивка {arg0} считает ID из ключа шифрования — исправлять нечего.'**
  String theMacAddressIsCorrectFirmware_79bf7b(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} д {arg1} ч'**
  String dH_0efa0f(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'{arg0} ч {arg1} мин'**
  String hMin_ace139(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'длиннее {arg0} байт'**
  String longerThanBytes_0b6b95(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Топ-{arg0} болтливых за {arg1} дн.'**
  String topMostTalkativeOverDays_f8e44b(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'сервер не ответил за {arg0} с'**
  String serverDidNotRespondWithinS_d4984e(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'нет связи с сервером: {arg0}'**
  String noConnectionToServer_c97c08(String arg0);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'сервер ответил {arg0} на /{arg1}'**
  String serverRespondedTo_546208(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Зеркало: ошибка обработки {arg0}: {arg1}'**
  String mirrorErrorProcessing_150c37(String arg0, String arg1);

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Зеркало: соединение закрыто{arg0}'**
  String mirrorConnectionClosed_fb5059(String arg0);

  /// No description provided for @compassTitle.
  ///
  /// In ru, this message translates to:
  /// **'Компас'**
  String get compassTitle;

  /// No description provided for @compassNoSensor.
  ///
  /// In ru, this message translates to:
  /// **'Это устройство не оснащено датчиком компаса. Курс недоступен.'**
  String get compassNoSensor;

  /// No description provided for @compassNoPermission.
  ///
  /// In ru, this message translates to:
  /// **'Для отображения расстояния и азимута требуется разрешение на определение местоположения.'**
  String get compassNoPermission;

  /// No description provided for @compassLocationOff.
  ///
  /// In ru, this message translates to:
  /// **'Геолокация выключена. Включите службы определения местоположения.'**
  String get compassLocationOff;

  /// No description provided for @compassWaitingGps.
  ///
  /// In ru, this message translates to:
  /// **'Ждём сигнала GPS, чтобы рассчитать расстояние и азимут.'**
  String get compassWaitingGps;

  /// No description provided for @compassWaitingHeading.
  ///
  /// In ru, this message translates to:
  /// **'Ждём истинный курс компаса. Держите телефон горизонтально.'**
  String get compassWaitingHeading;

  /// No description provided for @compassCalibration.
  ///
  /// In ru, this message translates to:
  /// **'Компас неточен. Отойдите от магнитов и поверните телефон восьмёркой.'**
  String get compassCalibration;

  /// No description provided for @compassSensorError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить данные компаса.'**
  String get compassSensorError;

  /// No description provided for @compassLocationError.
  ///
  /// In ru, this message translates to:
  /// **'Не удалось получить координаты телефона.'**
  String get compassLocationError;

  /// No description provided for @compassNoTarget.
  ///
  /// In ru, this message translates to:
  /// **'У ноды нет координат.'**
  String get compassNoTarget;

  /// No description provided for @compassTargetMissing.
  ///
  /// In ru, this message translates to:
  /// **'Нода не найдена.'**
  String get compassTargetMissing;

  /// No description provided for @compassDistance.
  ///
  /// In ru, this message translates to:
  /// **'Расстояние: {value}'**
  String compassDistance(String value);

  /// No description provided for @compassBearing.
  ///
  /// In ru, this message translates to:
  /// **'Азимут: {value}'**
  String compassBearing(String value);

  /// No description provided for @compassAccuracy.
  ///
  /// In ru, this message translates to:
  /// **'Точность позиции: ±{value}'**
  String compassAccuracy(String value);

  /// No description provided for @compassAccuracyUnknown.
  ///
  /// In ru, this message translates to:
  /// **'Точность позиции ноды неизвестна'**
  String get compassAccuracyUnknown;

  /// No description provided for @compassUpdated.
  ///
  /// In ru, this message translates to:
  /// **'Последнее обновление позиции: {value}'**
  String compassUpdated(String value);

  /// No description provided for @compassUnknownTime.
  ///
  /// In ru, this message translates to:
  /// **'Время позиции неизвестно'**
  String get compassUnknownTime;

  /// No description provided for @compassOpenSettings.
  ///
  /// In ru, this message translates to:
  /// **'Открыть настройки'**
  String get compassOpenSettings;

  /// No description provided for @compassAllowLocation.
  ///
  /// In ru, this message translates to:
  /// **'Разрешить геолокацию'**
  String get compassAllowLocation;

  /// No description provided for @compassRetry.
  ///
  /// In ru, this message translates to:
  /// **'Повторить'**
  String get compassRetry;

  /// No description provided for @compassPhoneAccuracy.
  ///
  /// In ru, this message translates to:
  /// **'Точность GPS телефона: ±{value}'**
  String compassPhoneAccuracy(String value);

  /// No description provided for @compassTargetCorrected.
  ///
  /// In ru, this message translates to:
  /// **'Координаты ноды скорректированы зеркалом'**
  String get compassTargetCorrected;

  /// No description provided for @compassTargetSpoofed.
  ///
  /// In ru, this message translates to:
  /// **'Координаты ноды могут быть подменены'**
  String get compassTargetSpoofed;

  /// No description provided for @compassTrueNorth.
  ///
  /// In ru, this message translates to:
  /// **'Направление относительно истинного севера'**
  String get compassTrueNorth;

  /// No description provided for @compassArrowLabel.
  ///
  /// In ru, this message translates to:
  /// **'Направление к ноде: {value}'**
  String compassArrowLabel(String value);

  /// No description provided for @compassPositionAge.
  ///
  /// In ru, this message translates to:
  /// **' {value} назад'**
  String compassPositionAge(String value);

  /// No description provided for @compassCoincident.
  ///
  /// In ru, this message translates to:
  /// **'Вы в пределах точности позиции ноды'**
  String get compassCoincident;

  /// No description provided for @compassExchangePosition.
  ///
  /// In ru, this message translates to:
  /// **'Обменяться позицией'**
  String get compassExchangePosition;

  /// No description provided for @youPrefix.
  ///
  /// In ru, this message translates to:
  /// **'Вы: '**
  String get youPrefix;

  /// No description provided for @notificationReplyTitle.
  ///
  /// In ru, this message translates to:
  /// **'{value} · ответ'**
  String notificationReplyTitle(String value);

  /// No description provided for @notificationReactionBody.
  ///
  /// In ru, this message translates to:
  /// **'{reaction} к «{target}»'**
  String notificationReactionBody(String reaction, String target);

  /// No description provided for @notificationTraceTitle.
  ///
  /// In ru, this message translates to:
  /// **'Трассировка маршрута: {value}'**
  String notificationTraceTitle(String value);

  /// No description provided for @cardinalNorth.
  ///
  /// In ru, this message translates to:
  /// **'С'**
  String get cardinalNorth;

  /// No description provided for @cardinalNorthEast.
  ///
  /// In ru, this message translates to:
  /// **'СВ'**
  String get cardinalNorthEast;

  /// No description provided for @cardinalEast.
  ///
  /// In ru, this message translates to:
  /// **'В'**
  String get cardinalEast;

  /// No description provided for @cardinalSouthEast.
  ///
  /// In ru, this message translates to:
  /// **'ЮВ'**
  String get cardinalSouthEast;

  /// No description provided for @cardinalSouth.
  ///
  /// In ru, this message translates to:
  /// **'Ю'**
  String get cardinalSouth;

  /// No description provided for @cardinalSouthWest.
  ///
  /// In ru, this message translates to:
  /// **'ЮЗ'**
  String get cardinalSouthWest;

  /// No description provided for @cardinalWest.
  ///
  /// In ru, this message translates to:
  /// **'З'**
  String get cardinalWest;

  /// No description provided for @cardinalNorthWest.
  ///
  /// In ru, this message translates to:
  /// **'СЗ'**
  String get cardinalNorthWest;

  /// No description provided for @trayShow.
  ///
  /// In ru, this message translates to:
  /// **'Показать'**
  String get trayShow;

  /// No description provided for @trayQuit.
  ///
  /// In ru, this message translates to:
  /// **'Выход'**
  String get trayQuit;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Как в системе, русский или английский'**
  String get systemDefaultRussianOrEnglish_f182fd;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **' (основное сохранено)'**
  String get mainSettingsSaved_00e02d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'\n\nВнимание: ключ своей ноды в этих базах разный — похоже, это другая нода.'**
  String get warningTheOwnNodeKeysDiffer_aed068;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'\n\nКлюч своей ноды неизвестен — проверить, что это та же нода, нельзя.'**
  String get theOwnNodeKeyIsUnknown_ccc9d8;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'\n\nКанала Services на ноде нет — добавьте его в настройках каналов.'**
  String get theNodeHasNoServicesChannel_ab2d98;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'байт'**
  String get bytes_e0d1c3;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'символов'**
  String get characters_7fbc31;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'час'**
  String get hour_1e0e6a;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'часа'**
  String get hours_4e4e58;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'часов'**
  String get hours_217fae;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'минута'**
  String get minute_28716b;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'минуты'**
  String get minutes_caa635;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'минут'**
  String get minutes_333ed1;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'секунда'**
  String get second_5dbcff;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'секунды'**
  String get seconds_86ee6d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'секунд'**
  String get seconds_2c2499;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Исправление отправит ноде её настоящий MAC. Перезагрузка не нужна, ничего не потеряется.'**
  String get theRepairSendsTheCorrectMac_7391e0;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Настоящий MAC этой ноды неизвестен ни приложению, ни зеркалу. Перезагрузите ноду: если ID сменится, вернитесь сюда — исправление вернёт прежний ID, ничего не потеряется.'**
  String get neitherTheApplicationNorTheMirror_04717d;

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **'Bluetooth не завершил операцию. Если на ноде включён PIN, возможно, нужно завершить сопряжение в Linux. Отключите автоподключение и нажмите «Отключить», затем выполните в терминале:\n\nbluetoothctl\nremove {arg0}\nagent KeyboardOnly\ndefault-agent\npair {arg1}\ntrust {arg2}\ndisconnect {arg3}\nquit\n\nПри запросе введите PIN ноды. Команда remove удаляет прежнее сопряжение. После успешного pair подключитесь снова в приложении. Если сопряжение уже выполнено, проверьте питание и доступность ноды.'**
  String bluetoothDidNotCompleteTheOperation_65145b(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  );

  /// UI text; source retained for immutable configuration metadata.
  ///
  /// In ru, this message translates to:
  /// **' ({arg0} из {arg1})'**
  String of_b319e7(String arg0, String arg1);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
