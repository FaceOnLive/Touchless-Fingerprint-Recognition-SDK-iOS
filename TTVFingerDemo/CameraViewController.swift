//
//  CameraViewController.swift
//  TTVFaceDemo
//
//  Created by user on 10/28/21.
//

import UIKit
import AVKit

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate{
       
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var label: UILabel!
    
    var mode: Int = 0
    var captureDevice: AVCaptureDevice? = nil
    var cameraInited: Bool = false
    var processingDone: Int = 0

    static var registerTemplates = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.cameraInited = false
        setupCamera()
    }
    
    fileprivate func setupCamera() {
        let captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high
        
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else { return }
        
        self.captureDevice = captureDevice
        guard let input = try? AVCaptureDeviceInput(device: captureDevice) else { return }
        captureSession.addInput(input)
        
        captureSession.startRunning()
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.cameraView.layer.addSublayer(previewLayer)
        
        previewLayer.frame = view.frame
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
        captureSession.addOutput(dataOutput)
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
               
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
                
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        let image = CIImage(cvPixelBuffer: pixelBuffer).oriented(CGImagePropertyOrientation.right)
        let capturedImage = UIImage(ciImage: image)
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        
        if(self.cameraInited == true) {

            if(self.mode == 0) {
                let quality:Double = FingerSDK.getInstance().getCaptureQuality(capturedImage)
                let fingerTemplates:NSMutableArray = FingerSDK.getInstance().captureFinger(capturedImage)
                if(quality > 0.9 && fingerTemplates.count > 0) {
                    var badNfiqCount: Int = 0
                    for fingerTemplate in (fingerTemplates as NSArray as! [FingerTemplate]) {
                        if(fingerTemplate.nfiqScore >= 3) {
                            badNfiqCount += 1
                        }
                    }

                    var isGood:Int = 0;
                    if(fingerTemplates.count == 1 && badNfiqCount == 0) {
                        isGood = 1
                    } else if(fingerTemplates.count == 2 && badNfiqCount <= 1) {
                        isGood = 1
                    } else if(fingerTemplates.count == 3 && badNfiqCount <= 1) {
                        isGood = 1
                    } else if(fingerTemplates.count == 4 && badNfiqCount <= 2) {
                        isGood = 1
                    } else if(fingerTemplates.count == 5 && badNfiqCount <= 2) {
                        isGood = 1
                    }

                    if(isGood == 1 && self.processingDone == 0) {
                        self.processingDone = 1
                        let userName = String(format: "User%03d", CameraViewController.registerTemplates.count + 1)
                        CameraViewController.registerTemplates[userName] = fingerTemplates
                        DispatchQueue.main.async {
                            if let vc = self.presentingViewController as? ViewController {
                                self.dismiss(animated: true, completion: {
                                    vc.sendData(state: 1, name: userName)
                                })
                            }
                        }
                    }
                }

            } else if(self.mode == 1) {
                let quality:Double = FingerSDK.getInstance().getCaptureQuality(capturedImage)
                let fingerTemplates:NSMutableArray = FingerSDK.getInstance().captureFinger(capturedImage)
                if(quality > 0.9 && fingerTemplates.count > 0 && CameraViewController.registerTemplates.count > 0) {

                    var maxScore = 0.0
                    var maxScoreID = ""
                    
                    for (_key, _value) in CameraViewController.registerTemplates {
                        var score = 0.0
                        for fingerTemplate1 in (fingerTemplates as NSArray as! [FingerTemplate]) {
                            for fingerTemplate2 in (_value as! NSArray as! [FingerTemplate]) {
                                score += FingerSDK.getInstance().compareFeature(fingerTemplate1, feat2: fingerTemplate2)
                            }
                        }
                        
                        if(maxScore < score) {
                            maxScore = score
                            maxScoreID = _key as! String
                        }
                    }
                    
                    if(maxScore > 100) {
                        DispatchQueue.main.async {
                            if let vc = self.presentingViewController as? ViewController {
                                self.dismiss(animated: true, completion: {
                                    vc.sendData(state: 2, name: maxScoreID)
                                })
                            }
                        }
                    }
                }
            }
        }
        
        DispatchQueue.main.async {
            if(self.cameraInited == false) {
                self.cameraInited = true
                FingerSDK.getInstance().initCapture()

                do {
                    try self.captureDevice?.lockForConfiguration()
                    if((self.captureDevice?.hasTorch) != false) {
                        self.captureDevice?.torchMode = .on
                    }
                    self.captureDevice?.videoZoomFactor = 2.4
                    self.captureDevice?.unlockForConfiguration()
                } catch {
                }
            }
        }
    }
}
