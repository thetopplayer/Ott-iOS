//
//  ExportViewController.swift
//  Ott
//
//  Created by Max on 9/1/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import MessageUI


class ExportViewController: ViewController, UIPrintInteractionControllerDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var codeImageView: UIImageView!
    @IBOutlet weak var printButtonItem: UIBarButtonItem!
    @IBOutlet weak var emailButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveToPhotosButtonItem: UIBarButtonItem!
    @IBOutlet weak var captionSwitch: UISwitch!
    @IBOutlet weak var imageSizeSegmentedControl: UISegmentedControl!
   
    var didLoadView = false
    override func viewDidLoad() {
        
        super.viewDidLoad()
        didLoadView = true
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        objectToExport = (navigationController as! NavigationController).payload
        setupDisplay()
        generateImage()
    }

    var objectToExport: PFObject?
    
    enum ObjectType {
        case Unknown, Topic, User
    }
    
    var objectType: ObjectType {
        
        if let object = objectToExport {
           
            if object is Topic {
                return .Topic
            }
            else if object is User {
                return .User
            }
        }
        
        return .Unknown
    }
    
    private func textForObject() -> String? {
        
        var result: String? = nil
        
        if let topic = objectToExport as? Topic {
            result = topic.name!
        }
        else if let user = objectToExport as? User {
            result = user.handle
        }
        
        return result
    }
    
    
    private var codeText: String?
    private var codeImage: UIImage?
    var imageBackgroundColor = UIColor.colorWithHex(0xDEEEFF)
    var imageColor = UIColor.blackColor()
    static let defaultImageSize = ScanTransformer.ImageSize.Large
    var imageSize = ExportViewController.defaultImageSize
    var includeCaption = true
    
    private func generateImage() {
        
        guard let theObject = objectToExport else {
            return
        }
        
        let generateImageOperation = NSBlockOperation { () -> Void in
            
            self.codeText = ScanTransformer.sharedInstance.codeForObject(theObject)
            let textForImage = self.includeCaption ? self.textForObject() : nil
            
            if let image = ScanTransformer.sharedInstance.imageForObject(theObject, backgroundColor: self.imageBackgroundColor, color: self.imageColor, size: self.imageSize, withCaption: textForImage) {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.codeImage = image
                    self.codeImageView.image = image
                    self.printButtonItem.enabled = true
                    self.emailButtonItem.enabled = true
                    self.saveToPhotosButtonItem.enabled = true
                }
            }
        }
        
        operationQueue.addOperation(generateImageOperation)
    }
    
    
    private func setupDisplay() {
        
        if objectToExport == nil {
            return
        }
        
        navigationItem.title = textForObject()
        
        self.printButtonItem.enabled = false
        self.emailButtonItem.enabled = false
        self.saveToPhotosButtonItem.enabled = false
        
        self.captionSwitch.on = true
        self.imageSizeSegmentedControl.selectedSegmentIndex = ExportViewController.defaultImageSize.rawValue
    }
    
    
    @IBAction func handleSwitchAction(sender: UISwitch?) {
        
        includeCaption = sender!.on
        generateImage()
    }
    
    
    @IBAction func handleSizeSelectionAction(sender: UISegmentedControl?) {
        
        imageSize = ScanTransformer.ImageSize(rawValue: (sender?.selectedSegmentIndex)!)!
        generateImage()
    }
    
    
    class ImagePrintRenderer: UIPrintPageRenderer {
        
        var imageToPrint: UIImage
        var imageSize: CGSize
        
        init(forImage image: UIImage, size: CGSize = CGSizeMake(80, 80)) {
            
            imageToPrint = image
            imageSize = size
            super.init()
        }
        
        override func drawPageAtIndex(pageIndex: Int, inRect printableRect: CGRect) {
            
            let x = printableRect.midX - (imageSize.width / 2)
            let y = printableRect.midY - (imageSize.height / 2)
            let destinationRect = CGRectMake(x, y, imageSize.width, imageSize.height)
            
            imageToPrint.drawInRect(destinationRect)
        }
    }
    
    
    @IBAction func handlePrintAction(sender: AnyObject) {
        
        let printController = UIPrintInteractionController.sharedPrintController()
        printController.delegate = self
        
        printController.printPageRenderer = ImagePrintRenderer(forImage: codeImage!)
        
        printController.presentAnimated(true) { (controller, status, error) -> Void in
            
        }
    }
    
    
    @IBAction func handleEmailAction(sender: AnyObject) {
        
        let emailVC = MFMailComposeViewController()
        emailVC.mailComposeDelegate = self
        
        let subject = "Ott " + textForObject()!
        emailVC.setSubject(subject)
        
        if let jpegData = UIImageJPEGRepresentation(codeImage!, 1) {
            
            let link = "<a href='\(self.codeText!)'>\(textForObject()!)</a>"
            var message = ""
            if objectType == .User {
                message = "Click on the link or scan the code from within the Ott app to view " + link
            }
            else if objectType == .Topic {
                message = "Click on the link or scan the code from within the Ott app to give your take on " + link
            }
            
            emailVC.setMessageBody(message, isHTML: true)
            
            let filename = textForObject()! + ".jpeg"
            emailVC.addAttachmentData(jpegData, mimeType:"image/jpeg", fileName:filename)
        }
        else {
            emailVC.setMessageBody("ERROR exporting image", isHTML: true)
        }
        
        presentViewController(emailVC, animated: true, completion: nil)
    }
    
    
    @IBAction func handlePhotosAction(sender: AnyObject) {
        
        UIImageWriteToSavedPhotosAlbum(codeImage!, self, "image:didFinishSavingWithError:contextInfo:", nil)
    }
    
    
    func image(image: UIImage, didFinishSavingWithError error: NSError?, contextInfo:UnsafePointer<Void>) {
        
        func presentAlert() {
            
            let alert = TimedAlertController(title: "Image Saved", message: "The image was saved to your camera roll.", preferredStyle: .Alert)
            alert.completion = {self.dismissViewControllerAnimated(true, completion: nil)}
            
            self.presentViewController(alert, animated: true, completion: {
                dispatch_async(dispatch_get_main_queue()) {
                    self.handleCancelAction(self)
                }
            })
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            presentAlert()
        }
    }
    
    
    @IBAction func handleCancelAction(sender: AnyObject) {
    
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    
    //MARK: - Print Controller Delegate
    
    func printInteractionControllerWillStartJob(printInteractionController: UIPrintInteractionController) {
        
        handleCancelAction(self)
    }
    
    
    
    //MARK: - Email Delegate
    
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        
        handleCancelAction(self)
    }
}
