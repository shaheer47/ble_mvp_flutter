import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleMessenger {
  static const MethodChannel _channel = MethodChannel('ble_messenger');

  /// Starts advertising the given [message] via BLE.
  /// The message is truncated to 20 bytes to fit in the advertisement packet.
  /// Uses Manufacturer ID 0x1234.
  Future<void> startAdvertising(String message) async {
    // Truncate if necessary (UTF-8 bytes)
    List<int> bytes = utf8.encode(message);
    if (bytes.length > 20) {
      // Decode back to string to ensure valid chars, then truncate
      String safeString = utf8.decode(bytes.sublist(0, 20), allowMalformed: true);
      message = safeString;
    }
    await _channel.invokeMethod('startAdvertising', {'id': message});
  }

  /// Stops advertising.
  Future<void> stopAdvertising() async {
    await _channel.invokeMethod('stopAdvertising');
  }

  /// Scans for other BleMessenger devices.
  /// Returns a stream of [BleMessage] objects found nearby.
  /// Filters strictly for Manufacturer ID 0x1234.
  Stream<List<BleMessage>> scanForMessengers() {
    // Start scanning
    FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 15),
      // Note: Android requires location permission. Ensure app requests it.
    );

    return FlutterBluePlus.scanResults.map((results) {
      return results
          .where((r) => r.advertisementData.manufacturerData.containsKey(0x1234))
          .map((r) {
            List<int> data = r.advertisementData.manufacturerData[0x1234] ?? [];
            String message = utf8.decode(data, allowMalformed: true);
            return BleMessage(
              deviceId: r.device.remoteId.str,
              message: message,
              rssi: r.rssi,
              device: r.device,
            );
          })
          .toList();
    });
  }
  
  /// Stops scanning.
  Future<void> stopScanning() async {
    await FlutterBluePlus.stopScan();
  }
}

class BleMessage {
  final String deviceId;
  final String message;
  final int rssi;
  final BluetoothDevice device;

  BleMessage({
    required this.deviceId,
    required this.message,
    required this.rssi,
    required this.device,
  });
}
