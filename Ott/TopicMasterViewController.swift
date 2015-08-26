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
            data = []
        }
    }
    
    
    deinit {
        endObservations()
    }

    
    
    //MARK: - Display
    
    private func updateNoDataLabel() {
        
        noDataLabel?.hidden = data.count > 0
    }
    
    
    func setHeaderView(nibName nib: String, reuseIdentifier: String, height: CGFloat) {
        
        let nib = UINib(nibName: nib, bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        
        headerReuseIdentifier = reuseIdentifier
        headerViewHeight = height
    }
    
    
    
    //MARK: - Data
    
    private var data = [Topic]()
    private var updatedData = [Topic]()
    func updateTable(withData data: [Topic], replacingExistingData: Bool = true) {
        
        updatedData = data
        refreshTableView(replacingExistingData: replacingExistingData)
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

    
    private func refreshTableView(replacingExistingData replacingExistingData: Bool = true) {
        
        let existingSet = Set(data)
        let updatedSet = Set(updatedData)
        
        // deletions
        let removedObjects = existingSet.subtract(updatedSet)
        var indexPathsForRemoval = [NSIndexPath]()
        for var index = 0; index < data.count; index++ {
            if removedObjects.contains(data[index]) {
                let ip = NSIndexPath(forRow: index, inSection: 0)
                indexPathsForRemoval.append(ip)
            }
        }
        
        // updates
        let updatedObjects = updatedSet.intersect(existingSet)
        var indexPathsForUpdate = [NSIndexPath]()
        for var index = 0; index < data.count; index++ {
            if updatedObjects.contains(data[index]) {
                let ip = NSIndexPath(forRow: index, inSection: 0)
                indexPathsForUpdate.append(ip)
            }
        }
        
        // insertions
        let addedObjects = updatedSet.subtract(existingSet)
        let finalData: [Topic] = {
            
            var finalSet = addedObjects.union(updatedObjects)
            
            // add back removed objects if we aren't deleting any
            if replacingExistingData == false {
                finalSet = finalSet.union(removedObjects)
            }
            
            return Array(finalSet).sort({ (a, b) -> Bool in
                return a.updatedAt!.laterDate(b.updatedAt!) == a.updatedAt!
            })
           
        }()
        
        var indexPathsForInsert = [NSIndexPath]()
        for var index = 0; index < finalData.count; index++ {
            if addedObjects.contains(finalData[index]) {
                let ip = NSIndexPath(forRow: index, inSection: 0)
                indexPathsForInsert.append(ip)
            }
        }
        
        // implement
        dispatch_async(dispatch_get_main_queue(), {
            
            // replace the data used by the table
            self.data = finalData
            self.updatedData = []
            
            self.tableView.beginUpdates()
            if replacingExistingData {
                self.tableView.deleteRowsAtIndexPaths(indexPathsForRemoval, withRowAnimation: .Automatic)
            }
            
            self.tableView.reloadRowsAtIndexPaths(indexPathsForUpdate, withRowAnimation: .None)
            self.tableView.insertRowsAtIndexPaths(indexPathsForInsert, withRowAnimation: .Top)
            self.tableView.endUpdates()
            
            self.updateNoDataLabel()
            self.lastRefreshedTableView = NSDate()
        })
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return data.count
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let theTopic = data[indexPath.row]
        
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
        
        selection = data[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
    
    
    
    //MARK: - Observations
    
    private var didStartObservations = false
    func startObservations() {
        
        if didStartObservations {
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidBecomeActiveNotification:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidPostNotification:", name: TopicDetailViewController.Notifications.DidUploadPost, object: nil)
        
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
    
    
    func handleDidPostNotification(notification: NSNotification) {
        
        update()
    }
    
    

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destinationController = segue.destinationViewController as? NavigationController {
            destinationController.topic = selection
        }
    }

}
