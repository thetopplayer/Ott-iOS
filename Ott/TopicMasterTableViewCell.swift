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
    

    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        innerContentContainer?.addBorder()
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
    
    
    private var _displayedTopic: Topic?
    var displayedTopic: Topic? {
        
        set {
            
            if _displayedTopic == nil {
                _displayedTopic = newValue
                updateContents(ignoringImage: false)
            }
            else {
                
                if newValue!.isEqual(_displayedTopic) {
                    updateContents(ignoringImage: true)
                }
                else {
                    _displayedTopic = newValue
                    updateContents(ignoringImage: false)
                }
           }
        }
        
        get {
            return _displayedTopic
        }
    }
    
    
    private func updateContents(ignoringImage ignoringImage: Bool) {
        
        if let topic = displayedTopic {
            
            topBarLabel.attributedText = attributedDescription()
            contentLabel.attributedText = attributedContent()
            statusLabel.attributedText = updatedTimeAndLocationAttributedString(topic)
            
            if currentUser().didPostToTopic(topic) {
                responseStatusImageView.tintColor = UIColor.lightGrayColor()
                responseStatusImageView.image = TopicMasterTableViewCell.didRespondImage
            }
            else {
                responseStatusImageView.tintColor = UIColor.tint()
                responseStatusImageView.image = TopicMasterTableViewCell.didNotRespondImage
            }
            
            if topic.hasImage() && (ignoringImage == false) {
                
                topic.getImage() {(success, image) in
                    
                    if success {
                        self.topicImageView!.setImageWithFade(image)
                    }
                }
            }
        }
    }


    private func attributedContent() -> NSAttributedString {
        
        if let topic = displayedTopic {
            
            let titleFont = UIFont.systemFontOfSize(22)
            let hashAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor(), NSFontAttributeName : titleFont]
            
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
            
            let normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(12)]
            
            let boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(12)]
            
            let s1 = NSMutableAttributedString(string: "by ", attributes: normalAttributes)
            let authorName = topic.authorName != nil ? topic.authorName! : "Anonymous"
            let s2 = NSAttributedString(string: authorName, attributes: boldAttributes)
            s1.appendAttributedString(s2)
            
            let s3 = NSMutableAttributedString(string: " |  ", attributes: normalAttributes)
            let s4 = NSAttributedString(string: "\(topic.numberOfPosts)", attributes: boldAttributes)
            let p = topic.numberOfPosts == 1 ? " post" : " posts"
            let s5 = NSAttributedString(string: p, attributes: normalAttributes)
            s3.appendAttributedString(s4)
            s3.appendAttributedString(s5)
            
            s1.appendAttributedString(s3)
            return s1
        }
        
        return NSAttributedString(string: "")
    }
    
}
