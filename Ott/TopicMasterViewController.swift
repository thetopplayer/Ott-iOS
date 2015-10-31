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
    
    
    override func viewDidLayoutSubviews() {
        
        super.viewDidLayoutSubviews()
//        statusLabel.frame = CGRectMake(0, 180, view.bounds.size.width, 32)
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
    
//    lazy var statusLabel: UILabel = {
//        
//        let label = UILabel(frame: CGRectZero)
//        label.textAlignment = .Center
//        label.textColor = UIColor.lightGrayColor()
//        label.text = "No Topics"
//        return label
//    }()
    
    
    enum StatusType {
        case Fetching, NoData, Default
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
    
    
    func showRefreshControl() {
        tableView.refreshControl.beginRefreshing()
    }
    
   
    func hideRefreshControl() {
        tableView.refreshControl.endRefreshing()
    }
    
    
    
    // MARK: - Table View
    
    private let cellNibName2 = "TopicMasterTableViewCellTwo"
    private let cellIdentifier2 = "topicCellTwo"
    private let cellNibName3 = "TopicMasterTableViewCellThree"
    private let cellIdentifier3 = "topicCellThree"
    
    private let cellHeight = CGFloat(72)
    private let cellHeightWithComment = CGFloat(96)
    private let imageCellHeight = CGFloat(117)
    
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
        
        let nib2 = UINib(nibName: cellNibName2, bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: cellIdentifier2)
        let nib3 = UINib(nibName: cellNibName3, bundle: nil)
        tableView.registerNib(nib3, forCellReuseIdentifier: cellIdentifier3)
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
        return 1
    }

    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return displayedTopics.count
    }
    
    
    private enum CellType {
        case NoImage, Image
    }
    

    private func cellTypeForIndexPath(indexPath: NSIndexPath) -> CellType {
        
        let theTopic = displayedTopics[indexPath.row]
        var type: CellType
        
        if theTopic.imageFile != nil {
            type = .Image
        }
        else {
            type = .NoImage
        }
        
        return type
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height = CGFloat(0)
        switch cellTypeForIndexPath(indexPath) {
            
        case .NoImage:
            height = cellHeightWithComment
            
        case .Image:
            height = imageCellHeight
        }
        
        return height
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let identifier: String
        switch cellTypeForIndexPath(indexPath) {
            
        case .NoImage:
            identifier = cellIdentifier2
            
        case .Image:
            identifier = cellIdentifier3
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as! TopicMasterTableViewCell
        cell.displayedTopic = displayedTopics[indexPath.row]

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
