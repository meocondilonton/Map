

import UIKit

public class PlaceDetails: CustomStringConvertible {
    public var name: String
    public var latitude: Double
    public var longitude: Double
    public var addres: [AnyObject]
    public var countryCode: String
    public var stateCode: String
    public var raw: [String: AnyObject]
    
    public init (){
        self.name  = ""
        self.latitude = 0
        self.longitude = 0
        self.addres = []
        self.countryCode = ""
        self.stateCode = ""
        self.raw =  [:]
        
    }
    
    public init(json: [String: AnyObject]) {
        let result = json["result"] as! [String: AnyObject]
        let geometry = result["geometry"] as! [String: AnyObject]
        let location = geometry["location"] as! [String: AnyObject]
        
        self.name = result["name"] as! String
        self.latitude = location["lat"] as! Double
        self.longitude = location["lng"] as! Double
        self.addres = result["address_components"] as! [ AnyObject]
        self.countryCode =  self.addres[ self.addres.count - 1]["short_name"] as! String
        self.stateCode =  self.addres[ self.addres.count - 2]["short_name"] as! String
        self.raw = json
    }
    
    public var description: String {
        return "PlaceDetails: \(name) (\(latitude), \(longitude))"
    }
}
