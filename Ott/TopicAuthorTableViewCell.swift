//
//  TopicAuthorTableViewCell.swift
//  Ott
//
//  Created by Max on 7/10/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicAuthorTableViewCell: TableViewCell {

    @IBOutlet var authorNameLabel: UILabel!
    @IBOutlet var authorHandleLabel: UILabel!
    @IBOutlet var authorImageView: UIImageView!
    @IBOutlet var followButton: UIButton!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        innerContentContainer?.addBorder()
        authorImageView.clipsToBounds = true
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
        
        authorNameLabel.text = topic.authorName
        authorHandleLabel.text = topic.authorHandle
        
        if topic.hasAuthorAvatar() {
            topic.getAuthorAvatarImage({ (success, image) -> Void in
                
                if success {
                    self.authorImageView!.setImageWithFade(image)
                }
            })
        }
        
        if currentUser().didAuthorTopic(topic) {
            
            followButton.hidden = true
        }
        else {
            
            followButton.hidden = false
            
            if currentUser().isFollowingUserWithHandle(topic.authorHandle!) {
                
                followButton.setTitle("Unfollow", forState: UIControlState.Normal)
                let color = UIColor.redColor()
                followButton.tintColor = color
                followButton.addRoundedBorder(withColor: color)
            }
            else {
                
                followButton.setTitle("Follow", forState: UIControlState.Normal)
                let color = UIColor.tint()
                followButton.tintColor = color
                followButton.addRoundedBorder(withColor: color)
            }
        }
    }
    
}
