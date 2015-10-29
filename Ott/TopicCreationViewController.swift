//
//  TopicCreationViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


class TopicCreationViewController: ViewController, UITableViewDataSource, UITableViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TopicCreationTableViewCellDelegate, TopicCreationButtonTableViewCellDelegate {

    
    @IBOutlet var tableView: UITableView!
    
    private var creationCellView: TopicCreationTableViewCell?
    private var didPresentImagePicker = false
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupTableView()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if didPresentImagePicker == false {
            
            // start fetching name for current location now
            LocationManager.sharedInstance.reverseGeocodeCurrentLocation()
            
            myTopic = Topic.create()
            doneButton.enabled = false
        }
        
        tableView.reloadData()
        startObservations()
    }

    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
        endObservations()
    }
    
    
    
    //MARK: - Display
    
    private var doneButton: UIBarButtonItem {
        
        return navigationItem.rightBarButtonItem!
    }
    
    
    private func adjustTableViewInsets(withBottom bottom: CGFloat) {
        
        var top = CGFloat(64.0)
        if let navHeight = navigationController?.navigationBar.frame.size.height {
            top = navHeight + 20
        }
        
        tableView.contentInset = UIEdgeInsetsMake(top, 0, bottom, 0)
    }
    

    
    
    //MARK: - Data
    
    var myTopic: Topic?
    
    private func saveChanges() {
        
        guard let topic = myTopic else {
            return
        }
        
        doneButton.enabled = false
        
        topic.name = creationCellView!.title
        if let comment = creationCellView!.comment {
            topic.comment = comment
        }

        topic.location = LocationManager.sharedInstance.location
        topic.locationDetails = LocationManager.sharedInstance.placemark?.toDictionary()
        
        let uploadOperation = UploadTopicOperation(topic: topic)
        PostQueue.sharedInstance.addOperation(uploadOperation)
    }
    
    private func discardChanges() {
        
        myTopic = nil
    }

    
    
    //MARK: - TableView
    
    private let creationCellViewNibName = "TopicCreationTableViewCell"
    private let creationCellViewIdentifier = "textCreationCell"
    private let creationCellViewHeight = CGFloat(128)

    private let imageCellViewNibName = "TopicCreationWithImageTableViewCell"
    private let imageCellViewIdentifer = "imageCreationCell"
    private let imageCellViewHeight = CGFloat(400)

    private let buttonCellViewNibName = "TopicCreationButtonTableViewCell"
    private let buttonCellViewIdentifer = "buttonCell"
    private let buttonCellViewHeight = CGFloat(70)
    
    private func setupTableView() {
     
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.backgroundColor = UIColor.background()
        
        tableView.separatorStyle = .None
        
        let nib = UINib(nibName: creationCellViewNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: creationCellViewIdentifier)
        
        let nib1 = UINib(nibName: imageCellViewNibName, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: imageCellViewIdentifer)
        
        let nib2 = UINib(nibName: buttonCellViewNibName, bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: buttonCellViewIdentifer)
    }
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if myTopic == nil {
            return 0
        }
        
        return 1
    }
    
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return myTopic!.imageFile == nil ? 2 : 1
    }
    
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        var height: CGFloat = 0
        if indexPath.row == 0 {
            height = myTopic!.imageFile == nil ? creationCellViewHeight : imageCellViewHeight
        }
        else {
            height = buttonCellViewHeight
        }
        
        return height
    }
    
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        func initializeTextCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(creationCellViewIdentifier) as! TopicCreationTableViewCell
            cell.delegate = self
            cell.displayedTopic = myTopic
            
            creationCellView = cell
            return cell
        }
        
        
        func initializeImageCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(imageCellViewIdentifer) as! TopicCreationTableViewCell
            cell.delegate = self
            cell.displayedTopic = myTopic
            
            creationCellView = cell
            return cell
        }
        
        func initializeButtonCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(buttonCellViewIdentifer) as! TopicCreationButtonTableViewCell
            cell.delegate = self
            return cell
        }
        
        
        var cell: UITableViewCell
        
        if indexPath.row == 0 {
            cell = myTopic!.imageFile == nil ? initializeTextCell() : initializeImageCell()
        }
        else {
            cell = initializeButtonCell()
        }
        
        return cell
    }
    
    

    
    //MARK: - Observations
    
    func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleKeyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidUploadTopicNotification:", name: UploadTopicOperation.Notifications.DidUpload, object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleUploadDidFailNotification:", name: UploadTopicOperation.Notifications.UploadDidFail, object: nil)
    }
    
    
    private func endObservations() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func handleDidUploadTopicNotification(notification: NSNotification) {
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func handleUploadDidFailNotification(notification: NSNotification) {
        
        
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
            self.view.layoutIfNeeded()
            
            }) { _ -> Void in
                
                self.adjustTableViewInsets(withBottom: kbFrame.size.height)
        }
    }
    
    
    func handleKeyboardWillHide(notification: NSNotification) {
        
        if isVisible() == false {
            return
        }
        
        let durationNum = notification.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        let duration = durationNum.doubleValue
        let curve = notification.userInfo![UIKeyboardAnimationCurveUserInfoKey] as! Int
        
        view.layoutIfNeeded()
        UIView.animateWithDuration(duration, delay: 0, options: UIViewAnimationOptions.BeginFromCurrentState, animations: { () -> Void in
            
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: curve)!)
            self.view.layoutIfNeeded()
            
            }) { _ -> Void in
                
                self.adjustTableViewInsets(withBottom: 0)
        }
    }
    
    
    //MARK: - Navigation
    
    @IBAction func handleCancelAction(sender: AnyObject) {
       
        if let creationCellView = creationCellView {
            creationCellView.resignFirstResponder()
        }

        discardChanges()
        dismissViewControllerAnimated(true) { () -> Void in }
    }
    
    
    @IBAction func handleDoneAction(sender: AnyObject) {
      
        navigationItem.title = "Posting..."
        saveChanges()
        dismissViewControllerAnimated(true) { () -> Void in }
    }
    
    
    
    //MARK: - TopicCreationTitleTableViewCellDelegate
    
    func validNameWasEntered(isValid: Bool) {
        
        doneButton.enabled = isValid
    }
    
    
    
    //MARK: - TopicCreationButtonTableViewCellDelegate
    
    func buttonViewButtonDidPress(action: TopicCreationButtonTableViewCell.ButtonAction) {
        
        myTopic!.name = creationCellView?.title
        myTopic!.comment = creationCellView?.comment
        
        if action == .Camera {
            
            creationCellView?.resignFirstResponder()
            didPresentImagePicker = true
            PostQueue.sharedInstance.addOperation(CameraOperation(presentationController: self, sourceType: .Camera))
        }
        else {
            
            creationCellView?.resignFirstResponder()
            didPresentImagePicker = true
            PostQueue.sharedInstance.addOperation(CameraOperation(presentationController: self, sourceType: .PhotoLibrary))
        }
    }
    
    
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let defaultImageSize = CGSizeMake(800, 800)
        self.myTopic!.setImage(image.resized(toSize: defaultImageSize))
        picker.dismissViewControllerAnimated(true) {
        
            self.tableView.reloadData()
        }
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        picker.dismissViewControllerAnimated(true, completion: { self.creationCellView?.becomeFirstResponder() } )
    }

}
