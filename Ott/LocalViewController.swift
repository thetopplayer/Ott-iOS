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
        
        let cacheName = "localTopics"
        
        let cachedFetchOperation = NSBlockOperation(block: { () -> Void in
            
            let query = Topic.query()!
            query.orderByDescending(DataKeys.UpdatedAt)
            query.fromPinWithName(cacheName)
            var error: NSError?
            let objects = query.findObjects(&error)
            if let objects = objects as? [Topic] {
                
                dispatch_async(dispatch_get_main_queue()) {
                    print("returning pinned objects")
                    self.updateTable(withData: objects)
                }
            }
        })
        
        operationQueue().addOperation(cachedFetchOperation)
        
        if let location = LocationManager.sharedInstance.location {
            
            // ADD GUARD FOR REACHABILITY
            
            let onlineFetchOperation = NSBlockOperation(block: { () -> Void in
                
                let query = Topic.query()!
                query.orderByDescending(DataKeys.CreatedAt)
                
                query.whereKey(DataKeys.Location, nearGeoPoint: PFGeoPoint(location: location), withinMiles: 20)
                query.whereKey(DataKeys.CreatedAt, greaterThanOrEqualTo: NSDate().daysFrom(-7))
                
                var error: NSError?
                let objects = query.findObjects(&error)
                if let objects = objects as? [Topic] {
                    
                    PFObject.unpinAllObjectsWithName(cacheName)  // unpin cached
                    PFObject.pinAll(objects, withName: cacheName) // cache retrieved objects
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        print("returning fetched objects")
                        self.updateTable(withData: objects)
                    }
                }
            })
            
            onlineFetchOperation.addDependencies([cachedFetchOperation])
            operationQueue().addOperation(onlineFetchOperation)
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
    

    
    //MARK: - Observations
    
    override func startObservations() {
        
        super.startObservations()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocationChangeNotification:", name: LocationManager.Notifications.SignificantLocationChangeDidOccur, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidCreateTopicNotification:", name: TopicCreationViewController.Notifications.DidUploadTopic, object: nil)
    }
    
    
    func handleLocationChangeNotification(notification: NSNotification) {
        
        update()
    }
    
    
    func handleDidCreateTopicNotification(notification: NSNotification) {
        
        if let topic = notification.userInfo?[TopicCreationViewController.Notifications.TopicKey as NSObject] as? Topic {
            
            updateTable(withData: [topic], replacingExistingData: false)
        }
    }
}
