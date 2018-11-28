//
//  LineNode.swift
//  ARKitWorkshop
//
//  Created by TSL075 on 2018-11-21.
//  Copyright © 2018 TSL075. All rights reserved.
//

import Foundation
import ARKit

extension SCNNode {
    static func lineNode(baselinePlaneAnchor:ARAnchor, startPosition: SCNVector3, destinationPosition: SCNVector3, radius: CGFloat = 0.2) -> SCNNode {
        let vector = destinationPosition - startPosition
        let height = vector.length()
        
        let material = SCNMaterial()
        material.diffuse.contents  = UIColor.cyan
        material.specular.contents = UIColor.green

        let box = SCNBox(width: 0.5, height: CGFloat(height), length: 0.1, chamferRadius: 0.05)
        box.materials = [material]
        box.firstMaterial?.transparency = 0.5
        
        let node = SCNNode(geometry: box)
        
        node.position.x = (destinationPosition.x + startPosition.x) / 2
        node.position.y = baselinePlaneAnchor.transform.columns.3.y
        node.position.z = (destinationPosition.z + startPosition.z) / 2
        
        node.eulerAngles = SCNVector3.lineEulerAngles(vector: vector)
        return node
    }
    
    static func lineNode(of length: CGFloat) -> SCNNode {
        
        print("--------------- Length is: \(length)")
        let height: CGFloat = 0.03
        
        let material = SCNMaterial()
        material.diffuse.contents  = UIColor.blue
        material.specular.contents = UIColor.green
        
        let box = SCNBox(width: 0.5, height: height, length: length, chamferRadius: 0.05)
        box.materials = [material]
        box.firstMaterial?.transparency = 0.7
        box.firstMaterial?.blendMode = .multiply
        
        let boxNode = SCNNode(geometry: box)
        // Position the bottom of the box to rest flat against the ground
        boxNode.position.y = Float(height) / 2.0
        // Position the start of the box at the origin
        boxNode.position.z = -Float(length) / 2.0
        
        let arrowPlane = SCNBox(width: 0.5, height: 0.01, length: 0.5, chamferRadius: 0.05)
        let clearMaterial = SCNMaterial()
        clearMaterial.diffuse.contents = UIColor.clear

        let arrowMaterial = SCNMaterial()
        arrowMaterial.diffuse.contents = UIImage.init(imageLiteralResourceName: "arrow-up-4")
        
        //[back, right, front, left, bottom, top]
        arrowPlane.materials = [clearMaterial,clearMaterial, clearMaterial, clearMaterial, clearMaterial, arrowMaterial]
        let arrowNode = SCNNode(geometry: arrowPlane)
        
//        arrowNode.eulerAngles.x = Float.pi/2 //SCNVector3(Double.pi/2, 0, 0)
        // Position the bottom of the box to rest flat against the ground
        arrowNode.eulerAngles.x = Float.pi
        arrowNode.position.y = Float(height) / 2.0
//        // Position the start of the box at the origin
//        arrowNode.position.z = -Float(length) / 2.0
        boxNode.addChildNode(arrowNode)
        
        return boxNode
    }
}

