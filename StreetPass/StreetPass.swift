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
    private var characteristic = CBMutableCharacteristic!()
    
    public func onStart() {
        let centralQueue: dispatch_queue_t = dispatch_queue_create("com.gupuru.StreetPass.central", DISPATCH_QUEUE_SERIAL)
        let peripheralQueue: dispatch_queue_t = dispatch_queue_create("com.gupuru.StreetPass.peripheral", DISPATCH_QUEUE_SERIAL)
        let centralOptions: [String : AnyObject] = [
            CBCentralManagerOptionRestoreIdentifierKey : "com.gupuru.StreetPass.central.restore"
        ]
        let peripheralOptions: [String : AnyObject] = [
            CBCentralManagerOptionRestoreIdentifierKey : "com.gupuru.StreetPass.peripheral.restore"
        ]
        self.centralManager = CBCentralManager(delegate: self, queue: centralQueue, options: centralOptions)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: peripheralQueue, options: peripheralOptions)
    }
    
    public func onStop() {
        if let central = self.centralManager {
            central.stopScan()
            self.centralManager = nil
        }
        if let peripheral = self.peripheralManager {
            peripheral.stopAdvertising()
            self.peripheralManager = nil
        }
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
            
            let serviceUUIDs: [CBUUID] = [CBUUID(string: Settings.UUID().service)]
            let options: [String : Bool] = [CBCentralManagerScanOptionAllowDuplicatesKey : Settings.ScanOptions().allowDuplicates]
            self.centralManager.scanForPeripheralsWithServices(serviceUUIDs, options: options)
        }
        self.delegate?.bleDidUpdateState()
    }
    
    public func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        print("復元しただがや")
        
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
        
//        self.peripheral = peripheral
//        self.centralManager.connectPeripheral(self.peripheral, options: nil)
    }
    
    /**
     端末に接続したらここよばれる
     
     - parameter central:    <#central description#>
     - parameter peripheral: <#peripheral description#>
     */
    public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        print("接続成功")
        print(peripheral)
        let serviceUUIDs: [CBUUID] = [CBUUID(string: Settings.UUID().service)]
        peripheral.delegate = self
        peripheral.discoverServices(serviceUUIDs)
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
    
    public func peripheralManager(peripheral: CBPeripheralManager, willRestoreState dict: [String : AnyObject]) {
        print("復活だがやあああああああああああああ")
        
        // Notificationの生成する.
        let myNotification: UILocalNotification = UILocalNotification()
        // メッセージを代入する.
        myNotification.alertBody = "復活"
        myNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
        // Timezoneを設定をする.
        myNotification.timeZone = NSTimeZone.defaultTimeZone()
        // Notificationを表示する.
        UIApplication.sharedApplication().scheduleLocalNotification(myNotification)

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
        let characteristicsUUIDs: [CBUUID] = [CBUUID(string: Settings.UUID().characteristic)]
        for obj in services {
            if let service = obj as? CBService {
                peripheral.discoverCharacteristics(characteristicsUUIDs, forService: service)
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
    
    public func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if error != nil {
            print("しっぱあああああい")
            return
        }
        print("サービス追加OK")
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
            let serviceUUID = CBUUID(string: Settings.UUID().service)
            let service = CBMutableService(type: serviceUUID, primary: true)
            let characteristicsUUID = CBUUID(string: Settings.UUID().characteristic)
            let characteristic = CBMutableCharacteristic(type: characteristicsUUID, properties: [CBCharacteristicProperties.Read, CBCharacteristicProperties.Write],
                value: nil, permissions: [CBAttributePermissions.Readable, CBAttributePermissions.Writeable])
            service.characteristics = [characteristic]
            self.peripheralManager.addService(service)
            
            let initData: NSData! = "mikkan".dataUsingEncoding(NSUTF8StringEncoding)
            characteristic.value = initData
            self.characteristic = characteristic
        
            let serviceAdvertiseUUID = [CBUUID(string: Settings.UUID().service)]
            let advertiseData: [String : AnyObject] = [
                CBAdvertisementDataLocalNameKey: "ios",
                CBAdvertisementDataServiceUUIDsKey: serviceAdvertiseUUID
            ]
            
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
    
    public func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        print("へーい、read来たぜ、ぐへへへ \(request.characteristic.UUID) \(request.characteristic.value)")
        if let data = request.characteristic.value {
            let out: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
            print(out)
        }
        
        if request.characteristic.UUID.isEqual(self.characteristic.UUID) {
            print("ほほほほほ")
            request.value = self.characteristic.value
            self.peripheralManager.respondToRequest(
                request,
                withResult: CBATTError.Success
            )
        }
        
    }
    
    public func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        print("write件数\(requests.count)")
        
        for obj in requests {
            if let request = obj as CBATTRequest! {
                if request.characteristic.UUID.isEqual(self.characteristic.UUID) {
                    print("ふええええ")
                    self.characteristic.value = request.value
                    if let data = obj.characteristic.value {
                        let out: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
                        print(out)
                    }
                }
            }
        }
        
        self.peripheralManager.respondToRequest(requests[0] as CBATTRequest, withResult: CBATTError.Success)
        
    }

}