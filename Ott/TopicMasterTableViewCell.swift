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
    @IBOutlet var topicImageView: ParseImageView?
    

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
            if let comment = topic.comment {
                commentLabel?.text = comment
            }
            else {
                commentLabel?.text = ""
            }
            
            statusLabel.attributedText = updatedTimeAndLocationAttributedString(topic)
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
        
        let hashColor = topic.currentUserDidPostTo ? UIColor.grayColor() : UIColor.tint()
        let titleColor = UIColor.blackColor()
        
        let titleFont = UIFont.boldSystemFontOfSize(20)
        let hashAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : hashColor, NSFontAttributeName : titleFont]
        
        let boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : titleColor, NSFontAttributeName: titleFont]
        
        let fullString = NSMutableAttributedString(string: "#", attributes: hashAttributes)
        let s1 = NSAttributedString(string: topic.name!, attributes: boldAttributes)
        fullString.appendAttributedString(s1)
        
        return fullString
    }
}
