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
        
        // swipe right to go back / cancel
        let swipeGR = UISwipeGestureRecognizer(target: self, action: "handleCancelAction:")
        swipeGR.direction = UISwipeGestureRecognizerDirection.Right
        tableView.addGestureRecognizer(swipeGR)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        tabBarController?.tabBar.hidden = true
        initializeViewForTopic()
        startObservations()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        
        performOnMainQueueAfterDelay(1) {
            self.remindUserToPost()
        }
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        endObservations()
        
        // record when this topic was viewed
        MaintenanceQueue.sharedInstance.addOperation(UpdateViewHistoryOperation(topic: topic!, viewedAt: NSDate()))
    }
    
    
    
    //MARK: - Display
    
    enum ExitMethod {
        case Back, Dismiss
    }
    var exitMethod = ExitMethod.Back
    
    
    private func remindUserToPost() {
        
        let maximumNumberOfPrompts = 2
        let numberOfPrompts = Globals.sharedInstance.remindersToPostToTopic
        if numberOfPrompts >= maximumNumberOfPrompts {
            return
        }
        
        presentOKAlert(title: "Create a Post", message: "See what others have said about this topic by first posting your take on it.", actionHandler: nil)
        
        Globals.sharedInstance.remindersToPostToTopic = numberOfPrompts + 1
    }
    
    
    private var didInitializeViewForTopic = false
    private func initializeViewForTopic() {
        
        guard let topic = topic else {
            return
        }
        
        if didInitializeViewForTopic {
            return
        }
        
        displayedData = topic.currentUserDidPostTo ? .TopicAndPosts : .Topic
        displayMode = topic.currentUserDidPostTo ? .View : .Edit
        
        navigationItem.title = topic.name!
        displayType = .List
        adjustMapRegionForTopic()
        
        didInitializeViewForTopic = true
    }
    
    
    private enum DisplayedData {
        case Topic, TopicAndPosts
    }
    
    
    private var displayedData: DisplayedData = .Topic
    
    
    private enum DisplayMode {
        case View, Edit
    }
    
    
    private var displayMode: DisplayMode = .View {
        
        didSet {
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
        
        
        func showBackButton() {
            
            let button = UIButton(frame: CGRectMake(0, 0, 80, 32))
            button.contentEdgeInsets = UIEdgeInsetsMake(4, 0, 4, 0)
            button.contentHorizontalAlignment = .Left
            let backImage = UIImage(named: "halfArrowLeft")
            button.setImage(backImage, forState: UIControlState.Normal)
            button.addTarget(self, action: "handleDoneAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            let backButton = UIBarButtonItem(customView: button)
            navigationItem.leftBarButtonItem = backButton
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
            
            if exitMethod == .Back {
                showBackButton()
            }
            else {
                showDoneButton()
            }
            
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
        case Normal, Updating, Fetching, Posting
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
                
            case .Updating:
                self.statusLabel.text = "Updating..."
                
            case .Fetching:
                self.statusLabel.text = "Fetching Posts..."
                
            case .Posting:
                self.statusLabel.text = "Posting..."
            }
        }
    }
    
    
    
    //MARK: - Data
    
    var topic: Topic? {
        
        didSet {
            
            guard let theTopic = topic else {
                return;
            }
            
            didInitializeViewForTopic = false
            if isVisible() {
                initializeViewForTopic()
            }
            
            if theTopic.currentUserDidPostTo {
                fetchPosts()
            }
        }
    }
    
    private var posts = [Post]()
    private var didFetchPosts = false
    private var dateOfMostRecentPost: NSDate?
    
    private func refreshTopic() {
        
        let reloadTopicOperation = UpdateTopicOperation(topic: topic!) {
            
            (refreshedObject, error) in
            
            self.displayStatus(type: .Normal)
            if let refreshedTopic = refreshedObject as? Topic {
                
                // setting the topic to the refreshedTopic will force a re-fetch of the posts
                self.topic = refreshedTopic
            }
        }
        
        displayStatus(type: .Updating)
        FetchQueue.sharedInstance.addOperation(reloadTopicOperation)
    }
    
    
    private func fetchPosts(offset: Int = 0) {
        
        didFetchPosts = true
        
        let fetchPostsForTopicOperation = FetchPostsForTopicOperation(topic: topic!, offset: offset, limit: 50) {
            
            (fetchResults, error) in
            
            self.displayStatus(type: .Normal)
            if let thePosts = fetchResults as? [Post] {
                
                self.refreshTableView(withUpdatedPosts: thePosts)
                self.reloadMapView()
            }
            
            // TODO;  ALLOW ADDITIONAL FETCHING FROM OFFSET
            
        }
        
        displayStatus(type: .Fetching)
        FetchQueue.sharedInstance.addOperation(fetchPostsForTopicOperation)
    }
    
    
    private func savePost() {
        
        displayMode = .View
        displayStatus(type: .Posting)
        
        let myPost = Post.createForTopic(topic!)
        myPost.rating = postInputView.rating
        if let comment = postInputView.comment {
            myPost.comment = comment
        }
        myPost.location = LocationManager.sharedInstance.location
        myPost.locationDetails = LocationManager.sharedInstance.placemark?.toDictionary()
        
        let postOperation = UploadPostOperation(post: myPost, topic: topic!) {
            
            (post, error) in
         
            self.displayStatus(type: .Normal)
            if post != nil {
                
                self.displayedData = .TopicAndPosts
                self.displayMode = .View
                
                self.refreshTopic()
            }
            else if let error = error {
                
                self.presentOKAlertWithError(error, messagePreamble: "An error occurred uploading your post.", actionHandler: { () -> Void in
                    
                    self.didInitializeViewForTopic = false
                    self.initializeViewForTopic()
                })
            }
        }
        
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
        
        savePost()
    }
    
    
    @IBAction func handleEnterEditModeAction(sender: AnyObject) {
        
        displayMode = .Edit
    }
    
    
    @IBAction func handleExportAction(sender: AnyObject) {
        
        if let navController = navigationController as? NavigationController {
            navController.presentExportViewController(withTopic: topic!)
        }
    }
    
    
    private func goodbye() {
        
        if exitMethod == .Back {
            navigationController?.popViewControllerAnimated(true)
        }
        else if exitMethod == .Dismiss {
            dismissViewControllerAnimated(true, completion: nil)
        }
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
            destinationController.topic = topic
        }
    }
    
    
    
    
    //MARK: - TableView
    
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
    
    
    enum TableViewSections: Int {
        case Topic = 0
        case Statistics = 1
        case Posts = 2
        
        static func maximumNumberOfSections() -> Int {
            return 3
        }
    }
    
    func refreshTableView(withUpdatedPosts updatedPosts: [Post]) {
        
        guard displayedData == .TopicAndPosts else {
            print("ERROR - trying to update table view but posts are not allowed")
            return
        }
        
        posts = updatedPosts

        self.tableView.beginUpdates()
        let numberOfSectionsThatWillBeDisplayed = numberOfSectionsInTableView(tableView)
        
        if tableView.numberOfSections == numberOfSectionsThatWillBeDisplayed {
            
            switch numberOfSectionsInTableView(tableView) {
                
            case 1:
                
                self.tableView.reloadSections(NSIndexSet(index:  TableViewSections.Topic.rawValue), withRowAnimation: .Fade)
                
            case 2:
                
                tableView.reloadSections(NSIndexSet(index:  TableViewSections.Statistics.rawValue), withRowAnimation: .Fade)
                
            case 3:
                
                tableView.reloadSections(NSIndexSet(index:  TableViewSections.Statistics.rawValue), withRowAnimation: .Fade)
                tableView.reloadSections(NSIndexSet(index:  TableViewSections.Posts.rawValue), withRowAnimation: .Automatic)
                
            default:
                assert(false)
            }
            
        }
        else if numberOfSectionsThatWillBeDisplayed == 2 {
            
            tableView.insertSections(NSIndexSet(index: TableViewSections.Statistics.rawValue), withRowAnimation: .Automatic)
        }
        else if numberOfSectionsThatWillBeDisplayed == 3 {
            
            if tableView.numberOfSections == 1 {
                tableView.insertSections(NSIndexSet(index: TableViewSections.Statistics.rawValue), withRowAnimation: .Automatic)
            }
            
            tableView.insertSections(NSIndexSet(index: TableViewSections.Posts.rawValue), withRowAnimation: .Automatic)
        }
        else {
            assert(false)
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
        
        if let topic = topic {
            
            var number = 0
            
            switch section {
                
            case TableViewSections.Topic.rawValue:
                number = topic.imageFile != nil ? 3 : 2
                
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
    
    
    private enum TableCellType {
        case TopicText, TopicImage, TopicAuthor, TopicStats, Post
    }
    
    
    private func cellTypeForIndexPath(indexPath: NSIndexPath) -> TableCellType {
        
        var cellType: TableCellType?
        
        switch indexPath.section {
            
        case TableViewSections.Topic.rawValue:
            
            let displayingImage = topic!.imageFile != nil
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
            cell.displayedTopic = topic
            return cell
        }
        
        func initializeImageCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(imageCellViewIdentifer) as! ImageTableViewCell
            cell.displayedTopic = topic
            return cell
        }
        
        func initializeAuthorCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(authorCellViewIdentifer) as! TopicAuthorTableViewCell
            cell.displayedTopic = topic
            return cell
        }
        
        func initializeStatsCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(topicStatsCellViewIdentifer) as! TopicStatisticsTableViewCell
            cell.displayedTopic = topic
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
        mapView.rotateEnabled = false
    }
    
    
    private func adjustMapRegionForTopic() {
        
        guard let bounds = topic!.bounds else {
            return
        }
        
        let centerCoordinate = CLLocationCoordinate2DMake(bounds[0] + (bounds[2] / 2), bounds[1] + (bounds[3] / 2))
        let span = MKCoordinateSpanMake(bounds[2], bounds[3])
        let coordinateRegion = MKCoordinateRegionMake(centerCoordinate, span)
        
        mapView.setRegion(coordinateRegion, animated: false)
    }
    
    
    private func reloadMapView() {
        
        mapSectors.removeAll()
        mapSectorIDs.removeAll()
        mapPosts.removeAll()
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        
        mapView.addAnnotations([topic!])
    }
    
    
    //MARK: - Displaying Map Sectors
    
    var mapSectors = [MapSector]()
    var mapSectorIDs = Set<String>()
    
    
    var sectorFetchTimer: NSTimer?
    func handleTimerFire(timer: NSTimer?) {
        fetchAndDisplaySectorsForRegion()
    }
    
    
    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        sectorFetchTimer?.invalidate()
        sectorFetchTimer = NSTimer.scheduledTimerWithTimeInterval(0.5, target: self, selector: "handleTimerFire:", userInfo: nil, repeats: false)
    }
    
    private var isFetchingSectors = false
    private func fetchAndDisplaySectorsForRegion() {
        
        if isFetchingSectors {
            return
        }
        
        let mapRect: [Double] = {
            
            let region = mapView.region
            let latitudeDelta = region.span.latitudeDelta
            let longitudeDelta = region.span.longitudeDelta
            let minLat = region.center.latitude - latitudeDelta / 2.0
            let minLong = region.center.longitude - longitudeDelta / 2.0
            
            return [minLat, minLong, latitudeDelta, longitudeDelta]
        }()
        
        print("map mapRect = \(mapRect)")

        isFetchingSectors = true
        let params: [String: AnyObject] = ["topicID": topic!.objectId!, "mapRect": mapRect]
        
        PFCloud.callFunctionInBackground("sectorIDsForMapRect", withParameters: params) {(response: AnyObject?, error: NSError?) -> Void in
            
            guard let response = response else {
                
                self.isFetchingSectors = false
                print("error fetching IDS:  no response from server")
                return
            }
            
            guard let fetchedIDs = response["IDs"] as? [String] else {
                
                self.isFetchingSectors = false
                if let error = error {
                    print("error fetching IDS = \(error)")
                }
                return;
            }
            
            var sectorsThatNeedToBeFetched = [String]()
            for anID in fetchedIDs {
                if self.mapSectorIDs.contains(anID) == false {
                    sectorsThatNeedToBeFetched.append(anID)
                }
            }
            
            print("sectorsThatNeedToBeFetched = \(sectorsThatNeedToBeFetched)")
            
            if sectorsThatNeedToBeFetched.count == 0 {
                return
            }
            
            let query: PFQuery = {
                
                let q = MapSector.query()!
                q.whereKey(DataKeys.SectorID, containedIn: sectorsThatNeedToBeFetched)
                q.limit = sectorsThatNeedToBeFetched.count
                return q
            }()
            
            query.findObjectsInBackgroundWithBlock({ (fetchedSectors, error) -> Void in
                
                self.isFetchingSectors = false
                
                if let fetchedSectors = fetchedSectors as? [MapSector] {
                    
                    // because sectors may not exist for all of the sectorIDs provided in the query, add all of those from the query to the list of IDs that we've fetched
                    
                    self.mapSectorIDs.unionInPlace(sectorsThatNeedToBeFetched)
                    
                    self.mapSectors += fetchedSectors
                    dispatch_async(dispatch_get_main_queue()) {
                        
                        print("fetched sectors = \(fetchedSectors)")
                    }
                }
                else if let error = error {
                    
                    print("error fetching sectors = \(error)")
                }
            })
        }
    }
    
    
    //MARK: - Displaying Map Posts
    
    // only display annotations for posts when zoomed smaller than the smallest sector
    // annotation for topic creation location should always be visible
    
    var mapPosts = [Post]()
    
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
            annotationView.pinTintColor = isTopic ? UIColor.purpleColor() : UIColor.redColor()
        }
        
        return annotationView
    }
    
    

    
    //MARK: -  Observations {
    
    private func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    private func endObservations() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
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
}
