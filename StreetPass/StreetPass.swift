//
//  StreetPass.swift
//  StreetPass
//
//  Created by 新見晃平 on 2016/02/23.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import Foundation
import CoreBluetooth

public class StreetPass: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate {
    
    public var delegate: StreetPassDelegate?
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    
    public func onStart() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    public func onStop() {
        self.centralManager.stopScan()
        self.peripheralManager.stopAdvertising()
    }
    
    public func centralManagerDidUpdateState(central: CBCentralManager) {
        print(central.state)
        switch central.state {
        case .Unknown:
            print("[DEBUG] Central manager state: Unknown")
        case .Resetting:
            print("[DEBUG] Central manager state: Resseting")
        case .Unsupported:
            print("[DEBUG] Central manager state: Unsopported")
        case .Unauthorized:
            print("[DEBUG] Central manager state: Unauthorized")
        case .PoweredOff:
            print("[DEBUG] Central manager state: Powered off")
        case .PoweredOn:
            print("[DEBUG] Central manager state: Powered on")
            self.centralManager.scanForPeripheralsWithServices(nil, options: nil)
        }
        self.delegate?.bleDidUpdateState()
    }
    
    public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print(peripheral)
    }
    
    public func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        print("periphera")
        switch peripheral.state {
        case .Unknown:
            print("[DEBUG] peripheral: Unknown")
        case .Resetting:
            print("[DEBUG] peripheral: Resseting")
        case .Unsupported:
            print("[DEBUG] peripheral: Unsopported")
        case .Unauthorized:
            print("[DEBUG] peripheral: Unauthorized")
        case .PoweredOff:
            print("[DEBUG] peripheral: Powered Off")
        case .PoweredOn:
            print("[DEBUG] peripheral: Powered on")
            let advertiseData: Dictionary = [CBAdvertisementDataLocalNameKey: "Test"]
            self.peripheralManager.startAdvertising(advertiseData)
        }
    }
    
    @objc public func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        print("adverise成功")
    }
    
}