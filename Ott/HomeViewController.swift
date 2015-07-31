//
//  HomeViewController.swift
//  Ott
//
//  Created by Max on 6/24/15.
//  Copyright © 2015 Senisa Software. All rights reserved.
//

import UIKit



class HomeViewController: ViewController {

    @IBOutlet weak var userContainerView: UIView!
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var handleTextLabel: UILabel!
    @IBOutlet weak var summaryContainerView: UIView!
    @IBOutlet weak var summaryTextLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    private var topicTableViewController: TopicMasterViewController
    private let tableHeaderNibName = "HomeTableHeaderView"
    private let headerReuseName = "headerView"
    private let headerViewHeight = CGFloat(50)
    


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
        
        topicTableViewController.fetchPredicate = NSPredicate(format: "author = %@", currentUser())
        topicTableViewController.tableView = tableView
        topicTableViewController.setHeaderView(nibName: tableHeaderNibName, reuseIdentifier: headerReuseName, height: headerViewHeight)
        topicTableViewController.viewDidLoad()
        
        let scanButton = UIBarButtonItem(image: UIImage(named: "QRCode"), style: .Plain, target: self, action: "presentTopicScanViewController:")
        let createButton = UIBarButtonItem(barButtonSystemItem: .Compose, target: self, action: "presentTopicCreationAction:")
        navigationItem.leftBarButtonItem = scanButton
        navigationItem.rightBarButtonItem = createButton

        startObservations()
    }
    
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear(animated)
        updateDisplayedInformation()
        topicTableViewController.update()
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
        
        let user = currentUser()
        
        self.nameTextLabel.text = currentUser().name
        self.handleTextLabel.text = currentUser().username
        if currentUser().hasAvatar {
            
            currentUser().getAvatar {
                
                (success: Bool, image: UIImage?) -> Void in
                
                if success {
                    self.avatarImageView.image = image
                }
                else {
                    print("error getting avatar")
                    self.avatarImageView.image = AuthorObject.defaultAvatar
                }
            }
        }
        else {
            avatarImageView.image = AuthorObject.defaultAvatar
        }
        
        summaryTextLabel.attributedText = self.attributedUserDetails(user)
    }
    
    
    private func attributedUserDetails(user: AuthorObject) -> NSAttributedString {
        
        var numberAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.darkGrayColor()]
        numberAttributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 15)
        
        let s1 = NSMutableAttributedString(string: "\(user.numberOfTopics)", attributes: numberAttributes)
        
        var textAttributes : [String : AnyObject] = [NSForegroundColorAttributeName : UIColor.grayColor()]
        textAttributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Regular", size: 12)
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        
        var s2: NSAttributedString
        let t = user.numberOfTopics == 1 ? " TOPIC  -  " : " TOPICS  -  "
        s2 = NSAttributedString(string: t, attributes: textAttributes)
        
        let s3 = NSMutableAttributedString(string: "\(user.numberOfPosts)", attributes: numberAttributes)
        
        var s4: NSAttributedString
        let p = user.numberOfPosts == 1 ? " POSTS" : " POSTS"
        s4 = NSAttributedString(string: p, attributes: textAttributes)
        s3.appendAttributedString(s4)
        
        s1.appendAttributedString(s2)
        s1.appendAttributedString(s3)
        return s1
    }

    
    
    //MARK: -  Observations {
    
    private var didStartObservations = false
    private func startObservations() {
        
        if didStartObservations {
            return
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "handleDidUpdateUserNotification:", name: DataManager.Notification.DidUpdateUser, object: nil)
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
    
    
    func handleDidUpdateUserNotification(notification: NSNotification) {
        
        // refetch to update info
//        myUser = nil
//        myUser = Author.user(inContext: managedObjectContext)
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
