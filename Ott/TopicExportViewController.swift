//
//  TopicExportViewController.swift
//  Ott
//
//  Created by Max on 9/1/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicExportViewController: ViewController, UIPrintInteractionControllerDelegate {

    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    
    
    override func prefersStatusBarHidden() -> Bool {
        return true;
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        setupDisplay()
    }

    
    var myTopic: Topic?
    
    
    private func setupDisplay() {
        
        if let topic = myTopic {
            
            topicLabel.text = topic.name!
            qrCodeImage = ScanTransformer.sharedInstance.imageForObject(topic)
            qrCodeImageView.image = qrCodeImage
        }
    }
    
    
    private var qrCodeImage: UIImage?
    
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
        
        printController.printPageRenderer = ImagePrintRenderer(forImage: qrCodeImage!)
        
        printController.presentAnimated(true) { (controller, status, error) -> Void in
            
        }
    }
    
    
    @IBAction func handleEmailAction(sender: AnyObject) {
        
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
    
}
