//
//  ViewController.swift
//  MapExample
//
//  Created by long nguyen on 04/03/2016.
//  Copyright © 2016 long nguyen. All rights reserved.
//

import UIKit

public struct LocationBias {
    public let latitude: Double
    public let longitude: Double
    public let radius: Int
    
    public init(latitude: Double = 0, longitude: Double = 0, radius: Int = 20000000) {
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    public var location: String {
        return "\(latitude),\(longitude)"
    }
}



public enum PlaceType: CustomStringConvertible {
    case All
    case Geocode
    case Address
    case Establishment
    case Regions
    case Cities
    
    public var description : String {
        switch self {
        case .All: return ""
        case .Geocode: return "geocode"
        case .Address: return "address"
        case .Establishment: return "establishment"
        case .Regions: return "(regions)"
        case .Cities: return "(cities)"
        }
    }
}

let GOOGLE_MAPS_START_LATITUDE = 40.761869
let GOOGLE_MAPS_START_LONGITUDE = -73.975282

class ViewController: UIViewController ,GMDraggableMarkerManagerDelegate ,CLLocationManagerDelegate {
    
    @IBOutlet weak var googleMapsView: GMSMapView!
    @IBOutlet weak var tfStart: TextFieldGrayCustom!
    @IBOutlet weak var tfEnd: TextFieldGrayCustom!
    @IBOutlet weak var btnStartCL: UIButton!
    @IBOutlet weak var btnEndCL: UIButton!
    
    private let locManager = CLLocationManager()
    private var currentLoc = CLLocationCoordinate2D()
    private var draggableMarkerManager: GMDraggableMarkerManager!
    private var mapManager = MapManager()
    private var start = CLLocationCoordinate2D(latitude: 10.799331, longitude: 106.648939)
    private var end = CLLocationCoordinate2D(latitude: 10.799331, longitude: 106.648939)
    private var markerStart:GMSMarker!
    private var markerEnd:GMSMarker!
    private var polyline:GMSPolyline?
    private var placeType: PlaceType = PlaceType.Address
    private var placesStarts = [Place]()
    private var placesEnds = [Place]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //request location
        self.requestLocationService()
        
        // Initialize the GoogleMaps view.
        self.googleMapsView.camera = GMSCameraPosition.cameraWithLatitude(GOOGLE_MAPS_START_LATITUDE, longitude: GOOGLE_MAPS_START_LONGITUDE, zoom: 12.0)
        self.googleMapsView.mapType = kGMSTypeNormal
        
        // Initialize the draggable marker manager.
        self.draggableMarkerManager = GMDraggableMarkerManager.init(mapView: self.googleMapsView, delegate: self)
        
        // Place sample marker to the map.
        markerStart = GMSMarker(position: start)
        markerStart.icon = GMSMarker.markerImageWithColor(UIColor(white: 0.2, alpha: 1.0))
        markerStart.title = "Start"
        markerStart.map = nil
        self.draggableMarkerManager.addDraggableMarker(markerStart)
        
        markerEnd = GMSMarker(position: end)
        markerEnd.icon = GMSMarker.markerImageWithColor(UIColor(red: 255.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 1.0))
        markerEnd.title = "End"
//            UIImage(named: "alternative-pin-red")
        markerEnd.map = nil
        self.draggableMarkerManager.addDraggableMarker(markerEnd)
        
        //textfield block
        self.tfStart.selectedItemHandle = {[weak self] ()->() in
            self?.btnStartCL.selected = false
            self?.start = CLLocationCoordinate2D(latitude: (self?.tfStart.currentValue as! PlaceDetails).latitude, longitude: (self?.tfStart.currentValue as! PlaceDetails).longitude)
        }
        
        self.tfEnd.selectedItemHandle = {[weak self] ()->() in
             self?.btnEndCL.selected = false
            self?.end = CLLocationCoordinate2D(latitude: (self?.tfEnd.currentValue as! PlaceDetails).latitude, longitude: (self?.tfEnd.currentValue as! PlaceDetails).longitude)
        }
        
    }
    
    func updateRouter(from from:CLLocationCoordinate2D, to:CLLocationCoordinate2D){
        mapManager.directionsUsingGoogle(from: markerStart.position, to: markerEnd.position) { (points ,route,directionInformation, boundingRegion, error) -> () in
            
            if(error != nil){
                print(error)
            }
            else{
                if let web = self.googleMapsView {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        let path = GMSPath(fromEncodedPath: points! as String)
                        self.polyline = GMSPolyline(path: path)
                        self.polyline!.map = web
                        self.markerStart.map = web
                        self.markerEnd.map = web
                        web.animateWithCameraUpdate(GMSCameraUpdate.fitBounds(GMSCoordinateBounds.init(coordinate: from, coordinate: to)))
                    }
                }
            }
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // GMDraggableMarkerManagerDelegate.
    func mapView(mapView: GMSMapView!, didBeginDraggingMarker marker: GMSMarker!) {
        if self.polyline != nil {
            self.polyline!.map = nil
        }
        
    }
    
    func mapView(mapView: GMSMapView!, didDragMarker marker: GMSMarker!) {
        print("drag" , marker.position)

    }
    
    func mapView(mapView: GMSMapView!, didEndDraggingMarker marker: GMSMarker!) {
        print("end")
        self.start = markerStart.position
        self.end = markerEnd.position
        self.updateRouter(from:  markerStart.position, to: markerEnd.position)
        
        //update textfield
        let geocoder = CLGeocoder()
        let location  = CLLocation(latitude:  marker.position.latitude , longitude: marker.position.longitude)
        
            geocoder.reverseGeocodeLocation(location) {
                [weak self] (placemarks, error) -> Void in
                if let placemarks = placemarks where placemarks.count > 0 {
                    let placemark = placemarks[0]
                    
                    let address:NSDictionary = placemark.addressDictionary!
                    if marker == self?.markerStart {
                        self?.tfStart.text =  address["Name"] as? String ?? ""
                        self?.btnStartCL.selected = false
                    }else{
                         self?.tfEnd.text =  address["Name"] as? String ?? ""
                         self?.btnEndCL.selected = false
                    }
                    
 
                }
            
        }
    }
    
    func mapView(mapView: GMSMapView!, didCancelDraggingMarker marker: GMSMarker!) {
        print("cancel")
        self.start = markerStart.position
        self.end = markerEnd.position
        self.updateRouter(from:  markerStart.position, to: markerEnd.position)
    }
    
}

//textfield delegate
extension ViewController :UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        var stringSearch:NSString = textField.text!
        stringSearch = stringSearch.stringByReplacingCharactersInRange(range, withString: string)
        
        if stringSearch == "" && textField is TextFieldGrayCustom {
            (textField as! TextFieldGrayCustom).hideDropDownView()
            return true
        }
        
        if textField == self.tfStart {
            self.tfStart.runActionAfterDelay({[weak self] () -> () in
                self?.getPlaces(stringSearch as String, succeed: { (places) -> Void in
                    self?.placesStarts = places
                    self?.tfStart.showDropDownView((self?.placesStarts)!)
                })
                })
        }
        if textField == self.tfEnd {
            self.tfEnd.runActionAfterDelay({[weak self] () -> () in
                self?.getPlaces(stringSearch as String, succeed: { (places) -> Void in
                    self?.placesEnds = places
                    self?.tfEnd.showDropDownView((self?.placesEnds)!)
                })
                })
        }
        return true
    }
    
    

    private func getPlaces(searchString: String , succeed: (places : [Place]) -> Void) {
        let params = [
            "input": searchString,
            "types": placeType.description ,
            "key": "AIzaSyCSS-rvDstFOLQoSxD9O__W2tZ8M4gjSNg"
        ]
        
        
        
        GooglePlacesRequestHelpers.doRequest(
            "https://maps.googleapis.com/maps/api/place/autocomplete/json",
            params: params
            ) { json in
                if let predictions = json["predictions"] as? Array<[String: AnyObject]> {
                    
                    let places = predictions.map { (prediction: [String: AnyObject]) -> Place in
                        return Place(prediction: prediction, apiKey: "AIzaSyCSS-rvDstFOLQoSxD9O__W2tZ8M4gjSNg")
                    }
                    succeed(places: places)
                }
        }
    }
    
}

//location manager
extension ViewController  {
    private func requestLocationService() {
        // Location service
        if (locManager.respondsToSelector(Selector("requestWhenInUseAuthorization"))) {
            
            locManager.requestWhenInUseAuthorization()
            
        }
        
        
        if (CLLocationManager.locationServicesEnabled()) {
            locManager.delegate = self
            locManager.desiredAccuracy = kCLLocationAccuracyBest
            
        }
        else
        {
            currentLoc = CLLocationCoordinate2D(latitude: 10.799331, longitude: 106.648939)
        }
    }
    
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLoc = manager.location!.coordinate
        
        if manager.location != nil {
            print("\(manager.location!.coordinate.latitude), \(manager.location!.coordinate.longitude)")
            
            if   self.btnStartCL.selected == true {
                self.tfStart.text =  "Current Location"
                self.start = self.currentLoc
            }
            
            if   self.btnEndCL.selected == true {
                self.tfEnd.text =   "Current Location"
                self.end = self.currentLoc
            }
        } else {
            print("manager is nil")
        }
        
        
        manager.stopUpdatingLocation()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        print("location update fail")
        manager.startUpdatingLocation()
        currentLoc = CLLocationCoordinate2D(latitude: 10.799331, longitude: 106.648939)
    }
    
}
//button handle
extension ViewController {
    
    @IBAction func btnSwapTouch(sender: AnyObject) {
        let temp = self.tfStart.text
        self.tfStart.text = self.tfEnd.text
        self.tfEnd.text = temp
        
        let tempLocation = self.start
        self.start = self.end
        self.end = tempLocation
    }
    
    @IBAction func btnStartCLTouch(sender: AnyObject) {
        self.btnStartCL.selected = !self.btnStartCL.selected
        self.locManager.startUpdatingLocation()
        
    }
    
    @IBAction func btnEndCLTouch(sender: AnyObject) {
        self.btnEndCL.selected = !self.btnEndCL.selected
        self.locManager.startUpdatingLocation()
    }
    
    @IBAction func btnSearchTouch(sender: AnyObject) {
        if self.polyline != nil {
            self.polyline!.map = nil
        }
        
        markerStart.position = self.start
        markerEnd.position = self.end
        self.updateRouter(from:  markerStart.position, to: markerEnd.position)
    }
    
    
}













