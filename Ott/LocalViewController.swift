//
//  LocalViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class LocalViewController: TopicMasterViewController {

    
    @IBOutlet var statusToolbarItem: UIBarButtonItem!
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let scanButton = UIBarButtonItem(image: UIImage(named: "scan"), style: .Plain, target: self, action: "presentTopicScanViewController:")
        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "presentTopicCreationAction:")
        navigationItem.leftBarButtonItem = scanButton
        navigationItem.rightBarButtonItem = createButton
        
        fetchTopics(.CachedThenFull)
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
        case CachedThenFull, Full, Update
    }
    
    private var isFetching = false
    
    private func fetchTopics(type: FetchType) {

        func retrieveFromCache(replacingDatasourceData replacingData: Bool) {
            
            let cachedTopics = cachedLocalTopics()
            dispatch_async(dispatch_get_main_queue()) {
                self.refreshTableView(withTopics: cachedTopics, replacingDatasourceData: replacingData)
            }
        }
        
        func updateDisplayForFetchCompletion() {
            
            dispatch_async(dispatch_get_main_queue()) {
                self.hideRefreshControl()
                self.displayStatus()
            }
        }
        
        
        /********/
        
         displayStatus(.Fetching)
        
        switch type {
            
        case .CachedThenFull:

            let retrieveFromCacheOperation = BlockOperation {
                retrieveFromCache(replacingDatasourceData: true)
                self.fetchTopics(.Full)
            }
            
            FetchQueue.sharedInstance.addOperation(retrieveFromCacheOperation)
            
            
        case .Full:
            
            guard let location = LocationManager.sharedInstance.location else {
                print("call to fetch for new location but have no location")
                return
            }
            
            let fetchForNewLocationOperation = FetchLocalTopicsOperation(location: location)
            
            fetchForNewLocationOperation.addCompletionBlock({
                retrieveFromCache(replacingDatasourceData: true)
                updateDisplayForFetchCompletion()
                })
            
            FetchQueue.sharedInstance.addOperation(fetchForNewLocationOperation)

            
        case .Update:
            
            guard let location = LocationManager.sharedInstance.location else {
                print("call to fetch update but have no location")
                return
            }
            
            let fetchToUpdateLocationOperation = FetchLocalTopicsOperation(location: location, updateOnly: true)
           
            fetchToUpdateLocationOperation.addCompletionBlock({
                retrieveFromCache(replacingDatasourceData: false)
                updateDisplayForFetchCompletion()
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
