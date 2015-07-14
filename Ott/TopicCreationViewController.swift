//
//  TopicCreationViewController.swift
//  Ott
//
//  Created by Max on 6/25/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit
import CoreData

class TopicCreationViewController: TableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, TopicCreationTitleTableViewCellDelegate, TopicCreationButtonTableViewCellDelegate {

    private var titleCellView: TopicCreationTitleTableViewCell?
    private var imageCellView: TopicImageTableViewCell?
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupTableView()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if myTopic == nil {
            myTopic = Topic.create(inContext: managedObjectContext)
            navigationItem.rightBarButtonItem?.enabled = false
        }
        
        if let titleCellView = titleCellView {
            
            titleCellView.title = myTopic?.name
            titleCellView.comment = myTopic?.comment
        }
        
        self.tableView.reloadData()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        titleCellView?.becomeFirstResponder()
    }
    
    
    func imageLoaded() -> Bool {
        return myTopic?.image != nil
    }
    
    
    
    //MARK: - Data
    
    var myTopic: Topic?
    
    private lazy var managedObjectContext: NSManagedObjectContext = {
        
        let moc = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        moc.parentContext = DataManager.sharedInstance.managedObjectContext
        return moc
        }()
    
    
    private func saveChanges() {
        
        if let myTopic = myTopic {
            
            myTopic.name = titleCellView!.title
            myTopic.comment = titleCellView!.comment
            myTopic.latitude = LocationManager.sharedInstance.location?.coordinate.latitude
            myTopic.longitude = LocationManager.sharedInstance.location?.coordinate.longitude
            myTopic.locationName = LocationManager.sharedInstance.locationName
            
            let user = Author.user(inContext: managedObjectContext)
            user.update(withTopic: myTopic)
            
            do {
                try managedObjectContext.save()
                self.myTopic = nil
                managedObjectContext.reset()
            } catch {
                NSLog("unable to save topic")
                abort()
            }
        }
    }
    
    
    private func discardChanges() {
        
        myTopic = nil
        managedObjectContext.reset()
    }

    
    
    //MARK: - TableView
    
    private let titleCellViewNibName = "TopicCreationTitleTableViewCell"
    private let titleCellViewIdentifier = "titleCell"
    private let imageCellViewNibName = "TopicImageTableViewCell"
    private let imageCellViewIdentifer = "imageCell"
    private let buttonCellViewNibName = "TopicCreationButtonTableViewCell"
    private let buttonCellViewIdentifer = "buttonCell"
    
    private let titleCellHeight = CGFloat(150)
    private let imageCellHeight = CGFloat(275)
    private let buttonCellHeight = CGFloat(50)

    private func setupTableView() {
     
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.backgroundColor = UIColor.background()

        let nib = UINib(nibName: titleCellViewNibName, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: titleCellViewIdentifier)
        
        let nib1 = UINib(nibName: imageCellViewNibName, bundle: nil)
        tableView.registerNib(nib1, forCellReuseIdentifier: imageCellViewIdentifer)
        
        let nib2 = UINib(nibName: buttonCellViewNibName, bundle: nil)
        tableView.registerNib(nib2, forCellReuseIdentifier: buttonCellViewIdentifer)
    }
    
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return titleCellHeight
        }
        
        if imageLoaded() {
            return imageCellHeight
        }
        else {
            return buttonCellHeight
        }
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell: UITableViewCell
        
        if indexPath.row == 0 {
            
            titleCellView = tableView.dequeueReusableCellWithIdentifier(titleCellViewIdentifier) as? TopicCreationTitleTableViewCell
            titleCellView!.delegate = self
            titleCellView!.title = myTopic?.name
            titleCellView!.comment = myTopic?.comment
            
            titleCellView!.becomeFirstResponder()
            cell = titleCellView!
        }
        else {
            
            if imageLoaded() {
                
                imageCellView = tableView.dequeueReusableCellWithIdentifier(imageCellViewIdentifer) as? TopicImageTableViewCell
                imageCellView!.topicImageView?.image = myTopic?.image
                cell = imageCellView!
            }
            else {
                
                let theCell = tableView.dequeueReusableCellWithIdentifier(buttonCellViewIdentifer) as! TopicCreationButtonTableViewCell
                theCell.delegate = self
                cell = theCell
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
        
        dismissViewControllerAnimated(true) { () -> Void in }
    }
    
    
    
    //MARK: - TopicCreationTitleTableViewCellDelegate
    
    func titleViewTitleFieldDidChange(text: String?) {
        
        if let cnt = text?.characters.count {
            navigationItem.rightBarButtonItem?.enabled = cnt > 0
        }
        else {
            navigationItem.rightBarButtonItem?.enabled = false
        }
    }
    
    
    
    //MARK: - TopicCreationButtonTableViewCellDelegate
    
    func buttonViewButtonDidPress(action: TopicCreationButtonTableViewCell.ButtonAction) {
        
        if let myTopic = myTopic {
            myTopic.name = titleCellView?.title
            myTopic.comment = titleCellView?.comment
        }
        
        if action == .Camera {
            
            titleCellView?.resignFirstResponder()
            operationQueue().addOperation(CameraOperation(presentationController: self, sourceType: .Camera))
        }
        else {
            
            titleCellView?.resignFirstResponder()
            operationQueue().addOperation(CameraOperation(presentationController: self, sourceType: .PhotoLibrary))
        }
    }
    
    
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        myTopic?.setImage(image, size: CGSizeMake(800, 800), quality: 0.8)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

}
