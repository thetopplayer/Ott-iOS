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
        
//        contentView.backgroundColor = UIColor.background()
//        innerContentContainer?.backgroundColor = UIColor.background()
        contentView.backgroundColor = UIColor.whiteColor()
//        contentView.addBorder()

        innerContentContainer?.backgroundColor = UIColor.whiteColor()
        countTitleLabel.text = "Posts"
        
        countLabel.text = ""
        countLabel.layer.cornerRadius = 12
        countLabel.layer.masksToBounds = true
        countLabel.backgroundColor = UIColor.brownColor()
        countLabel.textColor = UIColor.whiteColor()
        
        ratingTitleLabel.text = "Average"
        ratingLabel.text = ""
        ratingLabel.layer.cornerRadius = 12
        ratingLabel.layer.masksToBounds = true
        ratingLabel.textColor = UIColor.whiteColor()
    }
    
    
    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func updateContents() {
        
        if let topic = displayedTopic {
            countLabel.text = " \(topic.localNumberOfPosts) "
            ratingLabel.text = String.localizedStringWithFormat(" %.1f ", topic.localAverageRating)
            ratingLabel.backgroundColor = Rating(withFloat: topic.localAverageRating / 10).color()
        }
    }

}
