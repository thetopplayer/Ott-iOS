//
//  LocalViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class LocalViewController: TopicMasterViewController {

    var aTopicWasUpdated = false
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "presentTopicCreationAction:")
        navigationItem.rightBarButtonItem = createButton
        
        fetchTopics(.CacheThenServer)
    }

    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if aTopicWasUpdated {
            aTopicWasUpdated = false
            fetchTopics(.Cache)
        }
        
//        startAutomaticallyUpdatingFetches()
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        
        super.viewDidDisappear(animated)
//        stopAutomaticallyUpdatingFetches()
    }
    
    
    
    //MARK: - Data
    
    private enum FetchType {
        case Cache, CacheThenServer, Server
    }
    
    
    private func fetchTopics(type: FetchType) {
        
        let localRadius = Double(20)
        
        func fetchFromCacheOperationThenServer(fetchingFromServerNext: Bool) -> Operation {
            
            let theQuery: PFQuery = {
                
                let query = Topic.query()!
                query.orderByDescending(DataKeys.CreatedAt)
                return query
                }()

            
            let fetchOperation = FetchLocalTopicsOperation(dataSource: .Cache, query: theQuery, completion: { (fetchResults, error) -> Void in
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if let topics = fetchResults as? [Topic] {
                        self.reloadTableView(withTopics: topics)
                    }
                    self.hideRefreshControl()
                    self.displayStatus()
                    
                    // fetch from server now that we can be sure that table has been updated
                    if fetchingFromServerNext {
                        self.fetchTopics(.Server)
                    }
                }
            })
            
            return fetchOperation
        }
        
        
        func initializeServerFetchOperation(location: CLLocation) -> Operation {
            
            let theQuery: PFQuery = {
                
                let query = Topic.query()!
                query.orderByDescending(DataKeys.CreatedAt)
                query.whereKey(DataKeys.Location, nearGeoPoint: PFGeoPoint(location: location), withinMiles: localRadius)
                
                return query
                }()
            
            
            let fetchOperation = FetchLocalTopicsOperation(dataSource: .Server, query: theQuery, completion: { (fetchResults, error) -> Void in
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if let topics = fetchResults as? [Topic] {
                        self.reloadTableView(withTopics: topics)
                    }
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
            
        case .Cache:
            
            let cacheOperation = fetchFromCacheOperationThenServer(false)
            FetchQueue.sharedInstance.addOperation(cacheOperation)
            
            
        case .CacheThenServer:

            let cacheOperation = fetchFromCacheOperationThenServer(true)
            FetchQueue.sharedInstance.addOperation(cacheOperation)
            
        case .Server:
            
            let serverOperation = initializeServerFetchOperation(location)
            FetchQueue.sharedInstance.addOperation(serverOperation)
        }
    }
    
    
    override func update() {
        fetchTopics(.Server)
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
    

    
    //MARK: - Observations
    
    override func startObservations() {
        
        super.startObservations()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocationChangeNotification:", name: LocationManager.Notifications.LocationDidChange, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidUpdateTopicNotification:", name: UpdateTopicOperation.Notifications.DidUpdate, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidUploadTopicNotification:", name: UploadTopicOperation.Notifications.DidUpload, object: nil)

    }
    
    
    func handleLocationChangeNotification(notification: NSNotification) {
        
        fetchTopics(.Server)
    }
    
    // this notification is typically received when the view is not visible, since topics are updated after the user has posted to them in the detailed topic view
    func handleDidUpdateTopicNotification(notification: NSNotification) {
        
        aTopicWasUpdated = true
    }

    
    func handleDidUploadTopicNotification(notification: NSNotification) {
        
        update()
    }
}
