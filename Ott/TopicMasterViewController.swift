//
//  TopicMasterViewController.swift
//  rater
//
//  Created by Max on 6/23/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


class TopicMasterViewController: TableViewController {

    @IBOutlet var noDataLabel: UILabel?
    
    struct Notification {
        static let selectionDidChange = "topicMasterViewSelectionDidChange"
    }
    
    
    private let cellNibName = "TopicMasterTableViewCell"
    private let cellIdentifier = "topicCell"
    private let cellHeight = CGFloat(125)
    
    private let imageCellNibName = "TopicWithImageMasterTableViewCell"
    private let imageCellIdentifier = "topicImageCell"
    private let imageCellHeight = CGFloat(125)
    
    var headerReuseIdentifier: String?
    var headerViewHeight = CGFloat(0.1)
    var footerViewHeight = CGFloat(1.0)
    
    private var lastRefreshedTableView: NSDate?
    
       
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupTableView()
        
        let frame = CGRectMake(0, 180, view.bounds.size.width, 32)
        noDataLabel = UILabel(frame: frame)
        noDataLabel!.textAlignment = .Center
        noDataLabel!.textColor = UIColor.lightGrayColor()
        noDataLabel!.text = "No Topics"
        
        self.view.addSubview(noDataLabel!)
        
        startObservations()
        startRefreshDataTimer()
    }

    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
        if let label = noDataLabel {
            label.frame = CGRectMake(0, 180, view.bounds.size.width, 32)
        }
    }
    

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        updateNoDataLabel()
    }
    
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        
        if isVisible() == false {
            data = nil
        }
    }
    
    
    deinit {
        endObservations()
    }

    
    
    //MARK: - Display
    
    private func updateNoDataLabel() {
        
        if data == nil {
            noDataLabel?.hidden = false
        }
        else {
            noDataLabel?.hidden = data!.count > 0
        }
    }
    
    
    func setHeaderView(nibName nib: String, reuseIdentifier: String, height: CGFloat) {
        
        let nib = UINib(nibName: nib, bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        
        headerReuseIdentifier = reuseIdentifier
        headerViewHeight = height
    }
    
    
    
    //MARK: - Data
    
    private var data: [Topic]?

    func updateTable(withData withData: [Topic]?) {
        
        if data == nil {
            
            data = withData
            refreshTableView()
            return
        }
        
        
        // insert rows for new data
        // update existing rows with updated data
        
        
        
    }
    
    
    var selection: Topic? {
        
        didSet {
            let notification = NSNotification(name: TopicMasterViewController.Notification.selectionDidChange, object: self)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    
    
    private var _lastUpdated: NSDate?
    var lastUpdated: NSDate {
        
        if let date = _lastUpdated {
            return date
        }
        return NSDate.distantPast()
    }
    

    func update() {

        _lastUpdated = NSDate()
        
        //stub
        NSLog("NEED TO IMPLEMENT UPDATE FUNCTION")
    }
    

    func _handleUpdateTimerFire(timer: NSTimer) {
        update()
    }
    
    
    private func startRefreshDataTimer() {
        
        NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "_handleUpdateTimerFire:", userInfo: nil, repeats: true)
    }
    
    
    
    // MARK: - Table View
    
    private func setupTableView() {
        
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.background()
        tableView.showsHorizontalScrollIndicator = false
        
        tableView.estimatedRowHeight = cellHeight
        
        let nib = UINib(nibName: cellNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: cellIdentifier)
        
        let nib1 = UINib(nibName: imageCellNibName, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: imageCellIdentifier)
    }

    
    private func refreshTableView() {
        
        // TODO - compare previous and new data sets and insert/delete rows, instead of reloading all
        
        NSLog("refreshing table view")
        dispatch_async(dispatch_get_main_queue(), {
            
            self.updateNoDataLabel()
            self.tableView.reloadData()
            self.lastRefreshedTableView = NSDate()
        })
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if data != nil {
            return data!.count
        }
        return 0
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let theTopic = data![indexPath.row]
        
        let identifier = theTopic.hasImage ? imageCellIdentifier: cellIdentifier
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
    
    
//    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//
//        let theTopic = data![indexPath.row]
//        if theTopic.hasImage {
//            return imageCellHeight
//        }
//        return cellHeight
//    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selection = data![indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    
    //MARK: - Observations
    
    private var didStartObservations = false
    private func startObservations() {
        
        if didStartObservations {
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidBecomeActiveNotification:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleLocationChangeNotification:", name: LocationManager.Notifications.SignificantLocationChangeDidOccur, object: nil)
        
        didStartObservations = true
    }
    
    
    private func endObservations() {
        
        if didStartObservations == false {
            return
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        didStartObservations = false
    }
    
    
    func handleDidBecomeActiveNotification(notification: NSNotification) {
        
        // update table if it was last refreshed yesterday, for example
        if let lastRefreshedToday = lastRefreshedTableView?.isToday() {
            if lastRefreshedToday == false {
                refreshTableView()
            }
        }
    }
    
    
    func handleLocationChangeNotification(notification: NSNotification) {

        update()
    }
    
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destinationController = segue.destinationViewController as? NavigationController {
            destinationController.topic = selection
        }
    }

}
