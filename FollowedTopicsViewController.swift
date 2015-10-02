//
//  FollowedTopicsViewController.swift
//  Ott
//
//  Created by Max on 10/2/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class FollowedTopicsViewController: TopicMasterViewController {

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let scanButton = UIBarButtonItem(image: UIImage(named: "scan"), style: .Plain, target: self, action: "presentTopicScanViewController:")
        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "presentTopicCreationAction:")
        navigationItem.leftBarButtonItem = scanButton
        navigationItem.rightBarButtonItem = createButton
        
        fetchTopics(.CachedThenUpdate)
    }


    
    
    //MARK: - Data
    
    private enum FetchType {
        case CachedThenUpdate, Update
    }
    
    
    private func fetchTopics(type: FetchType) {

        func initializeCachedFetchOperation() -> Operation {
            
            let start = Globals.sharedInstance.defaultFetchSinceDate
            
            let fetchOperation = FetchCachedFolloweeTopicsOperation(dataSource: .Cache, startingAt: start, completion: { (topics, error) in
                
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
        
        
        func initializeServerFetchOperation(startingAt startingAt: NSDate) -> Operation {
            
            let fetchOperation = FetchCachedFolloweeTopicsOperation(dataSource: .Server, startingAt: startingAt, completion: { (topics, error) in
                
                if let mostRecentTopic = topics?.first {
                    Globals.sharedInstance.lastUpdatedFollowedUsersTopics = mostRecentTopic.updatedAt!
                }
                
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
        

        displayStatus(.Fetching)
        
        switch type {
            
        case .CachedThenUpdate:

            let cacheOperation = initializeCachedFetchOperation()
            
            let fetchFollowersOperation = FetchFollowersOperation(completion: nil)
            fetchFollowersOperation.addDependency(cacheOperation)
            
            let serverOperation = initializeServerFetchOperation(startingAt: Globals.sharedInstance.defaultFetchSinceDate)
            serverOperation.addDependency(fetchFollowersOperation)
            
            FetchQueue.sharedInstance.addOperation(cacheOperation)
            FetchQueue.sharedInstance.addOperation(fetchFollowersOperation)
            FetchQueue.sharedInstance.addOperation(serverOperation)
            
        case .Update:
            
            let fetchFollowersOperation = FetchFollowersOperation(completion: nil)
            let serverOperation = initializeServerFetchOperation(startingAt: Globals.sharedInstance.defaultFetchSinceDate)
            serverOperation.addDependency(fetchFollowersOperation)
            
            FetchQueue.sharedInstance.addOperation(fetchFollowersOperation)
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidFetchTopicNotification:", name: FetchTopicOperation.Notifications.DidFetch, object: nil)
    }
    
    
    func handleLocationChangeNotification(notification: NSNotification) {
        
        fetchTopics(.Update)
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
