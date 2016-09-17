import Foundation
import UIKit

@objc(HappieCamera) class HappieCamera : CDVPlugin, cameraDelegate  {

    //let cameraRoll: HappieCameraRoll = HappieCameraRoll();
    //let cameraView = HappieCameraViewController(nibName:"HappieCameraView", bundle:nil);

    var callBackId: String = "";
    var rollCallBackId: String = "";

    func openCamera(_ command: CDVInvokedUrlCommand) {
        //cameraRoll.delegate = self;
        let cameraVC: HappieCameraViewController = HappieCameraViewController(nibName:"HappieCameraView", bundle:nil);
        cameraVC.delegate = self;
        cameraVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical;
        cameraVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen;
        callBackId = command.callbackId;
        self.viewController?.present(cameraVC, animated: true, completion:nil)
    }

    func getCameraRoll(_ command: CDVInvokedUrlCommand){
        rollCallBackId = command.callbackId;
        //cameraRoll.getCameraRoll()
    }
    
    func cameraFinished(_ controller: HappieCameraViewController, JSON: String){
        controller.dismiss(animated: true, completion: nil);
        var pluginResult: CDVPluginResult;
        if(JSON.characters.count > 0){
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: JSON)
        }else{
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "no media captured")
        }
        commandDelegate!.send(pluginResult, callbackId:callBackId)
    }
    
    func cameraRollFinished(_ JSON: String){
        var pluginResult: CDVPluginResult;
        if(JSON.characters.count > 0){
            pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: JSON)
            pluginResult.setKeepCallbackAs(true)
        }else{
            pluginResult = CDVPluginResult(status: CDVCommandStatus_ERROR, messageAs: "could not find camera roll")
            pluginResult.setKeepCallbackAs(false)
        }
        commandDelegate!.send(pluginResult, callbackId:rollCallBackId)
    }
}
