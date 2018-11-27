//
//  Extensions.swift
//  ARKitWorkshop
//
//  Created by TSL075 on 2018-11-21.
//  Copyright © 2018 TSL075. All rights reserved.
//

import Foundation
import UIKit
import ARKit

extension UIView {
    func sw_roundedCorner(for containerView:UIView) {
        containerView.layer.cornerRadius = 8.0
        containerView.layer.masksToBounds = true
    }
    
    func sw_shadow(for containerView:UIView, roundedCorner: Bool = true, disable: Bool = false) {
        containerView.layer.cornerRadius = roundedCorner ? 4.0 : 0.0
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOpacity = disable ? 0.0 : 0.4
        containerView.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        containerView.layer.shadowRadius = 8.0
        containerView.layer.masksToBounds = false
    }
}

extension matrix_float4x4 {
    func position() -> SCNVector3 {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
}

extension float4x4 {
    var translation: float3 {
        return float3(columns.3.x, columns.3.y, columns.3.z)
    }
    
    init(translation vector: float3) {
        self.init(float4(1, 0, 0, 0),
                  float4(0, 1, 0, 0),
                  float4(0, 0, 1, 0),
                  float4(vector.x, vector.y, vector.z, 1))
    }
}
