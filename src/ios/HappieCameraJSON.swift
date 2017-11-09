import Foundation
import Raygun4iOS

@objc class HappieCameraJSON : NSObject  {
    override init(){ super.init() }
    //index 0 = original image path, 1 = thumb path

    static private let filemgr = FileManager.default

    static private var queue = DispatchQueue(label: "image.processing.count.queue")

    static private (set) var count: Int = 0

    static func initializeProcessingCount(){
        queue.sync { count = 0 }
    }

    static func incrementProcessingCount(){
        queue.sync { count += 1 }
    }

    static func decrementProcessingCount(){
        queue.sync { count -= 1 }
    }

    static func getProcessingCount() -> Int{
        return count;
    }

    static func getTotalImages(user:String, jnid:String) -> Int{
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0]
        let mediaDir = docsDir + "/media/" + user + "/" + jnid
        let dir = try? FileManager.default.contentsOfDirectory(at: URL(string: mediaDir)!, includingPropertiesForKeys:nil, options: .skipsHiddenFiles)
        var count = 0;
        for file in dir! {
            if(!file.absoluteString.contains(".json")){
                count += 1
            }
        }
        return count - 1;
    }

    private static var quality = 3;
    private static var user = "nouser";
    private static var jnid = "noid";
    
    static func getQuality()->Int{
        return HappieCameraJSON.quality;
    }

    static func getUser()->String{
        return HappieCameraJSON.user;
    }

    static func getJnid()->String{
        return HappieCameraJSON.jnid;
    }
    
    static func setQuality(newQual:Int){
        HappieCameraJSON.quality = newQual;
    }

    static func setUser(newUser:String){
        HappieCameraJSON.user = newUser;
    }

    static func setJnid(jnid:String){
        HappieCameraJSON.jnid = jnid;
    }
}
