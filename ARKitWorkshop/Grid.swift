//
//  Grid.swift
//  NextReality_Tutorial2
//
//  Created by Ambuj Punn on 5/2/18.
//  Copyright © 2018 Next Reality. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

class Grid : SCNNode {
    
    var anchor: ARPlaneAnchor
    var planeGeometry: SCNPlane!
    
    init(anchor: ARPlaneAnchor) {
        self.anchor = anchor
        super.init()
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(anchor: ARPlaneAnchor) {
        planeGeometry.width = CGFloat(anchor.extent.x);
        planeGeometry.height = CGFloat(anchor.extent.z);
        position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        
        let planeNode = self.childNodes.first!
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
    }
    
    private func setup() {
        planeGeometry = SCNPlane(width: CGFloat(self.anchor.extent.x), height: CGFloat(self.anchor.extent.z))
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named:"overlay_grid.png")
        
        planeGeometry.materials = [material]
        let planeNode = SCNNode(geometry: self.planeGeometry)
        planeNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: self.planeGeometry, options: nil))
        planeNode.physicsBody?.categoryBitMask = 2
        
        planeNode.position = SCNVector3Make(anchor.center.x, 0, anchor.center.z);
        planeNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0);

        addChildNode(planeNode)
    }
    
     static func pathNode(startPosition: SCNVector3, destinationPosition: SCNVector3, width: CGFloat = 0.25) -> SCNNode {
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "petal.png")
        
        var pathGeometry: SCNPlane!
        
        let vector = destinationPosition - startPosition
        let heightCalculated = vector.length()
        
        pathGeometry = SCNPlane(width: width, height: CGFloat(heightCalculated))
        pathGeometry.materials = [material]
        
        let pathNode = SCNNode(geometry: pathGeometry)
        pathNode.physicsBody = SCNPhysicsBody(type: .static, shape: SCNPhysicsShape(geometry: pathGeometry, options: nil))
        pathNode.physicsBody?.categoryBitMask = 2
        
        pathNode.position =  (destinationPosition + startPosition) / 2
        pathNode.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0);
        
        return pathNode
    }
}
