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
    
    
    var displayedFollow: Follow? {
        
        didSet {
            updateContents()
        }
    }
    
    private func updateContents() {
        
        guard let follow = displayedFollow else {
            return
        }
        
        nameLabel.attributedText = attributedStringForUsername(follow.followeeName!, handle: follow.followeeHandle!, bio: follow.followeeBio)
        
        if let avatarFile = follow.followeeAvatarFile {
            self.avatarImageView.displayImageInFile(avatarFile, withFade: true, defaultImage: Globals.sharedInstance.defaultAvatarImage)
        }
        else {
            self.avatarImageView.image = Globals.sharedInstance.defaultAvatarImage
        }
    }
}
