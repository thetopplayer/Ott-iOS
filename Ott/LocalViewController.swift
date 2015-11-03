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
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        defaultStatusMessage = "Local"
        tableView.backgroundColor = UIColor.whiteColor() // change to backgroundColor after data is first loaded
    }

    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = false
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
    
    private var lastUpdated: NSDate?
    private var fetchOffset = 0
    private var moreToFetch = false
    private let fetchLimit = 100
    
    private func fetchTopics() {
        
        guard isFetching == false else {
            return
        }
        
        guard serverIsReachable() else {
            
            presentOKAlert(title: "Offline", message: "Unable to reach server.  Please make sure you have WiFi or a cell signal and try again.", actionHandler: { () -> Void in
                
                if self.activityIndicator.isAnimating() {
                    self.hideActivityFadingIn()
                }
            })
            
            return
        }
        
        guard moreToFetch == false else {
            return
        }
        
        guard fetchOffset < fetchLimit else {
            return
        }
        
        guard let location = LocationManager.sharedInstance.location else {
            print("call to fetch update but have no location")
            return
        }
        
        let localRadius = Double(20)
        
        let theQuery: PFQuery = {
            
            let query = Topic.query()!
            query.limit = 20
            query.skip = fetchOffset
            query.orderByDescending(DataKeys.CreatedAt)
            query.whereKey(DataKeys.Location, nearGeoPoint: PFGeoPoint(location: location), withinMiles: localRadius)
            if let lastUpdated = lastUpdated {
                query.whereKey(DataKeys.UpdatedAt, greaterThanOrEqualTo: lastUpdated)
            }
            
            return query
        }()
        
        isFetching = true
        theQuery.findObjectsInBackgroundWithBlock { (fetchResults, error) -> Void in
            
            self.isFetching = false
            
            guard let topics = fetchResults as? [Topic] else {
                print("no local topics fetched")
                return
            }
            
            if self.fetchOffset == 0 {
                self.lastUpdated = NSDate()
            }
            
            self.moreToFetch = topics.count < theQuery.limit
            self.fetchOffset += theQuery.skip
            
            dispatch_async(dispatch_get_main_queue()) {
                
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
        
        fetchOffset = 0
        fetchTopics()
    }
    
    
    
    //MARK: - TableView
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        presentTopicDetailViewController(withTopic: selection)
    }
    

    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section != Sections.Data.rawValue {
            return
        }
        
        if indexPath.row == displayedTopics.count - 1 {
            fetchTopics()
        }
    }


    
    //MARK: - Actions
    
    @IBAction func presentTopicCreationAction(sender: AnyObject) {
        
        presentTopicCreationViewController()
    }
    

    
    //MARK: - Observations
    
    override func startObservations() {
        
        super.startObservations()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocationChangeNotification:", name: LocationManager.Notifications.LocationDidSignificantlyChange, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidSaveTopicNotification:", name: TopicCreationViewController.Notifications.DidCreateTopic, object: nil)
    }
    
    
    func handleLocationChangeNotification(notification: NSNotification) {
        
        locationDidChange = true
        update()
    }

    
    func handleDidSaveTopicNotification(notification: NSNotification) {
        
        update()
    }
    
}
