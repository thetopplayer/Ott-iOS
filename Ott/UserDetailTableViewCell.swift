//
//  UserDetailTableViewCell.swift
//  Ott
//
//  Created by Max on 9/23/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UserDetailTableViewCell: TableViewCell {

    @IBOutlet weak var captionImageView: UIImageView!
    @IBOutlet weak var avatarImageContainerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var handleTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var settingsButton: UIButton!

    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        avatarImageContainerView.addRoundedBorder(withColor: UIColor.whiteColor())
        avatarImageView.addRoundedBorder()
        exportButton.tintColor = UIColor.tint()
        captionImageView.layer.masksToBounds = true
        
        settingsButton.backgroundColor = UIColor.whiteColor()
        settingsButton.tintColor = UIColor.tint()
        settingsButton.addRoundedBorder(withColor: UIColor.tint())
        settingsButton.hidden = true
    }
    
    
    var displayedUser: User? {
        
        didSet {
            updateDisplay()
        }
    }
    
    
    private func displayingCurrentUser() -> Bool {
        
        guard let user = displayedUser else {
            return false
        }
        
        return (user.isEqual(currentUser()))!
    }
    
    
    private func updateDisplay() {
    
        guard let user = displayedUser else {
            return
        }
        
        settingsButton.hidden = displayingCurrentUser()
        
        handleTextLabel.text = user.handle
        let bioText = user.bio != nil ? user.bio : "(no bio)"
        bioTextLabel.text = bioText
        
        if user.hasAvatar() {
            user.getAvatar({ (success, image) -> Void in
                
                if success {
                    self.avatarImageView!.setImageWithFade(image)
                }
            })
        }
    }
}
