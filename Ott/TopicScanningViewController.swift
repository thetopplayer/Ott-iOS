//
//  TopicScanningViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import AVFoundation


class TopicScanningViewController: ViewController, AVCaptureMetadataOutputObjectsDelegate {

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        if cameraAccessGranted {
            createScanningSession()
        }
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if cameraAccessGranted {
            startScanning()
        }
        else {
            if hasRequestedCameraAccess {
                
                let alertViewController = UIAlertController(title: "Camera Access Disabled", message: "Please enable camera access in Settings>Preferences>Privacy to enable this feature.", preferredStyle: .Alert)
                
                func viewSettingsActionHandler(action: UIAlertAction) {
                    dispatch_after(0, dispatch_get_main_queue(), {
                        self.dismissViewControllerAnimated(false, completion: {
                            openSettings()
                        })
                    })
                }
                
                let viewSettingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: viewSettingsActionHandler)
                
                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in self.dismissViewControllerAnimated(true, completion: nil) })
                
                alertViewController.addAction(viewSettingsAction)
                alertViewController.addAction(cancelAction)
                
                presentViewController(alertViewController, animated: true, completion: nil)
            }
            else {
                requestAccessToCamera()
            }
        }
    }
    
    
    
    //MARK: - Access
    
    private let requestedAccessUserDefaultsKey = "requestedCameraAccess"
    private var hasRequestedCameraAccess: Bool {
        return NSUserDefaults.standardUserDefaults().boolForKey(requestedAccessUserDefaultsKey)
    }
    
    
    private func requestAccessToCamera() {
        
        let alertViewController = UIAlertController(title: "Camera Access", message: "This app can recognize QR codes associated with topics.  In order to enable this feature, you will be asked to provide the app with access to your camera.", preferredStyle: .Alert)
        
        func nextHandler(action: UIAlertAction) {
            
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
                (granted: Bool) -> Void in
                
                NSUserDefaults.standardUserDefaults().setBool(true, forKey: self.requestedAccessUserDefaultsKey)
                
                if granted {
                    self.createScanningSession()
                    self.startScanning()
                }
            })
        }
        
        let nextAction = UIAlertAction(title: "Next", style: UIAlertActionStyle.Default, handler: nextHandler)
    
        alertViewController.addAction(nextAction)
        presentViewController(alertViewController, animated: true, completion: nil)
    }

    
    private var cameraAccessGranted: Bool {
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        return status == AVAuthorizationStatus.Authorized
    }
    
    
    var canScan: Bool {
        if cameraAccessGranted == false {
            return false
        }
        if scanningSession == nil {
            return false
        }
        return true
    }
    
    
    
    //MARK: - Setup
    
    var scanningSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    private func createScanningSession() {
        
        if scanningSession != nil {
            return
        }
        
        let device = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeVideo)
        if device == nil {
            return
        }
        
        let inputDevice: AVCaptureDeviceInput!
        do {
            inputDevice = try AVCaptureDeviceInput(device: device)
        } catch _ {
            return
        }
        
        let session = AVCaptureSession()
        if session.canAddInput(inputDevice) {
            session.addInput(inputDevice)
        }
        
        let metaDataOutput = AVCaptureMetadataOutput()
        let queue = dispatch_queue_create( "net.senisa.Ott.metadata", DISPATCH_QUEUE_CONCURRENT)
        metaDataOutput.setMetadataObjectsDelegate(self, queue: queue)
        
        if session.canAddOutput(metaDataOutput) {
            session.addOutput(metaDataOutput)
        }
        
        metaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
        
        let pv = AVCaptureVideoPreviewLayer(session: session)
        pv.videoGravity = AVLayerVideoGravityResizeAspectFill
        pv.frame = view.bounds
        view.layer.addSublayer(pv)
        previewLayer = pv
        
        scanningSession = session
    }
    
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        stopScanning()
        
        if let layer = previewLayer {
            
            let firstDetectedObject = metadataObjects.first as! AVMetadataObject
            let transformedObject = layer.transformedMetadataObjectForMetadataObject(firstDetectedObject) as? AVMetadataMachineReadableCodeObject
            
            if let readableObject = transformedObject {
                dispatch_async(dispatch_get_main_queue(), {
                    self.handleRecognition(ofCode: readableObject.stringValue)
                })
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    self.handleScanFailure()
                })
            }
        }
    }
    
    
    
    //MARK: - Data
    
    var recognizedTopic: Topic?
    
    
    private func handleRecognition(ofCode code: String) {
        
        let alertViewController = UIAlertController(title: "Code Detected", message: "Fetching associated topic information...", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
        
            DataManager.sharedInstance.cancelFetchTopic()
            self.handleCancelAction(self)
        })
        
        alertViewController.addAction(cancelAction)

        presentViewController(alertViewController, animated: true) { () -> Void in
            
            func dataFetchCompletionHandler(theTopic: Topic?) {
                
                self.recognizedTopic = theTopic
                
                if self.recognizedTopic != nil {
                    dispatch_after(0, dispatch_get_main_queue(), { () -> Void in
                        
                        alertViewController.dismissViewControllerAnimated(false, completion: { () -> Void in
                            self.performSegueWithIdentifier("segueToRatingEntry", sender: self)
                        })
                    })
                }
                else {
                    
                    dispatch_after(0, dispatch_get_main_queue(), { () -> Void in
                        
                        alertViewController.dismissViewControllerAnimated(false, completion: { () -> Void in
                            self.handleCodeIsNotRecognized()
                        })
                    })
                }
            }
            
            DataManager.sharedInstance.fetchTopic(withIdentifier: code, completion: dataFetchCompletionHandler)
        }
    }
    
    
    private func handleScanFailure() {
        
        let alertViewController = UIAlertController(title: "Detection Failed", message: "Try again?", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:
            { action in self.startScanning() })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in self.handleCancelAction(self) })
        
        alertViewController.addAction(okAction)
        alertViewController.addAction(cancelAction)
        presentViewController(alertViewController, animated: true) { () -> Void in }
    }
    
    
    private func handleCodeIsNotRecognized() {
        
        let alertViewController = UIAlertController(title: "Invalid Code", message: "The scanned code does not represent a valid topic.  Do you want to scan another?", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler:
            { action in self.startScanning() })
        
        let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: { action in self.handleCancelAction(self) })
        
        alertViewController.addAction(okAction)
        alertViewController.addAction(cancelAction)
        presentViewController(alertViewController, animated: true) { () -> Void in }
    }

    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
    
    
    
    //MARK: - Actions
    
    var isScanning = false
    func startScanning() {
        
        if isScanning {
            return
        }
        
        if canScan {
            scanningSession?.startRunning()
            isScanning = true
        }
    }
    
    
    func stopScanning() {
        
        if isScanning == false {
            return
        }
        
        scanningSession?.stopRunning()
        isScanning = false
    }
    
    
    
    //MARK: - Navigation
    
    @IBAction func handleCancelAction(sender: AnyObject) {
        
        stopScanning()
        dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    @IBAction func handleDoneAction(sender: AnyObject) {
        
        dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    

}
