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
    
    fileprivate let street: StreetPass = StreetPass()
    fileprivate var startStopIsOn: Bool = false
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // アラート表示の許可をもらう
        let setting = UIUserNotificationSettings(types: [.sound, .alert], categories: nil)
        UIApplication.shared.registerUserNotificationSettings(setting)
        //delegateなど
        street.delegate = self
        nameTextField.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onTouchUpInsideStartStopButton(_ sender: UIButton) {
        if !startStopIsOn {
            //buttonの背景色, 文字変更
            startStopIsOn = true
            startStopUIButton.setTitle("Stop", for: UIControlState())
            startStopUIButton.backgroundColor = Color().stop()
            logTextView.text = ""
            setLogText("Start StreetPass")
            view.endEditing(true)
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
            startStopUIButton.setTitle("Start", for: UIControlState())
            startStopUIButton.backgroundColor = Color().main()
            setLogText("Stop StreetPass")
            //bleライブラリ停止
            street.stop()
        }
    }
    
    //MARK: - StreetPassDelegate
    
    func centralManagerState(_ state: CentralManagerState) {
        switch state {
        case .poweredOn:
            setLogText("Start central manager")
        default:
            setLogText("Failure central manager")
            break
        }
    }
    
    func peripheralManagerState(_ state: PeripheralManagerState) {
        switch state {
        case .poweredOn:
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
    
    func deviceConnectedState(_ connectedDeviceInfo : ConnectedDeviceInfo) {
        if let status = connectedDeviceInfo.status {
            switch status {
            case .success:
                setLogText("Success Device Connect")
            case .disConected:
                setLogText("DisConnect Device")
            case .failure:
                setLogText("Connect Failer")
            }
        }
    }

    public func streetPassError(_ error: Error) {
        setLogText("error.localizedDescription")
    }
    
    func nearByDevices(_ deveiceInfo: DeveiceInfo) {
        setLogText("Near by device: \(deveiceInfo.deviceName)")
    }
    
    func receivedData(_ receivedData: ReceivedData) {
        if let data = receivedData.data {
            setLogText("Receive Data: \(data)")
            // Notificationの生成する
            let myNotification: UILocalNotification = UILocalNotification()
            myNotification.alertBody = data
            myNotification.fireDate = Date(timeIntervalSinceNow: 1)
            myNotification.timeZone = TimeZone.current
            UIApplication.shared.scheduleLocalNotification(myNotification)

        }
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        // キーボード閉じる
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: - Sub Methods
    
    /**
    textViewに値をいれる
    */
    fileprivate func setLogText(_ text: String) {
        DispatchQueue.main.async {
            let log: String = self.logTextView.text
            self.logTextView.text = log + text + "\n"
        }
    }

}

