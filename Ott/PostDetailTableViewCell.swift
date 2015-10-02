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
    @IBOutlet var commentLabel: UILabel!

    
    
    var displayedPost: Post? {
        
        didSet {
            updateContents()
        }
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        innerContentContainer?.addRoundedBorder()
        contentView.backgroundColor = UIColor.background()
        innerContentContainer?.backgroundColor = UIColor.whiteColor()

        topBar.backgroundColor = UIColor.whiteColor()
        topBar.addBorder(withColor: UIColor(white: 0.8, alpha: 1.0))
        statusBar.backgroundColor = UIColor.clearColor()
        
        selectionStyle = .None
    }
    
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        updateContents()
    }
    
    
    private func updateContents() {
        
        if let post = displayedPost {
            
            topBarLabel.attributedText = attributedDescription(post)
            
            ratingLabel.text = post.rating?.text()
            ratingLabel.textColor = post.rating?.color()
            let comment = post.comment != nil ? post.comment! : ""
            commentLabel.text = comment
            
            statusLabel.attributedText = timeAndLocationAttributedString(post)
        }
        else {
            
            topBarLabel.text = ""
            ratingLabel.text = ""
            statusLabel.text = ""
        }
    }
    
    
    private func attributedDescription(topic: Post) -> NSAttributedString {
        
        let font = UIFont.systemFontOfSize(12)
        let normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName: font]
        
        let boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: font]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        
        let s1 = NSMutableAttributedString(string: "by ", attributes: normalAttributes)
        let authorName = topic.authorName != nil ? topic.authorName! : "Anonymous"
        let s2 = NSAttributedString(string: authorName, attributes: boldAttributes)
        
        s1.appendAttributedString(s2)
        return s1
    }

}
