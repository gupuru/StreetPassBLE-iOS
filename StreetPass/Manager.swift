//
//  Manager.swift
//  StreetPass
//
//  Created by 新見晃平 on 2016/02/25.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import Foundation
import CoreBluetooth

@objc public enum CentralManagerState : Int {
    
    case Unknown
    case Resetting
    case Unsupported
    case Unauthorized
    case PoweredOff
    case PoweredOn
    
}

@objc public enum PeripheralManagerState : Int {
    
    case Unknown
    case Resetting
    case Unsupported
    case Unauthorized
    case PoweredOff
    case PoweredOn
    
}

@objc public enum ConnectedDeviceStatus : Int {
    
    case Success
    case DisConected
    case Failure
    
}

/**
 受信したデータ
 */
@objc public class ReceivedData : NSObject {
    
    var _data : String?
    var _peripheral : CBPeripheral?
    
    public override init() {
        super.init()
    }
    
    public var data: String? {
        get {
            return _data
        }
        
        set(data) {
            _data = data
        }
    }
    
    public var peripheral : CBPeripheral? {
        get {
            return _peripheral
        }
        
        set(peripheral) {
            _peripheral = peripheral
        }
    }
    
}

/**
 接続した端末
 */
@objc public class ConnectedDeviceInfo : NSObject {
    
    var _status : ConnectedDeviceStatus?
    var _peripheral : CBPeripheral?

    public override init() {
        super.init()
    }
    
    public var status : ConnectedDeviceStatus? {
        get {
            return _status
        }
        
        set(status) {
            _status = status
        }
    }
    
    public var peripheral : CBPeripheral? {
        get {
            return _peripheral
        }
        
        set(peripheral) {
            _peripheral = peripheral
        }
    }
    
}

/**
 端末情報
 */
@objc public class DeveiceInfo: NSObject {
    
    var _peripheral : CBPeripheral?
    var _advertisementData : [String : AnyObject]?
    var _RSSI : NSNumber?
    
    public override init() {
        super.init()
    }
    
    public var deviceName : String = ""
    
    public var peripheral : CBPeripheral? {
        get {
            return _peripheral
        }
        
        set(peripheral) {
            _peripheral = peripheral
        }
    }
    
    public var advertisementData : [String : AnyObject]? {
        get {
            return _advertisementData
        }
        
        set(advertisementData) {
            _advertisementData = advertisementData
            if let data = advertisementData {
                if let name = data["kCBAdvDataLocalName"] as? String {
                    deviceName = name
                }
            }
        }
    }
    
    public var RSSI : NSNumber? {
        get {
            return _RSSI
        }
        
        set(RSSI) {
            _RSSI = RSSI
        }
    }

}

/**
 Central, Peripheral状態変化
 */
internal class CentralManager : NSObject {
    
    /**
     centralの状態変化
     */
    internal func setCentralState(delegate: StreetPassDelegate, central: CBCentralManager) {
        switch central.state {
        case .Unknown:
            if let _ = delegate.centralManagerState?(CentralManagerState.Unknown) {}
        case .Resetting:
            if let _ = delegate.centralManagerState?(CentralManagerState.Resetting) {}
        case .Unsupported:
            if let _ = delegate.centralManagerState?(CentralManagerState.Unsupported) {}
        case .Unauthorized:
            if let _ = delegate.centralManagerState?(CentralManagerState.Unauthorized) {}
        case .PoweredOff:
            if let _ = delegate.centralManagerState?(CentralManagerState.PoweredOff) {}
        case .PoweredOn:
            if let _ = delegate.centralManagerState?(CentralManagerState.PoweredOn) {}
        }
    }
    
    /**
     Peripheralの状態変化
     */
    internal func setPeripheralState(delegate: StreetPassDelegate, peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .Unknown:
            if let _ = delegate.peripheralManagerState?(PeripheralManagerState.Unknown) {}
        case .Resetting:
            if let _ = delegate.peripheralManagerState?(PeripheralManagerState.Resetting) {}
        case .Unsupported:
            if let _ = delegate.peripheralManagerState?(PeripheralManagerState.Unsupported) {}
        case .Unauthorized:
            if let _ = delegate.peripheralManagerState?(PeripheralManagerState.Unauthorized) {}
        case .PoweredOff:
            if let _ = delegate.peripheralManagerState?(PeripheralManagerState.PoweredOff) {}
        case .PoweredOn:
            if let _ = delegate.peripheralManagerState?(PeripheralManagerState.PoweredOn) {}
        }
    }
    
}