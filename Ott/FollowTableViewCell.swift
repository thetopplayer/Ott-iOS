//
//  FollowTableViewCell.swift
//  Ott
//
//  Created by Max on 10/1/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class FollowTableViewCell: UserTableViewCell {

    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        separatorInset = UIEdgeInsetsMake(0, 16, 0, 0)
    }
    
    enum DisplayType {
        case Followee, Follower
    }
    
    
    private var displayedFollow: Follow?
    private var displayType: DisplayType = .Followee
    
    
    func displayFolloweeForRelationship(follow: Follow?) {
        
        displayType = .Followee
        displayedFollow = follow
        updateContents()
    }
    
    
    func displayFollowerForRelationship(follow: Follow?) {
        
        displayType = .Follower
        displayedFollow = follow
        updateContents()
    }
    
    
    private func updateContents() {
        
        guard let follow = displayedFollow else {
            return
        }
        
        var name = String()
        var handle = String()
        var bio: String?
        var avatarFile: PFFile?
        
        if displayType == .Followee {
            
            name = follow.followeeName!
            handle = follow.followeeHandle!
            bio = follow.followeeBio
            avatarFile = follow.followeeAvatarFile
        }
        else if displayType == .Follower {
            
            name = follow.followerName!
            handle = follow.followerHandle!
            bio = follow.followerBio
            avatarFile = follow.followerAvatarFile
        }
        
        nameLabel.attributedText = attributedStringForUsername(name, handle: handle, bio: bio)
        
        if let avatarFile = avatarFile {
            self.avatarImageView.displayImageInFile(avatarFile, withFade: true, defaultImage: Globals.sharedInstance.defaultAvatarImage)
        }
        else {
            self.avatarImageView.image = Globals.sharedInstance.defaultAvatarImage
        }
    }
}
