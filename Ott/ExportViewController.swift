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

    @IBOutlet weak var captionContainer: UIView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var codeImageView: UIImageView!
    @IBOutlet weak var printButtonItem: UIBarButtonItem!
    @IBOutlet weak var emailButtonItem: UIBarButtonItem!
    @IBOutlet weak var saveToPhotosButtonItem: UIBarButtonItem!
    @IBOutlet weak var captionSwitch: UISwitch!
    @IBOutlet weak var imageSizeSegmentedControl: UISegmentedControl!
   
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    
    var didLoadView = false
    override func viewDidLoad() {
        
        super.viewDidLoad()
        captionContainer.backgroundColor = UIColor.background().colorWithAlphaComponent(0.4)
        captionContainer.addBorder()
        
        didLoadView = true
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        setupDisplay()
        generateImage()
    }

    
    var myTopic: Topic? {
        
        didSet {
            
            if didLoadView {
                setupDisplay()
                generateImage()
            }
        }
    }
    
    
    private var codeText: String?
    private var codeImage: UIImage?
    var imageBackgroundColor = UIColor.colorWithHex(0xDEEEFF)
    var imageColor = UIColor.blackColor()
    static let defaultImageSize = ScanTransformer.ImageSize.Large
    var imageSize = ExportViewController.defaultImageSize
    var includeTopicName = true
    
    private func generateImage() {
        
        guard let topic = myTopic else {
            return
        }
        
        let generateImageOperation = NSBlockOperation { () -> Void in
            
            self.codeText = ScanTransformer.sharedInstance.codeForObject(topic)
            var textForImage: String?
            if self.includeTopicName {
                textForImage = "#" + topic.name!
            }
            
            if let image = ScanTransformer.sharedInstance.imageForObject(topic, backgroundColor: self.imageBackgroundColor, color: self.imageColor, size: self.imageSize, withCaption: textForImage) {
                
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
        
        if let topic = myTopic {
            
            topicLabel.text = "#" + topic.name!

            self.printButtonItem.enabled = false
            self.emailButtonItem.enabled = false
            self.saveToPhotosButtonItem.enabled = false
            
            self.captionSwitch.on = true
            self.imageSizeSegmentedControl.selectedSegmentIndex = ExportViewController.defaultImageSize.rawValue
        }
    }
    
    
    @IBAction func handleSwitchAction(sender: UISwitch?) {
        
        includeTopicName = sender!.on
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
        
        let subject = "Ott #" + myTopic!.name!
        emailVC.setSubject(subject)
        
        if let jpegData = UIImageJPEGRepresentation(codeImage!, 1) {
            
            let link = "<a href='\(self.codeText!)'>#\(myTopic!.name!)</a>"
            let message = "Click on the link or scan the code from within the Ott app to give your take on " + link
            
            emailVC.setMessageBody(message, isHTML: true)
            
            let filename = myTopic!.name! + ".jpeg"
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
        
        dispatch_async(dispatch_get_main_queue()) {
            self.handleCancelAction(self)
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
        
        controller.dismissViewControllerAnimated(true, completion: { self.handleCancelAction(self) })
    }
}
