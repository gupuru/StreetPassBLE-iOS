//
//  StreetPass.swift
//  StreetPass
//
//  Created by 新見晃平 on 2016/02/23.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import Foundation
import CoreBluetooth

open class StreetPass: NSObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, CBPeripheralDelegate {
    
    open var delegate: StreetPassDelegate?
    fileprivate var streetPassSettings: StreetPassSettings?
    fileprivate var centralManager: CBCentralManager!
    fileprivate var peripheralManager: CBPeripheralManager!
    fileprivate var peripherals: [CBPeripheral] = []
    
    fileprivate var characteristicRead: CBMutableCharacteristic!
    fileprivate var characteristicWrite: CBMutableCharacteristic!
    
    //MARK: - init
    
    /**
    開始
    */
    open func start() {
        self.streetPassSettings = StreetPassSettings()
        initBLE()
    }
    
    /**
     開始(設定値あり)
     */
    open func start(_ streetPassSettings: StreetPassSettings) {
        self.streetPassSettings = streetPassSettings
        initBLE()
    }
    
    /**
     central, peripheralの初期化
     */
    fileprivate func initBLE() {
        let centralQueue: DispatchQueue = DispatchQueue(label: "com.gupuru.StreetPass.central", attributes: [])
        let peripheralQueue: DispatchQueue = DispatchQueue(label: "com.gupuru.StreetPass.peripheral", attributes: [])
        let centralOptions: [String : AnyObject] = [
            CBCentralManagerOptionRestoreIdentifierKey : "com.gupuru.StreetPass.central.restore" as AnyObject
        ]
        let peripheralOptions: [String : AnyObject] = [
            CBCentralManagerOptionRestoreIdentifierKey : "com.gupuru.StreetPass.peripheral.restore" as AnyObject
        ]
        self.centralManager = CBCentralManager(delegate: self, queue: centralQueue, options: centralOptions)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: peripheralQueue, options: peripheralOptions)
    }
    
    /**
     停止
     */
    open func stop() {
        if !peripherals.isEmpty {
            for peripheral in peripherals {
                centralManager.cancelPeripheralConnection(peripheral)
            }
            peripherals.removeAll()
        }
        if let central = self.centralManager {
            central.stopScan()
            self.centralManager = nil
        }
        if let peripheral = self.peripheralManager {
            if peripheral.isAdvertising {
                peripheral.stopAdvertising()
            }
            peripheral.removeAllServices()
            self.peripheralManager = nil
        }
    }
    
    /**
     Advertising処理
     */
    fileprivate func startAdvertising() {
        if let setting = self.streetPassSettings {
            //service uuid, name keyの追加
            let advertiseData: [String : AnyObject] = [
                CBAdvertisementDataLocalNameKey: setting.advertisementDataLocalNameKey as AnyObject,
                CBAdvertisementDataServiceUUIDsKey: setting.serviceUUID as AnyObject
            ]
            //Advertising開始
            self.peripheralManager.startAdvertising(advertiseData)
        }
    }
    
    /**
     notification処理
     */
    fileprivate func updateData() {
        if let setting = self.streetPassSettings {
            if let sendData: Data = setting.sendData.data(using: String.Encoding.utf8) {
                self.characteristicRead.value = sendData
                self.peripheralManager.updateValue(
                    sendData,
                    for: self.characteristicRead,
                    onSubscribedCentrals: nil
                )
            }
        }
    }
    
    //MARK: - CBCentralManagerDelegate
    
    /**
    scanステータス
    */
    open func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if let delegate = self.delegate {
            CentralManager().setCentralState(delegate, central: central)
        }
        switch central.state {
        case .poweredOn:
            if let setting = self.streetPassSettings {
                let options: [String : Bool] = [
                    CBCentralManagerScanOptionAllowDuplicatesKey : setting.allowDuplicates
                ]
                //scan開始
                self.centralManager.scanForPeripherals(withServices: setting.serviceUUID, options: options)
            }
        default:
            break
        }
    }
    
    /**
     CentralManager復元(アプリケーション復元時に呼ばれる)
     */
    open func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        // 復元された、接続を試みている、あるいは接続済みのペリフェラル
        if let peripherals: [CBPeripheral] = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] {
            // プロパティにセットしなおす
            for aPeripheral in peripherals {
                let aPeripheras = self.peripherals.filter({ (p: CBPeripheral) -> Bool in
                    p == aPeripheral
                })
                if aPeripheras.isEmpty {
                    self.peripherals.append(aPeripheral)
                    aPeripheral.delegate = self
                }
            }
        }
    }
    
    /**
     受信したとき
     */
    open func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let delegate = self.delegate {
            
            let deviceInfo : DeveiceInfo = DeveiceInfo()
            deviceInfo.peripheral = peripheral
            deviceInfo.advertisementData = advertisementData as [String : AnyObject]?
            deviceInfo.RSSI = RSSI
            
            if let _ = delegate.nearByDevices?(deviceInfo){}
            
        }
        if let setting = self.streetPassSettings {
            if setting.isConnect {
                peripherals.append(peripheral)
                //通知をoff
                let connectPeripheralOptions: [String : AnyObject] = [
                    CBConnectPeripheralOptionNotifyOnConnectionKey: false as AnyObject,
                    CBConnectPeripheralOptionNotifyOnDisconnectionKey: false as AnyObject,
                    CBConnectPeripheralOptionNotifyOnNotificationKey: false as AnyObject,
                ]
                //発見したペリフェラルへの接続を開始
                self.centralManager.connect(peripheral, options: connectPeripheralOptions)
            }
        }
    }
    
    /**
     ペリフェラルに接続したとき
     */
    open func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let delegate = self.delegate {
            let connectedDeviceInfo : ConnectedDeviceInfo = ConnectedDeviceInfo()
            connectedDeviceInfo.status = ConnectedDeviceStatus.success
            connectedDeviceInfo.peripheral = peripheral
            if let _ = delegate.deviceConnectedState?(connectedDeviceInfo){}
        }
        if let setting = self.streetPassSettings {
            //サービス探索のためのdelegate
            peripheral.delegate = self
            //サービス探索開始
            peripheral.discoverServices(setting.serviceUUID)
        }
    }
    
    /**
     ペリフェラルから切れたとき
     */
    open func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let delegate = self.delegate {
            let connectedDeviceInfo : ConnectedDeviceInfo = ConnectedDeviceInfo()
            connectedDeviceInfo.status = ConnectedDeviceStatus.disConected
            connectedDeviceInfo.peripheral = peripheral
            if let _ = delegate.deviceConnectedState?(connectedDeviceInfo){}
        }
        //peripheralの配列から削除
        peripherals = peripherals.filter { $0 != peripheral }
    }
    
    /**
     ペリフェラルの接続に失敗したとき
     */
    open func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let delegate = self.delegate {
            let connectedDeviceInfo : ConnectedDeviceInfo = ConnectedDeviceInfo()
            connectedDeviceInfo.status = ConnectedDeviceStatus.failure
            connectedDeviceInfo.peripheral = peripheral
            if let _ = delegate.deviceConnectedState?(connectedDeviceInfo){}
        }
        //peripheralの配列から削除
        peripherals = peripherals.filter { $0 != peripheral }
    }
    
    //MARK: - CBPeripheralManagerDelegate
    
    /**
    peripheral 復元時に呼ばれる
    */
    open func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
     
    }
    
    /**
     peripheralのserviceに追加時に呼ばれる
     */
    open func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        if error != nil {
            if let delegate = self.delegate {
                delegate.streetPassError(error!)
            }
            return
        }
        updateData()
        //Advertising開始
        startAdvertising()
        if let delegate = self.delegate {
            if let _ = delegate.peripheralDidAddService?() {}
        }
    }
    
    /**
     peripheral managerの状態変化
     */
    open func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        if let delegate = self.delegate {
            CentralManager().setPeripheralState(delegate, peripheral: peripheral)
        }
        switch peripheral.state {
        case .poweredOn:
            if let setting = self.streetPassSettings {
                let service = CBMutableService(type: setting.serviceUUID[0], primary: true)
                
                self.characteristicRead = CBMutableCharacteristic(
                    type: setting.readCharacteristicUUID[0],
                    properties: [
                        CBCharacteristicProperties.read,
                        CBCharacteristicProperties.notify,
                    ], value: nil, permissions: [CBAttributePermissions.readable]
                )
                
                self.characteristicWrite = CBMutableCharacteristic(
                    type: setting.writeCharacteristicUUID[0],
                    properties: [
                        CBCharacteristicProperties.write
                    ],
                    value: nil,
                    permissions: [CBAttributePermissions.writeable]
                )
                
                service.characteristics = [
                    characteristicRead,
                    characteristicWrite
                ]
                
                self.peripheralManager.add(service)
            }
        default:
            break
        }
    }
    
    /**
     Advertisingが開始したときに呼ばれる
     */
    @objc open func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        if error != nil {
            //Advertising失敗
            if let delegate = self.delegate {
                delegate.streetPassError(error!)
            }
            return
        }
        if let delegate = self.delegate {
            //Advertising成功
            if let _ = delegate.advertisingState?() {}
        }
    }
    
    /**
     read requestがあった時に呼ばれる
     */
    open func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        request.value = self.characteristicRead.value;
        //リクエストに応答
        self.peripheralManager.respond(
            to: request,
            withResult: CBATTError.Code.success
        )
    }
    
    /**
     write requestがあった時に呼ばれる
     */
    open func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        for obj in requests {
            if let request = obj as CBATTRequest! {
                self.characteristicWrite.value = request.value;
                if let data = request.characteristic.value {
                    let out: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                    if let delegate = self.delegate {
                        //値読込
                        let receivedData: ReceivedData = ReceivedData()
                        receivedData.data = out
                        delegate.receivedData(receivedData)
                    }
                }
            }
        }
        //リクエストに応答
        self.peripheralManager.respond(to: requests[0] as CBATTRequest, withResult: CBATTError.Code.success)
    }
    
    open func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        
    }
    
    open func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
    }
    
    open func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
    }
    
    //MARK: - CBPeripheralDelegate
    
    /**
    service発見時に呼ばれる
    */
    open func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if error != nil {
            //service発見失敗
            if let delegate = self.delegate {
                delegate.streetPassError(error!)
            }
            return
        }
        if let setting = streetPassSettings {
            var hasTargetService: Bool  = false
            if let services : [CBService] = peripheral.services {
                for obj in services {
                    //目的のサービスを提供していれば、キャラクタリスティック探索を開始
                    if obj.uuid.isEqual(setting.serviceUUID[0]) {
                        peripheral.discoverCharacteristics(nil, for: obj)
                        hasTargetService = true
                        break
                    }
                }
            }
            if !hasTargetService {
                //peripheralの配列から削除
                peripherals = peripherals.filter { $0 != peripheral }
            }
        }
    }
    
    /**
     characteristics発見時に呼ばれる
     */
    open func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        if error != nil {
            //characteristics発見失敗
            if let delegate = self.delegate {
                delegate.streetPassError(error!)
            }
            return
        }
        if let setting = streetPassSettings {
            if let characteristics : [CBCharacteristic] = service.characteristics {
                for obj in characteristics {
                    if obj.uuid.isEqual(setting.readCharacteristicUUID[0]) {
                        //現在値を読み込む
                        peripheral.readValue(for: obj)
                    }
                }
            }
        }
    }
    
    /**
     characteristic読み込み時に呼ばれる
     */
    open func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        
        if error != nil {
            if let delegate = self.delegate {
                delegate.streetPassError(error!)
            }
            return
        }
        
        if let delegate = self.delegate {
            if let data = characteristic.value {
                //値読込
                let out: String = NSString(data: data, encoding: String.Encoding.utf8.rawValue)! as String
                if out != "Apple Inc." {
                    let receivedData: ReceivedData = ReceivedData()
                    receivedData.peripheral = peripheral
                    receivedData.data = out
                    delegate.receivedData(receivedData)
                }
            }
        }
        
        if let setting = streetPassSettings {
            //peripheralに送信
            writeData(setting.sendData, peripheral: peripheral)
        }
    }
    
    /**
     write完了時に呼ばれる
     */
    open func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        //接続切断
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    //MARK: - Sub Methods
    
    /**
    write requestを発行する
    */
    open func writeData(_ data: String, peripheral: CBPeripheral) {
        if let sendData: Data = data.data(using: String.Encoding.utf8) {
            if let services : [CBService] = peripheral.services {
                for service in services {
                    if let characteristics: [CBCharacteristic] = service.characteristics {
                        for characteristic in characteristics {
                            if let setting = streetPassSettings {
                                if characteristic.uuid.isEqual(setting.writeCharacteristicUUID[0]) {
                                    //peripheralに情報を送る
                                    peripheral.writeValue(
                                        sendData,
                                        for: characteristic,
                                        type: CBCharacteristicWriteType.withResponse
                                    )
                                    break
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
}
