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
        
        exportButton.enabled = false
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
                exportButton.enabled = true
            }
            else {
                displayingCurrentUser = false
                exportButton.enabled = false
            }
        }
    }
    
    
    
    //MARK: - Display
    
    private func attributedTextForBio(bio: String?) -> NSAttributedString {
        
        if let bio = bio {
            
            let normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: UIFont.systemFontOfSize(14)]
            return NSAttributedString(string: bio, attributes: normalAttributes)
            
        }
        else {
            
            let inactiveAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor(), NSFontAttributeName: UIFont.systemFontOfSize(14)]
            return NSAttributedString(string: "(no bio)", attributes: inactiveAttributes)
        }
    }
    
    
    private func updateDisplayForTopic() {
        
        guard let topic = topic else {
            return
        }
        
        settingsButton.hidden = displayingCurrentUser == false
        handleTextLabel.text = topic.authorHandle
        bioTextLabel.attributedText = attributedTextForBio(topic.authorBio)
        
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
        bioTextLabel.attributedText = attributedTextForBio(user.bio)
        
        if user.hasAvatar() {
            user.getAvatar({ (success, image) -> Void in
                
                if success {
                    self.avatarImageView!.setImageWithFade(image)
                }
            })
        }
    }
    
    
    
    //MARK: - Actions
    
    static let settingsButtonTapNotification = "userDetailSettingsButtonTap"
    @IBAction func displaySettingsAction(sender: AnyObject) {
        
        let notification = NSNotification(name: UserDetailTableViewCell.settingsButtonTapNotification, object: self)
        NSNotificationQueue.defaultQueue().enqueueNotification(notification, postingStyle: .PostASAP)
    }
    
    static let exportButtonTapNotification = "userDetailExportButtonTap"
    static let userKey = "user"
    @IBAction func exportAction(sender: AnyObject) {
        
        guard let user = displayedUser else {
            return
        }
        
        let userinfo = [UserDetailTableViewCell.userKey: user]
        let notification = NSNotification(name: UserDetailTableViewCell.exportButtonTapNotification, object: self, userInfo: userinfo)
        NSNotificationQueue.defaultQueue().enqueueNotification(notification, postingStyle: .PostASAP)
    }
}
