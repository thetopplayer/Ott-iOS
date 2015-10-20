//
//  FollowTableViewCell.swift
//  Ott
//
//  Created by Max on 10/1/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class FollowTableViewCell: UserTableViewCell {

    var displayedFollow: Follow? {
        
        didSet {
            updateContents()
        }
    }
    
    private func updateContents() {
        
        guard let follow = displayedFollow else {
            return
        }
        
        nameLabel.text = follow.followeeName
        handleTextLabel.text = follow.followeeHandle
        bioTextLabel.attributedText = attributedTextForBio(follow.followeeBio)
        self.avatarImageView!.displayImageInFile(follow.followeeAvatarFile)
    }
}
