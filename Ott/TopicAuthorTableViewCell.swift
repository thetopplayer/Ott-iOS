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
        
        if let topic = displayedTopic {
            
            authorNameLabel.text = topic.authorName
            authorHandleLabel.text = topic.authorHandle
            
            if let authorHandle = topic.authorHandle {
                
                followButton.hidden = false
                
                if currentUser().isFollowingUserWithHandle(authorHandle) {
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
            else {
                followButton.hidden = true
            }
            
        }
    }
}
