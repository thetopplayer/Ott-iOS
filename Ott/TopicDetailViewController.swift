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
    
    @IBOutlet weak var tableView: TableView!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var postInputView: PostInputView!
    @IBOutlet weak var postInputViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var toolbarBottomConstraint: NSLayoutConstraint!
    
    struct Notifications {
        
        static let DidPostToTopic = "didPostToTopic"
        static let Topic = "post"
    }
    
    
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        view.backgroundColor = UIColor.whiteColor()
        
        postInputView.delegate = self
        postInputView.maximumViewHeight = 200
        
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
    
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        endObservations()
    }
    
    
    
    //MARK: - Display
    
    enum ExitMethod {
        case Back, Dismiss
    }
    var exitMethod = ExitMethod.Back
    
    
//    private func remindUserToPost() {
//        
//        let maximumNumberOfPrompts = 2
//        let numberOfPrompts = Globals.sharedInstance.remindersToPostToTopic
//        if numberOfPrompts >= maximumNumberOfPrompts {
//            return
//        }
//        
//        presentOKAlert(title: "Create a Post", message: "See what others have said about this topic by first posting your take on it.", actionHandler: nil)
//        
//        Globals.sharedInstance.remindersToPostToTopic = numberOfPrompts + 1
//    }
    
    
    private var didInitializeViewForTopic = false
    private func initializeViewForTopic(reloadingData reloadingData: Bool = true) {
        
        guard let topic = topic else {
            return
        }
        
        if didInitializeViewForTopic {
            return
        }
        didInitializeViewForTopic = true
        
        if let currentUserDidPostToTopic = topic.currentUserDidPostTo {
            displayMode = currentUserDidPostToTopic ? .View : .Edit
        }
        else {
            currentUser().didPostToTopic(topic, completion: { (didPost) -> Void in
                topic.currentUserDidPostTo = didPost
                self.displayMode = didPost ? .View : .Edit
            })
        }
        
        navigationItem.title = topic.name!
        displayType = .List
        
        if reloadingData {
            tableView.reloadData()
            initializeMapViewForTopic()
            fetchPosts()
        }
    }
    

    private var statusLabel: UILabel? {
        
        didSet {
            statusLabel?.text = statusMessage
        }
    }
    
    
    private var statusMessage: String? {
        
        didSet {
            statusLabel?.text = statusMessage
        }
    }

    
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
            
            view.layoutIfNeeded()
            UIView.animateWithDuration(animationDuration, animations: { () -> Void in
                
                self.postInputViewBottomConstraint.constant = 0
                self.toolbarBottomConstraint.constant = -self.toolbar.frame.size.height
                let bottom = self.postInputView.frame.size.height
                self.tableView.adjustTableViewInsets(withBottom: bottom)
                self.view.layoutIfNeeded()
                
                }) { (_) -> Void in
                    
            }
        }
        
        func showToolbar() {
            
            func animations() {
                
                self.postInputViewBottomConstraint.constant = -self.postInputView.frame.size.height
                self.toolbarBottomConstraint.constant = 0
                self.tableView.adjustTableViewInsets(withBottom: 0)
                self.view.layoutIfNeeded()
            }
            
            UIView.animateWithDuration(animationDuration, animations: animations) { (_) -> Void in
                
            }
        }
        
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
    
    
    private func mapToolbarButtonForLocationSetting() -> UIBarButtonItem {
        
        let image = displayUserLocation ? UIImage(named: "locationFull") : UIImage(named: "locationEmpty")
        return UIBarButtonItem(image: image, style: .Plain, target: self, action: "toggleUserLocationDisplay:")
    }
    
    
    var displayUserLocation = false {
        
        didSet {
            
            if displayType == .Map {
                var items = toolbar.items!
                items.removeFirst()
                items.insert(mapToolbarButtonForLocationSetting(), atIndex: 0)
                toolbar.setItems(items, animated: true)
            }
            
            mapView.showsUserLocation = displayUserLocation
            
            // TODO = ZOOM TO ENCOMPASS LOCATION
        }
    }
    

    private let listToolbarStatusLabel: UILabel = {
        
        let label = UILabel(frame: CGRectMake(0, 0, 120, 32))
        label.font = UIFont.systemFontOfSize(13)
        label.textAlignment = .Center
        label.textColor = UIColor.darkGrayColor()
        return label
    }()
    

    private let mapToolbarStatusLabel: UILabel = {
        
        let label = UILabel(frame: CGRectMake(0, 0, 120, 32))
        label.font = UIFont.systemFontOfSize(13)
        label.textAlignment = .Center
        label.textColor = UIColor.darkGrayColor()
        return label
    }()

    
    private func _setDisplayType(type: DisplayType) {
        
        func showListTools() {
            
            let listToolbarItems: [UIBarButtonItem] = {
                
                let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "enterEditMode:")
                let space1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
                let status = UIBarButtonItem(customView: listToolbarStatusLabel)
                status.width = 120
                let space2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
                let exportButton = UIBarButtonItem(barButtonSystemItem: .Action, target: self, action: "presentExportView:")
                return [createButton, space1, status, space2, exportButton]
            }()
            
            toolbar.setItems(listToolbarItems, animated: true)
            statusLabel = listToolbarStatusLabel
        }
        
        func showMapTools() {
            
            let mapToolbarItems: [UIBarButtonItem] = {
                
                let locationButton = mapToolbarButtonForLocationSetting()
                let space1 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
                let status = UIBarButtonItem(customView: mapToolbarStatusLabel)
                status.width = 120
                let space2 = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: "")
                let infoButton = UIBarButtonItem(image: UIImage(named: "info"), style: .Plain, target: self, action: "presentMapViewOptions:")
                return [locationButton, space1, status, space2, infoButton]
            }()
            
            toolbar.setItems(mapToolbarItems, animated: true)
            statusLabel = mapToolbarStatusLabel
        }
        
        switch type {
            
        case .Map:
            
            mapView.alpha = 0
            mapView.hidden = false
            showMapTools()
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                self.mapView.alpha = 1.0
            })
            
        case .List:
            
            showListTools()
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
    
    
    
    //MARK: - Data
    
    private var _oldTopic: Topic?
    var topic: Topic? {
        
        willSet {
            _oldTopic = newValue
        }
        
        didSet {
            
            let isNewTopic: Bool = {
                if let oldTopic = self._oldTopic {
                    return oldTopic.isEqual(self.topic) == false
                }
                return true
            }()
            
            didInitializeViewForTopic = false
            if isVisible() {
                initializeViewForTopic(reloadingData: isNewTopic)
            }
        }
    }
    
    private var posts = [Post]()
    private var didFetchPosts = false
    private var dateOfMostRecentPost: NSDate?
    private var postFetchOffset = 0
    private var allPostsFetched = false
    
    private func fetchPosts(offset: Int = 0) {
        
        guard allPostsFetched == false else {
            return
        }
        
        statusMessage = "Fetching posts..."
        
        let theQuery: PFQuery = {
            
            let query = Post.query()!
            query.skip = offset
            query.limit = 20
            query.orderByDescending(DataKeys.CreatedAt)
            query.whereKey(DataKeys.Topic, equalTo: topic!)
            return query
        }()
        
        theQuery.findObjectsInBackgroundWithBlock { (fetchResults, error) -> Void in
            
            if let thePosts = fetchResults as? [Post] {
                self.refreshTableView(replacingPosts: thePosts)
                
                self.postFetchOffset += thePosts.count
                self.allPostsFetched = thePosts.count < theQuery.limit
            }
            self.statusMessage = ""
            self.didFetchPosts = true
        }
    }
    
    
    private func savePost() {
        
        guard let topic = topic else {
            assert(false)
            return
        }
        
        func refreshTopicWithPost(post: Post) {
            
            // update topic values seen by the user:  not the actual ones, which are set by the server
            
            let updatedNumberOfPosts = topic.localNumberOfPosts + 1
            let updatedAverage = (topic.localAverageRating * Float(topic.localNumberOfPosts) + Float(post.rating!.value!)) / Float(updatedNumberOfPosts)
            topic.localNumberOfPosts = updatedNumberOfPosts
            topic.localAverageRating = updatedAverage
            
            let userinfo = [Notifications.Topic: topic]
            let notification = NSNotification(name: Notifications.DidPostToTopic, object: self, userInfo: userinfo)
            NSNotificationQueue.defaultQueue().enqueueNotification(notification, postingStyle: .PostNow)
        }
        
        func updateTableWithPost(post: Post) {
            
            self.posts.insert(post, atIndex: 0)
            
            tableView.beginUpdates()
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: TableViewSections.Statistics.rawValue)], withRowAnimation: .None)
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: TableViewSections.Posts.rawValue)], withRowAnimation: .Fade)
            tableView.endUpdates()
        }
        
        
        displayMode = .View
        statusMessage = "Posting..."
        
        let myPost = Post.createForTopic(topic)
        myPost.rating = postInputView.rating
        if let comment = postInputView.comment {
            myPost.comment = comment
        }
        myPost.location = LocationManager.sharedInstance.location
        myPost.locationDetails = LocationManager.sharedInstance.placemark?.toDictionary()
        
        let postOperation = UploadPostOperation(post: myPost, topic: topic) {
            
            (postedObject, error) in
         
            self.statusMessage = ""
            if let post = postedObject as? Post {
                
                refreshTopicWithPost(post)
                updateTableWithPost(post)
                self.addMapAnnotation(post)
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
    
    
    @IBAction func enterEditMode(sender: AnyObject) {
        
        displayMode = .Edit
    }
    
    
    @IBAction func toggleUserLocationDisplay(sender: AnyObject) {
        
        displayUserLocation = !displayUserLocation
    }
    
    
    @IBAction func presentMapViewOptions(sender: AnyObject) {
        
        let alertViewController = UIAlertController(title: "Map Type", message: nil, preferredStyle: .ActionSheet)
        
        let a1 = UIAlertAction(title: "Standard", style: UIAlertActionStyle.Default, handler: { action in self.mapView.mapType = .Standard })
        let a2 = UIAlertAction(title: "Satellite", style: UIAlertActionStyle.Default, handler: { action in self.mapView.mapType = .Satellite })
        let a3 = UIAlertAction(title: "Hybrid", style: UIAlertActionStyle.Default, handler: { action in self.mapView.mapType = .Hybrid })
        
        alertViewController.addAction(a1)
        alertViewController.addAction(a2)
        alertViewController.addAction(a3)
        
        presentViewController(alertViewController, animated: true, completion: nil)
    }
    
    
    @IBAction func presentExportView(sender: AnyObject) {
        
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
            displayMode = .View
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
    private let textCellViewHeight = CGFloat(133)
    private let imageCellViewNibName = "TopicImageTableViewCell"
    private let imageCellViewIdentifer = "imageCell"
    private let imageCellViewHeight = CGFloat(400)
    
    private let topicStatsCellViewNibName = "TopicStatisticsTableViewCell"
    private let topicStatsCellViewIdentifer = "topicStats"
    private let topicStatsCellViewHeight = CGFloat(92)
    
    private let postCellNibName = "PostDetailTableViewCell"
    private let postCellIdentifier = "postCell"
    private let postCellHeight = CGFloat(125)
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension

        let nib = UINib(nibName: textCellViewNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: textCellViewIdentifier)
        
        let nib1 = UINib(nibName: imageCellViewNibName, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: imageCellViewIdentifer)
        
        let nib3 = UINib(nibName: topicStatsCellViewNibName, bundle: nil)
        tableView.registerNib(nib3, forCellReuseIdentifier: topicStatsCellViewIdentifer)
        
        let nib4 = UINib(nibName: postCellNibName, bundle: nil)
        tableView.registerNib(nib4, forCellReuseIdentifier: postCellIdentifier)
    }
    
    
    enum TableViewSections: Int {
        case Topic = 0
        case Statistics = 1
        case Posts = 2
    }
    
    
    func refreshTableView(replacingPosts replacementPosts: [Post]) {
        
        posts = replacementPosts
        
        if tableView.numberOfSections == 0 {
            tableView.reloadData()
        }
        else {
            
            self.tableView.beginUpdates()
            tableView.reloadSections(NSIndexSet(index: TableViewSections.Posts.rawValue), withRowAnimation: .Fade)
            self.tableView.endUpdates()
        }
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if topic == nil {
            return 0
        }
        return 3
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0.01
        }
        return 40
    }
    
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        var title: String? = nil
        
        switch section {
            
        case 1:
            title = "statistics"
            
        case 2:
            title = "recent posts"
            
        default:
            ()
        }
        
        return title
    }
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.01
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard topic != nil else {
            return 0
        }
        
        var number = 0
        
        switch section {
            
        case TableViewSections.Topic.rawValue:
            number = 1
            
        case TableViewSections.Statistics.rawValue:
            number = 1
            
        case TableViewSections.Posts.rawValue:
            number = posts.count
            
        default:
            assert(false)
        }
        
        return number
    }
    
    
    private enum TableCellType {
        case TopicText, TopicImage, TopicStats, Post
    }
    
    
    private func cellTypeForIndexPath(indexPath: NSIndexPath) -> TableCellType {
        
        var cellType: TableCellType?
        
        switch indexPath.section {
            
        case TableViewSections.Topic.rawValue:
            cellType = topic!.imageFile != nil ? .TopicImage : .TopicText
            
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
            
        case .TopicStats:
            height = topicStatsCellViewHeight
            
        case .Post:
            height = postCellHeight
            
        }
        
        return height
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        func initializeTextCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(textCellViewIdentifier) as! TopicDetailTableViewCell
            cell.displayedTopic = topic
            return cell
        }
        
        func initializeImageCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(imageCellViewIdentifer) as! TopicDetailTableViewCell
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
    
    private var mapAnnotations = [Post]()
    private var mapSectorIDsOfDownloadedAnnotations = Set<String>()
    
    private var fewAnnotations = false
    
    private var mapSectorsBySize: [SectorSize: Array<MapSector>] = {
        
        var dictionary = [SectorSize: [MapSector]]()
        for size in MapSector.sizes {
            dictionary[size] = Array<MapSector>()
        }
        return dictionary
    }()
    
    
    private var sectorFetchOffsetsBySize: [SectorSize: Int] = {
        
        var dictionary = [SectorSize: Int]()
        for size in MapSector.sizes {
            dictionary[size] = 0
        }
        return dictionary
    }()
    
    
    private func clearMapSectorData() {
        
        for (size, _) in mapSectorsBySize {
            mapSectorsBySize[size] = Array<MapSector>()
        }
        
        for (size, _) in sectorFetchOffsetsBySize {
            sectorFetchOffsetsBySize[size] = 0
        }
    }
    
    
    enum MapDataType: Int {
        
        case None = -100
        case Annotations = -1
        case Sector0 = 0
        case Sector1 = 1
        case Sector2 = 2
        case Sector3 = 3
        case Sector4 = 4
        case Sector5 = 5
        
        func toSectorSize() -> SectorSize? {
            
            if self == .None || self == .Annotations {
                return nil
            }
            return self.rawValue
        }
    }
    
    
    private func initializeMapViewForTopic() {
        
        guard let topic = topic else {
            return
        }
        
        func adjustMapRegionForTopic() {
            
            guard let bounds = topic.bounds else {
                return
            }
            
            let centerCoordinate = CLLocationCoordinate2DMake(bounds[0] + (bounds[2] / 2), bounds[1] + (bounds[3] / 2))
            let span = MKCoordinateSpanMake(bounds[2], bounds[3])
            let coordinateRegion = MKCoordinateRegionMake(centerCoordinate, span)
            
            mapView.setRegion(coordinateRegion, animated: false)
        }
        
        fewAnnotations = topic.numberOfPosts < 100
        
        clearMapSectorData()
        mapAnnotations.removeAll()
        mapSectorIDsOfDownloadedAnnotations.removeAll()
        
        dispatch_async(dispatch_get_main_queue()) {
            self.mapView.removeAnnotations(self.mapView.annotations)
            self.mapView.removeOverlays(self.mapView.overlays)
            self.mapView.addAnnotation(self.topic!)
        }
        
        adjustMapRegionForTopic()
    }
    
    
    private func addMapAnnotation(post: Post) {
        
        self.mapAnnotations.append(post)
        if mapDataType == .Annotations {
            mapView.addAnnotation(post)
        }
    }
    
    
    private func removeAnnotationsLeavingTopic() {
        
        guard let topic = topic else {
            return
        }
        
        var annotations = self.mapView.annotations as! [AuthoredObject]
        if let topicIndex = annotations.indexOf(topic) {
            annotations.removeAtIndex(topicIndex)
        }
        self.mapView.removeAnnotations(annotations)
    }
    
    
    private var _mapDataType: MapDataType = .None
    private var mapDataType: MapDataType = .None {
        
        didSet {
            
            if _mapDataType == mapDataType {
                return
            }
            _mapDataType = mapDataType
            
            dispatch_async(dispatch_get_main_queue()) {
                
                switch self.mapDataType {
                    
                case .None:
                    
                    self.removeAnnotationsLeavingTopic()
                    self.mapView.removeOverlays(self.mapView.overlays)
                    
                case .Annotations:
                    self.mapView.removeOverlays(self.mapView.overlays)
                    self.mapView.addAnnotations(self.mapAnnotations)
                    
                default:
                    self.mapView.removeOverlays(self.mapView.overlays)
                    self.removeAnnotationsLeavingTopic()
                    
                    if let sectorSize = self.mapDataType.toSectorSize() {
                        self.mapView.addOverlays(self.mapSectorsBySize[sectorSize]!)
                    }
                }
            }
        }
    }
    
    
    private func appropriateDataTypeForRegion(region: MKCoordinateRegion) -> MapDataType {
        
        // TODO - implememnt after debugging
//        if fewAnnotations {
//            return .Annotations
//        }
        
        var type: MapDataType = .None
        
        let minimumSpan = max(region.span.latitudeDelta, region.span.longitudeDelta)
        if minimumSpan < MapSector.actualSizeForSize(2) {
            type = .Annotations
        }
        else if minimumSpan < MapSector.actualSizeForSize(3) {
            type = .Sector0
        }
        else if minimumSpan < MapSector.actualSizeForSize(4) {
            type = .Sector1
        }
        else if minimumSpan < MapSector.actualSizeForSize(5) {
            type = .Sector2
        }
        else {
            type = .Sector3
        }

        print("min span = \(type)")
        
        return type
    }
    
    
    private var isFetchingSectors = false
    private func fetchSectorsOfSize(size: SectorSize = 0) {
        
        if isFetchingSectors {
            return
        }
        isFetchingSectors = true
        
        guard let topic = topic else {
            return
        }
        
        print("fetching sectors of size = \(size)")
        
        let theQuery: PFQuery = {
            
            let query = MapSector.query()!
            query.skip = sectorFetchOffsetsBySize[size]!
            
//            let limit = sectorFetchOffsetsBySize[size] == 0 ? 10 : 50
            query.limit = 50
            
            query.whereKey(DataKeys.Topic, equalTo: topic)
            query.whereKey(DataKeys.SectorSize, equalTo: size)
            return query
        }()
        
        theQuery.findObjectsInBackgroundWithBlock { (fetchResults, error) -> Void in
            
            self.isFetchingSectors = false
            
            if let fetchedSectors = fetchResults as? [MapSector] {
                
                let offset = self.sectorFetchOffsetsBySize[size]
                self.sectorFetchOffsetsBySize[size] = offset! + fetchedSectors.count
                let sectors = self.mapSectorsBySize[size]
                self.mapSectorsBySize[size] = sectors! + fetchedSectors
                
                if self.mapDataType.toSectorSize() == size {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.mapView.addOverlays(fetchedSectors)
                    }
                }
            }
        }
    }
    
    
    private var isFetchingAnnotations = false
    private func fetchAnnotationsForRegion(region: MKCoordinateRegion) {
        
        if isFetchingAnnotations {
            return
        }
        isFetchingAnnotations = true
        
        func finishPresentingErrorMessage(message: String? = nil) {
            isFetchingAnnotations = false
            if let message = message {
                print(message)
            }
        }
        
        func fetchSectorIDs() {
            
            let mapRect: [Double] = {
                
                let region = mapView.region
                let latitudeDelta = region.span.latitudeDelta
                let longitudeDelta = region.span.longitudeDelta
                let minLat = region.center.latitude - latitudeDelta / 2.0
                let minLong = region.center.longitude - longitudeDelta / 2.0
                
                return [minLat, minLong, latitudeDelta, longitudeDelta]
            }()
            
            let params: [String: AnyObject] = ["topicID": topic!.objectId!, "mapRect": mapRect]
            
            PFCloud.callFunctionInBackground("sectorIDsForMapRect", withParameters: params) {(response: AnyObject?, error: NSError?) -> Void in
                
                if let error = error {
                    finishPresentingErrorMessage(error.localizedDescription)
                    return
                }
                
                guard let response = response else {
                    finishPresentingErrorMessage("error fetching IDS:  no response from server")
                    return
                }
                
                guard let numberOfSectors = response["count"] as? Int else {
                    finishPresentingErrorMessage()
                    return
                }
                
                if numberOfSectors == 0 {
                    finishPresentingErrorMessage("number of sectors is 0")
                    return
                }
                
                guard let fetchedIDs = response["IDs"] as? [String] else {
                    finishPresentingErrorMessage("error:  no fetched IDs")
                    return
                }
                
                var sectorsThatNeedToBeFetched = [String]()
                for anID in fetchedIDs {
                    if self.mapSectorIDsOfDownloadedAnnotations.contains(anID) == false {
                        sectorsThatNeedToBeFetched.append(anID)
                    }
                }
                
                if sectorsThatNeedToBeFetched.count > 0 {
                    fetchPostsForSectorsWithIDs(sectorsThatNeedToBeFetched)
                }
                else {
                    finishPresentingErrorMessage()
                }
            }
        }
        
        
        // TODO - go back and fetch more if we are still moving around within same area?  don't want to fetch too many, but if region gets smaller it makes sense to display what will reasonably fit in it
        
        func fetchPostsForSectorsWithIDs(sectorIDs: [String]) {
            
            let query: PFQuery = {
                
                let q = Post.query()!
                q.whereKey(DataKeys.SectorID, containedIn: sectorIDs)
                q.limit = 30
                return q
            }()
            
            query.findObjectsInBackgroundWithBlock({ (fetchResults, error) -> Void in
                
                if let posts = fetchResults as? [Post] {
                    
                    self.mapSectorIDsOfDownloadedAnnotations.unionInPlace(sectorIDs)
                    self.mapAnnotations += posts
                    
                    if self.mapDataType == .Annotations {
                        dispatch_async(dispatch_get_main_queue()) {
                            self.mapView.addAnnotations(posts)
                        }
                    }
                    
                    finishPresentingErrorMessage()
                }
                else if let error = error {
                    
                    let message = "error fetching posts = \(error.localizedDescription)"
                    finishPresentingErrorMessage(message)
                }
                else {
                    finishPresentingErrorMessage()
                }
            })
            
        }
        
        fetchSectorIDs()
    }
    

    func mapView(mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        
        fetchTimer?.invalidate()
        fetchTimer = NSTimer.scheduledTimerWithTimeInterval(0.75, target: self, selector: "handleTimerFire:", userInfo: nil, repeats: false)
    }
    
    
    var fetchTimer: NSTimer?
    func handleTimerFire(timer: NSTimer?) {
        
        let appropriateDataType = appropriateDataTypeForRegion(mapView.region)
        if appropriateDataType == mapDataType {
            return
        }
        
        mapDataType = appropriateDataType
        
        if appropriateDataType == .Annotations {
            fetchAnnotationsForRegion(mapView.region)
        }
        else {
            
            let sectorSize = appropriateDataType.toSectorSize()
            if mapSectorsBySize[sectorSize!]!.count == 0 {
                fetchSectorsOfSize(sectorSize!)
            }
        }
    }

    
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay) -> MKOverlayRenderer {
        
        let mapSector = overlay as! MapSector
        let renderer = MKPolygonRenderer(polygon: mapSector.polygon())
        
        renderer.fillColor = mapSector.color()
        renderer.alpha = {
            
            let minAlpha = CGFloat(0.25)
            let maxAlpha = CGFloat(0.80)
            
            guard mapSector.numberOfPosts < topic!.numberOfPosts else {
                return maxAlpha
            }
            
            let fractionOfTotal = CGFloat(mapSector.numberOfPosts) / CGFloat(topic!.numberOfPosts)
            return minAlpha + (fractionOfTotal * (maxAlpha - minAlpha))
        }()
        
        return renderer
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
                self.tableView.adjustTableViewInsets(withBottom: bottom)
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
                let bottom = self.displayMode == .Edit ? self.postInputView.frame.size.height : 0
                self.tableView.adjustTableViewInsets(withBottom: bottom)
            }
            
            self.view.layoutIfNeeded()
            
            }) { _ -> Void in
                
//                if keyboardIsCoveringContent() {
//                    
//                    let bottom = self.displayMode == .Edit ? self.postInputView.frame.size.height : 0
//                    self.tableView.adjustTableViewInsets(withBottom: bottom)
//                }
        }
    }
}

