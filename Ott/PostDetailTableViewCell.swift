//
//  PostDetailTableViewCell.swift
//  Ott
//
//  Created by Max on 7/14/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class PostDetailTableViewCell: TableViewCell {

    @IBOutlet var topBar: UIView!
    @IBOutlet var topBarLabel: UILabel!
    @IBOutlet var statusBar: UIView!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var commentTextView: UITextView!

    
    
    var displayedPost: Post? {
        
        didSet {
            updateContents()
        }
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        topBar.backgroundColor = UIColor.whiteColor()
        topBar.addBorder(withColor: UIColor(white: 0.8, alpha: 1.0))
        statusBar.backgroundColor = UIColor.clearColor()
        
        selectionStyle = .None
    }
    
    
    private func updateContents() {
        
//        if let post = displayedPost {
//            
//            topBarLabel.attributedText = timeAndLocationAttributedString(topic)
//            
//            ratingLabel.text = topic.ratingToText()
//            ratingLabel.textColor = topic.ratingToColor()
//            nameLabel.text = topic.name!
//            if topic.comment != nil {
//                commentLabel.text = topic.comment!
//            }
//            else {
//                commentLabel.text = ""
//            }
//            
//            statusLabel.attributedText = attributedDescription(topic)
//            topicImageView?.image = topic.image
//        }
    }
    

}
