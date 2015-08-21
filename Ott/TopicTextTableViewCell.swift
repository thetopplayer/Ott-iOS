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
        
        var titleAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.blackColor()]
        titleAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(32)
        
        let s1 = NSMutableAttributedString(string: topic.name!, attributes: titleAttributes)
        
        if let comment = topic.comment {
            
            let color = UIColor.darkGrayColor()
            var commentAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : color]
            commentAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(15)
            
            let text = "\n" + comment
            let s2 = NSAttributedString(string: text, attributes: commentAttributes)
            
            s1.appendAttributedString(s2)
        }
        
        return s1
    }
    
}
