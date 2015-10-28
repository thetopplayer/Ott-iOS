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
    @IBOutlet var authorImageView: ParseImageView!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
//        innerContentContainer?.addBorder()
        
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
        authorImageView.clear()
    }
    
    
    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func updateContents() {
        
        guard let topic = displayedTopic else {
            return
        }
        
        label.attributedText = attributedContent(topic)
        authorImageView.displayImageInFile(topic.authorAvatarFile)
    }
    
    
    private func attributedContent(topic: Topic) -> NSAttributedString {
        
        let nameColor = UIColor.blackColor()
        let handleColor = UIColor.brownColor()
        
        let nameFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let nameAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : nameColor, NSFontAttributeName: nameFont]
        
        let handleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        let handleAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : handleColor, NSFontAttributeName: handleFont]
        
        let nameString = topic.authorName! + "  "
        let fullAttrString = NSMutableAttributedString(string: nameString, attributes: nameAttributes)
        
        let handleString = "" + topic.authorHandle! + " \n"
        let handleAttrString = NSAttributedString(string: handleString, attributes: handleAttributes)
        
        fullAttrString.appendAttributedString(handleAttrString)
        
        if let bio = topic.authorBio {
            
            let bioColor = UIColor.darkGrayColor()
            let bioFont = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
            let bioAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : bioColor, NSFontAttributeName: bioFont]
            
            let bioAttrString = NSAttributedString(string: bio, attributes: bioAttributes)
            fullAttrString.appendAttributedString(bioAttrString)
        }

        return fullAttrString
    }
    
    
    private func presentAuthorInfo() {
        
        guard let topic = displayedTopic else {
            return
        }
        
        if let viewController = topmostViewController() {
            viewController.presentUserDetailViewController(withTopic: topic)
        }
    }
    
    
    @IBAction func displayAuthorDetail(sender: UIGestureRecognizer) {
        
        if sender.state != .Ended {
            return
        }
        
        presentAuthorInfo()
    }
    
}
