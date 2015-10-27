//
//  UserDetailTableViewCell.swift
//  Ott
//
//  Created by Max on 9/23/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UserDetailTableViewCell: TableViewCell {

    @IBOutlet weak var captionImageView: ParseImageView!
    @IBOutlet weak var avatarImageContainerView: UIView!
    @IBOutlet weak var avatarImageView: ParseImageView!
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
    
    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        avatarImageView.clear()
    }
    
    

    
    //MARK: - Data
    
    private var displayingCurrentUser = false
    
    private var topic: Topic?
    func fetchUserFromTopic(topic: Topic) {
        
        self.topic = topic
        displayingCurrentUser = topic.authorHandle == currentUser().handle!
        updateDisplayForTopic()
    }
    
    
    private var post: Post?
    func fetchUserFromPost(post: Post) {
        
        self.post = post
        displayingCurrentUser = post.authorHandle == currentUser().handle!
        updateDisplayForPost()
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
    
    private let defaultAvatarImage = UIImage(named: "avatar")!
    private let defaultBackgroundImage = UIImage(named: "blurryBlue")!
    
    private func updateDisplayForTopic() {
        
        guard let topic = topic else {
            return
        }
        
        settingsButton.hidden = displayingCurrentUser == false
        handleTextLabel.text = topic.authorHandle
        bioTextLabel.attributedText = attributedTextForBio(topic.authorBio)
        avatarImageView.displayImageInFile(topic.imageFile, defaultImage: defaultAvatarImage)
    }
    
    
    private func updateDisplayForPost() {
        
        guard let post = post else {
            return
        }
        
        settingsButton.hidden = displayingCurrentUser == false
        handleTextLabel.text = post.authorHandle
        bioTextLabel.attributedText = attributedTextForBio(post.authorBio)
        avatarImageView.displayImageInFile(post.imageFile, defaultImage: defaultAvatarImage)
    }
    
    
    private func updateDisplayForUser() {
        
        guard let user = displayedUser else {
            return
        }
        
        settingsButton.hidden = displayingCurrentUser == false
        handleTextLabel.text = user.handle
        bioTextLabel.attributedText = attributedTextForBio(user.bio)
        avatarImageView.displayImageInFile(user.avatarFile, defaultImage: defaultAvatarImage)
        captionImageView.displayImageInFile(user.backgroundImageFile, defaultImage: defaultBackgroundImage)
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
