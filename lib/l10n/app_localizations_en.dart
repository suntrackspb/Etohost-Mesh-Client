// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get language => 'Language';

  @override
  String get systemLanguage => 'System default';

  @override
  String get russian => 'Русский';

  @override
  String get english => 'English';

  @override
  String get languageHelp => 'Application interface language';

  @override
  String get hourClock_55c2f5 => '12 Hour Clock';

  @override
  String get h_d3db2b => '1H';

  @override
  String get buzzerGpio_fff3f4 => 'Buzzer GPIO';

  @override
  String get buttonGpio_845326 => 'Button GPIO';

  @override
  String get gpsTransmitGpio_e4dc9e => 'GPS Transmit GPIO';

  @override
  String get gpsReceiveGpio_402339 => 'GPS Receive GPIO';

  @override
  String get batteryInaXxICAddress_3b2fa6 => 'Battery INA_2XX I2C address';

  @override
  String get nodeId_021568 => 'Node ID';

  @override
  String get ip_42788e => 'IP';

  @override
  String get mqttDownlinkEnabled_990d36 => 'MQTT Downlink Enabled';

  @override
  String get mqttUplinkEnabled_9d43a7 => 'MQTT Uplink Enabled';

  @override
  String get mqttClientProxy_aa711a => 'MQTT Client Proxy';

  @override
  String get mqttConnectionRejectedCheckCredentials_5ddde1 =>
      'MQTT: connection rejected (check credentials)';

  @override
  String get mqttConnectionLost_681220 => 'MQTT: connection lost';

  @override
  String get tlsEnabled_df2997 => 'TLS Enabled';

  @override
  String get channelUrl_8b64fd => 'Channel URL';

  @override
  String get auto_569533 => 'Auto';

  @override
  String get administration_d838aa => 'Administration';

  @override
  String get address_8db46e => 'Address';

  @override
  String get active_76ddd7 => 'Active';

  @override
  String get uptime_d0d899 => 'Uptime';

  @override
  String get battery_96a4c3 => 'Battery';

  @override
  String get security_d4fab1 => 'Security';

  @override
  String get baud_cd221c => 'Baud';

  @override
  String get yourNodeWillPeriodicallySendAn_b5be37 =>
      'Your node will periodically send an unencrypted map report packet to the configured MQTT server, this includes id, short and long name, approximate location, hardware model, role, firmware version, LoRa region, modem preset and primary channel name.';

  @override
  String get upDown_908205 => 'Up Down 1';

  @override
  String get version_97c248 => 'Version';

  @override
  String get firmwareEdition_29bed8 => 'Firmware Edition';

  @override
  String get weight_38348d => 'Weight';

  @override
  String get wind_43eea9 => 'Wind';

  @override
  String get enablesTheDetectionSensorModuleIt_54016a =>
      'Enables the detection sensor module, it needs to be enabled on both the node with the sensor, and any nodes that you want to receive detection sensor text messages or view the detection sensor log and chart.';

  @override
  String get enablesTheStoreAndForwardModule_539c8a =>
      'Enables the store and forward module.';

  @override
  String get enabled_edde94 => 'Enabled';

  @override
  String get enablingEthernetWillDisableTheBluetooth_7dd901 =>
      'Enabling Ethernet will disable the bluetooth connection to the app.';

  @override
  String get enableBroadcastingDeviceMetricsToThe_7c0170 =>
      'Enable broadcasting device metrics to the mesh network. When disabled, metrics are only sent to connected clients.';

  @override
  String get enableBroadcastingPacketsViaUdpOver_60fa0e =>
      'Enable broadcasting packets via UDP over the local network.';

  @override
  String get enableFilterHere_f6dfd3 => 'Enable filter here';

  @override
  String get enableThisDeviceAsAStore_4fbae6 =>
      'Enable this device as a Store and Forward server. Requires an ESP32 device with PSRAM.';

  @override
  String get hum_b7b903 => 'Hum';

  @override
  String get soilMoist_1e2f47 => 'Soil Moist';

  @override
  String get humidity_3b6f05 => 'Humidity';

  @override
  String get externalNotification_22860a => 'External Notification';

  @override
  String get warningThisContactIsKnownImporting_555efb =>
      'Warning: This contact is known, importing will overwrite the previous contact information.';

  @override
  String get reconnecting_c0657e => 'Reconnecting…';

  @override
  String get clockwiseRotaryEvent_fc48d3 => 'Clockwise Rotary Event';

  @override
  String get counterClockwiseRotaryEvent_e87a94 =>
      'Counter Clockwise Rotary Event';

  @override
  String get historyReturnWindow_221c13 => 'History Return Window';

  @override
  String get time_c80d7e => 'Time';

  @override
  String get lastHeardTime_c3cbbb => 'Last Heard Time';

  @override
  String get all_fd08da => 'All';

  @override
  String get willSleepEverythingAsMuchAs_b3e005 =>
      'Will sleep everything as much as possible, for the tracker and sensor role this will also include the lora radio. Don\'t use this setting if you want to use your device with the phone apps or are using a device without a user button.';

  @override
  String get insertLink_ab6720 => 'Insert Link';

  @override
  String get all_fc7905 => 'All';

  @override
  String get yesterday_51403c => 'Yesterday';

  @override
  String get you_adb403 => 'You';

  @override
  String get areYouSureYouWantTo_7ff54f =>
      'Are you sure you want to regenerate your Private Key?\n\nNodes that may have previously exchanged keys with this node will need to Remove that node and re-exchange keys in order to resume secure communication.';

  @override
  String get areYouSure_b0069b => 'Are you sure?';

  @override
  String get pickTheBackupToRestoreTo_92df2d =>
      'Pick the backup to restore to this node. A factory reset or a new key changes the node\'s ID, so older backups stay under the old ID. Only restore a backup taken from this same radio: another radio\'s key gives both radios the same identity.';

  @override
  String get pickTheEncryptedKeyBackupTo_5e150c =>
      'Pick the encrypted key backup to delete from this device. This cannot be undone.';

  @override
  String get jsonOutputEnabled_946891 => 'JSON output enabled';

  @override
  String get outputLiveDebugLoggingOverSerial_db97f9 =>
      'Output live debug logging over serial, view and export position-redacted device logs over Bluetooth.';

  @override
  String get boldTheHeadingTextOnThe_6d5498 =>
      'Bold the heading text on the screen.';

  @override
  String get shutdown_468972 => 'Shutdown';

  @override
  String get shutdownNotSupportedOnThisDevice_04502f =>
      'Shutdown not supported on this device';

  @override
  String get altitude_b24a95 => 'Altitude';

  @override
  String get quit_c42457 => 'Quit';

  @override
  String get outputPinGpio_341423 => 'Output pin GPIO';

  @override
  String get outputPinVibraGpio_7e4cdf => 'Output pin vibra GPIO';

  @override
  String get done_398c7d => 'Done';

  @override
  String get baro_21229d => 'Baro';

  @override
  String get pressure_aa017a => 'Pressure';

  @override
  String get next_9c714c => 'Next';

  @override
  String get detectionSensor_ef8fca => 'Detection Sensor';

  @override
  String get doubleTapAsButton_d2bc2c => 'Double Tap as Button';

  @override
  String get actions_9978ac => 'Actions';

  @override
  String get display_fff385 => 'Display';

  @override
  String get gpioOutputDuration_e159f4 => 'GPIO Output Duration';

  @override
  String get superDeepSleepDuration_c44e27 => 'Super deep sleep duration';

  @override
  String get acceptUnsignedTrafficForMaximumCompatibility_6a6fd7 =>
      'Accept unsigned traffic for maximum compatibility. A signature that can be checked and is wrong still drops the packet.';

  @override
  String get noKeyBackupFoundForThis_ce5803 =>
      'No key backup found for this node';

  @override
  String get add_559a87 => 'Add';

  @override
  String get addChannel_af2785 => 'Add channel';

  @override
  String get addsErrorCorrectionOnTopOf_512807 =>
      'Adds error correction on top of the preset. A higher coding rate makes every packet longer on air and uses more of the duty cycle and channel utilization budget.';

  @override
  String get rainH_ee76fe => 'Rain (1h)';

  @override
  String get rainH_90ad74 => 'Rain (24h)';

  @override
  String get longitude_f22a3e => 'Longitude';

  @override
  String get availablePins_a9affa => 'Available pins';

  @override
  String get availableModemPresetsDefaultIsLong_71dc05 =>
      'Available modem presets, default is Long Fast.';

  @override
  String get displayUnits_4a7072 => 'Display Units';

  @override
  String get ifEnabledTheOutputPinWill_3d2627 =>
      'If enabled, the \'output\' Pin will be pulled active high, disabled means active low.';

  @override
  String get ifSetAnyPacketsYouSend_4305f4 =>
      'If set, any packets you send will be echoed back to your device.';

  @override
  String get boldHeading_29e9c1 => 'Bold Heading';

  @override
  String get debugLogs_dea656 => 'Debug Logs';

  @override
  String get logs_d821b9 => 'Logs';

  @override
  String get close_4ae50d => 'Close';

  @override
  String get replace_d772cc => 'Replace';

  @override
  String get audio_3bcc51 => 'Audio';

  @override
  String get ignore_00e05b => 'Ignore';

  @override
  String get ignoreMqtt_be2d01 => 'Ignore MQTT';

  @override
  String get favorite_b880e6 => 'Favorite';

  @override
  String get importConfiguration_c776ef => 'Import configuration';

  @override
  String get import_55fd5f => 'Import';

  @override
  String get importSharedContact_5e5c66 => 'Import Shared Contact?';

  @override
  String get name_aee78f => 'Name';

  @override
  String get username_a79f8a => 'Username';

  @override
  String get carouselInterval_fa458c => 'Carousel Interval';

  @override
  String get updateInterval_fe3feb => 'Update Interval';

  @override
  String get channelUtilization_b2e6eb => 'Channel utilization';

  @override
  String get useISAsBuzzer_8b207f => 'Use I2S As Buzzer';

  @override
  String get usePwmBuzzer_571ead => 'Use PWM Buzzer';

  @override
  String get usePreset_f457c3 => 'Use Preset';

  @override
  String get usePhoneTimeZone_8a4f73 => 'Use phone time zone';

  @override
  String get usesPullupResistor_a75a60 => 'Uses pullup resistor';

  @override
  String get utilizesTheNetworkConnectionOnYour_d40c1d =>
      'Utilizes the network connection on your phone to connect to MQTT.';

  @override
  String get useAPwmOutputLikeThe_6695f2 =>
      'Use a PWM output (like the RAK Buzzer) for tunes instead of an on/off output. This will ignore the output, output duration and active settings and use the device config buzzer GPIO option instead.';

  @override
  String get channels_88a8ec => 'Channels';

  @override
  String get keysBackedUpSecurely_249b39 => 'Keys backed up securely';

  @override
  String get numberOfRecords_107e13 => 'Number of records';

  @override
  String get sats_096274 => 'Sats';

  @override
  String get serialConsole_f80bee => 'Serial Console';

  @override
  String get serialConsoleOverTheStreamApi_ee1f12 =>
      'Serial Console over the Stream API.';

  @override
  String get gpioPin_68149e => 'GPIO pin';

  @override
  String get gpioPinToMonitor_cef408 => 'GPIO Pin to monitor';

  @override
  String get transmitDataTxdGpioPin_a33aed => 'Transmit data (txd) GPIO pin';

  @override
  String get receiveDataRxdGpioPin_05d193 => 'Receive data (rxd) GPIO pin';

  @override
  String get pressPin_e4f7eb => 'Press Pin';

  @override
  String get copy_4a05d8 => 'Copy';

  @override
  String get shortName_58073d => 'Short Name';

  @override
  String get spreadFactor_deb22e => 'Spread Factor';

  @override
  String get directMessages_6955f3 => 'Direct Messages';

  @override
  String get localStats_f21f8a => 'Local Stats';

  @override
  String get maxHopsForDirectResponse_3ca022 => 'Max Hops for Direct Response';

  @override
  String get maxPacketsInWindow_75eb31 => 'Max Packets in Window';

  @override
  String get historyReturnMax_cb0955 => 'History Return Max';

  @override
  String get position_82bd05 => 'Position';

  @override
  String get airQualityMetrics_e4a5d4 => 'Air-Quality Metrics';

  @override
  String get environmentMetrics_f472fb => 'Environment Metrics';

  @override
  String get environmentMetricsEnabled_67632b => 'Environment Metrics Enabled';

  @override
  String get powerMetrics_f93c31 => 'Power Metrics';

  @override
  String get deviceMetrics_19b5ae => 'Device Metrics';

  @override
  String get mesh_b9e236 => 'Mesh';

  @override
  String get minPositionIntervalSecs_293ba3 => 'Min Position Interval (secs)';

  @override
  String get minimumWakeTime_de36c3 => 'Minimum wake time';

  @override
  String get minimumDistance_404b16 => 'Minimum Distance';

  @override
  String get hardwareModel_feb4d1 => 'Hardware model';

  @override
  String get voltage_fb28eb => 'Voltage';

  @override
  String get bluetoothConfig_aae27c => 'Bluetooth Config';

  @override
  String get mqttConfig_c20987 => 'MQTT Config';

  @override
  String get takConfiguration_cb4e17 => 'TAK Configuration';

  @override
  String get detectionSensorConfig_9fd77e => 'Detection Sensor Config';

  @override
  String get audioConfig_7ca6bd => 'Audio Config';

  @override
  String get remoteHardwareConfig_b75c78 => 'Remote Hardware Config';

  @override
  String get trafficManagementConfiguration_3bcd5d =>
      'Traffic Management Configuration';

  @override
  String get configuration_7f17c7 => 'Configuration';

  @override
  String get moduleConfiguration_f1e43a => 'Module configuration';

  @override
  String get userConfig_28470f => 'User Config';

  @override
  String get neighborInfoConfig_b6a0ae => 'Neighbor Info Config';

  @override
  String get deviceConfiguration_2030e8 => 'Device configuration';

  @override
  String get failedToRestoreKeysFromBackup_89248f =>
      'Failed to restore keys from backup';

  @override
  String get inactive_0b3829 => 'Inactive';

  @override
  String get whetherOrNotUseInputPullup_f96145 =>
      'Whether or not use INPUT_PULLUP mode for GPIO pin. Only applicable if the board uses pull-up resistors on the pin';

  @override
  String get noResultsFound_1e1b70 => 'No results found';

  @override
  String get nodes_fea63e => 'Nodes';

  @override
  String get about_b9c9ff => 'About';

  @override
  String get okToMqtt_81b6f7 => 'Ok to MQTT';

  @override
  String get exchangePosition_b039f2 => 'Exchange position';

  @override
  String get refresh_c2f668 => 'Refresh';

  @override
  String get hardware_2cf041 => 'Hardware';

  @override
  String get rateLimited_eebeda => 'Rate limited';

  @override
  String get rateLimitWindowSecs_5c4a08 => 'Rate Limit Window (secs)';

  @override
  String get lux_0ca380 => 'Lux';

  @override
  String get rootTopic_994995 => 'Root Topic';

  @override
  String get dropUnknownPackets_ba44e0 => 'Drop Unknown Packets';

  @override
  String get reply_c6f466 => 'Reply';

  @override
  String get disabled_cadea0 => 'Disabled';

  @override
  String get shutdownOnPowerLoss_753913 => 'Shutdown on Power Loss';

  @override
  String get disconnected_9d30b9 => 'Disconnected';

  @override
  String get muteNotifications_6f777b => 'Mute notifications';

  @override
  String get disableFilterHere_24f1d5 => 'Disable filter here';

  @override
  String get openInBrowser_a1f2ae => 'Open in browser';

  @override
  String get debug_8669d1 => 'Debug';

  @override
  String get cancel_0ec753 => 'Cancel';

  @override
  String get cancelReply_d5465b => 'Cancel reply';

  @override
  String get timestamp_9604ae => 'Timestamp';

  @override
  String get displayFahrenheit_8c89d1 => 'Display Fahrenheit';

  @override
  String get send_76dcf7 => 'Send';

  @override
  String get sendAHeartbeatToAdvertiseThe_80f353 =>
      'Send a heartbeat to advertise the server\'s presence.';

  @override
  String get sendBell_9a7a42 => 'Send Bell';

  @override
  String get sendHeartbeat_733393 => 'Send Heartbeat';

  @override
  String get sendAsciiBellWithAlertMessage_fbcdc2 =>
      'Send ASCII bell with alert message. Useful for triggering external notification on bell.';

  @override
  String get filtered_a13eeb => 'Filtered';

  @override
  String get clear_98b207 => 'Clear';

  @override
  String get positionPacket_02f1de => 'Position Packet';

  @override
  String get password_14f7c6 => 'Password';

  @override
  String get primary_781ece => 'Primary';

  @override
  String get flipScreen_8fe129 => 'Flip Screen';

  @override
  String get flipScreenVertically_554b97 => 'Flip screen vertically';

  @override
  String get transmitEnabled_da32f9 => 'Transmit Enabled';

  @override
  String get reboot_a40813 => 'Reboot';

  @override
  String get adcOverride_577328 => 'ADC Override';

  @override
  String get frequencyOverride_80233f => 'Frequency Override';

  @override
  String get overrideConsoleSerialPort_6cee74 => 'Override console serial port';

  @override
  String get reconnect_a8e2cf => 'Reconnect';

  @override
  String get power_cea0d9 => 'Power';

  @override
  String get powerScreen_c81bdd => 'Power Screen';

  @override
  String get default_469631 => 'Default';

  @override
  String get rotary_378549 => 'Rotary 1';

  @override
  String get retry_9e506a => 'Retry';

  @override
  String get locationSharing_26e070 => 'Location Sharing';

  @override
  String get connecting_79e350 => 'Connecting';

  @override
  String get connecting_40b27e => 'Connecting…';

  @override
  String get connected_20bebc => 'Connected';

  @override
  String get connect_124298 => 'Connect';

  @override
  String get packetAuthenticity_43a0f6 => 'Packet authenticity';

  @override
  String get enablesDevicesWithNativeIS_fb6aba =>
      'Enables devices with native I2S audio output to use the RTTTL over speaker like a buzzer. T-Watch S3 and T-Deck for example have this capability.';

  @override
  String get broadcastDeviceMetrics_48d605 => 'Broadcast Device Metrics';

  @override
  String get show_7788a1 => 'Show';

  @override
  String get showOnDeviceScreen_b36075 => 'Show on device screen';

  @override
  String get onlyShowAndProcessCryptographicallyAuthenticated_4e43d0 =>
      'Only show and process cryptographically authenticated mesh packets. Older nodes and oversized packets may disappear.';

  @override
  String get user_51aff1 => 'User';

  @override
  String get unknownPacketThreshold_db491f => 'Unknown Packet Threshold';

  @override
  String get preview_5d092c => 'Preview';

  @override
  String get alertGpioVibraMotorWhenReceiving_fb8e2d =>
      'Alert GPIO vibra motor when receiving a bell';

  @override
  String get alertGpioVibraMotorWhenReceiving_31bde3 =>
      'Alert GPIO vibra motor when receiving a message';

  @override
  String get alertGpioBuzzerWhenReceivingA_5b83a2 =>
      'Alert GPIO buzzer when receiving a bell';

  @override
  String get alertGpioBuzzerWhenReceivingA_8c8033 =>
      'Alert GPIO buzzer when receiving a message';

  @override
  String get alertWhenReceivingABell_c28d01 => 'Alert when receiving a bell';

  @override
  String get alertWhenReceivingAMessage_a01361 =>
      'Alert when receiving a message';

  @override
  String get presets_c5eb0c => 'Presets';

  @override
  String get enablingWifiWillDisableTheBluetooth_29400e =>
      'Enabling WiFi will disable the bluetooth connection to the app.';

  @override
  String get whenEnabledThePaxCounterModule_bf807f =>
      'When enabled the PAX Counter module counts the number of people passing by using WiFi and Bluetooth. Both WiFI and Bluetooth must be disabled for PAX counter to work.';

  @override
  String get app_f9886c => 'App';

  @override
  String get rangeTest_6b237e => 'Range Test';

  @override
  String get bandwidth_cb1c61 => 'Bandwidth';

  @override
  String get firmware_df1881 => 'Firmware';

  @override
  String get hopsAway_1337cd => 'Hops away';

  @override
  String get nodeinfoDirectResponse_ee19b3 => 'NodeInfo Direct Response';

  @override
  String get aPublicStatusMessageThatIs_1e34f9 =>
      'A public status message that is broadcast to the mesh on change and every 12 hours.';

  @override
  String get publicKey_225a9f => 'Public Key';

  @override
  String get publicKeyChanged_999a04 => 'Public Key Changed';

  @override
  String get ledHeartbeat_351815 => 'LED Heartbeat';

  @override
  String get yourNodeSOperatingFrequencyIs_89edec =>
      'Your node’s operating frequency is calculated based on the region, modem preset, and this field. When 0, the slot is automatically calculated based on the primary channel name.';

  @override
  String get allowUndefinedPinAccess_323b2d => 'Allow undefined pin access';

  @override
  String get region_1089c8 => 'Region';

  @override
  String get mode_ff0fbd => 'Mode';

  @override
  String get rebroadcastMode_96abc5 => 'Rebroadcast Mode';

  @override
  String get pairingMode_053326 => 'Pairing Mode';

  @override
  String get displayMode_953816 => 'Display Mode';

  @override
  String get backupRestore_e10c3e => 'Backup & Restore';

  @override
  String get keyBackupDeleted_2ed312 => 'Key backup deleted';

  @override
  String get ringtone_622e53 => 'Ringtone';

  @override
  String get role_ab51a3 => 'Role';

  @override
  String get deviceRole_1118bf => 'Device & Role';

  @override
  String get light_808001 => 'Light';

  @override
  String get today_5d5d2e => 'Today';

  @override
  String get server_917e05 => 'Server';

  @override
  String get network_b3c4b1 => 'Network';

  @override
  String get signal_b26f0d => 'Signal';

  @override
  String get scanSharedChannelsQrCode_e4128b => 'Scan Shared Channels QR Code';

  @override
  String get download_fe8f79 => 'Download';

  @override
  String get codingRate_4440db => 'Coding Rate';

  @override
  String get hide_107291 => 'Hide';

  @override
  String get serviceNotifications_f0c59c => 'Service notifications';

  @override
  String get encoderPressEvent_c7ef35 => 'Encoder Press Event';

  @override
  String get consentToShareUnencryptedNodeData_2a83b2 =>
      'Consent to Share Unencrypted Node Data via MQTT';

  @override
  String get message_dc7234 => 'Message';

  @override
  String get messages_019803 => 'Messages';

  @override
  String get messagesSentDirectlyToYou_9bb02c =>
      'Messages sent directly to you.';

  @override
  String get gasResistance_ccf913 => 'Gas Resistance';

  @override
  String get status_81e4bb => 'Status';

  @override
  String get ledState_e13197 => 'LED State';

  @override
  String get theStateOfTheLedOn_90485e => 'The state of the LED (on/off)';

  @override
  String get statusMessage_b6dd18 => 'Status Message';

  @override
  String get save_486405 => 'Save';

  @override
  String get preserveFavorites_8bd086 => 'Preserve Favorites?';

  @override
  String get savesThePublicAndPrivateKeys_819ff7 =>
      'Saves the public and private keys to secure, encrypted storage on this device.';

  @override
  String get savesACsvWithTheRange_d3ca60 =>
      'Saves a CSV with the range test message details, currently only available on ESP32 devices with a web server.';

  @override
  String get status_f7f293 => 'Status';

  @override
  String get strictIgnoresEveryRemoteMeshPacket_c16f59 =>
      'Strict ignores every remote mesh packet that is not cryptographically authenticated. Older firmware, licensed or ham nodes without PKI keys, and oversized packets may disappear. PKI-authenticated direct messages remain available.';

  @override
  String get treatDoubleTapOnSupportedAccelerometers_28e78a =>
      'Treat double tap on supported accelerometers as a user button press.';

  @override
  String get timeout_82605b => 'Timeout';

  @override
  String get telemetry_c2d0b0 => 'Telemetry';

  @override
  String get theme_553c45 => 'Theme';

  @override
  String get temp_e0d826 => 'Temp';

  @override
  String get soilTemp_014031 => 'Soil Temp';

  @override
  String get temperature_56f765 => 'Temperature';

  @override
  String get oledType_6f928e => 'OLED Type';

  @override
  String get triggertype_435565 => 'TriggerType';

  @override
  String get current_47b6bf => 'Current';

  @override
  String get encryptedOnly_5943ed => 'Encrypted only';

  @override
  String get favoritesOnly_f1d6dc => 'Favorites only';

  @override
  String get signedOnly_a90195 => 'Signed only';

  @override
  String get dewPoint_5fb1ca => 'Dew Point';

  @override
  String get traceRoute_c2e3ed => 'Trace Route';

  @override
  String get requiresThatThereBeAnAccelerometer_b88b6d =>
      'Requires that there be an accelerometer on your device.';

  @override
  String get thisContactHasNoPublicKey_1b1efe =>
      'This contact has no public key, so it cannot be imported. A contact without one clears any key your radio already holds for that node. Ask the sender to share it again once their node has exchanged keys.';

  @override
  String get notifications_ee3c35 => 'Notifications';

  @override
  String get directMessageNotifications_35b81d =>
      'Direct message notifications';

  @override
  String get positionDeduplication_77bb08 => 'Position Deduplication';

  @override
  String get remoteHardwareEnabled_2d4140 => 'Remote Hardware enabled';

  @override
  String get remoteHardware_aa22db => 'Remote Hardware';

  @override
  String get delete_86ea33 => 'Delete';

  @override
  String get deleteKeyBackup_2b8633 => 'Delete Key Backup';

  @override
  String get smartPosition_71605c => 'Smart Position';

  @override
  String get trafficManagement_c0dc15 => 'Traffic Management';

  @override
  String get managedDevice_5802d0 => 'Managed Device';

  @override
  String get controlsTheBlinkingLedOnThe_f98894 =>
      'Controls the blinking LED on the device.  For most devices this will control one of the up to 4 LEDS, the charger and GPS LEDs are not controllable.';

  @override
  String get protectionLevel_b65cfe => 'Protection level';

  @override
  String get rxBoostedGain_ccd314 => 'RX Boosted Gain';

  @override
  String get setsTheScreenClockFormatTo_522029 =>
      'Sets the screen clock format to 12-hour.';

  @override
  String get device_bc791d => 'Device';

  @override
  String get deviceIsManagedByAMesh_c25d72 =>
      'Device is managed by a mesh administrator, the user is unable to access any of the device settings.';

  @override
  String get fixedPosition_375f92 => 'Fixed Position';

  @override
  String get fixedPin_a02794 => 'Fixed Pin';

  @override
  String get noFilterWordsConfigured_f30bc1 => 'No filter words configured';

  @override
  String get messageFilter_cf2a46 => 'Message Filter';

  @override
  String get filterAllConversations_0c4f61 => 'Filter all conversations';

  @override
  String get filterWords_42f560 => 'Filter Words';

  @override
  String get filters_67e16d => 'Filters';

  @override
  String get timeZone_47947a => 'Time Zone';

  @override
  String get timeZoneForDatesOnThe_ab5297 =>
      'Time zone for dates on the device screen and log.';

  @override
  String get frequencySlot_8cb1e6 => 'Frequency Slot';

  @override
  String get latitude_e4f731 => 'Latitude';

  @override
  String get encryptionEnabled_a31349 => 'Encryption Enabled';

  @override
  String get screenOnFor_c40d42 => 'Screen on for';

  @override
  String get wakeScreenOnTapOrMotion_cbc6f1 => 'Wake Screen on tap or motion';

  @override
  String get exportConfiguration_af2d98 => 'Export configuration';

  @override
  String get powerSaving_668a8d => 'Power Saving';

  @override
  String get thisBandwidthIsNotSupportedBy_629cec =>
      'This bandwidth is not supported by the connected radio in the selected region. Choose a supported value before saving.';

  @override
  String get thisConnectedDeviceDoesNotSupport_a098e6 =>
      'This connected device does not support packet signature verification.';

  @override
  String get thisQrCodeContainsAComplete_8382f2 =>
      'This QR code contains a complete configuration. This will REPLACE your existing channels and radio settings. All existing channels will be removed.';

  @override
  String get echo_1beee7 => 'Echo';

  @override
  String get language_ed3f0e => 'Language';

  @override
  String get thisWillShutdownTheNodePhysical_dda266 =>
      '⚠️ This will SHUTDOWN the node. Physical interaction will be required to turn it back on.';

  @override
  String get byte_2b1af8 => '1 byte';

  @override
  String get bit_4d4041 => '128 bit';

  @override
  String get bit_4b629b => '256 bit';

  @override
  String get mqttUplinkEnabled_0922b5 => 'MQTT Uplink Enabled';

  @override
  String get mqttDownlinkEnabled_07f56b => 'MQTT Downlink Enabled';

  @override
  String get udpBroadcast_cb95ce => 'UDP Broadcast';

  @override
  String get aTraceRouteWasSentNo_831209 =>
      'A Trace Route was sent, no response has been received.';

  @override
  String get include_66be7e => 'Include';

  @override
  String get soilMoisture_09ca2d => 'Soil Moisture';

  @override
  String get thereIsAnIssueWithThis_da58d6 =>
      'There is an issue with this contact\'s public key.';

  @override
  String get restore_29f3b2 => 'Restore';

  @override
  String get uptime_519192 => 'Uptime';

  @override
  String get second_a0f62f => 'Second';

  @override
  String get secondaryAdminKey_a17eea => 'Secondary Admin Key';

  @override
  String get inputs_4465f9 => 'Inputs';

  @override
  String get selectANode_674ed0 => 'Select a Node';

  @override
  String get timingAndOverrides_7df059 => 'Timing and Overrides';

  @override
  String get shutDownNode_6cff20 => 'Shut Down Node?';

  @override
  String get altitudeIsMeanSeaLevel_9128a7 => 'Altitude is Mean Sea Level';

  @override
  String get outputPinBuzzerGpio_d0254b => 'Output pin buzzer GPIO ';

  @override
  String get longName_4a55b1 => 'Long Name';

  @override
  String get forAllMqttFunctionalityOtherThan_528328 =>
      'For all Mqtt functionality other than the map report you must also set uplink and downlink for each channel you want to bridge over Mqtt.';

  @override
  String get toComplyWithPrivacyLawsLike_17f767 =>
      'To comply with privacy laws like CCPA and GDPR, we avoid sharing exact location data. Instead, we use anonymized or approximate (imprecise) location information to protect your privacy.';

  @override
  String get addChannels_236dd4 => 'Add Channels';

  @override
  String get addContact_155d11 => 'Add Contact';

  @override
  String get advanced_d7907f => 'Advanced';

  @override
  String get optionalGpio_967662 => 'Optional GPIO';

  @override
  String get traceRouteLog_eaa487 => 'Trace Route Log';

  @override
  String get replaceChannels_d0b4ac => 'Replace Channels';

  @override
  String get encrypted_347a1a => 'Encrypted';

  @override
  String get altitudeGeoidalSeparation_166950 => 'Altitude Geoidal Separation';

  @override
  String get ignored_4561a6 => 'Ignored';

  @override
  String get radiation_3bdf95 => 'Radiation';

  @override
  String get usedToIdentifyUnmonitoredOrInfrastructure_57ed87 =>
      'Used to identify unmonitored or infrastructure nodes so that messaging is not avaliable to nodes that will never respond.';

  @override
  String get howLongTheScreenRemainsOn_6187f3 =>
      'How long the screen remains on after the user button is pressed or messages are received.';

  @override
  String get key_cc6ec0 => 'Key';

  @override
  String get directMessageKey_db3f1a => 'Direct Message Key';

  @override
  String get adminKeys_59351d => 'Admin Keys';

  @override
  String get moduleConfiguration_4b812e => 'Module Configuration';

  @override
  String get cannedMessagesConfig_458203 => 'Canned Messages Config';

  @override
  String get deviceConfiguration_ccb937 => 'Device Configuration';

  @override
  String get theRootTopicToUseFor_ee86b4 => 'The root topic to use for MQTT.';

  @override
  String get keyMapping_0f4f90 => 'Key Mapping';

  @override
  String get findANode_861918 => 'Find a node';

  @override
  String get vehicleHeading_7136f7 => 'Vehicle heading';

  @override
  String get loraConfig_980826 => 'LoRa Config';

  @override
  String get externalNotificationConfig_b8060c =>
      'External Notification Config';

  @override
  String get ambientLightingConfig_04051c => 'Ambient Lighting Config';

  @override
  String get positionConfig_0ef894 => 'Position Config';

  @override
  String get serialConfig_060db9 => 'Serial Config';

  @override
  String get radioConfiguration_dbf9ae => 'Radio Configuration';

  @override
  String get networkConfig_845e74 => 'Network Config';

  @override
  String get storeForwardConfig_27a553 => 'Store & Forward Config';

  @override
  String get paxCounterConfig_5a4b67 => 'PAX Counter Config';

  @override
  String get rangeTestConfig_c02f93 => 'Range Test Config';

  @override
  String get deviceConfig_1c4174 => 'Device Config';

  @override
  String get securityConfig_2b6ab6 => 'Security Config';

  @override
  String get powerConfig_f44024 => 'Power Config';

  @override
  String get telemetryConfig_75dc08 => 'Telemetry Config';

  @override
  String get displayConfig_acaf70 => 'Display Config';

  @override
  String get unset_7faabd => 'Unset';

  @override
  String get unmessagable_42f44c => 'Unmessagable';

  @override
  String get unmonitored_0eff12 => 'Unmonitored';

  @override
  String get publicKeyMismatch_a6a194 => 'Public Key Mismatch';

  @override
  String get node_2409cc => 'Node';

  @override
  String get oneMinute_6d5cba => 'One Minute';

  @override
  String get ambientLighting_d3a18a => 'Ambient Lighting';

  @override
  String get online_76e9fb => 'Online';

  @override
  String get mapReport_64f9f0 => 'Map Report';

  @override
  String get clearStaleNodes_968b4f => 'Clear Stale Nodes';

  @override
  String get options_6744ad => 'Options';

  @override
  String get ethernetOptions_d9cb39 => 'Ethernet Options';

  @override
  String get wifiOptions_612b23 => 'WiFi Options';

  @override
  String get sensorOptions_abc34e => 'Sensor options';

  @override
  String get environmentSensorOptions_850067 => 'Environment Sensor Options';

  @override
  String get powerSensorOptions_9aba2f => 'Power Sensor Options';

  @override
  String get serverOption_1dc679 => 'Server Option';

  @override
  String get deviceOptions_4d2301 => 'Device Options';

  @override
  String get primaryGpio_b6ae3c => 'Primary GPIO';

  @override
  String get primaryAdminKey_e8e5be => 'Primary Admin Key';

  @override
  String get firstHeard_fb9dde => 'First heard';

  @override
  String get navigateToNode_3ebc01 => 'Navigate to node';

  @override
  String get overrideAutomaticOledScreenDetection_3e664c =>
      'Override automatic OLED screen detection.';

  @override
  String get overrideDefaultScreenLayout_abfc85 =>
      'Override default screen layout.';

  @override
  String get shareContactQr_3fcfa5 => 'Share Contact QR';

  @override
  String get shareQrCode_6584cb => 'Share QR Code';

  @override
  String get connectToMqttViaProxy_385c9e => 'Connect to MQTT via Proxy';

  @override
  String get details_abaf4c => 'Details...';

  @override
  String get confirm_846aff => 'Confirm';

  @override
  String get positionsEnabled_05a345 => 'Positions Enabled';

  @override
  String get position_c139a7 => 'Position';

  @override
  String get search_6433b5 => 'Search';

  @override
  String get sequenceNumber_12b28a => 'Sequence number';

  @override
  String get afterConfigValuesSaveTheNode_675d86 =>
      'After config values save the node will reboot.';

  @override
  String get theLastOfTheDeviceMac_aa05c8 =>
      'The last 4 of the device MAC address will be appended to the short name to set the device\'s BLE Name.  Short name can be up to 4 bytes long.';

  @override
  String get serial_427dc5 => 'Serial';

  @override
  String get configurationPresets_057e0a => 'Configuration Presets';

  @override
  String get approximateLocation_5a3d58 => 'Approximate Location';

  @override
  String get verifyWhoYouAreMessagingWith_690825 =>
      'Verify who you are messaging with by comparing public keys in person or over the phone. The most recent public key for this node does not match the previously recorded key. You can delete the node and let it exchange keys again if the key change was due to a factory reset or other intentional action but this also may indicate a more serious security problem.';

  @override
  String get empty_2138fa => 'Empty';

  @override
  String get fiveMinutes_960eec => 'Five Minutes';

  @override
  String get keySize_b9f9ea => 'Key Size';

  @override
  String get allowPositionRequests_11c111 => 'Allow Position Requests';

  @override
  String get advancedDeviceGps_afe61f => 'Advanced Device GPS';

  @override
  String get theRegionWhereYouWillBe_5a735c =>
      'The region where you will be using your radios.';

  @override
  String get backup_72f931 => 'Backup';

  @override
  String get keyBackup_30f9f7 => 'Key Backup';

  @override
  String get roles_265068 => 'Roles';

  @override
  String get channelRole_d02621 => 'Channel Role';

  @override
  String get resetNodedb_58a887 => 'Reset NodeDB';

  @override
  String get factoryResetWillDeleteDeviceAnd_cd2c63 =>
      'Factory reset will delete device and app data.';

  @override
  String get factoryReset_5dbd37 => 'Factory Reset';

  @override
  String get channelDetails_1240d4 => 'Channel Details';

  @override
  String get userDetails_4f06a9 => 'User Details';

  @override
  String get storeAndForwardServersRequireAn_adeadb =>
      'Store and forward servers require an ESP32 device with PSRAM or Linux Native.';

  @override
  String get vehicleSpeed_32ceef => 'Vehicle speed';

  @override
  String get regeneratePrivateKey_4eb698 => 'Regenerate Private Key';

  @override
  String get generateANewPrivateKeyTo_cb7634 =>
      'Generate a new private key to replace the one currently in use. The public key will automatically be regenerated from your private key.';

  @override
  String get backupYourPrivateKeyToYour_eef405 =>
      'Backup your private key to your iCloud keychain.';

  @override
  String get messagesSeparateWith_efc965 => 'Messages separate with |';

  @override
  String get cannedMessages_f068fb => 'Canned Messages';

  @override
  String get storeForward_05111b => 'Store & Forward';

  @override
  String get paxCounter_34f998 => 'PAX Counter';

  @override
  String get soilTemp_e10385 => 'Soil Temp';

  @override
  String get rangeTest_c0e745 => 'Range Test';

  @override
  String get controlType_b68319 => 'Control Type';

  @override
  String get preciseLocation_bdfcca => 'Precise Location';

  @override
  String get traffic_6990f2 => 'Traffic';

  @override
  String get tertiaryAdminKey_bc13d6 => 'Tertiary Admin Key';

  @override
  String get deleteAllConfigKeysAndBle_cca1f1 =>
      'Delete all config, keys and BLE bonds? ';

  @override
  String get deleteAllConfig_8a83a4 => 'Delete all config? ';

  @override
  String get deleteNode_d5a0b2 => 'Delete Node?';

  @override
  String get batteryLevel_9ffc19 => 'Battery Level';

  @override
  String get deviceGps_a724ae => 'Device GPS';

  @override
  String get positionFlags_813b55 => 'Position Flags';

  @override
  String get color_84b22e => 'Color';

  @override
  String get display_0cca12 => 'Display';

  @override
  String get deviceScreen_566ed6 => 'Device Screen';

  @override
  String get thisWillDisableFixedPositionAnd_d42ce0 =>
      'This will disable fixed position and remove the currently set position.';

  @override
  String get thisWillSendACurrentPosition_45fe3d =>
      'This will send a current position from your phone and enable fixed position.';

  @override
  String get airtime_060fe3 => 'Airtime';

  @override
  String get ringtoneTransferLanguageRtttlRingtoneString_7d5b14 =>
      'Ringtone Transfer Language(RTTTL) Ringtone String used by supported buzzers in external notifications.';

  @override
  String get triggerEventType_8a7f87 => 'Trigger event type';

  @override
  String get ledOutputDriveCurrent_1fa019 => 'LED output drive current.';

  @override
  String get mirrorOnly_543934 => 'Mirror only';

  @override
  String get nodeLogOnly_3a7130 => 'Node log only';

  @override
  String get positionPrecision_01dd31 => 'Position precision';

  @override
  String get prioritizesBroadcastingGpsPositionPackets_090b6f =>
      'Prioritizes broadcasting GPS position packets.';

  @override
  String get prioritizesBroadcastingTelemetryPackets_650606 =>
      'Prioritizes broadcasting telemetry packets.';

  @override
  String get tracerouteNotFound_b165bf => 'Traceroute not found';

  @override
  String get tracerouteSentWaitingForAResponse_9a18a6 =>
      'Traceroute sent; waiting for a response';

  @override
  String get traceroutes_84a6df => 'Traceroutes';

  @override
  String get noTraceroutes_921f96 => 'No traceroutes';

  @override
  String get dark_bd16b2 => 'Dark';

  @override
  String get eachNodeHasItsOwnDatabase_534196 =>
      'Each node has its own database: nodes, channels, messages and a mirror copy. When the limit is exceeded, the least recently used database and its conversations are deleted; 0 keeps all databases. The open database cannot be deleted.';

  @override
  String get thisNodeHasNeitherWiFi_ee205d =>
      'This node has neither Wi-Fi nor Ethernet.';

  @override
  String get removedFromFavorites_f3503a => 'Removed from favorites';

  @override
  String get reactionNotifications_cb9243 => 'Reaction notifications';

  @override
  String get remoteHardware_9cd039 => 'Remote hardware';

  @override
  String get deleteDatabase_97a78b => 'Delete database?';

  @override
  String get deleteImage_8faab6 => 'Delete image?';

  @override
  String get deleteMap_077c0a => 'Delete map';

  @override
  String get deleteExtraDatabases_ff4d99 => 'Delete extra databases?';

  @override
  String get specifiesHowToRotateOrInvert_c2e76b =>
      'Specifies how to rotate or invert the compass output for accurate display.';

  @override
  String get ukraineMhz_71f385 => 'Ukraine 433 MHz';

  @override
  String get smartInterval_e82120 => 'Smart interval';

  @override
  String get mentionsOfMyNode_dfdc0f => 'Mentions of my node';

  @override
  String get greenChannelLevelOfTheBacklight_82039b =>
      'Green channel level of the backlight LED.';

  @override
  String get redChannelLevelOfTheBacklight_eecf26 =>
      'Red channel level of the backlight LED.';

  @override
  String get blueChannelLevelOfTheBacklight_54c801 =>
      'Blue channel level of the backlight LED.';

  @override
  String get setManually_8f0d8a => 'Set manually';

  @override
  String get usePhonePosition_026914 => 'Use phone position';

  @override
  String get youHaveTheLatestVersion_6ae127 => 'You have the latest version';

  @override
  String get deprecatedInfrastructureRoleThatBreaksThe_9d25ee =>
      'Deprecated infrastructure role that breaks the mesh relay chain. Switch this node to a Router-based role (Router or Router Late).';

  @override
  String get legacyDevice_9f4169 => 'Legacy device';

  @override
  String get thisDeviceIsNoLongerSupported_1eacd7 =>
      'This device is no longer supported and receives no firmware updates.';

  @override
  String get communityDevice_ee5a2a => 'Community device';

  @override
  String get deviceThatDoesNotForwardPackets_56dca1 =>
      'Device that does not forward packets from other devices.';

  @override
  String get deviceThatTransmitsOnlyWhenNecessary_cbb9fa =>
      'Device that transmits only when necessary for stealth or power saving.';

  @override
  String get aCfgFileAsUsedBy_8cf2f0 =>
      'A .cfg file, as used by the official applications';

  @override
  String get theFileDoesNotAppearTo_bd6b67 =>
      'The file does not appear to be an image';

  @override
  String get theFileDoesNotAppearTo_788b13 =>
      'The file does not appear to be a key backup';

  @override
  String get theFileIsEmpty_e16485 => 'The file is empty';

  @override
  String get theFileIsTooLargeFor_f5e529 =>
      'The file is too large for a configuration';

  @override
  String get theFileWasSavedByA_ca52a5 =>
      'The file was saved by a newer application version';

  @override
  String get fixedPinForBluetoothPairingUsed_5e7b2a =>
      'Fixed PIN for Bluetooth pairing. Used in fixed PIN pairing mode';

  @override
  String get philippinesMhz_447f09 => 'Philippines 433 MHz';

  @override
  String get philippinesMhz_c66f5b => 'Philippines 868 MHz';

  @override
  String get philippinesMhz_6c76eb => 'Philippines 915 MHz';

  @override
  String get filtersAndSorting_7551fe => 'Filters and sorting';

  @override
  String get purple_13c197 => 'Purple';

  @override
  String get hops_859d39 => 'Hops';

  @override
  String get maximumHops_a86743 => 'Maximum hops';

  @override
  String get storeAndForward_61adb3 => 'Store and forward';

  @override
  String get storageAndDeletion_a10344 => 'Storage and deletion';

  @override
  String get accentColor_ff9b5d => 'Accent color';

  @override
  String get colorOfMessagesMentioningOrReplying_a39b9c =>
      'Color of messages mentioning or replying to you';

  @override
  String get colorOfMentionsAndRepliesTo_cbd753 =>
      'Color of mentions and replies to you';

  @override
  String get center_05b1c1 => 'Center';

  @override
  String get areaCenter_63f063 => 'Area center';

  @override
  String get particles_e6d802 => 'Particles';

  @override
  String get codecSampleRate_535520 => 'CODEC2 sample rate';

  @override
  String get chat_8c77e4 => 'Chat';

  @override
  String get whatIsNotSent_7dd3f5 => 'What is NOT sent';

  @override
  String get whatWillBeSent_e8db1a => 'What will be sent';

  @override
  String get whatYouDidWhatYouExpected_81e7ad =>
      'What you did, what you expected and what happened';

  @override
  String get whatIsWrongOptional_5f4ae1 => 'What is wrong (optional)';

  @override
  String get whatHappened_81dc9f => 'What happened';

  @override
  String get black_0d6b1a => 'Black';

  @override
  String get encryption_72622e => 'Encryption';

  @override
  String get gateway_715fc6 => 'Gateway';

  @override
  String get exportToFile_5ba2da => 'Export to file';

  @override
  String get exportPrivateKey_8cfcb4 => 'Export private key';

  @override
  String get thisDatabaseBelongsToTheCurrently_45a34e =>
      'This database belongs to the currently open node; it cannot be replaced';

  @override
  String get thisIsNotAMeshexDatabase_4c1a04 => 'This is not a Meshex database';

  @override
  String get thisIsNotAContactLink_e1159c => 'This is not a contact link';

  @override
  String get thisIsNotAMeshtasticChannel_036b26 =>
      'This is not a Meshtastic channel link';

  @override
  String get thisIsNotASqliteDatabase_c247f9 =>
      'This is not a SQLite database file';

  @override
  String get thisIsNotAMeshtasticConfiguration_21780c =>
      'This is not a Meshtastic configuration file';

  @override
  String get thisDatabaseIsOpen_86610c => 'This database is open';

  @override
  String get thisQrCodeContainsAFull_84c455 =>
      'This QR code contains a full configuration. It will replace your existing channels and radio settings.';

  @override
  String get s_b759c4 => 'S';

  @override
  String get se_e26c37 => 'SE';

  @override
  String get sw_58a11c => 'SW';

  @override
  String get japan_44a609 => 'Japan';

  @override
  String get aug_098b49 => 'Aug';

  @override
  String get apr_0ab944 => 'Apr';

  @override
  String get possiblySpoofedPositionInterferenceZone_80184e =>
      'possibly spoofed position (interference zone)';

  @override
  String get all_ef8ff2 => 'all';

  @override
  String get off_147380 => 'off';

  @override
  String get hpa_d96200 => 'hPa';

  @override
  String get locationServicesAreDisabledOnThe_c9a206 =>
      'location services are disabled on the phone';

  @override
  String get dec_e8b13c => 'Dec';

  @override
  String get waitingForResponse_ea1f81 => 'waiting for response';

  @override
  String get lastHours_154ae5 => 'last 2 hours';

  @override
  String get lastDays_3f4fcc => 'last 7 days';

  @override
  String get allTime_9790a7 => 'all time';

  @override
  String get lastHours_fee233 => 'last 24 hours';

  @override
  String get lastHour_5702d4 => 'last hour';

  @override
  String get loadingNodes_1c32b3 => 'loading nodes';

  @override
  String get mirror_53fbab => 'mirror';

  @override
  String get july_8510c0 => 'July';

  @override
  String get june_1e3af2 => 'June';

  @override
  String get kg_59ddef => 'kg';

  @override
  String get km_3ced3a => 'km';

  @override
  String get lx_cfc6c7 => 'lx';

  @override
  String get any_3290bc => 'any';

  @override
  String get mS_73183b => 'm/s';

  @override
  String get ma_6562f3 => 'mA';

  @override
  String get march_cd806e => 'March';

  @override
  String get may_7bbf85 => 'May';

  @override
  String get min_d6035d => 'min';

  @override
  String get rH_34dc16 => 'µR/h';

  @override
  String get gM_67c6f5 => 'µg/m³';

  @override
  String get mm_b8d125 => 'mm';

  @override
  String get marginal_e208a1 => 'marginal';

  @override
  String get connected_abb335 => 'connected';

  @override
  String get direct_95dc0c => 'direct';

  @override
  String get notSetTheFilterIsInactive_8aa65f =>
      'not set; the filter is inactive';

  @override
  String get unsupportedByTheFirmware_936c06 => 'unsupported by the firmware';

  @override
  String get disconnected_0cf65d => 'disconnected';

  @override
  String get disconnected_e29749 => 'disconnected';

  @override
  String get locationAccessDenied_606358 => 'location access denied';

  @override
  String get noKey_edc637 => 'no key';

  @override
  String get noResponse_967d69 => 'no response';

  @override
  String get noNodePublicKey_e13456 => 'no node public key';

  @override
  String get noNodePublicKeyWaitFor_78601d =>
      'no node public key; wait for its NodeInfo';

  @override
  String get noConnection_75a42a => 'no connection';

  @override
  String get noNodeConnection_114c0d => 'no node connection';

  @override
  String get theNodeDoesNotAcceptDirect_63d6ab =>
      'the node does not accept direct messages';

  @override
  String get nov_0adb0f => 'Nov';

  @override
  String get requiresFirmware_a63ae1 => 'requires firmware 2.7.20+';

  @override
  String get requiresFirmware_e37f17 => 'requires firmware 2.8+';

  @override
  String get waitingToReconnect_b168a0 => 'waiting to reconnect';

  @override
  String get oct_22e90b => 'Oct';

  @override
  String get primary_8a174a => 'primary';

  @override
  String get externalPower_963740 => 'external power';

  @override
  String get thePrimaryChannelCannotBeDeleted_1b4706 =>
      'the primary channel cannot be deleted';

  @override
  String get ping_1b6f5d => 'ping';

  @override
  String get poor_324298 => 'poor';

  @override
  String get bySnr_f87a18 => 'by SNR';

  @override
  String get byTime_5bad62 => 'by time';

  @override
  String get byName_21b8bf => 'by name';

  @override
  String get default_0d558f => 'default';

  @override
  String get byHops_90b84d => 'by hops';

  @override
  String get connected_f006c9 => 'connected';

  @override
  String get connecting_794e89 => 'connecting';

  @override
  String get receivingConfiguration_8a745a => 'receiving configuration';

  @override
  String get onConnectionLoss_24be13 => 'on connection loss';

  @override
  String get radio_c9a417 => 'radio';

  @override
  String get s_b40bbc => 's';

  @override
  String get ownNodeNotLoadedYet_b8cd83 => 'own node not loaded yet';

  @override
  String get sep_309c10 => 'Sep';

  @override
  String get theServerDidNotReturnA_df447b =>
      'the server did not return a report number';

  @override
  String get network_2f481e => 'network';

  @override
  String get correctedUsingNeighbors_e10fad => 'corrected using neighbors';

  @override
  String get tooManyReportsTryAgainLater_6816c9 =>
      'too many reports; try again later';

  @override
  String get theNodeConnectionChanged_1d3493 => 'the node connection changed';

  @override
  String get fair_f2d6a6 => 'fair';

  @override
  String get test_0ebb88 => 'test';

  @override
  String get mirrorOnly_cb09e9 => 'mirror only';

  @override
  String get justNow_c47cbe => 'just now';

  @override
  String get theContactHasNoPublicKey_3c0ca0 => 'the contact has no public key';

  @override
  String get yourNodeHasNoCoordinates_1602cf => 'your node has no coordinates';

  @override
  String get feb_4d7ceb => 'Feb';

  @override
  String get hop_bbae58 => 'hop';

  @override
  String get hops_070a7f => 'hops';

  @override
  String get hops_c54799 => 'hops';

  @override
  String get good_d5f5ec => 'good';

  @override
  String get jan_28e060 => 'Jan';

  @override
  String get defaultKhz_0f9e1a => 'Default (250 kHz)';

  @override
  String get defaultKhz_696623 => 'Default (812.5 kHz)';

  @override
  String get rotatesWithThePhone_3acc7b => 'Rotates with the phone';

  @override
  String get rotateWithTwoFingersWhenDisabled_194ca1 =>
      'Rotate with two fingers. When disabled, north stays at the top.';

  @override
  String get noNodesWithCoordinatesMatchThe_70925b =>
      'No nodes with coordinates match the filter.';

  @override
  String get nothingMatchesTheFilter_42d5b4 => 'Nothing matches the filter';

  @override
  String get supportedDevice_7bbcea => 'Supported device';

  @override
  String get supportedWithFirmwareUpdatesSpecializedForm_a06e6b =>
      'Supported, with firmware updates; specialized form factor.';

  @override
  String get support_6ae569 => 'Support';

  @override
  String get connectToTheLastNodeOn_98c221 =>
      'Connect to the last node on startup';

  @override
  String get connectingToAMirrorIsOptional_975b0b =>
      'Connecting to a mirror is optional; you choose the address. When checking an address or connecting, the server sees your connection IP, request times and parameters, application version and platform. The server may offer image and report services at other addresses. The respective service operator controls content, logs and retention; the client does not manage that server. Ask the operator about server data processing and deletion.';

  @override
  String get connectingToACommunityServer_a8bcbd =>
      'Connecting to a community server';

  @override
  String get connectedSince_c5387f => 'Connected since';

  @override
  String get connectTheNodeUsingAUsb_c6b502 =>
      'Connect the node using a USB cable';

  @override
  String get connectToANode_6caeff => 'Connect to a node';

  @override
  String get connectToANodeToImport_c0f2ca => 'Connect to a node to import';

  @override
  String get connectToANodeToSend_67b4d9 =>
      'Connect to a node to send messages';

  @override
  String get connectToYourOwnNode_d2f276 => 'Connect to your own node';

  @override
  String get connectToYourOwnNode_cefdf1 => 'Connect to your own node.';

  @override
  String get waitBeforeRepeatingTheCommand_4113a0 =>
      'Wait before repeating the command';

  @override
  String get pleaseWaitThisActionIsTemporarily_4a28f0 =>
      'Please wait; this action is temporarily unavailable';

  @override
  String get signPacketsFirmware_c59ca8 => 'Sign packets (firmware 2.8)';

  @override
  String get signature_a5dcf3 => 'Signature';

  @override
  String get signatureRejectedHasTheNodeKey_2b76db =>
      'Signature rejected. Has the node key changed? Try again later';

  @override
  String get senderSignatureVerified_96ee0d => 'Sender signature verified';

  @override
  String get details_7e4277 => 'Details';

  @override
  String get subnet_05d5fa => 'Subnet';

  @override
  String get acknowledgmentVerificationFailedPossibleForgery_c5e853 =>
      'Acknowledgment verification failed; possible forgery';

  @override
  String get report_5405a3 => 'Report';

  @override
  String get reportThisImage_07a666 => 'Report this image?';

  @override
  String get pleaseSelectARegion_a28cc4 => 'Please select a region';

  @override
  String get positionNotSetYetChooseIts_607bea =>
      'Position not set yet; choose its source';

  @override
  String get positionBroadcast_9b9f9c => 'Position broadcast';

  @override
  String get positionSentWaitingForAResponse_640d17 =>
      'Position sent; waiting for a response';

  @override
  String get phonePosition_68a6a2 => 'Phone position';

  @override
  String get searchFromTheNodeList_a208a5 => 'Search from the node list';

  @override
  String get searchSettings_69a03f => 'Search settings';

  @override
  String get searchMessages_b03790 => 'Search messages';

  @override
  String get searchingForPorts_eea068 => 'Searching for ports…';

  @override
  String get nothingHereYet_ea91cf => 'Nothing here yet';

  @override
  String get showAll_9d04f0 => 'Show all';

  @override
  String get showAllNodes_174d10 => 'Show all nodes';

  @override
  String get showMore_b53ec8 => 'Show more';

  @override
  String get showIgnoredNodes_48f862 => 'Show ignored nodes';

  @override
  String get showImages_436fda => 'Show images';

  @override
  String get showHiddenMessages_4e0ac3 => 'Show hidden messages';

  @override
  String get privacyPolicy_4041aa => 'Privacy policy';

  @override
  String get retrievingKeyFromMirror_8c97ce => 'Retrieving key from mirror…';

  @override
  String get retrievingPublicKeyFromMirror_c82d52 =>
      'Retrieving public key from mirror…';

  @override
  String get attempts_002dd4 => 'Attempts';

  @override
  String get noPortsFound_cc35ea => 'No ports found';

  @override
  String get theNodeWillRestartAfterWriting_a91c98 =>
      'The node will restart after writing and the connection will be interrupted.';

  @override
  String get timeSinceTheLastPacketFrom_b027b2 =>
      'Time since the last packet from the node';

  @override
  String get showPreviewsOfImageServiceLinks_92d5b2 =>
      'Show previews of image service links from the connected server in the message feed';

  @override
  String get preset_a6549e => 'Preset';

  @override
  String get uploadingAnImageSendsTheFile_5e9db2 =>
      'Uploading an image sends the file and node ID with a signed request to the selected service. Anyone with the link can view the image. Reporting sends the node ID, image ID and your reason. You can delete your own image if the service supports it and the application has retained its deletion token. This does not delete copies saved by other users.';

  @override
  String get loadingMapsSendsYourIpAddress_c7eb25 =>
      'Loading maps sends your IP address and tile requests to the tile server. Depending on the map style, OpenStreetMap, OpenTopoMap, CARTO or a configured proxy is used. The offline map is downloaded from the Meshex website. Builds with their own update checker use the GitHub API; automatic checks can be disabled in About.';

  @override
  String get whenCheckingAnAddressOrConnecting_ac269f =>
      'When checking an address or connecting, the server receives:\n• Your connection IP address and request times;\n• Application version and platform;\n• Requested data, such as the viewed node ID or message history range.\nThe operator may retain this information in server logs.';

  @override
  String get theFirmwareAlwaysPreservesFavoritesIn_0ef245 =>
      'The firmware always preserves favorites in this role.';

  @override
  String get zoomIn_0c937d => 'Zoom in';

  @override
  String get appConnectedOrStandaloneMessagingDevice_4df636 =>
      'App-connected or standalone messaging device.';

  @override
  String get theApplicationWillKeepRunningIn_035e16 =>
      'The application will keep running in the background, receiving messages and maintaining the node connection. Restore the window using the tray icon, or quit using its menu. You can change this in application settings.';

  @override
  String get deliveredWhileTheApplicationIsRunning_ef1ca3 =>
      'Delivered while the application is running, including in the background. Sounds and banners are controlled by system notification settings.';

  @override
  String get tracerouteResponseReceived_2f2fbf =>
      'Traceroute response received';

  @override
  String get checkAndEnable_38d621 => 'Check and enable';

  @override
  String get checkAndApply_5b616e => 'Check and apply';

  @override
  String get checkForUpdates_fa7bfc => 'Check for updates';

  @override
  String get rangeTestEnabled_eed1b9 => 'Range test enabled';

  @override
  String get checkLatitudeLongitudeAndAltitude_3d4bed =>
      'Check latitude, longitude and altitude';

  @override
  String get checkOnStartup_6a3174 => 'Check on startup';

  @override
  String get viewedMapTilesOfflineClearCache_5c907e =>
      'Viewed map tiles offline, clear cache';

  @override
  String get firmwareIsStillUpdatedButSome_3ef828 =>
      'Firmware is still updated, but some features may be unavailable.';

  @override
  String get mapReporting_161284 => 'Map reporting';

  @override
  String get worksOfflineTheOnlineMapLayer_6371a8 =>
      'Works offline. The online map layer is disabled.';

  @override
  String get radio_e36f9c => 'Radio';

  @override
  String get radioMirror_971a23 => 'Radio + Mirror';

  @override
  String get radius_3dfacb => 'Radius';

  @override
  String get mapSizeMismatch_1787b9 => 'Map size mismatch';

  @override
  String get permissionsAndPhoneLocation_73702c =>
      'Permissions and phone location';

  @override
  String get allowTransmissionOverLoraRadioDisable_103bcc =>
      'Allow transmission over LoRa radio. Disable when changing antennas or testing on a bench.';

  @override
  String get disconnects_775091 => 'Disconnects';

  @override
  String get connectionDrops_1da695 => 'Connection drops';

  @override
  String get reactionsToMyMessages_3250d9 => 'Reactions to my messages';

  @override
  String get reactionsToYourMessages_2a4302 => 'Reactions to your messages.';

  @override
  String get ituRegionAmateurM_99c943 => 'ITU Region 3 / Amateur 2 m';

  @override
  String get ituRegionAmateurCm_7aef8d => 'ITU Region 3 / Amateur 70 cm';

  @override
  String get periodicallySendsTheLocationAsA_ea2b0e =>
      'Periodically sends the location as a message to the primary channel to help recover the device.';

  @override
  String get gpsModePhysicalHardware_11df68 => 'GPS mode (physical hardware)';

  @override
  String get ipvMode_ed8756 => 'IPv4 mode';

  @override
  String get terrain_35f3e9 => 'Terrain';

  @override
  String get retransmissions_4ec216 => 'Retransmissions';

  @override
  String get ringtoneAndCannedMessages_9b84af => 'Ringtone and canned messages';

  @override
  String get pink_6e9cd3 => 'Pink';

  @override
  String get russia_3d9a48 => 'Russia';

  @override
  String get n_67bbe9 => 'N';

  @override
  String get fromGithub_c134e1 => 'From GitHub';

  @override
  String get fromWebsite_225fd2 => 'From website';

  @override
  String get ne_29cd51 => 'NE';

  @override
  String get nw_9ecc3e => 'NW';

  @override
  String get build_930d47 => 'Build';

  @override
  String get resetFilters_03ead0 => 'Reset filters';

  @override
  String get details_99bf04 => 'Details';

  @override
  String get minimizeToTray_a1d8e8 => 'Minimize to tray';

  @override
  String get minimizeToTray_2b2ecc => 'Minimize to tray?';

  @override
  String get light_726f3e => 'Light';

  @override
  String get minimizeToTrayOnClose_720ae8 => 'Minimize to tray on close';

  @override
  String get ownNode_237648 => 'Own node';

  @override
  String get ownNodeIdModelFirmwareRole_2fdfaf =>
      'Own node: ID, model, firmware, role, region, preset, node and channel counts';

  @override
  String get contactTheDeveloper_ca5284 => 'Contact the developer';

  @override
  String get connection_cbc0f9 => 'Connection';

  @override
  String get theNodeConnectionAndNotificationsKeep_155e05 =>
      'The node connection and notifications keep working. When disabled, closing the window quits the application.';

  @override
  String get theNodeDisconnectedItAppearsTo_25e160 =>
      'The node disconnected; it appears to be restarting and applying settings. Check the values after reconnecting.';

  @override
  String get northUp_be8de1 => 'North up';

  @override
  String get rsyslogServer_49feb1 => 'rsyslog server';

  @override
  String get theServerMayAlsoOfferImage_a319bd =>
      'The server may also offer image and report services at other addresses. Their operators also see your IP address and requests. Image uploads send the file and node ID; reports send the node ID, image ID and reason. Diagnostic report contents are shown separately before submission.';

  @override
  String get communityServers_917685 => 'Community servers';

  @override
  String get serviceTemporarilyUnavailable_3bd3fd =>
      'Service temporarily unavailable';

  @override
  String get theImageServiceIsNotResponding_3a7b0d =>
      'The image service is not responding; check your internet connection';

  @override
  String get theServiceDidNotRespondIn_cfe928 =>
      'The service did not respond in time';

  @override
  String get theServiceDoesNotKnowYour_ca4501 =>
      'The service does not know your node yet: it must appear on the mirror map';

  @override
  String get serialPort_7f0e67 => 'Serial port';

  @override
  String get singaporeMhz_2b2999 => 'Singapore 923 MHz';

  @override
  String get blue_04954c => 'Blue';

  @override
  String get system_3ac98f => 'System';

  @override
  String get systemLightDarkOrBlackOled_edaf2a =>
      'System, light, dark or black (OLED)';

  @override
  String get scanQr_ba92dd => 'Scan QR';

  @override
  String get scanContact_be9772 => 'Scan contact';

  @override
  String get downloadMap_df5ad3 => 'Download map';

  @override
  String get numberOfDatabasesToKeep_dd8856 => 'Number of databases to keep';

  @override
  String get copied_892254 => 'Copied';

  @override
  String get copy_ed4950 => 'Copy';

  @override
  String get copyNumber_82ae50 => 'Copy number';

  @override
  String get copyLink_a44800 => 'Copy link';

  @override
  String get serialBaudRate_bbbfb6 => 'Serial baud rate';

  @override
  String get hideNodesBeyondTheRadius_93e947 => 'Hide nodes beyond the radius';

  @override
  String get hideMessagesMatchingFiltersInEvery_5d3016 =>
      'Hide messages matching filters in every channel and direct chat. Disable for an individual conversation in its menu.';

  @override
  String get hideNodesViaMqtt_a06257 => 'Hide nodes via MQTT';

  @override
  String get monitor_a0b8fc => 'Monitor';

  @override
  String get tooManyRequestsTryAgainLater_f13749 =>
      'Too many requests; try again later';

  @override
  String get wordOrRegexPattern_d88d91 => 'Word or regex:pattern';

  @override
  String get layers_16876c => 'Layers';

  @override
  String get domainNameSystemDns_6275c5 => 'Domain Name System (DNS)';

  @override
  String get lastHeard_07e526 => 'Last heard';

  @override
  String get heardOverTheAir_d31ee9 => 'Heard over the air';

  @override
  String get noLongerSupported_e39ef3 => 'No longer supported';

  @override
  String get connectionEventsPacketsAndNodeLog_745e44 =>
      'Connection events, packets and node log';

  @override
  String get connection_0427c0 => 'Connection';

  @override
  String get connectionDuration_c69bbf => 'Connection duration';

  @override
  String get unitedStatesOfAmerica_7fc1f6 => 'United States of America';

  @override
  String get messageFromAnIgnoredNodeTap_0685fd =>
      'Message from an ignored node; tap to show';

  @override
  String get noMessagesYet_165664 => 'No messages yet';

  @override
  String get messagesFromIgnoredNodesAreCollapsed_379dd7 =>
      'Messages from ignored nodes are collapsed; tap to expand them. When disabled, they are hidden completely';

  @override
  String get messagesFromHiddenChannelsAreNot_ae5ae7 =>
      'Messages from hidden channels are not loaded from the mirror. Restore a channel to load its feed again.';

  @override
  String get messagesContainingTheseWordsWillBe_3bfbda =>
      'Messages containing these words will be hidden. Whole words are matched, ignoring case; regex:pattern specifies a regular expression.';

  @override
  String get giveThisNumberToTheDeveloper_53370d =>
      'Give this number to the developer to help find your report.';

  @override
  String get bluetoothPairingOnLinux_5f59c4 => 'Bluetooth pairing on Linux';

  @override
  String get sort_ed0301 => 'Sort';

  @override
  String get connectionStatusTransportBleNameOr_ccaddd =>
      'Connection status: transport (BLE name or node address), attempts and disconnects';

  @override
  String get savingToNode_283e94 => 'Saving to node';

  @override
  String get saved_f0dff5 => 'Saved';

  @override
  String get saveTheSettingsTheProxyWill_d1d086 =>
      'Save the settings: the proxy will connect once the client proxy is enabled on the node.';

  @override
  String get saveToFile_cdda1c => 'Save to file';

  @override
  String get saveChannel_cc1444 => 'Save channel?';

  @override
  String get saveUserConfigurationToS_8e9bf5 =>
      'Save user configuration to %s?';

  @override
  String get saveBluetoothSettings_0dcf49 => 'Save Bluetooth settings?';

  @override
  String get saveMqttSettings_fd988d => 'Save MQTT settings?';

  @override
  String get saveStoreForwardSettings_bb7b6d =>
      'Save Store & Forward settings?';

  @override
  String get saveTakSettings_a0c983 => 'Save TAK settings?';

  @override
  String get saveSecuritySettings_a7801d => 'Save security settings?';

  @override
  String get saveExternalNotificationSettings_96386a =>
      'Save external notification settings?';

  @override
  String get saveDetectionSensorSettings_b580f0 =>
      'Save detection sensor settings?';

  @override
  String get saveAudioSettings_8ccb7e => 'Save audio settings?';

  @override
  String get saveNeighborInformationSettings_c94aec =>
      'Save neighbor information settings?';

  @override
  String get saveAmbientLightingSettings_c54691 =>
      'Save ambient lighting settings?';

  @override
  String get savePowerSettings_0a3030 => 'Save power settings?';

  @override
  String get savePositionSettings_876ad7 => 'Save position settings?';

  @override
  String get saveSerialSettings_9fde53 => 'Save serial settings?';

  @override
  String get saveNetworkSettings_5ed6f6 => 'Save network settings?';

  @override
  String get saveCannedMessageSettings_2594d4 =>
      'Save canned message settings?';

  @override
  String get savePaxCounterSettings_2cf0b9 => 'Save pax counter settings?';

  @override
  String get saveTelemetrySettings_35193a => 'Save telemetry settings?';

  @override
  String get saveRangeTestSettings_284561 => 'Save range test settings?';

  @override
  String get saveRemoteHardwareSettings_bee1fe =>
      'Save remote hardware settings?';

  @override
  String get saveTrafficManagementSettings_22a20b =>
      'Save traffic management settings?';

  @override
  String get saveDeviceSettings_be53bb => 'Save device settings?';

  @override
  String get saveDisplaySettings_d04519 => 'Save display settings?';

  @override
  String get saveFile_d10137 => 'Save file';

  @override
  String get linksInSentMessagesWillStop_a4253e =>
      'Links in sent messages will stop working.';

  @override
  String get contactLink_3b3d44 => 'Contact link';

  @override
  String get theLinkIsEmpty_800d53 => 'The link is empty';

  @override
  String get linkCopied_49261e => 'Link copied';

  @override
  String get theLinkIsTooLong_75ef62 => 'The link is too long';

  @override
  String get stop_6d714e => 'Stop';

  @override
  String get bluetoothConnectionStrategy_56baed =>
      'Bluetooth connection strategy';

  @override
  String get posixTimeZoneDefinition_87d573 => 'POSIX time zone definition';

  @override
  String get dewPoint_2b7056 => 'Dew point';

  @override
  String get thailand_03ddbe => 'Thailand';

  @override
  String get taiwan_2cc337 => 'Taiwan';

  @override
  String get messageTextTheLogContainsOnly_d95f22 =>
      'Message text (the log contains only its size)';

  @override
  String get currentApplicationSettingsAndRecentConnections_ae2892 =>
      'Current application settings and recent connections will be replaced with data from the file. Node databases will not change.';

  @override
  String get mirror_14fdf3 => '(mirror)';

  @override
  String get khz_872eb4 => '125 kHz';

  @override
  String get khz_501421 => '203.125 kHz';

  @override
  String get h_4c8c75 => '24H';

  @override
  String get khz_1ebb85 => '31 kHz';

  @override
  String get khz_d95d4a => '406.25 kHz';

  @override
  String get khz_ac5e55 => '500 kHz';

  @override
  String get khz_91b5e4 => '62 kHz';

  @override
  String get d_3ecbe0 => '7D';

  @override
  String get khz_56b83b => '812.5 kHz';

  @override
  String get nodeMac_49269c => '<Node MAC>';

  @override
  String get bluetoothEnabled_3469b5 => 'Bluetooth enabled';

  @override
  String get bluetoothAndTheLocalNetworkConnect_2e6ed6 =>
      'Bluetooth and the local network connect to nodes; the camera scans QR codes. Notifications report application events. Location is used when selecting the phone position and when sharing it with your node. Sharing is off by default. The node firmware may broadcast coordinates according to its settings. Permissions can be changed in the operating system settings.';

  @override
  String get codecEnabled_8e6ef2 => 'CODEC 2 enabled';

  @override
  String get serialPortEnabled_c878e2 => 'Serial port enabled';

  @override
  String get ethernetEnabled_7440bf => 'Ethernet enabled';

  @override
  String get gpioPinForThePwmBuzzer_ac885c => 'GPIO pin for the PWM buzzer';

  @override
  String get gpioPinForTheUserButton_a5b887 =>
      'GPIO pin for the user button; can be reassigned on boards with multiple buttons';

  @override
  String get mirrorId_9b8cbe => 'Mirror ID';

  @override
  String get packetId_869cfb => 'Packet ID';

  @override
  String get packetIdHex_7d2120 => 'Packet ID (hex)';

  @override
  String get theIdMatchesTheNodeMac_ca22a6 =>
      'The ID matches the node MAC address; no repair is needed.';

  @override
  String get nodeIpOrHostname_4e0881 => 'Node IP or hostname';

  @override
  String get theJsonFileContainsTheUnencrypted_470e15 =>
      'The JSON file contains the unencrypted private key of your node. Anyone with this file can use your node key. Keep the file secure and do not share it.';

  @override
  String get communitySupportedLinuxDevice_372e0a =>
      'Community-supported Linux device.';

  @override
  String get macAndDeviceIdOfThe_018be2 =>
      'MAC and device_id of the connected node';

  @override
  String get thisMacBelongsToADifferent_c8f6b3 =>
      'This MAC belongs to a different node';

  @override
  String get yourNodeMacIsUnknown_80e80c => 'Your node MAC is unknown';

  @override
  String get mqttEnabled_47dd00 => 'MQTT enabled';

  @override
  String get meshexIsAClientForMeshtastic_b9497b =>
      'Meshex is a client for Meshtastic radio nodes. The application stores messages, node details and positions, settings, connected node configurations and a diagnostic log on this device. Clearing application data affects local data, not radio traffic or third-party servers.';

  @override
  String get ntpServer_0f61dc => 'NTP server';

  @override
  String get nodeinfoSent_16d722 => 'NodeInfo sent';

  @override
  String get nodeinfoBroadcast_f42668 => 'NodeInfo broadcast';

  @override
  String get paFanDisabled_a9c1ad => 'PA fan disabled';

  @override
  String get storeForwardEnabled_a01444 => 'Store & Forward enabled';

  @override
  String get telegramOrEmailIfYouWould_8f673d =>
      'Telegram or email, if you would like a reply';

  @override
  String get wiFiEnabled_c884a7 => 'Wi-Fi enabled';

  @override
  String get fromNumMustPrecedeToNum_be1e5b => 'from_num must precede to_num';

  @override
  String get possiblySpoofedPosition_5ca05b => '· possibly spoofed position';

  @override
  String get corrected_a0b938 => '· corrected';

  @override
  String get automaticPortraitLandscapeReversedOrientations_3e0120 =>
      'Automatic, portrait, landscape, reversed orientations';

  @override
  String get automaticallyCyclesThroughDisplayPagesAt_13281c =>
      'Automatically cycles through display pages at the configured interval.';

  @override
  String get adminAccessAndFlagsNodeKeys_502b16 =>
      'Admin access and flags (node keys are preserved)';

  @override
  String get mqttServerAddress_615ec8 => 'MQTT server address';

  @override
  String get mirrorAddressAndData_e46280 => 'Mirror address and data';

  @override
  String get mirrorServerAddressChatMessagesAnd_64453e =>
      'Mirror server address: chat messages and nodes from MQTT are loaded from this server. The application does not connect while the mirror is disabled. Checking the address also sends a request to that server.';

  @override
  String get landscape_53bf5f => 'Landscape';

  @override
  String get landscapeReversed_089eb6 => 'Landscape reversed';

  @override
  String get nodeHardwareIds_a78041 => 'Node hardware IDs';

  @override
  String get applicationDatabase_4d6431 => 'Application database';

  @override
  String get databaseSaved_190541 => 'Database saved';

  @override
  String get nodeDatabases_1e2d9d => 'Node databases';

  @override
  String get noNodeMirrorOnly_7434e1 => 'No node (mirror only)';

  @override
  String get noHighlight_14736b => 'No highlight';

  @override
  String get unencrypted_74bae3 => 'Unencrypted';

  @override
  String get securityChangesNodeKeysAndAdmin_a52c58 =>
      'Security changes node keys and admin access. Enable it only when restoring a backup of the same node.';

  @override
  String get teal_9161f9 => 'Teal';

  @override
  String get v_b25cd7 => 'V';

  @override
  String get theFollowingChannelsWereFoundIn_c3f485 =>
      'The following channels were found in the QR code. Existing channels will be preserved.';

  @override
  String get appliesToTheNodeListAnd_f9af88 =>
      'Applies to the node list and map. Nodes without coordinates and your own node remain visible.';

  @override
  String get theLinkContainsMoreThanChannels_158006 =>
      'The link contains more than 8 channels';

  @override
  String get theLinkHasNoChannelData_a0a60d => 'The link has no channel data';

  @override
  String get theLinkContainsNoChannels_a613c7 =>
      'The link contains no channels';

  @override
  String get theLinkHasNoLoraSettings_2b6cd1 =>
      'The link has no LoRa settings; channels can only be added';

  @override
  String get theFileWillContainYourNode_2c8772 =>
      'The file will contain your node and mirror addresses. Keep it private and do not share it.';

  @override
  String get theFileWillContainNodeKeys_7a17b9 =>
      'The file will contain node keys, channel keys and Wi-Fi/MQTT passwords. Do not share it.';

  @override
  String get theFileContainsNoNodeData_fba6b0 =>
      'The file contains no node data';

  @override
  String get theFileContainsNoKeys_274a37 => 'The file contains no keys';

  @override
  String get theFileContainsNoSettings_6865dd =>
      'The file contains no settings';

  @override
  String get theFileContainsNoApplicationSettings_276e18 =>
      'The file contains no application settings';

  @override
  String get yourCommentAndContactDetailsIf_7eb17d =>
      'Your comment and contact details, if provided';

  @override
  String get enterAtLeastCharacters_ffcd3a => 'Enter at least 2 characters';

  @override
  String get restore_c7aaa9 => 'Restore';

  @override
  String get osVersion_8aba4a => 'OS version';

  @override
  String get yourApplicationVersionIsOutdatedPlease_d5ccc4 =>
      'Your application version is outdated; please update';

  @override
  String get applicationVersionPhoneModelOsVersion_3c056a =>
      'Application version, phone model, OS version, language and time zone';

  @override
  String get vibrateOnNotification_d0009e => 'Vibrate on notification';

  @override
  String get nodeRowLayout_12026b => 'Node row layout';

  @override
  String get visibleOnlyToYou_e71a47 => 'Visible only to you';

  @override
  String get enablesAutomaticTakPliBroadcastsAnd_e4e185 =>
      'Enables automatic TAK PLI broadcasts and reduces routine broadcasts.';

  @override
  String get byEnablingThisFeatureYouAcknowledge_de04ee =>
      'By enabling this feature, you acknowledge and expressly consent to transmitting your device location in real time over MQTT without encryption. This location data may be used for real-time map reporting, device tracking and related telemetry.\n\nBecause map reports are unencrypted, third parties may permanently store and display your data. Meshtastic is not responsible for such storage, display or disclosure.\n\nI have read and understand the above. I voluntarily consent to the unencrypted transmission of my node data over MQTT.';

  @override
  String get enableBluetoothOnThisDevice_392fce =>
      'Enable Bluetooth on this device';

  @override
  String get enableMqttGateway_540669 => 'Enable MQTT gateway';

  @override
  String get enableCodecAudioEncodingDecodingFor_7f4387 =>
      'Enable Codec2 audio encoding/decoding for voice communication over the mesh network.';

  @override
  String get owner_926e3b => 'Owner';

  @override
  String get externalPower_684553 => 'External power';

  @override
  String get externalNotificationsEnabled_06341b =>
      'External notifications enabled';

  @override
  String get scrollDownAllMessagesRead_292955 =>
      'Scroll down; all messages read';

  @override
  String get questionsBugReportsAndPrivacyRequests_5ebcd5 =>
      'Questions, bug reports and privacy requests can be submitted in the Meshex project Issues. A GitHub account is required. Issues may be public: do not post private keys, passwords, precise coordinates or other personal information. Contact the community server operator about server content and data deletion.';

  @override
  String get mapRotation_8a6270 => 'Map rotation';

  @override
  String get allMessagesInThisChatWill_6baa0a =>
      'All messages in this chat will be deleted from this device. They will remain on the other device.';

  @override
  String get allFeaturesUnderActiveDevelopment_ce30a3 =>
      'All features, under active development.';

  @override
  String get alwaysOn_43ba2d => 'Always on';

  @override
  String get sendAnyway_c6bcaa => 'Send anyway';

  @override
  String get youChooseTheServerItsOperator_f140c4 =>
      'You choose the server. Its operator controls content, availability and data retention; the client does not manage that server. Connect only to operators you trust.';

  @override
  String get chooseAKeyToRestore_9fa859 => 'Choose a key to restore';

  @override
  String get selectAChannelOrConversation_3b7ddb =>
      'Select a channel or conversation';

  @override
  String get chooseFile_2e31da => 'Choose file';

  @override
  String get quit_026abb => 'Quit';

  @override
  String get disabled_d934ae => 'Disabled';

  @override
  String get altitudeM_4e463b => 'Altitude, m';

  @override
  String get gas_5d1111 => 'Gas';

  @override
  String get locationServicesAreDisabled_34928e =>
      'Location services are disabled';

  @override
  String get clusterNodes_d1274e => 'Cluster nodes';

  @override
  String get distantNodes_c51034 => 'Distant nodes';

  @override
  String get data_d8e5fd => 'Data';

  @override
  String get dataOnThisDevice_2ff795 => 'Data on this device';

  @override
  String get detectionSensorEnabled_1b4f0e => 'Detection sensor enabled';

  @override
  String get diagnosticReports_1eec79 => 'Diagnostic reports';

  @override
  String get theBlePinMustContainDigits_d88065 =>
      'The BLE PIN must contain 6 digits.';

  @override
  String get bluetoothWaitTime_de4a08 => 'Bluetooth wait time';

  @override
  String get forNodesWithoutGpsPhoneCoordinates_e96e7e =>
      'For nodes without GPS: phone coordinates are sent only to your own node. Its firmware broadcasts them according to its settings. Works while the application is open and connected.';

  @override
  String get setBothTheTimeWindowAnd_7dff47 =>
      'Set both the time window and packet count for rate limiting.';

  @override
  String get useDataToClearTheLocal_2715b2 =>
      'Use Data to clear the local database, and Security to remove a saved key backup. Manage exported files and operating system backups separately. Deleting local data does not recall radio packets or delete data held by other network participants. Application and privacy questions can be sent using the contact below.';

  @override
  String get addNote_57d0f4 => 'Add note';

  @override
  String get addedToFavorites_d0d718 => 'Added to favorites';

  @override
  String get rain_aad03f => 'Rain';

  @override
  String get rainH_770fb0 => 'Rain 1h';

  @override
  String get rainH_b2fa03 => 'Rain 24h';

  @override
  String get delivered_9b68fb => 'Delivered';

  @override
  String get deliveredVerifiedByTheRecipient_0d8f81 =>
      'Delivered, verified by the recipient';

  @override
  String get moreEmoji_2bfd6b => 'More emoji';

  @override
  String get itsMirrorMessagesWillBeDeleted_d9e39c =>
      'Its mirror messages will be deleted and will no longer be loaded. You can restore the channel in mirror settings.';

  @override
  String get measurementUnitsShownOnTheDevice_573c1c =>
      'Measurement units shown on the device display.';

  @override
  String get ifYourPhoneCannotConnectAfter_9fa7f4 =>
      'If your phone cannot connect after the node restarts, restart the node again.';

  @override
  String get hasCoordinates_4d4419 => 'Has coordinates';

  @override
  String get hasPublicKey_dd027c => 'Has public key';

  @override
  String get hasPublicKeyPki_b08915 => 'Has public key (PKI)';

  @override
  String get reportSent_050a2d => 'Report sent';

  @override
  String get theReportWillBeSentTo_5e4e2b =>
      'The report will be sent to the server operator';

  @override
  String get waitingForCoordinates_8cafb9 => 'Waiting for coordinates';

  @override
  String get waitingForANodeConnection_617dba =>
      'Waiting for a node connection';

  @override
  String get journal_67ade7 => 'Journal';

  @override
  String get reportLog_c75086 => 'Report log';

  @override
  String get applicationAndNodeLogsAndDetails_395cd3 =>
      'Application and node logs and details';

  @override
  String get applicationLogFromRecentLaunchesConnection_a484f1 =>
      'Application log from recent launches: connection events, service packets, node firmware logs and errors. The log contains IDs and names of nodes received over the air';

  @override
  String get journalCopied_1ee14a => 'Journal copied';

  @override
  String get w_a9d7eb => 'W';

  @override
  String get outsideTheDownloadedSaintPetersburgMap_24a118 =>
      'Outside the downloaded Saint Petersburg map';

  @override
  String get forget_90bc7d => 'Forget';

  @override
  String get loadMore_010963 => 'Load more';

  @override
  String get loadFromFile_e47fd3 => 'Load from file';

  @override
  String get imageUploadsAreBlockedForYour_4267f6 =>
      'Image uploads are blocked for your account';

  @override
  String get downloadCanceled_13f622 => 'Download canceled';

  @override
  String get radioTrafficUpload_cd86b2 => 'Radio traffic upload';

  @override
  String get maximumHopCountByDefaultHigher_c79f9b =>
      'Maximum hop count, 3 by default. Higher values increase congestion and should be used with caution. Messages with 0 hops will not receive acknowledgments.';

  @override
  String get privateKey_378280 => 'Private key';

  @override
  String get replaceDatabase_1a5ae6 => 'Replace database?';

  @override
  String get noRadioMeasurementsYet_45e333 => 'No radio measurements yet';

  @override
  String get note_917b58 => 'Note';

  @override
  String get write_4be730 => 'Write';

  @override
  String get writeConfigurationFromAFileTo_5b4b13 =>
      'Write configuration from a file to the node';

  @override
  String get requestSentWaitingForAResponse_8172e2 =>
      'Request sent; waiting for a response';

  @override
  String get request_ebdfd9 => 'Request';

  @override
  String get requestTelemetry_c5374e => 'Request telemetry';

  @override
  String get charge_b1ad91 => 'Charge';

  @override
  String get encrypted_9cdd75 => 'Encrypted';

  @override
  String get nodesYouHaveConnectedToWill_436ad0 =>
      'Nodes you have connected to will appear here';

  @override
  String get green_6989f8 => 'Green';

  @override
  String get green_a0f667 => 'Green';

  @override
  String get mirror_66ace6 => 'Mirror';

  @override
  String get mirrorInterferenceZonesCouldNotBe_7b5b5d =>
      'Mirror: interference zones could not be loaded';

  @override
  String get mirrorNodesCouldNotBeLoaded_41ed72 =>
      'Mirror: nodes could not be loaded';

  @override
  String get identifier_754cba => 'Identifier';

  @override
  String get searchingTheNetwork_bdab2d => 'Searching the network…';

  @override
  String get searchingForNodes_ba19cf => 'Searching for nodes…';

  @override
  String get fromMirror_f5296f => 'From mirror';

  @override
  String get favoriteAndIgnoredNodesAreAlways_f2c698 =>
      'Favorite and ignored nodes are always preserved. Other nodes are removed from the application database after the configured number of days. Nodes with PKC keys are kept for at least 7 days. Only nodes absent from the device node database are removed; your own node and nodes with notes are also preserved.';

  @override
  String get imagesAndReports_a79f68 => 'Images and reports';

  @override
  String get theLinkContainsDuplicateChannelNames_3b33c1 =>
      'The link contains duplicate channel names';

  @override
  String get importDatabaseFromFile_81e7f3 => 'Import database from file';

  @override
  String get importNodeDatabaseFromFile_7ff7a5 =>
      'Import node database from file';

  @override
  String get importFromFile_f190b3 => 'Import from file';

  @override
  String get sensorNameForMeshMessages_40e05a =>
      'Sensor name for mesh messages';

  @override
  String get nameOrId_ffe28b => 'Name or !id';

  @override
  String get nodeNameOrId_ee4d66 => 'Node name or ID';

  @override
  String get indigo_03aba6 => 'Indigo';

  @override
  String get nodeInformationBroadcastInterval_0a98b2 =>
      'Node information broadcast interval';

  @override
  String get airQualityUpdateInterval_008585 => 'Air quality update interval';

  @override
  String get environmentMetricsUpdateInterval_5d18f2 =>
      'Environment metrics update interval';

  @override
  String get deviceMetricsUpdateInterval_d890da =>
      'Device metrics update interval';

  @override
  String get powerMetricsUpdateInterval_d4bac6 =>
      'Power metrics update interval';

  @override
  String get stateBroadcastInterval_bec9d7 => 'State broadcast interval';

  @override
  String get repeatInterval_51be08 => 'Repeat interval';

  @override
  String get mapReportInterval_bee95f => 'Map report interval';

  @override
  String get neighborInformation_2b7dad => 'Neighbor information';

  @override
  String get neighborInformationEnabled_c25a9a =>
      'Neighbor information enabled';

  @override
  String get infrastructureNodeThatAlwaysRetransmitsPackets_704f22 =>
      'Infrastructure node that always retransmits packets once, but only after all other modes. Appears in the node list. Not recommended for rooftop nodes.';

  @override
  String get search_58212e => 'Search';

  @override
  String get useTheModemPresetInsteadOf_941abf =>
      'Use the modem preset instead of manually setting bandwidth, spreading factor and coding rate';

  @override
  String get useDownloadedMap_9e8629 => 'Use downloaded map';

  @override
  String get codecBitrateTheSampleRateIs_1a0df2 =>
      'Codec2 bitrate. The sample rate is always 8 kHz. Lower bitrates use less bandwidth but reduce audio quality.';

  @override
  String get repair_9b1c9a => 'Repair';

  @override
  String get repairNodeId_47d759 => 'Repair node ID';

  @override
  String get repairNodeId_16de55 => 'Repair node ID?';

  @override
  String get repairAndRestart_0ef1ee => 'Repair and restart';

  @override
  String get repairedTheNodeMacWasSent_4c3760 =>
      'Repaired: the node MAC was sent to the node';

  @override
  String get source_8290a3 => 'Source';

  @override
  String get kazakhstanMhz_c0f5fd => 'Kazakhstan 433 MHz';

  @override
  String get kazakhstanMhz_26f59e => 'Kazakhstan 863 MHz';

  @override
  String get howOftenToRequestGpsCoordinates_8f0f04 =>
      'How often to request GPS coordinates (intervals below 10 seconds keep GPS on continuously).';

  @override
  String get theChannelWillBeDisabledOn_3cb75d =>
      'The channel will be disabled on the node.';

  @override
  String get thisChannelExistsOnlyInThe_30433a =>
      'This channel exists only in the mirror; you cannot send messages to it.';

  @override
  String get channels_5488bf => 'Channels';

  @override
  String get channelsWillBeAddedToThe_32e8d4 =>
      'Channels will be added to the node.';

  @override
  String get channelsWillBeAddedExistingChannels_dfb994 =>
      'Channels will be added; existing channels and LoRa settings will be preserved.';

  @override
  String get channelsAndLora_147acf => 'Channels and LoRa';

  @override
  String get channelsAndLoraSettingsOnThe_31a15a =>
      'Channels and LoRa settings on the node will be replaced.';

  @override
  String get channelsWillAppearAfterConnectingTo_e7a062 =>
      'Channels will appear after connecting to a node.';

  @override
  String get channelsSaved_dbb2d3 => 'Channels saved';

  @override
  String get map_5736d0 => 'Map';

  @override
  String get image_690092 => 'Image';

  @override
  String get imageUploadedStoredForDays_144c69 =>
      'Image uploaded; stored for 3 days';

  @override
  String get imageUnavailableDeletedOrExpired_82b7c1 =>
      'Image unavailable\n(deleted or expired)';

  @override
  String get theImageIsTooLarge_94ad38 => 'The image is too large';

  @override
  String get imageDeleted_e4b164 => 'Image deleted';

  @override
  String get theImageIsAlreadyGone_910faf => 'The image is already gone';

  @override
  String get mapsAndUpdateChecks_f48d47 => 'Maps and update checks';

  @override
  String get keyRestoredSaveTheSettings_92bb30 =>
      'Key restored; save the settings';

  @override
  String get theKeyDoesNotMatchThe_4c6326 =>
      'The key does not match the selected size';

  @override
  String get keyCopied_c184c1 => 'Key copied';

  @override
  String get theKeyMustBeBytesEncoded_04f2cd =>
      'The key must be 32 bytes encoded as base64';

  @override
  String get keysAndBackups_9b106e => 'Keys and backups';

  @override
  String get nodeKeysAndAdminAccess_7b222d => 'Node keys and admin access';

  @override
  String get keysSavedToAFileKeep_32f5b4 =>
      'Keys saved to a file. Keep it in a secure place';

  @override
  String get encryptionKeysPsksAndChannelNames_cfa888 =>
      'Encryption keys, PSKs and channel names';

  @override
  String get portrait_79fe4f => 'Portrait';

  @override
  String get portraitReversed_674692 => 'Portrait reversed';

  @override
  String get hopCount_6d7f43 => 'Hop count';

  @override
  String get chirpsPerSymbolRaisedToThis_f60898 =>
      'Chirps per symbol: 2 raised to this value.';

  @override
  String get commandSent_d331b9 => 'Command sent';

  @override
  String get contactOptional_309ca4 => 'Contact (optional)';

  @override
  String get pttPin_3c56da => 'PTT pin';

  @override
  String get contactImported_0f4d2f => 'Contact imported';

  @override
  String get projectContact_9535fa => 'Project contact';

  @override
  String get mapChecksumMismatch_da850d => 'Map checksum mismatch';

  @override
  String get nodeConfigurationsMayContainPrivateKeys_b72311 =>
      'Node configurations may contain private keys and passwords. Separate key backups are stored in the system secure storage; iOS uses the synchronized iCloud Keychain. Exported JSON contains an unencrypted private key. Settings files may also contain keys and passwords. Your chosen save location may be in the cloud. Delete exported files and backups separately when they are no longer needed.';

  @override
  String get coordinatesCopied_082ae9 => 'Coordinates copied';

  @override
  String get coordinatesOfEitherThePhoneOr_6668dd =>
      'Coordinates of either the phone or nodes';

  @override
  String get copyText_667f44 => 'Copy text';

  @override
  String get korea_522d28 => 'Korea';

  @override
  String get yourNodeShortNameInChannel_7ab080 =>
      'Your node short name in channel messages';

  @override
  String get positionCorrection_e7d3bd => 'Position correction';

  @override
  String get red_1686b6 => 'Red';

  @override
  String get mapCache_fc6703 => 'Map cache';

  @override
  String get licenses_488dd1 => 'Licenses';

  @override
  String get directMessages_96a4a7 => 'Direct messages';

  @override
  String get mhz_b6fe8f => 'MHz';

  @override
  String get m_1ac436 => 'MΩ';

  @override
  String get maximumTimeBetweenNodePositionBroadcasts_118530 =>
      'Maximum time between node position broadcasts.';

  @override
  String get malaysiaMhz_8949b1 => 'Malaysia 433 MHz';

  @override
  String get malaysiaMhz_2a5dd6 => 'Malaysia 919 MHz';

  @override
  String get route_b765f3 => 'Route';

  @override
  String get returnRoute_9e78e2 => 'Return route';

  @override
  String get minimumTimeBetweenDetectionBroadcasts_e6291c =>
      'Minimum time between detection broadcasts';

  @override
  String get minimumTimeBetweenDetectionBroadcasts_ef8eba =>
      'Minimum time between detection broadcasts.';

  @override
  String get minimumDistanceForSmartPositionBroadcasting_c4fdb9 =>
      'Minimum distance for smart position broadcasting.';

  @override
  String get model_f1f1ee => 'Model';

  @override
  String get deviceModel_6b816f => 'Device model';

  @override
  String get airQualityModuleEnabled_341f24 => 'Air quality module enabled';

  @override
  String get powerMetricsModuleEnabled_74b93b => 'Power metrics module enabled';

  @override
  String get transmitPower_a90731 => 'Transmit power';

  @override
  String get radioTransmitPowerLeaveZeroTo_bdb039 =>
      'Radio transmit power. Leave zero to use the maximum permitted level for the region, which is recommended for most devices.';

  @override
  String get myNode_933f3d => 'My node';

  @override
  String get myLocation_e77573 => 'My location';

  @override
  String get myLocationRefresh_d26be2 => 'My location (refresh)';

  @override
  String get notSupportedOnIphonesWithFace_7d312d =>
      'Not supported on iPhones with Face ID';

  @override
  String get connected_1578f2 => 'Connected';

  @override
  String get name_3de498 => 'Name';

  @override
  String get findNodesOnTheLocalNetwork_9f4117 =>
      'Find nodes on the local network';

  @override
  String get findNearbyNodes_37deaa => 'Find nearby nodes';

  @override
  String get message_bda589 => 'Message';

  @override
  String get voltage_5b3602 => 'Voltage';

  @override
  String get compassHeading_c9f066 => 'Compass heading';

  @override
  String get settingsWrittenTheNodeWillRestart_ce3279 =>
      'Settings written; the node will restart';

  @override
  String get applicationSettingsAndRecentConnectionsFor_cab177 =>
      'Application settings and recent connections, for example to restore them after reinstalling. The file contains your node and mirror addresses: do not share it.';

  @override
  String get settingsSaved_0c3942 => 'Settings saved';

  @override
  String get trafficManagementSettingsInThisApplication_691b03 =>
      'Traffic management settings in this application use the firmware 2.8 schema. Update your node firmware.';

  @override
  String get beginEditing_cfa550 => 'Begin editing';

  @override
  String get notEncrypted_c40021 => 'Not encrypted';

  @override
  String get notFoundAmongNodesOnThe_ec3654 =>
      'Not found among nodes on the map';

  @override
  String get doNotRemindMe_7319fc => 'Do not remind me';

  @override
  String get notSent_304893 => 'Not sent';

  @override
  String get couldNotOpenTheDownloadedMap_be745e =>
      'Could not open the downloaded map.';

  @override
  String get couldNotOpenTheSupportPage_eb8159 =>
      'Could not open the support page';

  @override
  String get couldNotRetrieveTheKeyFrom_693021 =>
      'Could not retrieve the key from the mirror';

  @override
  String get couldNotVerifyTheOfflineMap_f0dd0f =>
      'Could not verify the offline map';

  @override
  String get couldNotReadChannelData_1a56bc => 'Could not read channel data';

  @override
  String get couldNotReadMapSettings_9d3bfa => 'Could not read map settings';

  @override
  String get couldNotDownloadTheMapCheck_07b3ae =>
      'Could not download the map. Check your network and try again.';

  @override
  String get noMoreOftenThanEvery_3389cd => 'No more often than every';

  @override
  String get incorrectDeviceTime_bcddb3 => 'Incorrect device time';

  @override
  String get invalidRegularExpression_d0b364 => 'Invalid regular expression';

  @override
  String get invalidChannelDataInTheLink_d0da40 =>
      'Invalid channel data in the link';

  @override
  String get invalidAddress_e5fb1c => 'Invalid address';

  @override
  String get invalidIpvAddress_c9875b => 'Invalid IPv4 address';

  @override
  String get recent_1328d8 => 'Recent';

  @override
  String get nepalMhz_73462a => 'Nepal 865 MHz';

  @override
  String get locationAccessDeniedAllowItIn_fa90c3 =>
      'Location access denied; allow it in system settings';

  @override
  String get noMeasurementsForThisPeriod_c02810 =>
      'No measurements for this period';

  @override
  String get noNodeKeyConnectToYour_7e5d9a =>
      'No node key; connect to your own node';

  @override
  String get noKeyNotEncrypted_1c5fa9 => 'No key; not encrypted';

  @override
  String get noNodesWithCoordinatesThisIs_34558f =>
      'No nodes with coordinates.\nThis is normal: position broadcasting is disabled by default starting with firmware 2.8.';

  @override
  String get noAcknowledgment_f9cd9b => 'No acknowledgment';

  @override
  String get noPublicKey_fc72da => 'No public key';

  @override
  String get noNodePublicKeyWaitFor_f9fbc4 =>
      'No node public key. Wait for NodeInfo or retry loading it from the mirror in the node details.';

  @override
  String get noNodeConnection_8ce75b => 'No node connection';

  @override
  String get noDatabaseFile_c7a185 => 'No database file';

  @override
  String get noneOfTheNodesOnThis_79590a =>
      'None of the nodes on this route have coordinates';

  @override
  String get never_f5bf59 => 'Never';

  @override
  String get specializedDevice_be7b26 => 'Specialized device';

  @override
  String get newZealandMhz_66ff01 => 'New Zealand 865 MHz';

  @override
  String get newMessages_f8bbc3 => 'New messages';

  @override
  String get nodesInDatabase_b7f028 => 'Nodes in database';

  @override
  String get nodesOnRadio_f76516 => 'Nodes on radio';

  @override
  String get noNodesYetConnectToYour_c2e63b =>
      'No nodes yet.\nConnect to your own node.';

  @override
  String get nodeNoLongerIgnored_c2b973 => 'Node no longer ignored';

  @override
  String get theNodeWillBeRemovedFrom_e0fd0d =>
      'The node will be removed from your radio node database. It will reappear when heard again.';

  @override
  String get theNodeWillBeRemovedFrom_0c5eb5 =>
      'The node will be removed from the application. It will reappear when heard again.';

  @override
  String get theNodeHasNotBroadcastIts_198664 =>
      'The node has not broadcast its details yet; wait and try again later';

  @override
  String get theNodeHasNotSentIts_58663f =>
      'The node has not sent its details yet; wait for loading to finish.';

  @override
  String get theNodeHasNotSentThese_0e8dcb =>
      'The node has not sent these settings yet';

  @override
  String get nodeIgnored_cdfc8a => 'Node ignored';

  @override
  String get theNodeUsesARegionUnsupported_213978 =>
      'The node uses a region unsupported by this application. Select a supported region before saving.';

  @override
  String get nodeNotFound_9951e4 => 'Node not found';

  @override
  String get notAcknowledgedByTheNode_90929d => 'Not acknowledged by the node';

  @override
  String get theNodeDidNotAcknowledgeImporting_65bf83 =>
      'The node did not acknowledge importing the recipient key';

  @override
  String get theNodeDidNotAcknowledgeThe_e56f57 =>
      'The node did not acknowledge the command';

  @override
  String get theNodeDidNotAcknowledgeSaving_e14f06 =>
      'The node did not acknowledge saving';

  @override
  String get thisNodeDoesNotAcceptDirect_338e6e =>
      'This node does not accept direct messages.';

  @override
  String get theNodeWillRespondWithIts_ab01ac =>
      'The node will respond with its current values';

  @override
  String get theNodeIsRestartingItsName_f432c3 =>
      'The node is restarting. Its name will be restored after reconnection.';

  @override
  String get theNodeWillClearItsSaved_7eed33 =>
      'The node will clear its saved state and restart. The encryption key and settings will be preserved.';

  @override
  String get theNodeSavedAZeroMac_630708 =>
      'The node saved a zero MAC address due to an error in Send NodeInfo in Meshex 0.1.7–0.1.10. On this firmware, the ID is derived from the key and will not change, but the MAC should be restored.\n\nThe repair sends the correct MAC to the node. No restart is required and no data will be lost.';

  @override
  String get nodeDeleted_bd0760 => 'Node deleted';

  @override
  String get number_1bb3d1 => 'Number';

  @override
  String get reportNumber_a2f60b => 'Report number';

  @override
  String get numberCopied_875e81 => 'Number copied';

  @override
  String get twoNodeDatabasesAreRequired_0e6b9d =>
      'Two node databases are required';

  @override
  String get exchangeNodeinfo_e2f5f6 => 'Exchange NodeInfo';

  @override
  String get colorPreview_dfa12d => 'Color preview';

  @override
  String get mentionsAndReplies_209ee7 => 'Mentions and replies';

  @override
  String get maintenance_3c5bdd => 'Maintenance';

  @override
  String get waiting_5813a9 => 'Waiting';

  @override
  String get window_f5988f => 'Window';

  @override
  String get optimizedForAtakCommunicationReducesRoutine_27d642 =>
      'Optimized for ATAK communication; reduces routine broadcasts.';

  @override
  String get orange_6494ce => 'Orange';

  @override
  String get screenOrientation_87b383 => 'Screen orientation';

  @override
  String get fromMyNode_336438 => 'From my node';

  @override
  String get replyToMessage_4e6ac3 => 'Reply to message';

  @override
  String get repliesAndMentions_f0aae9 => 'Replies and mentions';

  @override
  String get repliesToMyMessages_2fca62 => 'Replies to my messages';

  @override
  String get responsesToOutgoingTraceroutes_dea22a =>
      'Responses to outgoing traceroutes.';

  @override
  String get repliesToYourMessagesAndMentions_953527 =>
      'Replies to your messages and mentions in channels.';

  @override
  String get zoomOut_fea897 => 'Zoom out';

  @override
  String get disablesTheUserButtonTripleClick_9664f8 =>
      'Disables the user button triple-click shortcut.';

  @override
  String get disconnect_94d07a => 'Disconnect';

  @override
  String get disableTripleClickShortcut_0ac4dd =>
      'Disable triple-click shortcut';

  @override
  String get cannotDeleteTheCurrentlyOpenDatabase_023546 =>
      'Cannot delete the currently open database';

  @override
  String get open_125957 => 'Open';

  @override
  String get openInMaps_6bb0f2 => 'Open in Maps';

  @override
  String get openGithubSupport_603c75 => 'Open GitHub support';

  @override
  String get cancelDownload_136bdc => 'Cancel download';

  @override
  String get sender_522b04 => 'Sender';

  @override
  String get sendNodeinfo_79376f => 'Send NodeInfo';

  @override
  String get sendToServices_7ae0e3 => 'Send to Services';

  @override
  String get sendAgain_625609 => 'Send again';

  @override
  String get sendReport_63b6fb => 'Send report';

  @override
  String get sendReportToTheDeveloper_d46fe6 => 'Send report to the developer';

  @override
  String get sendAPingToServices_afe5a4 => 'Send a ping to Services?';

  @override
  String get sendPosition_1a3631 => 'Send position';

  @override
  String get sentOverTheAir_740ec0 => 'Sent over the air';

  @override
  String get sending_5f0935 => 'Sending';

  @override
  String get forwardEncryptedPacketsToMqtt_53e004 =>
      'Forward encrypted packets to MQTT';

  @override
  String get scanInMeshtasticToAddThis_e46939 =>
      'Scan in Meshtastic to add this contact';

  @override
  String get reportSent_4eb02c => 'Report sent';

  @override
  String get reportsAreSentAtYourRequest_7fcca2 =>
      'Reports are sent at your request to the service announced by the connected mirror. You can review the report and log before sending. Reports contain application, system, node and connection details, plus any comment and contact information you provide. Do not include secrets or personal information in the comment. To delete a submitted report, contact the service operator and provide its report number.';

  @override
  String get reportsAreSentThroughTheConnected_ceda96 =>
      'Reports are sent through the connected server, which is either unavailable or does not accept them.';

  @override
  String get offlineOpenstreetmapContributors_76e794 =>
      'Offline · © OpenStreetMap contributors';

  @override
  String get offlineMap_c6b2c6 => 'Offline map';

  @override
  String get offlineMapAboutKmMbData_433acc =>
      'Offline map · about 100 km · 194 MB\nData from 29 Oct 2026';

  @override
  String get offlineMapEnabled_4908b7 => 'Offline map enabled';

  @override
  String get offlineMap_7c2718 => 'Offline map…';

  @override
  String get appearance_d206f1 => 'Appearance';

  @override
  String get packetsReceived_83d955 => 'Packets received';

  @override
  String get sharePositionWithMyNode_acf46e => 'Share position with my node';

  @override
  String get broadcastOverLora_d52575 => 'Broadcast over LoRa';

  @override
  String get restarts_05fe86 => 'Restarts';

  @override
  String get transfer_081b1d => 'Transfer';

  @override
  String get transferToTheOpenDatabase_8042a9 =>
      'Transfer to the open database';

  @override
  String get transferMessages_f1f159 => 'Transfer messages?';

  @override
  String get overrideDutyCycle_e5b06b => 'Override duty cycle';

  @override
  String get reconnect_91c240 => 'Reconnect';

  @override
  String get regenerate_9bf881 => 'Regenerate';

  @override
  String get dragTheMarkerOrEnterCoordinates_1127fb =>
      'Drag the marker or enter coordinates';

  @override
  String get broadcastInterval_5acd28 => 'Broadcast interval';

  @override
  String get saintPetersburgAndSurroundings_6bc6a9 =>
      'Saint Petersburg and surroundings';

  @override
  String get platform_89009f => 'Platform';

  @override
  String get followApplicationTheme_6d6cea => 'Follow application theme';

  @override
  String m_a6990d(String arg0) {
    return '$arg0 m';
  }

  @override
  String km_f1c739(String arg0) {
    return '$arg0 km';
  }

  @override
  String trayUnavailable_046650(String arg0) {
    return 'Tray unavailable: $arg0';
  }

  @override
  String tray_2a443c(String arg0) {
    return 'Tray: $arg0';
  }

  @override
  String imageExceedsMb_0b3767(String arg0) {
    return 'Image exceeds $arg0 MB';
  }

  @override
  String mirror_871d44(String arg0) {
    return 'Mirror: $arg0';
  }

  @override
  String nodeDatabases_f031cb(String arg0) {
    return 'Node databases: $arg0';
  }

  @override
  String nodeDatabase_bed412(String arg0) {
    return 'Node database $arg0';
  }

  @override
  String deletingDatabase_41e9b6(String arg0, String arg1) {
    return 'Deleting database $arg0: $arg1';
  }

  @override
  String autoConnect_4cc7c7(String arg0) {
    return 'Auto-connect: $arg0';
  }

  @override
  String notification_7dcfc3(String arg0) {
    return 'Notification: $arg0';
  }

  @override
  String notificationsNotStarted_e0104d(String arg0) {
    return 'Notifications not started: $arg0';
  }

  @override
  String couldNotCollectReport_f860a7(String arg0) {
    return 'could not collect report: $arg0';
  }

  @override
  String inChannelMessages_74052f(String arg0) {
    return '“$arg0” in channel messages';
  }

  @override
  String min_c284de(String arg0) {
    return '$arg0 min';
  }

  @override
  String sent_c9f056(String arg0) {
    return 'Sent $arg0';
  }

  @override
  String error_8f7267(String arg0) {
    return 'Error: $arg0';
  }

  @override
  String viewedTilesAreAvailableOfflineUsing_f4b74a(String arg0, String arg1) {
    return 'Viewed tiles are available offline. Using $arg0 of $arg1.';
  }

  @override
  String couldNotReadOwnNode_d29415(String arg0) {
    return 'Could not read own node: $arg0';
  }

  @override
  String couldNotReadFirmwareDetails_b21e3e(String arg0) {
    return 'Could not read firmware details: $arg0';
  }

  @override
  String ownNodeHasNotLoadedYet_0d7292(String arg0) {
    return 'Own node $arg0 has not loaded yet';
  }

  @override
  String deleteChannel_8f1495(String arg0) {
    return 'Delete channel “$arg0”?';
  }

  @override
  String channel_024ea4(String arg0) {
    return 'Channel $arg0';
  }

  @override
  String couldNotSave_6886a1(String arg0) {
    return 'Could not save: $arg0';
  }

  @override
  String backup_5f3ad8(String arg0, String arg1) {
    return '$arg0, backup $arg1';
  }

  @override
  String couldNotReadFile_425230(String arg0) {
    return 'Could not read file: $arg0';
  }

  @override
  String keySelectedSaveTheSettingsOnly_f2a281(String arg0) {
    return 'Key $arg0 selected; save the settings. Only use a key on the node it was taken from';
  }

  @override
  String couldNotReadConfiguration_7e6b38(String arg0) {
    return 'Could not read configuration: $arg0';
  }

  @override
  String theNodeSavedAZeroMac_88c735(String arg0, String arg1) {
    return 'The node saved a zero MAC address due to an error in Send NodeInfo in Meshex 0.1.7–0.1.10. Until it restarts, its ID remains $arg0. On the next restart, the ID will change to a random value: others will see it as a new node, splitting their conversation history and favorites.\n\n$arg1';
  }

  @override
  String theNodeIdChangedFromTo_ca53f7(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'The node ID changed from $arg0 to $arg1 due to an error in Send NodeInfo in Meshex 0.1.7–0.1.10.\n\nThe repair will restore $arg2 and preserve the encryption key. The node will restart and the application will restore its name. The node list, favorites and ignored nodes will be preserved. Other users will see $arg3 as a separate node for a while.';
  }

  @override
  String nodeId_12da33(String arg0, String arg1) {
    return 'Node ID: $arg0.\n\n$arg1';
  }

  @override
  String failed_317897(String arg0) {
    return 'Failed: $arg0';
  }

  @override
  String toBrokerToNodeDropped_856a68(String arg0, String arg1, String arg2) {
    return 'To broker: $arg0 · to node: $arg1 · dropped: $arg2';
  }

  @override
  String couldNotOpenFile_7fa8ac(String arg0) {
    return 'Could not open file: $arg0';
  }

  @override
  String mainSettingsWrittenNotWrittenNode_5d2582(String arg0) {
    return 'Main settings written. Not written (node restarted): $arg0; set these manually';
  }

  @override
  String stoppedAt_546fe2(String arg0, String arg1) {
    return 'Stopped at “$arg0”$arg1';
  }

  @override
  String writtenLastTheNodeWillThen_35a22d(String arg0) {
    return 'Written last: $arg0. The node will then restart and briefly disconnect.';
  }

  @override
  String skipped_29ab80(String arg0) {
    return 'Skipped: $arg0';
  }

  @override
  String open_0cdbe8(String arg0) {
    return 'Open · $arg0';
  }

  @override
  String couldNotRead_35e132(String arg0) {
    return 'Could not read: $arg0';
  }

  @override
  String kb_c723dd(String arg0) {
    return '$arg0 KB';
  }

  @override
  String mb_d67a20(String arg0) {
    return '$arg0 MB';
  }

  @override
  String messagesFromDatabaseWillBeAdded_47ae75(String arg0, String arg1) {
    return 'Messages from database $arg0 will be added to the open database, replacing the old own node number with the current one. The old database will remain; you can delete it later.$arg1';
  }

  @override
  String messagesTransferred_4a0c59(String arg0) {
    return 'Messages transferred: $arg0';
  }

  @override
  String couldNotTransfer_613ff4(String arg0) {
    return 'Could not transfer: $arg0';
  }

  @override
  String settingsLoaded_66f8ee(String arg0) {
    return 'Settings loaded ($arg0)';
  }

  @override
  String couldNotLoad_9d91fc(String arg0) {
    return 'Could not load: $arg0';
  }

  @override
  String thisNodeDatabaseChannelsAndMessages_6599da(String arg0) {
    return '$arg0: this node database, channels and messages will be deleted from the device. The node itself will not change.';
  }

  @override
  String couldNotDelete_bacd63(String arg0) {
    return 'Could not delete: $arg0';
  }

  @override
  String databaseForNodeAlreadyExistsReplace_d59789(String arg0) {
    return 'Database for node $arg0 already exists. Replace it with data from the file?';
  }

  @override
  String databaseForNodeLoadedItWill_8f5c23(String arg0) {
    return 'Database for node $arg0 loaded; it will open when connecting to this node';
  }

  @override
  String afterDays_00b005(String arg0) {
    return 'After $arg0 days';
  }

  @override
  String currentDatabasesTheLeastRecentlyUsed_0fb1b8(String arg0, String arg1) {
    return 'Current databases: $arg0. The least recently used ($arg1) will be deleted with their conversations.';
  }

  @override
  String application_7574f7(String arg0) {
    return 'Application › $arg0';
  }

  @override
  String radius_02211c(String arg0, String arg1) {
    return '$arg0 · radius $arg1';
  }

  @override
  String mirrorRespondingNodes_d2a09d(String arg0) {
    return 'Mirror responding, nodes: $arg0';
  }

  @override
  String willUse_0a9e87(String arg0) {
    return 'Will use: $arg0';
  }

  @override
  String disconnectedRetryingInS_c55f01(String arg0) {
    return 'Disconnected, retrying in $arg0 s';
  }

  @override
  String versionReleased_3afe40(String arg0) {
    return 'Version $arg0 released';
  }

  @override
  String version_450a87(String arg0) {
    return 'Version $arg0';
  }

  @override
  String versionAvailableTapToDownload_af3a75(String arg0) {
    return 'Version $arg0 available; tap to download';
  }

  @override
  String couldNotCheck_d7d26b(String arg0) {
    return 'Could not check: $arg0';
  }

  @override
  String historyNotLoaded_652fe3(String arg0) {
    return 'History not loaded: $arg0';
  }

  @override
  String pingsAreUsuallySentToThe_159914(String arg0) {
    return 'Pings are usually sent to the service channel, where bots respond.$arg0';
  }

  @override
  String notSent_04b25a(String arg0) {
    return 'Not sent: $arg0';
  }

  @override
  String hops_3baa0e(String arg0) {
    return 'Hops: $arg0';
  }

  @override
  String hideFilteredMessages_3a8226(String arg0) {
    return 'Hide $arg0 filtered messages';
  }

  @override
  String showFilteredMessages_0be3c1(String arg0) {
    return 'Show $arg0 filtered messages';
  }

  @override
  String gatewaysShowOnMap_6e8104(String arg0) {
    return 'Gateways: $arg0. Show on map';
  }

  @override
  String sentOf_167cc7(String arg0, String arg1) {
    return 'Sent $arg0 of $arg1';
  }

  @override
  String tooLongMoreThanMessages_f438b3(String arg0) {
    return 'Too long: more than $arg0 messages';
  }

  @override
  String bytesWillSendAsMessages_e34c7b(String arg0, String arg1) {
    return '$arg0 bytes · will send as $arg1 messages';
  }

  @override
  String channel_6a801e(String arg0) {
    return 'channel $arg0';
  }

  @override
  String hideChannel_3f4e20(String arg0) {
    return 'Hide channel “$arg0”?';
  }

  @override
  String deleteConversationWith_7b6ba5(String arg0) {
    return 'Delete conversation with “$arg0”?';
  }

  @override
  String showWhoReacted_154369(String arg0, String arg1) {
    return '$arg0: $arg1. Show who reacted';
  }

  @override
  String theReportWillBeSentTo_360707(String arg0) {
    return 'The report will be sent to the server operator ($arg0)';
  }

  @override
  String scan_603ff2(String arg0) {
    return 'Scan: $arg0';
  }

  @override
  String networkSearch_a3c1c6(String arg0) {
    return 'Network search: $arg0';
  }

  @override
  String ports_1b477b(String arg0) {
    return 'Ports: $arg0';
  }

  @override
  String ports_50f8c3(String arg0) {
    return 'Ports: $arg0';
  }

  @override
  String log_b9a4c8(String arg0) {
    return 'Log · $arg0';
  }

  @override
  String db_112739(String arg0) {
    return '$arg0 dB';
  }

  @override
  String skipped_5dec4c(String arg0) {
    return 'skipped $arg0';
  }

  @override
  String nodes_3af8d3(String arg0) {
    return 'Nodes$arg0';
  }

  @override
  String minAgo_d8d327(String arg0) {
    return '$arg0 min ago';
  }

  @override
  String hAgo_9ef360(String arg0) {
    return '$arg0 h ago';
  }

  @override
  String dAgo_1ab28d(String arg0) {
    return '$arg0 d ago';
  }

  @override
  String cameraUnavailable_6012f0(String arg0) {
    return 'Camera unavailable: $arg0';
  }

  @override
  String hops_d23d4f(String arg0) {
    return 'hops: $arg0';
  }

  @override
  String db_660739(String arg0, String arg1) {
    return '$arg0 dB, $arg1';
  }

  @override
  String dbm_aadd53(String arg0) {
    return '$arg0 dBm';
  }

  @override
  String v_7e1412(String arg0) {
    return '$arg0 V';
  }

  @override
  String altitudeM_dd3a3e(String arg0) {
    return 'altitude $arg0 m';
  }

  @override
  String nodesAtThisLocation_39f71d(String arg0) {
    return 'Nodes at this location: $arg0';
  }

  @override
  String map_d56e1b(String arg0) {
    return 'Map$arg0';
  }

  @override
  String search_b34b80(String arg0) {
    return 'Search: $arg0';
  }

  @override
  String couldNotDetermineLocation_e5f6db(String arg0) {
    return 'Could not determine location: $arg0';
  }

  @override
  String downloadedOfMb_945586(String arg0) {
    return 'Downloaded $arg0 of 194 MB';
  }

  @override
  String linesKb_94885c(String arg0, String arg1) {
    return '$arg0 lines, $arg1 KB';
  }

  @override
  String databasesMoved_c705c3(String arg0) {
    return 'Databases moved: $arg0';
  }

  @override
  String movingDatabases_08b6c6(String arg0) {
    return 'Moving databases: $arg0';
  }

  @override
  String linuxShortcut_e8cde8(String arg0) {
    return 'Linux shortcut: $arg0';
  }

  @override
  String restoringAttempt_111048(String arg0, String arg1) {
    return 'Restoring (attempt $arg0): $arg1';
  }

  @override
  String disabled_7e8add(String arg0) {
    return 'Disabled: $arg0';
  }

  @override
  String mqttProxyConnectingTo_76c8be(String arg0, String arg1) {
    return 'MQTT proxy: connecting to $arg0 (#$arg1)';
  }

  @override
  String mqttProxyConnectedTopics_155375(String arg0) {
    return 'MQTT proxy: connected, topics: $arg0';
  }

  @override
  String mqttProxy_ae0acc(String arg0) {
    return 'MQTT proxy: $arg0';
  }

  @override
  String mqttProxyFailure_e15119(String arg0) {
    return 'MQTT proxy failure: $arg0';
  }

  @override
  String mqttProxyNotSentToNode_d164ca(String arg0) {
    return 'MQTT proxy: not sent to node: $arg0';
  }

  @override
  String defaultPreset_3eeaf1(String arg0) {
    return 'Default preset (4/$arg0)';
  }

  @override
  String unknown_bf9aae(String arg0) {
    return 'Unknown ($arg0)';
  }

  @override
  String unsupportedKhz_f4a35a(String arg0) {
    return 'Unsupported ($arg0 kHz)';
  }

  @override
  String noLongerThan_85eae1(String arg0, String arg1) {
    return 'No longer than $arg0 $arg1';
  }

  @override
  String ms_f929ee(String arg0) {
    return '$arg0 ms';
  }

  @override
  String optionalFieldsInPositionMessagesMore_544075(String arg0) {
    return 'Optional fields in position messages. More enabled fields mean larger messages, longer transmission times and a higher risk of packet loss.\n$arg0';
  }

  @override
  String owner_a19d69(String arg0) {
    return 'Owner: $arg0';
  }

  @override
  String channelsAndLora_f47f79(String arg0) {
    return 'Channels ($arg0) and LoRa';
  }

  @override
  String yourRegionHasADutyCycle_8bba9b(String arg0) {
    return 'Your region has a duty cycle limit of $arg0%. MQTT is not recommended when duty cycle is limited, as extra traffic can quickly overwhelm your LoRa network.';
  }

  @override
  String withinKm_810838(String arg0) {
    return 'Within $arg0 km';
  }

  @override
  String withinM_4c9617(String arg0) {
    return 'Within $arg0 m';
  }

  @override
  String aChannelNamedAlreadyExistsOn_f690d9(String arg0) {
    return 'A channel named “$arg0” already exists on the node';
  }

  @override
  String notEnoughFreeSlotsNeedAvailable_ebb9b1(String arg0, String arg1) {
    return 'Not enough free slots: need $arg0, available $arg1';
  }

  @override
  String s_b1049d(String arg0) {
    return '$arg0 s';
  }

  @override
  String nodeError_1c86cd(String arg0) {
    return 'Node error: $arg0';
  }

  @override
  String bits_1c3c42(String arg0) {
    return '$arg0 bits';
  }

  @override
  String bytes_b92ed8(String arg0) {
    return '$arg0 bytes';
  }

  @override
  String to_525c23(String arg0, String arg1) {
    return '$arg0 to “$arg1”';
  }

  @override
  String reply_9b21d8(String arg0) {
    return '$arg0 · reply';
  }

  @override
  String traceroute_bf254b(String arg0) {
    return 'Traceroute: $arg0';
  }

  @override
  String outbound_0eb5b8(String arg0) {
    return 'outbound $arg0';
  }

  @override
  String return_c58db8(String arg0) {
    return 'return $arg0';
  }

  @override
  String serverResponded_01d198(String arg0) {
    return 'server responded $arg0';
  }

  @override
  String lastPositionOutsideTheInterferenceZone_f954f0(String arg0) {
    return 'last position outside the interference zone, $arg0';
  }

  @override
  String precisionKm_52aa61(String arg0) {
    return 'precision ~$arg0 km';
  }

  @override
  String precisionM_0e4845(String arg0) {
    return 'precision ~$arg0 m';
  }

  @override
  String theMacAddressIsCorrectFirmware_79bf7b(String arg0) {
    return 'The MAC address is correct. Firmware $arg0 derives the ID from the encryption key; no repair is needed.';
  }

  @override
  String dH_0efa0f(String arg0, String arg1) {
    return '$arg0 d $arg1 h';
  }

  @override
  String hMin_ace139(String arg0, String arg1) {
    return '$arg0 h $arg1 min';
  }

  @override
  String longerThanBytes_0b6b95(String arg0) {
    return 'longer than $arg0 bytes';
  }

  @override
  String topMostTalkativeOverDays_f8e44b(String arg0, String arg1) {
    return 'Top $arg0 most talkative over $arg1 days';
  }

  @override
  String serverDidNotRespondWithinS_d4984e(String arg0) {
    return 'server did not respond within $arg0 s';
  }

  @override
  String noConnectionToServer_c97c08(String arg0) {
    return 'no connection to server: $arg0';
  }

  @override
  String serverRespondedTo_546208(String arg0, String arg1) {
    return 'server responded $arg0 to /$arg1';
  }

  @override
  String mirrorErrorProcessing_150c37(String arg0, String arg1) {
    return 'Mirror: error processing $arg0: $arg1';
  }

  @override
  String mirrorConnectionClosed_fb5059(String arg0) {
    return 'Mirror: connection closed$arg0';
  }

  @override
  String get compassTitle => 'Compass';

  @override
  String get compassNoSensor =>
      'This device has no compass sensor. Heading is unavailable.';

  @override
  String get compassNoPermission =>
      'Location permission is required to display distance and bearing.';

  @override
  String get compassLocationOff =>
      'Location is disabled. Enable location services.';

  @override
  String get compassWaitingGps =>
      'Waiting for a GPS fix to calculate distance and bearing.';

  @override
  String get compassWaitingHeading =>
      'Waiting for true compass heading. Hold the phone level.';

  @override
  String get compassCalibration =>
      'Compass accuracy is low. Move away from magnets and move the phone in a figure eight.';

  @override
  String get compassSensorError => 'Could not read the compass sensor.';

  @override
  String get compassLocationError => 'Could not read the phone location.';

  @override
  String get compassNoTarget => 'The node has no coordinates.';

  @override
  String get compassTargetMissing => 'Node not found.';

  @override
  String compassDistance(String value) {
    return 'Distance: $value';
  }

  @override
  String compassBearing(String value) {
    return 'Bearing: $value';
  }

  @override
  String compassAccuracy(String value) {
    return 'Position accuracy: ±$value';
  }

  @override
  String get compassAccuracyUnknown => 'Node position accuracy is unknown';

  @override
  String compassUpdated(String value) {
    return 'Last position update: $value';
  }

  @override
  String get compassUnknownTime => 'Position time is unknown';

  @override
  String get compassOpenSettings => 'Open settings';

  @override
  String get compassAllowLocation => 'Allow location';

  @override
  String get compassRetry => 'Retry';

  @override
  String compassPhoneAccuracy(String value) {
    return 'Phone GPS accuracy: ±$value';
  }

  @override
  String get compassTargetCorrected =>
      'Node coordinates were corrected by the mirror';

  @override
  String get compassTargetSpoofed => 'Node coordinates may be spoofed';

  @override
  String get compassTrueNorth => 'Heading relative to true north';

  @override
  String compassArrowLabel(String value) {
    return 'Direction to node: $value';
  }

  @override
  String compassPositionAge(String value) {
    return ' $value ago';
  }

  @override
  String get compassCoincident =>
      'You are within the node position uncertainty';

  @override
  String get compassExchangePosition => 'Exchange position';

  @override
  String get youPrefix => 'You: ';

  @override
  String notificationReplyTitle(String value) {
    return '$value · reply';
  }

  @override
  String notificationReactionBody(String reaction, String target) {
    return '$reaction to “$target”';
  }

  @override
  String notificationTraceTitle(String value) {
    return 'Traceroute: $value';
  }

  @override
  String get cardinalNorth => 'N';

  @override
  String get cardinalNorthEast => 'NE';

  @override
  String get cardinalEast => 'E';

  @override
  String get cardinalSouthEast => 'SE';

  @override
  String get cardinalSouth => 'S';

  @override
  String get cardinalSouthWest => 'SW';

  @override
  String get cardinalWest => 'W';

  @override
  String get cardinalNorthWest => 'NW';

  @override
  String get trayShow => 'Show';

  @override
  String get trayQuit => 'Quit';

  @override
  String get systemDefaultRussianOrEnglish_f182fd =>
      'System default, Russian or English';

  @override
  String get mainSettingsSaved_00e02d => ' (main settings saved)';

  @override
  String get warningTheOwnNodeKeysDiffer_aed068 =>
      '\n\nWarning: the own node keys differ between these databases; this appears to be a different node.';

  @override
  String get theOwnNodeKeyIsUnknown_ccc9d8 =>
      '\n\nThe own node key is unknown; it is not possible to verify that this is the same node.';

  @override
  String get theNodeHasNoServicesChannel_ab2d98 =>
      '\n\nThe node has no Services channel; add it in channel settings.';

  @override
  String get bytes_e0d1c3 => 'bytes';

  @override
  String get characters_7fbc31 => 'characters';

  @override
  String get hour_1e0e6a => 'hour';

  @override
  String get hours_4e4e58 => 'hours';

  @override
  String get hours_217fae => 'hours';

  @override
  String get minute_28716b => 'minute';

  @override
  String get minutes_caa635 => 'minutes';

  @override
  String get minutes_333ed1 => 'minutes';

  @override
  String get second_5dbcff => 'second';

  @override
  String get seconds_86ee6d => 'seconds';

  @override
  String get seconds_2c2499 => 'seconds';

  @override
  String get theRepairSendsTheCorrectMac_7391e0 =>
      'The repair sends the correct MAC to the node. No restart is required and no data will be lost.';

  @override
  String get neitherTheApplicationNorTheMirror_04717d =>
      'Neither the application nor the mirror knows the true MAC of this node. Restart the node. If its ID changes, return here: the repair will restore the previous ID without data loss.';

  @override
  String bluetoothDidNotCompleteTheOperation_65145b(
    String arg0,
    String arg1,
    String arg2,
    String arg3,
  ) {
    return 'Bluetooth did not complete the operation. If the node uses a PIN, you may need to finish pairing in Linux. Disable auto-connect, select Disconnect, then run in a terminal:\n\nbluetoothctl\nremove $arg0\nagent KeyboardOnly\ndefault-agent\npair $arg1\ntrust $arg2\ndisconnect $arg3\nquit\n\nEnter the node PIN when prompted. The remove command deletes the old pairing. After pair succeeds, reconnect in the application. If already paired, check node power and availability.';
  }

  @override
  String of_b319e7(String arg0, String arg1) {
    return ' ($arg0 of $arg1)';
  }
}
