//
//  DataDisplayOptionsTableViewCell.swift
//  Ott
//
//  Created by Max on 9/30/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class DataDisplayOptionsTableViewCell: TableViewCell {

    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        innerContentContainer?.addBorder()
        
        segmentedControl.selectedSegmentIndex = selection.rawValue
        handleControlAction(segmentedControl)
    }
    
    
    //MARK: - Selection
    
    var selectionEnabled: Bool {
        
        set {
            segmentedControl.enabled = newValue
        }
        
        get {
            return segmentedControl.enabled
        }
    }
    
    
    static let selectionDidChangeNotification = "dataDisplayOptionsDidChangeNotification"
    
    enum Selection: Int {
        case AuthoredTopics = 0
        case AuthoredPosts = 1
        case Following = 2
        case Followers = 3
    }
    
    var selection = Selection.AuthoredTopics
    @IBAction func handleControlAction(sender: UISegmentedControl) {
        
        selection = Selection(rawValue: sender.selectedSegmentIndex)!
        
        let notification = NSNotification(name: DataDisplayOptionsTableViewCell.selectionDidChangeNotification, object: self)
        NSNotificationQueue.defaultQueue().enqueueNotification(notification, postingStyle: .PostASAP)
    }

}
