//
//  TopicCreationViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit


class TopicCreationViewController: TableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TopicCreationTitleTableViewCellDelegate, TopicCreationButtonTableViewCellDelegate {

    
    private var titleCellView: TopicCreationTitleTableViewCell?
    private var didPresentImagePicker = false
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupTableView()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if didPresentImagePicker == false {
            
            myTopic = Topic.createWithAuthor(currentUser())
            image = nil
            navigationItem.rightBarButtonItem?.enabled = false
        }
        
        tableView.reloadData()
    }
    
    
    private var postingLabel: TransientLabel = {
        return TransientLabel(message: "Posting...", animationStyle: .Fade)
    }()
    
    
    //MARK: - Data
    
    private var image: UIImage?
    private let imageSize = CGSizeMake(800, 800)
    private let imageQuality = CGFloat(0.8)
    
    var myTopic: Topic?
    
    private func saveChanges() {
        
        let topic = myTopic!
        
        topic.name = titleCellView!.title
        if let comment = titleCellView!.comment {
            topic.comment = comment
        }
        topic.setImage(image, quality: imageQuality)
        topic.location = LocationManager.sharedInstance.location
        topic.locationName = LocationManager.sharedInstance.locationName
        
        let uploadOperation = UploadTopicOperation(topic: topic)
        PostQueue.sharedInstance.addOperation(uploadOperation)
        
//        topic.saveInBackgroundWithBlock() { (succeeded, error) in
//            
//            if succeeded {
//                
//                currentUser().archiveAuthoredTopicName(topic.name!)
//                dispatch_async(dispatch_get_main_queue()) {
//                    NSNotificationCenter.defaultCenter().postNotificationName(TopicCreationViewController.Notifications.DidUploadTopic,
//                        object: self)
//                }
//            }
//            else {
//                
//                dispatch_async(dispatch_get_main_queue()) {
//                    
//                    self.postingLabel.abortDisplay()
//                    
//                    if let error = error {
//                        (self as UIViewController).presentOKAlertWithError(error)
//                    }
//                    else {
//                        (self as UIViewController).presentOKAlert(title: "Error", message: "An unknown error occurred while trying to post.  Please check your internet connection and try again.", completion: nil)
//                        
//                    }
//                }
//            }
//        }
    }
    
    private func discardChanges() {
        
        myTopic = nil
    }

    
    
    //MARK: - TableView
    
    private let titleCellViewNibName = "TopicCreationTitleTableViewCell"
    private let titleCellViewIdentifier = "titleCell"
    private let imageCellViewNibName = "TopicDetailImageTableViewCell"
    private let imageCellViewIdentifer = "imageCell"
    private let buttonCellViewNibName = "TopicCreationButtonTableViewCell"
    private let buttonCellViewIdentifer = "buttonCell"
    
    private func setupTableView() {
     
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.backgroundColor = UIColor.whiteColor()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        let nib = UINib(nibName: titleCellViewNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: titleCellViewIdentifier)
        
        let nib1 = UINib(nibName: imageCellViewNibName, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: imageCellViewIdentifer)
        
        let nib2 = UINib(nibName: buttonCellViewNibName, bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: buttonCellViewIdentifer)
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        
        if myTopic == nil {
            return 0
        }
        
        return 1
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if myTopic == nil {
            return 0
        }
        
        return 2
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        func initializeTextCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(titleCellViewIdentifier) as! TopicCreationTitleTableViewCell
            cell.delegate = self
            cell.title = myTopic?.name
            cell.comment = myTopic?.comment
            
            titleCellView = cell
            titleCellView?.becomeFirstResponder()
            return cell
        }
        
        func initializeButtonCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(buttonCellViewIdentifer) as! TopicCreationButtonTableViewCell
            cell.delegate = self
            return cell
        }
        
        func initializeImageCell() -> UITableViewCell {
            
            let cell = tableView.dequeueReusableCellWithIdentifier(imageCellViewIdentifer) as! ImageTableViewCell
            cell.topicImageView?.image = image
            return cell
        }
        
        
        var cell: UITableViewCell
        
        if indexPath.row == 0 {
            
            if image == nil {
                cell = initializeTextCell()
            }
            else {
                cell = initializeImageCell()
            }
        }
        else {
            
            if image == nil {
                cell = initializeButtonCell()
            }
            else {
                cell = initializeTextCell()
            }
        }
        
        return cell
    }
    

    
    //MARK: - Navigation
    
    @IBAction func handleCancelAction(sender: AnyObject) {
       
        if let titleCellView = titleCellView {
            titleCellView.resignFirstResponder()
        }

        discardChanges()
        dismissViewControllerAnimated(true) { () -> Void in }
    }
    
    
    @IBAction func handleDoneAction(sender: AnyObject) {
      
        if let titleCellView = titleCellView {
            
            titleCellView.resignFirstResponder()
            saveChanges()
        }
        
        postingLabel.display(inView: view) { () -> Void in
            self.dismissViewControllerAnimated(true) { () -> Void in }
        }
    }
    
    
    
    //MARK: - TopicCreationTitleTableViewCellDelegate
    
    func validNameWasEntered(isValid: Bool) {
        
        navigationItem.rightBarButtonItem?.enabled = isValid
    }
    
    
    
    //MARK: - TopicCreationButtonTableViewCellDelegate
    
    func buttonViewButtonDidPress(action: TopicCreationButtonTableViewCell.ButtonAction) {
        
        myTopic!.name = titleCellView?.title
        myTopic!.comment = titleCellView?.comment
        
        if action == .Camera {
            
            titleCellView?.resignFirstResponder()
            didPresentImagePicker = true
            PostQueue.sharedInstance.addOperation(CameraOperation(presentationController: self, sourceType: .Camera))
        }
        else {
            
            titleCellView?.resignFirstResponder()
            didPresentImagePicker = true
            PostQueue.sharedInstance.addOperation(CameraOperation(presentationController: self, sourceType: .PhotoLibrary))
        }
    }
    
    
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        self.image = image.resized(toSize: imageSize)
        picker.dismissViewControllerAnimated(true, completion: { self.titleCellView?.becomeFirstResponder() } )
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        picker.dismissViewControllerAnimated(true, completion: { self.titleCellView?.becomeFirstResponder() } )
    }

}
