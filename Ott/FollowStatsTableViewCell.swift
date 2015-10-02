//
//  FollowStatsTableViewCell.swift
//  Ott
//
//  Created by Max on 9/29/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class FollowStatsTableViewCell: TableViewCell {

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
            setUnfollowButton()
        }
        else {
            setFollowButton()
        }
        
        followingInfoLabel.attributedText = {
            
            let normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName: UIFont.systemFontOfSize(13)]
            
            let boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(13)]
            
            let s1 = NSMutableAttributedString(string: "FOLLOWERS: ", attributes: normalAttributes)
            let followerCountString: String = {
               
                let number = user.followersCount
                if number < 1000 {
                    return "\(number)"
                }
                
                let str = NSString(format: "%.1fk", Float(number) / 1000)
                return str as String
            }()
            
            let s2 = NSAttributedString(string: followerCountString, attributes: boldAttributes)
            s1.appendAttributedString(s2)
            
            let s3 = NSMutableAttributedString(string: "   FOLLOWING: ", attributes: normalAttributes)
            
            let followingCountString: String = {
                
                let number = user.followingCount
                if number < 1000 {
                    return "\(number)"
                }
                
                let str = NSString(format: "%.1fk", Float(number) / 1000)
                return str as String
                }()
            
            let s4 = NSAttributedString(string: followingCountString, attributes: boldAttributes)
            s3.appendAttributedString(s4)
            s1.appendAttributedString(s3)
            return s1
            }()
        
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
        
        let removeFollowOperation = RemoveFollowOperation(followerHandle: currentUser().handle!, followeeHandle: user.handle!)
        MaintenanceQueue.sharedInstance.addOperation(removeFollowOperation)
        setFollowButton()
    }
    
}
