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
    
    
    var isFetching = false {
        
        didSet {
            dispatch_async(dispatch_get_main_queue()) {
                
                if self.isFetching {
                    self.tableView.startRefreshControlAnimation()
                    self.displayStatus("Fetching...")
                }
                else {
                    self.tableView.stopRefreshControlAnimation()
                    self.displayStatus()
                }
            }
        }
    }
    
    
    // MARK: - Table View
    
    enum Sections: Int {
        case Data = 0
    }
    
    private let topicCellNibName = "TopicMasterTableViewCell"
    private let topicCellIdentifier = "topicMaster"
    private let topicCellHeight = CGFloat(96)
    
    private let topicWithImageCellNibName = "TopicWithImageMasterTableViewCell"
    private let topicWithImageCellIdentifier = "topicImageMaster"
    private let topicWithImageCellHeight = CGFloat(117)

    var headerReuseIdentifier: String?
    var headerViewHeight = CGFloat(0.1)
    var footerViewHeight = CGFloat(0.1)
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self        
        tableView.showsHorizontalScrollIndicator = false

        tableView.useRefreshControl(forTarget: self, action: "update")
        
        let nib1 = UINib(nibName: topicCellNibName, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: topicCellIdentifier)
        let nib2 = UINib(nibName: topicWithImageCellNibName, bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: topicWithImageCellIdentifier)
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

        return willBecomeVisible() ? 1 : 0
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return displayedTopics.count
    }
    
    
    private enum CellType {
        case NoImage, Image
    }
    

    private func cellTypeForIndexPath(indexPath: NSIndexPath) -> CellType {
        
        let theTopic = displayedTopics[indexPath.row]
        return theTopic.imageFile != nil ? .Image : .NoImage
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height = CGFloat(0)
        switch cellTypeForIndexPath(indexPath) {
            
        case .NoImage:
            height = topicCellHeight
            
        case .Image:
            height = topicWithImageCellHeight
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidPostToTopicNotification:", name: TopicDetailViewController.Notifications.DidPostToTopic, object: nil)
    }
    
    
    // note:  call this AFTER subclass setup
    func endObservations() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
