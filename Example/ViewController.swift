//
//  ViewController.swift
//  Example
//
//  Created by 新見晃平 on 2016/02/23.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import UIKit
import StreetPass
import CoreBluetooth

class ViewController: UIViewController, StreetPassDelegate {
    
    private let street: StreetPass = StreetPass()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        street.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onTouchUpInsideStartButton(sender: UIButton) {
        street.onStart()
    }
    
    @IBAction func onTouchUpInsideStopButton(sender: UIButton) {
        street.onStop()
    }
    
    func bleDidUpdateState() {
        print("よばれる")
    }
}

