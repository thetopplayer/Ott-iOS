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
        
        // todo:  this was being triggered in the middle of a table load
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
    }
    
//
//    func _handleUpdateTimerFire(timer: NSTimer) {
//
//        update()
//    }
//    
//    
//    private var autoRefreshTimer: NSTimer?
//    func startAutomaticallyUpdatingFetches() {
//        
//        autoRefreshTimer = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: "_handleUpdateTimerFire:", userInfo: nil, repeats: true)
//    }
//    
//    
//    func stopAutomaticallyUpdatingFetches() {
//        
//        if let autoRefreshTimer = autoRefreshTimer {
//            autoRefreshTimer.invalidate()
//        }
//    }
//    
    
    func hideRefreshControl() {
        
        refreshControl?.endRefreshing()
    }
    
    
    
    // MARK: - Table View
    
    private let cellNibName1 = "TopicMasterTableViewCellOne"
    private let cellIdentifier1 = "topicCellOne"
    private let cellNibName2 = "TopicMasterTableViewCellTwo"
    private let cellIdentifier2 = "topicCellTwo"
    private let cellNibName3 = "TopicMasterTableViewCellThree"
    private let cellIdentifier3 = "topicCellThree"
    
    private let cellHeight = CGFloat(72)
    private let cellHeightWithComment = CGFloat(96)
    private let imageCellHeight = CGFloat(117)
    
    var headerReuseIdentifier: String?
    var headerViewHeight = CGFloat(0.1)
    var footerViewHeight = CGFloat(1.0)
    
    private var lastRefreshedTableView: NSDate?
    
    private func setupTableView() {
        
        tableView.backgroundColor = UIColor.background()
        tableView.showsHorizontalScrollIndicator = false

        refreshControl = {
            
            let rc = UIRefreshControl()
            rc.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
            rc.addTarget(self, action: "update", forControlEvents: UIControlEvents.ValueChanged)
            return rc
        }()
        
        let nib1 = UINib(nibName: cellNibName1, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: cellIdentifier1)
        let nib2 = UINib(nibName: cellNibName2, bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: cellIdentifier2)
        let nib3 = UINib(nibName: cellNibName3, bundle: nil)
        tableView.registerNib(nib3, forCellReuseIdentifier: cellIdentifier3)
    }

    
    func refreshTableView(withTopics updatedTopics: [Topic], replacingDatasourceData: Bool) {
        
        let sortFn = { (a: AnyObject, b: AnyObject) -> Bool in
            
            let firstTime = (a as! DataObject).updatedAt!
            let secondTime = (b as! DataObject).updatedAt!
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
    
    
    private enum CellType {
        case NoCommentNoImage, NoImage, Image
    }
    

    private func cellTypeForIndexPath(indexPath: NSIndexPath) -> CellType {
        
        let theTopic = displayedTopics[indexPath.row]
        var type: CellType
        
        if theTopic.imageFile != nil {
            type = .Image
        }
        else {
//            if theTopic.comment == nil {
//                type = .NoCommentNoImage
//            }
//            else {
                type = .NoImage
//            }
        }
        
        return type
    }
    
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height = CGFloat(0)
        switch cellTypeForIndexPath(indexPath) {
            
        case .NoCommentNoImage:
            height = cellHeight
            
        case .NoImage:
            height = cellHeightWithComment
            
        case .Image:
            height = imageCellHeight
        }
        
        return height
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier: String
        switch cellTypeForIndexPath(indexPath) {
            
        case .NoCommentNoImage:
            identifier = cellIdentifier1
            
        case .NoImage:
            identifier = cellIdentifier2
            
        case .Image:
            identifier = cellIdentifier3
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! TopicMasterTableViewCell
        cell.displayedTopic = displayedTopics[indexPath.row]

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
