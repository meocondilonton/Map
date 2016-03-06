


// MARK: - GooglePlacesRequestHelpers
class GooglePlacesRequestHelpers {
    /**
    Build a query string from a dictionary
    
    - parameter parameters: Dictionary of query string parameters
    - returns: The properly escaped query string
    */
    private class func query(parameters: [String: AnyObject]) -> String {
        var components: [(String, String)] = []
        for key in Array(parameters.keys).sort(<) {
            let value: AnyObject! = parameters[key]
            components += [(escape(key), escape("\(value)"))]
        }
        
        return (components.map{"\($0)=\($1)"} as [String]).joinWithSeparator("&")
    }
    
    private class func escape(string: String) -> String {
        let legalURLCharactersToBeEscaped: CFStringRef = ":/?&=;+!@#$()',*"
        return CFURLCreateStringByAddingPercentEscapes(nil, string, nil, legalURLCharactersToBeEscaped, CFStringBuiltInEncodings.UTF8.rawValue) as String
    }
    
     class func doRequest(url: String, params: [String: String], success: NSDictionary -> ()) {
        let request = NSMutableURLRequest(
            URL: NSURL(string: "\(url)?\(query(params))")!
        )
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            self.handleResponse(data, response: response as? NSHTTPURLResponse, error: error, success: success)
        }
        
        task.resume()
    }
    
    private class func handleResponse(data: NSData!, response: NSHTTPURLResponse!, error: NSError!, success: NSDictionary -> ()) {
        if let _ = error {
            //            println("GooglePlaces Error: \(error.localizedDescription)")
            return
        }
        
        if response == nil {
            //            println("GooglePlaces Error: No response from API")
            return
        }
        
        if response.statusCode != 200 {
            //            println("GooglePlaces Error: Invalid status code \(response.statusCode) from API")
            return
        }
        
        let json: NSDictionary = (try! NSJSONSerialization.JSONObjectWithData(
            data,
            options: NSJSONReadingOptions.MutableContainers)) as! NSDictionary
        
        if let status = json["status"] as? String {
            if status != "OK" {
                //                println("GooglePlaces API Error: \(status)")
                return
            }
        }
        
        // Perform table updates on UI thread
        dispatch_async(dispatch_get_main_queue(), {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            
            success(json)
        })
    }
}
