//
//  UserDetailViewController.swift
//  Ott
//
//  Created by Max on 9/23/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit

class UserDetailViewController: TableViewController {
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupTableView()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true

        // if data has not been set, look to my navigation controller
        if user == nil && topic == nil && post == nil {
            
            if let theUser = (navigationController as? NavigationController)?.user {
                self.user = theUser
            }
            if let theTopic = (navigationController as? NavigationController)?.topic {
                fetchUserFromTopic(theTopic)
            }
            else if let thePost = (navigationController as? NavigationController)?.post {
                fetchUserFromPost(thePost)
            }
        }
        
        startObservations()
    }

    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        endObservations()
    }
    
    
    
    //MARK: - Display
    
    enum ExitMethod {
        case Back, Dismiss
    }
    
    var exitMethod = ExitMethod.Dismiss {
        
        didSet {
            
            func showDoneButton() {
                
                let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "handleDoneAction:")
                navigationItem.leftBarButtonItem = doneButton
            }
            
            func showBackButton() {
                
                let button = UIButton(frame: CGRectMake(0, 0, 80, 32))
                button.contentEdgeInsets = UIEdgeInsetsMake(4, 0, 4, 0)
                button.contentHorizontalAlignment = .Left
                let backImage = UIImage(named: "halfArrowLeft")
                button.setImage(backImage, forState: UIControlState.Normal)
                
                let title = presentingViewController?.title
                button.setTitle(title, forState: UIControlState.Normal)
                button.setTitleColor(UIColor.tint(), forState: UIControlState.Normal)
                button.addTarget(self, action: "handleDoneAction:", forControlEvents: UIControlEvents.TouchUpInside)
                
                let backButton = UIBarButtonItem(customView: button)
                navigationItem.leftBarButtonItem = backButton
            }
            
            if exitMethod == .Back {
                showBackButton()
            }
            else if exitMethod == .Dismiss {
                showDoneButton()
            }
        }
    }

    
    
    //MARK: - Data

    private var topic: Topic?
    func fetchUserFromTopic(topic: Topic) {
        
        voidData()
        self.topic = topic
        navigationItem.title = topic.authorName
        fetchAndPresentUserInfo()
    }
    
    
    private var post: Post?
    func fetchUserFromPost(post: Post) {
        
        voidData()
        self.post = post
        navigationItem.title = post.authorName
        fetchAndPresentUserInfo()
    }
    
    
    var user: User? {
        
        didSet {
            
            dispatch_async(dispatch_get_main_queue()) {
                self.displayedData = .AuthoredTopics
                self.updateCurrentlyDisplayedData()
            }
        }
    }
    
    
    private func displayingCurrentUser() -> Bool {
        
        if let user = user {
            return user.isEqual(currentUser())
        }
        
        if let topic = topic {
            return topic.authorHandle == currentUser().handle!
        }
        
        if let post = post {
            return post.authorHandle == currentUser().handle!
        }
        
        return false
    }
    
    
    private var fetchingUserInformation = false
    
    private func fetchAndPresentUserInfo() {
        
        if fetchingUserInformation {
            return
        }
        
        fetchingUserInformation = true
        
        if displayingCurrentUser() {
            
            let updateOperation = UpdateUserOperation() { (success, error) in
             
                if success {
                    self.user = currentUser()
                }
                else if error != nil {
                    self.presentOKAlertWithError(error!)
                }
                
                self.fetchingUserInformation = false
            }
            
            FetchQueue.sharedInstance.addOperation(updateOperation)
        }
        else {
            
            let authorHandle: String = {
                
                if let topic = topic {
                    return topic.authorHandle!
                }
                else if let post = post {
                    return post.authorHandle!
                }
                
                assert(false)
                return ""
            }()
            
            let fetchOperation = FetchUserByHandleOperation(handle: authorHandle, caseInsensitive: false) { (fetchResults, error) in
                
                if let user = fetchResults?.first as? User {
                    self.user = user
                }
                else if error != nil {
                    self.presentOKAlertWithError(error!)
                }
                self.fetchingUserInformation = false
            }
            
            FetchQueue.sharedInstance.addOperation(fetchOperation)
        }
    }
    
    
    private enum DisplayedData {
        case None, AuthoredTopics, AuthoredPosts, Following, Followers
    }
    
    
    private var displayedData = DisplayedData.None {
        
        didSet {
            
            switch displayedData {
                
            case .AuthoredTopics:
                
                if fetchStatus_AuthoredTopics == .DidFetch {
                    updateDataSection()
                }
                else if fetchStatus_AuthoredTopics == .NotFetched {
                    fetchAuthoredTopics()
                }
                
            case .AuthoredPosts:
                
                if fetchStatus_AuthoredPosts == .DidFetch {
                    updateDataSection()
                }
                else if fetchStatus_AuthoredPosts == .NotFetched {
                    fetchAuthoredPosts()
                }
                
            case .Following:
                
                if fetchStatus_followingOthersRelationships == .DidFetch {
                    updateDataSection()
                }
                else if fetchStatus_followingOthersRelationships == .NotFetched {
                    fetchFollowingOthersRelationships()
                }
                
            case .Followers:
                
                if fetchStatus_followingMeRelationships == .DidFetch {
                    updateDataSection()
                }
                else if fetchStatus_followingMeRelationships == .NotFetched {
                    fetchUsersFollowingMeRelationships()
                }
                
            case .None:
                updateDataSection()
            }
        }
    }
    
    
    private var authoredTopics = [Topic]()
    private var authoredPosts = [Post]()
    private var followingOthersRelationships = [Follow]()
    private var followingMeRelationships = [Follow]()

    private enum FetchStatus {
        case NotFetched, Fetching, DidFetch
    }
    
    private var fetchStatus_AuthoredTopics = FetchStatus.NotFetched
    private var fetchStatus_AuthoredPosts = FetchStatus.NotFetched
    private var fetchStatus_followingOthersRelationships = FetchStatus.NotFetched
    private var fetchStatus_followingMeRelationships = FetchStatus.NotFetched
    
    
    private func voidData() {
        
        authoredTopics.removeAll()
        authoredPosts.removeAll()
        followingOthersRelationships.removeAll()
        followingMeRelationships.removeAll()
        
        fetchStatus_AuthoredTopics = FetchStatus.NotFetched
        fetchStatus_AuthoredPosts = FetchStatus.NotFetched
        fetchStatus_followingOthersRelationships = FetchStatus.NotFetched
        fetchStatus_followingMeRelationships = FetchStatus.NotFetched
        
        displayedData = .None
    }
    
    
    var authoredTopicsFetchOffset = 0
    private func fetchAuthoredTopics() {
        
        if fetchStatus_AuthoredTopics == .Fetching {
            return
        }
        
        guard let user = user else {
            return
        }
        
        fetchStatus_AuthoredTopics = .Fetching
        updateDataSection()
        
        let theQuery: PFQuery = {
            
            let query = Topic.query()!
            query.skip = authoredTopicsFetchOffset
            query.orderByDescending(DataKeys.CreatedAt)
            
            if user.isEqual(currentUser()) {
                query.fromPinWithName(CacheManager.PinNames.UserTopics)
            }
            else {
                query.whereKey(DataKeys.Author, equalTo: user)
            }
            
            return query
        }()
        
        
        theQuery.findObjectsInBackgroundWithBlock { (fetchedObjects, error) -> Void in
            
            self.fetchStatus_AuthoredTopics = .DidFetch
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let topics = fetchedObjects as? [Topic] {
                    self.authoredTopics = topics
                    self.updateDataSection()
                }
                
                if let error = error {
                    self.presentOKAlertWithError(error)
                }
            }
        }
    }
    
    
    private var authoredPostsFetchOffset = 0
    private func fetchAuthoredPosts() {
        
        if fetchStatus_AuthoredPosts == .Fetching {
            return
        }
        
        guard let user = user else {
            return
        }
        
        fetchStatus_AuthoredPosts = .Fetching
        updateDataSection()
        
        let theQuery: PFQuery = {
            
            let query = Post.query()!
            query.skip = authoredPostsFetchOffset
            query.orderByDescending(DataKeys.CreatedAt)
            
            if user.isEqual(currentUser()) {
                query.fromPinWithName(CacheManager.PinNames.UserPosts)
            }
            else {
                query.whereKey(DataKeys.Author, equalTo: user)
            }
            
            return query
        }()
        
        
        theQuery.findObjectsInBackgroundWithBlock { (fetchedObjects, error) -> Void in
            
            self.fetchStatus_AuthoredPosts = .DidFetch
            
            dispatch_async(dispatch_get_main_queue()) {
                
                if let posts = fetchedObjects as? [Post] {
                    self.authoredPosts = posts
                    self.updateDataSection()
                }
                
                if let error = error {
                    self.presentOKAlertWithError(error)
                }
            }
        }
    }
    
    
    private var followingOthersFetchOffset = 0
    private func fetchFollowingOthersRelationships() {

        if fetchStatus_followingOthersRelationships == .Fetching {
            return
        }
        
        fetchStatus_followingOthersRelationships = .Fetching
        updateDataSection()
        
        let theQuery: PFQuery = {
            
            let query = Follow.query()!
            query.skip = followingOthersFetchOffset
            query.orderByDescending(DataKeys.CreatedAt)
            query.whereKey(DataKeys.Follower, equalTo: user!)
            return query
        }()
        
        theQuery.findObjectsInBackgroundWithBlock { (fetchedObjects, error) -> Void in
            
            self.fetchStatus_followingOthersRelationships = .DidFetch

            dispatch_async(dispatch_get_main_queue()) {
                
                if let followedUsers = fetchedObjects as? [Follow] {
                    self.followingOthersRelationships = followedUsers
                    self.updateDataSection()
                }
                else if let error = error {
                    self.presentOKAlertWithError(error)
                }
            }
            
        }
    }
    
    
    private var followingMeFetchOffset = 0
    private func fetchUsersFollowingMeRelationships() {
        
        if fetchStatus_followingMeRelationships == .Fetching {
            return
        }
        
        fetchStatus_followingMeRelationships = .Fetching
        updateDataSection()
        
        let theQuery: PFQuery = {
            
            let query = Follow.query()!
            query.skip = followingMeFetchOffset
            query.orderByDescending(DataKeys.CreatedAt)
            query.whereKey(DataKeys.Followee, equalTo: currentUser())
            return query
        }()
        
        theQuery.findObjectsInBackgroundWithBlock({ (fetchResults, error) -> Void in
            
            self.fetchStatus_followingMeRelationships = .DidFetch
            if let followers = fetchResults as? [Follow] {
                
                self.followingMeRelationships = followers
                self.updateDataSection()
            }
            else if let error = error {
                self.presentOKAlertWithError(error)
            }
        })
    }
    
    
    func updateCurrentlyDisplayedData() {
        
        updateUserSection()
        
        switch displayedData {
            
        case .AuthoredTopics:
            fetchAuthoredTopics()
            
        case .AuthoredPosts:
            fetchAuthoredPosts()
            
        case .Following:
            fetchFollowingOthersRelationships()
            
        case .Followers:
            fetchUsersFollowingMeRelationships()
            
        default:
            ()
        }
        
    }

    

    //MARK: - Actions
    
    @IBAction func handleDoneAction(sender: AnyObject) {
        
        if exitMethod == .Back {
            navigationController?.popViewControllerAnimated(true)
        }
        else if exitMethod == .Dismiss {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }

    

    //MARK: - TableView
    
    private let userDetailCellViewNibName = "UserDetailTableViewCell"
    private let userDetailCellViewIdentifer = "userDetail"
    private let userDetailCellViewHeight = CGFloat(250) 
    
    private let followStatsCellViewNibName = "FollowStatsTableViewCell"
    private let followStatsCellViewIdentifer = "followStatsCell"
    private let followStatsCellViewHeight = CGFloat(44)
    
    private let topicCellViewNibName = "TopicMasterTableViewCell"
    private let topicCellViewIdentifier = "topicMaster"
    private let topicCellViewHeight = CGFloat(96)
    
    private let topicWithImageCellViewNibName = "TopicWithImageMasterTableViewCell"
    private let topicWithImageCellViewIdentifier = "topicImageMaster"
    private let topicWithImageCellViewHeight = CGFloat(117)
    
    private let postCellNibName = "PostDetailTableViewCell"
    private let postCellIdentifier = "postCell"
    private let postCellHeight = CGFloat(125)
    
    private let loadingDataCellViewNibName = "LoadingTableViewCell"
    private let loadingDataCellViewIdentifier = "loadingCell"
    private let loadingDataCellViewHeight = CGFloat(44)
    
    private let displayOptionsCellViewNibName = "DataDisplayOptionsTableViewCell"
    private let displayOptionsCellViewIdentifier = "dataOptionsCell"
    private let displayOptionsCellViewHeight = CGFloat(44)
    
    private let followCellViewNibName = "FollowTableViewCell"
    private let followCellViewIdentifier = "followCell"
    private let followCellViewHeight = CGFloat(69)
    
    private func setupTableView() {
        
        refreshControl = {
            
            let rc = UIRefreshControl()
            rc.tintColor = UIColor.blackColor().colorWithAlphaComponent(0.9)
            rc.addTarget(self, action: "updateCurrentlyDisplayedData", forControlEvents: UIControlEvents.ValueChanged)
            return rc
            }()
        
        let nib = UINib(nibName: userDetailCellViewNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: userDetailCellViewIdentifer)
        
        let nib1 = UINib(nibName: followStatsCellViewNibName, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: followStatsCellViewIdentifer)
        
        let nib3 = UINib(nibName: topicCellViewNibName, bundle: nil)
        tableView.registerNib(nib3, forCellReuseIdentifier: topicCellViewIdentifier)
        
        let nib4 = UINib(nibName: topicWithImageCellViewNibName, bundle: nil)
        tableView.registerNib(nib4, forCellReuseIdentifier: topicWithImageCellViewIdentifier)
        
        let nib5 = UINib(nibName: loadingDataCellViewNibName, bundle: nil)
        tableView.registerNib(nib5, forCellReuseIdentifier: loadingDataCellViewIdentifier)
        
        let nib6 = UINib(nibName: displayOptionsCellViewNibName, bundle: nil)
        tableView.registerNib(nib6, forCellReuseIdentifier: displayOptionsCellViewIdentifier)
        
        let nib7 = UINib(nibName: postCellNibName, bundle: nil)
        tableView.registerNib(nib7, forCellReuseIdentifier: postCellIdentifier)
        
        let nib8 = UINib(nibName: followCellViewNibName, bundle: nil)
        tableView.registerNib(nib8, forCellReuseIdentifier: followCellViewIdentifier)
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        func numberOfDataRows() -> Int {
            
            var number = 0
            
            switch displayedData {
                
            case .AuthoredTopics:
                number = fetchStatus_AuthoredTopics == .Fetching ? 1 : authoredTopics.count
                
            case .AuthoredPosts:
                number = fetchStatus_AuthoredPosts == .Fetching ? 1 : authoredPosts.count
                
            case .Following:
                number = fetchStatus_followingOthersRelationships == .Fetching ? 1 : followingOthersRelationships.count
                
            case .Followers:
                number = fetchStatus_followingMeRelationships == .Fetching ? 1 : followingMeRelationships.count
                
            case .None:
                number = 0
            }
            
            return number
        }
        
        var numberOfRows = 0
        switch section {
            
        case 0:
            numberOfRows = topic == nil && user == nil && post == nil ? 0 : 2
            
        case 1:
            numberOfRows = numberOfDataRows()
            
        default:
            assert(false)
        }
        
        return numberOfRows
    }

    
    private enum TableCellType {
        
        case UserDetail, Loading, FollowStats, DisplayOptions, TopicNoImage, TopicWithImage, Post, Followee, Follower
    }
    
    
    private func cellTypeForIndexPath(indexPath: NSIndexPath) -> TableCellType {
        
        var type: TableCellType?
        
        switch indexPath.section {
            
        case 0:
            
            if indexPath.row == 0 {
                type = .UserDetail
            }
            else if indexPath.row == 1 {
                
                if fetchingUserInformation {
                    type = .Loading
                }
                else if displayingCurrentUser() {
                    type = .DisplayOptions
                }
                else {
                    type = .FollowStats
                }
             }
            
        case 1:
            
            switch displayedData {
                
            case .AuthoredTopics:
                
                if fetchStatus_AuthoredTopics == .Fetching {
                    type = .Loading
                }
                else {
                    
                    let theTopic = authoredTopics[indexPath.row]
                    if theTopic.imageFile != nil {
                        type = .TopicWithImage
                    }
                    else {
                        type = .TopicNoImage
                    }
                }
                
            case .AuthoredPosts:
                
                if fetchStatus_AuthoredPosts == .Fetching {
                    type = .Loading
                }
                else {
                    type = .Post
                }
                
            case .Following:
                
                if fetchStatus_followingOthersRelationships == .Fetching {
                    type = .Loading
                }
                else {
                    type = .Followee
                }
                
            case .Followers:
                
                if fetchStatus_followingMeRelationships == .Fetching {
                    type = .Loading
                }
                else {
                    type = .Follower
                }
                
            case .None:
                assert(false)
            }
            
        default:
            assert(false)
        }
        
        return type!
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.1
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0.1
        }
        
        return 36
    }
    
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if section == 0 {
            return ""
        }
        
        guard let user = user else {
            return "Author"
        }
        
        let title: String
        switch displayedData {
            
        case .AuthoredTopics:
            
            let number = user.numberOfTopics
            if number == 1 {
                title = "\(number) Authored Topic"
            }
            else {
                title = "\(number) Authored Topics"
            }
            
        case .AuthoredPosts:
            
            let number = user.numberOfPosts
            if number == 1 {
                title = "\(number) Authored Post"
            }
            else {
                title = "\(number) Authored Posts"
            }
            
        case .Followers:
            
            let number = user.followersCount
            if number == 1 {
                title = "\(number) Follower"
            }
            else {
                title = "\(number) Followers"
            }
            
        case .Following:
            
            let number = user.followingCount
            if number == 1 {
                title = "Following \(number) User"
            }
            else {
                title = "Following \(number) Users"
            }
            
        default:
            title = ""
        }
        
        return title
    }
    
    
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height: CGFloat = 0
        
        switch cellTypeForIndexPath(indexPath) {
            
        case .UserDetail:
            height = userDetailCellViewHeight
            
        case .Loading:
            height = loadingDataCellViewHeight
            
        case .FollowStats:
            height = followStatsCellViewHeight
            
        case .DisplayOptions:
            height = displayOptionsCellViewHeight
            
        case .TopicNoImage:
            height = topicCellViewHeight
            
        case .TopicWithImage:
            height = topicWithImageCellViewHeight
            
        case .Post:
            height = postCellHeight
            
        case .Followee:
            height = followCellViewHeight
            
        case .Follower:
            height = followCellViewHeight
        }
        
        return height
    }
    

    var displayOptionsTableViewCell: DataDisplayOptionsTableViewCell?
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        func initializeUserDetailCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(userDetailCellViewIdentifer) as! UserDetailTableViewCell
            
            if user != nil {
                cell.displayedUser = user
            }
            else if let topic = topic {
                cell.fetchUserFromTopic(topic)
            }
            else if let post = post {
                cell.fetchUserFromPost(post)
            }
            
            return cell
        }
        
        func initializeFollowStatsCell(user: User) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(followStatsCellViewIdentifer) as! FollowStatsTableViewCell
            cell.displayedUser = user
            return cell
        }
        
        func initializeLoadingDataCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(loadingDataCellViewIdentifier) as! LoadingTableViewCell
            return cell
        }
        
        func initializeDisplayOptionsCell() -> UITableViewCell {
            
            guard displayOptionsTableViewCell == nil else {
                return displayOptionsTableViewCell!
            }
            
            let cell = tableView.dequeueReusableCellWithIdentifier(displayOptionsCellViewIdentifier) as! DataDisplayOptionsTableViewCell
            
            switch displayedData {
                
            case .AuthoredTopics:
                cell.segmentedControl.selectedSegmentIndex = 0
                
            case .AuthoredPosts:
                cell.segmentedControl.selectedSegmentIndex = 1
                
            case .Following:
                cell.segmentedControl.selectedSegmentIndex = 2
                
            case .Followers:
                cell.segmentedControl.selectedSegmentIndex = 3
                
            case .None:
                cell.segmentedControl.selectedSegmentIndex = 0                
            }
            
            displayOptionsTableViewCell = cell
            return cell
        }
        
        func initializeTopicCell(topic: Topic) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(topicCellViewIdentifier) as! TopicMasterTableViewCell
            cell.displayedTopic = topic
            return cell
        }
        
        func initializeTopicWithImageCell(topic: Topic) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(topicWithImageCellViewIdentifier) as! TopicMasterTableViewCell
            cell.displayedTopic = topic
            return cell
        }
        
        func initializePostCell(post: Post) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(postCellIdentifier) as! PostDetailTableViewCell
            cell.displayedPost = post
            return cell
        }
        
        func initializeFolloweeCell(followee: Follow) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(followCellViewIdentifier) as! FollowTableViewCell
            cell.displayFolloweeForRelationship(followee)
            return cell
        }
        
        func initializeFollowerCell(follower: Follow) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(followCellViewIdentifier) as! FollowTableViewCell
            cell.displayFollowerForRelationship(follower)
            return cell
        }
        
        
        var cell: UITableViewCell
        
        switch cellTypeForIndexPath(indexPath) {
            
        case .UserDetail:
            cell = initializeUserDetailCell()
            
        case .Loading:
            cell = initializeLoadingDataCell()
            
        case .FollowStats:
            cell = initializeFollowStatsCell(user!)
            
        case .DisplayOptions:
            cell = initializeDisplayOptionsCell()
            
        case .TopicNoImage:
            cell = initializeTopicCell(authoredTopics[indexPath.row])
            
        case .TopicWithImage:
            cell = initializeTopicWithImageCell(authoredTopics[indexPath.row])
            
        case .Post:
            cell = initializePostCell(authoredPosts[indexPath.row])
            
        case .Followee:
            cell = initializeFolloweeCell(followingOthersRelationships[indexPath.row])
            
        case .Follower:
            cell = initializeFollowerCell(followingMeRelationships[indexPath.row])
        }
        
        return cell
    }

    
    private func updateUserSection() {
        
        navigationItem.title = self.user?.name

        tableView.beginUpdates()
        tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
        tableView.endUpdates()
    }
    
    
    private func updateDataSection() {
        
        switch displayedData {
            
        case .AuthoredTopics:
            
            if fetchStatus_AuthoredTopics == .Fetching || authoredTopics.count == 0 {
                tableView.separatorColor = UIColor.background()
            }
            else {
                tableView.separatorColor = UIColor.separator()
            }
            
        case .AuthoredPosts:
            
            if fetchStatus_AuthoredPosts == .Fetching || authoredPosts.count == 0 {
                tableView.separatorColor = UIColor.background()
            }
            else {
                tableView.separatorColor = UIColor.separator()
            }
            
        case .Following:
            
            if fetchStatus_followingOthersRelationships == .Fetching || followingOthersRelationships.count == 0 {
                tableView.separatorColor = UIColor.background()
            }
            else {
                tableView.separatorColor = UIColor.separator()
            }
            
        case .Followers:
            
            if fetchStatus_followingMeRelationships == .Fetching || followingMeRelationships.count == 0 {
                tableView.separatorColor = UIColor.background()
            }
            else {
                tableView.separatorColor = UIColor.separator()
            }
            
        default:
            tableView.separatorColor = UIColor.separator()
        }
        
        tableView.beginUpdates()
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
        tableView.endUpdates()
        
        refreshControl?.endRefreshing()
    }
    
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        return displayedData == .Following
    }
    

    override func tableView(tableView: UITableView, willBeginEditingRowAtIndexPath indexPath: NSIndexPath) {
        
        displayOptionsTableViewCell?.selectionEnabled = false
    }
    
    
    override func tableView(tableView: UITableView, didEndEditingRowAtIndexPath indexPath: NSIndexPath) {
        displayOptionsTableViewCell?.selectionEnabled = true
    }
    
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        guard editingStyle == .Delete else {
            return
        }
        
        let follow = followingOthersRelationships[indexPath.row]
        follow.deleteInBackground()
        self.followingOthersRelationships.removeAtIndex(indexPath.row)
        dispatch_async(dispatch_get_main_queue()) {
            
            self.tableView.beginUpdates()
            self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            self.tableView.endUpdates()
        }
    }
    
    
    override func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        
        if displayedData == .AuthoredTopics {
            return indexPath.section == 1
        }
        
        return false
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        tableView.deselectRowAtIndexPath(indexPath, animated: false)
        
        if displayedData == .AuthoredTopics {
            
            let selection = authoredTopics[indexPath.row]
            presentTopicDetailViewController(withTopic: selection)
        }
    }
    
    
    
    //MARK: - Observations and Delegate Methods
    
    func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSettingsAction:", name: UserDetailTableViewCell.settingsButtonTapNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleExportAction:", name: UserDetailTableViewCell.exportButtonTapNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDisplayOptionDidChange:", name: DataDisplayOptionsTableViewCell.selectionDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleUserUpdateNotification:", name: UpdateUserOperation.Notifications.DidUpdate, object: nil)
    }
    
    
    func endObservations() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func handleSettingsAction(notification: NSNotification) {
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("settingsViewController")
        
        presentViewController(viewController, animated: true, completion: nil)
    }
    
    
    func handleExportAction(notification: NSNotification) {
        
        if let userinfo = notification.userInfo {
            
            if let user = userinfo[UserDetailTableViewCell.userKey] as? User {
                
                if let navController = navigationController as? NavigationController {
                    navController.presentExportViewController(withUser: user)
                }
            }
        }
    }
    
    
    func handleDisplayOptionDidChange(notification: NSNotification) {
        
        let sender = notification.object as! DataDisplayOptionsTableViewCell
        
        switch sender.selection {
            
        case .AuthoredTopics:
            displayedData = .AuthoredTopics
            
        case .AuthoredPosts:
            displayedData = .AuthoredPosts
            
        case .Following:
            displayedData = .Following
            
        case .Followers:
            displayedData = .Followers
        }
    }
    
    
    func handleUserUpdateNotification(notification: NSNotification) {
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.tableView.beginUpdates()
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
            self.tableView.endUpdates()
        }
    }
}
