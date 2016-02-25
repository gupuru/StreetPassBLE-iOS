//
//  Settings.swift
//  StreetPass
//
//  Created by 新見晃平 on 2016/02/24.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import Foundation

public class Settings {
    
    struct UUID {
        var service: String = "0000180a-0000-1000-8000-00805f9b34fb"
        var characteristic: String = "00002a29-0000-1000-8000-00805f9b34fb"
    }
    
    struct ScanOptions {
        var allowDuplicates: Bool = false
    }
    
}