//
//  FollowedTopicsViewController.swift
//  Ott
//
//  Created by Max on 10/2/15
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class FollowedTopicsViewController: TopicMasterViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        defaultStatusMessage = {
            let number = currentUser().followingCount
            return number == 1 ? "Following \(number) User" : "Following \(number) Users"
            }()
    }

    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = false
        
        fetchTopics()
    }
    
    

    //MARK: - Data
    
    private func fetchTopics() {
        
        guard isFetching == false else {
            return
        }
        
        isFetching = true
        
        guard serverIsReachable() else {
            
            isFetching = false
            presentOKAlert(title: "Offline", message: "Unable to reach server.  Please make sure you have WiFi or a cell signal and try again.", actionHandler: { () -> Void in
            })
            return
        }
        
        let numberOfFollowees = currentUser().followingCount
        
        if numberOfFollowees == 0 {
            isFetching = false
            return
        }
        
        
        // users being followed (followees) are cached in the background by the CacheManager:  fetch these, then iterature through them to retrieve the topics authored since our last fetch
        
        // used in below to keep track of how many follow relationships have been fetched
        let followeeQueryLimit = 25
        var numberOfPendingFolloweeFetches: Int = Int(ceilf(Float(numberOfFollowees) / Float(followeeQueryLimit)))
        
        func fetchTopicsForFollowees(followees: [Follow]) {
            
            if followees.count == 0 {
                isFetching = false
                return
            }
            
            var createdSince: NSDate
            if let lastFetched = Globals.sharedInstance.lastUpdatedFolloweeTopics {
                createdSince = lastFetched
            }
            else {
                createdSince = NSDate().daysFrom(-7)
            }
            Globals.sharedInstance.lastUpdatedFolloweeTopics = NSDate()
            
            var topicQueryOffset = 0
            var didFetchAllTopics = false
            while didFetchAllTopics == false {
                
                let topicQuery: PFQuery = {
                    
                    let query = Topic.query()!
                    query.whereKey(DataKeys.AuthorHandle, containedIn: followees)
                    query.whereKey(DataKeys.CreatedAt, greaterThanOrEqualTo: createdSince)
                    return query
                }()
                
                topicQuery.findObjectsInBackgroundWithBlock({ (fetchedObjects, error) -> Void in
                    
                    if let topics = fetchedObjects as? [Topic] {
                        
                        dispatch_async(dispatch_get_main_queue()) {
                            self.refreshTableView(withTopics: topics)
                        }
                        topicQueryOffset += topics.count
                        didFetchAllTopics = topics.count < topicQuery.limit
                        
                        self.isFetching = !(numberOfPendingFolloweeFetches > 0) && didFetchAllTopics
                    }
                    
                    if let error = error {
                        print("error fetching topics = \(error)")
                    }
                })
            }
        }
        
        for var followeeQueryOffset = 0; followeeQueryOffset < numberOfFollowees; followeeQueryOffset += followeeQueryLimit {
         
            let followeeQuery: PFQuery = {
                
                let query = Follow.query()!
                query.fromPinWithName(CacheManager.PinNames.FollowedByUser)
                query.skip = followeeQueryOffset
                query.limit = followeeQueryLimit
                query.orderByDescending(DataKeys.CreatedAt)
                query.whereKey(DataKeys.Follower, equalTo: currentUser())
                return query
            }()
            
            followeeQuery.findObjectsInBackgroundWithBlock({ (fetchedObjects, error) -> Void in
                
                if let followees = fetchedObjects as? [Follow] {
                    fetchTopicsForFollowees(followees)
                }
                
                numberOfPendingFolloweeFetches -= 1
            })
        }
    }
    
    
    override func update() {
        fetchTopics()
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
