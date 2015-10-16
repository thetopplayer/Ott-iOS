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

        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "presentTopicCreationAction:")
        navigationItem.rightBarButtonItem = createButton
        
        
        let title: String
        let number = currentUser().followingCount
        if number == 1 {
            title = "Following \(number) User"
        }
        else {
            title = "Following \(number) Users"
        }
        navigationItem.title = title

        
        fetchTopics(.CachedThenUpdate)
    }


    
    
    //MARK: - Data
    
    private enum FetchType {
        case CachedThenUpdate, Update
    }
    
    
    private func fetchTopics(type: FetchType) {

        func fetchCachedTopicsOperation() -> Operation {
            
            let fetchOperation = FetchFolloweeTopicsOperation(dataSource: .Cache, offset: 0, sinceDate: nil, completion: {
                
                (fetchedObjects, error) in
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if let topics = fetchedObjects as? [Topic] {
                        self.reloadTableView(withTopics: topics)
                    }
                    
                    self.hideRefreshControl()
                    self.displayStatus()
                    
                    if let error = error {
                        self.presentOKAlertWithError(error, messagePreamble: "Error retrieving cached data", actionHandler: nil)
                    }
                    else {
                        
                        // now that we've refreshed the display, fetch from server
                        FetchQueue.sharedInstance.addOperation(fetchTopicsFromServerOperation())
                    }
                }
            })
            
            return fetchOperation
        }
        
        
        func fetchTopicsFromServerOperation() -> Operation {
            
            let now = NSDate()
            let lastFetched = Globals.sharedInstance.lastUpdatedFolloweeTopics
            
            let fetchOperation = FetchFolloweeTopicsOperation(dataSource: .Server, offset: 0, sinceDate: lastFetched, completion: { (fetchedObjects, error) in
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if let topics = fetchedObjects as? [Topic] {
                        self.reloadTableView(withTopics: topics)
                    }
                    
                    self.hideRefreshControl()
                    self.displayStatus()
                    
                    if let error = error {
                        self.presentOKAlertWithError(error, messagePreamble: "Error retrieving followee topics from server", actionHandler: nil)
                    }
                    else {
                        Globals.sharedInstance.lastUpdatedFolloweeTopics = now
                    }
                }
            })
            
            return fetchOperation
        }
        

        displayStatus(.Fetching)
        
        switch type {
            
        case .CachedThenUpdate:

            FetchQueue.sharedInstance.addOperation(fetchCachedTopicsOperation())
            
        case .Update:
            
            FetchQueue.sharedInstance.addOperation(fetchTopicsFromServerOperation())
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
    

    
    //MARK: - Observations
    
    override func startObservations() {
        
        super.startObservations()
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidFetchTopicNotification:", name: UpdateTopicOperation.Notifications.DidUpdate, object: nil)
    }
    

    
//    func handleDidFetchTopicNotification(notification: NSNotification) {
//        
//        let userInfo = notification.userInfo as! [String: Topic]
//        if let topic = userInfo[UpdateTopicOperation.Notifications.TopicKey] {
//            
//            if let rowForTopic = displayedTopics.indexOf(topic) {
//                
//                tableView.beginUpdates()
//                let indexPath = NSIndexPath(forRow: rowForTopic, inSection: 0)
//                tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
//                tableView.endUpdates()
//            }
//        }
//    }
}
