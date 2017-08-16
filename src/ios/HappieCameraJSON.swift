import Foundation

@objc class HappieCameraJSON : NSObject  {
    override init(){ super.init() }
    //index 0 = original image path, 1 = thumb path

    static private var queue = DispatchQueue(label: "image.processing.count.queue")

    static private (set) var count: Int = 0
    static private (set) var total: Int = 0

    static func initializeProcessingCount(){
        queue.sync { count = 0 }
    }

    static func setTotalImages(imageCount:Int){
        queue.sync { total = imageCount }
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
        return total;
    }

    private static var quality = 3;
    
    static func getQuality()->Int{
        return HappieCameraJSON.quality;
    }
    
    static func setQuality(newQual:Int){
        HappieCameraJSON.quality = newQual;
    }
}
