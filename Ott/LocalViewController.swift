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

        let scanButton = UIBarButtonItem(image: UIImage(named: "scan"), style: .Plain, target: self, action: "presentTopicScanViewController:")
        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "presentTopicCreationAction:")
        navigationItem.leftBarButtonItem = scanButton
        navigationItem.rightBarButtonItem = createButton
        
        fetchTopics(.CachedThenUpdate)
    }

    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        startAutomaticallyUpdatingFetches()
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        
        super.viewDidDisappear(animated)
        stopAutomaticallyUpdatingFetches()
    }
    
    
    
    //MARK: - Data
    
    private enum FetchType {
        case CachedThenUpdate, Full, Update
    }
    
    private func fetchTopics(type: FetchType) {

        displayStatus(.Fetching)
        
        switch type {
            
        case .CachedThenUpdate:

            let retrieveFromCacheOperation = BlockOperation {
                
                let cachedTopics = cachedLocalTopics()
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.reloadTableView(withTopics: cachedTopics)
                    self.hideRefreshControl()
                    self.displayStatus()
                }
                
                self.fetchTopics(.Update)
            }
            
            FetchQueue.sharedInstance.addOperation(retrieveFromCacheOperation)
            
            
        case .Full:
            
            guard let location = LocationManager.sharedInstance.location else {
                print("call to fetch for new location but have no location")
                return
            }
            
            let fetchForNewLocationOperation = FetchLocalTopicsOperation(location: location)
            
            fetchForNewLocationOperation.addCompletionBlock({
                
                let cachedTopics = cachedLocalTopics()
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.refreshTableView(withTopics: cachedTopics, replacingDatasourceData: true)
                    self.hideRefreshControl()
                    self.displayStatus()
                }
            })
            
            FetchQueue.sharedInstance.addOperation(fetchForNewLocationOperation)

            
        case .Update:
            
            guard let location = LocationManager.sharedInstance.location else {
                print("call to fetch update but have no location")
                return
            }
            
            let fetchToUpdateLocationOperation = FetchLocalTopicsOperation(location: location, updateOnly: true)
           
            fetchToUpdateLocationOperation.addCompletionBlock({
                
                let cachedTopics = cachedLocalTopics()
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.refreshTableView(withTopics: cachedTopics, replacingDatasourceData: false)
                    self.hideRefreshControl()
                    self.displayStatus()
                }
            })
            
            FetchQueue.sharedInstance.addOperation(fetchToUpdateLocationOperation)
        }
    }
    
    
    override func update() {
        fetchTopics(.Update)
    }
    
    
    
    //MARK: - TableView
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        if let navController = navigationController as? NavigationController {
            navController.presentTopicDetailViewController(withTopic: selection)
        }
    }
    
    
    
    //MARK: - Actions
    
    @IBAction func presentTopicCreationAction(sender: AnyObject) {
        
        if let navController = navigationController as? NavigationController {
            navController.presentTopicCreationViewController()
        }
    }
    
    
    @IBAction func presentTopicScanViewController(sender: AnyObject) {
        
        if let navController = navigationController as? NavigationController {
            navController.presentTopicScanViewController()
        }
    }
    

    
    //MARK: - Observations
    
    override func startObservations() {
        
        super.startObservations()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocationChangeNotification:", name: LocationManager.Notifications.LocationDidChange, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidFetchTopicNotification:", name: FetchTopicOperation.Notifications.DidFetch, object: nil)
    }
    
    
    func handleLocationChangeNotification(notification: NSNotification) {
        
        fetchTopics(.Full)
    }
    
    
    func handleDidFetchTopicNotification(notification: NSNotification) {
        
        let userInfo = notification.userInfo as! [String: Topic]
        if let topic = userInfo[FetchTopicOperation.Notifications.TopicKey] {
            
            if let rowForTopic = displayedTopics.indexOf(topic) {
                
                tableView.beginUpdates()
                let indexPath = NSIndexPath(forRow: rowForTopic, inSection: 0)
                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                tableView.endUpdates()
            }
        }
    }

}
