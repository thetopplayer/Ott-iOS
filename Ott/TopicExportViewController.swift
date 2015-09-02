//
//  TopicExportViewController.swift
//  Ott
//
//  Created by Max on 9/1/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import MessageUI


class TopicExportViewController: ViewController, UIPrintInteractionControllerDelegate, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var codeImageView: UIImageView!
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        setupDisplay()
    }

    
    var myTopic: Topic?
    
    var imageBackgroundColor = UIColor.colorWithHex(0xDEEEFF)
    var imageColor = UIColor.blackColor()
    var imageScale = CGFloat(5)
    
    private func setupDisplay() {
        
        if let topic = myTopic {
            
            topicLabel.text = "#" + topic.name!
            codeImage = ScanTransformer.sharedInstance.imageForObject(topic, backgroundColor: imageBackgroundColor, color: imageColor, scale: imageScale)
            codeImageView.image = codeImage
        }
    }
    
    
    private var codeImage: UIImage?
    
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
        
        let subject = "Ott image for #" + myTopic!.name!
        emailVC.setSubject(subject)
        
        if let jpegData = UIImageJPEGRepresentation(codeImage!, 1) {
            
            emailVC.setMessageBody("Users will be sent directly to your topic when they scan this image from within the Ott app.", isHTML: true)
            
            let filename = myTopic!.name! + ".jpeg"
            emailVC.addAttachmentData(jpegData, mimeType:"image/jpeg", fileName:filename)
        }
        else {
            
            emailVC.setMessageBody("ERROR exporting image", isHTML: true)
        }
        
        presentViewController(emailVC, animated: true, completion: nil)
    }
    
    
    @IBAction func handlePhotosAction(sender: AnyObject) {
        
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
