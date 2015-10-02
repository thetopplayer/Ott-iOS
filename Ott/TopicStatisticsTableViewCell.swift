//
//  TopicStatisticsTableViewCell.swift
//  Ott
//
//  Created by Max on 8/29/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicStatisticsTableViewCell: TableViewCell {

    @IBOutlet var countContainerView: UIView!
    @IBOutlet var countLabel: UILabel!
    @IBOutlet var countTitleLabel: UILabel!
    
    @IBOutlet var ratingContainerView: UIView!
    @IBOutlet var ratingLabel: UILabel!
    @IBOutlet var ratingTitleLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        contentView.backgroundColor = UIColor.background()
        innerContentContainer?.backgroundColor = UIColor.whiteColor()
        innerContentContainer?.addBorder()
        innerContentContainer?.addDownShadow()
        countTitleLabel = "Posts"
        countLabel.text = ""
        countLabel.textColor = UIColor.brownColor()
        ratingTitleLabel = "Average"
        ratingLabel.text = ""
    }
    
    
    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func updateContents() {
        
        if let topic = displayedTopic {
            countLabel.text = "\(topic.numberOfPosts)"
            ratingLabel.text = String.localizedStringWithFormat("%.1f", topic.averageRating)
            ratingLabel.textColor = Rating(withFloat: topic.averageRating / 10).color()
        }
    }

}
