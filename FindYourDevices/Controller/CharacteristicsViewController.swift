//
//  CharacteristicsViewController.swift
//  FindYourDevices
//
//  Created by Le Vu Hoai An on 10/4/17.
//  Copyright © 2017 Le Vu Hoai An. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacteristicsViewController: BaseViewController {

    public var service: HAService?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if self.service != nil {
            self._activityIndicator.startAnimating()
            HABluetoothManager.shareManager.discoverCharacteristics((self.service?.cbService!)!, completion: { [weak self] (callBackCharacteristics: Array?) in
                self?._activityIndicator.stopAnimating()
                if let characteristics = callBackCharacteristics {
                    self?._data = characteristics
                    DispatchQueue.main.async {
                        self?._tableView.reloadData()
                    }
                }
                else {
                    let alert = UIAlertController(title: "Notification", message: "No characteristics. Please try again later", preferredStyle: UIAlertControllerStyle.alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self?.present(alert, animated: false, completion: nil)
                }
            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier: DEFAULT_CELL_IDENTIFIER)!
        
        var text = "Unknown"
        if let characteristic = self._data?[indexPath.row] as? HACharacteristic {
            text = characteristic.characteristicName()
        }
        cell.textLabel?.text = text
        
        return cell
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
