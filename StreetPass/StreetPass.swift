//
//  StreetPass.swift
//  StreetPass
//
//  Created by 新見晃平 on 2016/02/23.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import Foundation
import CoreBluetooth

public class StreetPass: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    public var delegate: StreetPassDelegate?
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    private var peripheral: CBPeripheral!
    
    public func onStart() {
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
    }
    
    public func onStop() {
        self.centralManager.stopScan()
        self.peripheralManager.stopAdvertising()
    }
    
    /**
     scanのステータス
     
     - parameter central: <#central description#>
     */
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
    
    /**
     受信したらここよばれる
     
     - parameter central:           central description
     - parameter peripheral:        <#peripheral description#>
     - parameter advertisementData: <#advertisementData description#>
     - parameter RSSI:              <#RSSI description#>
     */
    public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        print(peripheral)
        self.peripheral = peripheral
        self.centralManager.connectPeripheral(self.peripheral, options: nil)
    }
    
    /**
     端末に接続したらここよばれる
     
     - parameter central:    <#central description#>
     - parameter peripheral: <#peripheral description#>
     */
    public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("接続成功")
        print(peripheral)
        peripheral.delegate = self
        peripheral.discoverServices(nil)
        //接続きるよ
//        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    /**
     接続が切れた場合はここ
     
     - parameter central:    <#central description#>
     - parameter peripheral: <#peripheral description#>
     - parameter error:      <#error description#>
     */
    public func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("接続きったよ")
    }
    
    /**
     端末の接続に失敗したらここよばれる
     
     - parameter central:    <#central description#>
     - parameter peripheral: <#peripheral description#>
     - parameter error:      <#error description#>
     */
    public func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        print("接続失敗")
    }
    
    /**
     serviceが見つかったら、よばれる
     
     - parameter peripheral: <#peripheral description#>
     - parameter error:      <#error description#>
     */
    public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        let services: NSArray = peripheral.services!
        if services.count > 0 {
            print("なんこあるの \(services.count)")
        }
        for obj in services {
            if let service = obj as? CBService {
                peripheral.discoverCharacteristics(nil, forService: service)
            }
        }
    }
    
    /**
     characteristicsが見つかったら、呼ばれるよ
     
     - parameter peripheral: <#peripheral description#>
     - parameter service:    <#service description#>
     - parameter error:      <#error description#>
     */
    public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?){
        let characteristics: NSArray = service.characteristics!
        print("キャラちゃん\(characteristics.count)")
        for obj in characteristics {
            if let characteristic = obj as? CBCharacteristic {
                if characteristic.properties == CBCharacteristicProperties.Read {
                    peripheral.readValueForCharacteristic(characteristic)
                }
            }
        }
    }
    
    public func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("読込成功だよん\(characteristic.service.UUID)  \(characteristic.value)")
    }
    
    /**
     advertiseのステータス
     
     - parameter peripheral: <#peripheral description#>
     */
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
    
    /**
     advertiseが成功したか
     
     - parameter peripheral: <#peripheral description#>
     - parameter error:      <#error description#>
     */
    @objc public func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        print("adverise成功")
    }
    
}