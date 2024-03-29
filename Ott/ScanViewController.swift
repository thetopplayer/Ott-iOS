//
//  ScanViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import AVFoundation


class ScanViewController: ViewController, AVCaptureMetadataOutputObjectsDelegate {

    
    //MARK: - Lifecycle
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        startScanning()
        
        // TODO :  fade to scan/camera view
        
//        else {
//            if Globals.sharedInstance.didRequestCameraAccess {
//                
//                let alertViewController = UIAlertController(title: "Camera Access Disabled", message: "Please enable camera access in Settings>Preferences>Privacy to enable this feature.", preferredStyle: .Alert)
//                
//                func viewSettingsActionHandler(action: UIAlertAction) {
//                    dispatch_after(0, dispatch_get_main_queue(), {
//                        self.dismissViewControllerAnimated(false, completion: {
//                            openSettings()
//                        })
//                    })
//                }
//                
//                let viewSettingsAction = UIAlertAction(title: "Settings", style: UIAlertActionStyle.Default, handler: viewSettingsActionHandler)
//                
//                let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in self.dismissViewControllerAnimated(true, completion: nil) })
//                
//                alertViewController.addAction(viewSettingsAction)
//                alertViewController.addAction(cancelAction)
//                
//                presentViewController(alertViewController, animated: true, completion: nil)
//            }
//            else {
//                requestAccessToCamera()
//            }
//        }
    }
    
    
    
    
    override func viewDidDisappear(animated: Bool) {
        
        super.viewDidDisappear(animated)
        stopScanning()
    }
    
    
    
    
    //MARK: - Access
    
    /*
    private func requestAccessToCamera() {
        
        let alertViewController = UIAlertController(title: "Camera Access", message: "This app can recognize 2D bar codes associated with topics.  In order to enable this feature, you will be asked to provide the app with access to your camera.", preferredStyle: .Alert)
        
        func nextHandler(action: UIAlertAction) {
            
            AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
                (granted: Bool) -> Void in
                
                Globals.sharedInstance.didRequestCameraAccess = true
                
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
    */
    
    class func cameraAccessGranted() -> Bool {
        let status = AVCaptureDevice.authorizationStatusForMediaType(AVMediaTypeVideo)
        return status == AVAuthorizationStatus.Authorized
    }
    
    /*
    var canScan: Bool {
        if cameraAccessGranted == false {
            return false
        }
        if scanningSession == nil {
            return false
        }
        return true
    }
    */
    
    
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
        
        metaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeAztecCode]
        
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
    
    private var fetchOperation: BlockOperation?
    
    private func fetchObject(forCode code: String) {
        
        func fetchObject() {
            
            if let query = ScanTransformer.sharedInstance.queryForURL(code) {
                
                do {
                    
                    let objects = try query.findObjects()
                    if objects.count == 0 {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.handleCodeIsNotRecognized()
                        }
                        return
                    }
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.fetchingAlertViewController.dismissViewControllerAnimated(true, completion: { () -> Void in
                            
                            let theObject = objects.first!
                            if let user = theObject as? User {
                                self.displayDetailsForUser(user)
                            }
                            else if let topic = theObject as? Topic {
                                self.displayDetailsForTopic(topic)
                            }
                            else {
                                self.handleCodeIsNotRecognized()
                            }
                        })
                    }
                }
                catch let error as NSError {
                    presentOKAlertWithError(error, messagePreamble: "Unable to fetch object.", actionHandler: nil)
                }
            }
        }

        let fetchOperation: BlockOperation = {
            
            let reachabilityCondition: ReachabilityCondition = {
                
                let host = NSURL(string: "http://api.parse.com")
                return ReachabilityCondition(host: host!)
                }()
            
            let timeoutObserver = TimeoutObserver(timeout: 3600)
            
            let operation = BlockOperation {
                fetchObject()
            }
            
            operation.addCondition(reachabilityCondition)
            operation.addObserver(timeoutObserver)
            return operation
            }()
        
        self.fetchOperation = fetchOperation // save in case we need to cancel
        operationQueue.addOperation(fetchOperation)
    }
    
    
    lazy var fetchingAlertViewController: UIAlertController = {
        
        let controller = UIAlertController(title: "Code Detected", message: "Fetching data...", preferredStyle: .Alert)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            
            self.fetchOperation?.cancel()
        })
        
        controller.addAction(cancelAction)
        return controller
        }()
    
    
    private func handleRecognition(ofCode code: String) {
        
        if ScanTransformer.sharedInstance.URLAppearsValid(code) {
            
            presentViewController(fetchingAlertViewController, animated: true) { action in
                self.fetchObject(forCode: code)
            }
        }
        else {
            self.handleCodeIsNotRecognized()
        }
    }
    

    private func handleScanFailure() {
        
        let alertViewController = UIAlertController(title: "Detection Failed", message: "Try again?", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:
            { action in self.startScanning() })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in self.handleCancelScanAction(self) })
        
        alertViewController.addAction(okAction)
        alertViewController.addAction(cancelAction)
        
        dispatch_async(dispatch_get_main_queue()) {
            self.presentViewController(alertViewController, animated: true) { () -> Void in }
        }
    }
    
    
    private func handleCodeIsNotRecognized() {
        
        let alertViewController = UIAlertController(title: "Invalid Code", message: "The scanned code does not represent an Ott object.  Do you want to scan another?", preferredStyle: .Alert)
        
        let okAction = UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler:
            { action in self.startScanning() })
        
        let cancelAction = UIAlertAction(title: "No", style: UIAlertActionStyle.Cancel, handler: { action in self.handleCancelScanAction(self) })
        
        alertViewController.addAction(okAction)
        alertViewController.addAction(cancelAction)
        presentViewController(alertViewController, animated: true) { () -> Void in }
    }

    
    
    //MARK: - Actions
    
    var isScanning = false
    func startScanning() {
        
        if isScanning {
            return
        }
        
        if let scanningSession = scanningSession {
            scanningSession.startRunning()
        }
        else {
            createScanningSession()
            scanningSession?.startRunning()
        }
        
        isScanning = true
    }
    
    
    func stopScanning() {
        
        if isScanning == false {
            return
        }
        
        scanningSession?.stopRunning()
        isScanning = false
    }
    
    
    
    //MARK: - Navigation
    
    func displayDetailsForTopic(topic: Topic) {
        
        presentTopicDetailViewController(withTopic: topic, exitMethod: .Dismiss)
    }
    
    
    func displayDetailsForUser(user: User) {

        presentUserDetailViewController(withUser: user)
    }
    
    
    @IBAction func handleCancelScanAction(sender: AnyObject) {
        
        stopScanning()
        dismissViewControllerAnimated(true, completion: nil)
    }

}
