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
        
        let scanButton = UIBarButtonItem(image: UIImage(named: "QRCode"), style: .Plain, target: self, action: "presentTopicScanViewController:")
        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "presentTopicCreationAction:")
        navigationItem.leftBarButtonItem = scanButton
        navigationItem.rightBarButtonItem = createButton
        
        fetchTopics(.NewLocation)
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
    
    private let localRadius = Double(20)  // radius in miles for what is considered "local"
    private var lastUpdated: NSDate?
    
    /*
    private let dataCacheName = "localTopics"
    private func replaceCachedTopics(withTopics withTopics: [Topic]) {
        
        PFObject.unpinAllObjectsWithName(dataCacheName)
        PFObject.pinAll(withTopics, withName: dataCacheName)
    }
    
    private func appendToCachedData(withTopics withTopics: [Topic]) {
        
        let updatedTopics = self.displayedTopics + withTopics
        PFObject.unpinAllObjectsWithName(dataCacheName)  // unpin cached
        PFObject.pinAll(updatedTopics, withName: dataCacheName) // cache retrieved objects
    }
*/
    
    private enum FetchType {
        case NewLocation, UpdateCurrentLocation
    }
    
    private func fetchTopics(type: FetchType) {

        /*
        // simply return all currently cached objects
        func fetchFromCache() {
            
            guard let location = LocationManager.sharedInstance.location else {
                print("call to fetch for new location but have no location")
                return
            }
            
            let query = Topic.query()!
            query.orderByDescending(DataKeys.UpdatedAt)
            query.whereKey(DataKeys.Location, nearGeoPoint: PFGeoPoint(location: location), withinMiles: localRadius)
            query.fromPinWithName(self.dataCacheName)
            
            var error: NSError?
            let objects = query.findObjects(&error)
            if let topics = objects as? [Topic] {
                self.refreshTableView(withTopics: topics, replacingDatasourceData: true)
            }
        }
        */
        
        // fetch objects for new location, replacing all cached objects
        func fetchForNewLocation() {
            
            guard let location = LocationManager.sharedInstance.location else {
                print("call to fetch for new location but have no location")
                return
            }
            
            let query = Topic.query()!
            query.orderByDescending(DataKeys.CreatedAt)
            query.whereKey(DataKeys.Location, nearGeoPoint: PFGeoPoint(location: location), withinMiles: localRadius)
            
            var error: NSError?
            let objects = query.findObjects(&error)
            if let topics = objects as? [Topic] {
                
//                self.replaceCachedTopics(withTopics: topics)
                if let mostRecentTopicUpdate = topics.first?.updatedAt {
                    
                    self.lastUpdated = mostRecentTopicUpdate
                    dispatch_async(dispatch_get_main_queue()) {
                        self.refreshTableView(withTopics: topics, replacingDatasourceData: true)
                    }
                }
            }
        }
        
        // update objects for current location, fetching only recently updated ones
        // and adding additional objects to cache
        func fetchToUpdateLocation() {
            
            guard let location = LocationManager.sharedInstance.location else {
                print("call to fetch update location but have no location")
                return
            }
            
            let query = Topic.query()!
            query.orderByDescending(DataKeys.CreatedAt)
            query.whereKey(DataKeys.Location, nearGeoPoint: PFGeoPoint(location: location), withinMiles: 20)
            
            if let mostRecentlyFetchedUpdate = self.lastUpdated {
                query.whereKey(DataKeys.UpdatedAt, greaterThanOrEqualTo: mostRecentlyFetchedUpdate)
            }
            
            var error: NSError?
            let objects = query.findObjects(&error)
            if let topics = objects as? [Topic] {
                
                if let mostRecentTopicUpdate = topics.first?.updatedAt {
                    
//                    self.appendToCachedData(withTopics: topics)
                    self.lastUpdated = mostRecentTopicUpdate
                    dispatch_async(dispatch_get_main_queue()) {
                        self.refreshTableView(withTopics: topics, replacingDatasourceData: false)
                    }
                }
            }
        }
        
        // on completion of fetching
        func fetchCompletion() {
            
            dispatch_async(dispatch_get_main_queue()) {
                self.hideRefreshControl()
                self.updateStatus()
            }
        }
        
        
        /********/
        
        if displayedTopics.count == 0 {
            updateStatus(.Fetching)
        }
        
        switch type {
            
//        case .Cached:
//
//            let fetchFromCacheOperation = NSBlockOperation(block: fetchFromCache)
//            fetchFromCacheOperation.addCompletionBlock(fetchForNewLocation)
//            operationQueue.addOperation(fetchFromCacheOperation)
            
        case .NewLocation:
            
            // TODO : ADD GUARD FOR REACHABILITY
            let fetchForNewLocationOperation = NSBlockOperation(block: fetchForNewLocation)
            fetchForNewLocationOperation.addCompletionBlock(fetchCompletion)
            operationQueue.addOperation(fetchForNewLocationOperation)
            
        case .UpdateCurrentLocation:
            
            // TODO : ADD GUARD FOR REACHABILITY
            let fetchToUpdateLocationOperation = NSBlockOperation(block: fetchToUpdateLocation)
            fetchToUpdateLocationOperation.addCompletionBlock(fetchCompletion)
            operationQueue.addOperation(fetchToUpdateLocationOperation)
        }
    }
    
    
    override func update() {
        fetchTopics(.UpdateCurrentLocation)
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidPostNotification:", name: TopicDetailViewController.Notifications.DidUploadPost, object: nil)
    }
    
    
    func handleLocationChangeNotification(notification: NSNotification) {
        
        update()
    }
    
    
    func handleDidPostNotification(notification: NSNotification) {
        
        print("handleDidPostNotification ")
    }

}
