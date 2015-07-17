//
//  TopicCommentTableViewCell.swift
//  Ott
//
//  Created by Max on 7/7/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicCommentTableViewCell: TableViewCell {

    @IBOutlet var textView: UITextView!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.whiteColor()
        innerContentContainer?.addBorder(withColor: UIColor(white: 0.85, alpha: 1.0))
        
        textView.editable = false
        textView.selectable = false
    }

    
    var comment: String? {
        
        set {
            textView.text = newValue
            textView.font = UIFont.systemFontOfSize(16)
            textView.textColor = UIColor.darkGrayColor()
        }
        
        get {
            return textView.text
        }
    }
}
