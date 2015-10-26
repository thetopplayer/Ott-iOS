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
    @IBOutlet var didPostImageView: UIImageView!
    

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        separatorInset = UIEdgeInsetsMake(0, 25, 0, 0)
        contentView.backgroundColor = UIColor.whiteColor()
        
        didPostImageView.tintColor = UIColor.lightGrayColor()
        
        ratingView.textColor = UIColor.whiteColor()
        ratingView.borderColor = UIColor.whiteColor()
        ratingView.borderWidth = 2
        ratingView.font = UIFont.boldSystemFontOfSize(15)
        
        authorLabel?.textColor = UIColor(white: 0.05, alpha: 1.0)
        
        if let topicImageView = topicImageView {
            topicImageView.contentMode = .ScaleAspectFill
            topicImageView.clipsToBounds = true
        }

        selectionStyle = .None
    }
    
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        topicImageView?.clear()
        didPostImageView.hidden = true
    }
    
    
    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    

    private func topicRating() -> Rating {
        return Rating(withFloat: displayedTopic!.averageRating / 10.0)
    }
    
    
    private func updateContents() {
        
        guard let topic = displayedTopic else {
            return
        }
        
        titleLabel.attributedText = attributedTitle()
        authorLabel?.text = (topic.authorName)?.uppercaseString
        
        let rating = self.topicRating()
        self.ratingView?.fillColor = rating.color()
        self.ratingView?.text = rating.text()

        if topicImageView != nil {
            statusLabel.attributedText = timeAndLocationAttributedString(topic, separator: "\n")
        }
        else {
            statusLabel.attributedText = timeAndLocationAttributedString(topic)
        }
        
        let imageFile = topic.imageFile
        topicImageView?.displayImageInFile(imageFile)
        
        if let currentUserDidPostToTopic = topic.currentUserDidPostTo {
            
            didPostImageView.hidden = !currentUserDidPostToTopic
        }
        else {
            currentUser().didPostToTopic(topic, completion: { (didPost) -> Void in
                topic.currentUserDidPostTo = didPost
                self.didPostImageView.hidden = !didPost
            })
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
