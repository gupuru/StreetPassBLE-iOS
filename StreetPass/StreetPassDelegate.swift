//
//  StreetPassDelegate.swift
//  StreetPass
//
//  Created by 新見晃平 on 2016/02/24.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import Foundation

@objc public protocol StreetPassDelegate {
    func streetPassError(_ error: Error)
    func receivedData(_ receivedData: ReceivedData)
    @objc optional func nearByDevices(_ deveiceInfo: DeveiceInfo)
    @objc optional func centralManagerState(_ state: CentralManagerState)
    @objc optional func peripheralManagerState(_ state: PeripheralManagerState)
    @objc optional func advertisingState()
    @objc optional func peripheralDidAddService()
    @objc optional func deviceConnectedState(_ connectedDeviceInfo: ConnectedDeviceInfo)
}
