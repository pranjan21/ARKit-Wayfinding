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
    func sw_roundedFrame() {
        let circleLayer = CAShapeLayer()
        circleLayer.frame = bounds
        circleLayer.strokeColor = UIColor.white.cgColor
        circleLayer.fillColor = UIColor.clear.cgColor
        circleLayer.lineWidth = 2.0
        circleLayer.path = CGPath(ellipseIn: circleLayer.bounds, transform: nil)
        
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.fillColor = UIColor.white.cgColor
        maskLayer.path = CGPath(ellipseIn: circleLayer.bounds, transform: nil)
        
        layer.mask = maskLayer
        layer.addSublayer(circleLayer)
    }
}

extension matrix_float4x4 {
    func position() -> SCNVector3 {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
}
