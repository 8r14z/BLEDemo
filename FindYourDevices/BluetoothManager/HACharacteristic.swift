//
//  HACharacteristic.swift
//  FindYourDevices
//
//  Created by Le Vu Hoai An on 10/10/17.
//  Copyright © 2017 Le Vu Hoai An. All rights reserved.
//

import UIKit
import CoreBluetooth

class HACharacteristic: NSObject {
    public var cbCharacteristic: CBCharacteristic!
    public var UUIDString: String!
    
    init(withCharacteristic characteristic: CBCharacteristic, UUIDString string: String) {
        super.init()
        
        self.cbCharacteristic   = characteristic
        self.UUIDString         = string
    }
    
    public func characteristicName() -> String {
        return self.cbCharacteristic.uuid.description
    }
}
