//
//  TopicMasterViewController.swift
//  rater
//
//  Created by Max on 6/23/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


class TopicMasterViewController: TableViewController {

    struct Notification {
        static let selectionDidChange = "topicMasterViewSelectionDidChange"
    }
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupTableView()
        view.addSubview(statusLabel)
        startObservations()
    }

    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        tabBarController!.tabBar.hidden = false
    }
    
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        statusLabel.frame = CGRectMake(0, 180, view.bounds.size.width, 32)
    }
    

    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
//        if isVisible() == false {
//            topics.removeAll()
//        }
    }

    
    deinit {
        endObservations()
    }
    
    
    //MARK: - Display
    
    lazy var statusLabel: UILabel = {
        
        let label = UILabel(frame: CGRectZero)
        label.textAlignment = .Center
        label.textColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
        label.text = "No Topics"
        return label
    }()
    
    
    enum StatusType {
        case Fetching, NoData, Default
    }
    
    
    func displayStatus(type: StatusType = .Default) {
        
        statusLabel.hidden = displayedTopics.count > 0
        
        switch type {
            
        case .Fetching:
            statusLabel.text = "Fetching Topics..."
            
        default:
            statusLabel.text = "No Topics"
        }
    }
    
    
    func setHeaderView(nibName nib: String, reuseIdentifier: String, height: CGFloat) {
        
        let nib = UINib(nibName: nib, bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        
        headerReuseIdentifier = reuseIdentifier
        headerViewHeight = height
    }
    
    
    
    //MARK: - Data
    
    private var topics = [Topic]()
    var displayedTopics: [Topic] {
        return topics
    }
    
    var selection: Topic? {
        
        didSet {
//            let notification = NSNotification(name: TopicMasterViewController.Notification.selectionDidChange, object: self)
//            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    
    
    func update() {
        //stub
        NSLog("NEED TO IMPLEMENT UPDATE FUNCTION")
    }
    

    func _handleUpdateTimerFire(timer: NSTimer) {

        update()
    }
    
    
    private var autoRefreshTimer: NSTimer?
    func startAutomaticallyUpdatingFetches() {
        
        autoRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "_handleUpdateTimerFire:", userInfo: nil, repeats: true)
    }
    
    
    func stopAutomaticallyUpdatingFetches() {
        
        if let autoRefreshTimer = autoRefreshTimer {
            autoRefreshTimer.invalidate()
        }
    }
    
    
    func hideRefreshControl() {
        
        self.refreshControl?.endRefreshing()
    }
    
    
    
    // MARK: - Table View
    
    private let cellNibName = "TopicMasterTableViewCell"
    private let cellIdentifier = "topicCell"
    private let cellHeight = CGFloat(125)
    
    private let imageCellNibName = "TopicWithImageMasterTableViewCell"
    private let imageCellIdentifier = "topicImageCell"
    private let imageCellHeight = CGFloat(285)
    
    var headerReuseIdentifier: String?
    var headerViewHeight = CGFloat(0.1)
    var footerViewHeight = CGFloat(1.0)
    
    private var lastRefreshedTableView: NSDate?
    
    private func setupTableView() {
        
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.background()
        tableView.showsHorizontalScrollIndicator = false

        refreshControl = {
            
            let rc = UIRefreshControl()
            rc.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
            rc.addTarget(self, action: "update", forControlEvents: UIControlEvents.ValueChanged)
            return rc
        }()
        
        let nib = UINib(nibName: cellNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
        
        let nib1 = UINib(nibName: imageCellNibName, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: imageCellIdentifier)
    }

    
    func refreshTableView(withTopics updatedTopics: [Topic], replacingDatasourceData: Bool) {
        
        let sortFn = { (a: AnyObject, b: AnyObject) -> Bool in
            
            let firstTime = (a as! BaseObject).updatedAt!
            let secondTime = (b as! BaseObject).updatedAt!
            return firstTime.laterDate(secondTime) == firstTime
        }
        
        if replacingDatasourceData {
            
            tableView.updateByReplacing(datasourceData: &topics, withData: updatedTopics, inSection: 0,sortingArraysWith: sortFn)
        }
        else {
            
            tableView.updateByAddingTo(datasourceData: &topics, withData: updatedTopics, inSection: 0,sortingArraysWith: sortFn)
        }
    }
    
    
    func reloadTableView(withTopics updatedTopics: [Topic]? = nil) {
        
        if let updatedTopics = updatedTopics {
            topics.removeAll()
            topics += updatedTopics
        }
        
        tableView.reloadData()
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return displayedTopics.count
    }
    

    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        let theTopic = displayedTopics[indexPath.row]
        if theTopic.hasImage() {
            return imageCellHeight
        }
        
        return cellHeight
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let theTopic = displayedTopics[indexPath.row]
        
        let identifier = theTopic.hasImage() ? imageCellIdentifier: cellIdentifier
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! TopicMasterTableViewCell
        
        cell.displayedTopic = theTopic
        return cell
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerViewHeight
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerViewHeight
    }
    
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headerId = headerReuseIdentifier {
            return tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerId)
        }
        
        let headerView = UITableViewHeaderFooterView(frame: CGRectZero)
        headerView.contentView.backgroundColor = UIColor.background()
        return headerView
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selection = displayedTopics[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    
    //MARK: - Observations
    
    func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidBecomeActiveNotification:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
    }
    
    
    // note:  call this AFTER subclass setup
    func endObservations() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func handleDidBecomeActiveNotification(notification: NSNotification) {
        
        // update table if it was last refreshed yesterday, for example
        if let lastRefreshedToday = lastRefreshedTableView?.isToday() {
            if lastRefreshedToday == false {
                update()
            }
        }
    }
    


    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destinationController = segue.destinationViewController as? NavigationController {
            destinationController.topic = selection
        }
    }
    
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        print("unwind in topic master view controller")
    }

}
