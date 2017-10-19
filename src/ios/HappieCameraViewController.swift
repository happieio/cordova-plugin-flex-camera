import Foundation
import UIKit
import MobileCoreServices
import AVFoundation
import AssetsLibrary
import CoreMotion

@objc protocol cameraDelegate{ func cameraFinished(_ controller: HappieCameraViewController) }

@objc(HappieCameraViewController) class HappieCameraViewController : UIViewController, AVCaptureFileOutputRecordingDelegate  {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {

    }


    //MARK: Class Variables
    let captureSession = AVCaptureSession() //provides a UI context for capturing media
    var backCameraDevice: AVCaptureDevice? //represents the camera
    var stillImageInput: AVCaptureDeviceInput? //registers an input port for communicating with the connection
    var stillImageOutput: AVCaptureStillImageOutput? //output

    var canTakePhoto = true;

    let filemgr = FileManager.default
    var mediaDir: String = "";
    var thumbDir: String = "";
    var rawOrient: String = "";
    
    var flashState = 2; //0 = off, 1 = On, 2 = Auto
    var quadState = 0; //0 = UL , 1 = UR, 2 = LL, 3 = LR
    var oldOrientationValue: UIDeviceOrientation = UIDeviceOrientation.portrait;
    
     //send data back to the plugin class
    var thumbGen = HappieCameraThumb();

    var delegate:cameraDelegate?

    var uMM: CMMotionManager!

    override func viewWillAppear( _ p: Bool ) {
        super.viewWillAppear( p )
        uMM = CMMotionManager()
        uMM.accelerometerUpdateInterval = 0.2
        uMM.startAccelerometerUpdates( to: OperationQueue() ) { p, _ in
            if p != nil {
                var newRawOrient:String = "";
                   newRawOrient = abs( p!.acceleration.y ) < abs( p!.acceleration.x )
                        ?   p!.acceleration.x > 0 ? "Right"  :   "Left"
                        :   p!.acceleration.y > 0 ? "Down"   :   "Up"
                if self.rawOrient != newRawOrient {
                    self.rawOrient = newRawOrient
                }
            }
        }
        captureSession.startRunning()
    }
    
    override func viewDidDisappear( _ p: Bool ) {
        super.viewDidDisappear( p )
        uMM.stopAccelerometerUpdates()
        captureSession.stopRunning()
    }
    
    //MARK: State Functions
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?){
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil);
    }

    required init?(coder aDecoder: NSCoder) { fatalError("NSCoding not supported") }

    override func viewDidLoad(){
        super.viewDidLoad()
        var error: NSError?
        quadState = 0;
        badgeCount.text = "0"

        //let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HappieCameraViewController.LongPressDemo))
        //tapGesture.numberOfTapsRequired = 10;
        //demoButton.addGestureRecognizer(tapGesture)
        
        //create documents/media folder to contain captured images
        let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let docsDir = dirPaths[0]
        mediaDir = docsDir + "/media"
        do {
            try filemgr.createDirectory(atPath: mediaDir, withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error = error1
            print("Failed to create media dir: \(error!.localizedDescription)")
        }
        //create documents/media/thumb to contain thumbnails of captured images
        thumbDir = mediaDir + "/thumb";
        do {
            try filemgr.createDirectory(atPath: thumbDir, withIntermediateDirectories: true, attributes: nil)
        } catch let error1 as NSError {
            error = error1
            print("Failed to create thumb dir: \(error!.localizedDescription)")
        }

        let enumerator:FileManager.DirectoryEnumerator = filemgr.enumerator(atPath: mediaDir)!
        while let element = enumerator.nextObject() as? String {
            if (element.hasSuffix("jpeg") &&
                (element as NSString).contains("thumb") &&
                element != "thumb"){
                let path = mediaDir + "/" + element
                if(self.quadState == 0){
                    ULuii.image = UIImage(contentsOfFile: path)
                    self.quadState = 1
                }
                else if(self.quadState == 1){
                    URuii.image = UIImage(contentsOfFile: path)
                    self.quadState = 2
                }
                else if(self.quadState == 2){
                    LLuii.image = UIImage(contentsOfFile: path);
                    self.quadState = 3
                }
                else if(self.quadState == 3){
                    LRuii.image = UIImage(contentsOfFile: path);
                    self.quadState = 0
                }
            }
        }

        let dirContents = try? filemgr.contentsOfDirectory(atPath: mediaDir)
        let count = dirContents?.count
        badgeCount.text = String(describing: count! - 1)

        HappieCameraJSON.initializeProcessingCount();

        _ = AVCaptureDevice.devices(for: AVMediaType.video)

        let devices = AVCaptureDevice.devices()

        // Loop through all the capture devices on this phone
        for device in devices {
            // Make sure this particular device supports video
            if ((device as AnyObject).hasMediaType(AVMediaType.video)) {
                // Finally check the position and confirm we've got the back camera
                if((device as AnyObject).position == AVCaptureDevice.Position.back) {
                    backCameraDevice = device as? AVCaptureDevice
                }
            }
        }

        let possibleCameraInput: AnyObject?
        do {
            possibleCameraInput = try AVCaptureDeviceInput(device: backCameraDevice!)
        } catch let error1 as NSError {
            error = error1
            possibleCameraInput = nil
        }
        let backCameraInput = possibleCameraInput as? AVCaptureDeviceInput
        if captureSession.canAddInput(backCameraInput!) {
            captureSession.addInput(backCameraInput!)
        }

        stillImageOutput = AVCaptureStillImageOutput()
        if captureSession.canAddOutput(stillImageOutput!) {
            stillImageOutput?.isHighResolutionStillImageOutputEnabled = true;
            stillImageOutput?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG];
            captureSession.addOutput(stillImageOutput!)
        }
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        setFlashModeToAuto(backCameraDevice!)
        beginSession()
    }
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override var shouldAutorotate : Bool {
        return false
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator);
        coordinator.animate(alongsideTransition: nil, completion: {
            _ in
            _ = 0;
            self.captureSession.stopRunning();
            self.beginSession();
        })
    }
    
    //MARK: AVFoundation Implementation
    func beginSession(){
        let currentDevice: UIDevice = UIDevice.current
        var orientation: UIDeviceOrientation = currentDevice.orientation;
        oldOrientationValue = orientation;
        var width = UIScreen.main.bounds.size.width;
        var height = UIScreen.main.bounds.size.height;
        if(orientation == UIDeviceOrientation.landscapeLeft ||
            orientation == UIDeviceOrientation.landscapeRight){
            orientation = UIDeviceOrientation.portrait;
            let dummyVar = width;
            width=height;
            height=dummyVar;
        }
        else if(orientation == UIDeviceOrientation.faceUp ||
                orientation == UIDeviceOrientation.faceDown){
            orientation = UIDeviceOrientation.portrait;
//            let dummyVar = width;
//            width=height;
//            height=dummyVar;
        }
        else if(orientation == UIDeviceOrientation.portraitUpsideDown){
            orientation = UIDeviceOrientation.portrait;
            let dummyVar = width;
            width=height;
            height=dummyVar;
        }

        let previewLayer: AVCaptureVideoPreviewLayer? = AVCaptureVideoPreviewLayer(session: captureSession);
        if(previewLayer == nil) {
            let alertController = UIAlertController(title: "Camera Preview", message:
                "There is a problem starting the camera, please try again.", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(UIAlertAction(title: "Close Camera", style: UIAlertActionStyle.default,handler: {action in
                self.closeSession(0 as AnyObject);
            }))

            DispatchQueue.main.async() {
                self.present(alertController, animated: true, completion: { print("completed")})
            }
        }

        previewLayer?.frame = CGRect(x: 0, y: 0, width: width,height: height)
        previewLayer?.bounds = CGRect(x: 0, y: 0,width: width,height: height)
        previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill;
        
        previewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue)!;
        camPreview.layer.addSublayer(previewLayer!)

        captureSession.startRunning()
    }

    //MARK: IB Outlets and Actions
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var camPreview: UIView!
    @IBOutlet weak var flashUIButton: UIButton!
    @IBOutlet weak var ULuii: UIImageView!
    @IBOutlet weak var URuii: UIImageView!
    @IBOutlet weak var LLuii: UIImageView!
    @IBOutlet weak var LRuii: UIImageView!
    @IBOutlet weak var badgeBg: UIImageView!
    @IBOutlet weak var badgeCount: UILabel!

    @IBAction func flashToggle(_ sender: UIButton) {
        toggleFlashMode(backCameraDevice!)
    }

    @IBAction func closeSession(_ sender: AnyObject) {
        resetThumbImages()
        UIDevice.current.setValue(oldOrientationValue.rawValue, forKey: "orientation")
        delegate!.cameraFinished(self)
    }
    
    func resetThumbImages(){
        ULuii.image = UIImage(named:"gray.png")
        URuii.image = UIImage(named:"gray.png")
        LLuii.image = UIImage(named:"gray.png")
        LRuii.image = UIImage(named:"gray.png")
    }
    
    @IBAction func captureImage(_ sender: UIButton){
        if(canTakePhoto){
            HappieCameraJSON.incrementProcessingCount();
            canTakePhoto = false;
            let connection = stillImageOutput?.connection(with: AVMediaType.video)

            stillImageOutput?.captureStillImageAsynchronously(from: connection!) { imageBuffer, error in
                if((imageBuffer) != nil){
                    let imageData: Data = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageBuffer!)!
                    let UIImageFromData = UIImage(data: imageData)

                    var  orient = UIImageOrientation.right;
                    if(self.rawOrient == "Right"){//case Right // 90 deg CW
                        orient = UIImageOrientation.down
                    }
                    else if(self.rawOrient == "Left"){ //case Left // 90 deg CCW
                        orient = UIImageOrientation.up
                    }
                    else if(self.rawOrient == "Up"){ //case Up // default orientation
                        orient = UIImageOrientation.right
                    }
                    else if(self.rawOrient == "Down"){ //case Down // 180 deg rotation
                        orient = UIImageOrientation.left
                    }

                    let oImage = UIImage(cgImage: (UIImageFromData?.cgImage!)!, scale: CGFloat(0.0), orientation: orient)

                    let orientedAndScaledNSData: Data =
                        UIImageJPEGRepresentation(self.sizeUIImage(image: oImage, size: self.getCGFloat()), 0.84)!

                    let fileName = self.generateFileName()
                    let path = self.mediaDir + "/" + fileName
                    let thumbPath = self.thumbDir + "/" + fileName
                    if self.filemgr.createFile(atPath: path, contents: orientedAndScaledNSData, attributes: nil) {
                        let thumbData = self.thumbGen.createThumbOfImage(thumbPath, data: orientedAndScaledNSData)
                        if(self.quadState == 0) {self.ULuii.image = UIImage(data: thumbData, scale: 1); self.quadState = 1}
                        else if(self.quadState == 1) {self.URuii.image = UIImage(data: thumbData, scale: 1); self.quadState = 2}
                        else if(self.quadState == 2) {self.LLuii.image = UIImage(data: thumbData, scale: 1); self.quadState = 3}
                        else if(self.quadState == 3) {self.LRuii.image = UIImage(data: thumbData, scale: 1); self.quadState = 0}
                        let dirContents = try? self.filemgr.contentsOfDirectory(atPath: self.mediaDir)
                        let count = dirContents?.count
                        self.badgeCount.text = String(describing: count! - 1)
                        self.canTakePhoto = true;
                        HappieCameraJSON.decrementProcessingCount();
                    }else{
                        print("failed to write image to path: " + path)
                        self.canTakePhoto = true;
                        HappieCameraJSON.decrementProcessingCount();
                    }
                }
            }
        }
    }
    
    func getCGFloat()->CGFloat{
        let quality = HappieCameraJSON.getQuality();
        if(quality == 0){
            return CGFloat(0.20);
        }
        else if(quality == 1){
            return CGFloat(0.35);
        }
        else if(quality == 2){
            return CGFloat(0.43);
        }
        else{
            return CGFloat(0.5);
        }
    }
    
    func sizeUIImage(image:UIImage, size:CGFloat) ->UIImage{
        //modify image resolution if needed
        /**
         '0 =  High Compression (1024 x 768) *this option will offer the best performance'
         '1 = Medium Compression (2560 x 1440)'
         '2 = Low Compression (4096 x 2304)'
         '3 = No Compression',
         **/
        let quality = HappieCameraJSON.getQuality();
        if(quality == 3){
            return image;
        }
        
        let size:CGSize = (image.size).applying(CGAffineTransform(scaleX: CGFloat(0.5), y: CGFloat(0.5)));
        let hasAlpha = false
        let scale: CGFloat = 2.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.draw(in: CGRect(origin: CGPoint.zero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage!;
    }
    
    
    // MARK: AVCaptureFileOutputRecordingDelegate Delegate Conformance
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
    }

    //MARK: Utility Functions
    func deviceWithMediaType(_ mediaType : AVMediaType, preferringPosition: AVCaptureDevice.Position) -> AVCaptureDevice{
        let devices : [AVCaptureDevice] = AVCaptureDevice.devices(for: mediaType)
        var captureDevice: AVCaptureDevice = devices.first as! AVCaptureDevice

        for device in devices{
            if((device as AnyObject).position == preferringPosition){
                captureDevice = device as! AVCaptureDevice
                break
            }
        }
        return captureDevice
    }

    func setFlashModeToAuto(_ device: AVCaptureDevice){
        do{
            try device.lockForConfiguration();
            if(backCameraDevice!.hasFlash){
                if(backCameraDevice!.isFlashModeSupported(AVCaptureDevice.FlashMode.auto)){
                    device.flashMode = AVCaptureDevice.FlashMode.auto;
                    let image = UIImage(named: "camera_flash_auto.png") as UIImage!
                    flashUIButton.setImage(image, for: UIControlState())
                }
                if(backCameraDevice!.isTorchModeSupported(AVCaptureDevice.TorchMode.off)){
                    device.torchMode = AVCaptureDevice.TorchMode.off;
                }
            }else{
                let image = UIImage(named: "camera_flash_off.png") as UIImage!
                flashUIButton.setImage(image, for: UIControlState())
                flashUIButton.isHidden = true;
            }
            flashState = 2


            device.unlockForConfiguration()
        }catch{
            //TODO write error handling code at some point
        }
    }

    func toggleFlashMode(_ device:AVCaptureDevice){
        do{
            if(backCameraDevice!.hasFlash){
                try device.lockForConfiguration();

                if(flashState == 0){
                    if(backCameraDevice!.isFlashModeSupported(AVCaptureDevice.FlashMode.off)){
                        device.flashMode = AVCaptureDevice.FlashMode.off;
                        let image = UIImage(named: "camera_flash_off.png") as UIImage!
                        flashUIButton.setImage(image, for: UIControlState())
                    }
                    if(backCameraDevice!.isTorchModeSupported(AVCaptureDevice.TorchMode.off)){
                        device.torchMode = AVCaptureDevice.TorchMode.off;
                    }
                    flashState = 1;
                }

                else if(flashState == 1){
                    if(backCameraDevice!.isFlashModeSupported(AVCaptureDevice.FlashMode.auto)){
                        device.flashMode = AVCaptureDevice.FlashMode.auto;
                        let image = UIImage(named: "camera_flash_auto.png") as UIImage!
                        flashUIButton.setImage(image, for: UIControlState())
                    }
                    if(backCameraDevice!.isTorchModeSupported(AVCaptureDevice.TorchMode.off)){
                        device.torchMode = AVCaptureDevice.TorchMode.off;
                    }
                    flashState = 2
                }
                else if(flashState == 2){
                    if(backCameraDevice!.isFlashModeSupported(AVCaptureDevice.FlashMode.off)){
                        device.flashMode = AVCaptureDevice.FlashMode.off;
                        let image = UIImage(named: "camera_flash_on.png") as UIImage!
                        flashUIButton.setImage(image, for: UIControlState())
                    }
                    if(backCameraDevice!.isTorchModeSupported(AVCaptureDevice.TorchMode.on)){
                        device.torchMode = AVCaptureDevice.TorchMode.on;
                    }

                    flashState = 0;
                }
                device.unlockForConfiguration()
            }

        }catch{
            //TODO write error handling code at some point
        }
    }
    
    func generateFileName() -> String {
        let date = Date()
        let format = DateFormatter()
        format.dateFormat = "yyyyMMdd_HHmmssSS"
        let stringDate = format.string(from: date)
        return stringDate + "_photo.jpg"
    }
}
