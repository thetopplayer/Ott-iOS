//
//  TopicDetailTableViewCell.swift
//  Ott
//
//  Created by Max on 7/7/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TopicDetailTableViewCell: TableViewCell, JTSImageViewControllerOptionsDelegate {

    @IBOutlet var topicImageView: ParseImageView?
    @IBOutlet var contentLabel: UILabel!
    @IBOutlet var authorImageView: ParseImageView!
    @IBOutlet var authorLabel: UILabel!
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.whiteColor()
        selectionStyle = .None
        
        let tapGR: UIGestureRecognizer = {
            
            let gr = UITapGestureRecognizer()
            gr.addTarget(self, action: "displayAuthorDetail:")
            return gr
        }()
        
        authorImageView.addRoundedBorder(withColor: UIColor.clearColor())
        authorImageView.addGestureRecognizer(tapGR)
        authorImageView.userInteractionEnabled = true
        
        if let topicImageView = topicImageView {
            
            topicImageView.contentMode = .ScaleAspectFill
            topicImageView.clipsToBounds = true
            
            let tapGR: UIGestureRecognizer = {
                let gr = UITapGestureRecognizer()
                gr.addTarget(self, action: "displayImageDetail:")
                return gr
            }()
            
            topicImageView.addGestureRecognizer(tapGR)
            topicImageView.userInteractionEnabled = true
        }
    }

    
    override func prepareForReuse() {
        
        super.prepareForReuse()
        authorImageView.clear()
        topicImageView?.clear()
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
        
        if let topicImageFile = topic.imageFile {
            topicImageView?.displayImageInFile(topicImageFile)
        }
        
        contentLabel.attributedText = attributedContent(topic)
        
        authorLabel.attributedText = {
            
            let nameColor = UIColor.blackColor()
            let handleColor = UIColor.brownColor()
            
            let nameFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            let nameAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : nameColor, NSFontAttributeName: nameFont]
            
            let handleFont = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            let handleAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : handleColor, NSFontAttributeName: handleFont]
            
            let nameString = topic.authorName! + "  "
            let fullAttrString = NSMutableAttributedString(string: nameString, attributes: nameAttributes)
            
            let handleString = topic.authorHandle! + " \n"
            let handleAttrString = NSAttributedString(string: handleString, attributes: handleAttributes)
            
            fullAttrString.appendAttributedString(handleAttrString)
            fullAttrString.appendAttributedString(timeAndLocationAttributedString(topic))
            return fullAttrString
        }()
        
        authorImageView.displayImageInFile(topic.authorAvatarFile)
    }
    
    
    private func attributedContent(topic: Topic) -> NSAttributedString {
        
        let titleFont = UIFont.systemFontOfSize(32)
        let titleAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.blackColor(), NSFontAttributeName: titleFont]
        
        let fullAttrString = NSMutableAttributedString(string: topic.name!, attributes: titleAttributes)
        
        if let comment = topic.comment {
            
            let color = UIColor.darkGrayColor()
            let font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            let commentAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : color, NSFontAttributeName: font]
            
            let text = "\n" + comment
            let commentAttrString = NSAttributedString(string: text, attributes: commentAttributes)
            
            fullAttrString.appendAttributedString(commentAttrString)
        }
        
        return fullAttrString
    }
    
    
    private func presentAuthorInfo() {
        
        guard let topic = displayedTopic else {
            return
        }
        
        if let viewController = topmostViewController() {
            viewController.presentUserDetailViewController(withTopic: topic)
        }
    }
    
    
    @IBAction func displayAuthorDetail(sender: UIGestureRecognizer) {
        
        if sender.state != .Ended {
            return
        }
        
        presentAuthorInfo()
    }

    
    @IBAction func displayImageDetail(sender: AnyObject?) {
        
        guard let imageView = topicImageView else {
            return
        }
        
        let imageInfo = JTSImageInfo()
        imageInfo.image = imageView.image
        imageInfo.referenceRect = CGRectMake(imageView.frame.origin.x, imageView.frame.origin.y, imageView.frame.size.width, 0)
        imageInfo.referenceView = imageView
        
        let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode:JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundOptions.None)
        
        //        imageViewer.optionsDelegate = self
        
        imageViewer.showFromViewController(topmostViewController(), transition: JTSImageViewControllerTransition.FromOriginalPosition)
    }

}
