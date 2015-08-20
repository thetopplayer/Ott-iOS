//
//  TopicMasterTableViewCell.swift
//  Ott
//
//  Created by Max on 6/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import CoreLocation
import QuartzCore

class TopicMasterTableViewCell: TableViewCell {

    @IBOutlet var topBar: UIView!
    @IBOutlet var topBarLabel: UILabel!
    @IBOutlet var statusBar: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var topicImageView: UIImageView?
    
    
    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        innerContentContainer?.addRoundedBorder()
        topBar.backgroundColor = UIColor.whiteColor()
        topBar.addBorder(withColor: UIColor(white: 0.8, alpha: 1.0))
        statusBar.backgroundColor = UIColor.clearColor()
        
        if let topicImageView = topicImageView {
            
            topicImageView.contentMode = .ScaleAspectFill
            topicImageView.clipsToBounds = true
        }
        
        selectionStyle = .None
    }
    
    
    private func updateContents() {
        
        if let topic = displayedTopic {
            
            topBarLabel.attributedText = timeAndLocationAttributedString(topic)
            contentLabel.attributedText = attributedContent()
            statusLabel.attributedText = attributedDescription()
            
            if topic.hasImage {

                topic.getImage() {(success, image) in
                 
                    if success {
                        self.topicImageView!.image = image
                    }
                }
            }
        }
    }
    
    
    private func attributedContent() -> NSAttributedString {
        
        if let topic = displayedTopic {
            
            var boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.blackColor()]
            boldAttributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(22)
            
            let s1 = NSMutableAttributedString(string: topic.name!, attributes: boldAttributes)
            
            if let comment = topic.comment {
                
                var normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
                normalAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(14)
                
                let text = "\n" + comment
                let s2 = NSAttributedString(string: text, attributes: normalAttributes)
                s1.appendAttributedString(s2)
            }
            
            return s1
        }
        
        return NSAttributedString(string: "")
    }
    
    
    private func attributedDescription() -> NSAttributedString {
        
        if let topic = displayedTopic {
            
            var normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
            normalAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(12)
            
            var boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
            boldAttributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(12)
            
            let s1 = NSMutableAttributedString(string: "\(topic.numberOfPosts)", attributes: boldAttributes)
            
            let p = topic.numberOfPosts == 1 ? " rating " : " ratings "
            let s2 = NSAttributedString(string: p + "since creation by ", attributes: normalAttributes)
            let authorName = topic.authorName != nil ? topic.authorName! : "Anonymous"
            let s3 = NSAttributedString(string: authorName, attributes: boldAttributes)
            
            s1.appendAttributedString(s2)
            s1.appendAttributedString(s3)
            return s1
        }
        
        return NSAttributedString(string: "")
    }
    
}
