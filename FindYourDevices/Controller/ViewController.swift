//
//  ViewController.swift
//  FindYourDevices
//
//  Created by Le Vu Hoai An on 10/2/17.
//  Copyright © 2017 Le Vu Hoai An. All rights reserved.
//

import UIKit
import QuartzCore
import CoreBluetooth

enum Suit: String {
    case spades = "a"
    case hearts = "b"
    case diamonds = "c"
    case clubs = "d"
}

class ViewController: UIViewController {
    
    let DEFAULT_BUTTON_SIZE: CGFloat    = 80
    let DEFAULT_CELL_IDENTIFER          = "CellID"
    let DEFAULT_MARGIN: CGFloat         = 10
    private var _scanDevicesButton: UIButton!
    private var _bluetoothManager: HABluetoothManager?
    private var _devicesTableView: UITableView!
    private var _scanningActivityIndicator: UIActivityIndicatorView!
    private var _sortBarButtonItem: UIBarButtonItem!
    private var _peripherals: Array<HAPeripheral>?
    private var _connectedPeripherals: Array<HAPeripheral>?
    private var _isSorted: Bool!
    private var _isAscending: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.setupUI()
        
        self._bluetoothManager = HABluetoothManager.shareManager
        self._bluetoothManager?.delegate = self
    }
    
    func setupUI() -> Void {
        self.navigationItem.title = "Devices"
        
        let navigationHeight:CGFloat
        if self.navigationController != nil {
            navigationHeight = (self.navigationController?.navigationBar.frame.height)! + (self.navigationController?.navigationBar.frame.origin.y)!
        }
        else {
            navigationHeight = 0
        }
        
        // Set up scan button
        self._scanDevicesButton = UIButton(type: UIButtonType.roundedRect)
        self._scanDevicesButton.frame               = CGRect(x: (self.view.frame.width/2 - DEFAULT_BUTTON_SIZE),
                                                             y: navigationHeight == 0 ? 20 : navigationHeight + DEFAULT_MARGIN ,
                                                             width: DEFAULT_BUTTON_SIZE * 2,
                                                             height: 30)
        self._scanDevicesButton.titleLabel?.font    = UIFont.systemFont(ofSize: 20)
        self._scanDevicesButton.backgroundColor     = UIColor.lightGray
        self._scanDevicesButton.setTitle("Scan", for: UIControlState.normal)
        self._scanDevicesButton.tintColor           = UIColor.white
        self._scanDevicesButton.addTarget(self, action: #selector(scanDevices), for: UIControlEvents.touchUpInside)
        self._scanDevicesButton.layer.cornerRadius  = 10
        self.view .addSubview(self._scanDevicesButton)
    
        // Set up tableview
        let tableViewY: CGFloat = self._scanDevicesButton.frame.origin.y + self._scanDevicesButton.frame.height + DEFAULT_MARGIN
        self._devicesTableView               = UITableView(frame: CGRect(x: 0,
                                                                         y: tableViewY,
                                                                         width: self.view.frame.width,
                                                                         height: self.view.frame.height - tableViewY))
        self._devicesTableView.delegate      = self
        self._devicesTableView.dataSource    = self
        self._devicesTableView .register(PeripheralTableViewCell.self, forCellReuseIdentifier: "CellID")
        self.view .addSubview(self._devicesTableView)
    
        // Set up loading indicator
        self._scanningActivityIndicator         = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
        self._scanningActivityIndicator.frame   = CGRect(x: 10, y: 10, width: 10, height: 10)
        self._scanDevicesButton .addSubview(self._scanningActivityIndicator)
        
        // Set up sort bar item
        self._sortBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "sort-ascending"),
                                                  style: UIBarButtonItemStyle.plain,
                                                  target: self,
                                                  action: #selector(sortPeriperals))
        self._sortBarButtonItem.isEnabled = false
        self._isSorted = false
        self._isAscending = true
        self.navigationItem.rightBarButtonItem = self._sortBarButtonItem
    }
    
    @objc func scanDevices() {
        
        if !self._sortBarButtonItem.isEnabled {
            self._sortBarButtonItem.isEnabled = true
        }
        
        var buttonTitle: String
        if (self._bluetoothManager?.isScanning)! {
            self._bluetoothManager?.stopScanningForPeripherals()
            self._scanningActivityIndicator .stopAnimating()
            buttonTitle = "Scan"
        }
        else {
            self._scanningActivityIndicator .startAnimating()
            self._bluetoothManager?.scanForPeripherals(completion: nil)
            buttonTitle = "Stop"
        }
        
        // Animating button
        UIView.transition(with: self._scanDevicesButton, duration: 0.05, options: UIViewAnimationOptions.transitionCrossDissolve, animations: { [weak self] in
            self?._scanDevicesButton.setTitle(buttonTitle, for: UIControlState.normal)
            }, completion: nil)
    }
    
    @objc func sortPeriperals() {
        if !self._isSorted  {
            self._isSorted = true
            if self._peripherals != nil {
                self._sortBarButtonItem.image = #imageLiteral(resourceName: "sort-descending")
                self._peripherals?.sort(by: { (one, two) -> Bool in
                    return one.rssi! < two.rssi!
                })
                self._devicesTableView.reloadSections(IndexSet(0...0), with: UITableViewRowAnimation.none)
            }
        }
        else {
            if self._peripherals != nil {
                if self._isAscending {
                    self._sortBarButtonItem.image = #imageLiteral(resourceName: "sort-ascending")
                    self._peripherals?.sort(by: { (one, two) -> Bool in
                        return one.rssi! > two.rssi!
                    })
                }
                else {
                    self._sortBarButtonItem.image = #imageLiteral(resourceName: "sort-descending")
                    self._peripherals?.sort(by: { (one, two) -> Bool in
                        return one.rssi! < two.rssi!
                    })
                }
                self._isAscending = !self._isAscending
                self._devicesTableView.reloadData()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func insert(peripheral: HAPeripheral) {
        if self._peripherals == nil {
            self._peripherals = Array()
        }
        
        let index: Int?
        
        if let peripherals = self._peripherals {
            if self._isSorted && peripherals.count > 0 {
                index = self.insertingIndex(forPeripheral: peripheral)
            }
            else {
                index = self._peripherals?.count
            }
        }
        else {
            index = 0
        }
        
        if let insertingIndex = index  {
            self._peripherals?.insert(peripheral, at: insertingIndex)
            self._devicesTableView.insertRows(at: [IndexPath.init(row: insertingIndex, section: 0)], with: UITableViewRowAnimation.none)
        }
    }
    
    private func insertingIndex(forPeripheral peripheral: HAPeripheral) -> Int {
        
        if let peripherals = self._peripherals {
            var startIndex   = peripherals.startIndex
            var endIndex     = peripherals.endIndex
            
            if endIndex != startIndex {
                endIndex -= 1
            }
            if self._isAscending {
                if peripheral.rssi! < peripherals[startIndex].rssi! {
                    return startIndex
                }
                
                if peripheral.rssi! > peripherals[endIndex].rssi! {
                    return endIndex + 1
                }
            }
            else {
                if peripheral.rssi! > peripherals[startIndex].rssi! {
                    return startIndex
                }

                if peripheral.rssi! < peripherals[endIndex].rssi! {
                    return endIndex + 1
                }
            }

            while (startIndex < endIndex) {
                let median = startIndex + (endIndex - startIndex) / 2
                
                if peripheral.rssi! == peripherals[median].rssi! {
                    return median
                }
                
                if self._isAscending {
                    if peripheral.rssi! > peripherals[median].rssi! {
                        startIndex = median + 1
                    }
                    else {
                        endIndex   = median
                    }
                }
                else {
                    if peripheral.rssi! < peripherals[median].rssi! {
                        startIndex = median + 1
                    }
                    else {
                        endIndex   = median
                    }
                }
            }
            
            assert(startIndex == endIndex)
            return startIndex
        }
        
        return 0
    }
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if self._connectedPeripherals != nil {
            return 2
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.numberOfSections == 2 {
            if section == 1 {
                return "My devices"
            }
            else {
                return "Other devices"
            }
        }
        
        return nil
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if tableView.numberOfSections == 2 {
            return 40
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            if let peripherals = self._peripherals {
                return peripherals.count
            }
        }
        else {
            if let peripherals = self._connectedPeripherals {
                return peripherals.count
            }
        }
        
        return 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:PeripheralTableViewCell = tableView.dequeueReusableCell(withIdentifier: "CellID")! as! PeripheralTableViewCell
        
        var peripheral: HAPeripheral!
        
        if indexPath.section == 0 {
            peripheral = self._peripherals![indexPath.row]
        }
        else {
            peripheral = self._connectedPeripherals![indexPath.row]
        }
        
        cell.configCell(withDeviceName: peripheral.cbPeripheral.name , rssi: peripheral.rssi,serialNumber: peripheral.serialNumber, deviceStatus: peripheral.state?.rawValue)
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var peripheral: HAPeripheral!
        
        var isReconnecting = false
        if indexPath.section == 0 {
            peripheral = self._peripherals![indexPath.row]
        }
        else {
            peripheral = self._connectedPeripherals![indexPath.row]
        }
        
        if peripheral.state == HAPeripheralState.connected {
            isReconnecting = true
        }
        
        let servicesViewController = ServicesViewController()
        servicesViewController.title = "Services"
        servicesViewController.peripheral = peripheral
        servicesViewController.isReconnecting = isReconnecting
        self.navigationController?.pushViewController(servicesViewController, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}

extension ViewController: HABluetoothManagerDelegate {
    
    func bluetoothManager(didDiscover peripheral: HAPeripheral) {
        
        self.insert(peripheral: peripheral)
    }
    
    func bluetoothManager(didUpdateRSSI peripheral: HAPeripheral) {
        if let connectedPeripherals = self._connectedPeripherals {
            if let index = connectedPeripherals.index(of: peripheral) {
                let tmp = connectedPeripherals[index]
                tmp.rssi = peripheral.rssi
                self._devicesTableView.reloadRows(at: [IndexPath.init(row: index, section: 1)], with: UITableViewRowAnimation.none)
                return
            }
        }
        
        if let peripherals = self._peripherals {
            if let index = peripherals.index(of: peripheral) {
                let tmp = peripherals[index]
                tmp.rssi = peripheral.rssi
                self._devicesTableView.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: UITableViewRowAnimation.none)
                return
            }
        }
    }
    
    func bluetoothManager(didLoad connectedPeripherals: Array<HAPeripheral>?) {
        self._connectedPeripherals = connectedPeripherals
        DispatchQueue.main.async { [weak self] in
            self?._devicesTableView.reloadData()
        }
    }
    
    func bluetoothManager(didChangePeripheralState peripheral: HAPeripheral) {

        if let connectedPeripherals = self._connectedPeripherals {
            if let index = connectedPeripherals.index(of: peripheral){
                let tmp = connectedPeripherals[index]
                tmp.rssi = peripheral.rssi
                tmp.state = peripheral.state
                
                self._devicesTableView.reloadRows(at: [IndexPath.init(row: index, section: 1)], with: UITableViewRowAnimation.none)
                return
            }
        }
        
        if let peripherals = self._peripherals {
            if let index = peripherals.index(of: peripheral) {
                let tmp = peripherals[index]
                tmp.rssi = peripheral.rssi
                tmp.state = peripheral.state
                
                self._devicesTableView.reloadRows(at: [IndexPath.init(row: index, section: 0)], with: UITableViewRowAnimation.none)
                return
            }
        }
    }
}

