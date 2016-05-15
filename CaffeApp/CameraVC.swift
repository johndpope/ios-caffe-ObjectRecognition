import UIKit
import AVFoundation

class CameraVC: ViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    let captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var resultView: UIView?
    
    var isProcessing: Bool?
    
    let kScreenWidth = UIScreen.mainScreen().bounds.width
    let kScreenHeight = UIScreen.mainScreen().bounds.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        resultView = UIView(frame: CGRectMake(0, kScreenHeight - 150, kScreenWidth, 150))
        resultView?.layer.zPosition = 1000
        resultView?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.4)
        
        for i in 0 ..< 5 {
            let label_tag = UILabel(frame: CGRectMake(10, 10 + 30 * CGFloat(i), 200, 30))
            label_tag.textColor = UIColor.redColor()
            label_tag.tag = 100 + i
            
            let label_score = UILabel(frame: CGRectMake(220, 10 + 30 * CGFloat(i), 100, 30))
            label_score.textColor = UIColor.redColor()
            label_score.tag = 200 + i
            resultView?.addSubview(label_tag)
            resultView?.addSubview(label_score)
        }
        
        self.view.addSubview(resultView!)
        
        isProcessing = false;
        
//        headImage = UIView(frame: CGRectMake(0, 0, 100, 100))
//        headImage?.backgroundColor = UIColor.clearColor()
//        headImage?.layer.borderColor = UIColor.redColor().CGColor
//        headImage?.layer.borderWidth = 3
//        headImage?.layer.zPosition = 1000
//        self.view.addSubview(headImage!)
        
        captureSession.sessionPreset = AVCaptureSessionPresetLow
        let devices = AVCaptureDevice.devices()
        for device in devices {
            if (device.hasMediaType(AVMediaTypeVideo)) {
                if (device.position == AVCaptureDevicePosition.Back) {
                    captureDevice = device as? AVCaptureDevice
                    if captureDevice != nil {
                        print("Capture Device found")
                        beginSession()
                    }
                }
            }
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func beginSession() {
        
        try! captureSession.addInput(AVCaptureDeviceInput(device: captureDevice))
        let output = AVCaptureVideoDataOutput()
        
        let cameraQueue = dispatch_queue_create("cameraQueue", DISPATCH_QUEUE_SERIAL)
        output.setSampleBufferDelegate(self, queue: cameraQueue)
        let value: NSNumber = NSNumber(unsignedInt: kCVPixelFormatType_32BGRA)
        output.videoSettings = [kCVPixelBufferPixelFormatTypeKey: value]
        captureSession.addOutput(output)
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        previewLayer?.frame = self.view.bounds
        self.view.layer.addSublayer(previewLayer!)
        captureSession.startRunning()
        
    }
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
       // let resultImage:UIImage = sampleBufferToImage(sampleBuffer)
        
        if isProcessing == false {
            isProcessing = true
           // let txt = self.predictWithImage(resultImage)
             let text = self.predictWithBuffer(sampleBuffer)
            let arr = text.componentsSeparatedByString(",")
            for (index,str) in arr.enumerate(){
                print("prediction:",str)
               
                
                NSOperationQueue.mainQueue().addOperationWithBlock({
                    // Your code here
                    
                    let tag0 = 100 + index
                    let lbl0 =  self.resultView?.viewWithTag(tag0) as! UILabel
                    lbl0.text = str
                    
                    let tag1 = 200 + index
                    let lbl1 =  self.resultView?.viewWithTag(tag1) as! UILabel
                    lbl1.text = "score"
                })
                
            }
            isProcessing = false
        }
        
    }
    
    
    func sampleBufferToImage(sampleBuffer: CMSampleBuffer) -> UIImage {
        let imageBuffer: CVImageBufferRef = CMSampleBufferGetImageBuffer(sampleBuffer)!
        CVPixelBufferLockBaseAddress(imageBuffer, 0)
        let baseAddress = CVPixelBufferGetBaseAddress(imageBuffer)
        
        let bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer)
        let width = CVPixelBufferGetWidth(imageBuffer)
        let height = CVPixelBufferGetHeight(imageBuffer)
        
        let colorSpace: CGColorSpaceRef = CGColorSpaceCreateDeviceRGB()!
        
        let bitsPerCompornent = 8
        let bitmapInfo = CGBitmapInfo(rawValue: (CGBitmapInfo.ByteOrder32Little.rawValue | CGImageAlphaInfo.PremultipliedFirst.rawValue) as UInt32)
        
        let newContext = CGBitmapContextCreate(baseAddress, width, height, bitsPerCompornent, bytesPerRow, colorSpace, bitmapInfo.rawValue)! as CGContextRef
        
        let imageRef: CGImageRef = CGBitmapContextCreateImage(newContext)!
        let resultImage = UIImage(CGImage: imageRef, scale: 1.0, orientation: UIImageOrientation.Right)
        
        return resultImage
    }


}

