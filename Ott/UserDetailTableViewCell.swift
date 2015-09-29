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
    
    
    
    //MARK: - Data
    
    private var displayingCurrentUser = false
    
    private var topic: Topic?
    func fetchUserFromTopic(topic: Topic) {
        
        self.topic = topic
        
        displayingCurrentUser = topic.authorHandle == currentUser().handle!
        updateDisplayForTopic()
    }
    
    
    var displayedUser: User? {
        
        didSet {
            
            if let user = displayedUser {
                displayingCurrentUser = user.isEqual(currentUser())
                updateDisplayForUser()
            }
            else {
                displayingCurrentUser = false
            }
        }
    }
    
    
    
    //MARK: - Display
    
    private func updateDisplayForTopic() {
        
        guard let topic = topic else {
            return
        }
        
        settingsButton.hidden = displayingCurrentUser == false
        
        handleTextLabel.text = topic.authorHandle
        let bioText = topic.authorBio != nil ? topic.authorBio : "(no bio)"
        bioTextLabel.text = bioText
        
        if topic.hasAuthorAvatar() {
            topic.getAuthorAvatarImage({ (success, image) -> Void in
                
                if success {
                    self.avatarImageView.setImageWithFade(image)
                }
            })
        }
        
    }
    
    
    private func updateDisplayForUser() {
        
        guard let user = displayedUser else {
            return
        }
        
        settingsButton.hidden = displayingCurrentUser == false
        
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
