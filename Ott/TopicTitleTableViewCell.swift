//
//  TopicTitleTableViewCell.swift
//  Ott
//
//  Created by Max on 7/7/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicTitleTableViewCell: TableViewCell {

    @IBOutlet var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        innerContentContainer?.addBorder()
        
        selectionStyle = .None
    }

    
    var displayedTopic: TopicObject? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func updateContents() {
        
        let didPostToTopic = currentUser().didPostToTopic(displayedTopic!)
        titleLabel.attributedText = attributedTitle(displayedTopic!, displayingRating: didPostToTopic)
    }

    
    private func attributedTitle(topic: TopicObject, displayingRating: Bool) -> NSAttributedString {
        
        var normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.blackColor()]
        normalAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(32)
        
        let s1 = NSMutableAttributedString(string: topic.name!, attributes: normalAttributes)
        
        if displayingRating {
            
            let color = topic.rating!.color()
            var boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : color]
            boldAttributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(32)
            
            let text = "  \u{00b7}  " + topic.rating!.text()
            let s2 = NSAttributedString(string: text, attributes: boldAttributes)
            
            s1.appendAttributedString(s2)
        }
        
        return s1
    }
    
}
