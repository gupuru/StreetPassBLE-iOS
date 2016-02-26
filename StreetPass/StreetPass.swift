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
    private var streetPassSettings: StreetPassSettings?
    private var centralManager: CBCentralManager!
    private var peripheralManager: CBPeripheralManager!
    private var peripheral: CBPeripheral!
    private var characteristic = CBMutableCharacteristic!()
    
    /**
     開始
     */
    public func start() {
        self.streetPassSettings = StreetPassSettings()
        initBLE()
    }
    
    /**
     設定値ありの開始
     
     - parameter streetPassSettings: <#streetPassSettings description#>
     */
    public func start(streetPassSettings: StreetPassSettings) {
        self.streetPassSettings = streetPassSettings
        initBLE()
    }
    
    /**
     central, peripheralの初期化
     
     - returns: <#return value description#>
     */
    private func initBLE() {
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
    
    /**
     停止
     */
    public func stop() {
        if let central = self.centralManager {
            central.stopScan()
            self.centralManager = nil
        }
        if let peripheral = self.peripheralManager {
            peripheral.stopAdvertising()
            peripheral.removeAllServices()
            self.peripheralManager = nil
        }
    }
    
    /**
     scanのステータス
     
     - parameter central: <#central description#>
     */
    public func centralManagerDidUpdateState(central: CBCentralManager) {
        if let delegate = self.delegate {
            CentralManager().setCentralState(delegate, central: central)
        }
        switch central.state {
        case .PoweredOn:
            if let setting = self.streetPassSettings {
                let serviceUUIDs: [CBUUID] = [
                    CBUUID(string: setting.serviceUUID)
                ]
                let options: [String : Bool] = [
                    CBCentralManagerScanOptionAllowDuplicatesKey : setting.allowDuplicates
                ]
                //scan開始
                self.centralManager.scanForPeripheralsWithServices(serviceUUIDs, options: options)
            }
        default:
            break
        }
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
        if let delegate = self.delegate {
            
            let deviceInfo : DeveiceInfo = DeveiceInfo()
            deviceInfo.peripheral = peripheral
            deviceInfo.advertisementData = advertisementData
            deviceInfo.RSSI = RSSI
            
            delegate.receivingDevices(deviceInfo)
            
        }
        if let setting = self.streetPassSettings {
            if setting.isConnect {
                self.peripheral = peripheral
                //通知をoff
                let connectPeripheralOptions: [String : AnyObject] = [
                    CBConnectPeripheralOptionNotifyOnConnectionKey: false,
                    CBConnectPeripheralOptionNotifyOnDisconnectionKey: false,
                    CBConnectPeripheralOptionNotifyOnNotificationKey: false,
                ]
                //端末に接続
                self.centralManager.connectPeripheral(self.peripheral, options: connectPeripheralOptions)
            }
        }
    }
    
    /**
     端末に接続したらここよばれる
     
     - parameter central:    <#central description#>
     - parameter peripheral: <#peripheral description#>
     */
    public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        if let delegate = self.delegate {
            let connectedDeviceInfo : ConnectedDeviceInfo = ConnectedDeviceInfo()
            connectedDeviceInfo.status = ConnectedDeviceStatus.Success
            connectedDeviceInfo.peripheral = peripheral
            if let _ = delegate.deviceConnectedState?(connectedDeviceInfo){}
        }
        if let setting = self.streetPassSettings {
            let serviceUUIDs: [CBUUID] = [CBUUID(string: setting.serviceUUID)]
            peripheral.delegate = self
            peripheral.discoverServices(serviceUUIDs)
        }
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
        if let delegate = self.delegate {
            let connectedDeviceInfo : ConnectedDeviceInfo = ConnectedDeviceInfo()
            connectedDeviceInfo.status = ConnectedDeviceStatus.DisConected
            connectedDeviceInfo.peripheral = peripheral
            if let _ = delegate.deviceConnectedState?(connectedDeviceInfo){}
        }
    }
    
    /**
     端末の接続に失敗したらここよばれる
     
     - parameter central:    <#central description#>
     - parameter peripheral: <#peripheral description#>
     - parameter error:      <#error description#>
     */
    public func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let delegate = self.delegate {
            let connectedDeviceInfo : ConnectedDeviceInfo = ConnectedDeviceInfo()
            connectedDeviceInfo.status = ConnectedDeviceStatus.Failure
            connectedDeviceInfo.peripheral = peripheral
            if let _ = delegate.deviceConnectedState?(connectedDeviceInfo){}
        }
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
        if let setting = streetPassSettings {
            if let services : [CBService] = peripheral.services {
                let characteristicsUUIDs: [CBUUID] = [
                    CBUUID(string: setting.characteristicUUID)
                ]
                for obj in services {
                    peripheral.discoverCharacteristics(characteristicsUUIDs, forService: obj)
                }
            }
        }
    }
    
    /**
     characteristicsが見つかったら、呼ばれるよ
     
     - parameter peripheral: <#peripheral description#>
     - parameter service:    <#service description#>
     - parameter error:      <#error description#>
     */
    public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let characteristics : [CBCharacteristic] = service.characteristics {
            for obj in characteristics {
                if obj.properties == CBCharacteristicProperties.Read {
                    peripheral.readValueForCharacteristic(obj)
                }
            }
        }
    }
    
    public func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("ここよばれる")
        print("読込成功だよん\(characteristic.service.UUID)  \(characteristic.value)")
    }
    
    /**
     peripheralのserviceに追加された時
     
     - parameter peripheral: <#peripheral description#>
     - parameter service:    <#service description#>
     - parameter error:      <#error description#>
     */
    public func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        if error != nil {
            if let delegate = self.delegate {
                delegate.streetPassError(error!)
            }
            return
        }
        if let delegate = self.delegate {
            if let _ = delegate.peripheralDidAddService?() {}
        }
    }
    
    /**
     advertiseのステータス
     
     - parameter peripheral: <#peripheral description#>
     */
    public func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if let delegate = self.delegate {
            CentralManager().setPeripheralState(delegate, peripheral: peripheral)
        }
        switch peripheral.state {
        case .PoweredOn:
            if let setting = self.streetPassSettings {
                
                let serviceUUID = CBUUID(string: setting.serviceUUID)
                let service = CBMutableService(type: serviceUUID, primary: true)
                let characteristicsUUID = CBUUID(string: setting.characteristicUUID)
                let characteristic = CBMutableCharacteristic(
                    type: characteristicsUUID,
                    properties: [CBCharacteristicProperties.Read, CBCharacteristicProperties.Write],
                    value: nil,
                    permissions: [CBAttributePermissions.Readable, CBAttributePermissions.Writeable]
                )
                service.characteristics = [characteristic]
                self.peripheralManager.addService(service)
                
                let initData: NSData! = setting.initData.dataUsingEncoding(NSUTF8StringEncoding)
                characteristic.value = initData
                self.characteristic = characteristic
                
                let serviceAdvertiseUUID = [CBUUID(string: setting.serviceUUID)]
                let advertiseData: [String : AnyObject] = [
                    CBAdvertisementDataLocalNameKey: setting.advertisementDataLocalNameKey,
                    CBAdvertisementDataServiceUUIDsKey: serviceAdvertiseUUID
                ]
                
                self.peripheralManager.startAdvertising(advertiseData)
                
            }
        default:
            break
        }
    }
    
    /**
     advertiseが成功したか
     
     - parameter peripheral: <#peripheral description#>
     - parameter error:      <#error description#>
     */
    @objc public func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        if error != nil {
            if let delegate = self.delegate {
                delegate.streetPassError(error!)
            }
            return
        }
        if let delegate = self.delegate {
            if let _ = delegate.advertisingState?() {}
        }
    }
    
    private func writeDara(data: String, periperal: CBPeripheral) {
        
        
        if let characteristics : [CBCharacteristic] = service.characteristics {
            for obj in characteristics {
                if obj.properties == CBCharacteristicProperties.Read {
                    peripheral.readValueForCharacteristic(obj)
                }
                
        
        
        
        
        for obj in peripheral.services! {
            
        }
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