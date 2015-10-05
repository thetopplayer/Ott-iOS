//
//  FollowTableViewCell.swift
//  Ott
//
//  Created by Max on 10/1/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class FollowTableViewCell: TableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: ParseImageView!
    @IBOutlet weak var handleTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        avatarImageView.addRoundedBorder()
    }
    
    
    var displayedFollow: Follow? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func attributedTextForBio(bio: String?) -> NSAttributedString {
        
        if let bio = bio {
            
            let normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.mediumText(), NSFontAttributeName: UIFont.systemFontOfSize(14)]
            return NSAttributedString(string: bio, attributes: normalAttributes)
            
        }
        else {
            
            let inactiveAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.lightText(), NSFontAttributeName: UIFont.systemFontOfSize(14)]
            return NSAttributedString(string: "(no bio)", attributes: inactiveAttributes)
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
        
//        if follow.hasFolloweeAvatar() {
//            follow.getFolloweeAvatar({ (success, image) -> Void in
//                
//                self.avatarImageView!.image = image
//            })
//        }
    }
}