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
        view.backgroundColor = UIColor.whiteColor()
        setupTableView()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        startObservations()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        endObservations()
    }
    
    
    
    //MARK: - Display
    
    enum ExitMethod {
        case Back, Dismiss
    }
    
    var exitMethod = ExitMethod.Back {
        
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
    
    
    var user: User? {
        
        didSet {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.navigationItem.title = self.user?.name
                
                self.tableView.beginUpdates()
                self.tableView.reloadSections(NSIndexSet(index: 0), withRowAnimation: .None)
                self.tableView.endUpdates()
                
                self.displayedData = .AuthoredTopics
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
        
        return false
    }
    
    
    private var fetchingUserInformation = false
    private func fetchAndPresentUserInfo() {
        
        if fetchingUserInformation {
            return
        }
        
        guard let topic = topic else {
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
            
            let fetchOperation = FetchUserByHandleOperation(handle: topic.authorHandle!, caseInsensitive: false) { (user, error) in
                
                if user != nil {
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
                
                if fetchStatus_UsersBeingFollowed == .DidFetch {
                    updateDataSection()
                }
                else if fetchStatus_UsersBeingFollowed == .NotFetched {
                    fetchUsersBeingFollowed()
                }
                
            case .Followers:
                
                if fetchStatus_UsersFollowingMe == .DidFetch {
                    updateDataSection()
                }
                else if fetchStatus_UsersFollowingMe == .NotFetched {
                    fetchUsersUsersFollowingMe()
                }
                
            case .None:
                updateDataSection()
            }
        }
    }
    
    
    private var authoredTopics = [Topic]()
    private var authoredPosts = [Post]()
    private var usersBeingFollowed = [User]()
    private var usersFollowingMe = [User]()

    private enum FetchStatus {
        case NotFetched, Fetching, DidFetch
    }
    
    private var fetchStatus_AuthoredTopics = FetchStatus.NotFetched
    private var fetchStatus_AuthoredPosts = FetchStatus.NotFetched
    private var fetchStatus_UsersBeingFollowed = FetchStatus.NotFetched
    private var fetchStatus_UsersFollowingMe = FetchStatus.NotFetched
    
    
    private func voidData() {
        
        authoredTopics.removeAll()
        authoredPosts.removeAll()
        usersBeingFollowed.removeAll()
        usersFollowingMe.removeAll()
        
        fetchStatus_AuthoredTopics = FetchStatus.NotFetched
        fetchStatus_AuthoredPosts = FetchStatus.NotFetched
        fetchStatus_UsersBeingFollowed = FetchStatus.NotFetched
        fetchStatus_UsersFollowingMe = FetchStatus.NotFetched
        
        displayedData = .None
    }
    
    private func fetchAuthoredTopics() {
        
//        displayStatus(.Fetching)
        updateDataSection()
        
        if fetchStatus_AuthoredTopics == .Fetching {
            return
        }
        
        
        fetchStatus_AuthoredTopics = .Fetching
        
        let fetchTopicsOperation = FetchAuthoredTopicsOperation(user: user!)
        
        fetchTopicsOperation.addCompletionBlock({
            
            self.fetchStatus_AuthoredTopics = .DidFetch

            self.authoredTopics = cachedTopicsAuthoredByUser(self.user!)
            dispatch_async(dispatch_get_main_queue()) {
                
                self.updateDataSection()
//                self.hideRefreshControl()
//                self.displayStatus()
            }
        })
        
        FetchQueue.sharedInstance.addOperation(fetchTopicsOperation)
    }
    
    
    private func fetchAuthoredPosts() {
        
        updateDataSection()
    }
    
    
    private func fetchUsersBeingFollowed() {
        
        updateDataSection()
    }
    
    
    private func fetchUsersUsersFollowingMe() {
        
        updateDataSection()
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
    
    private let userFollowCellViewNibName = "UserFollowTableViewCell"
    private let userFollowCellViewIdentifer = "followCell"
    private let userFollowCellViewHeight = CGFloat(44)
    
    private let simpleTopicCellViewNibName = "TopicMasterTableViewCellOne"
    private let simpleTopicCellViewIdentifier = "topicCellOne"
    private let simpleTopicCellViewHeight = CGFloat(72)
    
    private let topicWithCommentCellViewNibName = "TopicMasterTableViewCellTwo"
    private let topicWithCommentCellViewIdentifier = "topicCellTwo"
    private let topicWithCommentCellViewHeight = CGFloat(96)
    
    private let topicWithImageCellViewNibName = "TopicMasterTableViewCellThree"
    private let topicWithImageCellViewIdentifier = "topicCellThree"
    private let topicWithImageCellViewHeight = CGFloat(117)
    
    private let loadingDataCellViewNibName = "LoadingTableViewCell"
    private let loadingDataCellViewIdentifier = "loadingCell"
    private let loadingDataCellViewHeight = CGFloat(44)
    
    private let displayOptionsCellViewNibName = "DataDisplayOptionsTableViewCell"
    private let displayOptionsCellViewIdentifier = "dataOptionsCell"
    private let displayOptionsCellViewHeight = CGFloat(44)
    
    private let headerViewHeight = CGFloat(0.1)
    private let footerViewHeight = CGFloat(1.0)

    
    private func setupTableView() {
        
//        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.background()
        tableView.showsHorizontalScrollIndicator = false
        
        let nib = UINib(nibName: userDetailCellViewNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: userDetailCellViewIdentifer)
        
        let nib1 = UINib(nibName: userFollowCellViewNibName, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: userFollowCellViewIdentifer)
        
        let nib2 = UINib(nibName: simpleTopicCellViewNibName, bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: simpleTopicCellViewIdentifier)
        
        let nib3 = UINib(nibName: topicWithCommentCellViewNibName, bundle: nil)
        tableView.registerNib(nib3, forCellReuseIdentifier: topicWithCommentCellViewIdentifier)
        
        let nib4 = UINib(nibName: topicWithImageCellViewNibName, bundle: nil)
        tableView.registerNib(nib4, forCellReuseIdentifier: topicWithImageCellViewIdentifier)
        
        let nib5 = UINib(nibName: loadingDataCellViewNibName, bundle: nil)
        tableView.registerNib(nib5, forCellReuseIdentifier: loadingDataCellViewIdentifier)
        
        let nib6 = UINib(nibName: displayOptionsCellViewNibName, bundle: nil)
        tableView.registerNib(nib6, forCellReuseIdentifier: displayOptionsCellViewIdentifier)
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 2
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        func numberOfDataRows() -> Int {
            
            var number = 0
            
            switch displayedData {
                
            case .AuthoredTopics:
                number = authoredTopics.count
                
            case .AuthoredPosts:
                number = authoredPosts.count
                
            case .Following:
                number = usersBeingFollowed.count
                
            case .Followers:
                number = usersFollowingMe.count
                
            case .None:
                number = 0
            }
            
            return number
        }
        
        var numberOfRows = 0
        switch section {
            
        case 0:
            numberOfRows = 2
            
        case 1:
            numberOfRows = numberOfDataRows()
            
        default:
            assert(false)
        }
        
        return numberOfRows
    }

    
    private enum TableCellType {
        
        case UserDetail, Loading, FollowStats, DisplayOptions, TopicSimple, TopicNoImage, TopicWithImage, Post, FolloweeOrFollower
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
                let theTopic = authoredTopics[indexPath.row]
                if theTopic.hasImage() {
                    type = .TopicWithImage
                }
                else {
                    if theTopic.comment == nil {
                        type = .TopicSimple
                    }
                    else {
                        type = .TopicNoImage
                    }
                }
                
            case .AuthoredPosts:
                type = .Post
                
            case .Following:
                type = .FolloweeOrFollower
                
            case .Followers:
                type = .FolloweeOrFollower
                
            case .None:
                assert(false)
            }
            
        default:
            assert(false)
        }
        
        return type!
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return footerViewHeight
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
        
        let title: String
        switch displayedData {
            
        case .AuthoredTopics:
            title = "\(user!.numberOfTopics) Authored Topics"
            
        case .AuthoredPosts:
            title = "\(user!.numberOfPosts) Authored Posts"
            
        case .Followers:
            title = "\(user!.followersCount) Followers"
            
        case .Following:
            title = "Following \(user!.followingCount) Users"
            
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
            height = userFollowCellViewHeight
            
        case .DisplayOptions:
            height = displayOptionsCellViewHeight
            
        case .TopicSimple:
            height = simpleTopicCellViewHeight
            
        case .TopicNoImage:
            height = topicWithCommentCellViewHeight
            
        case .TopicWithImage:
            height = topicWithImageCellViewHeight
            
        case .Post:
            height = 0
            
        case .FolloweeOrFollower:
            height = 0
        }
        
        return height
    }
    

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        func initializeUserDetailCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(userDetailCellViewIdentifer) as! UserDetailTableViewCell
            
            if user == nil {
                cell.fetchUserFromTopic(topic!)
            }
            else {
                cell.displayedUser = user
            }
            return cell
        }
        
        func initializeFollowStatsCell(user: User) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(userFollowCellViewIdentifer) as! UserFollowTableViewCell
            cell.displayedUser = user
            return cell
        }
        
        func initializeLoadingDataCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(loadingDataCellViewIdentifier) as! LoadingTableViewCell
            return cell
        }
        
        func initializeDisplayOptionsCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(displayOptionsCellViewIdentifier) as! DataDisplayOptionsTableViewCell
            return cell
        }
        
        func initializeSimpleTopicCell(topic: Topic) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(simpleTopicCellViewIdentifier) as! TopicMasterTableViewCell
            cell.displayedTopic = topic
            return cell
        }
        
        func initializeTopicWithCommentCell(topic: Topic) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(topicWithCommentCellViewIdentifier) as! TopicMasterTableViewCell
            cell.displayedTopic = topic
            return cell
        }
        
        func initializeTopicWithImageCell(topic: Topic) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(topicWithImageCellViewIdentifier) as! TopicMasterTableViewCell
            cell.displayedTopic = topic
            return cell
        }
        
        func initializePostCell(post: Post) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(topicWithImageCellViewIdentifier) as! TopicMasterTableViewCell
//            cell.displayedTopic = topic
            return cell
        }
        
        func initializeFolloweeFollowerCell(user: User) -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(userFollowCellViewIdentifer) as! UserFollowTableViewCell
            cell.displayedUser = user
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
            
        case .TopicSimple:
            
            let topic = authoredTopics[indexPath.row]
            cell = initializeSimpleTopicCell(topic)
            
        case .TopicNoImage:
            
            let topic = authoredTopics[indexPath.row]
            cell = initializeTopicWithCommentCell(topic)
            
        case .TopicWithImage:
            
            let topic = authoredTopics[indexPath.row]
            cell = initializeTopicWithImageCell(topic)
            
        case .Post:
            
            let post = authoredPosts[indexPath.row]
            cell = initializePostCell(post)
            
        case .FolloweeOrFollower:
            
            let theUser = displayedData == .Following ? usersBeingFollowed[indexPath.row] : usersFollowingMe[indexPath.row]
            cell = initializeFolloweeFollowerCell(theUser)
        }
        
        return cell
    }

    
    private func updateDataSection() {
        
        tableView.beginUpdates()
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Automatic)
        tableView.endUpdates()
    }
    
    

    
    
    //MARK: - Observations and Delegate Methods
    
    private func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSettingsAction:", name: UserDetailTableViewCell.settingsButtonWasTappedNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDisplayOptionDidChange:", name: DataDisplayOptionsTableViewCell.selectionDidChangeNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleUserUpdateNotification:", name: UpdateUserOperation.Notifications.DidUpdate, object: nil)
    }
    
    
    private func endObservations() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func handleSettingsAction(notification: NSNotification) {
        
        let storyboard = UIStoryboard(name: "Settings", bundle: nil)
        let viewController = storyboard.instantiateViewControllerWithIdentifier("settingsViewController")
        
        presentViewController(viewController, animated: true, completion: nil)
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
