//
//  HAService.swift
//  FindYourDevices
//
//  Created by Le Vu Hoai An on 10/10/17.
//  Copyright © 2017 Le Vu Hoai An. All rights reserved.
//

import UIKit
import CoreBluetooth

class HAService: NSObject {
    public var cbService: CBService!
    public var UUIDString: String!
    
    init(withService service: CBService, UUIDString string: String) {
        super.init()
        
        self.cbService  = service
        self.UUIDString = string
    }
    
    public func serviceName() -> String {
        return self.cbService.uuid.description
    }
}
