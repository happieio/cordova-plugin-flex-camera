import Foundation
import AssetsLibrary

//protocol cameraRollDelegate{ func cameraRollFinished(JSON: String) }


class HappieCameraRoll: CDVPlugin {

      //send data back to the plugin class
    var thumbGen = HappieCameraThumb();
    var jsonGen = HappieCameraJSON();
    //var delegate:cameraRollDelegate?

    override init(){
        super.init()
    }

    func getCameraRoll() {
        
    }
}
