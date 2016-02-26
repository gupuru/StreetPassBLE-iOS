//
//  StreetPassDelegate.swift
//  StreetPass
//
//  Created by 新見晃平 on 2016/02/24.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import Foundation

@objc public protocol StreetPassDelegate {
    func streetPassError(error : NSError)
    func receivingDevices(deveiceInfo : DeveiceInfo)
    optional func centralManagerState(state : CentralManagerState)
    optional func peripheralManagerState(state : PeripheralManagerState)
    optional func advertisingState()
    optional func peripheralDidAddService()
    optional func deviceConnectedState(connectedDeviceInfo : ConnectedDeviceInfo)
}
