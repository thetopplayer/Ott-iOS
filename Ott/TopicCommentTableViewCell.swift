//
//  TopicCommentTableViewCell.swift
//  Ott
//
//  Created by Max on 7/7/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicCommentTableViewCell: TableViewCell {

    @IBOutlet var label: UILabel!
        
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        innerContentContainer?.addBorder(withColor: UIColor(white: 0.85, alpha: 1.0))
    }

    
    var comment: String? {
        
        set {
            label.text = newValue
            label.font = UIFont.systemFontOfSize(16)
            label.textColor = UIColor.darkGrayColor()
        }
        
        get {
            return label.text
        }
    }
}
