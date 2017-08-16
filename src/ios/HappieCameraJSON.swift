import Foundation

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

    static func getTotalImages() -> Int{
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0]
        let mediaDir = docsDir + "/media"
        let dirContents = try? filemgr.contentsOfDirectory(atPath: mediaDir)
        let count = dirContents?.count
        return count! - 1;
    }

    private static var quality = 3;
    
    static func getQuality()->Int{
        return HappieCameraJSON.quality;
    }
    
    static func setQuality(newQual:Int){
        HappieCameraJSON.quality = newQual;
    }
}
