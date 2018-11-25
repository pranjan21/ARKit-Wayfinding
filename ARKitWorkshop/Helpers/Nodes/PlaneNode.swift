//
//  PlaneNode.swift
//  ARKitWorkshop
//
//  Created by TSL075 on 2018-11-21.
//  Copyright © 2018 TSL075. All rights reserved.
//

import Foundation
import ARKit

class PlaneNode: SCNNode {
    
    func planeNode(baselinesPlaneAnchor: ARAnchor, startPosition: SCNVector3, destPosition: SCNVector3) -> SCNNode {
        
        let width = CGFloat(0.5)
        let vector = destPosition - startPosition
        let height = vector.length()
        let plane = SCNPlane(width: width, height: CGFloat(height))
        
        let mat = SCNMaterial()
        mat.diffuse.contents  = UIColor.cyan
        mat.specular.contents = UIColor.green
        plane.materials = [mat]
        
        let planeNode = SCNNode(geometry: plane)
        planeNode.position.x = (destPosition.x + startPosition.x) / 2
        planeNode.position.y =  baselinesPlaneAnchor.transform.columns.3.y
        planeNode.position.z = (destPosition.z + startPosition.z) / 2
        

//        planeNode.physicsBody = SCNPhysicsBody(type: .dynamic, shape: SCNPhysicsShape(geometry: plane, options: nil))
//        planeNode.physicsBody?.mass = 2.0
//        planeNode.physicsBody?.categoryBitMask = 2
//
        planeNode.eulerAngles = SCNVector3.lineEulerAngles(vector: vector)
        //        planeNode.eulerAngles.x = -.pi / 2
        
        print("--------- Start Position: \(startPosition), \n Destination Position: \(destPosition), \n planeNode: \(planeNode)")
        
        return planeNode
    }
}

