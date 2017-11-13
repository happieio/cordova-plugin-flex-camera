import Foundation
import UIKit
import Raygun4iOS

@objc(HappieCamera) class HappieCamera : CDVPlugin, cameraDelegate  {

    //let cameraRoll: HappieCameraRoll = HappieCameraRoll();
    //let cameraView = HappieCameraViewController(nibName:"HappieCameraView", bundle:nil);

    @objc(writePhotoMeta:)
    func writePhotoMeta(_ command: CDVInvokedUrlCommand) {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0]
        let user = command.arguments[0] as! String
        let jnid = command.arguments[1] as! String
        let mediaDir = docsDir + "/media/" + user + "/" + jnid

        for metaGroup in command.arguments[2] as! [Any]  {
            let params:[String:Any] = metaGroup as! [String:Any]
            let fileName = params["id"] as! String
            let json = params["data"] as! String
            
            do {
                let fileURL = URL(fileURLWithPath: mediaDir + "/" + fileName)
                try json.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
            }
            catch {
                (Raygun.sharedReporter() as! Raygun).send("failed to write photo json", withReason: "unknown", withTags:nil, withUserCustomData:nil)
            }
        }
        let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: "finished writing json")
        commandDelegate!.send(pluginResult, callbackId:command.callbackId)
    }
    
    @objc(readPhotoMeta:)
    func readPhotoMeta(_ command: CDVInvokedUrlCommand) {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0]
        let user = command.arguments[0] as! String
        let jnid = command.arguments[1] as! String
        let mediaDir = docsDir + "/media/" + user + "/" + jnid
        
        let dir = try? FileManager.default.contentsOfDirectory(at: URL(string: mediaDir)!, includingPropertiesForKeys:nil, options: .skipsHiddenFiles)
        var array:[String] = [];
        do{
            for file in dir! {
                if(file.absoluteString.contains(".json")){
                    let data = try JSONSerialization.data(withJSONObject: array, options: [])
                    array.append(String(describing: data))
                }
            }
            
            let pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: String(format: "[%@]", array.joined(separator: ",")))
            commandDelegate!.send(pluginResult, callbackId:command.callbackId)
        }
        catch{
            (Raygun.sharedReporter() as! Raygun).send("failed to read photo json", withReason: "Failure in readPhotoMeta iOS", withTags:nil, withUserCustomData:nil)
        }
    }

    @objc(openCamera:)
    func openCamera(_ command: CDVInvokedUrlCommand) {
        let qual = command.arguments[0] as! Int
        let user = command.arguments[1] as! String
        let jnid = command.arguments[2] as! String
        HappieCameraJSON.setQuality(newQual: qual);
        HappieCameraJSON.setUser(newUser: user);
        HappieCameraJSON.setJnid(jnid: jnid);
        let cameraVC: HappieCameraViewController = HappieCameraViewController(nibName:"HappieCameraView", bundle:nil);
        cameraVC.delegate = self;
        cameraVC.modalTransitionStyle = UIModalTransitionStyle.coverVertical;
        cameraVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen;
        self.viewController?.present(cameraVC, animated: true, completion:nil)
    }

    @objc(getProcessingCount:)
    func getProcessingCount(_ command: CDVInvokedUrlCommand) {
        let user = command.arguments[0] as! String
        let jnid = command.arguments[1] as! String
        var pluginResult: CDVPluginResult;
        let message = "{\"count\":" + String(HappieCameraJSON.getProcessingCount()) + ", \"total\":" + String(HappieCameraJSON.getTotalImages(user:user, jnid:jnid)) + "}"
        pluginResult = CDVPluginResult(status: CDVCommandStatus_OK, messageAs: message)
        commandDelegate!.send(pluginResult, callbackId:command.callbackId)
    }

    func cameraFinished(_ controller: HappieCameraViewController){
        HappieCameraJSON.setUser(newUser: "user");
        HappieCameraJSON.setJnid(jnid: "jnid");
        controller.dismiss(animated: true, completion: nil);
    }

    @objc(generateThumbnail:)
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
