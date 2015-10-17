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
    @IBOutlet var authorLabel: UILabel?
    @IBOutlet var ratingView: LabeledDotView!
    @IBOutlet var topicImageView: ParseImageView?
    @IBOutlet var updatedIndicatorImageView: UIImageView!
    

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        separatorInset = UIEdgeInsetsMake(0, 21, 0, 0)

        contentView.backgroundColor = UIColor.whiteColor()
        
        updatedIndicatorImageView.tintColor = UIColor.tint()
        
        ratingView.textColor = UIColor.whiteColor()
        ratingView.borderColor = UIColor.whiteColor()
        ratingView.borderWidth = 2
        ratingView.font = UIFont.boldSystemFontOfSize(15)
        ratingView.hidden = true
        
        authorLabel?.textColor = UIColor(white: 0.05, alpha: 1.0)
        
        if let topicImageView = topicImageView {
            
            topicImageView.contentMode = .ScaleAspectFill
            topicImageView.clipsToBounds = true
            topicImageView.addRoundedBorder(withColor: UIColor.whiteColor())
        }

        selectionStyle = .None
    }
    
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        topicImageView?.clear()
    }
    
    
    static var didRespondImage: UIImage = {
        return UIImage(named: "arrowBack")!
        }()
    
    
    static var didNotRespondImage: UIImage = {
        return UIImage(named: "smallDot")!
        }()
    
    
    var displayedTopic: Topic? {
        
        didSet {
            
            updateContents()
        }
    }
    

    private func topicRating() -> Rating {
        return Rating(withFloat: displayedTopic!.averageRating / 10.0)
    }
    
    
    private func updateContents() {
        
        if let topic = displayedTopic {
            
            titleLabel.attributedText = attributedTitle()
            authorLabel?.text = (topic.authorName)?.uppercaseString
            
            if let lastPostDate = topic.lastPostDate {
                if let lastViewedDate = topic.currentUserViewedAt {
                    updatedIndicatorImageView.hidden = lastPostDate.earlierDate(lastViewedDate) == lastPostDate
                }
                else {
                    updatedIndicatorImageView.hidden = false
                }
            }
            else {
                updatedIndicatorImageView.hidden = false
            }
            
            if topicImageView != nil {
                statusLabel.attributedText = timeAndLocationAttributedString(topic, separator: "\n")
            }
            else {
                statusLabel.attributedText = timeAndLocationAttributedString(topic)
            }

            if topic.currentUserDidPostTo {
                
                let rating = self.topicRating()
                self.ratingView?.fillColor = rating.color()
                self.ratingView?.text = rating.text()
                self.ratingView?.hidden = false
            }
            else {
                self.ratingView?.hidden = true
            }
            
            let imageFile = topic.imageFile
            topicImageView?.displayImageInFile(imageFile)
        }
    }
    
    
    private func attributedTitle() -> NSAttributedString {
        
        guard let topic = displayedTopic else {
            return NSAttributedString(string: "")
        }
        
        let nameColor = UIColor.blackColor()
        let commentColor = UIColor.darkGrayColor()
        
        let titleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let titleAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : nameColor, NSFontAttributeName: titleFont]
        
        let nameString = topic.name! + "  "
        let fullString = NSMutableAttributedString(string: nameString, attributes: titleAttributes)
        
        if let comments = topic.comment {
            
            let commentFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
            let commentAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : commentColor, NSFontAttributeName : commentFont]
            
            let s1 = NSAttributedString(string: comments, attributes: commentAttributes)
            fullString.appendAttributedString(s1)
        }
        
        return fullString
    }
}
