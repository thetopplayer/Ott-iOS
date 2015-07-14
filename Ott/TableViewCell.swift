//
//  TableViewCell.swift
//  Ott
//
//  Created by Max on 7/9/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet var innerContentContainer: UIView?
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        separatorInset = UIEdgeInsetsZero
        layoutMargins = UIEdgeInsetsZero
        
        contentView.backgroundColor = UIColor.background()
        innerContentContainer?.backgroundColor = UIColor.whiteColor()
        innerContentContainer?.addBorder()
    }
    
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        if let frame = innerContentContainer?.frame {
            selectedBackgroundView?.frame = frame
        }
    }
}
