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
                let options: [String : Bool] = [
                    CBCentralManagerScanOptionAllowDuplicatesKey : setting.allowDuplicates
                ]
                //scan開始
                self.centralManager.scanForPeripheralsWithServices(setting.serviceUUID, options: options)
            }
        default:
            break
        }
    }
    
    /**
     復元
     
     - parameter central: <#central description#>
     - parameter dict:    <#dict description#>
     */
    public func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
        // 復元された、接続を試みている、あるいは接続済みのペリフェラル
        if let peripherals: [CBPeripheral] = dict[CBCentralManagerRestoredStatePeripheralsKey] as! [CBPeripheral]! {
            // プロパティに保持しなおす
            for aPeripheral in peripherals {
                aPeripheral.delegate = self
            }
        }
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
            
            delegate.nearByDevices(deviceInfo)
            
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
            peripheral.delegate = self
            peripheral.discoverServices(setting.serviceUUID)
        }
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
    
    /**
     復元
     
     - parameter peripheral: <#peripheral description#>
     - parameter dict:       <#dict description#>
     */
    public func peripheralManager(peripheral: CBPeripheralManager, willRestoreState dict: [String : AnyObject]) {
        if let setting = self.streetPassSettings {
            // 復元された登録済みサービス
            if let services: [CBMutableService] = dict[CBPeripheralManagerRestoredStateServicesKey] as! [CBMutableService]! {
                // プロパティにセットしなおす
                for service in services {
                    for aCharacteristic in service.characteristics! {
                        if aCharacteristic.isEqual(setting.characteristicUUID) {
                            self.characteristic = aCharacteristic as! CBMutableCharacteristic
                        }
                    }
                }
            }
        }
    }
    
    /**
     serviceが見つかったら、よばれる
     
     - parameter peripheral: <#peripheral description#>
     - parameter error:      <#error description#>
     */
    public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        if let setting = streetPassSettings {
            if let services : [CBService] = peripheral.services {
                for obj in services {
                    if obj.UUID.isEqual(setting.serviceUUID[0]) {
                        peripheral.discoverCharacteristics(setting.characteristicUUID, forService: obj)
                        break
                    }
                }
            }
        }
    }
    
    /**
     characteristicsが見つかったら、呼ばれるよ
     
     - parameter peripheral: peripheral description
     - parameter service:    service description
     - parameter error:      error description
     */
    public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        if let setting = streetPassSettings {
            if let characteristics : [CBCharacteristic] = service.characteristics {
                for obj in characteristics {
                    if obj.UUID.isEqual(setting.characteristicUUID[0]) {
                        //現在値を読み込む
                        peripheral.readValueForCharacteristic(obj)
                    }
                }
            }
        }
    }
    
    /**
     characteristicが読み込まれるとここがよばれる
     
     - parameter peripheral:     <#peripheral description#>
     - parameter characteristic: <#characteristic description#>
     - parameter error:          <#error description#>
     */
    public func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if error != nil {
            if let delegate = self.delegate {
                delegate.streetPassError(error!)
            }
            return
        }
        
        if let delegate = self.delegate {
            if let data = characteristic.value {
                //値読込
                let out: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
                let receivedData: ReceivedData = ReceivedData()
                receivedData.peripheral = peripheral
                receivedData.data = out
                delegate.receivedData(receivedData)
            }
        }
        
        if let setting = streetPassSettings {
            //送信
            writeData(setting.sendData, periperal: peripheral)
        }
    }
    
    /**
     write完了するとここがよばれる
     
     - parameter peripheral:     <#peripheral description#>
     - parameter characteristic: <#characteristic description#>
     - parameter error:          <#error description#>
     */
    public func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        //接続切断
        centralManager.cancelPeripheralConnection(peripheral)
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
                
                let service = CBMutableService(type: setting.serviceUUID[0], primary: true)
                let characteristic = CBMutableCharacteristic(
                    type: setting.characteristicUUID[0],
                    properties: [CBCharacteristicProperties.Read, CBCharacteristicProperties.Write],
                    value: nil,
                    permissions: [CBAttributePermissions.Readable, CBAttributePermissions.Writeable]
                )
                service.characteristics = [characteristic]
                self.peripheralManager.addService(service)
                
                let initData: NSData! = setting.initData.dataUsingEncoding(NSUTF8StringEncoding)
                characteristic.value = initData
                self.characteristic = characteristic
                
                let advertiseData: [String : AnyObject] = [
                    CBAdvertisementDataLocalNameKey: setting.advertisementDataLocalNameKey,
                    CBAdvertisementDataServiceUUIDsKey: setting.serviceUUID
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
    
    public func writeData(data: String, periperal: CBPeripheral) {
        if let sendData: NSData = data.dataUsingEncoding(NSUTF8StringEncoding) {
            if let services : [CBService] = peripheral.services {
                for service in services {
                    if let characteristics: [CBCharacteristic] = service.characteristics {
                        for characteristic in characteristics {
                            if characteristic.UUID.isEqual(self.characteristic.UUID) {
                                peripheral.writeValue(
                                    sendData,
                                    forCharacteristic: characteristic,
                                    type: CBCharacteristicWriteType.WithResponse
                                )
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        request.value = self.characteristic.value
        self.peripheralManager.respondToRequest(
            request,
            withResult: CBATTError.Success
        )
    }
    
    public func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        
        for obj in requests {
            if let request = obj as CBATTRequest! {
                self.characteristic.value = request.value
                if let data = obj.characteristic.value {
                    let out: String = NSString(data: data, encoding: NSUTF8StringEncoding)! as String
                    if let delegate = self.delegate {
                        //値読込
                        let receivedData: ReceivedData = ReceivedData()
                        receivedData.data = out
                        delegate.receivedData(receivedData)
                    }
                }
            }
        }
        
        self.peripheralManager.respondToRequest(requests[0] as CBATTRequest, withResult: CBATTError.Success)
        
    }
    
}