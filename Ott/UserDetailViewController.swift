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
        
        self.topic = topic
        navigationItem.title = topic.authorName
        fetchAndPresentUserInfo()
    }
    
    
    var user: User? {
        
        didSet {
            
            dispatch_async(dispatch_get_main_queue()) {
                
                self.navigationItem.title = self.user?.name
                self.tableView.reloadData()
            }
        }
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
    private let userFollowCellViewHeight = CGFloat(38)
    
    private let topicTextCellViewNibName = "TopicMasterTableViewCell"
    private let topicTextCellViewIdentifier = "topicCell"
    private let topicTextCellViewHeight = CGFloat(125)
    
    private let topicImageCellViewNibName = "TopicWithImageMasterTableViewCell"
    private let topicImageCellViewIdentifier = "topicImageCell"
    private let topicImageCellViewHeight = CGFloat(285)
    
    private let loadingDataCellViewNibName = "LoadingTableViewCell"
    private let loadingDataCellViewIdentifier = "loadingCell"
    private let loadingDataCellViewHeight = CGFloat(38)
    
    private let headerViewHeight = CGFloat(0.1)
    private let footerViewHeight = CGFloat(1.0)

    
    private func setupTableView() {
        
        tableView.separatorStyle = .None
        tableView.backgroundColor = UIColor.background()
        tableView.showsHorizontalScrollIndicator = false
        
        let nib = UINib(nibName: userDetailCellViewNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: userDetailCellViewIdentifer)
        
        let nib1 = UINib(nibName: userFollowCellViewNibName, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: userFollowCellViewIdentifer)
        
        let nib2 = UINib(nibName: topicTextCellViewNibName, bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: topicTextCellViewIdentifier)
        
        let nib3 = UINib(nibName: topicImageCellViewNibName, bundle: nil)
        tableView.registerNib(nib3, forCellReuseIdentifier: topicImageCellViewIdentifier)
        
        let nib4 = UINib(nibName: loadingDataCellViewNibName, bundle: nil)
        tableView.registerNib(nib4, forCellReuseIdentifier: loadingDataCellViewIdentifier)
    }

    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        return 1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if section == 0 {
            
            if user == nil {
                
                if fetchingUserInformation {
                    return 2
                }
                return 1
            }
            return 2
        }
        else {
            assert(false)
        }
    }

    
    private enum TableCellType {
        
        case UserDetail, UserFollow, TopicText, TopicImage, Loading
    }
    
    
    private func cellTypeForIndexPath(indexPath: NSIndexPath) -> TableCellType {
        
        var type: TableCellType?
        
        if indexPath.section == 0 {
            
            if indexPath.row == 0 {
                type = .UserDetail
            }
            else if indexPath.row == 1 {
                
                type = fetchingUserInformation ? .Loading : .UserFollow
            }
        }
        else if indexPath.section == 1 {
            type = .TopicText
        }
        else {
            assert(false)
        }
        
        return type!
    }
    
    
    override func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return footerViewHeight
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return headerViewHeight
    }
    
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height: CGFloat = 0
        
        switch cellTypeForIndexPath(indexPath) {
            
        case .UserDetail:
            height = userDetailCellViewHeight
            
        case .UserFollow:
            height = userFollowCellViewHeight
            
        case .TopicText:
            height = topicTextCellViewHeight
            
        case .TopicImage:
            height = topicImageCellViewHeight
            
        case .Loading:
            height = loadingDataCellViewHeight
            
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
        
        func initializeUserFollowCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(userFollowCellViewIdentifer) as! UserFollowTableViewCell
            cell.displayedUser = user
            return cell
        }
        
        func initializeLoadingDataCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(loadingDataCellViewIdentifier) as! LoadingTableViewCell
            return cell
        }
        
        func initializeTopicTextCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(topicTextCellViewIdentifier) as! TopicMasterTableViewCell
//            cell.displayedTopic = user
            return cell
        }
        
        func initializeTopicImageCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(topicImageCellViewIdentifier) as! TopicMasterTableViewCell
//            cell.cell.displayedTopic = user
            return cell
        }
        
        
        var cell: UITableViewCell
        
        switch cellTypeForIndexPath(indexPath) {
            
        case .UserDetail:
            
            cell = initializeUserDetailCell()
            
        case .UserFollow:
            
            cell = initializeUserFollowCell()
            
        case .TopicText:
            
            cell = initializeTopicTextCell()
            
        case .TopicImage:
            
            cell = initializeTopicImageCell()
            
        case .Loading:
            
            cell = initializeLoadingDataCell()
        }
        
        return cell
    }

    
    
    //MARK: - Observations and Delegate Methods
    
    private func startObservations() {
        
    }
    
    
    private func endObservations() {
        
//        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

}
