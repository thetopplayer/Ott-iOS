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
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!
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
            
//            ratingLabel.text = topic.ratingToText()
//            ratingLabel.textColor = topic.ratingToColor()
            nameLabel.text = topic.name!
            if topic.comment != nil {
                commentLabel.text = topic.comment!
            }
            else {
                commentLabel.text = ""
            }
            
            statusLabel.attributedText = attributedDescription(topic)
            topicImageView?.image = topic.image
        }
    }
    
    
    private func attributedDescription(topic: Topic) -> NSAttributedString {
        
        var normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
        normalAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(12)
        
        var boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
        boldAttributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(12)
        
        let s1 = NSMutableAttributedString(string: "\(topic.numberOfPosts)", attributes: boldAttributes)
        
        let p = topic.numberOfPosts == 1 ? " rating " : " ratings "
        let s2 = NSAttributedString(string: p + "since creation by ", attributes: normalAttributes)
        let authorName = topic.author.name != nil ? topic.author.name! : "Anonymous"
        let s3 = NSAttributedString(string: authorName, attributes: boldAttributes)
        
        s1.appendAttributedString(s2)
        s1.appendAttributedString(s3)
        return s1
    }
    
}
