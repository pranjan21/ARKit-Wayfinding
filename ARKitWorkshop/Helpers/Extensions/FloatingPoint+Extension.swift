//
//  FloatingPoint+Extension.swift
//  ARKitWorkshop
//
//  Created by TSL075 on 2018-11-25.
//  Copyright © 2018 TSL075. All rights reserved.
//

import Foundation

extension FloatingPoint {
    func toRadians() -> Self {
        return self * .pi / 180
    }
    
    func toDegrees() -> Self {
        return self * 180 / .pi
    }
}
