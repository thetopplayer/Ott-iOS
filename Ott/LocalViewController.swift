//
//  LocalViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class LocalViewController: TopicMasterViewController {

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let scanButton = UIBarButtonItem(image: UIImage(named: "QRCode"), style: .Plain, target: self, action: "presentTopicScanViewController:")
        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "presentTopicCreationAction:")
        navigationItem.leftBarButtonItem = scanButton
        navigationItem.rightBarButtonItem = createButton
        
        update()
    }

    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    
    
    //MARK: - Data
    
    override func update() {
        
        if let location = LocationManager.sharedInstance.location {
            
            let fetchOperation = NSBlockOperation(block: { () -> Void in
                
                let query = Topic.query()!
                let geoPoint = PFGeoPoint(location: location)
                query.whereKey(DataKeys.Location, nearGeoPoint: geoPoint, withinMiles: 20)
                let updatedKey = "updatedAt"
                query.whereKey(updatedKey, greaterThanOrEqualTo: self.lastUpdated)
                query.orderByDescending(updatedKey)
                
                var error: NSError?
                let objects = query.findObjects(&error)
                if let objects = objects as? [Topic] {
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        self.updateTable(withData: objects)
                    }
                }
            })
            
            operationQueue().addOperation(fetchOperation)
        }
    }
    
    
    
    //MARK: - TableView
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        (navigationController as! NavigationController).presentTopicDetailViewController(withTopic: selection)
    }
    
    
    
    //MARK: - Actions
    
    @IBAction func presentTopicCreationAction(sender: AnyObject) {
        
        (navigationController as! NavigationController).presentTopicCreationViewController()
    }
    
    
    @IBAction func presentTopicScanViewController(sender: AnyObject) {
        
        (navigationController as! NavigationController).presentTopicScanViewController()
    }
    

}
