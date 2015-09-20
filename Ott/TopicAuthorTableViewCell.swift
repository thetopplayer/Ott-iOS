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
    @IBOutlet var authorBioLabel: UILabel!
    @IBOutlet var authorImageView: UIImageView!
    @IBOutlet var followButton: UIButton!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        innerContentContainer?.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        innerContentContainer?.addBorder()
        authorImageView.addRoundedBorder()
        authorHandleLabel.textColor = UIColor.tint()
    }
    
    
    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func setFollowButton() {
    
        followButton.setTitle("Follow", forState: UIControlState.Normal)
        let color = UIColor.tint()
        followButton.tintColor = color
        followButton.addRoundedBorder(withColor: color)
        
        followButton.removeTarget(self, action: "handleUnfollowAction:", forControlEvents: .TouchUpInside)
        followButton.addTarget(self, action: "handleFollowAction:", forControlEvents: .TouchUpInside)
    }
    
    
    private func setUnfollowButton() {
        
        followButton.setTitle("Unfollow", forState: UIControlState.Normal)
        let color = UIColor.redColor()
        followButton.tintColor = color
        followButton.addRoundedBorder(withColor: color)
        
        followButton.removeTarget(self, action: "handleFollowAction:", forControlEvents: .TouchUpInside)
        followButton.addTarget(self, action: "handleUnfollowAction:", forControlEvents: .TouchUpInside)
    }
    
    
    private func updateContents() {
        
        guard let topic = displayedTopic else {
            return
        }
        
        authorNameLabel.text = topic.authorName
        authorHandleLabel.text = topic.authorHandle
        authorBioLabel.text = topic.authorBio
        
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
                setUnfollowButton()
            }
            else {
                setFollowButton()
            }
        }
    }
    
    
    @IBAction func handleFollowAction(sender: AnyObject) {
        
        guard let topic = displayedTopic else {
            return
        }
        
        let createFollowOperation = CreateFollowOperation(followeeHandle: topic.authorHandle!)
        MaintenanceQueue.sharedInstance.addOperation(createFollowOperation)
        setUnfollowButton()
    }
    
    
    @IBAction func handleUnfollowAction(sender: AnyObject) {
        
        guard let topic = displayedTopic else {
            return
        }
        
        let removeFollowOperation = RemoveFollowOperation(followeeHandle: topic.authorHandle!)
        MaintenanceQueue.sharedInstance.addOperation(removeFollowOperation)
        setFollowButton()
    }
    
}
