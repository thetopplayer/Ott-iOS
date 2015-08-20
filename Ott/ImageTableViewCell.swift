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
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        topicImageView.contentMode = .ScaleAspectFill
        topicImageView.clipsToBounds = true
        if roundedBorder {
            topicImageView.addRoundedBorder()
        }
    }
    

    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func updateContents() {
        
        if let topic = displayedTopic {
            
            if topic.hasImage {
                
                topic.getImage() {(success, image) in
                    
                    if success {
                        self.topicImageView!.image = image
                    }
                }
            }
        }
    }
    
}
