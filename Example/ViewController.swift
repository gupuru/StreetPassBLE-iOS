//
//  ViewController.swift
//  Example
//
//  Created by 新見晃平 on 2016/02/23.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import UIKit
import StreetPass

class ViewController: UIViewController, StreetPassDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var logTextView: UITextView!
    @IBOutlet weak var stopUiButton: UIButton!
    @IBOutlet weak var startUIButton: UIButton!
    
    private var deviceInfo : [String] = []
    private let street: StreetPass = StreetPass()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // アラート表示の許可をもらう.
        let setting = UIUserNotificationSettings(forTypes: [.Sound, .Alert], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(setting)
        
        street.delegate = self
        nameTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onTouchUpInsideStartButton(sender: UIButton) {
        
        var sendData: String = ""
        if nameTextField.text != nil {
            sendData = nameTextField.text!
        }
        
        startUIButton.enabled = false
        stopUiButton.enabled = true
        
        let streetPassSettings: StreetPassSettings = StreetPassSettings()
            .initData("108762")
            .sendData(sendData)
            .allowDuplicates(false)
            .isConnect(true)
        street.start(streetPassSettings)
        setLogText("")
        setLogText("Start StreetPass")
    }
    
    @IBAction func onTouchUpInsideStopButton(sender: UIButton) {
        street.stop()
        deviceInfo.removeAll()
        startUIButton.enabled = true
        stopUiButton.enabled = true
        setLogText("Stop StreetPass")
    }
    
    private func setLogText(text: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let log: String = self.logTextView.text
            dispatch_async(dispatch_get_main_queue()) {
                self.logTextView.text = log + text + "\n"
            }
        }
    }
    
    func centralManagerState(state: CentralManagerState) {
        switch state {
        case .PoweredOn:
            setLogText("Start central manager")
        default:
            setLogText("Failure central manager")
            break
        }
    }
    
    func peripheralManagerState(state: PeripheralManagerState) {
        switch state {
        case .PoweredOn:
            setLogText("Start peripheral manager")
            break
        default:
            setLogText("Failure peripheral manager")
            break
        }
    }
    
    func advertisingState() {
        setLogText("Now, Advertising")
    }
    
    func peripheralDidAddService() {
        setLogText("Start Service")
    }
    
    func deviceConnectedState(connectedDeviceInfo : ConnectedDeviceInfo) {
        switch connectedDeviceInfo.status {
        case .Success:
            setLogText("Success Device Connect")
        case .DisConected:
            setLogText("DisConnect Device")
        case .Failure:
            setLogText("Connect Failer")
        }
    }

    func streetPassError(error: NSError) {
        setLogText("error.localizedDescription")
    }
    
    func nearByDevices(deveiceInfo: DeveiceInfo) {
        deviceInfo.append(deveiceInfo.deviceName)
        setLogText("Near by device: \(deveiceInfo.deviceName)")
    }
    
    func receivedData(receivedData: ReceivedData) {
        setLogText("Receive Data: \(receivedData.data)")
        
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
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        // キーボード閉じる
        textField.resignFirstResponder()
        return true
    }

}

