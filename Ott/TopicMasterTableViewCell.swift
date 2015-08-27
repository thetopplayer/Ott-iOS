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
    @IBOutlet var responseStatusImageView: UIImageView!
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
            topicImageView.addBorder()
        }
        
        selectionStyle = .None
    }
    
    
    static var didRespondImage: UIImage = {
        return UIImage(named: "arrowBack")!
        }()
    
    
    static var didNotRespondImage: UIImage = {
        return UIImage(named: "smallDot")!
        }()
    
    
    private func updateContents() {
        
        if let topic = displayedTopic {
            
            topBarLabel.attributedText = updatedTimeAndLocationAttributedString(topic)
            contentLabel.attributedText = attributedContent()
            statusLabel.attributedText = attributedDescription()
            
            if currentUser().didPostToTopic(topic) {
                responseStatusImageView.tintColor = UIColor.lightGrayColor()
                responseStatusImageView.image = TopicMasterTableViewCell.didRespondImage
            }
            else {
                responseStatusImageView.tintColor = UIColor.aqua()
                responseStatusImageView.image = TopicMasterTableViewCell.didNotRespondImage
            }
            
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
            
            let titleFont = UIFont.systemFontOfSize(22)
            let hashAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName : titleFont]
            
            let boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: titleFont]
            
            let fullString = NSMutableAttributedString(string: "#", attributes: hashAttributes)
            let s1 = NSAttributedString(string: topic.name!, attributes: boldAttributes)
            fullString.appendAttributedString(s1)
            
            if let comment = topic.comment {
                
                let normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(14)]
                
                let text = "\n" + comment
                let s2 = NSAttributedString(string: text, attributes: normalAttributes)
                fullString.appendAttributedString(s2)
            }
            
            return fullString
        }
        
        return NSAttributedString(string: "")
    }
    
    
    private func attributedDescription() -> NSAttributedString {
        
        if let topic = displayedTopic {
            
            let normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor(), NSFontAttributeName: UIFont.systemFontOfSize(12)]
            
            let boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(12)]
            
            let s1 = NSMutableAttributedString(string: "\(topic.numberOfPosts)", attributes: boldAttributes)
            
            let p = topic.numberOfPosts == 1 ? " post | " : " posts | "
            let s2 = NSAttributedString(string: p + "authored by ", attributes: normalAttributes)
            let authorName = topic.authorName != nil ? topic.authorName! : "Anonymous"
            let s3 = NSAttributedString(string: authorName, attributes: boldAttributes)
            
            s1.appendAttributedString(s2)
            s1.appendAttributedString(s3)
            return s1
        }
        
        return NSAttributedString(string: "")
    }
    
}
