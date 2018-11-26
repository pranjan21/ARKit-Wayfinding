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
import CoreLocation

//let point1 = SCNVector3Make(3.9633987,-1.0010028,-4.06933)
//let point2 = SCNVector3Make(9.339279,-0.30742192,-4.286807)

struct PathPoint {
    let point: SCNVector3
    let emoji: String
}

//➡️
//⬅️
let point1 = PathPoint(point: SCNVector3Make(0,0,-5), emoji: "➡️")
let point2 = PathPoint(point: SCNVector3Make(5,0,-5), emoji: "⬅️")

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var informationLabel: UILabel!

    var hasDrawn = false
    var grids = [Grid]()

    var cameraVector: SCNVector3?
    var destinationNode: SCNNode?

    var artScene: SCNScene!
    var destinationPositions:[SCNVector3] = []
    var planeAnchors: [ARAnchor] = []
    var pathNodes:[SCNNode] = []
    var lowestPlaneAnchor: ARAnchor?
    var starNode: SCNNode!
    //CoreLocation
    
    let locationManager = CLLocationManager()
    var locationHelper = CLLocationHelper()
    let path: [PathPoint] = [point1, point2]

    //-----------------------------------------------------------
    //MARK - View Lifecycle
    //-----------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin, .showCameras]
    }
    
    private func startSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.delegate = self
        sceneView.session.run(configuration)
        
    }
    
    func drawNode() {
        if hasDrawn {
            return
        }
        
        hasDrawn = true
        var previousPoint = cameraVector!
        
        path.enumerated().forEach { (offset, destPathPoint) in
            let destVector = destPathPoint.point
            let destination =  SCNVector3Make(cameraVector!.x + destVector.x, 0, cameraVector!.z + destVector.z)
            addNode(to: destination, emoji: destPathPoint.emoji )
            addPathToNode(with: previousPoint, destinationPosition: destination)
            previousPoint = destVector
        }
        
    }

    func addNode(to position: SCNVector3, emoji: String) {
        let arrow = makeBillboardNode(emoji.image()!)
        arrow.position = position
        arrow.scale = SCNVector3Make(0.1, 0.1, 0.1)
        arrow.castsShadow = true
        arrow.opacity = 0.7
        sceneView.scene.rootNode.addChildNode(arrow)
    }
    
    func makeBillboardNode(_ image: UIImage) -> SCNNode {
        let plane = SCNPlane(width: 10, height: 10)
        plane.firstMaterial!.diffuse.contents = image
        let node = SCNNode(geometry: plane)
        node.constraints = [SCNBillboardConstraint()]
        return node
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
        
        addPathToNode(with: cameraVector, destinationPosition: anchor.transform.position())
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

            planeAnchors.sort { (anchor1, anchor2) -> Bool in
                anchor1.transform.columns.3.y < anchor2.transform.columns.3.y
            }
            lowestPlaneAnchor = planeAnchors.first
            
            drawNode()

            DispatchQueue.main.async { [weak self] in
                self?.informationLabel.text = "Success! We have detected the floor. Please begin your wayfinding journey :D!"

                DispatchQueue.main.asyncAfter(deadline: .now() + 4, execute: {
                    self?.informationLabel.isHidden = true
                })
            }
            
            print("------------------------ Lowest Plane Anchor is: \(String(describing: lowestPlaneAnchor))")
        }
    }
    
//    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
////        let grid = self.grids.filter { grid in
////            return grid.anchor.identifier == anchor.identifier
////            }.first
////
////        guard let foundGrid = grid else {
////            return
////        }
////
////        foundGrid.update(anchor: anchor as! ARPlaneAnchor)
//
//    }
//
//    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
//
////        guard let destNode = self.destinationNode else {
////            return
////        }
////
////        addPathToNode(with: cameraVector, destinationPosition: destNode.worldPosition)
//    }
    
    //-----------------------------------------------------------
    //MARK - Helpers
    //-----------------------------------------------------------

 
    func addPathToNode(with startPosition: SCNVector3?, destinationPosition: SCNVector3?) {
        let hasDrawnToDestination = destinationPositions.contains(where: { position in
            
            return destinationPosition == position
        })
        
        guard let startPosition = startPosition,
            let destinationPosition = destinationPosition,
            !hasDrawnToDestination else {
                return
        }
        
        destinationPositions.append(destinationPosition)
        
        print("*~*~*~*~*~*~~**~ ADDING PATH TO DESTINATION NODE: \(destinationNode) \n, where destinationPositions are: \(destinationPositions)")
        addLine(startPosition: startPosition, destPosition: destinationPosition)
        
    }
    
    func addPlane(startPosition: SCNVector3, destPosition: SCNVector3) {
        guard let lowestPlaneAnchor = lowestPlaneAnchor as? ARPlaneAnchor else {
            print("---------------- Couldn't even find one plane anchor")
            return
        }
        
        let planeNode = PlaneNode().planeNode(baselinesPlaneAnchor: lowestPlaneAnchor, startPosition: startPosition, destPosition: destPosition)
        sceneView.scene.rootNode.addChildNode(planeNode)
    }
    
    func addLine(startPosition: SCNVector3, destPosition: SCNVector3) {
        guard let lowestPlaneAnchor = lowestPlaneAnchor as? ARPlaneAnchor else {
            print("---------------- Couldn't even find one plane anchor")
            return
        }
        
        
        let lineNode = SCNNode.lineNode(baselinePlaneAnchor:lowestPlaneAnchor, startPosition: startPosition, destinationPosition: destPosition)
        sceneView.scene.rootNode.addChildNode(lineNode)
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
}
