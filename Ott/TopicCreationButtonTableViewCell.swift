//
//  TopicCreationButtonTableViewCell.swift
//  Ott
//
//  Created by Max on 7/6/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

protocol TopicCreationButtonTableViewCellDelegate {
    
    func buttonViewButtonDidPress(action: TopicCreationButtonTableViewCell.ButtonAction) -> Void
}



class TopicCreationButtonTableViewCell: TableViewCell {

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var photosButton: UIButton!

    var delegate: TopicCreationButtonTableViewCellDelegate?
    
    
    enum ButtonAction {
        case Camera, Photos
    }
    
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        contentView.backgroundColor = UIColor.whiteColor()
        
        cameraButton.addTarget(self, action: "handleCameraAction:", forControlEvents: UIControlEvents.TouchUpInside)
        photosButton.addTarget(self, action: "handlePhotosAction:", forControlEvents: UIControlEvents.TouchUpInside)
    }

    
    @IBAction func handleCameraAction(sender: AnyObject) {
        
        if let delegate = delegate {
            delegate.buttonViewButtonDidPress(.Camera)
        }
    }
    
    
    @IBAction func handlePhotosAction(sender: AnyObject) {
        
        if let delegate = delegate {
            delegate.buttonViewButtonDidPress(.Photos)
        }
    }

}
