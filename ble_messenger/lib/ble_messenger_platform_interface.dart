import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'ble_messenger_method_channel.dart';

abstract class BleMessengerPlatform extends PlatformInterface {
  /// Constructs a BleMessengerPlatform.
  BleMessengerPlatform() : super(token: _token);

  static final Object _token = Object();

  static BleMessengerPlatform _instance = MethodChannelBleMessenger();

  /// The default instance of [BleMessengerPlatform] to use.
  ///
  /// Defaults to [MethodChannelBleMessenger].
  static BleMessengerPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [BleMessengerPlatform] when
  /// they register themselves.
  static set instance(BleMessengerPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
