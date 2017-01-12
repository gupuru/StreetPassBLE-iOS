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
    
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
    
}

@objc public enum PeripheralManagerState : Int {
    
    case unknown
    case resetting
    case unsupported
    case unauthorized
    case poweredOff
    case poweredOn
    
}

@objc public enum ConnectedDeviceStatus : Int {
    
    case success
    case disConected
    case failure
    
}

/**
 受信したデータ
 */
@objc open class ReceivedData : NSObject {
    
    var _data : String?
    var _peripheral : CBPeripheral?
    
    public override init() {
        super.init()
    }
    
    open var data: String? {
        get {
            return _data
        }
        
        set(data) {
            _data = data
        }
    }
    
    open var peripheral : CBPeripheral? {
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
@objc open class ConnectedDeviceInfo : NSObject {
    
    var _status : ConnectedDeviceStatus?
    var _peripheral : CBPeripheral?

    public override init() {
        super.init()
    }
    
    open var status : ConnectedDeviceStatus? {
        get {
            return _status
        }
        
        set(status) {
            _status = status
        }
    }
    
    open var peripheral : CBPeripheral? {
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
@objc open class DeveiceInfo: NSObject {
    
    var _peripheral : CBPeripheral?
    var _advertisementData : [String : AnyObject]?
    var _RSSI : NSNumber?
    
    public override init() {
        super.init()
    }
    
    open var deviceName : String = ""
    
    open var peripheral : CBPeripheral? {
        get {
            return _peripheral
        }
        
        set(peripheral) {
            _peripheral = peripheral
        }
    }
    
    open var advertisementData : [String : AnyObject]? {
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
    
    open var RSSI : NSNumber? {
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
    internal func setCentralState(_ delegate: StreetPassDelegate, central: CBCentralManager) {
        switch central.state {
        case .unknown:
            if let _ = delegate.centralManagerState?(CentralManagerState.unknown) {}
        case .resetting:
            if let _ = delegate.centralManagerState?(CentralManagerState.resetting) {}
        case .unsupported:
            if let _ = delegate.centralManagerState?(CentralManagerState.unsupported) {}
        case .unauthorized:
            if let _ = delegate.centralManagerState?(CentralManagerState.unauthorized) {}
        case .poweredOff:
            if let _ = delegate.centralManagerState?(CentralManagerState.poweredOff) {}
        case .poweredOn:
            if let _ = delegate.centralManagerState?(CentralManagerState.poweredOn) {}
        }
    }
    
    /**
     Peripheralの状態変化
     */
    internal func setPeripheralState(_ delegate: StreetPassDelegate, peripheral: CBPeripheralManager) {
        switch peripheral.state {
        case .unknown:
            if let _ = delegate.peripheralManagerState?(PeripheralManagerState.unknown) {}
        case .resetting:
            if let _ = delegate.peripheralManagerState?(PeripheralManagerState.resetting) {}
        case .unsupported:
            if let _ = delegate.peripheralManagerState?(PeripheralManagerState.unsupported) {}
        case .unauthorized:
            if let _ = delegate.peripheralManagerState?(PeripheralManagerState.unauthorized) {}
        case .poweredOff:
            if let _ = delegate.peripheralManagerState?(PeripheralManagerState.poweredOff) {}
        case .poweredOn:
            if let _ = delegate.peripheralManagerState?(PeripheralManagerState.poweredOn) {}
        }
    }
    
}
