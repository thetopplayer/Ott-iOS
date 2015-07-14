//
//  TrendingViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TrendingViewController: TopicMasterViewController, NavigatorToTopicCreation {
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        selectionSegueIdentifier = "segueToRatingEntry"
        
//        fetchPredicate = NSPredicate(format: "isTrending = true")
    }

    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        update()
    }
    
    
    
    //MARK: - NavigatorToTopicCreation
    
    @IBAction func presentTopicCreationViewController(sender: AnyObject) {
        
        let segueToCreationIdentifier = "segueToTopicCreation"

        if LocationManager.sharedInstance.permissionGranted {
            performSegueWithIdentifier(segueToCreationIdentifier, sender: nil)
        }
        else {
            LocationManager.sharedInstance.requestPermission({ (granted) -> Void in
                if granted {
                    self.performSegueWithIdentifier(segueToCreationIdentifier, sender: nil)
                }
            })
        }
    }
    
    
    @IBAction func presentTopicScanViewController(sender: AnyObject) {
        
        let segueToScanIdentifier = "segueToScan"
        
        if LocationManager.sharedInstance.permissionGranted {
            performSegueWithIdentifier(segueToScanIdentifier, sender: nil)
        }
        else {
            LocationManager.sharedInstance.requestPermission({ (granted) -> Void in
                if granted {
                    self.performSegueWithIdentifier(segueToScanIdentifier, sender: nil)
                }
            })
        }
    }
}

