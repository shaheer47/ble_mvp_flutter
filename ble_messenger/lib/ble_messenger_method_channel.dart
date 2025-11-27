import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'ble_messenger_platform_interface.dart';

/// An implementation of [BleMessengerPlatform] that uses method channels.
class MethodChannelBleMessenger extends BleMessengerPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('ble_messenger');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
