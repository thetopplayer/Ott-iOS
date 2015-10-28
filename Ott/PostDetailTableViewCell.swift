//
//  PostDetailTableViewCell.swift
//  Ott
//
//  Created by Max on 7/14/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class PostDetailTableViewCell: TableViewCell {

    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var label: UILabel!
    @IBOutlet var authorImageView: ParseImageView!

    
    
    var displayedPost: Post? {
        
        didSet {
            updateContents()
        }
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        separatorInset = UIEdgeInsetsMake(0, 16, 0, 0)
        innerContentContainer?.backgroundColor = UIColor.whiteColor()
        
        selectionStyle = .None
        
        let tapGR: UIGestureRecognizer = {
            let gr = UITapGestureRecognizer()
            gr.addTarget(self, action: "displayAuthorDetail:")
            return gr
        }()
        
        authorImageView.addRoundedBorder(withColor: UIColor.clearColor())
        authorImageView.addGestureRecognizer(tapGR)
        authorImageView.userInteractionEnabled = true
    }
    
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        updateContents()
        authorImageView.clear()
    }
    
    
    private func updateContents() {
        
        guard let post = displayedPost else {
            return
        }
        
        ratingLabel.text = post.rating!.text()
        ratingLabel.textColor = post.rating!.color()

        label.attributedText = attributedContent(post)
        authorImageView.displayImageInFile(post.authorAvatarFile)
    }
    
    
    private func attributedContent(post: Post) -> NSAttributedString {
        
        let nameColor = UIColor(white: 0.05, alpha: 1.0)
        let handleColor = UIColor.brownColor()
        
        let nameFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        let nameAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : nameColor, NSFontAttributeName: nameFont]
        
        let handleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        let handleAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : handleColor, NSFontAttributeName: handleFont]
        
        let nameString = post.authorName! + "  "
        let fullAttrString = NSMutableAttributedString(string: nameString, attributes: nameAttributes)
        
        let handleString = "" + post.authorHandle! + " \n"
        let handleAttrString = NSAttributedString(string: handleString, attributes: handleAttributes)
        
        fullAttrString.appendAttributedString(handleAttrString)
        
        fullAttrString.appendAttributedString(timeAndLocationAttributedString(post))
        
        if let comment = post.comment {
            
            let commentColor = UIColor.darkGrayColor()
            let commentFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            let commentAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : commentColor, NSFontAttributeName: commentFont]
            
            let paddedComment = "\n\n" + comment
            
            let commentAttrString = NSAttributedString(string: paddedComment, attributes: commentAttributes)
            fullAttrString.appendAttributedString(commentAttrString)
        }
        
        return fullAttrString
    }
    
    
    private func attributedDescription(post: Post) -> NSAttributedString {
        
        let font = UIFont.systemFontOfSize(12)
        let normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName: font]
        
        let boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: font]
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        
        let s1 = NSMutableAttributedString(string: "by ", attributes: normalAttributes)
        let authorName = post.authorName != nil ? post.authorName! : "Anonymous"
        let s2 = NSAttributedString(string: authorName, attributes: boldAttributes)
        
        s1.appendAttributedString(s2)
        return s1
    }

    
    private func presentAuthorInfo() {
        
        guard let post = displayedPost else {
            return
        }
        
        if let viewController = topmostViewController() {
            viewController.presentUserDetailViewController(withPost: post)
        }
    }
    
    
    @IBAction func displayAuthorDetail(sender: UIGestureRecognizer) {
        
        if sender.state != .Ended {
            return
        }
        
        presentAuthorInfo()
    }
    
}
