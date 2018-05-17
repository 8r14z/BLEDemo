//
//  HABluetoothManager.swift
//  FindYourDevices
//
//  Created by Le Vu Hoai An on 10/3/17.
//  Copyright © 2017 Le Vu Hoai An. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol HABluetoothManagerDelegate {
    func bluetoothManager(didChangePeripheralState peripheral: HAPeripheral)
    func bluetoothManager(didLoad connectedPeripherals:Array<HAPeripheral>?)
    func bluetoothManager(didDiscover peripheral: HAPeripheral)
    func bluetoothManager(didUpdateRSSI peripheral: HAPeripheral)
}

class HABluetoothManager: NSObject {
    static  let shareManager = HABluetoothManager()
    private let CURRENT_SYSTEM_VERSION = UIDevice.current.systemVersion
    
    private var _centralManager: CBCentralManager!
    private var _peripherals: NSMutableDictionary!
    private var _connectedPeripherals:  NSDictionary?
    
    private var _scanPeripheralsBlock: ((Array<HAPeripheral>?) -> Void)?
    private var _connectPeripheralBlock: ((NSError?) -> Void)?
    private var _disconnectPeripheralBlock: (() -> Void)?
    private var _discoverServicesBlock: ((Array<HAService>?) -> Void)?
    private var _discoverCharacteristicsBlock: ((Array<HACharacteristic>?) -> Void)?
    
    public  var delegate: HABluetoothManagerDelegate?
    public  var isScanning: Bool!
    
    override init() {
        super.init()
        
        self._centralManager = CBCentralManager(delegate: self, queue: nil)
        self.isScanning = false
        self._peripherals = NSMutableDictionary()
    }
    
    // MARK: Public methods
    
    public func scanForPeripherals(completion: ((Array<HAPeripheral>?) -> Void)?) {
        
        self.isScanning = true
        self._centralManager.scanForPeripherals(withServices: nil, options: nil)
        self._scanPeripheralsBlock = completion
    }
    
    public func stopScanningForPeripherals() {
        
        self.isScanning = false
        self._centralManager.stopScan()
    }
    
    public func connect(peripheral: HAPeripheral, completion: ((Error?) -> Void)?) {
        
        self._connectPeripheralBlock = completion
        self._centralManager.connect(peripheral.cbPeripheral, options: nil)
        self.updatePeripheral(withIdentifier: peripheral.cbPeripheral.identifier, forState: HAPeripheralState.connecting)
        
        let curPeripheral = self.peripheral(forIdentifier: peripheral.cbPeripheral.identifier)
        self.perform(#selector(connectTimeout(peripheral:)), with: curPeripheral, afterDelay: TimeInterval(DEFAULT_TIME_OUT_INTERVAL))
    }
    
    public func disconnect(peripheral: HAPeripheral, completion: (() -> Void)?) {
        
        self._disconnectPeripheralBlock = completion
        self._centralManager.cancelPeripheralConnection(peripheral.cbPeripheral)
        self.updatePeripheral(withIdentifier: peripheral.cbPeripheral.identifier, forState: HAPeripheralState.disconnecting)
    }
    
    public func discoverServices(_ peripheral: HAPeripheral, completion: ((Array<HAService>?) -> Void)?) {
        
        self._discoverServicesBlock = completion
        peripheral.cbPeripheral.delegate = self
        peripheral.cbPeripheral.discoverServices(nil)
    }
    
    public func discoverCharacteristics(_ service: CBService, completion: ((Array<HACharacteristic>?) -> Void)?) {
        
        self._discoverCharacteristicsBlock = completion
        service.peripheral.discoverCharacteristics(nil, for: service)
    }
    
    // MARK: Private methods
    private func getSerialNumber(_ data: Data) -> String? {
        
        if data.count < 12 {
            return nil
        }
        guard var serialNumber = NSString(bytes: (data as NSData).bytes, length: data.count, encoding: String.Encoding.ascii.rawValue) else {
            return nil
        }
        serialNumber = serialNumber.substring(from: 2) as NSString
        serialNumber = serialNumber.substring(to: 10) as NSString
        return serialNumber as String
    }
    
    @objc private func connectTimeout(peripheral: HAPeripheral) {
        
        let curPeripheral = self.peripheral(forIdentifier: peripheral.cbPeripheral.identifier)
        
        if curPeripheral?.state == HAPeripheralState.connecting {
            self.disconnect(peripheral: peripheral) { [weak self] in
                if let completion = self?._connectPeripheralBlock {
                    completion(NSError(domain: ERROR_DOMAIN_NOT_CONNECT_PERIPHERAL,
                                       code: ERROR_CODE_NOT_CONNECT_PERIPHERAL,
                                       userInfo: [NSLocalizedDescriptionKey : "Cannot connect to peripheral"]))
                    self?._connectPeripheralBlock = nil
                }
            }
        }
    }
    
    private func peripheral(forIdentifier identifier: UUID) -> HAPeripheral? {
        
        var curPeripheral = self._connectedPeripherals?.object(forKey: identifier) as? HAPeripheral
        
        if curPeripheral == nil {
            curPeripheral = self._peripherals.object(forKey: identifier) as? HAPeripheral
        }
        
        return curPeripheral
    }
    
    private func updatePeripheral(withIdentifier identifier: UUID, forState state: HAPeripheralState) {
        
        let curPeripheral = self.peripheral(forIdentifier: identifier)
        
        if (curPeripheral != nil) {
            curPeripheral?.state = state
            delegate?.bluetoothManager(didChangePeripheralState: curPeripheral!)
        }
    }
}

extension HABluetoothManager: CBCentralManagerDelegate {

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        var isTurnOn = false
        if #available(iOS 10, *) {
            if central.state == CBManagerState.poweredOn {
                isTurnOn = true
            }
        }
        else {
            if central.state.rawValue == CBCentralManagerState.poweredOn.rawValue {
                isTurnOn = true
            }
        }
        
        if isTurnOn {
            self.retrieveConnectedPeriperals(completion: { [weak self] in
                self?.delegate?.bluetoothManager(didLoad: self?._connectedPeripherals?.allValues as! Array<HAPeripheral>?)
            })
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        self.updatePeripheral(withIdentifier: peripheral.identifier, forState: HAPeripheralState.connected)
        
        if let completion = self._connectPeripheralBlock {
            completion(nil)
            self._connectPeripheralBlock = nil
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        
        self.updatePeripheral(withIdentifier: peripheral.identifier, forState: HAPeripheralState.disconnected)
        
        if let completion = self._connectPeripheralBlock {
            completion(NSError(domain: ERROR_DOMAIN_NOT_CONNECT_PERIPHERAL,
                               code: ERROR_CODE_NOT_CONNECT_PERIPHERAL,
                               userInfo: [NSLocalizedDescriptionKey : "Cannot connect to peripheral"]))
            self._connectPeripheralBlock = nil
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        self.updatePeripheral(withIdentifier: peripheral.identifier, forState: HAPeripheralState.disconnected)
        
        if let completion = self._disconnectPeripheralBlock {
            completion()
            self._disconnectPeripheralBlock = nil
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        if let curPeripheral = self._peripherals.object(forKey: peripheral.identifier) as? HAPeripheral {
            curPeripheral.rssi = RSSI.intValue
            self.delegate?.bluetoothManager(didUpdateRSSI: curPeripheral)
        }
        else if let curPeripheral = self._connectedPeripherals?.object(forKey: peripheral.identifier) as? HAPeripheral {
            curPeripheral.rssi = RSSI.intValue
            self.delegate?.bluetoothManager(didUpdateRSSI: curPeripheral)
        }
        else {
            var serialNumber: String?
            if let data = advertisementData[ADV_DATA_KEY_MANUFACTURER_DATA] as? Data {
                serialNumber = getSerialNumber(data)
            }
            
            let curPeripheral = HAPeripheral(withPeripheral: peripheral, state: HAPeripheralState.disconnected, serialNumber: serialNumber, rssi: RSSI.intValue)
            self._peripherals.addEntries(from: [peripheral.identifier : curPeripheral])
            self.delegate?.bluetoothManager(didDiscover: curPeripheral)
        }
        
        if let completion = self._scanPeripheralsBlock {
            let curPeriperasl = self._peripherals.allValues as Array
            completion(curPeriperasl as? Array<HAPeripheral>)
        }
    }
    
    private func retrieveConnectedPeriperals(completion:(() -> Void)?) {
        DispatchQueue.global(qos: .default).async { [weak self] in
            if let connectedPeripherals = self?._centralManager.retrieveConnectedPeripherals(withServices: [CBUUID(string: DEVICE_INFORMATION_SERVICE)]) {
                let tmpConnectedPeripherals = NSMutableDictionary()
                
                for peripheral:CBPeripheral in connectedPeripherals {
                    let curState = HAPeripheralState.connected
                    let customPeripheral = HAPeripheral(withPeripheral: peripheral, state: curState, serialNumber: nil, rssi: nil)
                    tmpConnectedPeripherals.addEntries(from: [peripheral.identifier : customPeripheral])
                }
                
                if tmpConnectedPeripherals.count > 0 {
                    self?._connectedPeripherals = tmpConnectedPeripherals
                }
                
                if let completionBlock = completion {
                    completionBlock()
                }
            }
        }
    }
}

extension HABluetoothManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        if let completion = self._discoverServicesBlock {
            if let services = peripheral.services {
                var haServices = Array<HAService>()
                for service in services {
                    haServices.append(HAService.init(withService: service, UUIDString: service.uuid.uuidString))
                }
                completion(haServices)
            }
            else {
                completion(nil)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        if let completion = self._discoverCharacteristicsBlock {
            if let characteristics = service.characteristics {
                var haCharacteristics = Array<HACharacteristic>()
                for characteristic in characteristics {
                    haCharacteristics.append(HACharacteristic.init(withCharacteristic: characteristic, UUIDString: characteristic.uuid.uuidString))
                }
                completion(haCharacteristics)
            }
            else {
                completion(nil)
            }
        }
    }
}
