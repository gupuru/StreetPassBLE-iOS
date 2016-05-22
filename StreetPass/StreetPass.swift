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
    private var peripherals: [CBPeripheral] = []
    
    private var characteristicRead: CBMutableCharacteristic!
    private var characteristicWrite: CBMutableCharacteristic!
    
    //MARK: - init
    
    /**
    開始
    */
    public func start() {
        self.streetPassSettings = StreetPassSettings()
        initBLE()
    }
    
    /**
     開始(設定値あり)
     */
    public func start(streetPassSettings: StreetPassSettings) {
        self.streetPassSettings = streetPassSettings
        initBLE()
    }
    
    /**
     central, peripheralの初期化
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
    private func startAdvertising() {
        if let setting = self.streetPassSettings {
            //service uuid, name keyの追加
            let advertiseData: [String : AnyObject] = [
                CBAdvertisementDataLocalNameKey: setting.advertisementDataLocalNameKey,
                CBAdvertisementDataServiceUUIDsKey: setting.serviceUUID
            ]
            //Advertising開始
            self.peripheralManager.startAdvertising(advertiseData)
        }
    }
    
    /**
     notification処理
     */
    private func updateData() {
        if let setting = self.streetPassSettings {
            if let sendData: NSData = setting.sendData.dataUsingEncoding(NSUTF8StringEncoding) {
                self.characteristicRead.value = sendData
                self.peripheralManager.updateValue(
                    sendData,
                    forCharacteristic: self.characteristicRead,
                    onSubscribedCentrals: nil
                )
            }
        }
    }
    
    //MARK: - CBCentralManagerDelegate
    
    /**
    scanステータス
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
     CentralManager復元(アプリケーション復元時に呼ばれる)
     */
    public func centralManager(central: CBCentralManager, willRestoreState dict: [String : AnyObject]) {
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
    public func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if let delegate = self.delegate {
            
            let deviceInfo : DeveiceInfo = DeveiceInfo()
            deviceInfo.peripheral = peripheral
            deviceInfo.advertisementData = advertisementData
            deviceInfo.RSSI = RSSI
            
            if let _ = delegate.nearByDevices?(deviceInfo){}
            
        }
        if let setting = self.streetPassSettings {
            if setting.isConnect {
                peripherals.append(peripheral)
                //通知をoff
                let connectPeripheralOptions: [String : AnyObject] = [
                    CBConnectPeripheralOptionNotifyOnConnectionKey: false,
                    CBConnectPeripheralOptionNotifyOnDisconnectionKey: false,
                    CBConnectPeripheralOptionNotifyOnNotificationKey: false,
                ]
                //発見したペリフェラルへの接続を開始
                self.centralManager.connectPeripheral(peripheral, options: connectPeripheralOptions)
            }
        }
    }
    
    /**
     ペリフェラルに接続したとき
     */
    public func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        if let delegate = self.delegate {
            let connectedDeviceInfo : ConnectedDeviceInfo = ConnectedDeviceInfo()
            connectedDeviceInfo.status = ConnectedDeviceStatus.Success
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
    public func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let delegate = self.delegate {
            let connectedDeviceInfo : ConnectedDeviceInfo = ConnectedDeviceInfo()
            connectedDeviceInfo.status = ConnectedDeviceStatus.DisConected
            connectedDeviceInfo.peripheral = peripheral
            if let _ = delegate.deviceConnectedState?(connectedDeviceInfo){}
        }
        //peripheralの配列から削除
        peripherals = peripherals.filter { $0 != peripheral }
    }
    
    /**
     ペリフェラルの接続に失敗したとき
     */
    public func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        if let delegate = self.delegate {
            let connectedDeviceInfo : ConnectedDeviceInfo = ConnectedDeviceInfo()
            connectedDeviceInfo.status = ConnectedDeviceStatus.Failure
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
    public func peripheralManager(peripheral: CBPeripheralManager, willRestoreState dict: [String : AnyObject]) {
     
    }
    
    /**
     peripheralのserviceに追加時に呼ばれる
     */
    public func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
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
    public func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        if let delegate = self.delegate {
            CentralManager().setPeripheralState(delegate, peripheral: peripheral)
        }
        switch peripheral.state {
        case .PoweredOn:
            if let setting = self.streetPassSettings {
                let service = CBMutableService(type: setting.serviceUUID[0], primary: true)
                
                self.characteristicRead = CBMutableCharacteristic(
                    type: setting.readCharacteristicUUID[0],
                    properties: [
                        CBCharacteristicProperties.Read,
                        CBCharacteristicProperties.Notify,
                    ], value: nil, permissions: [CBAttributePermissions.Readable]
                )
                
                self.characteristicWrite = CBMutableCharacteristic(
                    type: setting.writeCharacteristicUUID[0],
                    properties: [
                        CBCharacteristicProperties.Write
                    ],
                    value: nil,
                    permissions: [CBAttributePermissions.Writeable]
                )
                
                service.characteristics = [
                    characteristicRead,
                    characteristicWrite
                ]
                
                self.peripheralManager.addService(service)
            }
        default:
            break
        }
    }
    
    /**
     Advertisingが開始したときに呼ばれる
     */
    @objc public func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
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
    public func peripheralManager(peripheral: CBPeripheralManager, didReceiveReadRequest request: CBATTRequest) {
        request.value = self.characteristicRead.value;
        //リクエストに応答
        self.peripheralManager.respondToRequest(
            request,
            withResult: CBATTError.Success
        )
    }
    
    /**
     write requestがあった時に呼ばれる
     */
    public func peripheralManager(peripheral: CBPeripheralManager, didReceiveWriteRequests requests: [CBATTRequest]) {
        for obj in requests {
            if let request = obj as CBATTRequest! {
                self.characteristicWrite.value = request.value;
                if let data = request.characteristic.value {
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
        //リクエストに応答
        self.peripheralManager.respondToRequest(requests[0] as CBATTRequest, withResult: CBATTError.Success)
    }
    
    public func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didSubscribeToCharacteristic characteristic: CBCharacteristic) {
        
    }
    
    public func peripheralManager(peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFromCharacteristic characteristic: CBCharacteristic) {
    }
    
    public func peripheralManagerIsReadyToUpdateSubscribers(peripheral: CBPeripheralManager) {
    }
    
    //MARK: - CBPeripheralDelegate
    
    /**
    service発見時に呼ばれる
    */
    public func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
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
                    if obj.UUID.isEqual(setting.serviceUUID[0]) {
                        peripheral.discoverCharacteristics(nil, forService: obj)
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
    public func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
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
                    if obj.UUID.isEqual(setting.readCharacteristicUUID[0]) {
                        //現在値を読み込む
                        peripheral.readValueForCharacteristic(obj)
                    }
                }
            }
        }
    }
    
    /**
     characteristic読み込み時に呼ばれる
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
    public func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        //接続切断
        centralManager.cancelPeripheralConnection(peripheral)
    }
    
    //MARK: - Sub Methods
    
    /**
    write requestを発行する
    */
    public func writeData(data: String, peripheral: CBPeripheral) {
        if let sendData: NSData = data.dataUsingEncoding(NSUTF8StringEncoding) {
            if let services : [CBService] = peripheral.services {
                for service in services {
                    if let characteristics: [CBCharacteristic] = service.characteristics {
                        for characteristic in characteristics {
                            if let setting = streetPassSettings {
                                if characteristic.UUID.isEqual(setting.writeCharacteristicUUID[0]) {
                                    //peripheralに情報を送る
                                    peripheral.writeValue(
                                        sendData,
                                        forCharacteristic: characteristic,
                                        type: CBCharacteristicWriteType.WithResponse
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