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
  
//        let cylinder = SCNCylinder(radius: radius, height: CGFloat(height))
//        cylinder.materials = [material]
//
        let box = SCNBox(width: 0.5, height: CGFloat(height), length: 0.1, chamferRadius: 0.05)
        box.materials = [material]
        box.firstMaterial?.transparency = 0.8
        
        let node = SCNNode(geometry: box)
        
        node.position.x = (destinationPosition.x + startPosition.x) / 2
        node.position.y = baselinePlaneAnchor.transform.columns.3.y
        node.position.z = (destinationPosition.z + startPosition.z) / 2
        
        node.eulerAngles = SCNVector3.lineEulerAngles(vector: vector)
        return node
    }
}

class LineNode: SCNNode
{
    init(
        v1: SCNVector3,  // where line starts
        v2: SCNVector3,  // where line ends
        material: [SCNMaterial] )  // any material.
    {
        super.init()
        let  height1 = self.distanceBetweenPoints2(A: v1, B: v2) as CGFloat //v1.distance(v2)
        
        position = v1
        
        let ndV2 = SCNNode()
        
        ndV2.position = v2
        
        let ndZAlign = SCNNode()
        ndZAlign.eulerAngles.x = Float.pi/2
        
        let cylgeo = SCNBox(width: 0.02, height: height1, length: 0.001, chamferRadius: 0)
        cylgeo.materials = material
        
        let ndCylinder = SCNNode(geometry: cylgeo )
        ndCylinder.position.y = Float(-height1/2) + 0.001
        ndZAlign.addChildNode(ndCylinder)
        
        addChildNode(ndZAlign)
        
        constraints = [SCNLookAtConstraint(target: ndV2)]
    }
    
    override init() {
        super.init()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func distanceBetweenPoints2(A: SCNVector3, B: SCNVector3) -> CGFloat {
        let l = sqrt(
            (A.x - B.x) * (A.x - B.x)
                +   (A.y - B.y) * (A.y - B.y)
                +   (A.z - B.z) * (A.z - B.z)
        )
        return CGFloat(l)
    }
}
