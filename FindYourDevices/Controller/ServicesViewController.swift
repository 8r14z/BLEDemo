//
//  ServicesViewController.swift
//  FindYourDevices
//
//  Created by Le Vu Hoai An on 10/4/17.
//  Copyright © 2017 Le Vu Hoai An. All rights reserved.
//

import UIKit
import CoreBluetooth

enum ConnectPeripheralState {
    case connecting
    case connected
    case discovering
    case discovered
}

class ServicesViewController: BaseViewController {
    
    public var peripheral: HAPeripheral?
    public var isReconnecting: Bool = false
    private var _isDismissed: Bool = false
    private var _isConnecting: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let peripheral = self.peripheral {
            self._activityIndicator.startAnimating()
            self._isConnecting = true
            HABluetoothManager.shareManager.connect(peripheral: peripheral, completion: { [weak self] (Error: Error?) in
                self?._isConnecting = false
                if (Error != nil) {
                    self?._activityIndicator.stopAnimating()
                    if !(self?._isDismissed)! {
                        let alert = UIAlertController(title: "Notification", message: "Can not connect to device. Please try again later!", preferredStyle: UIAlertControllerStyle.alert)
                        let cancelAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.cancel, handler: { (action) in
                            self?.navigationController?.popViewController(animated: true)
                        })
                        alert.addAction(cancelAction)
                        self?.present(alert, animated: false, completion: nil)
                    }
                }
                else {
                    if !(self?.isReconnecting)! {
                        let alert = UIAlertController(title: nil, message: "Connected", preferredStyle: UIAlertControllerStyle.actionSheet)
                        self?.present(alert, animated: true, completion: nil)
                        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5){
                            alert.dismiss(animated: true, completion: nil)
                        }
                    }
                    HABluetoothManager.shareManager.discoverServices(peripheral, completion: { [weak self] (callBackServices: Array?) in
                        self?._activityIndicator.stopAnimating()
                        if let services = callBackServices {
                            self?._data = services
                            DispatchQueue.main.async {
                                self?._tableView.reloadData()
                            }
                        }
                    })
                }
            })
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self._isConnecting {
            if let peripheral = self.peripheral {
                HABluetoothManager.shareManager.disconnect(peripheral: peripheral, completion: nil)
            }
        }
        self._isDismissed = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: DEFAULT_CELL_IDENTIFIER)!
        
        var text = "Unknown"
        if let service = self._data?[indexPath.row] as? HAService {
            text = service.serviceName()
        }
        cell.textLabel?.text = text
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let service = self._data?[indexPath.row] as? HAService {
            let characteristicsViewController = CharacteristicsViewController()
            characteristicsViewController.title = "Characteristics"
            characteristicsViewController.service = service
            self.navigationController?.pushViewController(characteristicsViewController, animated: true)
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
