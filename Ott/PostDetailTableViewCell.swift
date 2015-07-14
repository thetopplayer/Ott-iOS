//
//  PostDetailTableViewCell.swift
//  Ott
//
//  Created by Max on 7/14/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class PostDetailTableViewCell: TableViewCell {

    @IBOutlet var topBar: UIView!
    @IBOutlet var topBarLabel: UILabel!
    @IBOutlet var statusBar: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var commentTextView: UITextView!

    
    
    var displayedPost: Post? {
        
        didSet {
            updateContents()
        }
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        topBar.backgroundColor = UIColor.whiteColor()
        topBar.addBorder(withColor: UIColor(white: 0.8, alpha: 1.0))
        statusBar.backgroundColor = UIColor.clearColor()
        
        commentTextView.editable = false
        commentTextView.selectable = false
        
        selectionStyle = .None
    }
    
    
    private func updateContents() {
        
        if let post = displayedPost {
            
            topBarLabel.attributedText = timeAndLocationAttributedString(post)
            
            ratingLabel.text = post.ratingToText()
            ratingLabel.textColor = post.ratingToColor()
            if post.comment != nil {
                commentTextView.text = post.comment!
            }
            else {
                commentTextView.text = ""
            }
            
            statusLabel.attributedText = attributedDescription(post)
        }
    }
    
    
    private func attributedDescription(topic: Post) -> NSAttributedString {
        
        var normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
        normalAttributes[NSFontAttributeName] = UIFont.systemFontOfSize(12)
        
        var boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
        boldAttributes[NSFontAttributeName] = UIFont.boldSystemFontOfSize(12)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        
        let s1 = NSMutableAttributedString(string: "Posted by ", attributes: normalAttributes)
        let authorName = topic.author.name != nil ? topic.author.name! : "Anonymous"
        let s2 = NSAttributedString(string: authorName, attributes: boldAttributes)
        
        s1.appendAttributedString(s2)
        return s1
    }

}
