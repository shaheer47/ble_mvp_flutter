import Flutter
import UIKit

import Flutter
import UIKit
import CoreBluetooth

public class BleMessengerPlugin: NSObject, FlutterPlugin, CBPeripheralManagerDelegate {
    var peripheralManager: CBPeripheralManager?
    var resultCallback: FlutterResult?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "ble_messenger", binaryMessenger: registrar.messenger())
        let instance = BleMessengerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "startAdvertising":
            guard let args = call.arguments as? [String: Any],
                  let id = args["id"] as? String else {
                result(FlutterError(code: "INVALID_ARGUMENT", message: "ID is null", details: nil))
                return
            }
            startAdvertising(id: id, result: result)
            
        case "stopAdvertising":
            stopAdvertising()
            result(nil)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func startAdvertising(id: String, result: @escaping FlutterResult) {
        self.resultCallback = result
        
        if peripheralManager == nil {
            peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        }
        
        // Wait for state update to power on
        if peripheralManager?.state == .poweredOn {
            startAdvertisingInternal(id: id)
        } else {
            // If not powered on, we wait for delegate callback.
            // Store ID temporarily? Or just fail if off?
            // For simplicity, if off, we fail or wait.
            // Let's store the pending ID in a property if needed, but for MVP:
            if peripheralManager?.state == .poweredOff {
                 result(FlutterError(code: "BLUETOOTH_DISABLED", message: "Bluetooth is off", details: nil))
            }
            // If unknown/resetting, we might wait.
        }
    }
    
    func startAdvertisingInternal(id: String) {
        guard let manager = peripheralManager else { return }
        
        if manager.isAdvertising {
            manager.stopAdvertising()
        }
        
        let data = id.data(using: .utf8)!
        
        // Manufacturer Data: 0x1234 + Data
        // iOS puts Manufacturer Data in the overflow area if it's too big,
        // but for small data it might fit.
        // Note: iOS is restrictive about background advertising.
        // Foreground advertising of Manufacturer Data is generally allowed.
        
        let advertisementData: [String: Any] = [
            CBAdvertisementDataLocalNameKey: "ID-XXXX", // Optional, but good for discovery
            CBAdvertisementDataManufacturerDataKey: Data([0x34, 0x12]) + data // Little Endian 0x1234
        ]
        
        manager.startAdvertising(advertisementData)
    }
    
    func stopAdvertising() {
        peripheralManager?.stopAdvertising()
        peripheralManager = nil
    }
    
    public func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if peripheral.state == .poweredOn {
            // Ready
        }
    }
    
    public func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if let error = error {
            resultCallback?(FlutterError(code: "ADVERTISE_FAILED", message: error.localizedDescription, details: nil))
        } else {
            resultCallback?(nil)
        }
        resultCallback = nil
    }
}
