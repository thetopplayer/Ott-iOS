//
//  TopicDetailSummaryTableViewCell.swift
//  Ott
//
//  Created by Max on 7/10/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicDetailSummaryTableViewCell: TableViewCell {

    @IBOutlet var summaryLabel: UILabel!
    @IBOutlet var authorNameLabel: UILabel!
    @IBOutlet var authorHandleLabel: UILabel!
    @IBOutlet var authorImageView: UIImageView!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.whiteColor()
        innerContentContainer?.backgroundColor = UIColor(white: 0.95, alpha: 1.0)
        authorImageView.clipsToBounds = true
    }
    
    
    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func updateContents() {
        
        if let topic = displayedTopic {
            summaryLabel.attributedText = attributedDescription(topic)
        }
    }
    
    
    private func attributedDescription(topic: Topic) -> NSAttributedString {
        
        var normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
        normalAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(14)
        
        var boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
        boldAttributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(14)
        
        let s1 = NSMutableAttributedString(string: "\(topic.numberOfPosts)", attributes: boldAttributes)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        
        let p = topic.numberOfPosts == 1 ? " post " : " posts "
        let s2 = NSAttributedString(string: p + "since creation on ", attributes: normalAttributes)
        let dateString = dateFormatter.stringFromDate(topic.timestamp)
        let s3 = NSAttributedString(string: dateString, attributes: boldAttributes)
        
        s1.appendAttributedString(s2)
        s1.appendAttributedString(s3)
        return s1
    }

}
