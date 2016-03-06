

import UIKit

public class Place: NSObject, AutoCompleteObject {
    public let id: String
    public let desc: String
    public var apiKey: String?
    
    public func autocompleteString() -> String! {
        return self.desc
    }
    
    override public var description: String {
        get { return desc }
    }
    
    public init(id: String, description: String) {
        self.id = id
        self.desc = description
    }
    
    public convenience init(prediction: [String: AnyObject], apiKey: String?) {
        self.init(
            id: prediction["place_id"] as! String,
            description: prediction["description"] as! String
        )
        
        self.apiKey = apiKey
    }
    
    /**
    Call Google Place Details API to get detailed information for this place
    
    Requires that Place#apiKey be set
    
    - parameter result: Callback on successful completion with detailed place information
    */
    public func getDetails(result: PlaceDetails -> ()) {
        GooglePlaceDetailsRequest(place: self).request(result)
    }
}