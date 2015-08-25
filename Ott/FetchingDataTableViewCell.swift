//
//  FetchingDataTableViewCell.swift
//  Ott
//
//  Created by Max on 8/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class FetchingDataTableViewCell: TableViewCell {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var label: UILabel!

    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.clearColor()
        innerContentContainer?.backgroundColor = UIColor.clearColor()
    }
    
    func startAnimating(withMessage message: String) {
        
        label.text = message
        activityIndicator.startAnimating()
    }

}
