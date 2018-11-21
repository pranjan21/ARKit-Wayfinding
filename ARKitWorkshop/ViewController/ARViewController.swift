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

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    var grids = [Grid]()
    var cameraVector: SCNVector3?
    var destinationNode: SCNNode?
    var artScene: SCNScene!
    var destinationPositions:[SCNVector3] = []
    var planeAnchors: [ARAnchor] = []
    var pathNodes:[SCNNode] = []
    
    var lowestPlaneAnchor: ARAnchor?
    
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var distanceAmount: UILabel!
  
    //-----------------------------------------------------------
    //MARK - View Lifecycle
    //-----------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        setupDistanceLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    //-----------------------------------------------------------
    //MARK - Setup Methods
    //-----------------------------------------------------------
    
    private func setupScene() {
        sceneView.delegate = self
        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin]
    }
    
    private func startSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
//        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.delegate = self
        sceneView.session.run(configuration)
    }
    
    private func setupDistanceLabel() {
        labelView.sw_roundedFrame()
        distanceAmount.text = "-"
    }
    
    //-----------------------------------------------------------
    //MARK - UITouch Methods
    //-----------------------------------------------------------
    
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
    
    //-----------------------------------------------------------
    //MARK - ARSessionDelegate
    //-----------------------------------------------------------
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let currentFrame = frame.camera.transform
        cameraVector = currentFrame.position()
    }
    
    //-----------------------------------------------------------
    //MARK - ARSCNViewDelegate
    //-----------------------------------------------------------
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        
        print("----------------- Called rendered with node: \(node), anchor: \(anchor)")
        if !anchor.isKind(of: ARPlaneAnchor.self) {
            
            var distanceString: String = "-"
            if let startPos = cameraVector {
                let distance = node.worldPosition.distance(vector: startPos)
                distanceString = String(distance)
            }

            let sphereNode = BaseNode(title: "Nodes")
            sphereNode.addNode(with: 0.25, and: UIColor.blue, and: distanceString)
            node.addChildNode(sphereNode)

            self.destinationNode = sphereNode
            
        }
        
        if let planeAnchor = anchor as? ARPlaneAnchor {
            planeAnchors.append(planeAnchor)
            let grid = Grid(anchor: anchor as! ARPlaneAnchor)
            self.grids.append(grid)
            node.addChildNode(grid)
            
            planeAnchors.sort { (anchor1, anchor2) -> Bool in
                anchor1.transform.columns.3.y < anchor2.transform.columns.3.y
            }
            lowestPlaneAnchor = planeAnchors.first
            
            print("------------------------ Lowest Plane Anchor is: \(lowestPlaneAnchor)")
        }
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
    
    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        
        guard let destNode = self.destinationNode else {
            return
        }
        
        addLineToNode(with: cameraVector, destinationPosition: destNode.worldPosition)
    }
    
    //-----------------------------------------------------------
    //MARK - Helpers
    //-----------------------------------------------------------
    
    func addLineToNode(with startPosition: SCNVector3?, destinationPosition: SCNVector3?) {
        
        
        let hasDrawnToDestination = destinationPositions.contains(where: { position in
            return destinationPosition == position
        })
        
        
        guard let startPosition = startPosition,
            let destinationPosition = destinationPosition,
            !hasDrawnToDestination else {
                return
        }
        
        destinationPositions.append(destinationPosition)



        addPlane(startPosition: startPosition, destPosition: destinationPosition)

        
//        let lineNode = LineNode(v1: startPosition, v2: destinationPosition, material: [mat])
//        self.sceneView.scene.rootNode.addChildNode(lineNode)

//        let line2Node = SCNNode.lineNode(startPosition: startPosition,
//                                         destinationPosition: destinationPosition)
//        sceneView.scene.rootNode.addChildNode(line2Node)
    }
    
    //-----------------------------------------------------------
    //MARK - ARSessionObserver
    //-----------------------------------------------------------
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }
    

    func addPlane(startPosition: SCNVector3, destPosition: SCNVector3) {
        guard let lowestPlaneAnchor = lowestPlaneAnchor as? ARPlaneAnchor else {
            print("---------------- Couldn't even find one plane anchor")
            return
        }

        let width = CGFloat(0.5)
        let vector = destPosition - startPosition
        let height = CGFloat(vector.length())
        let plane = SCNPlane(width: width, height: height)

        let mat = SCNMaterial()
        
        mat.diffuse.contents  = UIColor.cyan
        mat.specular.contents = UIColor.green
        
        plane.materials = [mat]

        let planeNode = SCNNode(geometry: plane)
        let position = (destPosition + startPosition) / 2

        let x = CGFloat(position.x)
        let y = CGFloat(lowestPlaneAnchor.transform.columns.3.y)
        let z = CGFloat(position.z)
        planeNode.position = SCNVector3(x,y,z)
        planeNode.eulerAngles = SCNVector3.lineEulerAngles(vector: vector)
//        planeNode.eulerAngles.x = -.pi / 2

        sceneView.scene.rootNode.addChildNode(planeNode)

        print("--------- Start Position: \(startPosition), \n Destination Position: \(destPosition), \n planeNode: \(planeNode)")
        
        //planeNode.eulerAngles.z = -.pi / 2
        //
        //
        //        let lxz = sqrtf(vector.x * vector.x + vector.z * vector.z)
        //        let pitchB = vector.y < 0 ? Float.pi - asinf(lxz/Float(height)) : asinf(lxz/Float(height))
        //        let pitch = vector.z == 0 ? pitchB : sign(vector.z) * pitchB
        
        //        planeNode.constraints = [SCNLookAtConstraint(target: destinationNode!)]
        
//        node.addChildNode(planeNode)
//        node.name = "plane"
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





//
//    func anchorToBurjKhalifa() {
//
////        25.1972° N, 55.2744° E
//
//        let anchor = ARAnchor(
//    }
//
