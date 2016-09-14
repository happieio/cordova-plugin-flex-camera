import Foundation
import UIKit

@objc class HappieCameraThumb : NSObject  {
    
    let filemgr = NSFileManager.defaultManager()
    var counter = 0;
    
    override init(){ super.init() }
    
    func createThumbOfImage(path: String, data: NSData) -> NSData{
            let image = UIImage(data: data)
            let size = CGSizeApplyAffineTransform(image!.size, CGAffineTransformMakeScale(0.08, 0.08))
            let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
            
            UIGraphicsBeginImageContextWithOptions(size, false, scale)
            image!.drawInRect(CGRect(origin: CGPointZero, size: size))
            
            let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            let imageData: NSData = UIImageJPEGRepresentation(scaledImage!, 0.7)!;
            filemgr.createFileAtPath(path, contents: imageData, attributes: nil)
            return imageData
    }
    
    func createThumbOfCamRollImage(image: UIImage) -> String {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docsDir = dirPaths[0]
        let mediaDir = docsDir + "media";
        let thumbDir = mediaDir + "thumb";
        let fullThumbFilePath = thumbDir + generateFileName();
        let size = CGSizeApplyAffineTransform(image.size, CGAffineTransformMakeScale(0.08, 0.08))
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageData: NSData = UIImageJPEGRepresentation(scaledImage!, 0.7)!;
        filemgr.createFileAtPath(fullThumbFilePath, contents: imageData, attributes: nil)
        
        return fullThumbFilePath
    }
    
    func generateFileName() -> String {
        counter += 1;
        let date = NSDate()
        let format = NSDateFormatter()
        format.dateFormat = "yyyyMMdd_HHmmss"
        let stringDate = format.stringFromDate(date)
        return "role_" + stringDate + "photo" + String(counter) + ".jpeg"
    }
}
