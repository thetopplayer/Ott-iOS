//
//  LoadingTableViewCell.swift
//  Ott
//
//  Created by Max on 9/29/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class LoadingTableViewCell: TableViewCell {

    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        innerContentContainer?.addBorder()
    }
}
