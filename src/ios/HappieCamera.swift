import Foundation
import UIKit

@objc(HappieCamera) class HappieCamera : CDVPlugin, cameraDelegate, cameraRollDelegate  {
    let cameraVC: HappieCameraViewController = HappieCameraViewController(nibName:"HappieCameraView", bundle:nil);
    
    let cameraRoll: HappieCameraRoll = HappieCameraRoll();
    //let cameraView = HappieCameraViewController(nibName:"HappieCameraView", bundle:nil);
    
    var callBackId: String = "";
    var rollCallBackId: String = "";

    func openCamera(command: CDVInvokedUrlCommand) {
        cameraVC.delegate = self;
        cameraRoll.delegate = self;
        cameraVC.modalTransitionStyle = UIModalTransitionStyle.CoverVertical;
        cameraVC.modalPresentationStyle = UIModalPresentationStyle.FullScreen;
        callBackId = command.callbackId;
        self.viewController!.presentViewController(cameraVC, animated: true, completion:nil)
    }
    
    func getCameraRoll(command: CDVInvokedUrlCommand){
        rollCallBackId = command.callbackId;
        cameraRoll.getCameraRoll()
    }
    
    func cameraFinished(controller: HappieCameraViewController, JSON: String){
        controller.dismissViewControllerAnimated(true, completion: nil);
        var pluginResult: CDVPluginResult;
        if(JSON.characters.count > 0){
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: JSON)
        }else{
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAsString: "no media captured")
        }
        commandDelegate!.sendPluginResult(pluginResult, callbackId:callBackId)
    }
    
    func cameraRollFinished(JSON: String){
        var pluginResult: CDVPluginResult;
        if(JSON.characters.count > 0){
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAsString: JSON)
            pluginResult.setKeepCallbackAsBool(true)
        }else{
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAsString: "could not find camera roll")
            pluginResult.setKeepCallbackAsBool(false)
        }
        commandDelegate!.sendPluginResult(pluginResult, callbackId:rollCallBackId)
    }
}