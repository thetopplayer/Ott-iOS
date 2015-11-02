//
//  SearchViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class SearchViewController: ViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    @IBOutlet var tableView: TableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var noResultsLabel: UILabel!
    
    var searchBar: UISearchBar?
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        searchBar = {
            
            let width = navigationController!.navigationBar.frame.size.width
            let height = navigationController!.navigationBar.frame.size.width
            let searchFrame = CGRectMake(0, 0, width, height)
            let bar = UISearchBar(frame: searchFrame)
            
            bar.delegate = self
            bar.barTintColor = UIColor.blackColor()
            bar.translucent = true
            return bar
            }()
        
        navigationItem.titleView = searchBar
        showCreateButton()
        
        noResultsLabel.hidden = true
        
        view.backgroundColor = UIColor.whiteColor()
        setupTableView()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        if tableView.numberOfSections == 0 {
            searchBar?.becomeFirstResponder()
        }
    }
    
    
    
    //MARK: - Search
    
    private func showCreateButton() {
        
        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "presentTopicCreationAction:")
        navigationItem.rightBarButtonItem = createButton
    }
    
    
    private func showCancelButton() {
        
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "cancelSearch:")
        navigationItem.rightBarButtonItem = cancelButton
    }
    
    
    @IBAction func cancelSearch(sender: AnyObject?) {
        
        users.removeAll()
        topics.removeAll()
        noResultsLabel.hidden = true
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.searchBar!.text = ""
            self.searchBar!.resignFirstResponder()
            self.showCreateButton()
            self.tableView.reloadData()
        }
    }
    
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        
        users.removeAll()
        topics.removeAll()
        noResultsLabel.hidden = true
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.showCancelButton()
            self.tableView.reloadData()
        }
    }
    
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        
        
    }
    
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        
        
    }
    
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        guard let searchPhrase = searchBar.text else {
            return
        }
        
        guard searchPhrase.length > 0 else {
            return
        }
        
        fetchObjectsWithSearchPhrase(searchPhrase)
        searchBar.resignFirstResponder()
    }
    
    
    //MARK: - Data
    
    var users = [User]()
    var topics = [Topic]()
    
    
    private func fetchObjectsWithSearchPhrase(searchPhrase: String, limit: Int = 10) {
        
        guard serverIsReachable() else {
            
            presentOKAlert(title: "Offline", message: "Unable to reach server.  Please make sure you have WiFi or a cell signal and try again.", actionHandler: { () -> Void in
            })
            return
        }
        
        activityIndicator.startAnimating()
        
        let lowercaseString = searchPhrase.lowercaseString
        let cleanedString = lowercaseString.stringByRemovingCharactersInString(".,;:\"")
        let wordArray = cleanedString.componentsSeparatedByString(" ")
        
        let userQuery = User.query()!
        let topicQuery = Topic.query()!
        
        let theQueries: [PFQuery] = [userQuery, topicQuery]
        
        userQuery.whereKey(DataKeys.SearchWords, containsAllObjectsInArray: wordArray)
        for query in theQueries {
            
            query.whereKey(DataKeys.SearchWords, containsAllObjectsInArray: wordArray)
            query.orderByDescending(DataKeys.CreatedAt)
            query.limit = limit
        }
        
        // cannot or queries with different classes, so create separate operations for each
        
        let userFetchOperation = FetchOperation(dataSource: .Server, query: userQuery) { (fetchResults, error) -> Void in
            
            if let fetchResults = fetchResults as? [User] {
                self.users = fetchResults
            }
        }
        
        let topicFetchOperation = FetchOperation(dataSource: .Server, query: topicQuery) { (fetchResults, error) -> Void in
            
            if let fetchResults = fetchResults as? [Topic] {
                self.topics = fetchResults
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.activityIndicator.stopAnimating()
                self.noResultsLabel.hidden = (self.users.count > 0) || (self.topics.count > 0)

                self.tableView.reloadData()
            }
        }
        
        topicFetchOperation.addDependency(userFetchOperation)
        
        FetchQueue.sharedInstance.addOperation(userFetchOperation)
        FetchQueue.sharedInstance.addOperation(topicFetchOperation)
    }
    
    
    //MARK: - TableView
    
    private let userCellViewNibName = "UserTableViewCell"
    private let userCellViewIdentifer = "userCell"
    private let userCellViewHeight = CGFloat(69)
    
    private let topicCellViewNibName = "TopicMasterTableViewCell"
    private let topicCellViewIdentifier = "topicMaster"
    private let topicCellViewHeight = CGFloat(96)
    
    private let topicWithImageCellViewNibName = "TopicWithImageMasterTableViewCell"
    private let topicWithImageCellViewIdentifier = "topicImageMaster"
    private let topicWithImageCellViewHeight = CGFloat(117)
    
    private let loadingDataCellViewNibName = "LoadingTableViewCell"
    private let loadingDataCellViewIdentifier = "loadingCell"
    private let loadingDataCellViewHeight = CGFloat(44)
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        
        let nib = UINib(nibName: userCellViewNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: userCellViewIdentifer)
        
        let nib3 = UINib(nibName: topicCellViewNibName, bundle: nil)
        tableView.registerNib(nib3, forCellReuseIdentifier: topicCellViewIdentifier)
        
        let nib4 = UINib(nibName: topicWithImageCellViewNibName, bundle: nil)
        tableView.registerNib(nib4, forCellReuseIdentifier: topicWithImageCellViewIdentifier)
    }
    
    
    enum SectionType {
        case User, Topic
    }
    
    
    enum CellType {
        case User, TopicNoImage, TopicWithImage
    }
    
    
    private func isDisplayingUsers() -> Bool {
        return users.count > 0
    }
    
    
    private func isDisplayingTopics() -> Bool {
        return topics.count > 0
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        var number = 0
        if isDisplayingUsers() {
            number++
        }
        if isDisplayingTopics() {
            number++
        }
        
        return number
    }
    
    
    private func sectionTypeForSection(section: Int) -> SectionType {
        
        var type: SectionType?
        switch section {
            
        case 0:
            
            if isDisplayingUsers() {
                type = .User
            }
            else if isDisplayingTopics() {
                type = .Topic
            }
            
        case 1:
            
            type = .Topic
            
        default:
            assert(false)
        }
        
        return type!
    }
    
    
    private func cellTypeForObject(object: PFObject) -> CellType {
        
        var theType: CellType?
        
        if object is User {
            theType = .User
        }
        else if object is Topic {
            if (object as! Topic).imageFile == nil {
                theType = .TopicNoImage
            }
            else {
                theType = .TopicWithImage
            }
        }
        
        return theType!
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) ->  CGFloat {
        
        return 36
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        let title: String?
        
        switch sectionTypeForSection(section) {
            
        case .User:
            title = "Users"
            
        case .Topic:
            title = "Topics"
        }
        
        return title!
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var number = 0
        switch sectionTypeForSection(section) {
            
        case .User:
            number = users.count
            
        case .Topic:
            number = topics.count
        }
        
        return number
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height: CGFloat = 0
        
        switch sectionTypeForSection(indexPath.section) {
            
        case .User:
            height = userCellViewHeight
            
        case .Topic:
            height = topicWithImageCellViewHeight
        }
        return height
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        func initializeuserCell(user: User) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(userCellViewIdentifer) as! UserTableViewCell
            
            cell.user = user
            return cell
        }
        
        func initializetopicCell(topic: Topic) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(topicCellViewIdentifier) as! TopicMasterTableViewCell
            cell.displayedTopic = topic
            return cell
        }
        
        func initializeTopicWithImageCell(topic: Topic) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(topicWithImageCellViewIdentifier) as! TopicMasterTableViewCell
            cell.displayedTopic = topic
            return cell
        }
        
        
        var cell: UITableViewCell
        
        switch sectionTypeForSection(indexPath.section) {
            
        case .User:
            
            let user = users[indexPath.row]
            cell = initializeuserCell(user)
            
        case .Topic:
            
            let topic = topics[indexPath.row]
            if topic.imageFile != nil {
                cell = initializeTopicWithImageCell(topic)
            }
            else {
                cell = initializetopicCell(topic)
            }
        }
        
        return cell
    }
    
    
    
    //
    //    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    //
    //        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
    //        presentTopicDetailViewController(withTopic: selection)
    //    }
    
    
    
    //MARK: - Actions
    
    @IBAction func presentTopicCreationAction(sender: AnyObject) {
        
        presentTopicCreationViewController()
    }
    
    
    @IBAction func presentTopicScanViewController(sender: AnyObject) {
        
        if let navController = navigationController as? NavigationController {
            navController.presentTopicScanViewController()
        }
    }
    
    
}

