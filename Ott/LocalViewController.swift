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
//        startAutomaticallyUpdatingFetches()
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        
        super.viewDidDisappear(animated)
//        stopAutomaticallyUpdatingFetches()
    }
    
    
    
    //MARK: - Data
    
    private enum FetchType {
        case CachedThenUpdate, Full, Update
    }
    
    
    private func fetchTopics(type: FetchType) {

        func initializeCachedFetchOperation(location: CLLocation) -> Operation {
            
            let start = Globals.sharedInstance.defaultFetchSinceDate
            
            let fetchOperation = FetchLocalTopicsOperation(dataSource: .Cache, location: location, startingAt: start, replaceCache: false, completion: { (topics, error) -> Void in
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.reloadTableView(withTopics: topics)
                    self.hideRefreshControl()
                    self.displayStatus()
                    
                    if let error = error {
                        self.presentOKAlertWithError(error, messagePreamble: "Error retrieving cached data", actionHandler: nil)
                    }
                }
            })
            
            return fetchOperation
        }
        
        
        func initializeServerFetchOperation(location: CLLocation, startingAt: NSDate, replaceCache: Bool) -> Operation {
            
            let fetchOperation = FetchLocalTopicsOperation(dataSource: .Server, location: location, startingAt: startingAt, replaceCache: replaceCache, completion: { (topics, error) -> Void in
                
                if let mostRecentTopic = topics?.first {
                     Globals.sharedInstance.lastUpdatedLocalTopics = mostRecentTopic.updatedAt!
                }
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    self.reloadTableView(withTopics: topics)
                    self.hideRefreshControl()
                    self.displayStatus()
                    
                    if let error = error {
                        self.presentOKAlertWithError(error, messagePreamble: "Error retrieving data from server", actionHandler: nil)
                    }
                }
            })
            
            return fetchOperation
        }
        
        
        guard let location = LocationManager.sharedInstance.location else {
            print("call to fetch update but have no location")
            return
        }
        
        
        displayStatus(.Fetching)
        
        switch type {
            
        case .CachedThenUpdate:

            let cacheOperation = initializeCachedFetchOperation(location)
            let serverOperation = initializeServerFetchOperation(location, startingAt: Globals.sharedInstance.defaultFetchSinceDate, replaceCache: true)
            serverOperation.addDependency(cacheOperation)
            
            FetchQueue.sharedInstance.addOperation(cacheOperation)
            FetchQueue.sharedInstance.addOperation(serverOperation)
            
        case .Full:
            
            let serverOperation = initializeServerFetchOperation(location, startingAt: Globals.sharedInstance.defaultFetchSinceDate, replaceCache: true)
            FetchQueue.sharedInstance.addOperation(serverOperation)
            
        case .Update:
            
            let serverOperation = initializeServerFetchOperation(location, startingAt: Globals.sharedInstance.lastUpdatedLocalTopics, replaceCache: false)
            FetchQueue.sharedInstance.addOperation(serverOperation)
        }
    }
    
    
    override func update() {
        fetchTopics(.Update)
    }
    
    
    
    //MARK: - TableView
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        presentTopicDetailViewController(withTopic: selection)
    }
    
    
    
    //MARK: - Actions
    
    @IBAction func presentTopicCreationAction(sender: AnyObject) {
        
        presentTopicCreationViewController()
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidUploadTopicNotification:", name: UploadTopicOperation.Notifications.DidUpload, object: nil)

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

    
    func handleDidUploadTopicNotification(notification: NSNotification) {
        
        update()
    }
}
