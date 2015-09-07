import Foundation

@objc(HappieCameraJSON) class HappieCameraJSON : NSObject  {
    override init(){ super.init() }
    //index 0 = original image path, 1 = thumb path
    var paths: Array<Array<String>> = []
    
    func addToPathArray(path:Array<String>){ paths.append(path) }

    func getFinalJSON(dest route: String, save shouldSave: Bool) -> String{
        if(shouldSave){
            var json = [String: AnyObject]()
            json["route"] = route
            
            var pathDictionary: [Dictionary<String, String>] = [];
            for pathPair in paths {
                pathDictionary.append(["url":pathPair[0],"thumb":pathPair[1]])
            }
            
            json["paths"] = pathDictionary
            if NSJSONSerialization.isValidJSONObject(json){
                if let data = NSJSONSerialization.dataWithJSONObject(json, options: nil, error: nil){
                    if let jsonString = NSString(data: data, encoding: NSUTF8StringEncoding){
                        resetJSON()
                        return jsonString as String
                    }
                }
            }
        }
        else{
            deleteCapturedImages()
            resetJSON()
            return "{\"route\":\"cancel\", \"paths\":null }"
        }
        return "{\"route\":\"cancel\", \"paths\":null }"
    }
    
    func resetJSON(){
        paths.removeAll(keepCapacity: false)
    }
    
    func deleteCapturedImages() {
        //TODO delete images in paths array
    }
}

/** EXAMPLE RESULTING JSON STRING
{
    paths: [
        {
            url:"full/size/path",
            thumb: "thumb/path"
        }
    ],
    route: "queue",// options: queue || selection
}
*/