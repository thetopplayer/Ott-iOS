//
//  ImageTableViewCell.swift
//  Ott
//
//  Created by Max on 7/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class ImageTableViewCell: TableViewCell {
    
    @IBOutlet var topicImageView: ParseImageView!
    
    var roundedBorder = false
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        topicImageView.contentMode = .ScaleAspectFill
        topicImageView.clipsToBounds = true
        if roundedBorder {
            topicImageView.addRoundedBorder()
        }
        
        let tapGR: UIGestureRecognizer = {
            
            let gr = UITapGestureRecognizer()
            gr.addTarget(self, action: "displayImageDetail:")
            return gr
        }()
        
        topicImageView.addGestureRecognizer(tapGR)
        topicImageView.userInteractionEnabled = true
    }
    

    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func updateContents() {
        
        if let topic = displayedTopic {
            topicImageView!.displayImageInFile(topic.imageFile)
        }
    }
    
    
    @IBAction func displayImageDetail(sender: AnyObject?) {
        
        guard let imageView = topicImageView else {
            return
        }
        
        let imageInfo = JTSImageInfo()
        imageInfo.image = imageView.image
        imageInfo.referenceRect = self.frame
        imageInfo.referenceView = topmostViewController()?.view
        
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode:JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.Blurred)
        
        imageViewer.showFromViewController(topmostViewController(), transition: JTSImageViewControllerTransition.FromOriginalPosition)
    }
    
}
