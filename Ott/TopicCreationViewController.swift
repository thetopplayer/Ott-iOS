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
    private var imageCellView: ImageTableViewCell?
    
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupTableView()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        
        if myTopic == nil {
            myTopic = TopicObject()
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
    
    
    
    //MARK: - Data
    
    var myTopic: TopicObject?
    
    private func saveChanges() {
        
        let topic = myTopic!
        
        topic.name = titleCellView!.title
        topic.comment = titleCellView!.comment
        topic.location = LocationManager.sharedInstance.location?.coordinate
        topic.locationName = LocationManager.sharedInstance.locationName
        currentUser().addTopic(topic)
        
        currentUser().save()
    }
    
    
    private func discardChanges() {
        
        myTopic = nil
    }

    
    
    //MARK: - TableView
    
    private let titleCellViewNibName = "TopicCreationTitleTableViewCell"
    private let titleCellViewIdentifier = "titleCell"
    private let imageCellViewNibName = "TopicCreationImageTableViewCell"
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
        
        if myTopic!.hasImage {
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
            
            if myTopic!.hasImage {
                
                imageCellView = tableView.dequeueReusableCellWithIdentifier(imageCellViewIdentifer) as? ImageTableViewCell
//                imageCellView!.topicImageView?.image = myTopic?.image
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
        
        myTopic!.name = titleCellView?.title
        myTopic!.comment = titleCellView?.comment
        
        
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
