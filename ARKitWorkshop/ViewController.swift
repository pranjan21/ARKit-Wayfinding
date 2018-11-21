//
//  ViewController.swift
//  ARKitWorkshop
//
//  Created by TSL075 on 2018-09-03.
//  Copyright © 2018 TSL075. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var grids = [Grid]()
    var cameraVector: SCNVector3?
    var destinationNode: SCNNode?
    var artScene: SCNScene!
    var destinationPositions:[SCNVector3] = []
    
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var distanceAmount: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        labelView.sw_roundedFrame()
        
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
        
        distanceAmount.text = "-"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isIdleTimerDisabled = true
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.delegate = self
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
//
//    func anchorToBurjKhalifa() {
//
////        25.1972° N, 55.2744° E
//
//        let anchor = ARAnchor(
//    }
//
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        guard let location = touches.first?.location(in: sceneView) else {
            return
        }
        
        let hitResultsFeaturePoints: [ARHitTestResult] = sceneView.hitTest(location, types: [.estimatedHorizontalPlane])
        
        guard let firstPoint =  hitResultsFeaturePoints.first else {
            return
        }
        
        let anchor = firstPoint.anchor ?? ARAnchor(transform: firstPoint.worldTransform)
        sceneView.session.add(anchor: anchor)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        print("----------------- Called rendered with node: \(node), anchor: \(anchor)")
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            let scene = SCNScene(named: "art.scnassets/star/star.dae")!
            let lampNode = scene.rootNode.childNode(withName: "lamp", recursively: true)!
            let starNode = scene.rootNode.childNode(withName: "star", recursively: true)!
            let lamp2Node = scene.rootNode.childNode(withName: "lamp2", recursively: true)!
            
            node.addChildNode(lampNode)
            node.addChildNode(starNode)
            node.addChildNode(lamp2Node)
            
            self.destinationNode = starNode
            
        }
        
        
        if let planeAnchor = anchor as? ARPlaneAnchor {
            let grid = Grid(anchor: anchor as! ARPlaneAnchor)
            self.grids.append(grid)
            node.addChildNode(grid)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        guard let destNode = self.destinationNode else {
            return
        }
        
        addLineToNode(with: cameraVector, destinationPosition: destNode.worldPosition)
    }
    
    func addLineToNode(with startPosition: SCNVector3?, destinationPosition: SCNVector3?) {
        
        
        let hasDrawnToDestination = destinationPositions.contains(where: { position in
            return destinationPosition == position
        })
        
        
        guard let startPosition = startPosition,
            let destinationPosition = destinationPosition,
            !hasDrawnToDestination else {
                print("----------- No start or destination point.")
                return
        }
        
        distanceAmount.text = String(destinationPosition.distance(vector: startPosition))

        destinationPositions.append(destinationPosition)
        let line2Node = SCNNode.lineNode(startPosition: startPosition, destinationPosition: destinationPosition)
        sceneView.scene.rootNode.addChildNode(line2Node)
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        let grid = self.grids.filter { grid in
            return grid.anchor.identifier == anchor.identifier
            }.first
        
        guard let foundGrid = grid else {
            return
        }
        
        foundGrid.update(anchor: anchor as! ARPlaneAnchor)
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let currentFrame = frame.camera.transform
        cameraVector = currentFrame.position()
    }
}

extension matrix_float4x4 {
    func position() -> SCNVector3 {
        return SCNVector3(columns.3.x, columns.3.y, columns.3.z)
    }
}

extension SCNNode {
    static func lineNode(startPosition: SCNVector3, destinationPosition: SCNVector3, radius: CGFloat = 0.05) -> SCNNode {
        let vector = destinationPosition - startPosition
        let height = vector.length()
        
        let material = SCNMaterial()
        material.diffuse.contents = UIImage(named: "petal.png")
        let cylinder = SCNCylinder(radius: radius, height: CGFloat(height))
        cylinder.materials = [material]
        
        let node = SCNNode(geometry: cylinder)
        
        let positionOnFloor = SCNVector3Make((destinationPosition.x + startPosition.x)/2, 0, (destinationPosition.z+startPosition.z)/2 )
        node.position = positionOnFloor //(destinationPosition + startPosition) / 2
        node.eulerAngles = SCNVector3.lineEulerAngles(vector: vector)
//        node.transform = SCNMatrix4MakeRotation(Float(-Double.pi / 2.0), 1.0, 0.0, 0.0);
        return node
    }
}


//    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
//
//        guard let cameraNode = self.cameraNode, let destinationNode = self.destinationNode else {
//            print("-------------------- It couldnt find the nodes")
//            return
//        }
////
////        guard let animationInfo = animationInfo else {
////            return
////        }
//
//    }
//
//
//    func refreshAnimationVariables(startTime: TimeInterval, initialPosition: float3, finalPosition: float3, initialOrientation: simd_quatd, finalOrientation: simd_quatd) {
//        let distance = simd_distance(initialPosition, finalPosition)
//        let speed = Float(0.15)
//
//        let animationDuration = Double(min(max(0.1, distance/speed), 2))
//
//        animationInfo = AnimationInfo(startTime: startTime,
//                                      duration: animationDuration,
//                                      initialModelPosition: initialPosition,
//                                      finalModelPosition: finalPosition,
//                                      initialModelRotation: initialOrientation,
//                                      finalModelRotation: finalOrientation)
//    }
// MARK: - ARSCNViewDelegate

/*
 // Override to create and configure nodes for anchors added to the view's session.
 func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
 let node = SCNNode()
 
 return node
 }
 
 
 
 func getCameraPosition(in view: ARSCNView) -> SCNVector3? {
 guard let lastFrame = view.session.currentFrame else {
 return nil
 }
 
 let position = lastFrame.camera.transform * float4(x: 0, y: 0, z: 0, w: 1)
 let camera: SCNVector3 = SCNVector3(position.x, position.y, position.z)
 
 return camera
 }
 */

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
