//
//  LocalViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class LocalViewController: TopicMasterViewController {

    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    var locationDidChange = true
    var lastUpdated: NSDate?
    var fetchOffset = 0
    var moreToFetch = false
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "presentTopicCreationAction:")
        navigationItem.rightBarButtonItem = createButton
        
        defaultStatusMessage = "Local"
        // change to backgroundColor after data is first loaded
        tableView.backgroundColor = UIColor.whiteColor()
    }

    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        if let lastUpdated = lastUpdated {
            
            if lastUpdated.minutesFromNow(absolute: true) > 2 {
                fetchTopics()
            }
        }
        else {
        
            showActivityFadingOut()
            fetchTopics()
        }
    }
    
    
    private func showActivityFadingOut() {
        
        activityIndicator.startAnimating()
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.tableView.alpha = 0
        })
    }
    
    
    private func hideActivityFadingIn() {
        
        activityIndicator.stopAnimating()
        tableView.backgroundColor = UIColor.background()  // should have started with white

        UIView.animateWithDuration(0.3, animations: { () -> Void in
            self.tableView.alpha = 1
        })
    }
    
    
    
    //MARK: - Data
    
    var fetchTime: NSDate?
    
    private func fetchTopics(offset: Int = 0) {
        
        guard let location = LocationManager.sharedInstance.location else {
            print("call to fetch update but have no location")
            return
        }
        
        displayStatus("Fetching...")
        
        let localRadius = Double(20)
        
        let theQuery: PFQuery = {
            
            let query = Topic.query()!
            query.limit = 20
            query.skip = offset
            query.orderByDescending(DataKeys.CreatedAt)
            query.whereKey(DataKeys.Location, nearGeoPoint: PFGeoPoint(location: location), withinMiles: localRadius)
            if let lastUpdated = lastUpdated {
                query.whereKey(DataKeys.UpdatedAt, greaterThanOrEqualTo: lastUpdated)
            }
            
            return query
        }()
        
        theQuery.findObjectsInBackgroundWithBlock { (fetchResults, error) -> Void in
            
            guard let topics = fetchResults as? [Topic] else {
                print("no local topics fetched")
                return
            }
            
            if offset == 0 {
                self.lastUpdated = NSDate()
            }
            
            self.moreToFetch = topics.count < theQuery.limit
            self.fetchOffset += theQuery.skip
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.displayStatus()
                
                self.refreshTableView(withTopics: topics, replacingDatasourceData: self.locationDidChange)
                self.locationDidChange = false
               
                self.hideActivityFadingIn()
                self.hideRefreshControl()
                
                if let error = error {
                    if self.isVisible() {
                        self.presentOKAlertWithError(error, messagePreamble: "Error retrieving local topics.", actionHandler: nil)
                    }
                }
            }
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocationChangeNotification:", name: LocationManager.Notifications.LocationDidChange, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidUploadTopicNotification:", name: UploadTopicOperation.Notifications.DidUpload, object: nil)
    }
    
    
    func handleLocationChangeNotification(notification: NSNotification) {
        
        locationDidChange = true
        update()
    }

    
    func handleDidUploadTopicNotification(notification: NSNotification) {
        
        update()
    }
    
}
