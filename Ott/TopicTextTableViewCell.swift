//
//  TopicTextTableViewCell.swift
//  Ott
//
//  Created by Max on 7/7/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicTextTableViewCell: TableViewCell {

    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var contentLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.whiteColor()
        selectionStyle = .None
    }

    
    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func updateContents() {
        
        if let topic = displayedTopic {
            
            statusLabel.attributedText = timeAndLocationAttributedString(topic)
            contentLabel.attributedText = attributedContent(topic)
        }
    }

    
    private func attributedContent(topic: Topic) -> NSAttributedString {
        
        let titleFont = UIFont.systemFontOfSize(32)
//        let hashAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor(), NSFontAttributeName : titleFont]
        
        let titleAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: titleFont]
        
//        let fullString = NSMutableAttributedString(string: "#", attributes: hashAttributes)
        let fullString = NSMutableAttributedString(string: topic.name!, attributes: titleAttributes)
//        fullString.appendAttributedString(s1)
        
        if let comment = topic.comment {
            
            let color = UIColor.darkGrayColor()
            var commentAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : color]
            commentAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(15)
            
            let text = "\n" + comment
            let s2 = NSAttributedString(string: text, attributes: commentAttributes)
            
            fullString.appendAttributedString(s2)
        }
        
        return fullString
    }
    
}
