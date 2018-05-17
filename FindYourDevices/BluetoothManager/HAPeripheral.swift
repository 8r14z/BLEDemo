//
//  HAPeripheral.swift
//  FindYourDevices
//
//  Created by Le Vu Hoai An on 10/3/17.
//  Copyright © 2017 Le Vu Hoai An. All rights reserved.
//

import UIKit
import CoreBluetooth

enum HAPeripheralState: String {

    case disconnected   = "Disconnected"
    case connecting     = "Connecting"
    case connected      = "Connected"
    case disconnecting  = "Disconnecting"
}

class HAPeripheral: NSObject {
    public var cbPeripheral: CBPeripheral!
    public var rssi: NSInteger?
    public var state: HAPeripheralState?
    public var serialNumber: String?
    
    init(withPeripheral peripheral:CBPeripheral?, state stt:HAPeripheralState?,serialNumber sn: String?, rssi RSSI:NSInteger?) {
        super.init()
        
        self.cbPeripheral   = peripheral
        self.state          = stt
        self.rssi           = RSSI
        self.serialNumber   = sn
    }
    
    class func state(with state:CBPeripheralState) -> HAPeripheralState {
        var peripheralState: HAPeripheralState!
        switch state {
        case .connected:
            peripheralState = HAPeripheralState.connected
            break
        case .disconnected:
            peripheralState = HAPeripheralState.disconnected
            break
        case .connecting:
            peripheralState = HAPeripheralState.connecting
            break
        case .disconnecting:
            peripheralState = HAPeripheralState.disconnecting
            break
        }
        
        return peripheralState
    }
    
}
