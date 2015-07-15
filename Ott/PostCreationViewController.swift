//
//  PostCreationViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import CoreData

class PostCreationViewController: ViewController, UITableViewDelegate, UITableViewDataSource, PostInputViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var postInputView: PostInputView!
    @IBOutlet weak var postInputViewBottomConstraint: NSLayoutConstraint!
    
    private let segueToTopicDetailIdentifier = "segueToTopicDetail"
    var presentTopicDetailAfterEntry = false
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        postInputView.delegate = self
        postInputView.maximumViewHeight = 200
        
        setupTableView()
        startObservations()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let navController = navigationController as? NavigationController {
            myTopic = navController.topic
        }
        
        navigationItem.rightBarButtonItem?.enabled = false
        refreshDisplay()
    }
    
    
    deinit {
        endObservations()
    }
    
    
    
    //MARK: - Display
    
    private var _shouldRefreshDisplay = false
    func refreshDisplay() {
        
        if isViewLoaded() {
            
            _shouldRefreshDisplay = false
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
        else {
            _shouldRefreshDisplay = true
        }
    }
    
    
    
    //MARK: - Data
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.parentContext = DataManager.sharedInstance.managedObjectContext
        return moc
        }()
    
    
    private var _myTopic: Topic?
    var myTopic: Topic? {
        
        set {
            
            if let t = newValue {
                _myTopic = t.instance(inContext: managedObjectContext) as? Topic
            }
            else {
                _myTopic = nil
            }

            refreshDisplay()
        }
        
        get {
            return _myTopic;
        }
    }
    
    
    private func imageLoaded() -> Bool {
        return myTopic?.image != nil
    }
    
    
    private func saveChanges() {
        
        let myPost = Post.create(inContext: self.managedObjectContext)
        myPost.author = Author.user(inContext: managedObjectContext)
        myPost.rating = postInputView.rating
        myPost.comment = postInputView.comment
        myPost.latitude = LocationManager.sharedInstance.location?.coordinate.latitude
        myPost.longitude = LocationManager.sharedInstance.location?.coordinate.longitude
        myPost.locationName = LocationManager.sharedInstance.locationName

        myTopic?.update(withPost: myPost)
        myTopic?.userDidPostRating = true
        
        let user = Author.user(inContext: managedObjectContext)
        myPost.identifier = user.newContentIdentifier()
        user.update(withPost: myPost)

        managedObjectContext.saveContext()
        DataManager.sharedInstance.upload(myPost)
        managedObjectContext.reset()
    }
    
    
    private func discardChanges() {
        
        managedObjectContext.reset()
    }
    
    
    
    //MARK: - Input and PostInputViewDelegate
    
    func postInputViewPostActionDidOccur() {
        
        saveChanges()
        
        if presentTopicDetailAfterEntry {
            performSegueWithIdentifier(segueToTopicDetailIdentifier, sender: self)
        }
        else {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    
    //MARK: - TableView
    
    private let titleCellViewNibName = "TopicTitleTableViewCell"
    private let titleCellViewIdentifier = "titleCell"
    private let commentCellViewNibName = "TopicCommentTableViewCell"
    private let commentCellViewIdentifier = "commentCell"
    private let imageCellViewNibName = "TopicImageTableViewCell"
    private let imageCellViewIdentifer = "imageCell"
    private let authorCellViewNibName = "TopicAuthorTableViewCell"
    private let authorCellViewIdentifer = "authorCell"
    
    private let titleCellViewHeight = CGFloat(77)
    private let commentCellViewHeight = CGFloat(100)
    private let imageCellViewHeight = CGFloat(275)
    private let authorCellViewHeight = CGFloat(44)
    
    private func setupTableView() {
        
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.separatorStyle = .None
        adjustTableViewInsets(withBottom: postInputView.frame.size.height)
        
        let nib = UINib(nibName: titleCellViewNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: titleCellViewIdentifier)
        
        let nib1 = UINib(nibName: commentCellViewNibName, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: commentCellViewIdentifier)
        
        let nib2 = UINib(nibName: imageCellViewNibName, bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: imageCellViewIdentifer)
        
        let nib3 = UINib(nibName: authorCellViewNibName, bundle: nil)
        tableView.registerNib(nib3, forCellReuseIdentifier: authorCellViewIdentifer)
    }
    
    
    private func adjustTableViewInsets(withBottom bottom: CGFloat) {
        
        var top = CGFloat(64.0)
        if let navHeight = navigationController?.navigationBar.frame.size.height {
            top = navHeight + UIApplication.sharedApplication().statusBarFrame.size.height
        }
        
        tableView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var number: Int?
        
        if section == 0 {
            
            if let myTopic = myTopic {
                
                number = 1
                
                if myTopic.hasComment {
                    number!++
                    if myTopic.hasImage {
                        number!++
                    }
                }
                else if myTopic.hasImage {
                    number!++
                }
            }
        }
        else if section == 1 {
            number = 1
        }
        
        return number!
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height: CGFloat?
        
        if indexPath.section == 0 {
            
            switch indexPath.row {
                
            case 0:
                height = titleCellViewHeight
                
            case 1:
                if myTopic!.hasComment {
                    height = commentCellViewHeight
                }
                else {
                    height = imageCellViewHeight
                }
                
            case 2:
                height = imageCellViewHeight
                
            default:
                height = nil
            }
        }
        else if indexPath.section == 1 {
            height = authorCellViewHeight
        }
        
        return height!
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        func initializeTitleCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(titleCellViewIdentifier) as! TopicTitleTableViewCell
            cell.title = myTopic?.name
            return cell
        }
        
        func initializeCommentCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(commentCellViewIdentifier) as! TopicCommentTableViewCell
            cell.comment = myTopic?.comment
            return cell
        }
        
        func initializeImageCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(imageCellViewIdentifer) as! TopicImageTableViewCell
            cell.topicImageView?.image = myTopic?.image
            return cell
        }
        
        func initializeAuthorCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(authorCellViewIdentifer) as! TopicAuthorTableViewCell
            cell.displayedTopic = myTopic
            return cell
        }
        
        var cell: UITableViewCell?
        
        if indexPath.section == 0 {
            
            switch indexPath.row {
                
            case 0:
                cell = initializeTitleCell()
                
            case 1:
                if myTopic!.hasComment {
                    cell = initializeCommentCell()
                }
                else {
                    cell = initializeImageCell()
                }
                
            case 2:
                cell = initializeImageCell()
                
            default:
                ()
            }
        }
        else if indexPath.section == 1 {
            cell = initializeAuthorCell()
        }
        
        cell!.contentView.backgroundColor = UIColor.whiteColor()
        return cell!
    }
    
    

    //MARK: - Navigation
    
    @IBAction func handleCancelAction(sender: AnyObject) {
       
        postInputView?.resignFirstResponder()
        discardChanges()
        dismissViewControllerAnimated(true) { () -> Void in }
    }
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        super.prepareForSegue(segue, sender: sender)
        
        if segue.identifier == segueToTopicDetailIdentifier {
            let destinationVC = segue.destinationViewController as! TopicDetailViewController
            destinationVC.myTopic = myTopic
        }
    }
    
    
    //MARK: -  Observations {
    
    private var didStartObservations = false
    private func startObservations() {
        
        if didStartObservations {
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        didStartObservations = true
    }
    
    
    private func endObservations() {
        
        if didStartObservations == false {
            return
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        didStartObservations = false
    }
    
    
    func handleKeyboardWillShow(notification: NSNotification) {
        
        if isVisible() == false {
            return
        }
        
        let kbFrameValue = notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        let kbFrame = kbFrameValue.CGRectValue()
        let durationNum = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationNum.doubleValue
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! Int
        
        view.layoutIfNeeded()
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
            self.postInputViewBottomConstraint.constant = kbFrame.size.height
            
            self.view.layoutIfNeeded()
            
            }) { _ -> Void in
                
                let bottom = self.postInputView.frame.size.height + kbFrame.size.height
                self.adjustTableViewInsets(withBottom: bottom)
        }
    }
    
    
    func handleKeyboardWillHide(notification: NSNotification) {
        
        func keyboardIsCoveringContent() -> Bool {
            
            let rectForFooter = tableView.rectForSection(1)
            let contentHeight = tableView.contentSize.height + tableView.contentOffset.y
            return contentHeight < (rectForFooter.origin.y + rectForFooter.size.height)
        }
        
        if isVisible() == false {
            return
        }
        
        let durationNum = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationNum.doubleValue
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! Int
        
        view.layoutIfNeeded()
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
            self.postInputViewBottomConstraint.constant = 0

            if keyboardIsCoveringContent() == false {
                // only animate if not covering content to avoid drawing artifacts
                let bottom = self.postInputView.frame.size.height
                self.adjustTableViewInsets(withBottom: bottom)
            }

            self.view.layoutIfNeeded()
            
            }) { _ -> Void in
        
                if keyboardIsCoveringContent() {
                    
                    let bottom = self.postInputView.frame.size.height
                    self.adjustTableViewInsets(withBottom: bottom)
                }}
    }
}
