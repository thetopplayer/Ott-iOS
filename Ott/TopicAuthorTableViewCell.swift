//
//  TopicAuthorTableViewCell.swift
//  Ott
//
//  Created by Max on 7/10/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicAuthorTableViewCell: TableViewCell {

    @IBOutlet var label: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.clearColor()
    }
    
    
    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func updateContents() {
        
        if let topic = displayedTopic {
            label.attributedText = attributedDescription(topic)
        }
    }
    
    
    private func attributedDescription(topic: Topic) -> NSAttributedString {
        
        var normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
        normalAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(12)
        
        var boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
        boldAttributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(12)
        
        var blueBoldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.aqua()]
        blueBoldAttributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(12)
        
        let s1 = NSMutableAttributedString(string: "Posted ", attributes: normalAttributes)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        
        let s2 = NSAttributedString(string: "\(dateFormatter.stringFromDate(topic.timestamp))", attributes: boldAttributes)
        
        let s3 = NSAttributedString(string: " by ", attributes: normalAttributes)
        
        let authorName = topic.author.name != nil ? topic.author.name! : "Anonymous"
        let s4 = NSAttributedString(string: authorName, attributes: blueBoldAttributes)
        
        s1.appendAttributedString(s2)
        s1.appendAttributedString(s3)
        s1.appendAttributedString(s4)
        
        return s1
    }

}
