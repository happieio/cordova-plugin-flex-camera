import Foundation

@objc class HappieCameraJSON : NSObject  {
    override init(){ super.init() }
    //index 0 = original image path, 1 = thumb path

    static private var queue = DispatchQueue(label: "image.processing.count.queue")

    static private (set) var value: Int = 0

    static func initializeProcessingCount(){
        queue.sync { value = 0 }
    }

    static func incrementProcessingCount(){
        queue.sync { value += 1 }
    }

    static func decrementProcessingCount(){
        queue.sync { value -= 1 }
    }

    static func getProcessingCount() -> Int{
        return value;
    }

    private static var quality = 3;
    
    static func getQuality()->Int{
        return HappieCameraJSON.quality;
    }
    
    static func setQuality(newQual:Int){
        HappieCameraJSON.quality = newQual;
    }
}
