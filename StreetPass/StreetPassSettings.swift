//
//  Settings.swift
//  StreetPass
//
//  Created by 新見晃平 on 2016/02/24.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import Foundation

public class StreetPassSettings {
    
    private var _serviceUUID : String = "0000180a-0000-1000-8000-00805f9b34fb"
    private var _characteristicUUID : String = "00002a29-0000-1000-8000-00805f9b34fb"
    private var _allowDuplicates : Bool = false
    private var _initData : String = "spb"
    private var _advertisementDataLocalNameKey : String = "iOS"
    private var _isConnect : Bool = false

    public init() {
    }
    
    var serviceUUID : String {
        get {
            return _serviceUUID
        }
        
        set(serviceUUID) {
            _serviceUUID = serviceUUID
        }
    }
    
    var characteristicUUID : String {
        get {
            return _characteristicUUID
        }
        
        set(characteristicUUID) {
            _characteristicUUID = characteristicUUID
        }
    }
    
    var allowDuplicates : Bool {
        get {
            return _allowDuplicates
        }
        
        set(allowDuplicates) {
            _allowDuplicates = allowDuplicates
        }
    }
    
    var initData : String {
        get {
            return _initData
        }
        
        set(initData) {
            _initData = initData
        }
    }
    
    var advertisementDataLocalNameKey : String {
        get {
            return _advertisementDataLocalNameKey
        }
        
        set(initData) {
            _advertisementDataLocalNameKey = advertisementDataLocalNameKey
        }
    }
    
    var isConnect : Bool {
        get {
            return _isConnect
        }
        
        set(isConnect) {
            _isConnect = isConnect
        }
    }
    
    public func serviceUUID(serviceUUID : String) -> Self {
        self.serviceUUID = serviceUUID
        return self
    }
    
    public func characteristicUUID(characteristicUUID : String) -> Self {
        self.characteristicUUID = characteristicUUID
        return self
    }
    
    public func allowDuplicates(allowDuplicates : Bool) -> Self {
        self.allowDuplicates = allowDuplicates
        return self
    }
    
    public func initData(initData : String) -> Self {
        self.initData = initData
        return self
    }
    
    public func advertisementDataLocalNameKey(advertisementDataLocalNameKey : String) -> Self {
        self.advertisementDataLocalNameKey = advertisementDataLocalNameKey
        return self
    }
    
    public func isConnect(isConnect : Bool) -> Self {
        self.isConnect = isConnect
        return self
    }
    
}