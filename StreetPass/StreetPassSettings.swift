//
//  Settings.swift
//  StreetPass
//
//  Created by 新見晃平 on 2016/02/24.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import Foundation
import CoreBluetooth

open class StreetPassSettings {
    
    fileprivate var _serviceUUID: [CBUUID] = [CBUUID(string: "0000180A-0000-1000-8000-00805F9B34FB")]
    fileprivate var _writeCharacteristicUUID: [CBUUID] = [CBUUID(string: "0C136FCC-3381-4F1E-9602-E2A3F8B70CEB")]
    fileprivate var _readCharacteristicUUID: [CBUUID] = [CBUUID(string: "1BE31CB9-9E07-4892-AA26-30E87ABE9F70")]
    fileprivate var _allowDuplicates: Bool = false
    fileprivate var _sendData: String = ""
    fileprivate var _advertisementDataLocalNameKey: String = "iOS"
    fileprivate var _isConnect: Bool = false

    public init() {
    }
    
    var serviceUUID: [CBUUID] {
        get {
            return _serviceUUID
        }
        
        set(serviceUUID) {
            _serviceUUID = serviceUUID
        }
    }
    
    var writeCharacteristicUUID: [CBUUID] {
        get {
            return _writeCharacteristicUUID
        }
        
        set(writeCharacteristicUUID) {
            _writeCharacteristicUUID = writeCharacteristicUUID
        }
    }
    
    var readCharacteristicUUID: [CBUUID] {
        get {
            return _readCharacteristicUUID
        }
        
        set(readCharacteristicUUID) {
            _readCharacteristicUUID = readCharacteristicUUID
        }
    }
    
    var allowDuplicates: Bool {
        get {
            return _allowDuplicates
        }
        
        set(allowDuplicates) {
            _allowDuplicates = allowDuplicates
        }
    }
    
    var sendData: String {
        get {
            return _sendData
        }
        
        set(sendData) {
            _sendData = sendData
        }
    }
    
    var advertisementDataLocalNameKey: String {
        get {
            return _advertisementDataLocalNameKey
        }
        
        set(initData) {
            _advertisementDataLocalNameKey = advertisementDataLocalNameKey
        }
    }
    
    var isConnect: Bool {
        get {
            return _isConnect
        }
        
        set(isConnect) {
            _isConnect = isConnect
        }
    }
    
    open func serviceUUID(_ serviceUUID: String) -> Self {
        self.serviceUUID = [
            CBUUID(string: serviceUUID)
        ]
        return self
    }
    
    open func writeCharacteristicUUID(_ writeCharacteristicUUID: String) -> Self {
        self.writeCharacteristicUUID = [
            CBUUID(string: writeCharacteristicUUID)
        ]
        return self
    }
    
    open func readCharacteristicUUID(_ readCharacteristicUUID: String) -> Self {
        self.readCharacteristicUUID = [
            CBUUID(string: readCharacteristicUUID)
        ]
        return self
    }
    
    open func allowDuplicates(_ allowDuplicates: Bool) -> Self {
        self.allowDuplicates = allowDuplicates
        return self
    }
    
    open func sendData(_ sendData: String) -> Self {
        self.sendData = sendData
        return self
    }
    
    open func advertisementDataLocalNameKey(_ advertisementDataLocalNameKey: String) -> Self {
        self.advertisementDataLocalNameKey = advertisementDataLocalNameKey
        return self
    }
    
    open func isConnect(_ isConnect : Bool) -> Self {
        self.isConnect = isConnect
        return self
    }
    
}
