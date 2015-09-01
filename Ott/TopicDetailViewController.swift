//
//  PostCreationViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import MapKit


class TopicDetailViewController: ViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, PostInputViewDelegate {
    
    @IBOutlet weak var qrCodeDisplayView: UIView!
    @IBOutlet weak var qrCodeImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var postInputView: PostInputView!
    @IBOutlet weak var postInputViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    struct Notifications {
        
        static let DidRefreshTopic = "didRefreshTopic"
        static let TopicKey = "topic"
    }
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        postInputView.delegate = self
        postInputView.maximumViewHeight = 200
        
        var items = toolbar.items
        let statusBarButtonItem = UIBarButtonItem(customView: statusLabel)
        statusBarButtonItem.width = 120
        items?.insert(statusBarButtonItem, atIndex: 2)
        toolbar.setItems(items!, animated: false)
        
        qrCodeDisplayView.hidden = true
        
        setupTableView()
        setupMapView()
        displayType = .List  // affirmatively set in order to setup display
        startObservations()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let navController = navigationController as? NavigationController {
            myTopic = navController.topic
        }
    }
    
    
    deinit {
        endObservations()
    }
    
    
    
    //MARK: - Display
    
    private enum DisplayMode {
        case RequirePostEntry, AllData
    }
    
    
    private var displayMode: DisplayMode? {
        
        didSet {
            _setDisplayMode(displayMode!)
        }
    }
    
    
    private func _setDisplayMode(mode: DisplayMode) {
        
        let animationDuration = 0.25
        
        func showCancelButton() {
            
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "handleCancelAction:")
            navigationItem.leftBarButtonItem = cancelButton
        }
        
        
        func showDoneButton() {
            
            let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "handleDoneAction:")
            navigationItem.leftBarButtonItem = doneButton
        }
        
        
        func showPostInputView() {
            
            func animations() {
                
                self.postInputViewBottomConstraint.constant = 0
                self.toolbarBottomConstraint.constant = -self.toolbar.frame.size.height
                
                let bottom = self.postInputView.frame.size.height
                self.adjustTableViewInsets(withBottom: bottom)
                self.view.layoutIfNeeded()
            }
            
            UIView.animateWithDuration(animationDuration, animations: animations)
        }
        
        
        func showToolbar() {
            
            func animations() {
                
                self.postInputViewBottomConstraint.constant = -self.postInputView.frame.size.height
                self.toolbarBottomConstraint.constant = 0
                
                let bottom = self.toolbar.frame.size.height
                self.adjustTableViewInsets(withBottom: bottom)
                self.view.layoutIfNeeded()
            }
            
            UIView.animateWithDuration(animationDuration, animations: animations)
        }
        
        
        let mapToggleButton = navigationItem.rightBarButtonItem
        
        switch mode {
            
        case .RequirePostEntry:
            
            showCancelButton()
            postInputView.reset()
            showPostInputView()
            mapToggleButton?.enabled = false
            
        case .AllData:
            
            showDoneButton()
            showToolbar()
            mapToggleButton?.enabled = currentUser().didPostToTopic(myTopic!)
        }
    }
    

    private enum DisplayType {
        case Map, List
    }
    
    
    private var displayType: DisplayType = .List {
        
        didSet {
            _setDisplayType(displayType)
        }
    }
    
    
    private func _setDisplayType(type: DisplayType) {
        
        switch type {
            
        case .Map:
            
            mapView.alpha = 0
            mapView.hidden = false
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                self.mapView.alpha = 1.0
            })
            
        case .List:
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                self.mapView.alpha = 0
                }, completion: { (_) -> Void in
                    self.mapView.hidden = true
            })
        }
        
        synchronizeDisplayButton()
    }
    
    
    private func synchronizeDisplayButton() {
        
        let mapImageName = "paperMap"
        let tableImageName = "list"
        
        switch displayType {
            
        case .Map:
            navigationItem.rightBarButtonItem?.image = UIImage(named: tableImageName)
            
        case .List:
            navigationItem.rightBarButtonItem?.image = UIImage(named: mapImageName)
        }
    }
    
    
    lazy var statusLabel: UILabel = {
        
        let label = UILabel(frame: CGRectMake(0, 0, 120, 32))
        label.font = UIFont.systemFontOfSize(13)
        label.textAlignment = .Center
        label.textColor = UIColor.darkGrayColor()
        return label
        }()
    
    
    private enum StatusType {
        case Normal, Fetching, Posting
    }
    
    private func displayStatus(type type: StatusType = .Normal) {
        
        func attributedStatus() -> NSAttributedString {
            
            let boldAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayColor(), NSFontAttributeName: UIFont.boldSystemFontOfSize(13)]
            
            let normalAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor(), NSFontAttributeName: UIFont.systemFontOfSize(13)]
            
            let numberOfPosts = posts.count
            let s1 = NSMutableAttributedString(string: "\(numberOfPosts)", attributes: boldAttributes)
            
            let text = numberOfPosts == 1 ? " post" : " posts"
            let s2 = NSAttributedString(string: text, attributes: normalAttributes)
            s1.appendAttributedString(s2)
            return s1
        }
        
        dispatch_async(dispatch_get_main_queue()) {
            
            switch type {
                
            case .Normal:
                
                self.statusLabel.text = ""
                
            case .Fetching:
                self.statusLabel.text = "Updating..."
                
            case .Posting:
                self.statusLabel.text = "Posting..."
            }
        }
    }
    
    
    
    //MARK: - Data
    
    var myTopic: Topic? {
        
        didSet {
            
            displayMode = currentUser().didPostToTopic(myTopic!) ? .AllData : .RequirePostEntry

            let title = "#" + myTopic!.name!
            self.navigationItem.title = title
            displayType = .List

            if displayMode == .AllData {
                fetchPosts()
            }
        }
    }
    
    
    private var posts = [Post]()
    
    private var _dateOfMostRecentPost: NSDate?
    private func fetchPosts(reloadingTopic reloadTopic: Bool = false) {
        
        displayStatus(type: .Fetching)

        // ADD GUARD FOR REACHABILITY
        
        let onlineFetchOperation = NSBlockOperation(block: { () -> Void in
            
            // update topic as well
            if reloadTopic {
                
               self.myTopic?.fetch()
                dispatch_async(dispatch_get_main_queue()) {
                    
                    let userInfo: [NSObject: AnyObject] = [TopicDetailViewController.Notifications.TopicKey: self.myTopic!]
                    NSNotificationCenter.defaultCenter().postNotificationName(TopicDetailViewController.Notifications.DidRefreshTopic, object: self, userInfo: userInfo)
                }
            }
            
            let query = Post.query()!
            query.orderByDescending(DataKeys.CreatedAt)
            query.whereKey(DataKeys.Topic, equalTo: self.myTopic!)
            if let minDate = self._dateOfMostRecentPost {
                query.whereKey(DataKeys.CreatedAt, greaterThanOrEqualTo: minDate)
            }
            
            var error: NSError?
            let objects = query.findObjects(&error)
            
            self.displayStatus(type: .Normal)
            
            if let fetchedPosts = objects as? [Post] {
                
                if fetchedPosts.count > 0 {
                    
                    self._dateOfMostRecentPost = fetchedPosts.first?.createdAt
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        self.refreshTableView(withUpdatedPosts: fetchedPosts)
                        self.refreshMapView(withUpdatedPosts: fetchedPosts)
                    }
                }
            }
        })
        
        operationQueue().addOperation(onlineFetchOperation)
    }
    
    
    private func saveChanges() {
        
        guard let topicID = self.myTopic!.objectId else {
            
            print("ERROR:  in posting post -> no topic id for topic with name = \(self.myTopic!.name)")
            return
        }
        
        if self.displayMode == .RequirePostEntry {
            currentUser().archivePostedTopicID(topicID)
            self.displayMode = .AllData
        }
        
        displayStatus(type: .Posting)
        
        let myPost = Post.createWithAuthor(currentUser(), topic: myTopic!)
        myPost.rating = postInputView.rating
        if let comment = postInputView.comment {
            myPost.comment = comment
        }
        myPost.location = LocationManager.sharedInstance.location
        myPost.locationName = LocationManager.sharedInstance.locationName
        myPost.saveInBackgroundWithBlock() { (succeeded, error) in
            
            self.displayStatus(type: .Normal)
            
            if succeeded {
                
                self.fetchPosts(reloadingTopic: true) // update data for topic
            }
            else {
                
                dispatch_async(dispatch_get_main_queue()) {
                    
                    if let error = error {
                        (self as UIViewController).presentOKAlertWithError(error)
                    }
                    else {
                        (self as UIViewController).presentOKAlert(title: "Error", message: "An unknown error occurred while trying to post.  Please check your internet connection and try again.", completion: nil)
                        
                    }
                }
            }
        }
    }
    
    
    private func discardChanges() {
        
        // nothing has been created, so don't do anything
    }
    
    
    
    //MARK: - Actions and PostInputViewDelegate
    
    @IBAction func handleToggleViewAction(sender: AnyObject) {
        
        if displayType == .Map {
            displayType = .List
        }
        else {
            displayType = .Map
        }
    }
    
    
    func postInputViewPostActionDidOccur() {
        
        saveChanges()
    }
    
    
    @IBAction func handleEnterEditModeAction(sender: AnyObject) {
        
        displayMode = .RequirePostEntry
    }
    
    
    lazy private var alertViewController: UIAlertController = {
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let printAction = UIAlertAction(title: "Print", style: UIAlertActionStyle.Default, handler: { action in
            
            self.hideCodeView()
        })
        
        let emailAction = UIAlertAction(title: "Email", style: UIAlertActionStyle.Default, handler: { action in
            
            self.hideCodeView()
        })
        
        let photosAction = UIAlertAction(title: "Save to Photos", style: UIAlertActionStyle.Default, handler: { action in
            
            self.hideCodeView()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
            
            self.hideCodeView()
        })
        
        controller.addAction(printAction)
        controller.addAction(emailAction)
        controller.addAction(photosAction)
        controller.addAction(cancelAction)
        
        return controller
        }()
    
    
    private func showCodeViewAndPresentAlert() {
        
        self.qrCodeDisplayView.alpha = 0
        self.qrCodeImageView.alpha = 0
        self.qrCodeDisplayView.hidden = false
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.qrCodeDisplayView.alpha = 1
            self.qrCodeImageView.alpha = 1
            }, completion: { (Bool) -> Void in
                
                self.presentViewController(self.alertViewController, animated: true, completion: nil)
        })
    }
    
    
    private func hideCodeView() {
        
        UIView.animateWithDuration(0.3, animations: { () -> Void in
            
            self.qrCodeDisplayView.alpha = 0
            self.qrCodeImageView.alpha = 0
            }, completion: { (Bool) -> Void in
                
                self.qrCodeDisplayView.hidden = true
        })
    }

    
    @IBAction func handleExportAction(sender: AnyObject) {
        
        qrCodeImageView.image = ScanTransformer.sharedInstance.imageForObject(myTopic!)
        showCodeViewAndPresentAlert()
    }
    
    
    @IBAction func handleCancelAction(sender: AnyObject) {
        
        postInputView?.resignFirstResponder()
        discardChanges()
        
        if currentUser().didPostToTopic(myTopic!) {
            displayMode = .AllData
        }
        else {
            dismissViewControllerAnimated(true) { () -> Void in }
        }
    }
    
    
    @IBAction func handleDoneAction(sender: AnyObject) {
        
        dismissViewControllerAnimated(true) { () -> Void in }
    }
    
    
    
    //MARK: - TableView
    
    enum TableViewSections: Int {
        case Topic = 0
        case Statistics = 1
        case Posts = 2
        
        static func maximumNumberOfSections() -> Int {
            return 3
        }
    }
    
    
    private let textCellViewNibName = "TopicTextTableViewCell"
    private let textCellViewIdentifier = "textCell"
    private let textCellViewHeight = CGFloat(78)
    private let imageCellViewNibName = "TopicDetailImageTableViewCell"
    private let imageCellViewIdentifer = "imageCell"
    private let imageCellViewHeight = CGFloat(275)
    private let authorCellViewNibName = "TopicAuthorTableViewCell"
    private let authorCellViewIdentifer = "authorCell"
    private let authorCellViewHeight = CGFloat(56)
    
    private let topicStatsCellViewNibName = "TopicStatisticsTableViewCell"
    private let topicStatsCellViewIdentifer = "topicStats"
    private let topicStatsCellViewHeight = CGFloat(100)
    
    private let postCellNibName = "PostDetailTableViewCell"
    private let postCellIdentifier = "postCell"
    private let postCellHeight = CGFloat(125)
    
    private let footerHeight = CGFloat(0.1)
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.backgroundColor = UIColor.background()
        tableView.separatorStyle = .None
        adjustTableViewInsets(withBottom: postInputView.frame.size.height)
        
        let nib = UINib(nibName: textCellViewNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: textCellViewIdentifier)
        
        let nib1 = UINib(nibName: imageCellViewNibName, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: imageCellViewIdentifer)
        
        let nib2 = UINib(nibName: authorCellViewNibName, bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: authorCellViewIdentifer)
        
        let nib3 = UINib(nibName: topicStatsCellViewNibName, bundle: nil)
        tableView.registerNib(nib3, forCellReuseIdentifier: topicStatsCellViewIdentifer)
        
        let nib4 = UINib(nibName: postCellNibName, bundle: nil)
        tableView.registerNib(nib4, forCellReuseIdentifier: postCellIdentifier)
    }
    
    
    func refreshTableView(withUpdatedPosts updatedPosts: [Post]) {
        
        let sortFn = { (a: AnyObject, b: AnyObject) -> Bool in
            
            let firstTime = (a as! BaseObject).updatedAt!
            let secondTime = (b as! BaseObject).updatedAt!
            return firstTime.laterDate(secondTime) == firstTime
        }
        
        guard displayMode == .AllData else {
            print("ERROR - trying to update table view but posts are not allowed")
            return
        }
        
        self.tableView.beginUpdates()
        if tableView.numberOfSections == 1 {
            
            // this will be the case when going from requiring a post entry to displaying all data
            
            posts = updatedPosts
            
            let allDataSections = NSMutableIndexSet(index:TableViewSections.Statistics.rawValue)
            allDataSections.addIndex(TableViewSections.Posts.rawValue)
            self.tableView.insertSections(allDataSections, withRowAnimation: .Top)
        }
        else {
            
            let statsIndexPath = NSIndexPath(forRow: 0, inSection: TableViewSections.Statistics.rawValue)
            self.tableView.reloadRowsAtIndexPaths([statsIndexPath], withRowAnimation: .None)
            
            tableView.updateByAddingTo(datasourceData: &posts, withData: updatedPosts, inSection: TableViewSections.Posts.rawValue, sortingArraysWith: sortFn)
        }
        self.tableView.endUpdates()
    }
    
    
    private func adjustTableViewInsets(withBottom bottom: CGFloat) {
        
        var top = CGFloat(64.0)
        if let navHeight = navigationController?.navigationBar.frame.size.height {
            top = navHeight + 20
        }
        
        tableView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if displayMode == .AllData {
            return TableViewSections.maximumNumberOfSections()
        }
        return 1
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
            return 0.01
    }
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return footerHeight
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let topic = myTopic {
            
            var number = 0
            
            switch section {
                
            case TableViewSections.Topic.rawValue:
                number = topic.hasImage ? 3 : 2
                
            case TableViewSections.Statistics.rawValue:
                number = 1
                
            case TableViewSections.Posts.rawValue:
                number = posts.count
                
            default:
                assert(false)
            }
            
            return number
        }
        
        return 0
    }
    
    
    enum TableCellType {
        case TopicText, TopicImage, TopicAuthor, TopicStats, Post
    }
    
    
    func cellTypeForIndexPath(indexPath: NSIndexPath) -> TableCellType {
        
        var cellType: TableCellType?
        
        switch indexPath.section {
            
        case TableViewSections.Topic.rawValue:
            
            let displayingImage = myTopic!.hasImage
            switch indexPath.row {
                
            case 0:
                if displayingImage {
                    cellType = .TopicImage
                }
                else {
                    cellType = .TopicText
                }
                
            case 1:
                if displayingImage {
                    cellType = .TopicText
                }
                else {
                    cellType = .TopicAuthor
                }
                
            case 2:
                cellType = .TopicAuthor
                
            default:
                assert(false)
            }
            
        case TableViewSections.Statistics.rawValue:
            cellType = .TopicStats
            
        case TableViewSections.Posts.rawValue:
            cellType = .Post
            
        default:
            assert(false)
        }
        
        return cellType!
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height: CGFloat = 0
        
        switch cellTypeForIndexPath(indexPath) {
            
        case .TopicText:
            height = textCellViewHeight
            
        case .TopicImage:
            height = imageCellViewHeight
            
        case .TopicAuthor:
            height = authorCellViewHeight
            
        case .TopicStats:
            height = topicStatsCellViewHeight
            
        case .Post:
            height = postCellHeight
            
        }
        
        return height
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        func initializeTextCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(textCellViewIdentifier) as! TopicTextTableViewCell
            cell.displayedTopic = myTopic
            return cell
        }
        
        func initializeImageCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(imageCellViewIdentifer) as! ImageTableViewCell
            cell.displayedTopic = myTopic
            return cell
        }
        
        func initializeAuthorCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(authorCellViewIdentifer) as! TopicAuthorTableViewCell
            cell.displayedTopic = myTopic
            return cell
        }
        
        func initializeStatsCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(topicStatsCellViewIdentifer) as! TopicStatisticsTableViewCell
            cell.displayedTopic = myTopic
            return cell
        }
        
        func initializePostCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(postCellIdentifier) as! PostDetailTableViewCell
            
            cell.displayedPost = posts[indexPath.row]
            return cell
        }
        
        
        var cell: UITableViewCell?
        
        switch cellTypeForIndexPath(indexPath) {
            
        case .TopicText:
            cell = initializeTextCell()
            
        case .TopicImage:
            cell = initializeImageCell()
            
        case .TopicAuthor:
            cell = initializeAuthorCell()
            
        case .TopicStats:
            cell = initializeStatsCell()
            
        case .Post:
            cell = initializePostCell()
            
        }
        
        return cell!
    }
    
    
    
    //MARK: - MapView
    
    private func setupMapView() {
        
        mapView.delegate = self
    }
    
    
    private func refreshMapView(withUpdatedPosts updatedPosts: [Post]) {
        
        let allObjects: [Creation] = [myTopic!] + updatedPosts
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(allObjects)
        mapView.showAnnotations(allObjects, animated: true)
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let topicIdentifier = "topicAnnotation"
        let postIdentifier = "postAnnotation"
        
        let isTopic = (annotation as! Creation) is Topic
        let identifier = isTopic ? topicIdentifier : postIdentifier
        
        var annotationView: MKPinAnnotationView
        if let view = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView {
            
            annotationView = view
        }
        else {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView.pinColor = isTopic ? .Purple : .Red
        }
        
        return annotationView
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
            
            let rectForFooter = tableView.rectForSection(tableView.numberOfSections - 1)
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
                let bottom = self.displayMode == .RequirePostEntry ? self.postInputView.frame.size.height : self.toolbar.frame.size.height
                self.adjustTableViewInsets(withBottom: bottom)
            }
            
            self.view.layoutIfNeeded()
            
            }) { _ -> Void in
                
                if keyboardIsCoveringContent() {
                    
                    let bottom = self.displayMode == .RequirePostEntry ? self.postInputView.frame.size.height : self.toolbar.frame.size.height
                    self.adjustTableViewInsets(withBottom: bottom)
                }}
    }
}
