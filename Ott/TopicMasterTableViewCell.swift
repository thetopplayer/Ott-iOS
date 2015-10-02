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
    
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var commentLabel: UILabel?
    @IBOutlet var ratingView: LabeledDotView!
    @IBOutlet var topicImageView: UIImageView?
    

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        contentView.backgroundColor = UIColor.whiteColor()
        
        ratingView.textColor = UIColor.whiteColor()
        ratingView.borderColor = UIColor.whiteColor()
        ratingView.borderWidth = 2
        ratingView.font = UIFont.boldSystemFontOfSize(15)
        ratingView.hidden = true
        
        commentLabel?.textColor = UIColor(white: 0.15, alpha: 1.0)
        
        if let topicImageView = topicImageView {
            
            topicImageView.contentMode = .ScaleAspectFill
            topicImageView.clipsToBounds = true
            topicImageView.addRoundedBorder(withColor: UIColor.whiteColor())
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
    
    
    private func topicRating() -> Rating {
        return Rating(withFloat: displayedTopic!.averageRating / 10.0)
    }
    
    
    private func updateContents(ignoringImage ignoringImage: Bool) {
        
        if let topic = displayedTopic {
            
            titleLabel.attributedText = attributedTitle()
            if let comment = topic.comment {
                commentLabel?.text = comment
            }
            else {
                commentLabel?.text = ""
            }
            
            statusLabel.attributedText = updatedTimeAndLocationAttributedString(topic)
            if currentUser().didPostToTopic(topic) {
                
                let rating = topicRating()
                ratingView?.fillColor = rating.color()
                ratingView?.text = rating.text()
                ratingView?.hidden = false
            }
            else {
                
                ratingView?.hidden = true
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
    

    private func attributedTitle() -> NSAttributedString {
        
        if let topic = displayedTopic {
            
            let hashColor = currentUser().didPostToTopic(topic) ? UIColor.grayColor() : UIColor.tint()            
            let titleColor = UIColor.blackColor()
            
            let titleFont = UIFont.boldSystemFontOfSize(20)
            let hashAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : hashColor, NSFontAttributeName : titleFont]
            
            let boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : titleColor, NSFontAttributeName: titleFont]
            
            let fullString = NSMutableAttributedString(string: "#", attributes: hashAttributes)
            let s1 = NSAttributedString(string: topic.name!, attributes: boldAttributes)
            fullString.appendAttributedString(s1)
            
            return fullString
        }
        
        return NSAttributedString(string: "")
    }
    
    
//    private func attributedDescription() -> NSAttributedString {
//        
//        if let topic = displayedTopic {
//            
//            let normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(10)]
//            
//            let boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(10)]
//            
//            let s1 = NSMutableAttributedString(string: "by ", attributes: normalAttributes)
//            let authorName = topic.authorName != nil ? topic.authorName! : "Anonymous"
//            let s2 = NSAttributedString(string: authorName, attributes: boldAttributes)
//            s1.appendAttributedString(s2)
//            
//            let s3 = NSMutableAttributedString(string: " |  ", attributes: normalAttributes)
//            let s4 = NSAttributedString(string: "\(topic.numberOfPosts)", attributes: boldAttributes)
//            let p = topic.numberOfPosts == 1 ? " post" : " posts"
//            let s5 = NSAttributedString(string: p, attributes: normalAttributes)
//            s3.appendAttributedString(s4)
//            s3.appendAttributedString(s5)
//            
//            s1.appendAttributedString(s3)
//            return s1
//        }
//        
//        return NSAttributedString(string: "")
//    }
    
}
