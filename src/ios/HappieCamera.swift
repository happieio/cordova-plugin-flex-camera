import Foundation
import UIKit

@objc(HappieCamera) class HappieCamera : CDVPlugin, cameraDelegate  {

    //let cameraRoll: HappieCameraRoll = HappieCameraRoll();
    //let cameraView = HappieCameraViewController(nibName:"HappieCameraView", bundle:nil);

    func openCamera(_ command: CDVInvokedUrlCommand) {
        //cameraRoll.delegate = self;
        let params: [String: Any] = command.arguments[0] as! [String: Any]
        let qual: Int = params["quality"] as! Int
        HappieCameraJSON.setQuality(newQual: qual);
        let cameraVC: HappieCameraViewController = HappieCameraViewController(nibName:"HappieCameraView", bundle:nil);
        cameraVC.delegate = self;
        cameraVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical;
        cameraVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen;
        self.viewController?.present(cameraVC, animated: true, completion:nil)
    }

    func getProcessingCount(_ command: CDVInvokedUrlCommand) {
        var pluginResult: CDVPluginResult;
        let message = "{\"count\":" + String(HappieCameraJSON.getProcessingCount()) + ", \"total\":" + String(HappieCameraJSON.getTotalImages()) + "}"
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message)
        commandDelegate!.send(pluginResult, callbackId:command.callbackId)
    }

    func cameraFinished(_ controller: HappieCameraViewController){
        controller.dismiss(animated: true, completion: nil);
    }

    func generateThumbnail(_ command: CDVInvokedUrlCommand) {
        let name: String = (command.argument(at: 0) as AnyObject) as! String
        self.commandDelegate.run {
            let thumbGen = HappieCameraThumb();

            if(thumbGen.createThumbAtPathWithName(name: name)){
                let pluginResult: CDVPluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "true")
                self.commandDelegate!.send(pluginResult, callbackId:command.callbackId)
            }
            else {
                let pluginResult: CDVPluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "false")
                self.commandDelegate!.send(pluginResult, callbackId:command.callbackId)
            }
        }
    }
}
