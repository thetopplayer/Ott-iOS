//
//  UserTableViewCell.swift
//  Ott
//
//  Created by Max on 10/20/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UserTableViewCell: TableViewCell {
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet weak var avatarImageView: ParseImageView!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        avatarImageView.addRoundedBorder(withColor: UIColor.whiteColor())
    }
    
    
    var user: User? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func updateContents() {
        
        guard let user = user else {
            return
        }
        
        nameLabel.attributedText = attributedStringForUsername(user.name!, handle: user.handle!, bio: user.bio)
        
        if let avatarFile = user.avatarFile {
            self.avatarImageView.displayImageInFile(avatarFile)
        }
        else {
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }
    
    
    func attributedStringForUsername(userName: String, handle: String, bio: String?) -> NSAttributedString {
        
        let nameColor = UIColor(white: 0.05, alpha: 1.0)
        let handleColor = UIColor.brownColor()
        
        let nameFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let nameAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : nameColor, NSFontAttributeName: nameFont]
        
        let handleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
        let handleAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : handleColor, NSFontAttributeName: handleFont]
        
        let nameString = userName + "  "
        let fullAttrString = NSMutableAttributedString(string: nameString, attributes: nameAttributes)
        
        let handleString = handle
        let handleAttrString = NSAttributedString(string: handleString, attributes: handleAttributes)
        
        fullAttrString.appendAttributedString(handleAttrString)
        
        let bioColor = bio != nil ? UIColor.darkGrayColor() : UIColor.lightGrayColor()
        let bioFont = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
        let commentAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : bioColor, NSFontAttributeName: bioFont]
        
        var paddedBio = "\n"
        if let bio = bio {
            paddedBio += bio
        }
        else {
            paddedBio += "(no bio)"
        }
        
        let bioAttrString = NSAttributedString(string: paddedBio, attributes: commentAttributes)
        fullAttrString.appendAttributedString(bioAttrString)
        
        return fullAttrString
    }
    
}
