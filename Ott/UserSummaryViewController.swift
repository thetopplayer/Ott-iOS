//
//  UserSummaryViewController.swift
//  Ott
//
//  Created by Max on 6/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit



class UserSummaryViewController: ViewController {

    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var handleTextLabel: UILabel!
    @IBOutlet weak var bioTextLabel: UILabel!
    @IBOutlet weak var summaryContainerView: UIView!
    @IBOutlet weak var tableContainerView: UIView!
    
    private var topicTableViewController: TopicMasterViewController


    //MARK: - Lifecycle
    
    required init?(coder aDecoder: NSCoder) {
        
        topicTableViewController = TopicMasterViewController()
        
        super.init(coder: aDecoder)
        addChildViewController(topicTableViewController)
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

        summaryContainerView.backgroundColor = UIColor.whiteColor()
        summaryContainerView.addBorder(withColor: UIColor(white: 0.8, alpha: 1.0))
        
        let scanButton = UIBarButtonItem(image: UIImage(named: "QRCode"), style: .Plain, target: self, action: "presentTopicScanViewController:")
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
        
        if let bio = currentUser().bio {
            bioTextLabel.text = bio
        }
        
        if currentUser().hasImage {
            
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
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleSelectionDidChangeNotification:", name: TopicMasterViewController.Notification.selectionDidChange, object: topicTableViewController)
        
        didStartObservations = true
    }
    
    
    private func endObservations() {
        
        if didStartObservations == false {
            return
        }
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
        didStartObservations = false
    }
    
    
    func handleSelectionDidChangeNotification(notification: NSNotification) {
        
        (navigationController as! NavigationController).presentTopicDetailViewController(withTopic: topicTableViewController.selection)
    }
    
    
    
    //MARK: - Actions
    
    @IBAction func presentTopicCreationAction(sender: AnyObject) {
        
        (navigationController as! NavigationController).presentTopicCreationViewController()
    }
    
    
    @IBAction func presentTopicScanViewController(sender: AnyObject) {
        
        (navigationController as! NavigationController).presentTopicScanViewController()
    }

}
