//
//  TopicTitleTableViewCell.swift
//  Ott
//
//  Created by Max on 7/7/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicTitleTableViewCell: TableViewCell {

    @IBOutlet var titleLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor(white: 0.98, alpha: 1.0)
        innerContentContainer?.addBorder()
    }

    
    var title: String? {
        
        set {
            titleLabel.text = newValue
        }
        
        get {
            return titleLabel.text
        }
    }
}
