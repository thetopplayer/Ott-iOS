//
//  PostCreationViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//


/*

Note that the topic is obtained from the Navigation Controller

*/


import UIKit
import MapKit


class TopicDetailViewController: ViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, PostInputViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var postInputView: PostInputView!
    @IBOutlet weak var postInputViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    let segueToExportIdentifier = "segueToExport"
    
    
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
        
        setupTableView()
        setupMapView()
        displayType = .List  // affirmatively set in order to setup display
        
        startObservations()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let navController = navigationController as? NavigationController {
            myTopic = navController.topic
            initializeViewForTopic()
        }
    }
    
    
    deinit {
        endObservations()
    }
    
    
    
    //MARK: - Display
    
    private var didInitializeViewForTopic = false
    private func initializeViewForTopic() {
                
        guard let topic = myTopic else {
            return
        }
        
        if didInitializeViewForTopic == false {
            
            let onlyDisplayTopic = displayedData == .Topic
            displayMode = onlyDisplayTopic ? .Edit : .View
            
            let title = "#" + topic.name!
            self.navigationItem.title = title
            displayType = .List
            
            if onlyDisplayTopic == false {
                fetchPosts()
            }
            
            didInitializeViewForTopic = true
       }
    }
    

    private enum DisplayedData {
        case Topic, TopicAndPosts
    }
    
    
    private var displayedData: DisplayedData {
        
        return currentUser().didPostToTopic(myTopic!) ? .TopicAndPosts : .Topic
    }
    
    
    private enum DisplayMode {
        case View, Edit
    }
    
    
    private var displayMode: DisplayMode = .View {
        
        didSet {
            
            if displayMode == .Edit {
                
                // prepare in case we are going to post
                LocationManager.sharedInstance.reverseGeocodeCurrentLocation()
            }
            
            _setDisplayMode(displayMode)
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
        mapToggleButton?.enabled = displayedData == .TopicAndPosts
        
        switch mode {
            
        case .Edit:
            
            showCancelButton()
            postInputView.reset()
            showPostInputView()
            
        case .View:
            
            showDoneButton()
            showToolbar()
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
            didInitializeViewForTopic = false
        }
    }
    
    private var posts = [Post]()
    private var fetchPostsOperation: FetchPostsOperation?
    private var reloadTopicOperation: FetchTopicOperation?
    private var dateOfMostRecentPost: NSDate?
    
    private func fetchPosts(reloadingTopic reloadingTopic: Bool = false) {
        
        func updateDisplayWithPostsFromCache() {
            
            let cachedPosts = cachedPostsForTopic(myTopic!)
            dateOfMostRecentPost = cachedPosts.first?.createdAt
            
            dispatch_async(dispatch_get_main_queue()) {
                self.displayStatus(type: .Normal)
                self.refreshTableView(withUpdatedPosts: cachedPosts)
                self.reloadMapView()
            }
        }

        
        /*****/
        
        displayStatus(type: .Fetching)

        fetchPostsOperation = {
            
            var operation: FetchPostsOperation
            if let minDate = dateOfMostRecentPost {
                operation = FetchPostsOperation(topic: myTopic!, postedSince: minDate)
            }
            else {
                operation = FetchPostsOperation(topic: myTopic!)
            }
            
            operation.addCompletionBlock({
                updateDisplayWithPostsFromCache()
            })
            
            return operation
            }()
        
        
        if reloadingTopic {
            
            reloadTopicOperation = {
                
                let operation = FetchTopicOperation(topic: myTopic!)
                operation.addDependency(fetchPostsOperation!)
                
                operation.addCompletionBlock({
                    updateDisplayWithPostsFromCache()
                })
                
                return operation
            }()
            
            FetchQueue.sharedInstance.addOperation(reloadTopicOperation!)
            FetchQueue.sharedInstance.addOperation(fetchPostsOperation!)
        }
        else {
            
            fetchPostsOperation!.addCompletionBlock({
                updateDisplayWithPostsFromCache()
            })
            
            FetchQueue.sharedInstance.addOperation(fetchPostsOperation!)
        }
    }
    
    
    private func saveChanges() {
        
        displayMode = .View
        displayStatus(type: .Posting)
        
        let myPost = Post.createWithAuthor(currentUser(), topic: myTopic!)
        myPost.rating = postInputView.rating
        if let comment = postInputView.comment {
            myPost.comment = comment
        }
        myPost.location = LocationManager.sharedInstance.location
        myPost.locationName = LocationManager.sharedInstance.nameForCurrentLocation()
        
        let postOperation = UploadPostOperation(post: myPost)
        PostQueue.sharedInstance.addOperation(postOperation)
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
        
        displayMode = .Edit
    }
    
    
    @IBAction func handleExportAction(sender: AnyObject) {
        
        performSegueWithIdentifier(segueToExportIdentifier, sender: self)
    }
    
    
    private func goodbye() {
        
        fetchPostsOperation?.cancel()
        performSegueWithIdentifier("unwindToMasterView", sender: self)
    }
    
    
    @IBAction func handleCancelAction(sender: AnyObject) {
        
        postInputView?.resignFirstResponder()
        discardChanges()
        
        if displayMode == .View {
            goodbye()
        }
        else {
            
            if displayedData == .Topic {
                goodbye()
            }
            else {
                displayMode = .View
            }
        }
    }
    
    
    @IBAction func handleDoneAction(sender: AnyObject) {
        
        goodbye()
    }
    
    
    
    //MARK: - Navigation
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if let destinationController = segue.destinationViewController as? NavigationController {
            destinationController.topic = myTopic
        }
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
        
        guard displayedData == .TopicAndPosts else {
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
        
        if displayedData == .TopicAndPosts {
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
                number = topic.hasImage() ? 3 : 2
                
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
            
            let displayingImage = myTopic!.hasImage()
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
    
    
    private func reloadMapView() {
        
        let allObjects: [AuthoredObject] = [myTopic!] + posts

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
        
        let isTopic = (annotation as! AuthoredObject) is Topic
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidUploadPost:", name: UploadPostOperation.Notifications.DidUpload, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleUploadDidFail:", name: UploadPostOperation.Notifications.UploadDidFail, object: nil)
        
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
                let bottom = self.displayMode == .Edit ? self.postInputView.frame.size.height : self.toolbar.frame.size.height
                self.adjustTableViewInsets(withBottom: bottom)
            }
            
            self.view.layoutIfNeeded()
            
            }) { _ -> Void in
                
                if keyboardIsCoveringContent() {
                    
                    let bottom = self.displayMode == .Edit ? self.postInputView.frame.size.height : self.toolbar.frame.size.height
                    self.adjustTableViewInsets(withBottom: bottom)
                }}
    }
    
    
    func handleDidUploadPost(notification: NSNotification) {
        
        fetchPosts(reloadingTopic: true)
    }
    
    
    func handleUploadDidFail(notification: NSNotification) {
        
        displayMode = .Edit
        displayStatus(type: .Normal)
    }

}
