//
//  UserFollowTableViewCell.swift
//  Ott
//
//  Created by Max on 9/29/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UserFollowTableViewCell: TableViewCell {

    @IBOutlet var followingInfoLabel: UILabel!
    @IBOutlet var followButton: UIButton!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
//        innerContentContainer?.backgroundColor = UIColor(white: 1.0, alpha: 0.9)
        innerContentContainer?.addBorder()
    }
    
    
    var displayedUser: User? {
        
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
        
        guard let user = displayedUser else {
            return
        }
        
        if currentUser().isFollowingUserWithHandle(user.handle!) {
            setFollowButton()
        }
        else {
            setUnfollowButton()
        }
        
//        authorNameLabel.text = topic.authorName
//        authorHandleLabel.text = topic.authorHandle
//        authorBioLabel.text = topic.authorBio
//        
//        if topic.hasAuthorAvatar() {
//            topic.getAuthorAvatarImage({ (success, image) -> Void in
//                
//                if success {
//                    self.authorImageView!.setImageWithFade(image)
//                }
//            })
//        }
//        
//        if currentUser().didAuthorTopic(topic) {
//            
//            followButton.hidden = true
//        }
//        else {
//            
//            followButton.hidden = false
//            
//            if currentUser().isFollowingUserWithHandle(topic.authorHandle!) {
//                setUnfollowButton()
//            }
//            else {
//                setFollowButton()
//            }
//        }
    }
    
    
    @IBAction func handleFollowAction(sender: AnyObject) {
        
        guard let user = displayedUser else {
            return
        }
        
        let createFollowOperation = CreateFollowOperation(followeeHandle: user.handle!)
        MaintenanceQueue.sharedInstance.addOperation(createFollowOperation)
        setUnfollowButton()
    }
    
    
    @IBAction func handleUnfollowAction(sender: AnyObject) {
        
        guard let user = displayedUser else {
            return
        }
        
        let removeFollowOperation = RemoveFollowOperation(followeeHandle: user.handle!)
        MaintenanceQueue.sharedInstance.addOperation(removeFollowOperation)
        setFollowButton()
    }
    
}
