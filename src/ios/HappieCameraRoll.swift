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
        let library: ALAssetsLibrary = ALAssetsLibrary()
        //run the job in a background thread
        let backgroundJob = QOS_CLASS_BACKGROUND
        let backgroundQueue = dispatch_get_global_queue(backgroundJob, 0)
        dispatch_async(backgroundQueue,
        {
            library.enumerateGroupsWithTypes(ALAssetsGroupSavedPhotos,
                usingBlock: {(group: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in

                    //All images have been fetched
                    if(group == nil){
                        //self.delegate?.cameraRollFinished("undefined")
                    }
                    else{ //Enumerate through Camera Roll
                        group.enumerateAssetsUsingBlock({ (result: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                            if(result != nil){
                                let urls: AnyObject = result.valueForProperty(ALAssetPropertyURLs)
                                urls.enumerateKeysAndObjectsUsingBlock({ (id: AnyObject!, obj: AnyObject!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                                    //generate thumbnail
                                    if obj.absoluteString!.lowercaseString.rangeOfString("mov") == nil {
                                        let url = NSURL(string: obj.absoluteString!)
                                        let data = NSData(contentsOfURL: url!)
                                        let imageData: UIImage = UIImage(data: data!)!
                                        let thumbPath = self.thumbGen.createThumbOfCamRollImage(imageData);
                                        let paths: Array<String> = [obj.absoluteString!, thumbPath]
                                        self.jsonGen.addToPathArray(paths)
                                        let jsonPaths = self.jsonGen.getFinalJSON(dest: "selection", save: true)
                                        //self.delegate?.cameraRollFinished(jsonPaths)
                                    }
                                })
                            }
                        })
                    }
                })
                {(error: NSError!) -> Void in //it broke
                    //self.delegate?.cameraRollFinished("{route:\"selection\", paths:[]}")
                }
        })
    }
}