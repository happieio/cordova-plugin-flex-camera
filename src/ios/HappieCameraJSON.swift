import Foundation

@objc class HappieCameraJSON : NSObject  {
    override init(){ super.init() }
    //index 0 = original image path, 1 = thumb path
    var paths: Array<Array<String>> = []
    
    func addToPathArray(_ path:Array<String>){ paths.append(path) }

    func getFinalJSON(dest route: String, save shouldSave: Bool, counter count:Int) -> String{
        let stringCount = String(count)
        if(shouldSave){
            var json = [String: AnyObject]()
            json["route"] = route as AnyObject?
            json["count"] = stringCount as AnyObject?
            
            var pathDictionary: [Dictionary<String, String>] = [];
            for pathPair in paths {
                pathDictionary.append(["url":pathPair[0],"thumb":pathPair[1]])
            }
            
            json["paths"] = pathDictionary as AnyObject?
            if JSONSerialization.isValidJSONObject(json){
                if let data = try? JSONSerialization.data(withJSONObject: json, options: []){
                    if let jsonString = NSString(data: data, encoding: String.Encoding.utf8.rawValue){
                        resetJSON()
                        return jsonString as String
                    }
                }
            }
        }
        else{
            deleteCapturedImages()
            resetJSON()
            
            return "{\"route\":\"cancel\", \"paths\":null, \"\":" + stringCount + " }"
        }
        return "{\"route\":\"cancel\", \"paths\":null, \"\":" + stringCount + " }"
    }
    
    func resetJSON(){
        paths.removeAll(keepingCapacity: false)
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
