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
    @IBOutlet weak var handleTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        avatarImageView.addRoundedBorder()
    }
    
    
    var user: User? {
        
        didSet {
            updateContents()
        }
    }
    
    
    func attributedTextForBio(bio: String?) -> NSAttributedString {
        
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
        
        guard let user = user else {
            return
        }
        
        nameLabel.text = user.name
        handleTextLabel.text = user.handle
        bioTextLabel.attributedText = attributedTextForBio(user.bio)
        self.avatarImageView!.displayImageInFile(user.avatarFile)
    }
}
