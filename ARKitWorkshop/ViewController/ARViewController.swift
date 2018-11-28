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

class ARViewController: UIViewController, ARSCNViewDelegate, ARSessionDelegate, CLLocationManagerDelegate {
    
    @IBOutlet var sceneView: ARSCNView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var restartMapButton: UIButton!
    @IBOutlet weak var storeDescriptionView: StoreDescriptionView!
    
    @IBOutlet weak var roundedBackgroundView: UIView!
    
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
    private var previousPosition: SCNVector3?
    
    private var shouldAddDestinationAnchor: Bool = false
    
    //CoreLocation
    
    let locationManager = CLLocationManager()
    var locationHelper = CLLocationHelper()

    //-----------------------------------------------------------
    //MARK - View Lifecycle
    //-----------------------------------------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScene()
        
        informationLabel.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
        
        view.sw_roundedCorner(for: self.roundedBackgroundView)
        view.sw_shadow(for: self.storeDescriptionView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        LocalDataManager.loadLocalMapData(receivedDataHandler: receivedData)
        UIApplication.shared.isIdleTimerDisabled = true
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
//        sceneView.showsStatistics = true
        sceneView.automaticallyUpdatesLighting = true
//        sceneView.debugOptions = [.showFeaturePoints, .showWorldOrigin, .showCameras]
    }
    
    private func startSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.worldAlignment = .gravityAndHeading
        sceneView.session.delegate = self
        sceneView.session.run(configuration)
    }
    

    //-----------------------------------------------------------
    //MARK - UITouch Methods
    //-----------------------------------------------------------
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        handleSceneTap(touches: touches)
    }
    
    /// - Tag: PlaceCharacter
    func handleSceneTap(touches: Set<UITouch>) {
        
        guard let location = touches.first?.location(in: sceneView),
            let hitTestResult = sceneView
            .hitTest(location,
                     types: [.existingPlaneUsingGeometry, .estimatedHorizontalPlane])
            .first
            else { return }

        
        // Place Destination *******************
        
        if shouldAddDestinationAnchor,
            let currentFrame = sceneView.session.currentFrame {
            print("--------------- 2 touches!")
            let arCamera = currentFrame.camera
            let rotation = simd_float4x4(SCNMatrix4MakeRotation(arCamera.eulerAngles.y, 0, 1, 0))
            let transform = simd_mul(hitTestResult.worldTransform, rotation)
            let destinationAnchor = ARAnchor(name: "destination", transform: transform)
            
            sceneView.session.add(anchor: destinationAnchor)
            return
        }
        
        // Place Waypoint ************************
        let targetPosition = SCNVector3(hitTestResult.worldTransform.translation)
        
        if let previousPosition = previousPosition {
            let tNode = SCNNode()
            tNode.position = previousPosition
            tNode.look(at: targetPosition)
            let tempTransform = simd_float4x4(tNode.transform)
            
            let lineLength = previousPosition.distance(vector: targetPosition)
            let anchor = WaypointLineAnchor(length: lineLength, transform: tempTransform)
            sceneView.session.add(anchor: anchor)
        } else {
            showFeedback(text: "Saved!")
        }
        
        previousPosition = targetPosition
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
 
        if anchor.name?.hasPrefix("destination") ?? false {
            let destinationNode = makeBillboardNode("😃".image())
            node.addChildNode(destinationNode)
        } else if let waypointAnchor = anchor as? WaypointLineAnchor {
            let waypointBox = SCNNode.lineNode(of: CGFloat(waypointAnchor.length))
            node.addChildNode(waypointBox)
        } else {
            print("---------- IT DOESNT KNOW WHAT TO DO for anchor type: \(anchor)")
        }
    }
    
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
        addLine(startPosition: startPosition, destPosition: destinationPosition)
    }

    
    func addLine(startPosition: SCNVector3, destPosition: SCNVector3) {
        guard let lowestPlaneAnchor = lowestPlaneAnchor as? ARPlaneAnchor else {
            return
        }
        
        
        let lineNode = SCNNode.lineNode(baselinePlaneAnchor:lowestPlaneAnchor,
                                        startPosition: startPosition,
                                        destinationPosition: destPosition)
        sceneView.scene.rootNode.addChildNode(lineNode)
    }
    
    //-----------------------------------------------------------
    //MARK - Draw Methods
    //-----------------------------------------------------------

    func makeBillboardNode(_ image: UIImage?) -> SCNNode {
//        let plane = SCNPlane(width: 10, height: 10)
//        plane.firstMaterial?.diffuse.contents = image
//        let node = SCNNode(geometry: plane)
//        node.constraints = [SCNBillboardConstraint()]
//        return node
        
        
        //        let imagePlane = SCNPlane(width: 0.1, height: 0.1)
        //        imagePlane.firstMaterial?.diffuse.contents = UIImage.init(imageLiteralResourceName: "gucci1")
        //        let imageNode = SCNNode(geometry: imagePlane)
        //
        
        //-----------------------------------------------------
        //-----------------------------------------------------
        let titleTextGeometry = SCNText(string: "Destination!", extrusionDepth: 1.0)
        titleTextGeometry.font = UIFont.systemFont(ofSize: 4, weight: .bold)
        let textMaterials = SCNMaterial()
        textMaterials.diffuse.contents = UIColor.white
        textMaterials.transparency = 0.8
        titleTextGeometry.materials = [textMaterials]
        
//        // Update object's pivot to its center
//        // https://stackoverflow.com/questions/44828764/arkit-placing-an-scntext-at-a-particular-point-in-front-of-the-camera
        let (min, max) = titleTextGeometry.boundingBox
        let dx = min.x + 0.5 * (max.x - min.x)
        let dy = min.y + 0.5 * (max.y - min.y)
        let dz = min.z + 0.5 * (max.z - min.z)

        let textNode = SCNNode(geometry: titleTextGeometry)
        textNode.pivot = SCNMatrix4MakeTranslation(dx - 0.5, dy, dz)
        textNode.scale = SCNVector3(0.01, 0.01, 0.01)
        
//        //-----------------------------------------------------
//        //-----------------------------------------------------
//
//        let subtitleTextGeometry = SCNText(string: "Blah blah blah", extrusionDepth: 1.0)
//        subtitleTextGeometry.font = UIFont.systemFont(ofSize: 1.5, weight: .regular)
//        let subtitleTextMaterials = SCNMaterial()
//        subtitleTextMaterials.diffuse.contents = UIColor.white
//        subtitleTextMaterials.transparency = 0.8
//        subtitleTextGeometry.materials = [subtitleTextMaterials]
//
//        //        let imagePlane = SCNPlane(width: 0.1, height: 0.1)
//        //        imagePlane.firstMaterial?.diffuse.contents = UIImage.init(imageLiteralResourceName: "gucci1")
//        //        let imageNode = SCNNode(geometry: imagePlane)
//        //
//        //        // Update object's pivot to its center
//        //        // https://stackoverflow.com/questions/44828764/arkit-placing-an-scntext-at-a-particular-point-in-front-of-the-camera
//        let (min1, max1) = subtitleTextGeometry.boundingBox
//        let dx1 = min1.x + 0.5 * (max1.x - min1.x)
//        let dy1 = min1.y + 0.5 * (max1.y - min1.y)
//        let dz1 = min1.z + 0.5 * (max1.z - min1.z)
//
//        let subtitleTextNode = SCNNode(geometry: subtitleTextGeometry)
//        subtitleTextNode.pivot = SCNMatrix4MakeTranslation(dx1, dy1, dz1)
//        subtitleTextNode.scale = SCNVector3(0.01, 0.01, 0.01)
//
//        //-----------------------------------------------------
//        //-----------------------------------------------------
        
        let backgroundPlane = SCNPlane(width: 0.4, height: 0.2)
        let backgroundPlaneMaterial = SCNMaterial()
        backgroundPlaneMaterial.diffuse.contents = UIColor.black
        backgroundPlaneMaterial.transparency = 0.7
        backgroundPlane.materials = [backgroundPlaneMaterial]
        backgroundPlane.cornerRadius = 0.05
        let parentNode = SCNNode(geometry: backgroundPlane) // this node will hold our text node
        
        let yFreeConstraint = SCNBillboardConstraint()
        yFreeConstraint.freeAxes = .Y // optionally
        parentNode.constraints = [yFreeConstraint] // apply the constraint to the parent node
        
        parentNode.position = SCNVector3(0, 0, -0.5)
        parentNode.addChildNode(textNode)
//        parentNode.addChildNode(subtitleTextNode)
//        parentNode.addChildNode(imageNode)

        return parentNode
    }
    
    //-----------------------------------------------------------
    //MARK - UIButtonTapped
    //-----------------------------------------------------------
    
    @IBAction func destinationButtonTapped(_ sender: Any) {
        shouldAddDestinationAnchor.toggle()
        showFeedback(text: "\(shouldAddDestinationAnchor)", isPositive: shouldAddDestinationAnchor)
    }
    
    @IBAction func restartMapButtonTapped(_ sender: Any) {
        runNewSession()
        LocalDataManager.deleteData()
    }
    
    @IBAction func saveMapButtonTapped(_ sender: Any) {
        
        sceneView.session.getCurrentWorldMap { worldMap, error in
            guard let map = worldMap
                else { print("Error: \(error!.localizedDescription)"); return }
            
            print("Saving map with \(map.anchors.count) anchors")
            
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: false) else {
                fatalError("can't encode map")
            }
            LocalDataManager.saveData(data)

            self.showFeedback(text: "Saved!")
        }
        
    }
    
    private func runNewSession() {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    
    func receivedData(_ data: Data) {
        
        if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [ARWorldMap.classForKeyedUnarchiver()], from: data),
           
            
            let worldMap = unarchived as? ARWorldMap {
            
            // Run the session with the received world map.
            let configuration = ARWorldTrackingConfiguration()
            configuration.planeDetection = .horizontal
            configuration.initialWorldMap = worldMap
            
            print("Loading map with \(worldMap.anchors.count) anchors")
            
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            
            for anchor in worldMap.anchors {
                sceneView.session.add(anchor: anchor)
            }
            
            sceneView.setNeedsLayout()
            sceneView.setNeedsDisplay()
            
            showFeedback(text: "Loaded")
        } else if let unarchived = try? NSKeyedUnarchiver.unarchivedObject(ofClasses: [ARAnchor.classForKeyedUnarchiver()], from: data),
            let anchor = unarchived as? ARAnchor {
            sceneView.session.add(anchor: anchor)
            
            
            sceneView.setNeedsLayout()
            sceneView.setNeedsDisplay()
            
            showFeedback(text: "Loaded")

        } else {
            showFeedback(text: "Failed to load data", isPositive: false)
            print("ERROR: unknown data recieved")
        }
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
    
    func showFeedback(text: String, isPositive: Bool = true) {
        self.informationLabel.isHidden = false
        self.informationLabel.alpha = 1.0
        self.informationLabel.text = text
        self.informationLabel.backgroundColor = isPositive ? UIColor.green : UIColor.red
        
        UIView.animate(withDuration: 1.0, animations: {
            self.informationLabel.alpha = 0
        }, completion: { _ in
            self.informationLabel.isHidden = true
        })
    }
}
