//
//  AuthoredTopicsViewController.swift
//  Ott
//
//  Created by Max on 9/11/2015
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class AuthoredTopicsViewController: TopicMasterViewController {

    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        fetchTopics()
    }

    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    
    override func viewDidDisappear(animated: Bool) {
        
        super.viewDidDisappear(animated)
    }
    
    
    
    //MARK: - Data
    
    private func fetchTopics() {
        
        displayStatus(.Fetching)
        
        let fetchTopicsOperation = FetchAuthoredTopicsOperation(user: currentUser())
        
        fetchTopicsOperation.addCompletionBlock({
            
            let cachedTopics = cachedTopicsAuthoredByUser(currentUser())
            dispatch_async(dispatch_get_main_queue()) {
                
                self.refreshTableView(withTopics: cachedTopics, replacingDatasourceData: true)
                self.hideRefreshControl()
                self.displayStatus()
            }
        })
        
        FetchQueue.sharedInstance.addOperation(fetchTopicsOperation)
    }
    
    
    override func update() {
        fetchTopics()
    }
    
    
    
    //MARK: - TableView
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        if let navController = navigationController as? NavigationController {
            navController.presentTopicDetailViewController(withTopic: selection)
        }
    }
    
    

    
    //MARK: - Observations
    
    override func startObservations() {
        
        super.startObservations()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidFetchTopicNotification:", name: FetchTopicOperation.Notifications.DidFetch, object: nil)
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
