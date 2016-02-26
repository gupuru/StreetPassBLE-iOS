//
//  ViewController.swift
//  Example
//
//  Created by 新見晃平 on 2016/02/23.
//  Copyright © 2016年 kohei Niimi. All rights reserved.
//

import UIKit
import StreetPass

class ViewController: UIViewController, StreetPassDelegate, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var centralStatusUiLabel: UILabel!
    @IBOutlet weak var peripheralUiLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var advertisingStatusUiLabel: UILabel!
    @IBOutlet weak var messageUiLabel: UILabel!
    
    private var deviceInfo : [String] = []
    private let street: StreetPass = StreetPass()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        street.delegate = self
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onTouchUpInsideStartButton(sender: UIButton) {
        let streetPassSettings: StreetPassSettings = StreetPassSettings()
            .allowDuplicates(false)
            .isConnect(true)
        street.start(streetPassSettings)
        centralStatusUiLabel.text = "ready..."
        peripheralUiLabel.text = "ready..."
    }
    
    @IBAction func onTouchUpInsideStopButton(sender: UIButton) {
        street.stop()
        deviceInfo.removeAll()
        tableView.reloadData()
        centralStatusUiLabel.text = "Status"
        peripheralUiLabel.text = "Status"
    }
    
    func centralManagerState(state: CentralManagerState) {
        switch state {
        case .PoweredOn:
            centralStatusUiLabel.text = "OK"
        default:
            centralStatusUiLabel.text = "NG"
            break
        }
    }
    
    func peripheralManagerState(state: PeripheralManagerState) {
        switch state {
        case .PoweredOn:
            peripheralUiLabel.text = "OK"
            break
        default:
            peripheralUiLabel.text = "NG"
            break
        }
    }
    
    func advertisingState() {
        advertisingStatusUiLabel.text = "Now, Advertising"
    }
    
    func peripheralDidAddService() {
        messageUiLabel.text = "Service Starting"
    }
    
    func deviceConnectedState(connectedDeviceInfo : ConnectedDeviceInfo) {
        switch connectedDeviceInfo.status {
        case .Success:
            messageUiLabel.text = "Connect Success"
        case .DisConected:
            messageUiLabel.text = "DisConnect"
        case .Failure:
            messageUiLabel.text = "Connect Failer"
        }
    }

    func streetPassError(error: NSError) {
        messageUiLabel.text = error.localizedDescription
    }
    
    func receivingDevices(deveiceInfo: DeveiceInfo) {
        deviceInfo.append(deveiceInfo.deviceName)
        tableView.reloadData()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if deviceInfo.isEmpty {
            return 0
        }
        return deviceInfo.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        if !deviceInfo.isEmpty {
            cell.textLabel?.text = deviceInfo[indexPath.row]
        }
        return cell
    }
    
    func tableView(table: UITableView, didSelectRowAtIndexPath indexPath:NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated:true)
        print(deviceInfo[indexPath.row])
    }
    
}

