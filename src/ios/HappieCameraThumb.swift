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

    func createThumbAtPathWithName(name:String) -> Bool{
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0]
        let cacheDir = docsDir + "/mainCache/";
        let fullFilePath = cacheDir + name + "_thumb";

        let fullSizeImage = UIImage(contentsOfFile: cacheDir + name)

        let size = fullSizeImage?.size.applying(CGAffineTransform(scaleX: 0.08, y: 0.08))
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen

        UIGraphicsBeginImageContextWithOptions(size!, false, scale)
        fullSizeImage?.draw(in: CGRect(origin: CGPoint.zero, size: size!))

        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        let imageData: Data = UIImageJPEGRepresentation(scaledImage!, 0.7)!;
        filemgr.createFile(atPath: fullFilePath, contents: imageData, attributes: nil)
        return true;
    }

    func createThumbOfCamRollImage(_ image: UIImage) -> String {
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0]
        let mediaDir = docsDir + "media";
        let thumbDir = mediaDir + "thumb";
        let fullThumbFilePath = thumbDir + generateFileName();
        let size = image.size.applying(CGAffineTransform(scaleX: 0.08, y: 0.08))
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let imageData: Data = UIImageJPEGRepresentation(scaledImage!, 0.7)!;
        filemgr.createFile(atPath: fullThumbFilePath, contents: imageData, attributes: nil)
        
        return fullThumbFilePath
    }
    
    func generateFileName() -> String {
        counter += 1;
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyyMMdd_HHmmss"
        let stringDate = format.string(from: date)
        return "role_" + stringDate + "photo" + String(counter) + ".jpeg"
    }
}
