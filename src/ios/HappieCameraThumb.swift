import Foundation
import UIKit

@objc class HappieCameraThumb : NSObject  {
    
    let filemgr = FileManager.default
    var counter = 0;
    
    override init(){ super.init() }
    
    func createThumbOfImage(_ path: String, data: Data) -> Data{
            let image = UIImage(data: data)
            let size = image!.size.applying(CGAffineTransform(scaleX: 0.08, y: 0.08))
            let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
            
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            image!.draw(in: CGRect(origin: CGPoint.zero, size: size))
            
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let imageData: Data = UIImageJPEGRepresentation(scaledImage!, 0.7)!;
            filemgr.createFile(atPath: path, contents: imageData, attributes: nil)
            return imageData
    }

    func createThumbAtPathWithName(name:String, user:String, jnid:String) -> Bool{
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0]
        
        var fullPath = "";
        var thumbPath = "";
        
        if(user.count > 0 && jnid.count > 0){
            fullPath = docsDir + "/media/" + user + "/" + jnid + "/" + name;
            thumbPath = docsDir + "/media/" + user + "/" + jnid + "/thumb/" + name;
        }
        else {
            fullPath = docsDir + "/mainCache/" + name;
            thumbPath = docsDir + "/mainCache/" + name + "_thumb";
        }
        
        let fullSizeImage:UIImage? = UIImage(contentsOfFile: fullPath)
        if(fullSizeImage == nil) {return false}
        
        let size: CGSize? = fullSizeImage?.size.applying(CGAffineTransform(scaleX: 0.08, y: 0.08))
        if(size == nil) {return false}
        
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size!, false, scale)
        fullSizeImage?.draw(in: CGRect(origin: CGPoint.zero, size: size!))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageData: Data? = UIImageJPEGRepresentation(scaledImage!, 0.7);
        if(imageData == nil) {return false}
        filemgr.createFile(atPath: thumbPath, contents: imageData, attributes: nil)
        return true;
    }
}
