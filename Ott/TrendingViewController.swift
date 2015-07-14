//
//  TrendingViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class TrendingViewController: TopicMasterViewController, NavigatorToTopicCreationProtocol {
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
         
//        fetchPredicate = NSPredicate(format: "isTrending = true")
    }

    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        update()
    }
    
    
    
    //MARK: - TableView
    
    private let selectionSegueIdentifier = "segueToRatingEntry"
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        let segueOperation = SegueOperation(presentationController: self, identifer: selectionSegueIdentifier, conditions: [LocationCondition(usage: .WhenInUse)])
        operationQueue().addOperation(segueOperation)
    }
    
    
    
    //MARK: - NavigatorToTopicCreationProtocol
    
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

