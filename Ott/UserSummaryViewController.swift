//
//  UserSummaryViewController.swift
//  Ott
//
//  Created by Max on 6/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit



class UserSummaryViewController: ViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var handleTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var summaryContainerView: UIView!
    @IBOutlet weak var tableContainerView: UIView!
    
    
    //MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
     }
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        view.backgroundColor = UIColor.background()

        userContainerView.backgroundColor = UIColor.whiteColor()
        userContainerView.addBorder()
        userContainerView.addDownShadow()
        
        avatarImageView.addRoundedBorder()
        avatarImageView.contentMode = .ScaleAspectFill
        avatarImageView.layer.masksToBounds = true
        avatarImageView.userInteractionEnabled = true
        let tapGR = UITapGestureRecognizer()
        tapGR.addTarget(self, action: "addAvatar:")
        avatarImageView.addGestureRecognizer(tapGR)
        
        
        handleTextLabel.textColor = UIColor.tint()
        
        summaryContainerView.backgroundColor = UIColor.whiteColor()
        summaryContainerView.addBorder(withColor: UIColor(white: 0.8, alpha: 1.0))
        
        let scanButton = UIBarButtonItem(image: UIImage(named: "scan"), style: .Plain, target: self, action: "presentTopicScanViewController:")
        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "presentTopicCreationAction:")
        navigationItem.leftBarButtonItem = scanButton
        navigationItem.rightBarButtonItem = createButton

        startObservations()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        updateDisplayedInformation()
//        topicTableViewController.update()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
    }

    
    override func didReceiveMemoryWarning() {
 
        super.didReceiveMemoryWarning()
     }
    
    
    deinit {
        endObservations()
    }

    
    
    //MARK: - Display
    
    private func updateDisplayedInformation() {
        
        nameTextLabel.text = currentUser().name
        handleTextLabel.text = currentUser().username
        
        let bioText = currentUser().bio != nil ? currentUser().bio : ""
        bioTextLabel.text = bioText
        
        if currentUser().hasImage() {
            
            currentUser().getImage {
                
                (success: Bool, image: UIImage?) -> Void in
                
                if success {
                    self.avatarImageView.image = image
                }
                else {
                    print("error getting avatar")
                    self.avatarImageView.image = User.defaultAvatar
                }
            }
        }
        else {
            avatarImageView.image = User.defaultAvatar
        }
        
    }

    
    
    //MARK: -  Observations {
    
    private var didStartObservations = false
    private func startObservations() {
        
        if didStartObservations {
            return
        }
        
        didStartObservations = true
    }
    
    
    private func endObservations() {
        
        if didStartObservations == false {
            return
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        didStartObservations = false
    }
    
    
//    func handleSelectionDidChangeNotification(notification: NSNotification) {
//        
//        (navigationController as! NavigationController).presentTopicDetailViewController(withTopic: topicTableViewController.selection)
//    }
    
    
    
    //MARK: - Actions
    
    @IBAction func addAvatar(sender: AnyObject) {
        
        func presentOptionsSheet() {
            
            let alertViewController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
            
            let libraryAction = UIAlertAction(title: "Photo Library", style: UIAlertActionStyle.Default, handler: { action in
                
                self.operationQueue.addOperation(CameraOperation(presentationController: self, sourceType: .PhotoLibrary))
            })
            
            let cameraAction = UIAlertAction(title: "Take Photo", style: UIAlertActionStyle.Default, handler: { action in
                
                self.operationQueue.addOperation(CameraOperation(presentationController: self, sourceType: .Camera))
            })
            
            let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: { action in
                
            })
            
            alertViewController.addAction(libraryAction)
            alertViewController.addAction(cameraAction)
            alertViewController.addAction(cancelAction)
            
            presentViewController(alertViewController, animated: true, completion: nil)
        }
        
        presentOptionsSheet()
    }

    
    @IBAction func presentTopicScanViewController(sender: AnyObject) {
        
        (navigationController as! NavigationController).presentTopicScanViewController()
    }

    @IBAction func avatarTapAction(sender: AnyObject) {
        
        (navigationController as! NavigationController).presentTopicScanViewController()
    }
    

    /*
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
    */
    
    
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let resizedImage = image.resized(toSize: CGSizeMake(200, 200))
        self.avatarImageView.image = resizedImage
        
        currentUser().setImage(resizedImage)
        let updateOperation = UpdateUserOperation(user: currentUser())
        PostQueue.sharedInstance.addOperation(updateOperation)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

}
