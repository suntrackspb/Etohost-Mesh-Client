// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $NodesTable extends Nodes with TableInfo<$NodesTable, Node> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NodesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _numMeta = const VerificationMeta('num');
  @override
  late final GeneratedColumn<int> num = GeneratedColumn<int>(
    'num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
    'user_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _longNameMeta = const VerificationMeta(
    'longName',
  );
  @override
  late final GeneratedColumn<String> longName = GeneratedColumn<String>(
    'long_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _shortNameMeta = const VerificationMeta(
    'shortName',
  );
  @override
  late final GeneratedColumn<String> shortName = GeneratedColumn<String>(
    'short_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _hwModelMeta = const VerificationMeta(
    'hwModel',
  );
  @override
  late final GeneratedColumn<int> hwModel = GeneratedColumn<int>(
    'hw_model',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<int> role = GeneratedColumn<int>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _publicKeyMeta = const VerificationMeta(
    'publicKey',
  );
  @override
  late final GeneratedColumn<Uint8List> publicKey = GeneratedColumn<Uint8List>(
    'public_key',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isUnmessagableMeta = const VerificationMeta(
    'isUnmessagable',
  );
  @override
  late final GeneratedColumn<bool> isUnmessagable = GeneratedColumn<bool>(
    'is_unmessagable',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unmessagable" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _lastHeardMeta = const VerificationMeta(
    'lastHeard',
  );
  @override
  late final GeneratedColumn<DateTime> lastHeard = GeneratedColumn<DateTime>(
    'last_heard',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _snrMeta = const VerificationMeta('snr');
  @override
  late final GeneratedColumn<double> snr = GeneratedColumn<double>(
    'snr',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hopsAwayMeta = const VerificationMeta(
    'hopsAway',
  );
  @override
  late final GeneratedColumn<int> hopsAway = GeneratedColumn<int>(
    'hops_away',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viaMqttMeta = const VerificationMeta(
    'viaMqtt',
  );
  @override
  late final GeneratedColumn<bool> viaMqtt = GeneratedColumn<bool>(
    'via_mqtt',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("via_mqtt" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isIgnoredMeta = const VerificationMeta(
    'isIgnored',
  );
  @override
  late final GeneratedColumn<bool> isIgnored = GeneratedColumn<bool>(
    'is_ignored',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_ignored" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<int> altitude = GeneratedColumn<int>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _batteryLevelMeta = const VerificationMeta(
    'batteryLevel',
  );
  @override
  late final GeneratedColumn<int> batteryLevel = GeneratedColumn<int>(
    'battery_level',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _voltageMeta = const VerificationMeta(
    'voltage',
  );
  @override
  late final GeneratedColumn<double> voltage = GeneratedColumn<double>(
    'voltage',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelUtilizationMeta =
      const VerificationMeta('channelUtilization');
  @override
  late final GeneratedColumn<double> channelUtilization =
      GeneratedColumn<double>(
        'channel_utilization',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _airUtilTxMeta = const VerificationMeta(
    'airUtilTx',
  );
  @override
  late final GeneratedColumn<double> airUtilTx = GeneratedColumn<double>(
    'air_util_tx',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uptimeSecondsMeta = const VerificationMeta(
    'uptimeSeconds',
  );
  @override
  late final GeneratedColumn<int> uptimeSeconds = GeneratedColumn<int>(
    'uptime_seconds',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _onRadioMeta = const VerificationMeta(
    'onRadio',
  );
  @override
  late final GeneratedColumn<bool> onRadio = GeneratedColumn<bool>(
    'on_radio',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("on_radio" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _onMirrorMeta = const VerificationMeta(
    'onMirror',
  );
  @override
  late final GeneratedColumn<bool> onMirror = GeneratedColumn<bool>(
    'on_mirror',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("on_mirror" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    num,
    userId,
    longName,
    shortName,
    hwModel,
    role,
    publicKey,
    isUnmessagable,
    lastHeard,
    snr,
    hopsAway,
    viaMqtt,
    isFavorite,
    isIgnored,
    latitude,
    longitude,
    altitude,
    batteryLevel,
    voltage,
    channelUtilization,
    airUtilTx,
    uptimeSeconds,
    onRadio,
    onMirror,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'nodes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Node> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('num')) {
      context.handle(
        _numMeta,
        num.isAcceptableOrUnknown(data['num']!, _numMeta),
      );
    }
    if (data.containsKey('user_id')) {
      context.handle(
        _userIdMeta,
        userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta),
      );
    }
    if (data.containsKey('long_name')) {
      context.handle(
        _longNameMeta,
        longName.isAcceptableOrUnknown(data['long_name']!, _longNameMeta),
      );
    }
    if (data.containsKey('short_name')) {
      context.handle(
        _shortNameMeta,
        shortName.isAcceptableOrUnknown(data['short_name']!, _shortNameMeta),
      );
    }
    if (data.containsKey('hw_model')) {
      context.handle(
        _hwModelMeta,
        hwModel.isAcceptableOrUnknown(data['hw_model']!, _hwModelMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('public_key')) {
      context.handle(
        _publicKeyMeta,
        publicKey.isAcceptableOrUnknown(data['public_key']!, _publicKeyMeta),
      );
    }
    if (data.containsKey('is_unmessagable')) {
      context.handle(
        _isUnmessagableMeta,
        isUnmessagable.isAcceptableOrUnknown(
          data['is_unmessagable']!,
          _isUnmessagableMeta,
        ),
      );
    }
    if (data.containsKey('last_heard')) {
      context.handle(
        _lastHeardMeta,
        lastHeard.isAcceptableOrUnknown(data['last_heard']!, _lastHeardMeta),
      );
    }
    if (data.containsKey('snr')) {
      context.handle(
        _snrMeta,
        snr.isAcceptableOrUnknown(data['snr']!, _snrMeta),
      );
    }
    if (data.containsKey('hops_away')) {
      context.handle(
        _hopsAwayMeta,
        hopsAway.isAcceptableOrUnknown(data['hops_away']!, _hopsAwayMeta),
      );
    }
    if (data.containsKey('via_mqtt')) {
      context.handle(
        _viaMqttMeta,
        viaMqtt.isAcceptableOrUnknown(data['via_mqtt']!, _viaMqttMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_ignored')) {
      context.handle(
        _isIgnoredMeta,
        isIgnored.isAcceptableOrUnknown(data['is_ignored']!, _isIgnoredMeta),
      );
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    if (data.containsKey('battery_level')) {
      context.handle(
        _batteryLevelMeta,
        batteryLevel.isAcceptableOrUnknown(
          data['battery_level']!,
          _batteryLevelMeta,
        ),
      );
    }
    if (data.containsKey('voltage')) {
      context.handle(
        _voltageMeta,
        voltage.isAcceptableOrUnknown(data['voltage']!, _voltageMeta),
      );
    }
    if (data.containsKey('channel_utilization')) {
      context.handle(
        _channelUtilizationMeta,
        channelUtilization.isAcceptableOrUnknown(
          data['channel_utilization']!,
          _channelUtilizationMeta,
        ),
      );
    }
    if (data.containsKey('air_util_tx')) {
      context.handle(
        _airUtilTxMeta,
        airUtilTx.isAcceptableOrUnknown(data['air_util_tx']!, _airUtilTxMeta),
      );
    }
    if (data.containsKey('uptime_seconds')) {
      context.handle(
        _uptimeSecondsMeta,
        uptimeSeconds.isAcceptableOrUnknown(
          data['uptime_seconds']!,
          _uptimeSecondsMeta,
        ),
      );
    }
    if (data.containsKey('on_radio')) {
      context.handle(
        _onRadioMeta,
        onRadio.isAcceptableOrUnknown(data['on_radio']!, _onRadioMeta),
      );
    }
    if (data.containsKey('on_mirror')) {
      context.handle(
        _onMirrorMeta,
        onMirror.isAcceptableOrUnknown(data['on_mirror']!, _onMirrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {num};
  @override
  Node map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Node(
      num: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}num'],
      )!,
      userId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}user_id'],
      )!,
      longName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}long_name'],
      )!,
      shortName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}short_name'],
      )!,
      hwModel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hw_model'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role'],
      )!,
      publicKey: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}public_key'],
      ),
      isUnmessagable: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unmessagable'],
      )!,
      lastHeard: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_heard'],
      ),
      snr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}snr'],
      ),
      hopsAway: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hops_away'],
      ),
      viaMqtt: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}via_mqtt'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isIgnored: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_ignored'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      ),
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      ),
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}altitude'],
      ),
      batteryLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}battery_level'],
      ),
      voltage: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}voltage'],
      ),
      channelUtilization: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}channel_utilization'],
      ),
      airUtilTx: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}air_util_tx'],
      ),
      uptimeSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}uptime_seconds'],
      ),
      onRadio: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}on_radio'],
      )!,
      onMirror: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}on_mirror'],
      )!,
    );
  }

  @override
  $NodesTable createAlias(String alias) {
    return $NodesTable(attachedDatabase, alias);
  }
}

class Node extends DataClass implements Insertable<Node> {
  final int num;
  final String userId;
  final String longName;
  final String shortName;
  final int hwModel;
  final int role;
  final Uint8List? publicKey;

  /// Нода не принимает личные сообщения (`User.is_unmessagable`).
  final bool isUnmessagable;
  final DateTime? lastHeard;
  final double? snr;
  final int? hopsAway;
  final bool viaMqtt;
  final bool isFavorite;
  final bool isIgnored;
  final double? latitude;
  final double? longitude;
  final int? altitude;
  final int? batteryLevel;
  final double? voltage;
  final double? channelUtilization;
  final double? airUtilTx;
  final int? uptimeSeconds;

  /// Слышали через свою ноду.
  final bool onRadio;

  /// Знаем из зеркала.
  final bool onMirror;
  const Node({
    required this.num,
    required this.userId,
    required this.longName,
    required this.shortName,
    required this.hwModel,
    required this.role,
    this.publicKey,
    required this.isUnmessagable,
    this.lastHeard,
    this.snr,
    this.hopsAway,
    required this.viaMqtt,
    required this.isFavorite,
    required this.isIgnored,
    this.latitude,
    this.longitude,
    this.altitude,
    this.batteryLevel,
    this.voltage,
    this.channelUtilization,
    this.airUtilTx,
    this.uptimeSeconds,
    required this.onRadio,
    required this.onMirror,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['num'] = Variable<int>(num);
    map['user_id'] = Variable<String>(userId);
    map['long_name'] = Variable<String>(longName);
    map['short_name'] = Variable<String>(shortName);
    map['hw_model'] = Variable<int>(hwModel);
    map['role'] = Variable<int>(role);
    if (!nullToAbsent || publicKey != null) {
      map['public_key'] = Variable<Uint8List>(publicKey);
    }
    map['is_unmessagable'] = Variable<bool>(isUnmessagable);
    if (!nullToAbsent || lastHeard != null) {
      map['last_heard'] = Variable<DateTime>(lastHeard);
    }
    if (!nullToAbsent || snr != null) {
      map['snr'] = Variable<double>(snr);
    }
    if (!nullToAbsent || hopsAway != null) {
      map['hops_away'] = Variable<int>(hopsAway);
    }
    map['via_mqtt'] = Variable<bool>(viaMqtt);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_ignored'] = Variable<bool>(isIgnored);
    if (!nullToAbsent || latitude != null) {
      map['latitude'] = Variable<double>(latitude);
    }
    if (!nullToAbsent || longitude != null) {
      map['longitude'] = Variable<double>(longitude);
    }
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<int>(altitude);
    }
    if (!nullToAbsent || batteryLevel != null) {
      map['battery_level'] = Variable<int>(batteryLevel);
    }
    if (!nullToAbsent || voltage != null) {
      map['voltage'] = Variable<double>(voltage);
    }
    if (!nullToAbsent || channelUtilization != null) {
      map['channel_utilization'] = Variable<double>(channelUtilization);
    }
    if (!nullToAbsent || airUtilTx != null) {
      map['air_util_tx'] = Variable<double>(airUtilTx);
    }
    if (!nullToAbsent || uptimeSeconds != null) {
      map['uptime_seconds'] = Variable<int>(uptimeSeconds);
    }
    map['on_radio'] = Variable<bool>(onRadio);
    map['on_mirror'] = Variable<bool>(onMirror);
    return map;
  }

  NodesCompanion toCompanion(bool nullToAbsent) {
    return NodesCompanion(
      num: Value(num),
      userId: Value(userId),
      longName: Value(longName),
      shortName: Value(shortName),
      hwModel: Value(hwModel),
      role: Value(role),
      publicKey: publicKey == null && nullToAbsent
          ? const Value.absent()
          : Value(publicKey),
      isUnmessagable: Value(isUnmessagable),
      lastHeard: lastHeard == null && nullToAbsent
          ? const Value.absent()
          : Value(lastHeard),
      snr: snr == null && nullToAbsent ? const Value.absent() : Value(snr),
      hopsAway: hopsAway == null && nullToAbsent
          ? const Value.absent()
          : Value(hopsAway),
      viaMqtt: Value(viaMqtt),
      isFavorite: Value(isFavorite),
      isIgnored: Value(isIgnored),
      latitude: latitude == null && nullToAbsent
          ? const Value.absent()
          : Value(latitude),
      longitude: longitude == null && nullToAbsent
          ? const Value.absent()
          : Value(longitude),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
      batteryLevel: batteryLevel == null && nullToAbsent
          ? const Value.absent()
          : Value(batteryLevel),
      voltage: voltage == null && nullToAbsent
          ? const Value.absent()
          : Value(voltage),
      channelUtilization: channelUtilization == null && nullToAbsent
          ? const Value.absent()
          : Value(channelUtilization),
      airUtilTx: airUtilTx == null && nullToAbsent
          ? const Value.absent()
          : Value(airUtilTx),
      uptimeSeconds: uptimeSeconds == null && nullToAbsent
          ? const Value.absent()
          : Value(uptimeSeconds),
      onRadio: Value(onRadio),
      onMirror: Value(onMirror),
    );
  }

  factory Node.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Node(
      num: serializer.fromJson<int>(json['num']),
      userId: serializer.fromJson<String>(json['userId']),
      longName: serializer.fromJson<String>(json['longName']),
      shortName: serializer.fromJson<String>(json['shortName']),
      hwModel: serializer.fromJson<int>(json['hwModel']),
      role: serializer.fromJson<int>(json['role']),
      publicKey: serializer.fromJson<Uint8List?>(json['publicKey']),
      isUnmessagable: serializer.fromJson<bool>(json['isUnmessagable']),
      lastHeard: serializer.fromJson<DateTime?>(json['lastHeard']),
      snr: serializer.fromJson<double?>(json['snr']),
      hopsAway: serializer.fromJson<int?>(json['hopsAway']),
      viaMqtt: serializer.fromJson<bool>(json['viaMqtt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isIgnored: serializer.fromJson<bool>(json['isIgnored']),
      latitude: serializer.fromJson<double?>(json['latitude']),
      longitude: serializer.fromJson<double?>(json['longitude']),
      altitude: serializer.fromJson<int?>(json['altitude']),
      batteryLevel: serializer.fromJson<int?>(json['batteryLevel']),
      voltage: serializer.fromJson<double?>(json['voltage']),
      channelUtilization: serializer.fromJson<double?>(
        json['channelUtilization'],
      ),
      airUtilTx: serializer.fromJson<double?>(json['airUtilTx']),
      uptimeSeconds: serializer.fromJson<int?>(json['uptimeSeconds']),
      onRadio: serializer.fromJson<bool>(json['onRadio']),
      onMirror: serializer.fromJson<bool>(json['onMirror']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'num': serializer.toJson<int>(num),
      'userId': serializer.toJson<String>(userId),
      'longName': serializer.toJson<String>(longName),
      'shortName': serializer.toJson<String>(shortName),
      'hwModel': serializer.toJson<int>(hwModel),
      'role': serializer.toJson<int>(role),
      'publicKey': serializer.toJson<Uint8List?>(publicKey),
      'isUnmessagable': serializer.toJson<bool>(isUnmessagable),
      'lastHeard': serializer.toJson<DateTime?>(lastHeard),
      'snr': serializer.toJson<double?>(snr),
      'hopsAway': serializer.toJson<int?>(hopsAway),
      'viaMqtt': serializer.toJson<bool>(viaMqtt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isIgnored': serializer.toJson<bool>(isIgnored),
      'latitude': serializer.toJson<double?>(latitude),
      'longitude': serializer.toJson<double?>(longitude),
      'altitude': serializer.toJson<int?>(altitude),
      'batteryLevel': serializer.toJson<int?>(batteryLevel),
      'voltage': serializer.toJson<double?>(voltage),
      'channelUtilization': serializer.toJson<double?>(channelUtilization),
      'airUtilTx': serializer.toJson<double?>(airUtilTx),
      'uptimeSeconds': serializer.toJson<int?>(uptimeSeconds),
      'onRadio': serializer.toJson<bool>(onRadio),
      'onMirror': serializer.toJson<bool>(onMirror),
    };
  }

  Node copyWith({
    int? num,
    String? userId,
    String? longName,
    String? shortName,
    int? hwModel,
    int? role,
    Value<Uint8List?> publicKey = const Value.absent(),
    bool? isUnmessagable,
    Value<DateTime?> lastHeard = const Value.absent(),
    Value<double?> snr = const Value.absent(),
    Value<int?> hopsAway = const Value.absent(),
    bool? viaMqtt,
    bool? isFavorite,
    bool? isIgnored,
    Value<double?> latitude = const Value.absent(),
    Value<double?> longitude = const Value.absent(),
    Value<int?> altitude = const Value.absent(),
    Value<int?> batteryLevel = const Value.absent(),
    Value<double?> voltage = const Value.absent(),
    Value<double?> channelUtilization = const Value.absent(),
    Value<double?> airUtilTx = const Value.absent(),
    Value<int?> uptimeSeconds = const Value.absent(),
    bool? onRadio,
    bool? onMirror,
  }) => Node(
    num: num ?? this.num,
    userId: userId ?? this.userId,
    longName: longName ?? this.longName,
    shortName: shortName ?? this.shortName,
    hwModel: hwModel ?? this.hwModel,
    role: role ?? this.role,
    publicKey: publicKey.present ? publicKey.value : this.publicKey,
    isUnmessagable: isUnmessagable ?? this.isUnmessagable,
    lastHeard: lastHeard.present ? lastHeard.value : this.lastHeard,
    snr: snr.present ? snr.value : this.snr,
    hopsAway: hopsAway.present ? hopsAway.value : this.hopsAway,
    viaMqtt: viaMqtt ?? this.viaMqtt,
    isFavorite: isFavorite ?? this.isFavorite,
    isIgnored: isIgnored ?? this.isIgnored,
    latitude: latitude.present ? latitude.value : this.latitude,
    longitude: longitude.present ? longitude.value : this.longitude,
    altitude: altitude.present ? altitude.value : this.altitude,
    batteryLevel: batteryLevel.present ? batteryLevel.value : this.batteryLevel,
    voltage: voltage.present ? voltage.value : this.voltage,
    channelUtilization: channelUtilization.present
        ? channelUtilization.value
        : this.channelUtilization,
    airUtilTx: airUtilTx.present ? airUtilTx.value : this.airUtilTx,
    uptimeSeconds: uptimeSeconds.present
        ? uptimeSeconds.value
        : this.uptimeSeconds,
    onRadio: onRadio ?? this.onRadio,
    onMirror: onMirror ?? this.onMirror,
  );
  Node copyWithCompanion(NodesCompanion data) {
    return Node(
      num: data.num.present ? data.num.value : this.num,
      userId: data.userId.present ? data.userId.value : this.userId,
      longName: data.longName.present ? data.longName.value : this.longName,
      shortName: data.shortName.present ? data.shortName.value : this.shortName,
      hwModel: data.hwModel.present ? data.hwModel.value : this.hwModel,
      role: data.role.present ? data.role.value : this.role,
      publicKey: data.publicKey.present ? data.publicKey.value : this.publicKey,
      isUnmessagable: data.isUnmessagable.present
          ? data.isUnmessagable.value
          : this.isUnmessagable,
      lastHeard: data.lastHeard.present ? data.lastHeard.value : this.lastHeard,
      snr: data.snr.present ? data.snr.value : this.snr,
      hopsAway: data.hopsAway.present ? data.hopsAway.value : this.hopsAway,
      viaMqtt: data.viaMqtt.present ? data.viaMqtt.value : this.viaMqtt,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isIgnored: data.isIgnored.present ? data.isIgnored.value : this.isIgnored,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
      batteryLevel: data.batteryLevel.present
          ? data.batteryLevel.value
          : this.batteryLevel,
      voltage: data.voltage.present ? data.voltage.value : this.voltage,
      channelUtilization: data.channelUtilization.present
          ? data.channelUtilization.value
          : this.channelUtilization,
      airUtilTx: data.airUtilTx.present ? data.airUtilTx.value : this.airUtilTx,
      uptimeSeconds: data.uptimeSeconds.present
          ? data.uptimeSeconds.value
          : this.uptimeSeconds,
      onRadio: data.onRadio.present ? data.onRadio.value : this.onRadio,
      onMirror: data.onMirror.present ? data.onMirror.value : this.onMirror,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Node(')
          ..write('num: $num, ')
          ..write('userId: $userId, ')
          ..write('longName: $longName, ')
          ..write('shortName: $shortName, ')
          ..write('hwModel: $hwModel, ')
          ..write('role: $role, ')
          ..write('publicKey: $publicKey, ')
          ..write('isUnmessagable: $isUnmessagable, ')
          ..write('lastHeard: $lastHeard, ')
          ..write('snr: $snr, ')
          ..write('hopsAway: $hopsAway, ')
          ..write('viaMqtt: $viaMqtt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('voltage: $voltage, ')
          ..write('channelUtilization: $channelUtilization, ')
          ..write('airUtilTx: $airUtilTx, ')
          ..write('uptimeSeconds: $uptimeSeconds, ')
          ..write('onRadio: $onRadio, ')
          ..write('onMirror: $onMirror')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    num,
    userId,
    longName,
    shortName,
    hwModel,
    role,
    $driftBlobEquality.hash(publicKey),
    isUnmessagable,
    lastHeard,
    snr,
    hopsAway,
    viaMqtt,
    isFavorite,
    isIgnored,
    latitude,
    longitude,
    altitude,
    batteryLevel,
    voltage,
    channelUtilization,
    airUtilTx,
    uptimeSeconds,
    onRadio,
    onMirror,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Node &&
          other.num == this.num &&
          other.userId == this.userId &&
          other.longName == this.longName &&
          other.shortName == this.shortName &&
          other.hwModel == this.hwModel &&
          other.role == this.role &&
          $driftBlobEquality.equals(other.publicKey, this.publicKey) &&
          other.isUnmessagable == this.isUnmessagable &&
          other.lastHeard == this.lastHeard &&
          other.snr == this.snr &&
          other.hopsAway == this.hopsAway &&
          other.viaMqtt == this.viaMqtt &&
          other.isFavorite == this.isFavorite &&
          other.isIgnored == this.isIgnored &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude &&
          other.batteryLevel == this.batteryLevel &&
          other.voltage == this.voltage &&
          other.channelUtilization == this.channelUtilization &&
          other.airUtilTx == this.airUtilTx &&
          other.uptimeSeconds == this.uptimeSeconds &&
          other.onRadio == this.onRadio &&
          other.onMirror == this.onMirror);
}

class NodesCompanion extends UpdateCompanion<Node> {
  final Value<int> num;
  final Value<String> userId;
  final Value<String> longName;
  final Value<String> shortName;
  final Value<int> hwModel;
  final Value<int> role;
  final Value<Uint8List?> publicKey;
  final Value<bool> isUnmessagable;
  final Value<DateTime?> lastHeard;
  final Value<double?> snr;
  final Value<int?> hopsAway;
  final Value<bool> viaMqtt;
  final Value<bool> isFavorite;
  final Value<bool> isIgnored;
  final Value<double?> latitude;
  final Value<double?> longitude;
  final Value<int?> altitude;
  final Value<int?> batteryLevel;
  final Value<double?> voltage;
  final Value<double?> channelUtilization;
  final Value<double?> airUtilTx;
  final Value<int?> uptimeSeconds;
  final Value<bool> onRadio;
  final Value<bool> onMirror;
  const NodesCompanion({
    this.num = const Value.absent(),
    this.userId = const Value.absent(),
    this.longName = const Value.absent(),
    this.shortName = const Value.absent(),
    this.hwModel = const Value.absent(),
    this.role = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.isUnmessagable = const Value.absent(),
    this.lastHeard = const Value.absent(),
    this.snr = const Value.absent(),
    this.hopsAway = const Value.absent(),
    this.viaMqtt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isIgnored = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.voltage = const Value.absent(),
    this.channelUtilization = const Value.absent(),
    this.airUtilTx = const Value.absent(),
    this.uptimeSeconds = const Value.absent(),
    this.onRadio = const Value.absent(),
    this.onMirror = const Value.absent(),
  });
  NodesCompanion.insert({
    this.num = const Value.absent(),
    this.userId = const Value.absent(),
    this.longName = const Value.absent(),
    this.shortName = const Value.absent(),
    this.hwModel = const Value.absent(),
    this.role = const Value.absent(),
    this.publicKey = const Value.absent(),
    this.isUnmessagable = const Value.absent(),
    this.lastHeard = const Value.absent(),
    this.snr = const Value.absent(),
    this.hopsAway = const Value.absent(),
    this.viaMqtt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isIgnored = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
    this.batteryLevel = const Value.absent(),
    this.voltage = const Value.absent(),
    this.channelUtilization = const Value.absent(),
    this.airUtilTx = const Value.absent(),
    this.uptimeSeconds = const Value.absent(),
    this.onRadio = const Value.absent(),
    this.onMirror = const Value.absent(),
  });
  static Insertable<Node> custom({
    Expression<int>? num,
    Expression<String>? userId,
    Expression<String>? longName,
    Expression<String>? shortName,
    Expression<int>? hwModel,
    Expression<int>? role,
    Expression<Uint8List>? publicKey,
    Expression<bool>? isUnmessagable,
    Expression<DateTime>? lastHeard,
    Expression<double>? snr,
    Expression<int>? hopsAway,
    Expression<bool>? viaMqtt,
    Expression<bool>? isFavorite,
    Expression<bool>? isIgnored,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? altitude,
    Expression<int>? batteryLevel,
    Expression<double>? voltage,
    Expression<double>? channelUtilization,
    Expression<double>? airUtilTx,
    Expression<int>? uptimeSeconds,
    Expression<bool>? onRadio,
    Expression<bool>? onMirror,
  }) {
    return RawValuesInsertable({
      if (num != null) 'num': num,
      if (userId != null) 'user_id': userId,
      if (longName != null) 'long_name': longName,
      if (shortName != null) 'short_name': shortName,
      if (hwModel != null) 'hw_model': hwModel,
      if (role != null) 'role': role,
      if (publicKey != null) 'public_key': publicKey,
      if (isUnmessagable != null) 'is_unmessagable': isUnmessagable,
      if (lastHeard != null) 'last_heard': lastHeard,
      if (snr != null) 'snr': snr,
      if (hopsAway != null) 'hops_away': hopsAway,
      if (viaMqtt != null) 'via_mqtt': viaMqtt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isIgnored != null) 'is_ignored': isIgnored,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
      if (batteryLevel != null) 'battery_level': batteryLevel,
      if (voltage != null) 'voltage': voltage,
      if (channelUtilization != null) 'channel_utilization': channelUtilization,
      if (airUtilTx != null) 'air_util_tx': airUtilTx,
      if (uptimeSeconds != null) 'uptime_seconds': uptimeSeconds,
      if (onRadio != null) 'on_radio': onRadio,
      if (onMirror != null) 'on_mirror': onMirror,
    });
  }

  NodesCompanion copyWith({
    Value<int>? num,
    Value<String>? userId,
    Value<String>? longName,
    Value<String>? shortName,
    Value<int>? hwModel,
    Value<int>? role,
    Value<Uint8List?>? publicKey,
    Value<bool>? isUnmessagable,
    Value<DateTime?>? lastHeard,
    Value<double?>? snr,
    Value<int?>? hopsAway,
    Value<bool>? viaMqtt,
    Value<bool>? isFavorite,
    Value<bool>? isIgnored,
    Value<double?>? latitude,
    Value<double?>? longitude,
    Value<int?>? altitude,
    Value<int?>? batteryLevel,
    Value<double?>? voltage,
    Value<double?>? channelUtilization,
    Value<double?>? airUtilTx,
    Value<int?>? uptimeSeconds,
    Value<bool>? onRadio,
    Value<bool>? onMirror,
  }) {
    return NodesCompanion(
      num: num ?? this.num,
      userId: userId ?? this.userId,
      longName: longName ?? this.longName,
      shortName: shortName ?? this.shortName,
      hwModel: hwModel ?? this.hwModel,
      role: role ?? this.role,
      publicKey: publicKey ?? this.publicKey,
      isUnmessagable: isUnmessagable ?? this.isUnmessagable,
      lastHeard: lastHeard ?? this.lastHeard,
      snr: snr ?? this.snr,
      hopsAway: hopsAway ?? this.hopsAway,
      viaMqtt: viaMqtt ?? this.viaMqtt,
      isFavorite: isFavorite ?? this.isFavorite,
      isIgnored: isIgnored ?? this.isIgnored,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      voltage: voltage ?? this.voltage,
      channelUtilization: channelUtilization ?? this.channelUtilization,
      airUtilTx: airUtilTx ?? this.airUtilTx,
      uptimeSeconds: uptimeSeconds ?? this.uptimeSeconds,
      onRadio: onRadio ?? this.onRadio,
      onMirror: onMirror ?? this.onMirror,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (num.present) {
      map['num'] = Variable<int>(num.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (longName.present) {
      map['long_name'] = Variable<String>(longName.value);
    }
    if (shortName.present) {
      map['short_name'] = Variable<String>(shortName.value);
    }
    if (hwModel.present) {
      map['hw_model'] = Variable<int>(hwModel.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(role.value);
    }
    if (publicKey.present) {
      map['public_key'] = Variable<Uint8List>(publicKey.value);
    }
    if (isUnmessagable.present) {
      map['is_unmessagable'] = Variable<bool>(isUnmessagable.value);
    }
    if (lastHeard.present) {
      map['last_heard'] = Variable<DateTime>(lastHeard.value);
    }
    if (snr.present) {
      map['snr'] = Variable<double>(snr.value);
    }
    if (hopsAway.present) {
      map['hops_away'] = Variable<int>(hopsAway.value);
    }
    if (viaMqtt.present) {
      map['via_mqtt'] = Variable<bool>(viaMqtt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isIgnored.present) {
      map['is_ignored'] = Variable<bool>(isIgnored.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<int>(altitude.value);
    }
    if (batteryLevel.present) {
      map['battery_level'] = Variable<int>(batteryLevel.value);
    }
    if (voltage.present) {
      map['voltage'] = Variable<double>(voltage.value);
    }
    if (channelUtilization.present) {
      map['channel_utilization'] = Variable<double>(channelUtilization.value);
    }
    if (airUtilTx.present) {
      map['air_util_tx'] = Variable<double>(airUtilTx.value);
    }
    if (uptimeSeconds.present) {
      map['uptime_seconds'] = Variable<int>(uptimeSeconds.value);
    }
    if (onRadio.present) {
      map['on_radio'] = Variable<bool>(onRadio.value);
    }
    if (onMirror.present) {
      map['on_mirror'] = Variable<bool>(onMirror.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NodesCompanion(')
          ..write('num: $num, ')
          ..write('userId: $userId, ')
          ..write('longName: $longName, ')
          ..write('shortName: $shortName, ')
          ..write('hwModel: $hwModel, ')
          ..write('role: $role, ')
          ..write('publicKey: $publicKey, ')
          ..write('isUnmessagable: $isUnmessagable, ')
          ..write('lastHeard: $lastHeard, ')
          ..write('snr: $snr, ')
          ..write('hopsAway: $hopsAway, ')
          ..write('viaMqtt: $viaMqtt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isIgnored: $isIgnored, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude, ')
          ..write('batteryLevel: $batteryLevel, ')
          ..write('voltage: $voltage, ')
          ..write('channelUtilization: $channelUtilization, ')
          ..write('airUtilTx: $airUtilTx, ')
          ..write('uptimeSeconds: $uptimeSeconds, ')
          ..write('onRadio: $onRadio, ')
          ..write('onMirror: $onMirror')
          ..write(')'))
        .toString();
  }
}

class $MessagesTable extends Messages with TableInfo<$MessagesTable, Message> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MessagesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _packetIdMeta = const VerificationMeta(
    'packetId',
  );
  @override
  late final GeneratedColumn<int> packetId = GeneratedColumn<int>(
    'packet_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fromNumMeta = const VerificationMeta(
    'fromNum',
  );
  @override
  late final GeneratedColumn<int> fromNum = GeneratedColumn<int>(
    'from_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _toNumMeta = const VerificationMeta('toNum');
  @override
  late final GeneratedColumn<int> toNum = GeneratedColumn<int>(
    'to_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _channelMeta = const VerificationMeta(
    'channel',
  );
  @override
  late final GeneratedColumn<int> channel = GeneratedColumn<int>(
    'channel',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _channelKeyMeta = const VerificationMeta(
    'channelKey',
  );
  @override
  late final GeneratedColumn<String> channelKey = GeneratedColumn<String>(
    'channel_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rxTimeMeta = const VerificationMeta('rxTime');
  @override
  late final GeneratedColumn<DateTime> rxTime = GeneratedColumn<DateTime>(
    'rx_time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isOutgoingMeta = const VerificationMeta(
    'isOutgoing',
  );
  @override
  late final GeneratedColumn<bool> isOutgoing = GeneratedColumn<bool>(
    'is_outgoing',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_outgoing" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _replyIdMeta = const VerificationMeta(
    'replyId',
  );
  @override
  late final GeneratedColumn<int> replyId = GeneratedColumn<int>(
    'reply_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emojiMeta = const VerificationMeta('emoji');
  @override
  late final GeneratedColumn<int> emoji = GeneratedColumn<int>(
    'emoji',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _rxSnrMeta = const VerificationMeta('rxSnr');
  @override
  late final GeneratedColumn<double> rxSnr = GeneratedColumn<double>(
    'rx_snr',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rxRssiMeta = const VerificationMeta('rxRssi');
  @override
  late final GeneratedColumn<int> rxRssi = GeneratedColumn<int>(
    'rx_rssi',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hopStartMeta = const VerificationMeta(
    'hopStart',
  );
  @override
  late final GeneratedColumn<int> hopStart = GeneratedColumn<int>(
    'hop_start',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hopLimitMeta = const VerificationMeta(
    'hopLimit',
  );
  @override
  late final GeneratedColumn<int> hopLimit = GeneratedColumn<int>(
    'hop_limit',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _viaMqttMeta = const VerificationMeta(
    'viaMqtt',
  );
  @override
  late final GeneratedColumn<bool> viaMqtt = GeneratedColumn<bool>(
    'via_mqtt',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("via_mqtt" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _pkiEncryptedMeta = const VerificationMeta(
    'pkiEncrypted',
  );
  @override
  late final GeneratedColumn<bool> pkiEncrypted = GeneratedColumn<bool>(
    'pki_encrypted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("pki_encrypted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<AckState, int> ackState =
      GeneratedColumn<int>(
        'ack_state',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      ).withConverter<AckState>($MessagesTable.$converterackState);
  static const VerificationMeta _ackErrorMeta = const VerificationMeta(
    'ackError',
  );
  @override
  late final GeneratedColumn<int> ackError = GeneratedColumn<int>(
    'ack_error',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heardOnRadioMeta = const VerificationMeta(
    'heardOnRadio',
  );
  @override
  late final GeneratedColumn<bool> heardOnRadio = GeneratedColumn<bool>(
    'heard_on_radio',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("heard_on_radio" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _heardOnMirrorMeta = const VerificationMeta(
    'heardOnMirror',
  );
  @override
  late final GeneratedColumn<bool> heardOnMirror = GeneratedColumn<bool>(
    'heard_on_mirror',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("heard_on_mirror" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _mirrorIdMeta = const VerificationMeta(
    'mirrorId',
  );
  @override
  late final GeneratedColumn<int> mirrorId = GeneratedColumn<int>(
    'mirror_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _relayCountMeta = const VerificationMeta(
    'relayCount',
  );
  @override
  late final GeneratedColumn<int> relayCount = GeneratedColumn<int>(
    'relay_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _isBotMeta = const VerificationMeta('isBot');
  @override
  late final GeneratedColumn<bool> isBot = GeneratedColumn<bool>(
    'is_bot',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bot" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    packetId,
    fromNum,
    toNum,
    channel,
    channelKey,
    body,
    rxTime,
    isOutgoing,
    replyId,
    emoji,
    rxSnr,
    rxRssi,
    hopStart,
    hopLimit,
    viaMqtt,
    pkiEncrypted,
    ackState,
    ackError,
    heardOnRadio,
    heardOnMirror,
    mirrorId,
    relayCount,
    isBot,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<Message> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('packet_id')) {
      context.handle(
        _packetIdMeta,
        packetId.isAcceptableOrUnknown(data['packet_id']!, _packetIdMeta),
      );
    } else if (isInserting) {
      context.missing(_packetIdMeta);
    }
    if (data.containsKey('from_num')) {
      context.handle(
        _fromNumMeta,
        fromNum.isAcceptableOrUnknown(data['from_num']!, _fromNumMeta),
      );
    } else if (isInserting) {
      context.missing(_fromNumMeta);
    }
    if (data.containsKey('to_num')) {
      context.handle(
        _toNumMeta,
        toNum.isAcceptableOrUnknown(data['to_num']!, _toNumMeta),
      );
    } else if (isInserting) {
      context.missing(_toNumMeta);
    }
    if (data.containsKey('channel')) {
      context.handle(
        _channelMeta,
        channel.isAcceptableOrUnknown(data['channel']!, _channelMeta),
      );
    }
    if (data.containsKey('channel_key')) {
      context.handle(
        _channelKeyMeta,
        channelKey.isAcceptableOrUnknown(data['channel_key']!, _channelKeyMeta),
      );
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('rx_time')) {
      context.handle(
        _rxTimeMeta,
        rxTime.isAcceptableOrUnknown(data['rx_time']!, _rxTimeMeta),
      );
    } else if (isInserting) {
      context.missing(_rxTimeMeta);
    }
    if (data.containsKey('is_outgoing')) {
      context.handle(
        _isOutgoingMeta,
        isOutgoing.isAcceptableOrUnknown(data['is_outgoing']!, _isOutgoingMeta),
      );
    }
    if (data.containsKey('reply_id')) {
      context.handle(
        _replyIdMeta,
        replyId.isAcceptableOrUnknown(data['reply_id']!, _replyIdMeta),
      );
    }
    if (data.containsKey('emoji')) {
      context.handle(
        _emojiMeta,
        emoji.isAcceptableOrUnknown(data['emoji']!, _emojiMeta),
      );
    }
    if (data.containsKey('rx_snr')) {
      context.handle(
        _rxSnrMeta,
        rxSnr.isAcceptableOrUnknown(data['rx_snr']!, _rxSnrMeta),
      );
    }
    if (data.containsKey('rx_rssi')) {
      context.handle(
        _rxRssiMeta,
        rxRssi.isAcceptableOrUnknown(data['rx_rssi']!, _rxRssiMeta),
      );
    }
    if (data.containsKey('hop_start')) {
      context.handle(
        _hopStartMeta,
        hopStart.isAcceptableOrUnknown(data['hop_start']!, _hopStartMeta),
      );
    }
    if (data.containsKey('hop_limit')) {
      context.handle(
        _hopLimitMeta,
        hopLimit.isAcceptableOrUnknown(data['hop_limit']!, _hopLimitMeta),
      );
    }
    if (data.containsKey('via_mqtt')) {
      context.handle(
        _viaMqttMeta,
        viaMqtt.isAcceptableOrUnknown(data['via_mqtt']!, _viaMqttMeta),
      );
    }
    if (data.containsKey('pki_encrypted')) {
      context.handle(
        _pkiEncryptedMeta,
        pkiEncrypted.isAcceptableOrUnknown(
          data['pki_encrypted']!,
          _pkiEncryptedMeta,
        ),
      );
    }
    if (data.containsKey('ack_error')) {
      context.handle(
        _ackErrorMeta,
        ackError.isAcceptableOrUnknown(data['ack_error']!, _ackErrorMeta),
      );
    }
    if (data.containsKey('heard_on_radio')) {
      context.handle(
        _heardOnRadioMeta,
        heardOnRadio.isAcceptableOrUnknown(
          data['heard_on_radio']!,
          _heardOnRadioMeta,
        ),
      );
    }
    if (data.containsKey('heard_on_mirror')) {
      context.handle(
        _heardOnMirrorMeta,
        heardOnMirror.isAcceptableOrUnknown(
          data['heard_on_mirror']!,
          _heardOnMirrorMeta,
        ),
      );
    }
    if (data.containsKey('mirror_id')) {
      context.handle(
        _mirrorIdMeta,
        mirrorId.isAcceptableOrUnknown(data['mirror_id']!, _mirrorIdMeta),
      );
    }
    if (data.containsKey('relay_count')) {
      context.handle(
        _relayCountMeta,
        relayCount.isAcceptableOrUnknown(data['relay_count']!, _relayCountMeta),
      );
    }
    if (data.containsKey('is_bot')) {
      context.handle(
        _isBotMeta,
        isBot.isAcceptableOrUnknown(data['is_bot']!, _isBotMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {packetId, fromNum},
  ];
  @override
  Message map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Message(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      packetId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}packet_id'],
      )!,
      fromNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}from_num'],
      )!,
      toNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}to_num'],
      )!,
      channel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}channel'],
      ),
      channelKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}channel_key'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      rxTime: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}rx_time'],
      )!,
      isOutgoing: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_outgoing'],
      )!,
      replyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reply_id'],
      ),
      emoji: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}emoji'],
      )!,
      rxSnr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rx_snr'],
      ),
      rxRssi: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rx_rssi'],
      ),
      hopStart: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hop_start'],
      ),
      hopLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hop_limit'],
      ),
      viaMqtt: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}via_mqtt'],
      )!,
      pkiEncrypted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}pki_encrypted'],
      )!,
      ackState: $MessagesTable.$converterackState.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.int,
          data['${effectivePrefix}ack_state'],
        )!,
      ),
      ackError: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ack_error'],
      ),
      heardOnRadio: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}heard_on_radio'],
      )!,
      heardOnMirror: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}heard_on_mirror'],
      )!,
      mirrorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mirror_id'],
      ),
      relayCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}relay_count'],
      )!,
      isBot: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bot'],
      )!,
    );
  }

  @override
  $MessagesTable createAlias(String alias) {
    return $MessagesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<AckState, int, int> $converterackState =
      const EnumIndexConverter<AckState>(AckState.values);
}

class Message extends DataClass implements Insertable<Message> {
  final int id;

  /// id пакета Meshtastic; вместе с [fromNum] — ключ дедупликации эфир/зеркало.
  final int packetId;
  final int fromNum;
  final int toNum;

  /// Индекс канала на своей ноде (для отправки); у сообщений из зеркала — null.
  final int? channel;

  /// Имя канала в нижнем регистре — по нему лента и склейка с зеркалом.
  final String channelKey;
  final String body;
  final DateTime rxTime;
  final bool isOutgoing;
  final int? replyId;
  final int emoji;
  final double? rxSnr;
  final int? rxRssi;
  final int? hopStart;
  final int? hopLimit;
  final bool viaMqtt;

  /// Личное, зашифрованное ключом получателя (PKI).
  final bool pkiEncrypted;
  final AckState ackState;

  /// Routing.Error при [AckState.failed].
  final int? ackError;
  final bool heardOnRadio;
  final bool heardOnMirror;

  /// id записи на зеркале (для relay_update и подгрузки истории).
  final int? mirrorId;
  final int relayCount;
  final bool isBot;
  const Message({
    required this.id,
    required this.packetId,
    required this.fromNum,
    required this.toNum,
    this.channel,
    required this.channelKey,
    required this.body,
    required this.rxTime,
    required this.isOutgoing,
    this.replyId,
    required this.emoji,
    this.rxSnr,
    this.rxRssi,
    this.hopStart,
    this.hopLimit,
    required this.viaMqtt,
    required this.pkiEncrypted,
    required this.ackState,
    this.ackError,
    required this.heardOnRadio,
    required this.heardOnMirror,
    this.mirrorId,
    required this.relayCount,
    required this.isBot,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['packet_id'] = Variable<int>(packetId);
    map['from_num'] = Variable<int>(fromNum);
    map['to_num'] = Variable<int>(toNum);
    if (!nullToAbsent || channel != null) {
      map['channel'] = Variable<int>(channel);
    }
    map['channel_key'] = Variable<String>(channelKey);
    map['body'] = Variable<String>(body);
    map['rx_time'] = Variable<DateTime>(rxTime);
    map['is_outgoing'] = Variable<bool>(isOutgoing);
    if (!nullToAbsent || replyId != null) {
      map['reply_id'] = Variable<int>(replyId);
    }
    map['emoji'] = Variable<int>(emoji);
    if (!nullToAbsent || rxSnr != null) {
      map['rx_snr'] = Variable<double>(rxSnr);
    }
    if (!nullToAbsent || rxRssi != null) {
      map['rx_rssi'] = Variable<int>(rxRssi);
    }
    if (!nullToAbsent || hopStart != null) {
      map['hop_start'] = Variable<int>(hopStart);
    }
    if (!nullToAbsent || hopLimit != null) {
      map['hop_limit'] = Variable<int>(hopLimit);
    }
    map['via_mqtt'] = Variable<bool>(viaMqtt);
    map['pki_encrypted'] = Variable<bool>(pkiEncrypted);
    {
      map['ack_state'] = Variable<int>(
        $MessagesTable.$converterackState.toSql(ackState),
      );
    }
    if (!nullToAbsent || ackError != null) {
      map['ack_error'] = Variable<int>(ackError);
    }
    map['heard_on_radio'] = Variable<bool>(heardOnRadio);
    map['heard_on_mirror'] = Variable<bool>(heardOnMirror);
    if (!nullToAbsent || mirrorId != null) {
      map['mirror_id'] = Variable<int>(mirrorId);
    }
    map['relay_count'] = Variable<int>(relayCount);
    map['is_bot'] = Variable<bool>(isBot);
    return map;
  }

  MessagesCompanion toCompanion(bool nullToAbsent) {
    return MessagesCompanion(
      id: Value(id),
      packetId: Value(packetId),
      fromNum: Value(fromNum),
      toNum: Value(toNum),
      channel: channel == null && nullToAbsent
          ? const Value.absent()
          : Value(channel),
      channelKey: Value(channelKey),
      body: Value(body),
      rxTime: Value(rxTime),
      isOutgoing: Value(isOutgoing),
      replyId: replyId == null && nullToAbsent
          ? const Value.absent()
          : Value(replyId),
      emoji: Value(emoji),
      rxSnr: rxSnr == null && nullToAbsent
          ? const Value.absent()
          : Value(rxSnr),
      rxRssi: rxRssi == null && nullToAbsent
          ? const Value.absent()
          : Value(rxRssi),
      hopStart: hopStart == null && nullToAbsent
          ? const Value.absent()
          : Value(hopStart),
      hopLimit: hopLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(hopLimit),
      viaMqtt: Value(viaMqtt),
      pkiEncrypted: Value(pkiEncrypted),
      ackState: Value(ackState),
      ackError: ackError == null && nullToAbsent
          ? const Value.absent()
          : Value(ackError),
      heardOnRadio: Value(heardOnRadio),
      heardOnMirror: Value(heardOnMirror),
      mirrorId: mirrorId == null && nullToAbsent
          ? const Value.absent()
          : Value(mirrorId),
      relayCount: Value(relayCount),
      isBot: Value(isBot),
    );
  }

  factory Message.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Message(
      id: serializer.fromJson<int>(json['id']),
      packetId: serializer.fromJson<int>(json['packetId']),
      fromNum: serializer.fromJson<int>(json['fromNum']),
      toNum: serializer.fromJson<int>(json['toNum']),
      channel: serializer.fromJson<int?>(json['channel']),
      channelKey: serializer.fromJson<String>(json['channelKey']),
      body: serializer.fromJson<String>(json['body']),
      rxTime: serializer.fromJson<DateTime>(json['rxTime']),
      isOutgoing: serializer.fromJson<bool>(json['isOutgoing']),
      replyId: serializer.fromJson<int?>(json['replyId']),
      emoji: serializer.fromJson<int>(json['emoji']),
      rxSnr: serializer.fromJson<double?>(json['rxSnr']),
      rxRssi: serializer.fromJson<int?>(json['rxRssi']),
      hopStart: serializer.fromJson<int?>(json['hopStart']),
      hopLimit: serializer.fromJson<int?>(json['hopLimit']),
      viaMqtt: serializer.fromJson<bool>(json['viaMqtt']),
      pkiEncrypted: serializer.fromJson<bool>(json['pkiEncrypted']),
      ackState: $MessagesTable.$converterackState.fromJson(
        serializer.fromJson<int>(json['ackState']),
      ),
      ackError: serializer.fromJson<int?>(json['ackError']),
      heardOnRadio: serializer.fromJson<bool>(json['heardOnRadio']),
      heardOnMirror: serializer.fromJson<bool>(json['heardOnMirror']),
      mirrorId: serializer.fromJson<int?>(json['mirrorId']),
      relayCount: serializer.fromJson<int>(json['relayCount']),
      isBot: serializer.fromJson<bool>(json['isBot']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'packetId': serializer.toJson<int>(packetId),
      'fromNum': serializer.toJson<int>(fromNum),
      'toNum': serializer.toJson<int>(toNum),
      'channel': serializer.toJson<int?>(channel),
      'channelKey': serializer.toJson<String>(channelKey),
      'body': serializer.toJson<String>(body),
      'rxTime': serializer.toJson<DateTime>(rxTime),
      'isOutgoing': serializer.toJson<bool>(isOutgoing),
      'replyId': serializer.toJson<int?>(replyId),
      'emoji': serializer.toJson<int>(emoji),
      'rxSnr': serializer.toJson<double?>(rxSnr),
      'rxRssi': serializer.toJson<int?>(rxRssi),
      'hopStart': serializer.toJson<int?>(hopStart),
      'hopLimit': serializer.toJson<int?>(hopLimit),
      'viaMqtt': serializer.toJson<bool>(viaMqtt),
      'pkiEncrypted': serializer.toJson<bool>(pkiEncrypted),
      'ackState': serializer.toJson<int>(
        $MessagesTable.$converterackState.toJson(ackState),
      ),
      'ackError': serializer.toJson<int?>(ackError),
      'heardOnRadio': serializer.toJson<bool>(heardOnRadio),
      'heardOnMirror': serializer.toJson<bool>(heardOnMirror),
      'mirrorId': serializer.toJson<int?>(mirrorId),
      'relayCount': serializer.toJson<int>(relayCount),
      'isBot': serializer.toJson<bool>(isBot),
    };
  }

  Message copyWith({
    int? id,
    int? packetId,
    int? fromNum,
    int? toNum,
    Value<int?> channel = const Value.absent(),
    String? channelKey,
    String? body,
    DateTime? rxTime,
    bool? isOutgoing,
    Value<int?> replyId = const Value.absent(),
    int? emoji,
    Value<double?> rxSnr = const Value.absent(),
    Value<int?> rxRssi = const Value.absent(),
    Value<int?> hopStart = const Value.absent(),
    Value<int?> hopLimit = const Value.absent(),
    bool? viaMqtt,
    bool? pkiEncrypted,
    AckState? ackState,
    Value<int?> ackError = const Value.absent(),
    bool? heardOnRadio,
    bool? heardOnMirror,
    Value<int?> mirrorId = const Value.absent(),
    int? relayCount,
    bool? isBot,
  }) => Message(
    id: id ?? this.id,
    packetId: packetId ?? this.packetId,
    fromNum: fromNum ?? this.fromNum,
    toNum: toNum ?? this.toNum,
    channel: channel.present ? channel.value : this.channel,
    channelKey: channelKey ?? this.channelKey,
    body: body ?? this.body,
    rxTime: rxTime ?? this.rxTime,
    isOutgoing: isOutgoing ?? this.isOutgoing,
    replyId: replyId.present ? replyId.value : this.replyId,
    emoji: emoji ?? this.emoji,
    rxSnr: rxSnr.present ? rxSnr.value : this.rxSnr,
    rxRssi: rxRssi.present ? rxRssi.value : this.rxRssi,
    hopStart: hopStart.present ? hopStart.value : this.hopStart,
    hopLimit: hopLimit.present ? hopLimit.value : this.hopLimit,
    viaMqtt: viaMqtt ?? this.viaMqtt,
    pkiEncrypted: pkiEncrypted ?? this.pkiEncrypted,
    ackState: ackState ?? this.ackState,
    ackError: ackError.present ? ackError.value : this.ackError,
    heardOnRadio: heardOnRadio ?? this.heardOnRadio,
    heardOnMirror: heardOnMirror ?? this.heardOnMirror,
    mirrorId: mirrorId.present ? mirrorId.value : this.mirrorId,
    relayCount: relayCount ?? this.relayCount,
    isBot: isBot ?? this.isBot,
  );
  Message copyWithCompanion(MessagesCompanion data) {
    return Message(
      id: data.id.present ? data.id.value : this.id,
      packetId: data.packetId.present ? data.packetId.value : this.packetId,
      fromNum: data.fromNum.present ? data.fromNum.value : this.fromNum,
      toNum: data.toNum.present ? data.toNum.value : this.toNum,
      channel: data.channel.present ? data.channel.value : this.channel,
      channelKey: data.channelKey.present
          ? data.channelKey.value
          : this.channelKey,
      body: data.body.present ? data.body.value : this.body,
      rxTime: data.rxTime.present ? data.rxTime.value : this.rxTime,
      isOutgoing: data.isOutgoing.present
          ? data.isOutgoing.value
          : this.isOutgoing,
      replyId: data.replyId.present ? data.replyId.value : this.replyId,
      emoji: data.emoji.present ? data.emoji.value : this.emoji,
      rxSnr: data.rxSnr.present ? data.rxSnr.value : this.rxSnr,
      rxRssi: data.rxRssi.present ? data.rxRssi.value : this.rxRssi,
      hopStart: data.hopStart.present ? data.hopStart.value : this.hopStart,
      hopLimit: data.hopLimit.present ? data.hopLimit.value : this.hopLimit,
      viaMqtt: data.viaMqtt.present ? data.viaMqtt.value : this.viaMqtt,
      pkiEncrypted: data.pkiEncrypted.present
          ? data.pkiEncrypted.value
          : this.pkiEncrypted,
      ackState: data.ackState.present ? data.ackState.value : this.ackState,
      ackError: data.ackError.present ? data.ackError.value : this.ackError,
      heardOnRadio: data.heardOnRadio.present
          ? data.heardOnRadio.value
          : this.heardOnRadio,
      heardOnMirror: data.heardOnMirror.present
          ? data.heardOnMirror.value
          : this.heardOnMirror,
      mirrorId: data.mirrorId.present ? data.mirrorId.value : this.mirrorId,
      relayCount: data.relayCount.present
          ? data.relayCount.value
          : this.relayCount,
      isBot: data.isBot.present ? data.isBot.value : this.isBot,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Message(')
          ..write('id: $id, ')
          ..write('packetId: $packetId, ')
          ..write('fromNum: $fromNum, ')
          ..write('toNum: $toNum, ')
          ..write('channel: $channel, ')
          ..write('channelKey: $channelKey, ')
          ..write('body: $body, ')
          ..write('rxTime: $rxTime, ')
          ..write('isOutgoing: $isOutgoing, ')
          ..write('replyId: $replyId, ')
          ..write('emoji: $emoji, ')
          ..write('rxSnr: $rxSnr, ')
          ..write('rxRssi: $rxRssi, ')
          ..write('hopStart: $hopStart, ')
          ..write('hopLimit: $hopLimit, ')
          ..write('viaMqtt: $viaMqtt, ')
          ..write('pkiEncrypted: $pkiEncrypted, ')
          ..write('ackState: $ackState, ')
          ..write('ackError: $ackError, ')
          ..write('heardOnRadio: $heardOnRadio, ')
          ..write('heardOnMirror: $heardOnMirror, ')
          ..write('mirrorId: $mirrorId, ')
          ..write('relayCount: $relayCount, ')
          ..write('isBot: $isBot')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    id,
    packetId,
    fromNum,
    toNum,
    channel,
    channelKey,
    body,
    rxTime,
    isOutgoing,
    replyId,
    emoji,
    rxSnr,
    rxRssi,
    hopStart,
    hopLimit,
    viaMqtt,
    pkiEncrypted,
    ackState,
    ackError,
    heardOnRadio,
    heardOnMirror,
    mirrorId,
    relayCount,
    isBot,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Message &&
          other.id == this.id &&
          other.packetId == this.packetId &&
          other.fromNum == this.fromNum &&
          other.toNum == this.toNum &&
          other.channel == this.channel &&
          other.channelKey == this.channelKey &&
          other.body == this.body &&
          other.rxTime == this.rxTime &&
          other.isOutgoing == this.isOutgoing &&
          other.replyId == this.replyId &&
          other.emoji == this.emoji &&
          other.rxSnr == this.rxSnr &&
          other.rxRssi == this.rxRssi &&
          other.hopStart == this.hopStart &&
          other.hopLimit == this.hopLimit &&
          other.viaMqtt == this.viaMqtt &&
          other.pkiEncrypted == this.pkiEncrypted &&
          other.ackState == this.ackState &&
          other.ackError == this.ackError &&
          other.heardOnRadio == this.heardOnRadio &&
          other.heardOnMirror == this.heardOnMirror &&
          other.mirrorId == this.mirrorId &&
          other.relayCount == this.relayCount &&
          other.isBot == this.isBot);
}

class MessagesCompanion extends UpdateCompanion<Message> {
  final Value<int> id;
  final Value<int> packetId;
  final Value<int> fromNum;
  final Value<int> toNum;
  final Value<int?> channel;
  final Value<String> channelKey;
  final Value<String> body;
  final Value<DateTime> rxTime;
  final Value<bool> isOutgoing;
  final Value<int?> replyId;
  final Value<int> emoji;
  final Value<double?> rxSnr;
  final Value<int?> rxRssi;
  final Value<int?> hopStart;
  final Value<int?> hopLimit;
  final Value<bool> viaMqtt;
  final Value<bool> pkiEncrypted;
  final Value<AckState> ackState;
  final Value<int?> ackError;
  final Value<bool> heardOnRadio;
  final Value<bool> heardOnMirror;
  final Value<int?> mirrorId;
  final Value<int> relayCount;
  final Value<bool> isBot;
  const MessagesCompanion({
    this.id = const Value.absent(),
    this.packetId = const Value.absent(),
    this.fromNum = const Value.absent(),
    this.toNum = const Value.absent(),
    this.channel = const Value.absent(),
    this.channelKey = const Value.absent(),
    this.body = const Value.absent(),
    this.rxTime = const Value.absent(),
    this.isOutgoing = const Value.absent(),
    this.replyId = const Value.absent(),
    this.emoji = const Value.absent(),
    this.rxSnr = const Value.absent(),
    this.rxRssi = const Value.absent(),
    this.hopStart = const Value.absent(),
    this.hopLimit = const Value.absent(),
    this.viaMqtt = const Value.absent(),
    this.pkiEncrypted = const Value.absent(),
    this.ackState = const Value.absent(),
    this.ackError = const Value.absent(),
    this.heardOnRadio = const Value.absent(),
    this.heardOnMirror = const Value.absent(),
    this.mirrorId = const Value.absent(),
    this.relayCount = const Value.absent(),
    this.isBot = const Value.absent(),
  });
  MessagesCompanion.insert({
    this.id = const Value.absent(),
    required int packetId,
    required int fromNum,
    required int toNum,
    this.channel = const Value.absent(),
    this.channelKey = const Value.absent(),
    required String body,
    required DateTime rxTime,
    this.isOutgoing = const Value.absent(),
    this.replyId = const Value.absent(),
    this.emoji = const Value.absent(),
    this.rxSnr = const Value.absent(),
    this.rxRssi = const Value.absent(),
    this.hopStart = const Value.absent(),
    this.hopLimit = const Value.absent(),
    this.viaMqtt = const Value.absent(),
    this.pkiEncrypted = const Value.absent(),
    this.ackState = const Value.absent(),
    this.ackError = const Value.absent(),
    this.heardOnRadio = const Value.absent(),
    this.heardOnMirror = const Value.absent(),
    this.mirrorId = const Value.absent(),
    this.relayCount = const Value.absent(),
    this.isBot = const Value.absent(),
  }) : packetId = Value(packetId),
       fromNum = Value(fromNum),
       toNum = Value(toNum),
       body = Value(body),
       rxTime = Value(rxTime);
  static Insertable<Message> custom({
    Expression<int>? id,
    Expression<int>? packetId,
    Expression<int>? fromNum,
    Expression<int>? toNum,
    Expression<int>? channel,
    Expression<String>? channelKey,
    Expression<String>? body,
    Expression<DateTime>? rxTime,
    Expression<bool>? isOutgoing,
    Expression<int>? replyId,
    Expression<int>? emoji,
    Expression<double>? rxSnr,
    Expression<int>? rxRssi,
    Expression<int>? hopStart,
    Expression<int>? hopLimit,
    Expression<bool>? viaMqtt,
    Expression<bool>? pkiEncrypted,
    Expression<int>? ackState,
    Expression<int>? ackError,
    Expression<bool>? heardOnRadio,
    Expression<bool>? heardOnMirror,
    Expression<int>? mirrorId,
    Expression<int>? relayCount,
    Expression<bool>? isBot,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (packetId != null) 'packet_id': packetId,
      if (fromNum != null) 'from_num': fromNum,
      if (toNum != null) 'to_num': toNum,
      if (channel != null) 'channel': channel,
      if (channelKey != null) 'channel_key': channelKey,
      if (body != null) 'body': body,
      if (rxTime != null) 'rx_time': rxTime,
      if (isOutgoing != null) 'is_outgoing': isOutgoing,
      if (replyId != null) 'reply_id': replyId,
      if (emoji != null) 'emoji': emoji,
      if (rxSnr != null) 'rx_snr': rxSnr,
      if (rxRssi != null) 'rx_rssi': rxRssi,
      if (hopStart != null) 'hop_start': hopStart,
      if (hopLimit != null) 'hop_limit': hopLimit,
      if (viaMqtt != null) 'via_mqtt': viaMqtt,
      if (pkiEncrypted != null) 'pki_encrypted': pkiEncrypted,
      if (ackState != null) 'ack_state': ackState,
      if (ackError != null) 'ack_error': ackError,
      if (heardOnRadio != null) 'heard_on_radio': heardOnRadio,
      if (heardOnMirror != null) 'heard_on_mirror': heardOnMirror,
      if (mirrorId != null) 'mirror_id': mirrorId,
      if (relayCount != null) 'relay_count': relayCount,
      if (isBot != null) 'is_bot': isBot,
    });
  }

  MessagesCompanion copyWith({
    Value<int>? id,
    Value<int>? packetId,
    Value<int>? fromNum,
    Value<int>? toNum,
    Value<int?>? channel,
    Value<String>? channelKey,
    Value<String>? body,
    Value<DateTime>? rxTime,
    Value<bool>? isOutgoing,
    Value<int?>? replyId,
    Value<int>? emoji,
    Value<double?>? rxSnr,
    Value<int?>? rxRssi,
    Value<int?>? hopStart,
    Value<int?>? hopLimit,
    Value<bool>? viaMqtt,
    Value<bool>? pkiEncrypted,
    Value<AckState>? ackState,
    Value<int?>? ackError,
    Value<bool>? heardOnRadio,
    Value<bool>? heardOnMirror,
    Value<int?>? mirrorId,
    Value<int>? relayCount,
    Value<bool>? isBot,
  }) {
    return MessagesCompanion(
      id: id ?? this.id,
      packetId: packetId ?? this.packetId,
      fromNum: fromNum ?? this.fromNum,
      toNum: toNum ?? this.toNum,
      channel: channel ?? this.channel,
      channelKey: channelKey ?? this.channelKey,
      body: body ?? this.body,
      rxTime: rxTime ?? this.rxTime,
      isOutgoing: isOutgoing ?? this.isOutgoing,
      replyId: replyId ?? this.replyId,
      emoji: emoji ?? this.emoji,
      rxSnr: rxSnr ?? this.rxSnr,
      rxRssi: rxRssi ?? this.rxRssi,
      hopStart: hopStart ?? this.hopStart,
      hopLimit: hopLimit ?? this.hopLimit,
      viaMqtt: viaMqtt ?? this.viaMqtt,
      pkiEncrypted: pkiEncrypted ?? this.pkiEncrypted,
      ackState: ackState ?? this.ackState,
      ackError: ackError ?? this.ackError,
      heardOnRadio: heardOnRadio ?? this.heardOnRadio,
      heardOnMirror: heardOnMirror ?? this.heardOnMirror,
      mirrorId: mirrorId ?? this.mirrorId,
      relayCount: relayCount ?? this.relayCount,
      isBot: isBot ?? this.isBot,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (packetId.present) {
      map['packet_id'] = Variable<int>(packetId.value);
    }
    if (fromNum.present) {
      map['from_num'] = Variable<int>(fromNum.value);
    }
    if (toNum.present) {
      map['to_num'] = Variable<int>(toNum.value);
    }
    if (channel.present) {
      map['channel'] = Variable<int>(channel.value);
    }
    if (channelKey.present) {
      map['channel_key'] = Variable<String>(channelKey.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (rxTime.present) {
      map['rx_time'] = Variable<DateTime>(rxTime.value);
    }
    if (isOutgoing.present) {
      map['is_outgoing'] = Variable<bool>(isOutgoing.value);
    }
    if (replyId.present) {
      map['reply_id'] = Variable<int>(replyId.value);
    }
    if (emoji.present) {
      map['emoji'] = Variable<int>(emoji.value);
    }
    if (rxSnr.present) {
      map['rx_snr'] = Variable<double>(rxSnr.value);
    }
    if (rxRssi.present) {
      map['rx_rssi'] = Variable<int>(rxRssi.value);
    }
    if (hopStart.present) {
      map['hop_start'] = Variable<int>(hopStart.value);
    }
    if (hopLimit.present) {
      map['hop_limit'] = Variable<int>(hopLimit.value);
    }
    if (viaMqtt.present) {
      map['via_mqtt'] = Variable<bool>(viaMqtt.value);
    }
    if (pkiEncrypted.present) {
      map['pki_encrypted'] = Variable<bool>(pkiEncrypted.value);
    }
    if (ackState.present) {
      map['ack_state'] = Variable<int>(
        $MessagesTable.$converterackState.toSql(ackState.value),
      );
    }
    if (ackError.present) {
      map['ack_error'] = Variable<int>(ackError.value);
    }
    if (heardOnRadio.present) {
      map['heard_on_radio'] = Variable<bool>(heardOnRadio.value);
    }
    if (heardOnMirror.present) {
      map['heard_on_mirror'] = Variable<bool>(heardOnMirror.value);
    }
    if (mirrorId.present) {
      map['mirror_id'] = Variable<int>(mirrorId.value);
    }
    if (relayCount.present) {
      map['relay_count'] = Variable<int>(relayCount.value);
    }
    if (isBot.present) {
      map['is_bot'] = Variable<bool>(isBot.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MessagesCompanion(')
          ..write('id: $id, ')
          ..write('packetId: $packetId, ')
          ..write('fromNum: $fromNum, ')
          ..write('toNum: $toNum, ')
          ..write('channel: $channel, ')
          ..write('channelKey: $channelKey, ')
          ..write('body: $body, ')
          ..write('rxTime: $rxTime, ')
          ..write('isOutgoing: $isOutgoing, ')
          ..write('replyId: $replyId, ')
          ..write('emoji: $emoji, ')
          ..write('rxSnr: $rxSnr, ')
          ..write('rxRssi: $rxRssi, ')
          ..write('hopStart: $hopStart, ')
          ..write('hopLimit: $hopLimit, ')
          ..write('viaMqtt: $viaMqtt, ')
          ..write('pkiEncrypted: $pkiEncrypted, ')
          ..write('ackState: $ackState, ')
          ..write('ackError: $ackError, ')
          ..write('heardOnRadio: $heardOnRadio, ')
          ..write('heardOnMirror: $heardOnMirror, ')
          ..write('mirrorId: $mirrorId, ')
          ..write('relayCount: $relayCount, ')
          ..write('isBot: $isBot')
          ..write(')'))
        .toString();
  }
}

class $ChannelsTable extends Channels
    with TableInfo<$ChannelsTable, MeshChannel> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChannelsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _indexMeta = const VerificationMeta('index');
  @override
  late final GeneratedColumn<int> index = GeneratedColumn<int>(
    'index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<int> role = GeneratedColumn<int>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pskMeta = const VerificationMeta('psk');
  @override
  late final GeneratedColumn<Uint8List> psk = GeneratedColumn<Uint8List>(
    'psk',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [index, name, role, psk];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'channels';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeshChannel> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('index')) {
      context.handle(
        _indexMeta,
        index.isAcceptableOrUnknown(data['index']!, _indexMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    }
    if (data.containsKey('psk')) {
      context.handle(
        _pskMeta,
        psk.isAcceptableOrUnknown(data['psk']!, _pskMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {index};
  @override
  MeshChannel map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeshChannel(
      index: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}index'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}role'],
      )!,
      psk: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}psk'],
      ),
    );
  }

  @override
  $ChannelsTable createAlias(String alias) {
    return $ChannelsTable(attachedDatabase, alias);
  }
}

class MeshChannel extends DataClass implements Insertable<MeshChannel> {
  final int index;
  final String name;
  final int role;
  final Uint8List? psk;
  const MeshChannel({
    required this.index,
    required this.name,
    required this.role,
    this.psk,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['index'] = Variable<int>(index);
    map['name'] = Variable<String>(name);
    map['role'] = Variable<int>(role);
    if (!nullToAbsent || psk != null) {
      map['psk'] = Variable<Uint8List>(psk);
    }
    return map;
  }

  ChannelsCompanion toCompanion(bool nullToAbsent) {
    return ChannelsCompanion(
      index: Value(index),
      name: Value(name),
      role: Value(role),
      psk: psk == null && nullToAbsent ? const Value.absent() : Value(psk),
    );
  }

  factory MeshChannel.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeshChannel(
      index: serializer.fromJson<int>(json['index']),
      name: serializer.fromJson<String>(json['name']),
      role: serializer.fromJson<int>(json['role']),
      psk: serializer.fromJson<Uint8List?>(json['psk']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'index': serializer.toJson<int>(index),
      'name': serializer.toJson<String>(name),
      'role': serializer.toJson<int>(role),
      'psk': serializer.toJson<Uint8List?>(psk),
    };
  }

  MeshChannel copyWith({
    int? index,
    String? name,
    int? role,
    Value<Uint8List?> psk = const Value.absent(),
  }) => MeshChannel(
    index: index ?? this.index,
    name: name ?? this.name,
    role: role ?? this.role,
    psk: psk.present ? psk.value : this.psk,
  );
  MeshChannel copyWithCompanion(ChannelsCompanion data) {
    return MeshChannel(
      index: data.index.present ? data.index.value : this.index,
      name: data.name.present ? data.name.value : this.name,
      role: data.role.present ? data.role.value : this.role,
      psk: data.psk.present ? data.psk.value : this.psk,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeshChannel(')
          ..write('index: $index, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('psk: $psk')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(index, name, role, $driftBlobEquality.hash(psk));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeshChannel &&
          other.index == this.index &&
          other.name == this.name &&
          other.role == this.role &&
          $driftBlobEquality.equals(other.psk, this.psk));
}

class ChannelsCompanion extends UpdateCompanion<MeshChannel> {
  final Value<int> index;
  final Value<String> name;
  final Value<int> role;
  final Value<Uint8List?> psk;
  const ChannelsCompanion({
    this.index = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.psk = const Value.absent(),
  });
  ChannelsCompanion.insert({
    this.index = const Value.absent(),
    this.name = const Value.absent(),
    this.role = const Value.absent(),
    this.psk = const Value.absent(),
  });
  static Insertable<MeshChannel> custom({
    Expression<int>? index,
    Expression<String>? name,
    Expression<int>? role,
    Expression<Uint8List>? psk,
  }) {
    return RawValuesInsertable({
      if (index != null) 'index': index,
      if (name != null) 'name': name,
      if (role != null) 'role': role,
      if (psk != null) 'psk': psk,
    });
  }

  ChannelsCompanion copyWith({
    Value<int>? index,
    Value<String>? name,
    Value<int>? role,
    Value<Uint8List?>? psk,
  }) {
    return ChannelsCompanion(
      index: index ?? this.index,
      name: name ?? this.name,
      role: role ?? this.role,
      psk: psk ?? this.psk,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (index.present) {
      map['index'] = Variable<int>(index.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (role.present) {
      map['role'] = Variable<int>(role.value);
    }
    if (psk.present) {
      map['psk'] = Variable<Uint8List>(psk.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChannelsCompanion(')
          ..write('index: $index, ')
          ..write('name: $name, ')
          ..write('role: $role, ')
          ..write('psk: $psk')
          ..write(')'))
        .toString();
  }
}

class $PositionsTable extends Positions
    with TableInfo<$PositionsTable, PositionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PositionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nodeNumMeta = const VerificationMeta(
    'nodeNum',
  );
  @override
  late final GeneratedColumn<int> nodeNum = GeneratedColumn<int>(
    'node_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _latitudeMeta = const VerificationMeta(
    'latitude',
  );
  @override
  late final GeneratedColumn<double> latitude = GeneratedColumn<double>(
    'latitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _longitudeMeta = const VerificationMeta(
    'longitude',
  );
  @override
  late final GeneratedColumn<double> longitude = GeneratedColumn<double>(
    'longitude',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _altitudeMeta = const VerificationMeta(
    'altitude',
  );
  @override
  late final GeneratedColumn<int> altitude = GeneratedColumn<int>(
    'altitude',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nodeNum,
    time,
    latitude,
    longitude,
    altitude,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'positions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PositionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('node_num')) {
      context.handle(
        _nodeNumMeta,
        nodeNum.isAcceptableOrUnknown(data['node_num']!, _nodeNumMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeNumMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('latitude')) {
      context.handle(
        _latitudeMeta,
        latitude.isAcceptableOrUnknown(data['latitude']!, _latitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_latitudeMeta);
    }
    if (data.containsKey('longitude')) {
      context.handle(
        _longitudeMeta,
        longitude.isAcceptableOrUnknown(data['longitude']!, _longitudeMeta),
      );
    } else if (isInserting) {
      context.missing(_longitudeMeta);
    }
    if (data.containsKey('altitude')) {
      context.handle(
        _altitudeMeta,
        altitude.isAcceptableOrUnknown(data['altitude']!, _altitudeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PositionRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PositionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nodeNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}node_num'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      latitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}latitude'],
      )!,
      longitude: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}longitude'],
      )!,
      altitude: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}altitude'],
      ),
    );
  }

  @override
  $PositionsTable createAlias(String alias) {
    return $PositionsTable(attachedDatabase, alias);
  }
}

class PositionRecord extends DataClass implements Insertable<PositionRecord> {
  final int id;
  final int nodeNum;
  final DateTime time;
  final double latitude;
  final double longitude;
  final int? altitude;
  const PositionRecord({
    required this.id,
    required this.nodeNum,
    required this.time,
    required this.latitude,
    required this.longitude,
    this.altitude,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['node_num'] = Variable<int>(nodeNum);
    map['time'] = Variable<DateTime>(time);
    map['latitude'] = Variable<double>(latitude);
    map['longitude'] = Variable<double>(longitude);
    if (!nullToAbsent || altitude != null) {
      map['altitude'] = Variable<int>(altitude);
    }
    return map;
  }

  PositionsCompanion toCompanion(bool nullToAbsent) {
    return PositionsCompanion(
      id: Value(id),
      nodeNum: Value(nodeNum),
      time: Value(time),
      latitude: Value(latitude),
      longitude: Value(longitude),
      altitude: altitude == null && nullToAbsent
          ? const Value.absent()
          : Value(altitude),
    );
  }

  factory PositionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PositionRecord(
      id: serializer.fromJson<int>(json['id']),
      nodeNum: serializer.fromJson<int>(json['nodeNum']),
      time: serializer.fromJson<DateTime>(json['time']),
      latitude: serializer.fromJson<double>(json['latitude']),
      longitude: serializer.fromJson<double>(json['longitude']),
      altitude: serializer.fromJson<int?>(json['altitude']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nodeNum': serializer.toJson<int>(nodeNum),
      'time': serializer.toJson<DateTime>(time),
      'latitude': serializer.toJson<double>(latitude),
      'longitude': serializer.toJson<double>(longitude),
      'altitude': serializer.toJson<int?>(altitude),
    };
  }

  PositionRecord copyWith({
    int? id,
    int? nodeNum,
    DateTime? time,
    double? latitude,
    double? longitude,
    Value<int?> altitude = const Value.absent(),
  }) => PositionRecord(
    id: id ?? this.id,
    nodeNum: nodeNum ?? this.nodeNum,
    time: time ?? this.time,
    latitude: latitude ?? this.latitude,
    longitude: longitude ?? this.longitude,
    altitude: altitude.present ? altitude.value : this.altitude,
  );
  PositionRecord copyWithCompanion(PositionsCompanion data) {
    return PositionRecord(
      id: data.id.present ? data.id.value : this.id,
      nodeNum: data.nodeNum.present ? data.nodeNum.value : this.nodeNum,
      time: data.time.present ? data.time.value : this.time,
      latitude: data.latitude.present ? data.latitude.value : this.latitude,
      longitude: data.longitude.present ? data.longitude.value : this.longitude,
      altitude: data.altitude.present ? data.altitude.value : this.altitude,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PositionRecord(')
          ..write('id: $id, ')
          ..write('nodeNum: $nodeNum, ')
          ..write('time: $time, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nodeNum, time, latitude, longitude, altitude);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PositionRecord &&
          other.id == this.id &&
          other.nodeNum == this.nodeNum &&
          other.time == this.time &&
          other.latitude == this.latitude &&
          other.longitude == this.longitude &&
          other.altitude == this.altitude);
}

class PositionsCompanion extends UpdateCompanion<PositionRecord> {
  final Value<int> id;
  final Value<int> nodeNum;
  final Value<DateTime> time;
  final Value<double> latitude;
  final Value<double> longitude;
  final Value<int?> altitude;
  const PositionsCompanion({
    this.id = const Value.absent(),
    this.nodeNum = const Value.absent(),
    this.time = const Value.absent(),
    this.latitude = const Value.absent(),
    this.longitude = const Value.absent(),
    this.altitude = const Value.absent(),
  });
  PositionsCompanion.insert({
    this.id = const Value.absent(),
    required int nodeNum,
    required DateTime time,
    required double latitude,
    required double longitude,
    this.altitude = const Value.absent(),
  }) : nodeNum = Value(nodeNum),
       time = Value(time),
       latitude = Value(latitude),
       longitude = Value(longitude);
  static Insertable<PositionRecord> custom({
    Expression<int>? id,
    Expression<int>? nodeNum,
    Expression<DateTime>? time,
    Expression<double>? latitude,
    Expression<double>? longitude,
    Expression<int>? altitude,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nodeNum != null) 'node_num': nodeNum,
      if (time != null) 'time': time,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      if (altitude != null) 'altitude': altitude,
    });
  }

  PositionsCompanion copyWith({
    Value<int>? id,
    Value<int>? nodeNum,
    Value<DateTime>? time,
    Value<double>? latitude,
    Value<double>? longitude,
    Value<int?>? altitude,
  }) {
    return PositionsCompanion(
      id: id ?? this.id,
      nodeNum: nodeNum ?? this.nodeNum,
      time: time ?? this.time,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      altitude: altitude ?? this.altitude,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nodeNum.present) {
      map['node_num'] = Variable<int>(nodeNum.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (latitude.present) {
      map['latitude'] = Variable<double>(latitude.value);
    }
    if (longitude.present) {
      map['longitude'] = Variable<double>(longitude.value);
    }
    if (altitude.present) {
      map['altitude'] = Variable<int>(altitude.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PositionsCompanion(')
          ..write('id: $id, ')
          ..write('nodeNum: $nodeNum, ')
          ..write('time: $time, ')
          ..write('latitude: $latitude, ')
          ..write('longitude: $longitude, ')
          ..write('altitude: $altitude')
          ..write(')'))
        .toString();
  }
}

class $TelemetryLogTable extends TelemetryLog
    with TableInfo<$TelemetryLogTable, TelemetryLogData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TelemetryLogTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nodeNumMeta = const VerificationMeta(
    'nodeNum',
  );
  @override
  late final GeneratedColumn<int> nodeNum = GeneratedColumn<int>(
    'node_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, nodeNum, time, kind, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'telemetry_log';
  @override
  VerificationContext validateIntegrity(
    Insertable<TelemetryLogData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('node_num')) {
      context.handle(
        _nodeNumMeta,
        nodeNum.isAcceptableOrUnknown(data['node_num']!, _nodeNumMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeNumMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TelemetryLogData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TelemetryLogData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nodeNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}node_num'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $TelemetryLogTable createAlias(String alias) {
    return $TelemetryLogTable(attachedDatabase, alias);
  }
}

class TelemetryLogData extends DataClass
    implements Insertable<TelemetryLogData> {
  final int id;
  final int nodeNum;
  final DateTime time;

  /// Имя варианта Telemetry: deviceMetrics, environmentMetrics, powerMetrics…
  final String kind;
  final Uint8List data;
  const TelemetryLogData({
    required this.id,
    required this.nodeNum,
    required this.time,
    required this.kind,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['node_num'] = Variable<int>(nodeNum);
    map['time'] = Variable<DateTime>(time);
    map['kind'] = Variable<String>(kind);
    map['data'] = Variable<Uint8List>(data);
    return map;
  }

  TelemetryLogCompanion toCompanion(bool nullToAbsent) {
    return TelemetryLogCompanion(
      id: Value(id),
      nodeNum: Value(nodeNum),
      time: Value(time),
      kind: Value(kind),
      data: Value(data),
    );
  }

  factory TelemetryLogData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TelemetryLogData(
      id: serializer.fromJson<int>(json['id']),
      nodeNum: serializer.fromJson<int>(json['nodeNum']),
      time: serializer.fromJson<DateTime>(json['time']),
      kind: serializer.fromJson<String>(json['kind']),
      data: serializer.fromJson<Uint8List>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nodeNum': serializer.toJson<int>(nodeNum),
      'time': serializer.toJson<DateTime>(time),
      'kind': serializer.toJson<String>(kind),
      'data': serializer.toJson<Uint8List>(data),
    };
  }

  TelemetryLogData copyWith({
    int? id,
    int? nodeNum,
    DateTime? time,
    String? kind,
    Uint8List? data,
  }) => TelemetryLogData(
    id: id ?? this.id,
    nodeNum: nodeNum ?? this.nodeNum,
    time: time ?? this.time,
    kind: kind ?? this.kind,
    data: data ?? this.data,
  );
  TelemetryLogData copyWithCompanion(TelemetryLogCompanion data) {
    return TelemetryLogData(
      id: data.id.present ? data.id.value : this.id,
      nodeNum: data.nodeNum.present ? data.nodeNum.value : this.nodeNum,
      time: data.time.present ? data.time.value : this.time,
      kind: data.kind.present ? data.kind.value : this.kind,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TelemetryLogData(')
          ..write('id: $id, ')
          ..write('nodeNum: $nodeNum, ')
          ..write('time: $time, ')
          ..write('kind: $kind, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nodeNum, time, kind, $driftBlobEquality.hash(data));
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TelemetryLogData &&
          other.id == this.id &&
          other.nodeNum == this.nodeNum &&
          other.time == this.time &&
          other.kind == this.kind &&
          $driftBlobEquality.equals(other.data, this.data));
}

class TelemetryLogCompanion extends UpdateCompanion<TelemetryLogData> {
  final Value<int> id;
  final Value<int> nodeNum;
  final Value<DateTime> time;
  final Value<String> kind;
  final Value<Uint8List> data;
  const TelemetryLogCompanion({
    this.id = const Value.absent(),
    this.nodeNum = const Value.absent(),
    this.time = const Value.absent(),
    this.kind = const Value.absent(),
    this.data = const Value.absent(),
  });
  TelemetryLogCompanion.insert({
    this.id = const Value.absent(),
    required int nodeNum,
    required DateTime time,
    required String kind,
    required Uint8List data,
  }) : nodeNum = Value(nodeNum),
       time = Value(time),
       kind = Value(kind),
       data = Value(data);
  static Insertable<TelemetryLogData> custom({
    Expression<int>? id,
    Expression<int>? nodeNum,
    Expression<DateTime>? time,
    Expression<String>? kind,
    Expression<Uint8List>? data,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nodeNum != null) 'node_num': nodeNum,
      if (time != null) 'time': time,
      if (kind != null) 'kind': kind,
      if (data != null) 'data': data,
    });
  }

  TelemetryLogCompanion copyWith({
    Value<int>? id,
    Value<int>? nodeNum,
    Value<DateTime>? time,
    Value<String>? kind,
    Value<Uint8List>? data,
  }) {
    return TelemetryLogCompanion(
      id: id ?? this.id,
      nodeNum: nodeNum ?? this.nodeNum,
      time: time ?? this.time,
      kind: kind ?? this.kind,
      data: data ?? this.data,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nodeNum.present) {
      map['node_num'] = Variable<int>(nodeNum.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TelemetryLogCompanion(')
          ..write('id: $id, ')
          ..write('nodeNum: $nodeNum, ')
          ..write('time: $time, ')
          ..write('kind: $kind, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }
}

class $TraceroutesTable extends Traceroutes
    with TableInfo<$TraceroutesTable, TracerouteRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TraceroutesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _requestIdMeta = const VerificationMeta(
    'requestId',
  );
  @override
  late final GeneratedColumn<int> requestId = GeneratedColumn<int>(
    'request_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetNumMeta = const VerificationMeta(
    'targetNum',
  );
  @override
  late final GeneratedColumn<int> targetNum = GeneratedColumn<int>(
    'target_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, requestId, targetNum, time, data];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'traceroutes';
  @override
  VerificationContext validateIntegrity(
    Insertable<TracerouteRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('request_id')) {
      context.handle(
        _requestIdMeta,
        requestId.isAcceptableOrUnknown(data['request_id']!, _requestIdMeta),
      );
    } else if (isInserting) {
      context.missing(_requestIdMeta);
    }
    if (data.containsKey('target_num')) {
      context.handle(
        _targetNumMeta,
        targetNum.isAcceptableOrUnknown(data['target_num']!, _targetNumMeta),
      );
    } else if (isInserting) {
      context.missing(_targetNumMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TracerouteRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TracerouteRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      requestId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}request_id'],
      )!,
      targetNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_num'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}data'],
      )!,
    );
  }

  @override
  $TraceroutesTable createAlias(String alias) {
    return $TraceroutesTable(attachedDatabase, alias);
  }
}

class TracerouteRecord extends DataClass
    implements Insertable<TracerouteRecord> {
  final int id;
  final int requestId;
  final int targetNum;
  final DateTime time;
  final Uint8List data;
  const TracerouteRecord({
    required this.id,
    required this.requestId,
    required this.targetNum,
    required this.time,
    required this.data,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['request_id'] = Variable<int>(requestId);
    map['target_num'] = Variable<int>(targetNum);
    map['time'] = Variable<DateTime>(time);
    map['data'] = Variable<Uint8List>(data);
    return map;
  }

  TraceroutesCompanion toCompanion(bool nullToAbsent) {
    return TraceroutesCompanion(
      id: Value(id),
      requestId: Value(requestId),
      targetNum: Value(targetNum),
      time: Value(time),
      data: Value(data),
    );
  }

  factory TracerouteRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TracerouteRecord(
      id: serializer.fromJson<int>(json['id']),
      requestId: serializer.fromJson<int>(json['requestId']),
      targetNum: serializer.fromJson<int>(json['targetNum']),
      time: serializer.fromJson<DateTime>(json['time']),
      data: serializer.fromJson<Uint8List>(json['data']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'requestId': serializer.toJson<int>(requestId),
      'targetNum': serializer.toJson<int>(targetNum),
      'time': serializer.toJson<DateTime>(time),
      'data': serializer.toJson<Uint8List>(data),
    };
  }

  TracerouteRecord copyWith({
    int? id,
    int? requestId,
    int? targetNum,
    DateTime? time,
    Uint8List? data,
  }) => TracerouteRecord(
    id: id ?? this.id,
    requestId: requestId ?? this.requestId,
    targetNum: targetNum ?? this.targetNum,
    time: time ?? this.time,
    data: data ?? this.data,
  );
  TracerouteRecord copyWithCompanion(TraceroutesCompanion data) {
    return TracerouteRecord(
      id: data.id.present ? data.id.value : this.id,
      requestId: data.requestId.present ? data.requestId.value : this.requestId,
      targetNum: data.targetNum.present ? data.targetNum.value : this.targetNum,
      time: data.time.present ? data.time.value : this.time,
      data: data.data.present ? data.data.value : this.data,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TracerouteRecord(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('targetNum: $targetNum, ')
          ..write('time: $time, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    requestId,
    targetNum,
    time,
    $driftBlobEquality.hash(data),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TracerouteRecord &&
          other.id == this.id &&
          other.requestId == this.requestId &&
          other.targetNum == this.targetNum &&
          other.time == this.time &&
          $driftBlobEquality.equals(other.data, this.data));
}

class TraceroutesCompanion extends UpdateCompanion<TracerouteRecord> {
  final Value<int> id;
  final Value<int> requestId;
  final Value<int> targetNum;
  final Value<DateTime> time;
  final Value<Uint8List> data;
  const TraceroutesCompanion({
    this.id = const Value.absent(),
    this.requestId = const Value.absent(),
    this.targetNum = const Value.absent(),
    this.time = const Value.absent(),
    this.data = const Value.absent(),
  });
  TraceroutesCompanion.insert({
    this.id = const Value.absent(),
    required int requestId,
    required int targetNum,
    required DateTime time,
    required Uint8List data,
  }) : requestId = Value(requestId),
       targetNum = Value(targetNum),
       time = Value(time),
       data = Value(data);
  static Insertable<TracerouteRecord> custom({
    Expression<int>? id,
    Expression<int>? requestId,
    Expression<int>? targetNum,
    Expression<DateTime>? time,
    Expression<Uint8List>? data,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (requestId != null) 'request_id': requestId,
      if (targetNum != null) 'target_num': targetNum,
      if (time != null) 'time': time,
      if (data != null) 'data': data,
    });
  }

  TraceroutesCompanion copyWith({
    Value<int>? id,
    Value<int>? requestId,
    Value<int>? targetNum,
    Value<DateTime>? time,
    Value<Uint8List>? data,
  }) {
    return TraceroutesCompanion(
      id: id ?? this.id,
      requestId: requestId ?? this.requestId,
      targetNum: targetNum ?? this.targetNum,
      time: time ?? this.time,
      data: data ?? this.data,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (requestId.present) {
      map['request_id'] = Variable<int>(requestId.value);
    }
    if (targetNum.present) {
      map['target_num'] = Variable<int>(targetNum.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TraceroutesCompanion(')
          ..write('id: $id, ')
          ..write('requestId: $requestId, ')
          ..write('targetNum: $targetNum, ')
          ..write('time: $time, ')
          ..write('data: $data')
          ..write(')'))
        .toString();
  }
}

class $NeighborsTable extends Neighbors
    with TableInfo<$NeighborsTable, NeighborRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $NeighborsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _nodeNumMeta = const VerificationMeta(
    'nodeNum',
  );
  @override
  late final GeneratedColumn<int> nodeNum = GeneratedColumn<int>(
    'node_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _neighborNumMeta = const VerificationMeta(
    'neighborNum',
  );
  @override
  late final GeneratedColumn<int> neighborNum = GeneratedColumn<int>(
    'neighbor_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _snrMeta = const VerificationMeta('snr');
  @override
  late final GeneratedColumn<double> snr = GeneratedColumn<double>(
    'snr',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timeMeta = const VerificationMeta('time');
  @override
  late final GeneratedColumn<DateTime> time = GeneratedColumn<DateTime>(
    'time',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [nodeNum, neighborNum, snr, time];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'neighbors';
  @override
  VerificationContext validateIntegrity(
    Insertable<NeighborRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('node_num')) {
      context.handle(
        _nodeNumMeta,
        nodeNum.isAcceptableOrUnknown(data['node_num']!, _nodeNumMeta),
      );
    } else if (isInserting) {
      context.missing(_nodeNumMeta);
    }
    if (data.containsKey('neighbor_num')) {
      context.handle(
        _neighborNumMeta,
        neighborNum.isAcceptableOrUnknown(
          data['neighbor_num']!,
          _neighborNumMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_neighborNumMeta);
    }
    if (data.containsKey('snr')) {
      context.handle(
        _snrMeta,
        snr.isAcceptableOrUnknown(data['snr']!, _snrMeta),
      );
    } else if (isInserting) {
      context.missing(_snrMeta);
    }
    if (data.containsKey('time')) {
      context.handle(
        _timeMeta,
        time.isAcceptableOrUnknown(data['time']!, _timeMeta),
      );
    } else if (isInserting) {
      context.missing(_timeMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {nodeNum, neighborNum};
  @override
  NeighborRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return NeighborRecord(
      nodeNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}node_num'],
      )!,
      neighborNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}neighbor_num'],
      )!,
      snr: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}snr'],
      )!,
      time: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}time'],
      )!,
    );
  }

  @override
  $NeighborsTable createAlias(String alias) {
    return $NeighborsTable(attachedDatabase, alias);
  }
}

class NeighborRecord extends DataClass implements Insertable<NeighborRecord> {
  final int nodeNum;
  final int neighborNum;
  final double snr;
  final DateTime time;
  const NeighborRecord({
    required this.nodeNum,
    required this.neighborNum,
    required this.snr,
    required this.time,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['node_num'] = Variable<int>(nodeNum);
    map['neighbor_num'] = Variable<int>(neighborNum);
    map['snr'] = Variable<double>(snr);
    map['time'] = Variable<DateTime>(time);
    return map;
  }

  NeighborsCompanion toCompanion(bool nullToAbsent) {
    return NeighborsCompanion(
      nodeNum: Value(nodeNum),
      neighborNum: Value(neighborNum),
      snr: Value(snr),
      time: Value(time),
    );
  }

  factory NeighborRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return NeighborRecord(
      nodeNum: serializer.fromJson<int>(json['nodeNum']),
      neighborNum: serializer.fromJson<int>(json['neighborNum']),
      snr: serializer.fromJson<double>(json['snr']),
      time: serializer.fromJson<DateTime>(json['time']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'nodeNum': serializer.toJson<int>(nodeNum),
      'neighborNum': serializer.toJson<int>(neighborNum),
      'snr': serializer.toJson<double>(snr),
      'time': serializer.toJson<DateTime>(time),
    };
  }

  NeighborRecord copyWith({
    int? nodeNum,
    int? neighborNum,
    double? snr,
    DateTime? time,
  }) => NeighborRecord(
    nodeNum: nodeNum ?? this.nodeNum,
    neighborNum: neighborNum ?? this.neighborNum,
    snr: snr ?? this.snr,
    time: time ?? this.time,
  );
  NeighborRecord copyWithCompanion(NeighborsCompanion data) {
    return NeighborRecord(
      nodeNum: data.nodeNum.present ? data.nodeNum.value : this.nodeNum,
      neighborNum: data.neighborNum.present
          ? data.neighborNum.value
          : this.neighborNum,
      snr: data.snr.present ? data.snr.value : this.snr,
      time: data.time.present ? data.time.value : this.time,
    );
  }

  @override
  String toString() {
    return (StringBuffer('NeighborRecord(')
          ..write('nodeNum: $nodeNum, ')
          ..write('neighborNum: $neighborNum, ')
          ..write('snr: $snr, ')
          ..write('time: $time')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(nodeNum, neighborNum, snr, time);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is NeighborRecord &&
          other.nodeNum == this.nodeNum &&
          other.neighborNum == this.neighborNum &&
          other.snr == this.snr &&
          other.time == this.time);
}

class NeighborsCompanion extends UpdateCompanion<NeighborRecord> {
  final Value<int> nodeNum;
  final Value<int> neighborNum;
  final Value<double> snr;
  final Value<DateTime> time;
  final Value<int> rowid;
  const NeighborsCompanion({
    this.nodeNum = const Value.absent(),
    this.neighborNum = const Value.absent(),
    this.snr = const Value.absent(),
    this.time = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  NeighborsCompanion.insert({
    required int nodeNum,
    required int neighborNum,
    required double snr,
    required DateTime time,
    this.rowid = const Value.absent(),
  }) : nodeNum = Value(nodeNum),
       neighborNum = Value(neighborNum),
       snr = Value(snr),
       time = Value(time);
  static Insertable<NeighborRecord> custom({
    Expression<int>? nodeNum,
    Expression<int>? neighborNum,
    Expression<double>? snr,
    Expression<DateTime>? time,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (nodeNum != null) 'node_num': nodeNum,
      if (neighborNum != null) 'neighbor_num': neighborNum,
      if (snr != null) 'snr': snr,
      if (time != null) 'time': time,
      if (rowid != null) 'rowid': rowid,
    });
  }

  NeighborsCompanion copyWith({
    Value<int>? nodeNum,
    Value<int>? neighborNum,
    Value<double>? snr,
    Value<DateTime>? time,
    Value<int>? rowid,
  }) {
    return NeighborsCompanion(
      nodeNum: nodeNum ?? this.nodeNum,
      neighborNum: neighborNum ?? this.neighborNum,
      snr: snr ?? this.snr,
      time: time ?? this.time,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (nodeNum.present) {
      map['node_num'] = Variable<int>(nodeNum.value);
    }
    if (neighborNum.present) {
      map['neighbor_num'] = Variable<int>(neighborNum.value);
    }
    if (snr.present) {
      map['snr'] = Variable<double>(snr.value);
    }
    if (time.present) {
      map['time'] = Variable<DateTime>(time.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('NeighborsCompanion(')
          ..write('nodeNum: $nodeNum, ')
          ..write('neighborNum: $neighborNum, ')
          ..write('snr: $snr, ')
          ..write('time: $time, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MyNodeTable extends MyNode with TableInfo<$MyNodeTable, MyNodeRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MyNodeTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _myNodeNumMeta = const VerificationMeta(
    'myNodeNum',
  );
  @override
  late final GeneratedColumn<int> myNodeNum = GeneratedColumn<int>(
    'my_node_num',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rebootCountMeta = const VerificationMeta(
    'rebootCount',
  );
  @override
  late final GeneratedColumn<int> rebootCount = GeneratedColumn<int>(
    'reboot_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _firmwareVersionMeta = const VerificationMeta(
    'firmwareVersion',
  );
  @override
  late final GeneratedColumn<String> firmwareVersion = GeneratedColumn<String>(
    'firmware_version',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _metadataMeta = const VerificationMeta(
    'metadata',
  );
  @override
  late final GeneratedColumn<Uint8List> metadata = GeneratedColumn<Uint8List>(
    'metadata',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    myNodeNum,
    rebootCount,
    firmwareVersion,
    metadata,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'my_node';
  @override
  VerificationContext validateIntegrity(
    Insertable<MyNodeRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('my_node_num')) {
      context.handle(
        _myNodeNumMeta,
        myNodeNum.isAcceptableOrUnknown(data['my_node_num']!, _myNodeNumMeta),
      );
    } else if (isInserting) {
      context.missing(_myNodeNumMeta);
    }
    if (data.containsKey('reboot_count')) {
      context.handle(
        _rebootCountMeta,
        rebootCount.isAcceptableOrUnknown(
          data['reboot_count']!,
          _rebootCountMeta,
        ),
      );
    }
    if (data.containsKey('firmware_version')) {
      context.handle(
        _firmwareVersionMeta,
        firmwareVersion.isAcceptableOrUnknown(
          data['firmware_version']!,
          _firmwareVersionMeta,
        ),
      );
    }
    if (data.containsKey('metadata')) {
      context.handle(
        _metadataMeta,
        metadata.isAcceptableOrUnknown(data['metadata']!, _metadataMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MyNodeRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MyNodeRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      myNodeNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}my_node_num'],
      )!,
      rebootCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reboot_count'],
      )!,
      firmwareVersion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}firmware_version'],
      )!,
      metadata: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}metadata'],
      ),
    );
  }

  @override
  $MyNodeTable createAlias(String alias) {
    return $MyNodeTable(attachedDatabase, alias);
  }
}

class MyNodeRecord extends DataClass implements Insertable<MyNodeRecord> {
  final int id;
  final int myNodeNum;
  final int rebootCount;
  final String firmwareVersion;
  final Uint8List? metadata;
  const MyNodeRecord({
    required this.id,
    required this.myNodeNum,
    required this.rebootCount,
    required this.firmwareVersion,
    this.metadata,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['my_node_num'] = Variable<int>(myNodeNum);
    map['reboot_count'] = Variable<int>(rebootCount);
    map['firmware_version'] = Variable<String>(firmwareVersion);
    if (!nullToAbsent || metadata != null) {
      map['metadata'] = Variable<Uint8List>(metadata);
    }
    return map;
  }

  MyNodeCompanion toCompanion(bool nullToAbsent) {
    return MyNodeCompanion(
      id: Value(id),
      myNodeNum: Value(myNodeNum),
      rebootCount: Value(rebootCount),
      firmwareVersion: Value(firmwareVersion),
      metadata: metadata == null && nullToAbsent
          ? const Value.absent()
          : Value(metadata),
    );
  }

  factory MyNodeRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MyNodeRecord(
      id: serializer.fromJson<int>(json['id']),
      myNodeNum: serializer.fromJson<int>(json['myNodeNum']),
      rebootCount: serializer.fromJson<int>(json['rebootCount']),
      firmwareVersion: serializer.fromJson<String>(json['firmwareVersion']),
      metadata: serializer.fromJson<Uint8List?>(json['metadata']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'myNodeNum': serializer.toJson<int>(myNodeNum),
      'rebootCount': serializer.toJson<int>(rebootCount),
      'firmwareVersion': serializer.toJson<String>(firmwareVersion),
      'metadata': serializer.toJson<Uint8List?>(metadata),
    };
  }

  MyNodeRecord copyWith({
    int? id,
    int? myNodeNum,
    int? rebootCount,
    String? firmwareVersion,
    Value<Uint8List?> metadata = const Value.absent(),
  }) => MyNodeRecord(
    id: id ?? this.id,
    myNodeNum: myNodeNum ?? this.myNodeNum,
    rebootCount: rebootCount ?? this.rebootCount,
    firmwareVersion: firmwareVersion ?? this.firmwareVersion,
    metadata: metadata.present ? metadata.value : this.metadata,
  );
  MyNodeRecord copyWithCompanion(MyNodeCompanion data) {
    return MyNodeRecord(
      id: data.id.present ? data.id.value : this.id,
      myNodeNum: data.myNodeNum.present ? data.myNodeNum.value : this.myNodeNum,
      rebootCount: data.rebootCount.present
          ? data.rebootCount.value
          : this.rebootCount,
      firmwareVersion: data.firmwareVersion.present
          ? data.firmwareVersion.value
          : this.firmwareVersion,
      metadata: data.metadata.present ? data.metadata.value : this.metadata,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MyNodeRecord(')
          ..write('id: $id, ')
          ..write('myNodeNum: $myNodeNum, ')
          ..write('rebootCount: $rebootCount, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    myNodeNum,
    rebootCount,
    firmwareVersion,
    $driftBlobEquality.hash(metadata),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MyNodeRecord &&
          other.id == this.id &&
          other.myNodeNum == this.myNodeNum &&
          other.rebootCount == this.rebootCount &&
          other.firmwareVersion == this.firmwareVersion &&
          $driftBlobEquality.equals(other.metadata, this.metadata));
}

class MyNodeCompanion extends UpdateCompanion<MyNodeRecord> {
  final Value<int> id;
  final Value<int> myNodeNum;
  final Value<int> rebootCount;
  final Value<String> firmwareVersion;
  final Value<Uint8List?> metadata;
  const MyNodeCompanion({
    this.id = const Value.absent(),
    this.myNodeNum = const Value.absent(),
    this.rebootCount = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.metadata = const Value.absent(),
  });
  MyNodeCompanion.insert({
    this.id = const Value.absent(),
    required int myNodeNum,
    this.rebootCount = const Value.absent(),
    this.firmwareVersion = const Value.absent(),
    this.metadata = const Value.absent(),
  }) : myNodeNum = Value(myNodeNum);
  static Insertable<MyNodeRecord> custom({
    Expression<int>? id,
    Expression<int>? myNodeNum,
    Expression<int>? rebootCount,
    Expression<String>? firmwareVersion,
    Expression<Uint8List>? metadata,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (myNodeNum != null) 'my_node_num': myNodeNum,
      if (rebootCount != null) 'reboot_count': rebootCount,
      if (firmwareVersion != null) 'firmware_version': firmwareVersion,
      if (metadata != null) 'metadata': metadata,
    });
  }

  MyNodeCompanion copyWith({
    Value<int>? id,
    Value<int>? myNodeNum,
    Value<int>? rebootCount,
    Value<String>? firmwareVersion,
    Value<Uint8List?>? metadata,
  }) {
    return MyNodeCompanion(
      id: id ?? this.id,
      myNodeNum: myNodeNum ?? this.myNodeNum,
      rebootCount: rebootCount ?? this.rebootCount,
      firmwareVersion: firmwareVersion ?? this.firmwareVersion,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (myNodeNum.present) {
      map['my_node_num'] = Variable<int>(myNodeNum.value);
    }
    if (rebootCount.present) {
      map['reboot_count'] = Variable<int>(rebootCount.value);
    }
    if (firmwareVersion.present) {
      map['firmware_version'] = Variable<String>(firmwareVersion.value);
    }
    if (metadata.present) {
      map['metadata'] = Variable<Uint8List>(metadata.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MyNodeCompanion(')
          ..write('id: $id, ')
          ..write('myNodeNum: $myNodeNum, ')
          ..write('rebootCount: $rebootCount, ')
          ..write('firmwareVersion: $firmwareVersion, ')
          ..write('metadata: $metadata')
          ..write(')'))
        .toString();
  }
}

class $ConfigBlobsTable extends ConfigBlobs
    with TableInfo<$ConfigBlobsTable, ConfigBlob> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ConfigBlobsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<Uint8List> data = GeneratedColumn<Uint8List>(
    'data',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedMeta = const VerificationMeta(
    'updated',
  );
  @override
  late final GeneratedColumn<DateTime> updated = GeneratedColumn<DateTime>(
    'updated',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, data, updated];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'config_blobs';
  @override
  VerificationContext validateIntegrity(
    Insertable<ConfigBlob> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
        _dataMeta,
        this.data.isAcceptableOrUnknown(data['data']!, _dataMeta),
      );
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('updated')) {
      context.handle(
        _updatedMeta,
        updated.isAcceptableOrUnknown(data['updated']!, _updatedMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  ConfigBlob map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ConfigBlob(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      data: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}data'],
      )!,
      updated: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated'],
      )!,
    );
  }

  @override
  $ConfigBlobsTable createAlias(String alias) {
    return $ConfigBlobsTable(attachedDatabase, alias);
  }
}

class ConfigBlob extends DataClass implements Insertable<ConfigBlob> {
  final String key;
  final Uint8List data;
  final DateTime updated;
  const ConfigBlob({
    required this.key,
    required this.data,
    required this.updated,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['data'] = Variable<Uint8List>(data);
    map['updated'] = Variable<DateTime>(updated);
    return map;
  }

  ConfigBlobsCompanion toCompanion(bool nullToAbsent) {
    return ConfigBlobsCompanion(
      key: Value(key),
      data: Value(data),
      updated: Value(updated),
    );
  }

  factory ConfigBlob.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ConfigBlob(
      key: serializer.fromJson<String>(json['key']),
      data: serializer.fromJson<Uint8List>(json['data']),
      updated: serializer.fromJson<DateTime>(json['updated']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'data': serializer.toJson<Uint8List>(data),
      'updated': serializer.toJson<DateTime>(updated),
    };
  }

  ConfigBlob copyWith({String? key, Uint8List? data, DateTime? updated}) =>
      ConfigBlob(
        key: key ?? this.key,
        data: data ?? this.data,
        updated: updated ?? this.updated,
      );
  ConfigBlob copyWithCompanion(ConfigBlobsCompanion data) {
    return ConfigBlob(
      key: data.key.present ? data.key.value : this.key,
      data: data.data.present ? data.data.value : this.data,
      updated: data.updated.present ? data.updated.value : this.updated,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ConfigBlob(')
          ..write('key: $key, ')
          ..write('data: $data, ')
          ..write('updated: $updated')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, $driftBlobEquality.hash(data), updated);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ConfigBlob &&
          other.key == this.key &&
          $driftBlobEquality.equals(other.data, this.data) &&
          other.updated == this.updated);
}

class ConfigBlobsCompanion extends UpdateCompanion<ConfigBlob> {
  final Value<String> key;
  final Value<Uint8List> data;
  final Value<DateTime> updated;
  final Value<int> rowid;
  const ConfigBlobsCompanion({
    this.key = const Value.absent(),
    this.data = const Value.absent(),
    this.updated = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ConfigBlobsCompanion.insert({
    required String key,
    required Uint8List data,
    required DateTime updated,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       data = Value(data),
       updated = Value(updated);
  static Insertable<ConfigBlob> custom({
    Expression<String>? key,
    Expression<Uint8List>? data,
    Expression<DateTime>? updated,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (data != null) 'data': data,
      if (updated != null) 'updated': updated,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ConfigBlobsCompanion copyWith({
    Value<String>? key,
    Value<Uint8List>? data,
    Value<DateTime>? updated,
    Value<int>? rowid,
  }) {
    return ConfigBlobsCompanion(
      key: key ?? this.key,
      data: data ?? this.data,
      updated: updated ?? this.updated,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (data.present) {
      map['data'] = Variable<Uint8List>(data.value);
    }
    if (updated.present) {
      map['updated'] = Variable<DateTime>(updated.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ConfigBlobsCompanion(')
          ..write('key: $key, ')
          ..write('data: $data, ')
          ..write('updated: $updated, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecentConnectionsTable extends RecentConnections
    with TableInfo<$RecentConnectionsTable, RecentConnection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecentConnectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _nodeNumMeta = const VerificationMeta(
    'nodeNum',
  );
  @override
  late final GeneratedColumn<int> nodeNum = GeneratedColumn<int>(
    'node_num',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastUsedMeta = const VerificationMeta(
    'lastUsed',
  );
  @override
  late final GeneratedColumn<DateTime> lastUsed = GeneratedColumn<DateTime>(
    'last_used',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    kind,
    address,
    name,
    nodeNum,
    lastUsed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recent_connections';
  @override
  VerificationContext validateIntegrity(
    Insertable<RecentConnection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    } else if (isInserting) {
      context.missing(_addressMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    }
    if (data.containsKey('node_num')) {
      context.handle(
        _nodeNumMeta,
        nodeNum.isAcceptableOrUnknown(data['node_num']!, _nodeNumMeta),
      );
    }
    if (data.containsKey('last_used')) {
      context.handle(
        _lastUsedMeta,
        lastUsed.isAcceptableOrUnknown(data['last_used']!, _lastUsedMeta),
      );
    } else if (isInserting) {
      context.missing(_lastUsedMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {kind, address};
  @override
  RecentConnection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecentConnection(
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      nodeNum: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}node_num'],
      ),
      lastUsed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_used'],
      )!,
    );
  }

  @override
  $RecentConnectionsTable createAlias(String alias) {
    return $RecentConnectionsTable(attachedDatabase, alias);
  }
}

class RecentConnection extends DataClass
    implements Insertable<RecentConnection> {
  /// EndpointKind.name: ble / tcp / serial.
  final String kind;
  final String address;
  final String name;

  /// Номер ноды на том конце (если успели узнать).
  final int? nodeNum;
  final DateTime lastUsed;
  const RecentConnection({
    required this.kind,
    required this.address,
    required this.name,
    this.nodeNum,
    required this.lastUsed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['kind'] = Variable<String>(kind);
    map['address'] = Variable<String>(address);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || nodeNum != null) {
      map['node_num'] = Variable<int>(nodeNum);
    }
    map['last_used'] = Variable<DateTime>(lastUsed);
    return map;
  }

  RecentConnectionsCompanion toCompanion(bool nullToAbsent) {
    return RecentConnectionsCompanion(
      kind: Value(kind),
      address: Value(address),
      name: Value(name),
      nodeNum: nodeNum == null && nullToAbsent
          ? const Value.absent()
          : Value(nodeNum),
      lastUsed: Value(lastUsed),
    );
  }

  factory RecentConnection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecentConnection(
      kind: serializer.fromJson<String>(json['kind']),
      address: serializer.fromJson<String>(json['address']),
      name: serializer.fromJson<String>(json['name']),
      nodeNum: serializer.fromJson<int?>(json['nodeNum']),
      lastUsed: serializer.fromJson<DateTime>(json['lastUsed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'kind': serializer.toJson<String>(kind),
      'address': serializer.toJson<String>(address),
      'name': serializer.toJson<String>(name),
      'nodeNum': serializer.toJson<int?>(nodeNum),
      'lastUsed': serializer.toJson<DateTime>(lastUsed),
    };
  }

  RecentConnection copyWith({
    String? kind,
    String? address,
    String? name,
    Value<int?> nodeNum = const Value.absent(),
    DateTime? lastUsed,
  }) => RecentConnection(
    kind: kind ?? this.kind,
    address: address ?? this.address,
    name: name ?? this.name,
    nodeNum: nodeNum.present ? nodeNum.value : this.nodeNum,
    lastUsed: lastUsed ?? this.lastUsed,
  );
  RecentConnection copyWithCompanion(RecentConnectionsCompanion data) {
    return RecentConnection(
      kind: data.kind.present ? data.kind.value : this.kind,
      address: data.address.present ? data.address.value : this.address,
      name: data.name.present ? data.name.value : this.name,
      nodeNum: data.nodeNum.present ? data.nodeNum.value : this.nodeNum,
      lastUsed: data.lastUsed.present ? data.lastUsed.value : this.lastUsed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecentConnection(')
          ..write('kind: $kind, ')
          ..write('address: $address, ')
          ..write('name: $name, ')
          ..write('nodeNum: $nodeNum, ')
          ..write('lastUsed: $lastUsed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(kind, address, name, nodeNum, lastUsed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecentConnection &&
          other.kind == this.kind &&
          other.address == this.address &&
          other.name == this.name &&
          other.nodeNum == this.nodeNum &&
          other.lastUsed == this.lastUsed);
}

class RecentConnectionsCompanion extends UpdateCompanion<RecentConnection> {
  final Value<String> kind;
  final Value<String> address;
  final Value<String> name;
  final Value<int?> nodeNum;
  final Value<DateTime> lastUsed;
  final Value<int> rowid;
  const RecentConnectionsCompanion({
    this.kind = const Value.absent(),
    this.address = const Value.absent(),
    this.name = const Value.absent(),
    this.nodeNum = const Value.absent(),
    this.lastUsed = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecentConnectionsCompanion.insert({
    required String kind,
    required String address,
    this.name = const Value.absent(),
    this.nodeNum = const Value.absent(),
    required DateTime lastUsed,
    this.rowid = const Value.absent(),
  }) : kind = Value(kind),
       address = Value(address),
       lastUsed = Value(lastUsed);
  static Insertable<RecentConnection> custom({
    Expression<String>? kind,
    Expression<String>? address,
    Expression<String>? name,
    Expression<int>? nodeNum,
    Expression<DateTime>? lastUsed,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (kind != null) 'kind': kind,
      if (address != null) 'address': address,
      if (name != null) 'name': name,
      if (nodeNum != null) 'node_num': nodeNum,
      if (lastUsed != null) 'last_used': lastUsed,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecentConnectionsCompanion copyWith({
    Value<String>? kind,
    Value<String>? address,
    Value<String>? name,
    Value<int?>? nodeNum,
    Value<DateTime>? lastUsed,
    Value<int>? rowid,
  }) {
    return RecentConnectionsCompanion(
      kind: kind ?? this.kind,
      address: address ?? this.address,
      name: name ?? this.name,
      nodeNum: nodeNum ?? this.nodeNum,
      lastUsed: lastUsed ?? this.lastUsed,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (nodeNum.present) {
      map['node_num'] = Variable<int>(nodeNum.value);
    }
    if (lastUsed.present) {
      map['last_used'] = Variable<DateTime>(lastUsed.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecentConnectionsCompanion(')
          ..write('kind: $kind, ')
          ..write('address: $address, ')
          ..write('name: $name, ')
          ..write('nodeNum: $nodeNum, ')
          ..write('lastUsed: $lastUsed, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $NodesTable nodes = $NodesTable(this);
  late final $MessagesTable messages = $MessagesTable(this);
  late final $ChannelsTable channels = $ChannelsTable(this);
  late final $PositionsTable positions = $PositionsTable(this);
  late final $TelemetryLogTable telemetryLog = $TelemetryLogTable(this);
  late final $TraceroutesTable traceroutes = $TraceroutesTable(this);
  late final $NeighborsTable neighbors = $NeighborsTable(this);
  late final $MyNodeTable myNode = $MyNodeTable(this);
  late final $ConfigBlobsTable configBlobs = $ConfigBlobsTable(this);
  late final $RecentConnectionsTable recentConnections =
      $RecentConnectionsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final Index messagesChannelTime = Index(
    'messages_channel_time',
    'CREATE INDEX messages_channel_time ON messages (channel_key, rx_time)',
  );
  late final Index positionsNodeTime = Index(
    'positions_node_time',
    'CREATE INDEX positions_node_time ON positions (node_num, time)',
  );
  late final Index telemetryNodeKindTime = Index(
    'telemetry_node_kind_time',
    'CREATE INDEX telemetry_node_kind_time ON telemetry_log (node_num, kind, time)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    nodes,
    messages,
    channels,
    positions,
    telemetryLog,
    traceroutes,
    neighbors,
    myNode,
    configBlobs,
    recentConnections,
    appSettings,
    messagesChannelTime,
    positionsNodeTime,
    telemetryNodeKindTime,
  ];
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$NodesTableCreateCompanionBuilder =
    NodesCompanion Function({
      Value<int> num,
      Value<String> userId,
      Value<String> longName,
      Value<String> shortName,
      Value<int> hwModel,
      Value<int> role,
      Value<Uint8List?> publicKey,
      Value<bool> isUnmessagable,
      Value<DateTime?> lastHeard,
      Value<double?> snr,
      Value<int?> hopsAway,
      Value<bool> viaMqtt,
      Value<bool> isFavorite,
      Value<bool> isIgnored,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int?> altitude,
      Value<int?> batteryLevel,
      Value<double?> voltage,
      Value<double?> channelUtilization,
      Value<double?> airUtilTx,
      Value<int?> uptimeSeconds,
      Value<bool> onRadio,
      Value<bool> onMirror,
    });
typedef $$NodesTableUpdateCompanionBuilder =
    NodesCompanion Function({
      Value<int> num,
      Value<String> userId,
      Value<String> longName,
      Value<String> shortName,
      Value<int> hwModel,
      Value<int> role,
      Value<Uint8List?> publicKey,
      Value<bool> isUnmessagable,
      Value<DateTime?> lastHeard,
      Value<double?> snr,
      Value<int?> hopsAway,
      Value<bool> viaMqtt,
      Value<bool> isFavorite,
      Value<bool> isIgnored,
      Value<double?> latitude,
      Value<double?> longitude,
      Value<int?> altitude,
      Value<int?> batteryLevel,
      Value<double?> voltage,
      Value<double?> channelUtilization,
      Value<double?> airUtilTx,
      Value<int?> uptimeSeconds,
      Value<bool> onRadio,
      Value<bool> onMirror,
    });

class $$NodesTableFilterComposer extends Composer<_$AppDatabase, $NodesTable> {
  $$NodesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get num => $composableBuilder(
    column: $table.num,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get longName => $composableBuilder(
    column: $table.longName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hwModel => $composableBuilder(
    column: $table.hwModel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnmessagable => $composableBuilder(
    column: $table.isUnmessagable,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastHeard => $composableBuilder(
    column: $table.lastHeard,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get snr => $composableBuilder(
    column: $table.snr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hopsAway => $composableBuilder(
    column: $table.hopsAway,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get viaMqtt => $composableBuilder(
    column: $table.viaMqtt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get voltage => $composableBuilder(
    column: $table.voltage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get channelUtilization => $composableBuilder(
    column: $table.channelUtilization,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get airUtilTx => $composableBuilder(
    column: $table.airUtilTx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get uptimeSeconds => $composableBuilder(
    column: $table.uptimeSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onRadio => $composableBuilder(
    column: $table.onRadio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onMirror => $composableBuilder(
    column: $table.onMirror,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NodesTableOrderingComposer
    extends Composer<_$AppDatabase, $NodesTable> {
  $$NodesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get num => $composableBuilder(
    column: $table.num,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get userId => $composableBuilder(
    column: $table.userId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get longName => $composableBuilder(
    column: $table.longName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shortName => $composableBuilder(
    column: $table.shortName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hwModel => $composableBuilder(
    column: $table.hwModel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get publicKey => $composableBuilder(
    column: $table.publicKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnmessagable => $composableBuilder(
    column: $table.isUnmessagable,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastHeard => $composableBuilder(
    column: $table.lastHeard,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get snr => $composableBuilder(
    column: $table.snr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hopsAway => $composableBuilder(
    column: $table.hopsAway,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get viaMqtt => $composableBuilder(
    column: $table.viaMqtt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIgnored => $composableBuilder(
    column: $table.isIgnored,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get voltage => $composableBuilder(
    column: $table.voltage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get channelUtilization => $composableBuilder(
    column: $table.channelUtilization,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get airUtilTx => $composableBuilder(
    column: $table.airUtilTx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get uptimeSeconds => $composableBuilder(
    column: $table.uptimeSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onRadio => $composableBuilder(
    column: $table.onRadio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onMirror => $composableBuilder(
    column: $table.onMirror,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NodesTableAnnotationComposer
    extends Composer<_$AppDatabase, $NodesTable> {
  $$NodesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get num =>
      $composableBuilder(column: $table.num, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get longName =>
      $composableBuilder(column: $table.longName, builder: (column) => column);

  GeneratedColumn<String> get shortName =>
      $composableBuilder(column: $table.shortName, builder: (column) => column);

  GeneratedColumn<int> get hwModel =>
      $composableBuilder(column: $table.hwModel, builder: (column) => column);

  GeneratedColumn<int> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<Uint8List> get publicKey =>
      $composableBuilder(column: $table.publicKey, builder: (column) => column);

  GeneratedColumn<bool> get isUnmessagable => $composableBuilder(
    column: $table.isUnmessagable,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastHeard =>
      $composableBuilder(column: $table.lastHeard, builder: (column) => column);

  GeneratedColumn<double> get snr =>
      $composableBuilder(column: $table.snr, builder: (column) => column);

  GeneratedColumn<int> get hopsAway =>
      $composableBuilder(column: $table.hopsAway, builder: (column) => column);

  GeneratedColumn<bool> get viaMqtt =>
      $composableBuilder(column: $table.viaMqtt, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIgnored =>
      $composableBuilder(column: $table.isIgnored, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);

  GeneratedColumn<int> get batteryLevel => $composableBuilder(
    column: $table.batteryLevel,
    builder: (column) => column,
  );

  GeneratedColumn<double> get voltage =>
      $composableBuilder(column: $table.voltage, builder: (column) => column);

  GeneratedColumn<double> get channelUtilization => $composableBuilder(
    column: $table.channelUtilization,
    builder: (column) => column,
  );

  GeneratedColumn<double> get airUtilTx =>
      $composableBuilder(column: $table.airUtilTx, builder: (column) => column);

  GeneratedColumn<int> get uptimeSeconds => $composableBuilder(
    column: $table.uptimeSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onRadio =>
      $composableBuilder(column: $table.onRadio, builder: (column) => column);

  GeneratedColumn<bool> get onMirror =>
      $composableBuilder(column: $table.onMirror, builder: (column) => column);
}

class $$NodesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NodesTable,
          Node,
          $$NodesTableFilterComposer,
          $$NodesTableOrderingComposer,
          $$NodesTableAnnotationComposer,
          $$NodesTableCreateCompanionBuilder,
          $$NodesTableUpdateCompanionBuilder,
          (Node, BaseReferences<_$AppDatabase, $NodesTable, Node>),
          Node,
          PrefetchHooks Function()
        > {
  $$NodesTableTableManager(_$AppDatabase db, $NodesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NodesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NodesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NodesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> num = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> longName = const Value.absent(),
                Value<String> shortName = const Value.absent(),
                Value<int> hwModel = const Value.absent(),
                Value<int> role = const Value.absent(),
                Value<Uint8List?> publicKey = const Value.absent(),
                Value<bool> isUnmessagable = const Value.absent(),
                Value<DateTime?> lastHeard = const Value.absent(),
                Value<double?> snr = const Value.absent(),
                Value<int?> hopsAway = const Value.absent(),
                Value<bool> viaMqtt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int?> altitude = const Value.absent(),
                Value<int?> batteryLevel = const Value.absent(),
                Value<double?> voltage = const Value.absent(),
                Value<double?> channelUtilization = const Value.absent(),
                Value<double?> airUtilTx = const Value.absent(),
                Value<int?> uptimeSeconds = const Value.absent(),
                Value<bool> onRadio = const Value.absent(),
                Value<bool> onMirror = const Value.absent(),
              }) => NodesCompanion(
                num: num,
                userId: userId,
                longName: longName,
                shortName: shortName,
                hwModel: hwModel,
                role: role,
                publicKey: publicKey,
                isUnmessagable: isUnmessagable,
                lastHeard: lastHeard,
                snr: snr,
                hopsAway: hopsAway,
                viaMqtt: viaMqtt,
                isFavorite: isFavorite,
                isIgnored: isIgnored,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                batteryLevel: batteryLevel,
                voltage: voltage,
                channelUtilization: channelUtilization,
                airUtilTx: airUtilTx,
                uptimeSeconds: uptimeSeconds,
                onRadio: onRadio,
                onMirror: onMirror,
              ),
          createCompanionCallback:
              ({
                Value<int> num = const Value.absent(),
                Value<String> userId = const Value.absent(),
                Value<String> longName = const Value.absent(),
                Value<String> shortName = const Value.absent(),
                Value<int> hwModel = const Value.absent(),
                Value<int> role = const Value.absent(),
                Value<Uint8List?> publicKey = const Value.absent(),
                Value<bool> isUnmessagable = const Value.absent(),
                Value<DateTime?> lastHeard = const Value.absent(),
                Value<double?> snr = const Value.absent(),
                Value<int?> hopsAway = const Value.absent(),
                Value<bool> viaMqtt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isIgnored = const Value.absent(),
                Value<double?> latitude = const Value.absent(),
                Value<double?> longitude = const Value.absent(),
                Value<int?> altitude = const Value.absent(),
                Value<int?> batteryLevel = const Value.absent(),
                Value<double?> voltage = const Value.absent(),
                Value<double?> channelUtilization = const Value.absent(),
                Value<double?> airUtilTx = const Value.absent(),
                Value<int?> uptimeSeconds = const Value.absent(),
                Value<bool> onRadio = const Value.absent(),
                Value<bool> onMirror = const Value.absent(),
              }) => NodesCompanion.insert(
                num: num,
                userId: userId,
                longName: longName,
                shortName: shortName,
                hwModel: hwModel,
                role: role,
                publicKey: publicKey,
                isUnmessagable: isUnmessagable,
                lastHeard: lastHeard,
                snr: snr,
                hopsAway: hopsAway,
                viaMqtt: viaMqtt,
                isFavorite: isFavorite,
                isIgnored: isIgnored,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
                batteryLevel: batteryLevel,
                voltage: voltage,
                channelUtilization: channelUtilization,
                airUtilTx: airUtilTx,
                uptimeSeconds: uptimeSeconds,
                onRadio: onRadio,
                onMirror: onMirror,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NodesTable, Node>(table),
                  BaseReferences<_$AppDatabase, $NodesTable, Node>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NodesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NodesTable,
      Node,
      $$NodesTableFilterComposer,
      $$NodesTableOrderingComposer,
      $$NodesTableAnnotationComposer,
      $$NodesTableCreateCompanionBuilder,
      $$NodesTableUpdateCompanionBuilder,
      (Node, BaseReferences<_$AppDatabase, $NodesTable, Node>),
      Node,
      PrefetchHooks Function()
    >;
typedef $$MessagesTableCreateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      required int packetId,
      required int fromNum,
      required int toNum,
      Value<int?> channel,
      Value<String> channelKey,
      required String body,
      required DateTime rxTime,
      Value<bool> isOutgoing,
      Value<int?> replyId,
      Value<int> emoji,
      Value<double?> rxSnr,
      Value<int?> rxRssi,
      Value<int?> hopStart,
      Value<int?> hopLimit,
      Value<bool> viaMqtt,
      Value<bool> pkiEncrypted,
      Value<AckState> ackState,
      Value<int?> ackError,
      Value<bool> heardOnRadio,
      Value<bool> heardOnMirror,
      Value<int?> mirrorId,
      Value<int> relayCount,
      Value<bool> isBot,
    });
typedef $$MessagesTableUpdateCompanionBuilder =
    MessagesCompanion Function({
      Value<int> id,
      Value<int> packetId,
      Value<int> fromNum,
      Value<int> toNum,
      Value<int?> channel,
      Value<String> channelKey,
      Value<String> body,
      Value<DateTime> rxTime,
      Value<bool> isOutgoing,
      Value<int?> replyId,
      Value<int> emoji,
      Value<double?> rxSnr,
      Value<int?> rxRssi,
      Value<int?> hopStart,
      Value<int?> hopLimit,
      Value<bool> viaMqtt,
      Value<bool> pkiEncrypted,
      Value<AckState> ackState,
      Value<int?> ackError,
      Value<bool> heardOnRadio,
      Value<bool> heardOnMirror,
      Value<int?> mirrorId,
      Value<int> relayCount,
      Value<bool> isBot,
    });

class $$MessagesTableFilterComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get packetId => $composableBuilder(
    column: $table.packetId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get fromNum => $composableBuilder(
    column: $table.fromNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get toNum => $composableBuilder(
    column: $table.toNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get channelKey => $composableBuilder(
    column: $table.channelKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get rxTime => $composableBuilder(
    column: $table.rxTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get replyId => $composableBuilder(
    column: $table.replyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rxSnr => $composableBuilder(
    column: $table.rxSnr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rxRssi => $composableBuilder(
    column: $table.rxRssi,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hopStart => $composableBuilder(
    column: $table.hopStart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hopLimit => $composableBuilder(
    column: $table.hopLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get viaMqtt => $composableBuilder(
    column: $table.viaMqtt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pkiEncrypted => $composableBuilder(
    column: $table.pkiEncrypted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<AckState, AckState, int> get ackState =>
      $composableBuilder(
        column: $table.ackState,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get ackError => $composableBuilder(
    column: $table.ackError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get heardOnRadio => $composableBuilder(
    column: $table.heardOnRadio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get heardOnMirror => $composableBuilder(
    column: $table.heardOnMirror,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mirrorId => $composableBuilder(
    column: $table.mirrorId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get relayCount => $composableBuilder(
    column: $table.relayCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBot => $composableBuilder(
    column: $table.isBot,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MessagesTableOrderingComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get packetId => $composableBuilder(
    column: $table.packetId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get fromNum => $composableBuilder(
    column: $table.fromNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get toNum => $composableBuilder(
    column: $table.toNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get channel => $composableBuilder(
    column: $table.channel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get channelKey => $composableBuilder(
    column: $table.channelKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get rxTime => $composableBuilder(
    column: $table.rxTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get replyId => $composableBuilder(
    column: $table.replyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get emoji => $composableBuilder(
    column: $table.emoji,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rxSnr => $composableBuilder(
    column: $table.rxSnr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rxRssi => $composableBuilder(
    column: $table.rxRssi,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hopStart => $composableBuilder(
    column: $table.hopStart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hopLimit => $composableBuilder(
    column: $table.hopLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get viaMqtt => $composableBuilder(
    column: $table.viaMqtt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pkiEncrypted => $composableBuilder(
    column: $table.pkiEncrypted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ackState => $composableBuilder(
    column: $table.ackState,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ackError => $composableBuilder(
    column: $table.ackError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get heardOnRadio => $composableBuilder(
    column: $table.heardOnRadio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get heardOnMirror => $composableBuilder(
    column: $table.heardOnMirror,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mirrorId => $composableBuilder(
    column: $table.mirrorId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get relayCount => $composableBuilder(
    column: $table.relayCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBot => $composableBuilder(
    column: $table.isBot,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MessagesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MessagesTable> {
  $$MessagesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get packetId =>
      $composableBuilder(column: $table.packetId, builder: (column) => column);

  GeneratedColumn<int> get fromNum =>
      $composableBuilder(column: $table.fromNum, builder: (column) => column);

  GeneratedColumn<int> get toNum =>
      $composableBuilder(column: $table.toNum, builder: (column) => column);

  GeneratedColumn<int> get channel =>
      $composableBuilder(column: $table.channel, builder: (column) => column);

  GeneratedColumn<String> get channelKey => $composableBuilder(
    column: $table.channelKey,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get rxTime =>
      $composableBuilder(column: $table.rxTime, builder: (column) => column);

  GeneratedColumn<bool> get isOutgoing => $composableBuilder(
    column: $table.isOutgoing,
    builder: (column) => column,
  );

  GeneratedColumn<int> get replyId =>
      $composableBuilder(column: $table.replyId, builder: (column) => column);

  GeneratedColumn<int> get emoji =>
      $composableBuilder(column: $table.emoji, builder: (column) => column);

  GeneratedColumn<double> get rxSnr =>
      $composableBuilder(column: $table.rxSnr, builder: (column) => column);

  GeneratedColumn<int> get rxRssi =>
      $composableBuilder(column: $table.rxRssi, builder: (column) => column);

  GeneratedColumn<int> get hopStart =>
      $composableBuilder(column: $table.hopStart, builder: (column) => column);

  GeneratedColumn<int> get hopLimit =>
      $composableBuilder(column: $table.hopLimit, builder: (column) => column);

  GeneratedColumn<bool> get viaMqtt =>
      $composableBuilder(column: $table.viaMqtt, builder: (column) => column);

  GeneratedColumn<bool> get pkiEncrypted => $composableBuilder(
    column: $table.pkiEncrypted,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<AckState, int> get ackState =>
      $composableBuilder(column: $table.ackState, builder: (column) => column);

  GeneratedColumn<int> get ackError =>
      $composableBuilder(column: $table.ackError, builder: (column) => column);

  GeneratedColumn<bool> get heardOnRadio => $composableBuilder(
    column: $table.heardOnRadio,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get heardOnMirror => $composableBuilder(
    column: $table.heardOnMirror,
    builder: (column) => column,
  );

  GeneratedColumn<int> get mirrorId =>
      $composableBuilder(column: $table.mirrorId, builder: (column) => column);

  GeneratedColumn<int> get relayCount => $composableBuilder(
    column: $table.relayCount,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBot =>
      $composableBuilder(column: $table.isBot, builder: (column) => column);
}

class $$MessagesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MessagesTable,
          Message,
          $$MessagesTableFilterComposer,
          $$MessagesTableOrderingComposer,
          $$MessagesTableAnnotationComposer,
          $$MessagesTableCreateCompanionBuilder,
          $$MessagesTableUpdateCompanionBuilder,
          (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
          Message,
          PrefetchHooks Function()
        > {
  $$MessagesTableTableManager(_$AppDatabase db, $MessagesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MessagesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MessagesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MessagesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> packetId = const Value.absent(),
                Value<int> fromNum = const Value.absent(),
                Value<int> toNum = const Value.absent(),
                Value<int?> channel = const Value.absent(),
                Value<String> channelKey = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> rxTime = const Value.absent(),
                Value<bool> isOutgoing = const Value.absent(),
                Value<int?> replyId = const Value.absent(),
                Value<int> emoji = const Value.absent(),
                Value<double?> rxSnr = const Value.absent(),
                Value<int?> rxRssi = const Value.absent(),
                Value<int?> hopStart = const Value.absent(),
                Value<int?> hopLimit = const Value.absent(),
                Value<bool> viaMqtt = const Value.absent(),
                Value<bool> pkiEncrypted = const Value.absent(),
                Value<AckState> ackState = const Value.absent(),
                Value<int?> ackError = const Value.absent(),
                Value<bool> heardOnRadio = const Value.absent(),
                Value<bool> heardOnMirror = const Value.absent(),
                Value<int?> mirrorId = const Value.absent(),
                Value<int> relayCount = const Value.absent(),
                Value<bool> isBot = const Value.absent(),
              }) => MessagesCompanion(
                id: id,
                packetId: packetId,
                fromNum: fromNum,
                toNum: toNum,
                channel: channel,
                channelKey: channelKey,
                body: body,
                rxTime: rxTime,
                isOutgoing: isOutgoing,
                replyId: replyId,
                emoji: emoji,
                rxSnr: rxSnr,
                rxRssi: rxRssi,
                hopStart: hopStart,
                hopLimit: hopLimit,
                viaMqtt: viaMqtt,
                pkiEncrypted: pkiEncrypted,
                ackState: ackState,
                ackError: ackError,
                heardOnRadio: heardOnRadio,
                heardOnMirror: heardOnMirror,
                mirrorId: mirrorId,
                relayCount: relayCount,
                isBot: isBot,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int packetId,
                required int fromNum,
                required int toNum,
                Value<int?> channel = const Value.absent(),
                Value<String> channelKey = const Value.absent(),
                required String body,
                required DateTime rxTime,
                Value<bool> isOutgoing = const Value.absent(),
                Value<int?> replyId = const Value.absent(),
                Value<int> emoji = const Value.absent(),
                Value<double?> rxSnr = const Value.absent(),
                Value<int?> rxRssi = const Value.absent(),
                Value<int?> hopStart = const Value.absent(),
                Value<int?> hopLimit = const Value.absent(),
                Value<bool> viaMqtt = const Value.absent(),
                Value<bool> pkiEncrypted = const Value.absent(),
                Value<AckState> ackState = const Value.absent(),
                Value<int?> ackError = const Value.absent(),
                Value<bool> heardOnRadio = const Value.absent(),
                Value<bool> heardOnMirror = const Value.absent(),
                Value<int?> mirrorId = const Value.absent(),
                Value<int> relayCount = const Value.absent(),
                Value<bool> isBot = const Value.absent(),
              }) => MessagesCompanion.insert(
                id: id,
                packetId: packetId,
                fromNum: fromNum,
                toNum: toNum,
                channel: channel,
                channelKey: channelKey,
                body: body,
                rxTime: rxTime,
                isOutgoing: isOutgoing,
                replyId: replyId,
                emoji: emoji,
                rxSnr: rxSnr,
                rxRssi: rxRssi,
                hopStart: hopStart,
                hopLimit: hopLimit,
                viaMqtt: viaMqtt,
                pkiEncrypted: pkiEncrypted,
                ackState: ackState,
                ackError: ackError,
                heardOnRadio: heardOnRadio,
                heardOnMirror: heardOnMirror,
                mirrorId: mirrorId,
                relayCount: relayCount,
                isBot: isBot,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MessagesTable, Message>(table),
                  BaseReferences<_$AppDatabase, $MessagesTable, Message>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MessagesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MessagesTable,
      Message,
      $$MessagesTableFilterComposer,
      $$MessagesTableOrderingComposer,
      $$MessagesTableAnnotationComposer,
      $$MessagesTableCreateCompanionBuilder,
      $$MessagesTableUpdateCompanionBuilder,
      (Message, BaseReferences<_$AppDatabase, $MessagesTable, Message>),
      Message,
      PrefetchHooks Function()
    >;
typedef $$ChannelsTableCreateCompanionBuilder =
    ChannelsCompanion Function({
      Value<int> index,
      Value<String> name,
      Value<int> role,
      Value<Uint8List?> psk,
    });
typedef $$ChannelsTableUpdateCompanionBuilder =
    ChannelsCompanion Function({
      Value<int> index,
      Value<String> name,
      Value<int> role,
      Value<Uint8List?> psk,
    });

class $$ChannelsTableFilterComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get index => $composableBuilder(
    column: $table.index,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get psk => $composableBuilder(
    column: $table.psk,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChannelsTableOrderingComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get index => $composableBuilder(
    column: $table.index,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get psk => $composableBuilder(
    column: $table.psk,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChannelsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ChannelsTable> {
  $$ChannelsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get index =>
      $composableBuilder(column: $table.index, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<Uint8List> get psk =>
      $composableBuilder(column: $table.psk, builder: (column) => column);
}

class $$ChannelsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ChannelsTable,
          MeshChannel,
          $$ChannelsTableFilterComposer,
          $$ChannelsTableOrderingComposer,
          $$ChannelsTableAnnotationComposer,
          $$ChannelsTableCreateCompanionBuilder,
          $$ChannelsTableUpdateCompanionBuilder,
          (
            MeshChannel,
            BaseReferences<_$AppDatabase, $ChannelsTable, MeshChannel>,
          ),
          MeshChannel,
          PrefetchHooks Function()
        > {
  $$ChannelsTableTableManager(_$AppDatabase db, $ChannelsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChannelsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChannelsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChannelsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> index = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> role = const Value.absent(),
                Value<Uint8List?> psk = const Value.absent(),
              }) => ChannelsCompanion(
                index: index,
                name: name,
                role: role,
                psk: psk,
              ),
          createCompanionCallback:
              ({
                Value<int> index = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> role = const Value.absent(),
                Value<Uint8List?> psk = const Value.absent(),
              }) => ChannelsCompanion.insert(
                index: index,
                name: name,
                role: role,
                psk: psk,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ChannelsTable, MeshChannel>(table),
                  BaseReferences<_$AppDatabase, $ChannelsTable, MeshChannel>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChannelsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ChannelsTable,
      MeshChannel,
      $$ChannelsTableFilterComposer,
      $$ChannelsTableOrderingComposer,
      $$ChannelsTableAnnotationComposer,
      $$ChannelsTableCreateCompanionBuilder,
      $$ChannelsTableUpdateCompanionBuilder,
      (MeshChannel, BaseReferences<_$AppDatabase, $ChannelsTable, MeshChannel>),
      MeshChannel,
      PrefetchHooks Function()
    >;
typedef $$PositionsTableCreateCompanionBuilder =
    PositionsCompanion Function({
      Value<int> id,
      required int nodeNum,
      required DateTime time,
      required double latitude,
      required double longitude,
      Value<int?> altitude,
    });
typedef $$PositionsTableUpdateCompanionBuilder =
    PositionsCompanion Function({
      Value<int> id,
      Value<int> nodeNum,
      Value<DateTime> time,
      Value<double> latitude,
      Value<double> longitude,
      Value<int?> altitude,
    });

class $$PositionsTableFilterComposer
    extends Composer<_$AppDatabase, $PositionsTable> {
  $$PositionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nodeNum => $composableBuilder(
    column: $table.nodeNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PositionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PositionsTable> {
  $$PositionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nodeNum => $composableBuilder(
    column: $table.nodeNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get latitude => $composableBuilder(
    column: $table.latitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get longitude => $composableBuilder(
    column: $table.longitude,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get altitude => $composableBuilder(
    column: $table.altitude,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PositionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PositionsTable> {
  $$PositionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get nodeNum =>
      $composableBuilder(column: $table.nodeNum, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<double> get latitude =>
      $composableBuilder(column: $table.latitude, builder: (column) => column);

  GeneratedColumn<double> get longitude =>
      $composableBuilder(column: $table.longitude, builder: (column) => column);

  GeneratedColumn<int> get altitude =>
      $composableBuilder(column: $table.altitude, builder: (column) => column);
}

class $$PositionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PositionsTable,
          PositionRecord,
          $$PositionsTableFilterComposer,
          $$PositionsTableOrderingComposer,
          $$PositionsTableAnnotationComposer,
          $$PositionsTableCreateCompanionBuilder,
          $$PositionsTableUpdateCompanionBuilder,
          (
            PositionRecord,
            BaseReferences<_$AppDatabase, $PositionsTable, PositionRecord>,
          ),
          PositionRecord,
          PrefetchHooks Function()
        > {
  $$PositionsTableTableManager(_$AppDatabase db, $PositionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PositionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PositionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PositionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> nodeNum = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<double> latitude = const Value.absent(),
                Value<double> longitude = const Value.absent(),
                Value<int?> altitude = const Value.absent(),
              }) => PositionsCompanion(
                id: id,
                nodeNum: nodeNum,
                time: time,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int nodeNum,
                required DateTime time,
                required double latitude,
                required double longitude,
                Value<int?> altitude = const Value.absent(),
              }) => PositionsCompanion.insert(
                id: id,
                nodeNum: nodeNum,
                time: time,
                latitude: latitude,
                longitude: longitude,
                altitude: altitude,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PositionsTable, PositionRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PositionsTable,
                    PositionRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PositionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PositionsTable,
      PositionRecord,
      $$PositionsTableFilterComposer,
      $$PositionsTableOrderingComposer,
      $$PositionsTableAnnotationComposer,
      $$PositionsTableCreateCompanionBuilder,
      $$PositionsTableUpdateCompanionBuilder,
      (
        PositionRecord,
        BaseReferences<_$AppDatabase, $PositionsTable, PositionRecord>,
      ),
      PositionRecord,
      PrefetchHooks Function()
    >;
typedef $$TelemetryLogTableCreateCompanionBuilder =
    TelemetryLogCompanion Function({
      Value<int> id,
      required int nodeNum,
      required DateTime time,
      required String kind,
      required Uint8List data,
    });
typedef $$TelemetryLogTableUpdateCompanionBuilder =
    TelemetryLogCompanion Function({
      Value<int> id,
      Value<int> nodeNum,
      Value<DateTime> time,
      Value<String> kind,
      Value<Uint8List> data,
    });

class $$TelemetryLogTableFilterComposer
    extends Composer<_$AppDatabase, $TelemetryLogTable> {
  $$TelemetryLogTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nodeNum => $composableBuilder(
    column: $table.nodeNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TelemetryLogTableOrderingComposer
    extends Composer<_$AppDatabase, $TelemetryLogTable> {
  $$TelemetryLogTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nodeNum => $composableBuilder(
    column: $table.nodeNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TelemetryLogTableAnnotationComposer
    extends Composer<_$AppDatabase, $TelemetryLogTable> {
  $$TelemetryLogTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get nodeNum =>
      $composableBuilder(column: $table.nodeNum, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$TelemetryLogTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TelemetryLogTable,
          TelemetryLogData,
          $$TelemetryLogTableFilterComposer,
          $$TelemetryLogTableOrderingComposer,
          $$TelemetryLogTableAnnotationComposer,
          $$TelemetryLogTableCreateCompanionBuilder,
          $$TelemetryLogTableUpdateCompanionBuilder,
          (
            TelemetryLogData,
            BaseReferences<_$AppDatabase, $TelemetryLogTable, TelemetryLogData>,
          ),
          TelemetryLogData,
          PrefetchHooks Function()
        > {
  $$TelemetryLogTableTableManager(_$AppDatabase db, $TelemetryLogTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TelemetryLogTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TelemetryLogTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TelemetryLogTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> nodeNum = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<Uint8List> data = const Value.absent(),
              }) => TelemetryLogCompanion(
                id: id,
                nodeNum: nodeNum,
                time: time,
                kind: kind,
                data: data,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int nodeNum,
                required DateTime time,
                required String kind,
                required Uint8List data,
              }) => TelemetryLogCompanion.insert(
                id: id,
                nodeNum: nodeNum,
                time: time,
                kind: kind,
                data: data,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TelemetryLogTable, TelemetryLogData>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TelemetryLogTable,
                    TelemetryLogData
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TelemetryLogTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TelemetryLogTable,
      TelemetryLogData,
      $$TelemetryLogTableFilterComposer,
      $$TelemetryLogTableOrderingComposer,
      $$TelemetryLogTableAnnotationComposer,
      $$TelemetryLogTableCreateCompanionBuilder,
      $$TelemetryLogTableUpdateCompanionBuilder,
      (
        TelemetryLogData,
        BaseReferences<_$AppDatabase, $TelemetryLogTable, TelemetryLogData>,
      ),
      TelemetryLogData,
      PrefetchHooks Function()
    >;
typedef $$TraceroutesTableCreateCompanionBuilder =
    TraceroutesCompanion Function({
      Value<int> id,
      required int requestId,
      required int targetNum,
      required DateTime time,
      required Uint8List data,
    });
typedef $$TraceroutesTableUpdateCompanionBuilder =
    TraceroutesCompanion Function({
      Value<int> id,
      Value<int> requestId,
      Value<int> targetNum,
      Value<DateTime> time,
      Value<Uint8List> data,
    });

class $$TraceroutesTableFilterComposer
    extends Composer<_$AppDatabase, $TraceroutesTable> {
  $$TraceroutesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetNum => $composableBuilder(
    column: $table.targetNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TraceroutesTableOrderingComposer
    extends Composer<_$AppDatabase, $TraceroutesTable> {
  $$TraceroutesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get requestId => $composableBuilder(
    column: $table.requestId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetNum => $composableBuilder(
    column: $table.targetNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TraceroutesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TraceroutesTable> {
  $$TraceroutesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get requestId =>
      $composableBuilder(column: $table.requestId, builder: (column) => column);

  GeneratedColumn<int> get targetNum =>
      $composableBuilder(column: $table.targetNum, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);

  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);
}

class $$TraceroutesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TraceroutesTable,
          TracerouteRecord,
          $$TraceroutesTableFilterComposer,
          $$TraceroutesTableOrderingComposer,
          $$TraceroutesTableAnnotationComposer,
          $$TraceroutesTableCreateCompanionBuilder,
          $$TraceroutesTableUpdateCompanionBuilder,
          (
            TracerouteRecord,
            BaseReferences<_$AppDatabase, $TraceroutesTable, TracerouteRecord>,
          ),
          TracerouteRecord,
          PrefetchHooks Function()
        > {
  $$TraceroutesTableTableManager(_$AppDatabase db, $TraceroutesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TraceroutesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TraceroutesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TraceroutesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> requestId = const Value.absent(),
                Value<int> targetNum = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<Uint8List> data = const Value.absent(),
              }) => TraceroutesCompanion(
                id: id,
                requestId: requestId,
                targetNum: targetNum,
                time: time,
                data: data,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int requestId,
                required int targetNum,
                required DateTime time,
                required Uint8List data,
              }) => TraceroutesCompanion.insert(
                id: id,
                requestId: requestId,
                targetNum: targetNum,
                time: time,
                data: data,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TraceroutesTable, TracerouteRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $TraceroutesTable,
                    TracerouteRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TraceroutesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TraceroutesTable,
      TracerouteRecord,
      $$TraceroutesTableFilterComposer,
      $$TraceroutesTableOrderingComposer,
      $$TraceroutesTableAnnotationComposer,
      $$TraceroutesTableCreateCompanionBuilder,
      $$TraceroutesTableUpdateCompanionBuilder,
      (
        TracerouteRecord,
        BaseReferences<_$AppDatabase, $TraceroutesTable, TracerouteRecord>,
      ),
      TracerouteRecord,
      PrefetchHooks Function()
    >;
typedef $$NeighborsTableCreateCompanionBuilder =
    NeighborsCompanion Function({
      required int nodeNum,
      required int neighborNum,
      required double snr,
      required DateTime time,
      Value<int> rowid,
    });
typedef $$NeighborsTableUpdateCompanionBuilder =
    NeighborsCompanion Function({
      Value<int> nodeNum,
      Value<int> neighborNum,
      Value<double> snr,
      Value<DateTime> time,
      Value<int> rowid,
    });

class $$NeighborsTableFilterComposer
    extends Composer<_$AppDatabase, $NeighborsTable> {
  $$NeighborsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get nodeNum => $composableBuilder(
    column: $table.nodeNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get neighborNum => $composableBuilder(
    column: $table.neighborNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get snr => $composableBuilder(
    column: $table.snr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnFilters(column),
  );
}

class $$NeighborsTableOrderingComposer
    extends Composer<_$AppDatabase, $NeighborsTable> {
  $$NeighborsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get nodeNum => $composableBuilder(
    column: $table.nodeNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get neighborNum => $composableBuilder(
    column: $table.neighborNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get snr => $composableBuilder(
    column: $table.snr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get time => $composableBuilder(
    column: $table.time,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$NeighborsTableAnnotationComposer
    extends Composer<_$AppDatabase, $NeighborsTable> {
  $$NeighborsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get nodeNum =>
      $composableBuilder(column: $table.nodeNum, builder: (column) => column);

  GeneratedColumn<int> get neighborNum => $composableBuilder(
    column: $table.neighborNum,
    builder: (column) => column,
  );

  GeneratedColumn<double> get snr =>
      $composableBuilder(column: $table.snr, builder: (column) => column);

  GeneratedColumn<DateTime> get time =>
      $composableBuilder(column: $table.time, builder: (column) => column);
}

class $$NeighborsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $NeighborsTable,
          NeighborRecord,
          $$NeighborsTableFilterComposer,
          $$NeighborsTableOrderingComposer,
          $$NeighborsTableAnnotationComposer,
          $$NeighborsTableCreateCompanionBuilder,
          $$NeighborsTableUpdateCompanionBuilder,
          (
            NeighborRecord,
            BaseReferences<_$AppDatabase, $NeighborsTable, NeighborRecord>,
          ),
          NeighborRecord,
          PrefetchHooks Function()
        > {
  $$NeighborsTableTableManager(_$AppDatabase db, $NeighborsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$NeighborsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$NeighborsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$NeighborsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> nodeNum = const Value.absent(),
                Value<int> neighborNum = const Value.absent(),
                Value<double> snr = const Value.absent(),
                Value<DateTime> time = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => NeighborsCompanion(
                nodeNum: nodeNum,
                neighborNum: neighborNum,
                snr: snr,
                time: time,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int nodeNum,
                required int neighborNum,
                required double snr,
                required DateTime time,
                Value<int> rowid = const Value.absent(),
              }) => NeighborsCompanion.insert(
                nodeNum: nodeNum,
                neighborNum: neighborNum,
                snr: snr,
                time: time,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$NeighborsTable, NeighborRecord>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $NeighborsTable,
                    NeighborRecord
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$NeighborsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $NeighborsTable,
      NeighborRecord,
      $$NeighborsTableFilterComposer,
      $$NeighborsTableOrderingComposer,
      $$NeighborsTableAnnotationComposer,
      $$NeighborsTableCreateCompanionBuilder,
      $$NeighborsTableUpdateCompanionBuilder,
      (
        NeighborRecord,
        BaseReferences<_$AppDatabase, $NeighborsTable, NeighborRecord>,
      ),
      NeighborRecord,
      PrefetchHooks Function()
    >;
typedef $$MyNodeTableCreateCompanionBuilder =
    MyNodeCompanion Function({
      Value<int> id,
      required int myNodeNum,
      Value<int> rebootCount,
      Value<String> firmwareVersion,
      Value<Uint8List?> metadata,
    });
typedef $$MyNodeTableUpdateCompanionBuilder =
    MyNodeCompanion Function({
      Value<int> id,
      Value<int> myNodeNum,
      Value<int> rebootCount,
      Value<String> firmwareVersion,
      Value<Uint8List?> metadata,
    });

class $$MyNodeTableFilterComposer
    extends Composer<_$AppDatabase, $MyNodeTable> {
  $$MyNodeTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get myNodeNum => $composableBuilder(
    column: $table.myNodeNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rebootCount => $composableBuilder(
    column: $table.rebootCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MyNodeTableOrderingComposer
    extends Composer<_$AppDatabase, $MyNodeTable> {
  $$MyNodeTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get myNodeNum => $composableBuilder(
    column: $table.myNodeNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rebootCount => $composableBuilder(
    column: $table.rebootCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get metadata => $composableBuilder(
    column: $table.metadata,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MyNodeTableAnnotationComposer
    extends Composer<_$AppDatabase, $MyNodeTable> {
  $$MyNodeTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get myNodeNum =>
      $composableBuilder(column: $table.myNodeNum, builder: (column) => column);

  GeneratedColumn<int> get rebootCount => $composableBuilder(
    column: $table.rebootCount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get firmwareVersion => $composableBuilder(
    column: $table.firmwareVersion,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get metadata =>
      $composableBuilder(column: $table.metadata, builder: (column) => column);
}

class $$MyNodeTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MyNodeTable,
          MyNodeRecord,
          $$MyNodeTableFilterComposer,
          $$MyNodeTableOrderingComposer,
          $$MyNodeTableAnnotationComposer,
          $$MyNodeTableCreateCompanionBuilder,
          $$MyNodeTableUpdateCompanionBuilder,
          (
            MyNodeRecord,
            BaseReferences<_$AppDatabase, $MyNodeTable, MyNodeRecord>,
          ),
          MyNodeRecord,
          PrefetchHooks Function()
        > {
  $$MyNodeTableTableManager(_$AppDatabase db, $MyNodeTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MyNodeTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MyNodeTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MyNodeTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> myNodeNum = const Value.absent(),
                Value<int> rebootCount = const Value.absent(),
                Value<String> firmwareVersion = const Value.absent(),
                Value<Uint8List?> metadata = const Value.absent(),
              }) => MyNodeCompanion(
                id: id,
                myNodeNum: myNodeNum,
                rebootCount: rebootCount,
                firmwareVersion: firmwareVersion,
                metadata: metadata,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int myNodeNum,
                Value<int> rebootCount = const Value.absent(),
                Value<String> firmwareVersion = const Value.absent(),
                Value<Uint8List?> metadata = const Value.absent(),
              }) => MyNodeCompanion.insert(
                id: id,
                myNodeNum: myNodeNum,
                rebootCount: rebootCount,
                firmwareVersion: firmwareVersion,
                metadata: metadata,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MyNodeTable, MyNodeRecord>(table),
                  BaseReferences<_$AppDatabase, $MyNodeTable, MyNodeRecord>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MyNodeTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MyNodeTable,
      MyNodeRecord,
      $$MyNodeTableFilterComposer,
      $$MyNodeTableOrderingComposer,
      $$MyNodeTableAnnotationComposer,
      $$MyNodeTableCreateCompanionBuilder,
      $$MyNodeTableUpdateCompanionBuilder,
      (MyNodeRecord, BaseReferences<_$AppDatabase, $MyNodeTable, MyNodeRecord>),
      MyNodeRecord,
      PrefetchHooks Function()
    >;
typedef $$ConfigBlobsTableCreateCompanionBuilder =
    ConfigBlobsCompanion Function({
      required String key,
      required Uint8List data,
      required DateTime updated,
      Value<int> rowid,
    });
typedef $$ConfigBlobsTableUpdateCompanionBuilder =
    ConfigBlobsCompanion Function({
      Value<String> key,
      Value<Uint8List> data,
      Value<DateTime> updated,
      Value<int> rowid,
    });

class $$ConfigBlobsTableFilterComposer
    extends Composer<_$AppDatabase, $ConfigBlobsTable> {
  $$ConfigBlobsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ConfigBlobsTableOrderingComposer
    extends Composer<_$AppDatabase, $ConfigBlobsTable> {
  $$ConfigBlobsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get data => $composableBuilder(
    column: $table.data,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updated => $composableBuilder(
    column: $table.updated,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ConfigBlobsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ConfigBlobsTable> {
  $$ConfigBlobsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<Uint8List> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<DateTime> get updated =>
      $composableBuilder(column: $table.updated, builder: (column) => column);
}

class $$ConfigBlobsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ConfigBlobsTable,
          ConfigBlob,
          $$ConfigBlobsTableFilterComposer,
          $$ConfigBlobsTableOrderingComposer,
          $$ConfigBlobsTableAnnotationComposer,
          $$ConfigBlobsTableCreateCompanionBuilder,
          $$ConfigBlobsTableUpdateCompanionBuilder,
          (
            ConfigBlob,
            BaseReferences<_$AppDatabase, $ConfigBlobsTable, ConfigBlob>,
          ),
          ConfigBlob,
          PrefetchHooks Function()
        > {
  $$ConfigBlobsTableTableManager(_$AppDatabase db, $ConfigBlobsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ConfigBlobsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ConfigBlobsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ConfigBlobsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<Uint8List> data = const Value.absent(),
                Value<DateTime> updated = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ConfigBlobsCompanion(
                key: key,
                data: data,
                updated: updated,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required Uint8List data,
                required DateTime updated,
                Value<int> rowid = const Value.absent(),
              }) => ConfigBlobsCompanion.insert(
                key: key,
                data: data,
                updated: updated,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ConfigBlobsTable, ConfigBlob>(table),
                  BaseReferences<_$AppDatabase, $ConfigBlobsTable, ConfigBlob>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ConfigBlobsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ConfigBlobsTable,
      ConfigBlob,
      $$ConfigBlobsTableFilterComposer,
      $$ConfigBlobsTableOrderingComposer,
      $$ConfigBlobsTableAnnotationComposer,
      $$ConfigBlobsTableCreateCompanionBuilder,
      $$ConfigBlobsTableUpdateCompanionBuilder,
      (
        ConfigBlob,
        BaseReferences<_$AppDatabase, $ConfigBlobsTable, ConfigBlob>,
      ),
      ConfigBlob,
      PrefetchHooks Function()
    >;
typedef $$RecentConnectionsTableCreateCompanionBuilder =
    RecentConnectionsCompanion Function({
      required String kind,
      required String address,
      Value<String> name,
      Value<int?> nodeNum,
      required DateTime lastUsed,
      Value<int> rowid,
    });
typedef $$RecentConnectionsTableUpdateCompanionBuilder =
    RecentConnectionsCompanion Function({
      Value<String> kind,
      Value<String> address,
      Value<String> name,
      Value<int?> nodeNum,
      Value<DateTime> lastUsed,
      Value<int> rowid,
    });

class $$RecentConnectionsTableFilterComposer
    extends Composer<_$AppDatabase, $RecentConnectionsTable> {
  $$RecentConnectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get nodeNum => $composableBuilder(
    column: $table.nodeNum,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastUsed => $composableBuilder(
    column: $table.lastUsed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RecentConnectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $RecentConnectionsTable> {
  $$RecentConnectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get nodeNum => $composableBuilder(
    column: $table.nodeNum,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastUsed => $composableBuilder(
    column: $table.lastUsed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RecentConnectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecentConnectionsTable> {
  $$RecentConnectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get nodeNum =>
      $composableBuilder(column: $table.nodeNum, builder: (column) => column);

  GeneratedColumn<DateTime> get lastUsed =>
      $composableBuilder(column: $table.lastUsed, builder: (column) => column);
}

class $$RecentConnectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RecentConnectionsTable,
          RecentConnection,
          $$RecentConnectionsTableFilterComposer,
          $$RecentConnectionsTableOrderingComposer,
          $$RecentConnectionsTableAnnotationComposer,
          $$RecentConnectionsTableCreateCompanionBuilder,
          $$RecentConnectionsTableUpdateCompanionBuilder,
          (
            RecentConnection,
            BaseReferences<
              _$AppDatabase,
              $RecentConnectionsTable,
              RecentConnection
            >,
          ),
          RecentConnection,
          PrefetchHooks Function()
        > {
  $$RecentConnectionsTableTableManager(
    _$AppDatabase db,
    $RecentConnectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecentConnectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecentConnectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecentConnectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> kind = const Value.absent(),
                Value<String> address = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> nodeNum = const Value.absent(),
                Value<DateTime> lastUsed = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RecentConnectionsCompanion(
                kind: kind,
                address: address,
                name: name,
                nodeNum: nodeNum,
                lastUsed: lastUsed,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String kind,
                required String address,
                Value<String> name = const Value.absent(),
                Value<int?> nodeNum = const Value.absent(),
                required DateTime lastUsed,
                Value<int> rowid = const Value.absent(),
              }) => RecentConnectionsCompanion.insert(
                kind: kind,
                address: address,
                name: name,
                nodeNum: nodeNum,
                lastUsed: lastUsed,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RecentConnectionsTable, RecentConnection>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $RecentConnectionsTable,
                    RecentConnection
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RecentConnectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RecentConnectionsTable,
      RecentConnection,
      $$RecentConnectionsTableFilterComposer,
      $$RecentConnectionsTableOrderingComposer,
      $$RecentConnectionsTableAnnotationComposer,
      $$RecentConnectionsTableCreateCompanionBuilder,
      $$RecentConnectionsTableUpdateCompanionBuilder,
      (
        RecentConnection,
        BaseReferences<
          _$AppDatabase,
          $RecentConnectionsTable,
          RecentConnection
        >,
      ),
      RecentConnection,
      PrefetchHooks Function()
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$NodesTableTableManager get nodes =>
      $$NodesTableTableManager(_db, _db.nodes);
  $$MessagesTableTableManager get messages =>
      $$MessagesTableTableManager(_db, _db.messages);
  $$ChannelsTableTableManager get channels =>
      $$ChannelsTableTableManager(_db, _db.channels);
  $$PositionsTableTableManager get positions =>
      $$PositionsTableTableManager(_db, _db.positions);
  $$TelemetryLogTableTableManager get telemetryLog =>
      $$TelemetryLogTableTableManager(_db, _db.telemetryLog);
  $$TraceroutesTableTableManager get traceroutes =>
      $$TraceroutesTableTableManager(_db, _db.traceroutes);
  $$NeighborsTableTableManager get neighbors =>
      $$NeighborsTableTableManager(_db, _db.neighbors);
  $$MyNodeTableTableManager get myNode =>
      $$MyNodeTableTableManager(_db, _db.myNode);
  $$ConfigBlobsTableTableManager get configBlobs =>
      $$ConfigBlobsTableTableManager(_db, _db.configBlobs);
  $$RecentConnectionsTableTableManager get recentConnections =>
      $$RecentConnectionsTableTableManager(_db, _db.recentConnections);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
