//
//  TopicAuthorTableViewCell.swift
//  Ott
//
//  Created by Max on 7/10/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicAuthorTableViewCell: TableViewCell {

    @IBOutlet var authorNameLabel: UILabel!
    @IBOutlet var authorHandleLabel: UILabel!
    @IBOutlet var authorBioLabel: UILabel!
    @IBOutlet var authorImageView: ParseImageView!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        innerContentContainer?.addBorder()
        
        let tapGR: UIGestureRecognizer = {
            
            let gr = UITapGestureRecognizer()
            gr.addTarget(self, action: "displayAuthorDetail:")
            return gr
            }()

        authorImageView.addRoundedBorder()
        authorImageView.addGestureRecognizer(tapGR)
        authorImageView.userInteractionEnabled = true
        
        let tapGR1: UIGestureRecognizer = {
            
            let gr = UITapGestureRecognizer()
            gr.addTarget(self, action: "displayAuthorDetail:")
            return gr
            }()
        
        authorHandleLabel.textColor = UIColor.tint()
        authorHandleLabel.addGestureRecognizer(tapGR1)
        authorHandleLabel.userInteractionEnabled = true
    }
    
    
    var displayedTopic: Topic? {
        
        didSet {
            updateContents()
        }
    }
    
    
    private func updateContents() {
        
        guard let topic = displayedTopic else {
            return
        }
        
        authorNameLabel.text = topic.authorName
        authorHandleLabel.text = topic.authorHandle
        authorBioLabel.text = topic.authorBio
        authorImageView.displayImageInFile(topic.authorAvatarFile)
//        if topic.hasAuthorAvatar() {
//            topic.getAuthorAvatarImage({ (success, image) -> Void in
//                
//                if success {
//                    self.authorImageView.image = image
//                }
//            })
//        }
    }
    
    
    private func presentAuthorInfo() {
        
        guard let topic = displayedTopic else {
            return
        }
        
        if let viewController = topmostViewController() {
            viewController.presentUserDetailViewController(withTopic: topic, exitMethod: .Back)
        }
    }
    
    
    @IBAction func displayAuthorDetail(sender: UIGestureRecognizer) {
        
        if sender.state != .Ended {
            return
        }
        
        presentAuthorInfo()
    }
    
}
