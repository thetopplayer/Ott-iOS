//
//  TopicImageTableViewCell.swift
//  Ott
//
//  Created by Max on 7/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicImageTableViewCell: TableViewCell {
    
    @IBOutlet var topicImageView: UIImageView!
    
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
        topicImageView.addRoundedBorder()
    }
    
}
