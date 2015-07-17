//
//  ImageTableViewCell.swift
//  Ott
//
//  Created by Max on 7/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class ImageTableViewCell: TableViewCell {
    
    @IBOutlet var topicImageView: UIImageView!
    
    var roundedBorder = false
    
    var topicImage: UIImage? {
        
        get {
            if let image = topicImageView.image {
                return image
            }
            return nil
        }
        
        set {
            self.topicImageView?.image = newValue
        }
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        topicImageView.contentMode = .ScaleAspectFill
        topicImageView.clipsToBounds = true
        if roundedBorder {
            topicImageView.addRoundedBorder()
        }
    }
    
}
