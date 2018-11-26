//
//  ViewController.swift
//  JibestreamApp
//
//  Created by TSL075 on 2018-11-26.
//  Copyright © 2018 TSL075. All rights reserved.
//

import UIKit

class MapViewController: UIViewController, JMapDelegate, JMapUIDelegate {

    private var jMap: JMap?
    private var control: JMapController?
    private var mapUIKit: JMapUI?
    @IBOutlet weak var canvas: JMapCanvas!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupMap()
    }

    func jmapInitialized(_ error: JMapError?) {

        guard error != nil else {
            assertionFailure("Could not load the map, with error: \(String(describing: error))")
            return
        }

            self.control = self.jMap?.controller
            setupUnitsAndIcons()
            setupMapUIKit()
            setupFloorSelector()
            setupCompass()
            setupSearchBar()
    }
    
    //----------------------------------------------------------
    //Setup
    //----------------------------------------------------------
    
    private func setupMap() {
        //Create Options
        let options = JMapOptions()
        options.host = "https://demo-api.jibestream.com"
        options.clientId = "b696a4cd-36da-4a02-bd03-90556949dba4"
        options.clientSecret = "JOuYlLt7ZGaMI8CKxRUteEuBUeJiqInc6cg9Q311bW8="
        options.customerId = 136
        options.venueId = 307
        
        options.stage = self.canvas
        
        //optional
        options.clearCacheData = true
        
        //Initialize JMap
        self.jMap = JMap(options: options)
        self.jMap?.delegate = self
    }
    
    private func setupUnitsAndIcons() {
        //Enable units interactivity
        self.control?.enableLayerInteractivity(forLayerName: "Units")
        
        //Enable icon interactivity
        self.control?.enableLayerInteractivity(forLayerName: "iconsLayer")
        
        //Show Icon
        self.control?.showAllAmenities()
        self.control?.showAllPathTypes()
    }
    
    private func setupMapUIKit() {
        //Initialize UIKit
        self.mapUIKit = JMapUI(controller: self.control!, andViewController: self, andOptions: nil)
        self.mapUIKit?.delegate = self
    }
    
    private func setupFloorSelector() {
        //Load Floor selector
        let floorSelectorOption = ["position": [0.9, 0.9]]
        mapUIKit?.renderFloorSelector(options: floorSelectorOption)
    }
    
    private func setupCompass() {
        //Load Compass
        let compassOption = ["position": [0.05, 0.9], "width": 75, "height": 75] as [String: Any]
        mapUIKit?.renderCompass(options: compassOption)
    }
    
    private func setupSearchBar() {
        //Load search bar
        let searchOption = ["placeholder": "Search Bar", "maxResults": 3, "position": 0.1] as [String: Any]
        mapUIKit?.renderSearch(options: searchOption)
    }
    
    //----------------------------------------------------------
    //JMapDelegate
    //----------------------------------------------------------

    func canvas(_ canvas: JMapCanvas, scrollViewDidRotateByDegrees degrees: Float) {
        mapUIKit?.updateCompass(degrees)
    }

    
    func canvas(_ canvas: JMapCanvas, detectedTapOnElement element: Any?, at point: CGPoint) {
        if element is Shape,
            let shape = element as? Shape,
            let destination = control?.getDestinationsFrom(shape).first,
            let waypoint = control?.getWaypointsFrom(shape).first
        {
            
            //Add styling for popup
            let buttonStyle = JMapStyle()
            buttonStyle.setFill(UIColor.blue)
            
            let popupStyle = JMapStyle()
            popupStyle.setFill(UIColor.white)
            
            let titleFont = UIFont.systemFont(ofSize: 18)
            let titleFontColor = UIColor.black
            
            let subFont = UIFont.systemFont(ofSize: 12)
            let subFontColor = UIColor.gray
            
            //Add options to popup
            
            let popupOptions = ["coordinates": NSValue(cgPoint: point),
                                "titleText": destination.name,
                                "subText" : "\(waypoint.id)",
                                "titleFont" : titleFont,
                                "subFont" : subFont,
                                "showActionButton": 1,
                                "actionButtonText": "Action",
                                "actionButtonFont": UIFont.systemFont(ofSize: 15),
                                "titleFontColor": titleFontColor,
                                "subFontColor": subFontColor,
                                "actionButtonFontColor": UIColor.white,
                                "meta" : destination] as [String: Any]
            mapUIKit?.renderPopup(options: popupOptions)
           
        } else if let icon = element as? JMapIconView {
            //Get the waypoint associated to the icon
            
            let waypoint = self.control?.currentMap?.waypoints?.getById(Int(icon.waypointId)!)
            
            //Determine whether icon tapped is path type or amenity
            var pathType: JMapPathType?
            if let pathTypeId = icon.pathTypeId {
                pathType = control?.activeVenue?.pathTypes?.getById(Int(pathTypeId)!)
            }
            
            var amenity: JMapAmenity?
            if let amenityId = icon.amenityTypeId {
                amenity = control?.activeVenue?.amenities?.getById(Int(amenityId)!)
            }
            
            //Create the styles
            let backgroundStyle = JMapStyle()
            backgroundStyle.setFill(UIColor.blue)
            
            let middlegroundStyle = JMapStyle()
            middlegroundStyle.setFill(UIColor.green)
            
            let foregroundStyle = JMapStyle()
            foregroundStyle.setFill(UIColor.red)
            
            //Create iconStyle object
            let iconStyle = JMapIconStyle(styleForeground: foregroundStyle, middleground: middlegroundStyle, background: backgroundStyle)
            
            //Check if path type or amenity
            
            if let pathType = pathType,
                let waypoint = waypoint {
                control?.stylePathType(pathType, at: waypoint, withStyling: iconStyle!)
            } else if let amenity = amenity,
                let waypoint = waypoint {
                control?.styleAmenity(amenity, at: waypoint, withStyling: iconStyle!)
            }
            
        }
    }
    
    
    //----------------------------------------------------------
    //JMapUIDelegate
    //----------------------------------------------------------
    
    func actionButtonCallback(_ popup: Popup) {
        //102632
        //102626
        
        control?.clearWayfindingPath()
        let waypointFrom = control?.currentMap?.waypoints?.getById(102632)
        //        let waypointTo = control?.currentMap?.waypoints?.getById(102626)
        let destination = popup.options?["meta"] as! JMapDestination
        let waypointTo = control?.activeVenue?.maps?.getWaypointsBy(destination).first
        
        let paths = control?.wayfindBetweenWaypoint(waypointFrom!, andWaypoint: waypointTo!, withAccessibility: 100, withObstacle: nil)
        print("--- All the paths: \(paths)")
        
        
        let pathStyle = JMapStyle()
        pathStyle.setFill(UIColor.red)
        var index = 0
        
        for path in paths! {
            
            if index%2  == 0 {
                pathStyle.setFill(UIColor.yellow)
            } else {
                pathStyle.setFill(UIColor.blue)
            }
            
            index = index + 1
            control?.drawWayfindingPath(path, with: pathStyle)
            //            control?.drawWayfindingPath(path)
        }
        
    }
    
    func onSelect(_ item: Any!) {
        //Handle Search Result
        
        if item is JMapDestination
        {
            let destination = item as! JMapDestination
            
            //Check if selected destination is on the current map or not
            
            if let destinationMapId = destination.locations?.first?.mapId?.intValue, destinationMapId != control?.currentMap?.id.intValue,
                let map = self.control?.activeVenue?.maps?.getById(destinationMapId) {
                
                //Switch floors
                
                self.control?.show(map, completionHandler: { [weak self] error in
                    
                    if error != nil {
                        print ("------------ Error! \(error)")
                    }
                    
                    self?.highlightShapesAtDestination(destination: destination)
                })
                
            } else {
                //Already on the viewing floor
                highlightShapesAtDestination(destination: destination)
            }
        }
    }
    
    //----------------------------------------------------------
    //Helpers
    //----------------------------------------------------------
    
    func highlightShapesAtDestination(destination: JMapDestination) {
        //Get shapes from the destination
        
        self.control?.getUnitsFrom(destination, completionHandler: { [weak self] (shapes, error) in
            if let bounds = shapes.first?.pathFrame {
                
                self?.control?.fitBounds(inView: bounds)
                
                //Highlight the unit
                let highlight = JMapStyle()
                highlight.setFill(UIColor.blue)
                
                //Apply color to shape
                self?.control?.styleShapes(shapes, withStyling: highlight)
            }
        })
    }
}

