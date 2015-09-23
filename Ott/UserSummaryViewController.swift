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
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var summaryContainerView: UIView!
    @IBOutlet weak var viewSelectionSegmentedControl: UISegmentedControl!
    @IBOutlet weak var authoredTopicsContainerView: UIView!
    @IBOutlet weak var authoredPostsContainerView: UIView!
    @IBOutlet weak var followingContainerView: UIView!
    @IBOutlet weak var followersContainerView: UIView!
    
  
    
    
    //MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
     }
    
    
    override func viewDidLoad() {

        super.viewDidLoad()
        
        view.backgroundColor = UIColor.background()
        setupNavigationBar()
        setupUserDetailView()
        setupChildren()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        updateDisplayedInformation()
    }
    
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
    }

    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear(animated)
    }
    
    
    override func didReceiveMemoryWarning() {
 
        super.didReceiveMemoryWarning()
     }

    
    
    //MARK: - Display
    
    private func setupNavigationBar() {
        
        navigationItem.titleView = {
            
            let button = UIButton(frame: CGRectMake(0, 0, 40, 32))
            let image = UIImage(named: "action")
            button.setImage(image, forState: UIControlState.Normal)
            button.addTarget(self, action: "handleExportAction:", forControlEvents: UIControlEvents.TouchUpInside)
            
            return button
            }()
        
        let scanButton = UIBarButtonItem(image: UIImage(named: "scan"), style: .Plain, target: self, action: "presentTopicScanViewController:")
        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "presentTopicCreationAction:")
        navigationItem.leftBarButtonItem = scanButton
        navigationItem.rightBarButtonItem = createButton
    }
    
    
    private func setupUserDetailView() {
        
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
        
        settingsButton.addRoundedBorder(withColor: UIColor.tint())
        
        // start in tab 1
        viewSelectionSegmentedControl.selectedSegmentIndex = 0
        viewSwitchAction(viewSelectionSegmentedControl)
    }
    
    
    let authoredTopicsViewController: AuthoredTopicsViewController = {
        
        let controller = AuthoredTopicsViewController(nibName: "AuthoredTopicsViewController", bundle: nil)
        controller.user = currentUser()
        return controller
        }()
    
    
    private func setupChildren() {
        
        addChildViewController(authoredTopicsViewController)
        authoredTopicsViewController.view.frame = authoredTopicsContainerView.bounds
        
        let mask = UIViewAutoresizing.FlexibleWidth.rawValue | UIViewAutoresizing.FlexibleHeight.rawValue
        authoredTopicsViewController.view.autoresizingMask = UIViewAutoresizing(rawValue: mask)
        authoredTopicsContainerView.addSubview(authoredTopicsViewController.tableView)

    }
    
    
    private func updateDisplayedInformation() {
        
        nameTextLabel.text = currentUser().name
        handleTextLabel.text = currentUser().handle
        
        let bioText = currentUser().bio != nil ? currentUser().bio : "(no bio)"
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
    
    private func startObservations() {
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleUserDidChangeNotification:", name: UpdateUserOperation.Notifications.DidUpdate, object: nil)
    }
    
    
    private func endObservations() {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    func handleUserDidChangeNotification(notification: NSNotification) {
        
        updateDisplayedInformation()
    }
    
    
    
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

    
    @IBAction func viewSwitchAction(sender: UISegmentedControl) {
        
        let view0 = authoredTopicsContainerView
        let view1 = authoredPostsContainerView
        let view2 = followingContainerView
        let view3 = followersContainerView
        
        switch sender.selectedSegmentIndex {
            
        case 0:
            view0.hidden = false
            view1.hidden = true
            view2.hidden = true
            view3.hidden = true
            
        case 1:
            view0.hidden = true
            view1.hidden = false
            view2.hidden = true
            view3.hidden = true
            
        case 2:
            view0.hidden = true
            view1.hidden = true
            view2.hidden = false
            view3.hidden = true
            
        case 3:
            view0.hidden = true
            view1.hidden = true
            view2.hidden = true
            view3.hidden = false
            
        default:
            assert(false)
        }
    }
    
    
    @IBAction func presentTopicCreationAction(sender: AnyObject) {
        
        if let navController = navigationController as? NavigationController {
            navController.presentTopicCreationViewController()
        }
    }
    
    
    @IBAction func presentTopicScanViewController(sender: AnyObject) {
        
        if let navController = navigationController as? NavigationController {
            navController.presentTopicScanViewController()
        }
    }
    
    
    @IBAction func presentSettingsView(sender: AnyObject) {
        
        let segueIdentifier = "segueToSettingsView"
        performSegueWithIdentifier(segueIdentifier, sender: self)
    }
    
    
    @IBAction func handleExportAction(sender: AnyObject) {
        
        if let navController = navigationController as? NavigationController {
            navController.presentExportViewController(withUser: currentUser())
        }
    }
    
    
    
    //MARK: - UIImagePickerControllerDelegate
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String : AnyObject]?) {
        
        let resizedImage = image.resized(toSize: CGSizeMake(200, 200))
        self.avatarImageView.image = resizedImage
        
        currentUser().setImage(resizedImage)
        PostQueue.sharedInstance.addOperation(UpdateUserOperation())
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }

    
    // MARK: - Navigation
    
    @IBAction override func unwindForSegue(unwindSegue: UIStoryboardSegue, towardsViewController subsequentVC: UIViewController) {
        
    }
    
}
