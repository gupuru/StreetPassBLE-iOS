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
    @IBOutlet weak var startStopUIButton: UIButton!
    
    private let street: StreetPass = StreetPass()
    private var startStopIsOn: Bool = false
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // アラート表示の許可をもらう
        let setting = UIUserNotificationSettings(forTypes: [.Sound, .Alert], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(setting)
        //delegateなど
        street.delegate = self
        nameTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onTouchUpInsideStartStopButton(sender: UIButton) {
        if !startStopIsOn {
            //buttonの背景色, 文字変更
            startStopIsOn = true
            startStopUIButton.setTitle("Stop", forState: .Normal)
            startStopUIButton.backgroundColor = Color().stop()
            logTextView.text = ""
            setLogText("Start StreetPass")
            //textfieldに入っている文言取得
            var sendData: String = ""
            if nameTextField.text != nil {
                sendData = nameTextField.text!
            }
            //bleの設定
            let streetPassSettings: StreetPassSettings = StreetPassSettings()
                .sendData(sendData)
                .allowDuplicates(false)
                .isConnect(true)
            //bleライブラリ開始
            street.start(streetPassSettings)
        } else {
            //buttonの背景色, 文字変更
            startStopIsOn = false
            startStopUIButton.setTitle("Start", forState: .Normal)
            startStopUIButton.backgroundColor = Color().main()
            setLogText("Stop StreetPass")
            //bleライブラリ停止
            street.stop()
        }
    }
    
    //MARK: - StreetPassDelegate
    
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
        if let status = connectedDeviceInfo.status {
            switch status {
            case .Success:
                setLogText("Success Device Connect")
            case .DisConected:
                setLogText("DisConnect Device")
            case .Failure:
                setLogText("Connect Failer")
            }
        }
    }

    func streetPassError(error: NSError) {
        setLogText("error.localizedDescription")
    }
    
    func nearByDevices(deveiceInfo: DeveiceInfo) {
        setLogText("Near by device: \(deveiceInfo.deviceName)")
    }
    
    func receivedData(receivedData: ReceivedData) {
        setLogText("Receive Data: \(receivedData.data)")
        // Notificationの生成する
        let myNotification: UILocalNotification = UILocalNotification()
        myNotification.alertBody = receivedData.data
        myNotification.fireDate = NSDate(timeIntervalSinceNow: 1)
        myNotification.timeZone = NSTimeZone.defaultTimeZone()
        UIApplication.sharedApplication().scheduleLocalNotification(myNotification)
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        // キーボード閉じる
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Sub Methods
    
    /**
    textViewに値をいれる
    */
    private func setLogText(text: String) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let log: String = self.logTextView.text
            dispatch_async(dispatch_get_main_queue()) {
                self.logTextView.text = log + text + "\n"
            }
        }
    }

}

