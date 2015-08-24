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
        
        setupTableView()
        startObservations()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if let navController = navigationController as? NavigationController {
            myTopic = navController.topic
        }
        
        self.navigationItem.title = "Topic"
     }
    
    
    deinit {
        endObservations()
    }
    
    
    
    //MARK: - Display
    
    private enum DisplayMode {
        case PostCreation, PostDisplay
    }
    
    
    private var displayMode: DisplayMode? {
        
        didSet {
            _setDisplayMode(displayMode!)
        }
    }
    
    
    private func _setDisplayMode(mode: DisplayMode) {
        
        func showCancelButton() {
            
            let cancelButton = UIBarButtonItem(barButtonSystemItem: .Cancel, target: self, action: "handleCancelAction:")
            navigationItem.leftBarButtonItem = cancelButton
        }
        
        
        func showDoneButton() {
            
            let doneButton = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "handleDoneAction:")
            navigationItem.leftBarButtonItem = doneButton
        }
        
        
        func showPostInputView() {
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .LayoutSubviews, animations: { () -> Void in
                
                self.postInputViewBottomConstraint.constant = 0
                self.toolbarBottomConstraint.constant = -self.toolbar.frame.size.height
                
                let bottom = self.postInputView.frame.size.height
                self.adjustTableViewInsets(withBottom: bottom)

                }) { (_) -> Void in }
        }
        
        
        func showToolbar() {
            
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: .LayoutSubviews, animations: { () -> Void in
                
                self.postInputViewBottomConstraint.constant = -self.postInputView.frame.size.height
                self.toolbarBottomConstraint.constant = 0
                
                let bottom = self.toolbar.frame.size.height
                self.adjustTableViewInsets(withBottom: bottom)

                }) { (_) -> Void in }
        }
        
    
        let mapToggleButton = navigationItem.rightBarButtonItem
        
        switch mode {
            
        case .PostCreation:
            
            showCancelButton()
            postInputView.reset()
            showPostInputView()
            mapToggleButton?.enabled = false
            
        case .PostDisplay:
            
            showDoneButton()
            showToolbar()
            mapToggleButton?.enabled = currentUser().didPostToTopic(myTopic!)
        }
    }
    
    
    func refreshDisplay(refreshingData refreshingData:Bool = true) {
        
        //        func postsArrangedByTimestamp(posts: Set<Post>?) -> [Post] {
        //
        //            var result: [Post]?
        //            if let posts = _myTopic!.posts {
        //
        //                result = posts.sort({ (first, second) -> Bool in
        //                    let d1 = first.createdAt
        //                    let d2 = second.createdAt
        //                    return d1.compare(d2) == .OrderedDescending
        //                })
        //            }
        //            else {
        //                result = []
        //            }
        //            return result!
        //        }
        
        if myTopic == nil {
            return
        }
        
        // enter edit mode if the user has not yet posted to this topic
        displayMode = currentUser().didPostToTopic(myTopic!) ? .PostDisplay : .PostCreation
        setDisplayType(.List)
        
        
        func fetchCompletion(success: Bool, posts: [Post]?) {
            
            if success == false {
                return
            }
            
            if posts == nil {
                self.arrangedPosts = []
                return
            }
            
            self.arrangedPosts = posts!.sort({ (first, second) -> Bool in
                let d1 = first.createdAt!
                let d2 = second.createdAt!
                return d1.compare(d2) == .OrderedDescending
            })
            
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
                self.setMapAnnotations(forPosts: self.arrangedPosts)
            }
        }
        
        myTopic!.getPosts(fetchCompletion)
    }
    
    
    
    private enum DisplayType {
        case Map, List
    }
    

    private var displayedType: DisplayType? {
        
        didSet {
            if let type = displayedType {
                setDisplayType(type)
            }
        }
    }
    
    
    private func setDisplayType(type: DisplayType) {
        
        let mapImageName = "paperMap"
        let tableImageName = "list"

        switch type {
            
        case .Map:
            
            navigationItem.rightBarButtonItem?.image = UIImage(named: tableImageName)
            
            mapView.alpha = 0
            mapView.hidden = false
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                self.mapView.alpha = 1.0
            })
            
        case .List:
            
            navigationItem.rightBarButtonItem?.image = UIImage(named: mapImageName)
            
            UIView.animateWithDuration(0.25, animations: { () -> Void in
                
                self.mapView.alpha = 0
                }, completion: { (_) -> Void in
                    self.mapView.hidden = true
            })
        }
    }
    
   
    
    
    
    //MARK: - Data
    
    private lazy var operationQueue: OperationQueue = {
        
        return OperationQueue()
    }()
    
    
    private var _myTopic: Topic?
    var myTopic: Topic? {
        
        set {
            _myTopic = newValue
            refreshDisplay()
        }
        
        get {
            return _myTopic;
        }
    }
    
    
    private var arrangedPosts = [Post]()
    
    
    private func saveChanges() {
        
        let myPost = Post.createWithAuthor(currentUser(), topic: myTopic!)
        myPost.rating = postInputView.rating
        myPost.comment = postInputView.comment
        myPost.location = LocationManager.sharedInstance.location
        myPost.locationName = LocationManager.sharedInstance.locationName
        myPost.saveEventually()
        
        currentUser().archivePostedTopicID(myTopic!.objectId!)
        
        
        // TODO :  topic needs to know to update its rating
    }
    
    
    private func discardChanges() {
        
        // nothing has been created, so don't do anything
    }
    
    
    
    //MARK: - Actions and PostInputViewDelegate
    
    @IBAction func handleToggleViewAction(sender: AnyObject) {
        
        if displayedType == .Map {
            displayedType = .List
        }
        else {
            displayedType = .Map
        }
    }
    

    func postInputViewPostActionDidOccur() {
        
        saveChanges()
        refreshDisplay()
    }
    
    
    @IBAction func handleEnterEditModeAction(sender: AnyObject) {

        displayMode = .PostCreation
    }
    
    
    @IBAction func handleExportAction(sender: AnyObject) {
        
        
    }
    

    @IBAction func handleCancelAction(sender: AnyObject) {
        
        postInputView?.resignFirstResponder()
        discardChanges()
        
        if currentUser().didPostToTopic(myTopic!) {
            displayMode = .PostDisplay
        }
        else {
            dismissViewControllerAnimated(true) { () -> Void in }
        }
    }
    
    
    @IBAction func handleDoneAction(sender: AnyObject) {
        
        dismissViewControllerAnimated(true) { () -> Void in }
    }
    
    
    
    
    
    //MARK: - TableView
    
    private let topicSection = 0
    private let textCellViewNibName = "TopicTextTableViewCell"
    private let textCellViewIdentifier = "textCell"
    private let imageCellViewNibName = "TopicDetailImageTableViewCell"
    private let imageCellViewIdentifer = "imageCell"
    private let authorCellViewNibName = "TopicAuthorTableViewCell"
    private let authorCellViewIdentifer = "authorCell"
    private let textCellViewHeight = CGFloat(78)
    private let imageCellViewHeight = CGFloat(275)
    private let authorCellViewHeight = CGFloat(56)
    
    private let postsSection = 1
    private let postCellNibName = "PostDetailTableViewCell"
    private let postCellIdentifier = "postCell"
    private let postCellHeight = CGFloat(125)
    
    private let footerHeight = CGFloat(0.1)
    
    private func setupTableView() {
        
        tableView.delegate = self
        tableView.dataSource = self
//        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.backgroundColor = UIColor.background()
        tableView.separatorStyle = .None
        adjustTableViewInsets(withBottom: postInputView.frame.size.height)
        
        let nib = UINib(nibName: textCellViewNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: textCellViewIdentifier)
        
        let nib2 = UINib(nibName: imageCellViewNibName, bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: imageCellViewIdentifer)
        
        let nib4 = UINib(nibName: authorCellViewNibName, bundle: nil)
        tableView.registerNib(nib4, forCellReuseIdentifier: authorCellViewIdentifer)
        
        let nib5 = UINib(nibName: postCellNibName, bundle: nil)
        tableView.registerNib(nib5, forCellReuseIdentifier: postCellIdentifier)
    }
    
    
    private func adjustTableViewInsets(withBottom bottom: CGFloat) {
        
        var top = CGFloat(64.0)
        if let navHeight = navigationController?.navigationBar.frame.size.height {
            top = navHeight + UIApplication.sharedApplication().statusBarFrame.size.height
        }
        
        tableView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        var number: Int = 0
        if let myTopic = myTopic {
            number = currentUser().didPostToTopic(myTopic) ? 2 : 1
        }
        return number
    }


    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return 0.1
        }
        
        return 16
    }
    
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UITableViewHeaderFooterView(frame: CGRectZero)
        view.contentView.backgroundColor = UIColor.background()
        return view
    }
    
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return footerHeight
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if myTopic == nil {
            return 0
        }
        
        let topic = myTopic!
        var number = 0
        
        if section == topicSection {
            
            number = 2  // text and author
            
            if topic.hasImage {
                number++
            }
        }
        else if section == postsSection {
            number = arrangedPosts.count
        }
        
        return number
    }
    
    
    enum TableCellType {
        case TopicText, TopicImage, TopicAuthor, Post
    }
    
    
    func cellTypeForIndexPath(indexPath: NSIndexPath) -> TableCellType {
        
        var cellType: TableCellType?
        
        if indexPath.section == topicSection {
            
            switch indexPath.row {
                
            case 0:
                if myTopic!.hasImage {
                    cellType = .TopicImage
                }
                else {
                    cellType = .TopicText
                }
                
            case 1:
                if myTopic!.hasImage {
                    cellType = .TopicText
                }
                else {
                    cellType = .TopicAuthor
                }
                
            case 2:
                cellType = .TopicAuthor
               
            default:
                NSLog("too many rows for section %d", indexPath.section)
                assert(false)
            }
        }
        else if indexPath.section == postsSection {
            cellType = .Post
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
        
        func initializePostCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(postCellIdentifier) as! PostDetailTableViewCell
            cell.displayedPost = arrangedPosts[indexPath.row]
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
            
        case .Post:
            cell = initializePostCell()
            
        }
        
        return cell!
    }
    
    

    //MARK: - MapView
    
    private func setupMapView() {
        
        mapView.delegate = self
    }
    
    
    private func setMapAnnotations(forPosts posts: [MKAnnotation]) {
        
        mapView.removeAnnotations(mapView.annotations)
        mapView.addAnnotations(posts)
        mapView.showAnnotations(posts, animated: true)
    }
    
    
    func mapViewWillStartRenderingMap(mapView: MKMapView) {
        
        mapView.alpha = 0
    }
    
    
    func mapViewDidFinishRenderingMap(mapView: MKMapView) {
        
        UIView.animateWithDuration(0.3) { () -> Void in
            mapView.alpha = 1.0
        }
    }
    
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        if annotation is MKUserLocation {
            return nil
        }
        
        let identifier = "annotation"
        
        var view = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
        if view == nil {
            view = MKAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        else {
            view?.annotation = annotation
        }
        
        return view
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
                let bottom = self.displayMode == .PostCreation ? self.postInputView.frame.size.height : self.toolbar.frame.size.height
                self.adjustTableViewInsets(withBottom: bottom)
            }

            self.view.layoutIfNeeded()
            
            }) { _ -> Void in
        
                if keyboardIsCoveringContent() {
                    
                    let bottom = self.displayMode == .PostCreation ? self.postInputView.frame.size.height : self.toolbar.frame.size.height
                    self.adjustTableViewInsets(withBottom: bottom)
                }}
    }
}
