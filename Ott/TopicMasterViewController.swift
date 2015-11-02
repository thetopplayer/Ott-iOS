//
//  TopicMasterViewController.swift
//  rater
//
//  Created by Max on 6/23/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


class TopicMasterViewController: ViewController, UITableViewDelegate, UITableViewDataSource {

    
    @IBOutlet var tableView: TableView!
    
    //MARK: - Lifecycle

    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        setupTableView()
        var insets = tableView.contentInset
        insets.bottom -= tabBarController!.tabBar.frame.size.height
        tableView.contentInset = insets

        startObservations()
    }

    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        tabBarController!.tabBar.hidden = false
    }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        reloadCellsAtIndexPaths()
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
    
//    lazy var statusLabel: UILabel = {
//        
//        let label = UILabel(frame: CGRectZero)
//        label.textAlignment = .Center
//        label.textColor = UIColor.lightGrayColor()
//        label.text = "No Topics"
//        return label
//    }()
    
    
    func setHeaderView(nibName nib: String, reuseIdentifier: String, height: CGFloat) {
        
        let nib = UINib(nibName: nib, bundle: nil)
        tableView.registerNib(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        
        headerReuseIdentifier = reuseIdentifier
        headerViewHeight = height
    }
    
    
    private var indexPathsToReload = [NSIndexPath]()
    func reloadCellsAtIndexPaths(paths: [NSIndexPath]? = nil) {
        
        if let paths = paths {
            indexPathsToReload += paths
        }
        
        if indexPathsToReload.count == 0 {
            return
        }
        
        if isVisible() {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.tableView.beginUpdates()
                self.tableView.reloadRowsAtIndexPaths(self.indexPathsToReload, withRowAnimation: .Automatic)
                self.tableView.endUpdates()
                
                self.indexPathsToReload.removeAll()
            }
        }
    }
    
    
    
    //MARK: - Data
    
    private var topics = [Topic]()
    var displayedTopics: [Topic] {
        return topics
    }
    
    var selection: Topic?    
    
    func update() {
        //stub
    }
    
    
    func showRefreshControl() {
        tableView.refreshControl.beginRefreshing()
    }
    
   
    func hideRefreshControl() {
        tableView.refreshControl.endRefreshing()
    }
    
    
    private var _isFetching = false
    var isFetching = false {
        
        didSet {
            if _isFetching == isFetching {
                return
            }
            
            _isFetching = isFetching
            dispatch_async(dispatch_get_main_queue()) {
                if self.isFetching {
                    self.tableView.insertSections(NSIndexSet(index: Sections.LoadingStatus.rawValue), withRowAnimation: .Automatic)
                }
                else {
                    self.tableView.deleteSections(NSIndexSet(index: Sections.LoadingStatus.rawValue), withRowAnimation: .Automatic)
                }
            }
        }
    }
    
    
    // MARK: - Table View
    
    enum Sections: Int {
        case Data = 0
        case LoadingStatus = 1
    }
    
    private let topicCellNibName = "TopicMasterTableViewCell"
    private let topicCellIdentifier = "topicMaster"
    private let topicCellHeight = CGFloat(96)
    
    private let topicWithImageCellNibName = "TopicWithImageMasterTableViewCell"
    private let topicWithImageCellIdentifier = "topicImageMaster"
    private let topicWithImageCellHeight = CGFloat(117)
    
    private let loadingDataCellViewNibName = "LoadingTableViewCell"
    private let loadingDataCellViewIdentifier = "loadingCell"
    private let loadingDataCellViewHeight = CGFloat(44)
    
    var headerReuseIdentifier: String?
    var headerViewHeight = CGFloat(0.1)
    var footerViewHeight = CGFloat(0.1)
    
    private var lastRefreshedTableView: NSDate?
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self        
        tableView.showsHorizontalScrollIndicator = false

        tableView.useRefreshControl()
        tableView.refreshControl.addTarget(self, action: "update", forControlEvents: UIControlEvents.ValueChanged)
        
        let nib1 = UINib(nibName: topicCellNibName, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: topicCellIdentifier)
        let nib2 = UINib(nibName: topicWithImageCellNibName, bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: topicWithImageCellIdentifier)
        let nib3 = UINib(nibName: loadingDataCellViewNibName, bundle: nil)
        tableView.registerNib(nib3, forCellReuseIdentifier: loadingDataCellViewIdentifier)
    }

    
    func refreshTableView(withTopics updatedTopics: [Topic], replacingDatasourceData: Bool = false) {
        
        let sortFn = { (a: AnyObject, b: AnyObject) -> Bool in
            
            let firstTime = (a as! DataObject).createdAt!
            let secondTime = (b as! DataObject).createdAt!
            return firstTime.laterDate(secondTime) == firstTime
        }
        
        if replacingDatasourceData {
            tableView.updateByReplacing(datasourceData: &topics, withData: updatedTopics, inSection: 0, sortingArraysWith: sortFn)
        }
        else {
            tableView.updateByAddingTo(datasourceData: &topics, withData: updatedTopics, inSection: 0, sortingArraysWith: sortFn)
        }
    }
    
    
    func reloadTableView(withTopics updatedTopics: [Topic]? = nil) {
        
        if let updatedTopics = updatedTopics {
            topics.removeAll()
            topics += updatedTopics
        }
        
        tableView.reloadData()
    }

    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        let number = isFetching ? 2 : 1
        return number
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return displayedTopics.count
    }
    
    
    private enum CellType {
        case NoImage, Image, Loading
    }
    

    private func cellTypeForIndexPath(indexPath: NSIndexPath) -> CellType {
        
        var type: CellType
        if indexPath.section == Sections.Data.rawValue {
            let theTopic = displayedTopics[indexPath.row]
            type = theTopic.imageFile != nil ? .Image : .NoImage
        }
        else {
            type = .Loading
        }
        
        return type
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height = CGFloat(0)
        switch cellTypeForIndexPath(indexPath) {
            
        case .NoImage:
            height = topicCellHeight
            
        case .Image:
            height = topicWithImageCellHeight
            
        case .Loading:
            height = loadingDataCellViewHeight
        }
        
        return height
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        switch cellTypeForIndexPath(indexPath) {
            
        case .NoImage:
            let theCell = tableView.dequeueReusableCellWithIdentifier(topicCellIdentifier, forIndexPath: indexPath) as! TopicMasterTableViewCell
            theCell.displayedTopic = displayedTopics[indexPath.row]
            cell = theCell
            
        case .Image:
            let theCell = tableView.dequeueReusableCellWithIdentifier(topicWithImageCellIdentifier, forIndexPath: indexPath) as! TopicMasterTableViewCell
            theCell.displayedTopic = displayedTopics[indexPath.row]
            cell = theCell
            
        case .Loading:
            let theCell = tableView.dequeueReusableCellWithIdentifier(loadingDataCellViewIdentifier, forIndexPath: indexPath) as! LoadingTableViewCell
            cell = theCell
        }
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerViewHeight
    }
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return footerViewHeight
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if let headerId = headerReuseIdentifier {
            return tableView.dequeueReusableHeaderFooterViewWithIdentifier(headerId)
        }
        
        let headerView = UITableViewHeaderFooterView(frame: CGRectZero)
        headerView.contentView.backgroundColor = UIColor.background()
        return headerView
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        selection = displayedTopics[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }

    
    
    //MARK: - Observations
    
    func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidBecomeActiveNotification:", name: UIApplicationDidBecomeActiveNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidPostToTopicNotification:", name: TopicDetailViewController.Notifications.DidPostToTopic, object: nil)
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
    
    
    func handleDidPostToTopicNotification(notification: NSNotification) {
        
        let topic = notification.userInfo![TopicDetailViewController.Notifications.Topic] as! Topic
        if let index = displayedTopics.indexOf(topic) {
            
            let ip = NSIndexPath(forRow: index, inSection: 0)
            reloadCellsAtIndexPaths([ip])
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
