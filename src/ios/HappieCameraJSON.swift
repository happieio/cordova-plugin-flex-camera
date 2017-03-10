import Foundation

@objc class HappieCameraJSON : NSObject  {
    override init(){ super.init() }
    //index 0 = original image path, 1 = thumb path

    private static var quality = 3;
    
    static func getQuality()->Int{
        return HappieCameraJSON.quality;
    }
    
    static func setQuality(newQual:Int){
        HappieCameraJSON.quality = newQual;
    }
}
